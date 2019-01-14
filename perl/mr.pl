#! /usr/bin/perl


use strict;
use warnings;


#---
# ouverture fichiers et argument

open (my $FH_IN, "<$ARGV[0]");

open (my $FH_OUT, ">$ARGV[1]");

open (my $FH_ASS, ">$ARGV[2]");

my $seuil = $ARGV[3];

#---
# parcourt du fichier swpOp

my %HoH;

my $ind_clu = 1;

while (my $ligne = <$FH_IN>) {
  
  my @part_ligne = split /\t/, $ligne;

  # recup evalue
  my $evalue = $part_ligne[1];
  if ($evalue <= $seuil) {

    # ass
    print $FH_ASS $ligne;

    # recup echs
    my @part_ligne2 = split /-/, $part_ligne[0];

    # recup no_clu
    my @part_ligne3 = split /_/, $part_ligne2[0];
    my $no_clu = $part_ligne3[0];
    print $FH_OUT "\t$no_clu";

    # remplissage hash
    for (my $i = 1; $i <= $#part_ligne2; $i++) {
      my @ech_abds = split /_/, $part_ligne2[$i];
      $HoH{$ech_abds[0]}{$no_clu} = $ech_abds[1];
    }

    $ind_clu++;
  }

}


#---
# écriture

for my $clu (sort {$a <=> $b} keys %HoH) {
  print $FH_OUT "\n$clu";
  for my $ech (sort {$a <=> $b} keys %{$HoH{$clu}}) {
    print $FH_OUT "\t$HoH{$clu}{$ech}";
  }
}


