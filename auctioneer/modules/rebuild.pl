#!/usr/bin/perl

print "Scanning plugins folder...\n";

open OUTPUT, "> Active.xml";
print OUTPUT qq(<Ui xmlns="http://www.blizzard.com/wow/ui/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.blizzard.com/wow/ui/ ..\\FrameXML\\UI.xsd">\n);

$active = $inactive = 0;
for $fn (<auc-*>) {
	if (-d $fn) {
		if (-f "$fn/Embed.xml") {
			$active++;
			print "  + Activating: $fn\n";
			print OUTPUT "\t<Include file=\"$fn\\Embed.xml\"/>\n";
		}
		else {
			$invalid++;
			print "  ! Module \"$fn\" is not embeddable\n";
		}
	}
}
print OUTPUT "</Ui>";

print "Activated: $active modules.\n";
if ($invalid > 0) {
	print "WARNING: There were $invalid non-embeddable modules detected.\n";
	print "Sometimes Auctioneer modules are not embeddable,\n";
	print "and need to be installed as normal addons.\n";
	print "Embeddable modules will have an Embed.xml file in the folder.\n";
	print "Press <RETURN> to exit...";
	<>;
}
else {
	sleep(2.5);
}

