#	Itemizer Addon for World of Warcraft(tm).
#	Version: <%version%> (<%codename%>)
#	Revision: $Id$
#
#	Itemizer Tables Updater.
#	Perl Script that scans the converted DBC files and generates the Itemizer cache tables.
#
#	License:
#		This program is free software; you can redistribute it and/or
#		modify it under the terms of the GNU General Public License
#		as published by the Free Software Foundation; either version 2
#		of the License, or (at your option) any later version.
#
#		This program is distributed in the hope that it will be useful,
#		but WITHOUT ANY WARRANTY; without even the implied warranty of
#		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#		GNU General Public License for more details.
#
#		You should have received a copy of the GNU General Public License
#		along with this program(see GPL.txt); if not, write to the Free Software
#		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# VERY Useful
use strict;
use warnings;
use diagnostics;
print "\n\nStarting to generate Itemizer's cache tables.\n";

# Scalar Variable Declarations
my $count = 1;
my $keyCount;
my $ItemTables;
my $EnchantDBC;
my $RandomPropDBC;
my $numberOfRandomProps = 1;

# Hash Variable Declarations
my %itemSuffixes;
my %enchantKeys;
my %interestedEnchants;

# File Handle Declarations
open($ItemTables, ">", "ItemTables.lua");
open($EnchantDBC, "SpellItemEnchantment.dbc.csv")
	or die "\n\nI'm sorry Dave, I can't do that.\n\n\n\"SpellItemEnchantment.dbc.csv\" file missing.\n\n";
open($RandomPropDBC, "ItemRandomProperties.dbc.csv")
	or die "\n\nI'm sorry Dave, I can't do that.\n\n\n\"ItemRandomProperties.dbc.csv\" file missing.\n\n";

if(not($EnchantDBC and $RandomPropDBC)){
	die "\n\nI'm sorry Dave, I can't do that.\n\n\n\"SpellItemEnchantment.dbc.csv\" or \"ItemRandomProperties.dbc.csv\" file missing.\n\n";
}

# Print the warning and licence boilerplate first
print "Printing the Warning and Boilerplate.\n";
print $ItemTables "--[[
	File automatically generated
	DO NOT EDIT!!!

	Itemizer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: \$Id\$

	Itemizer Tables.
	Cache tables that Itemizer uses to save storage space.

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]\n\n";

# First up is the RandomProps table
print "Generating the RandomProps table.\n";
print $ItemTables "--[[
	This is the RandomProps table.
	This table holds a string that contains two, three or four numbers separated by a colon \":\".
	The first number is the key to the suffix of the randomProp found in the Suffixes table (duh!).
	The other one, two or three numbers are the keys to the enchants that the randomProp is comprised of.
 ]]\n";
print $ItemTables "ItemizerRandomProps = {\n";
while(<$RandomPropDBC>){
	chomp;
	my @line = split(",");

	my $curLine;
	if ($line[2]){
		$numberOfRandomProps++;
		if($itemSuffixes{$line[7]}){
			$line[7] = $itemSuffixes{$line[7]};

			}else{
				$itemSuffixes{$line[7]} = $count;
				$line[7] = $count++;
		}

		$curLine = $line[7].":".$line[2];
		$interestedEnchants{$line[2]} = 1;

		if ($line[3]){
			$curLine = $curLine.":".$line[3];
			$interestedEnchants{$line[3]} = 1;

			if ($line[4]){
				$curLine = $curLine.":".$line[4];
				$interestedEnchants{$line[4]} = 1;
			}
		}
	}

	if ($curLine){
		print $ItemTables "\t";
		print $ItemTables "[$line[0]] = \"$curLine\",";
		print $ItemTables "\n";
	}
}
print $ItemTables "}\n\n";

# Next up is the item suffixes table
print "Generating the Suffixes table.\n";
print $ItemTables "--[[
	This is the Suffixes table.
	This table contains the string of the randomProp's suffix (\"of the Owl\").
	This table is indexed by a number generated at random for that specific suffix.
 ]]\n";
print $ItemTables "ItemizerSuffixes = {\n";
my $key;
foreach $key (sort { $itemSuffixes{$a} <=> $itemSuffixes{$b} } keys %itemSuffixes) {
	print $ItemTables "\t[", $itemSuffixes{$key}, "] = \"", $key, "\",\n";
}
print $ItemTables "}\n\n";

# Last is the Enchants table
print "Generating the Enchants table.\n";
print $ItemTables "--[[
	This is the Enchants table.
	This table holds the quantity of the modifier and a key to the modifier type.
	The key is comprised of two strings united by a dash character \"-\".
	The left side of the dash is a two letter string that encodes the class of modifier (Per five, Stat, Weapon Skill, etc).
	The right part of the dash is a three letter string that encodes the type of modification (Fire, Sword, Health, Intellect).
 ]]\n";
print $ItemTables "ItemizerEnchants = {\n";
while(<$EnchantDBC>){
	chomp;
	my @line = split(",");

	my $word2;
	my $word1;
	my $curLine;
	my $ammount;
	if ($interestedEnchants{$line[0]}){
		$curLine = $line[13];
	}

	if ($curLine){
		if($curLine =~ m/\+(\d+)\s(\w*)\s(\w*)/i){
			$word2 = $3;
			$word1 = $2;
			$ammount = $1;
			if(($word2 eq "Resistance") or ($word1 eq "Resist")){ # Got to account for a Blizzard typo here
				$word2 = "Re";

				$word1 =~ s/Fire/Fir/i;
				$word1 =~ s/Holy/Hol/i;
				$word1 =~ s/Frost/Fro/i;
				$word1 =~ s/Nature/Nat/i;
				$word1 =~ s/Resist/Sha/i;# Typo here
				$word1 =~ s/Arcane/Arc/i;
				$word1 =~ s/Shadow/Sha/i;

			}elsif($word2 =~ m/(Spell|Spells)/i){
				$word2 = "Sp";

				$word1 =~ s/Fire/Fir/i;
				$word1 =~ s/Holy/Hol/i;
				$word1 =~ s/Frost/Fro/i;
				$word1 =~ s/Nature/Nat/i;
				$word1 =~ s/Arcane/Arc/i;
				$word1 =~ s/Healing/Hea/i;
				$word1 =~ s/Shadow/Sha/i;

			}elsif($word2 eq "every"){
				$word2 = "P5";

				$word1 =~ s/Mana/Man/i;
				$word1 =~ s/Health/Het/i;

			}elsif($word2 eq "Slaying"){
				$word2 = "Sl";
				$word1 = "Bea";

			}elsif($word2 eq "Power"){
				$word2 = "Atk";
				$word1 = "Mel";

			}elsif($word2 eq "and"){
				$word2 = "Sp";
				$word1 = "D&H";

			}elsif($word2 eq "Attack"){
				$word2 = "Atk";
				$word1 = "Ran";
			}
			print $ItemTables "\t";
			print $ItemTables "[$line[0]] = {$ammount, \"$word2-$word1\",},\t--$curLine";
			print $ItemTables "\n";

			$enchantKeys{"$word2-$word1"} = 1;
		}elsif ($curLine =~ m/\+(\d+)\s(\w*)/i){
			$word1 = $2;
			$ammount = $1;

			$word1 =~ s/Spirit/Spi/i;
			$word1 =~ s/Agility/Agi/i;
			$word1 =~ s/Armor/Arm/i;
			$word1 =~ s/Intellect/Int/i;
			$word1 =~ s/Strength/Str/i;
			$word1 =~ s/Stamina/Sta/i;
			$word1 =~ s/Defense/Def/i;
			$word1 =~ s/Damage/Dam/i;
			print $ItemTables "\t";
			print $ItemTables "[$line[0]] = {$ammount, \"Ba-$word1\",},\t--$curLine";
			print $ItemTables "\n";

			$enchantKeys{"Ba-$word1"} = 1;
		}elsif($curLine =~ m/Two-Handed\s(\w*)\sSkill\s\+(\d*)/i){
			$word1 = $1;
			$ammount = $2;

			$word1 =~ s/Axe/Axe/i;
			$word1 =~ s/Bow/Bow/i;
			$word1 =~ s/Gun/Gun/i;
			$word1 =~ s/Mace/Mac/i;
			$word1 =~ s/Sword/Swo/i;
			$word1 =~ s/Dagger/Dag/i;
			print $ItemTables "\t";
			print $ItemTables "[$line[0]] = {$ammount, \"TH-$word1\",},\t--$curLine";
			print $ItemTables "\n";

			$enchantKeys{"TH-$word1"} = 1;
		}elsif($curLine =~ m/(\w*)\sSkill\s\+(\d*)/i){
			$word1 = $1;
			$ammount = $2;

			$word1 =~ s/Axe/Axe/i;
			$word1 =~ s/Ase/Axe/i; # Yet another blizzard typo
			$word1 =~ s/Bow/Bow/i;
			$word1 =~ s/Gun/Gun/i;
			$word1 =~ s/Mace/Mac/i;
			$word1 =~ s/Sword/Swo/i;
			$word1 =~ s/Dagger/Dag/i;
			print $ItemTables "\t";
			print $ItemTables "[$line[0]] = {$ammount, \"OH-$word1\",},\t--$curLine";
			print $ItemTables "\n";

			$enchantKeys{"OH-$word1"} = 1;
		}
	}
}
print $ItemTables "}\n\n";

# Just for debugging
print "Printing debugging info.\n";
print $ItemTables "--[[
	This section is the debugging info, it shows the final tallies for the enchants and randomProps.";

print $ItemTables "\n\n\t", "Number of randomProps: ", $numberOfRandomProps, "\n";
print $ItemTables "\n\t", "Number of item suffixes: ", $keyCount = keys(%itemSuffixes), "\n";
print $ItemTables "\n\t", "Number of enchants: ", $keyCount = keys(%interestedEnchants), "\n";
print $ItemTables "\n\t", "Number of unique enchant keys: ", $keyCount = keys(%enchantKeys), "\n";
print $ItemTables "]]\n";

# Close our file handles
close($ItemTables);
close($EnchantDBC);
close($RandomPropDBC);
print "Done!\n\n";