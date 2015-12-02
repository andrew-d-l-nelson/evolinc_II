#!/usr/bin/perl

#Usage: perl <tecate_script.pl> <listfile>
use strict;
use warnings;

my $listFile = $ARGV[0];
my @list;

open (AFILE, $listFile) or die "cannot open $listFile\n";
while (my $line = <AFILE>) {
        chomp $line;
        push @list, $line;
}
close AFILE;
print "\n@list\n\n"; #to test the elements of the array

for (my $i=0; $i<@list; $i++) {
        my $file = $list[$i];
        system("raxmlHPC -s $file -n Raxml_$file -m GTRGAMMA -x 12345 -# 100 -f a");
		system("mv Raxml_$file Raxml_families/");
}