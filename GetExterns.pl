#!/usr/bin/perl
use HTTP::DAV;

for $propfile (<*/.svn/dir-prop-base>) {
	$dir = $propfile;
	$dir =~ s/\/\.svn\/dir-prop-base//;

	%p = readPropFile($propfile);

	if ($ext = $p{"svn:externals"}) {
		@l = split(/[\r\n]+/, $ext);
		for $l (@l) {
			if ($l) {
				($folder, $uri) = split(/\s+/, $l, 2);
				$uris{$uri} = 1;
				push(@{$uridata->{$uri}}, "$dir/$folder");
			}
		}
	}
}

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



