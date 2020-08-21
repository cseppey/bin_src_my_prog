#! /usr/bin/perl


use strict;
use warnings;

# $ARGV[0] : non-chimera fasta
# $ARGV[1] : assignation infile
# $ARGV[2] : response matrix infile
# $ARGV[3] : output dir


#---
# establishing input file handlers file names

open (my $FH_NC_IN1,   "<$ARGV[0]");
open (my $FH_NC_IN2,   "<$ARGV[0]");
open (my $FH_ASS_IN1, "<$ARGV[1]");
open (my $FH_ASS_IN2, "<$ARGV[1]");
open (my $FH_MR_IN1,  "<$ARGV[2]");
open (my $FH_MR_IN2,  "<$ARGV[2]");

my $file_nc  = $ARGV[0];
my $file_ass = $ARGV[1];
my $file_mr  = $ARGV[2];

$file_nc  =~ s/.*\/(.*)/$1/;
$file_ass =~ s/.*\/(.*)/$1/;
$file_mr  =~ s/.*\/(.*)/$1/;


# create the output file handler

my $file_fa = $file_ass;
$file_fa =~ s/(.*)\..*/$1.fa/;

my $out_ass = $ARGV[3] . '/' . $file_ass;
my $out_mr  = $ARGV[3] . '/' . $file_mr; 
my $out_fa  = $ARGV[3] . '/' . $file_fa; 

mkdir $ARGV[3];

open (my $FH_ASS_OUT, ">$out_ass");
open (my $FH_MR_OUT,  ">$out_mr");
open (my $FH_FA_OUT,  ">$out_fa");

print "in path =   $ARGV[0]\t$ARGV[1]\nin files =  $file_ass\t$file_mr\nout paths = $out_ass\t$out_mr\t$out_fa\n#####\n";


#---
# reading the non-chimera file

my %OTU_nc;

my $ind_seq = 1;

my $ln_nb;
$ln_nb += tr/>/>/ while sysread ($FH_NC_IN1, $_, 2 ** 16);
print "non-chim = $ln_nb seqences\n";

while (my $line = <$FH_NC_IN2>) {

  if ($line =~ m/^>/) {

    chomp $line;
    $line =~ s/>(.*);size=(.*)/$1_$2/;
    $OTU_nc{$line} = '';

    if ($ind_seq % 100000 == 0) {
      my $perc = $ind_seq / $ln_nb;
      $perc =~ s/^(.{5}).*$/$1/;
      print "nc $perc\n";
    }
    $ind_seq++;

  }

}

close $FH_NC_IN1;
close $FH_NC_IN2;


#--
# retreiving the ligne in the assignation file

my @OTU_nbs;

my $ind_otu = 1;

$ln_nb = 0;
$ln_nb += tr/\n/\n/ while sysread ($FH_ASS_IN1, $_, 2 ** 16);
print "ass = $ln_nb lines\n";

while (my $line = <$FH_ASS_IN2>) {
  
  # check if the OTU is in th non-chimera
  my $id = $line;
  $id =~ s/.*?_(.*?)\t.*/$1/;
  chomp $id;

  if (exists ($OTU_nc{$id}) ) {
    
    # print the new assignation file
    print $FH_ASS_OUT $line;

    # print the new fasta file
    my $line_fa = $line;
    $line_fa =~ s/^.*?_(.*?)\t.*\t(.*)/>$1\n$2/;
    print $FH_FA_OUT $line_fa;
  
    # get the OTU nb to parse the response matrix
    push @OTU_nbs, $ind_otu;
    
  }

  #---
  if ($ind_otu % 100000 == 0) {
    my $perc = $ind_otu / $ln_nb;
    $perc =~ s/^(.{5}).*$/$1/;
    print "ass $perc\n";
  }
  $ind_otu++;
}

close $FH_ASS_IN1;
close $FH_ASS_IN2;
close $FH_ASS_OUT;
close $FH_FA_OUT;


#---
# reading the community matrix

my $ind_smp = 0;

$ln_nb = 0;
$ln_nb += tr/\n/\n/ while sysread ($FH_MR_IN1, $_, 2 ** 16);
print "mr = $ln_nb lines\n";

while (my $line = <$FH_MR_IN2>) {
  
  chomp $line;
  my @parts_line = split /\t/, $line;
  my $join_line = join "\t", @parts_line[0,@OTU_nbs];

  print $FH_MR_OUT "$join_line\n";

  #---
  if ($ind_smp % 10 == 0) {
    my $perc = $ind_smp / $ln_nb;
    $perc =~ s/^(.{5}).*$/$1/;
    print "mr $perc\n";
  }

  $ind_smp++;

}

close $FH_MR_IN1;
close $FH_MR_IN2;
close $FH_MR_OUT;




















