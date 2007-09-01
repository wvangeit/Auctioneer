#!/usr/bin/perl
use HTTP::DAV;

getExterns();

for $uri (keys %uris) {
	print "URI: $uri\n";
	my @folders = @{$uridata->{$uri}};

	$d = HTTP::DAV->new();
	$d->open($uri);
	if ($r = $d->propfind()) {
		if ($r->is_collection) {
			$rl = $r->get_resourcelist();
			for $ri ($rl->get_resources) {
				$filename = $ri->get_property("rel_uri");
				$res = $ri->get;
				if ($res->is_success) {
					$data = $ri->get_content;
					print " - $filename\n";
					for $folder (@folders) {
						if (!$cleaned{$folder}) {
							remove($folder);
							mkdir($folder);
							$cleaned{$folder}++;
						}
						print "  => $folder/$filename\n";
						open DATA, "> $folder/$filename";
						print DATA $data;
						close DATA;
					}
				}
			}
		}
	}
}

sub remove {
	my ($arg) = @_;
	if (-d $arg) {
		remove("$arg/.svn");
		for $entry (<$arg/*>) {
			if (-d $entry) {
				remove($entry);
			}
			else {
				unlink($entry);
			}
		}
		rmdir($arg);
	}
	else {
		unlink($arg);
	}
}

sub progress {
	my ($s, $m) = @_;
	if ($s == 0) { print "Error: $m\n"; }
	if ($s == 1) { print " - $m\n"; }
}

sub readPropFile {
	my ($propfile) = @_;
	my ($read, $propname, $propval, %props);

	open PROP, "< $propfile" || die("Can't open prop file: $propfile");
	while ($read = <PROP>) {
		if ($read !~ /^END$/) {
			if ($read !~ /^K (\d+)$/) { die("BadPropFile: $propfile") }
			read(PROP, $propname, $1);
			<PROP>;
			$read = <PROP>;
			if ($read !~ /^V (\d+)$/) { die("BadPropFile: $propfile") }
			read(PROP, $propval, $1);
			<PROP>;

			$props{$propname} = $propval;
		}
	}
	close PROP;
	return %props
}

sub getExterns {
	my ($dir, $level) = @_;
	$dir = "." unless ($dir);
	$level = 0 unless ($level);
	return if ($level > 10);
	
	processProp($dir);

	my $entry;
	for $entry (<$dir/*>) {
		getExterns($entry, $level+1) if (-d $entry);
	}
}
	
sub processProp {
	my ($dir) = @_;
	my $propfile = "$dir/.svn/dir-prop-base";
	if (-f $propfile) {
		my %p = readPropFile($propfile);
		if ($ext = $p{"svn:externals"}) {
			my @l = split(/[\r\n]+/, $ext);
			my $l;
			for $l (@l) {
				if ($l) {
					my ($folder, $uri) = split(/\s+/, $l, 2);
					$uris{$uri} = 1;
					push(@{$uridata->{$uri}}, "$dir/$folder");
				}
			}
		}
	}
}


