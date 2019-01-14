#! /usr/bin/perl


use strict;
use warnings;


open (my $FH_IN, "<$ARGV[0]");

open (my $FH_OUT, ">$ARGV[1]");

open (my $FH_TMP, "<$ARGV[2]");
my @clu = <$FH_TMP>;
close $FH_TMP;

#---

my $on_off = 1;

my $no_cluster = chomp $clu[0];
my $nb_seq;
my $nb_seq_tot;
my $seq;

my $index_ligne = 0;

print $FH_OUT '>';

while (my $ligne = <$FH_IN>) {

  if ((($ligne =~ /^>\d+$/) || (eof)) && ($index_ligne != 0) ) {
    print $FH_OUT "$no_cluster\_$nb_seq/$nb_seq_tot\n$seq";

    chomp $ligne;
    $no_cluster = $ligne;
    
    $on_off++;
  }

  else {
    if (($on_off == 1) && ($index_ligne != 0)) {
      my @part_ligne = split /\t/, $ligne;
      
      $nb_seq = $part_ligne[0];
      $seq = $part_ligne[1];
      $nb_seq_tot = $nb_seq;

      $on_off--;
    }
    else {
      my @part_ligne = split /\t/, $ligne;
      $nb_seq_tot = $nb_seq_tot + $part_ligne[0];
    }
  }

  $index_ligne++;

}

close $FH_IN;
close $FH_OUT;
