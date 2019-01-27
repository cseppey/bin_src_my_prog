#! /usr/bin/perl

use warnings;
use strict;


open (my $IN_FH, "<$ARGV[0]");

my $prefix = $ARGV[1];
my $out_prot = $prefix . '_prot.fa';
my $out_nucl = $prefix . '_nucl.fa';

open (my $OUT_PROT_FH, ">$out_prot");
open (my $OUT_NUCL_FH, ">$out_nucl");

#---

my %aacode = ( # bacterial archaea code
  TTT => "F", TTC => "F", TTA => "L", TTG => "L",
  TCT => "S", TCC => "S", TCA => "S", TCG => "S",
  TAT => "Y", TAC => "Y", TAA => "_", TAG => "_",
  TGT => "C", TGC => "C", TGA => "_", TGG => "W",
  CTT => "L", CTC => "L", CTA => "L", CTG => "S",
  CCT => "P", CCC => "P", CCA => "P", CCG => "P",
  CAT => "H", CAC => "H", CAA => "Q", CAG => "Q",
  CGT => "R", CGC => "R", CGA => "R", CGG => "R",
  ATT => "I", ATC => "I", ATA => "I", ATG => "M",
  ACT => "T", ACC => "T", ACA => "T", ACG => "T",
  AAT => "N", AAC => "N", AAA => "K", AAG => "K",
  AGT => "S", AGC => "S", AGA => "R", AGG => "R",
  GTT => "V", GTC => "V", GTA => "V", GTG => "V",
  GCT => "A", GCC => "A", GCA => "A", GCG => "A",
  GAT => "D", GAC => "D", GAA => "E", GAG => "E",
  GGT => "G", GGC => "G", GGA => "G", GGG => "G",
);

#---

my $titre;
while (my $ligne = <$IN_FH>) {
  if ($ligne =~ /^>/) {
    $titre = $ligne;
  }
  else {
    $ligne = substr $ligne, $ARGV[2];
    $ligne = substr $ligne, 0, -($ARGV[3]+1);

    my $l = length $ligne;
    
    if (($ligne !~ /^((.{3})*?)(TGA|TAG|TAA).*/) & ($l % 3 == 0)) {

      print $OUT_NUCL_FH $titre;
      print $OUT_NUCL_FH "$ligne\n";

      print $OUT_PROT_FH $titre;

      while ($l >= 3) {
        my $codon = substr $ligne, 0, 3;

        if ($codon =~ 'N') {
          print $OUT_PROT_FH '-';
        }
        else {
          print $OUT_PROT_FH "$aacode{$codon}";
        }

        $ligne = substr $ligne, 3;
        $l = length $ligne;
      }
      print $OUT_PROT_FH "\n";
    }
  }

}

close $IN_FH;
close $OUT_NUCL_FH;
close $OUT_PROT_FH;
