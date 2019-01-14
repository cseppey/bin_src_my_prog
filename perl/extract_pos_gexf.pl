#! /usr/bin/perl

use strict;
use warnings;


open (my $FH_IN, "<$ARGV[0]");
open (my $FH_OUT, ">$ARGV[1]");

while (my $ligne = <$FH_IN>) {
  if ($ligne =~ /<node id="(.*)" label="(.*)">/) {
    print $FH_OUT "$1\t$2\t";
  }
  if ($ligne =~ /<viz:position x="(.*)" y="(.*)">/) {
    print $FH_OUT "$1\t$2\n";
  }
}

