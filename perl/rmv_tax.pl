#! /usr/bin/perl


use strict;
use warnings;

# $ARGV[0] : assignation infile
# $ARGV[1] : response matrix infile
# $ARGV[2] : outfile directory
# $ARGV[3] : regex of taxa to remove


#---
# establishing input file handlers file names

open (my $FH_ASS_IN1, "<$ARGV[0]");
open (my $FH_ASS_IN2, "<$ARGV[0]");
open (my $FH_MR_IN1,  "<$ARGV[1]");
open (my $FH_MR_IN2,  "<$ARGV[1]");

my $file_ass = $ARGV[0];
my $file_mr  = $ARGV[1];

$file_ass =~ s/.*\/(.*)/$1/;
$file_mr  =~ s/.*\/(.*)/$1/;


# create the output file handlers

my $file_fa = $file_ass;
$file_fa =~ s/(.*)\..*/$1.fa/;

my $out_ass = $ARGV[2] . '/' . $file_ass;
my $out_mr  = $ARGV[2] . '/' . $file_mr; 
my $out_fa  = $ARGV[2] . '/' . $file_fa; 

mkdir $ARGV[2];

open (my $FH_ASS_OUT, ">$out_ass");
open (my $FH_MR_OUT,  ">$out_mr");
open (my $FH_FA_OUT,  ">$out_fa");

print "in path =   $ARGV[0]\t$ARGV[1]\nin files =  $file_ass\t$file_mr\nout paths = $out_ass\t$out_mr\t$out_fa\n#####\n";

#---
# reading assignation file

my $tax_rgx = $ARGV[3];

my @OTU_nbs;

my $ind_line = 0;

my $ln_nb;
$ln_nb += tr/\n/\n/ while sysread ($FH_ASS_IN1, $_, 2 ** 16);
print "ass = $ln_nb lines\n";

while (my $line = <$FH_ASS_IN2>) {
  
  # check if the OTU belong to taxa to remove
  if ($line !~ m/$tax_rgx/) {
    
    # print the new assignation file
    print $FH_ASS_OUT $line;

    # print the new fasta file
    my $line_fa = $line;
    $line_fa =~ s/^.*?_(.*?)\t.*\t(.*)/>$1\n$2/;
    print $FH_FA_OUT $line_fa;
  
    # get the OTU nb to parse the response matrix
    my $OTU_nb = $line;
    $OTU_nb =~ s/(.*?)_.*/$1/;
    chomp $OTU_nb;
    push @OTU_nbs, $OTU_nb;

  }

  #---
  if ($ind_line % 100000 == 0) {
    my $perc = $ind_line / $ln_nb;
    $perc =~ s/^(.{5}).*$/$1/;
    print "ass $perc\n";
  }

  $ind_line++;

}

close $FH_ASS_IN1;
close $FH_ASS_IN2;
close $FH_ASS_OUT;
close $FH_FA_OUT;


#---
# reading community matrix

$ind_line = 0;

$ln_nb = 0;
$ln_nb += tr/\n/\n/ while sysread ($FH_MR_IN1, $_, 2 ** 16);
print "mr = $ln_nb lines\n";

while (my $line = <$FH_MR_IN2>) {
  
  chomp $line;
  my @parts_line = split /\t/, $line;
  my $join_line = join "\t", @parts_line[0,@OTU_nbs];

  print $FH_MR_OUT "$join_line\n";

  #---
  if ($ind_line % 10 == 0) {
    my $perc = $ind_line / $ln_nb;
    $perc =~ s/^(.{5}).*$/$1/;
    print "mr $perc\n";
  }

  $ind_line++;

}

close $FH_MR_IN1;
close $FH_MR_IN2;
close $FH_MR_OUT;

