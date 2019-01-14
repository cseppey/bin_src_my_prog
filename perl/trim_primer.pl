#! /usr/bin/perl


use strict;
use warnings;


open (my $FH_IN, "<$ARGV[0]");

open (my $FH_OUT, ">$ARGV[1]");

open (my $FH_SCRAP, ">$ARGV[2]");

#---


my $primer_fwd = $ARGV[3];
my $primer_fwdR = $primer_fwd;
$primer_fwdR =~ tr/ATCG][/TAGC[]/;
$primer_fwdR = reverse $primer_fwdR;

my $primer_rev = $ARGV[4];
my $primer_revR = $primer_rev;
$primer_revR =~ tr/ATCG][/TAGC[]/;
$primer_revR = reverse $primer_revR;

my $titre;
my $seq;
my $length_tag_primer1;
my $seqok = 0;
my $seqRev = 0;

# pour fasta
if ($ARGV[0] =~ /a$/) {
  while (my $ligne = <$FH_IN>) {
  
    if ($ligne =~ /^>/) {
      $titre = $ligne;
    }
    elsif ($ligne =~ /^.*($primer_fwd)(.*)($primer_rev).*$/) {
      print $FH_OUT "$titre$2\n";
    }
    elsif ($ligne =~ /^.*($primer_revR)(.*)($primer_fwdR).*$/) {
        $2 =~ tr/ATCG/TAGC/;
        $2 = reverse $2;
        print $FH_OUT "$titre$2\n";
    }
    else {
        print $FH_SCRAP "$titre$2\n";
    }
  
  }
}

# pour fastq
elsif ($ARGV[0] =~ /q$/) {
  my $ind_ligne = 0;
  while (my $ligne = <$FH_IN>) {
    
    # titre
    if ($ind_ligne % 4 == 0) {
      $titre = $ligne;
    }
    
    # sequence
    if ($ind_ligne % 4 == 1) {

      if ($ligne =~ /^($primer_fwd)(.*)($primer_rev)$/) {
        $seqok = 1;
        $seqRev = 0;
        $seq = $2;

        $ligne =~ /$primer_fwd/;
        $length_tag_primer1 = length($`) + length($&);
      }
      elsif ($ligne =~ /^($primer_revR)(.*)($primer_fwdR)$/) {
        $seqok = 1;
        $seqRev = 1;
        $seq = $2;
        $seq =~ tr/ATCG/TAGC/;
        $seq = reverse $seq;

        $ligne =~ tr/ATCG/TAGC/;
        $ligne = reverse $ligne;
        $ligne =~ /$primer_fwd/;
        $length_tag_primer1 = length($`) + length($&);
      }
      else {
        $seqok = 0;
        $seq = $ligne;
      }

    }

    # score
    if ($ind_ligne % 4 == 3) {
      if ($seqok == 1) {
        if ($seqRev == 0) {
          my $score = substr $ligne, $length_tag_primer1, length $seq;
          print $FH_OUT "$titre$seq\n+\n$score\n";
        }
        else {
          my $score = reverse $ligne;
          $score = substr $score, $length_tag_primer1, length $seq;
          print $FH_OUT "$titre$seq\n+\n$score\n";
        }

      }
      else {
        print $FH_SCRAP "$titre$seq+\n$ligne";
      }
    }
    

    $ind_ligne++;
  }
}

else {
  print "Hey Dude, are you sure that you have a sequence file (fasta | fastq)?\nIf yes, add a correct extention.\n";
}

close $FH_OUT;
close $FH_OUT;


