#! /usr/bin/perl


use strict;
use warnings;


open (my $FH_fastq, "<$ARGV[0]");

open (my $FH_primer, "<$ARGV[1]");
my @primers = <$FH_primer>;
close $FH_primer;

#---
# prep tags

my %H_primers = ();
my $reg_check_seq;
my $ind_primer = 0;

print "\nprimers scan\n";

for my $primer (@primers) {

  chomp $primer;
  
  $primer =~ s/R/[AG]/g;
  $primer =~ s/Y/[CT]/g;
  $primer =~ s/S/[GC]/g;
  $primer =~ s/W/[AT]/g;
  $primer =~ s/K/[GT]/g;
  $primer =~ s/M/[AC]/g;
  $primer =~ s/B/[CGT]/g;
  $primer =~ s/D/[AGT]/g;
  $primer =~ s/H/[ACT]/g;
  $primer =~ s/V/[ACG]/g;

  my @parts_ligne = split / /, $primer;

  if ($ind_primer == 0) {
    if ($#ARGV == 4) {
      $reg_check_seq = substr ($parts_ligne[1], $ARGV[3]) . '(.*)' . substr ($parts_ligne[2], 0, -$ARGV[4]);

    } elsif ($#ARGV == 3) {
      $reg_check_seq = substr ($parts_ligne[1], $ARGV[3]) . '(.*)';
  
    } else {
      print "Be shure to format the tag file as follow:\nFile_names\\tForward_tagForwardPrimer\\tBackward_primerBackward_tag or \nFile_names\\tForward_tagForwardPrimer\\tBackward_primer\nThink also to give as input:\ninput_file tag_file output_directory length_forward_tag (length_backward_tag if you have double tag)\n"
    }
  }
  
  my $reg_primer = '(' . $parts_ligne[1] . ')(.*)(' . $parts_ligne[2] . ')' ;

  $H_primers{$reg_primer} = $parts_ligne[0];

  my $path_file = $ARGV[2] . '/' . $parts_ligne[0];
  if (-e $path_file) {
    unlink $path_file;
  } else {
    mkdir $ARGV[2]
  }

  $ind_primer++;

}


#---
# parcourt fastq

my $titre;
my $seq;
my $ind_ligne = 0;

print "\nscan fastq\n";

while (my $ligne = <$FH_fastq>) {
  chomp $ligne;
  
  if ($ind_ligne % 4 == 0) {
    $titre = $ligne;
  }

  if ($ind_ligne % 4 == 1) {
    $seq = $ligne;
  }

  if ($ind_ligne % 4 == 3) {

    my $rev_seq = $seq;
    $rev_seq =~ tr/ATCG/TAGC/;
    $rev_seq = reverse $rev_seq;
  
    if ($seq =~ /$reg_check_seq/) {

      for my $key (keys %H_primers) {
        if ($seq =~ /$key/) {
          
          $ligne = substr $ligne, $+[1], $+[2] - $-[2];
  
          my $path_file = $ARGV[2] . '/' . $H_primers{$key};
  
          open (my $FH_out, ">>$path_file");
          print $FH_out "$titre\n$2\n+\n$ligne\n";
          close $FH_out;
  
          last;
        }
      }
    } elsif ($rev_seq =~ /$reg_check_seq/) {
  
      for my $key (keys %H_primers) {
        if ($rev_seq =~ /$key/) {
          
          $ligne = substr $ligne, $+[1], $+[2] - $-[2];
  
          my $path_file = $ARGV[2] . '/' . $H_primers{$key};
  
          open (my $FH_out, ">>$path_file");
          print $FH_out "$titre\n$2\n+\n$ligne\n";
          close $FH_out;
  
          last;
        }
      }
    }
  }

  $ind_ligne++;

  if ($ind_ligne % 10000 == 0) {
    print "line $ind_ligne\n";
  }
}





