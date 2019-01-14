#! /usr/bin/perl


use strict;
use warnings;
use threads;



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
  
  my @parts_ligne = split / /, $primer;

  my $reg_primer = '(' . $parts_ligne[1] . ')(.*)(' . $parts_ligne[2] . ')' ;

  $reg_primer =~ s/R/[AG]/g;
  $reg_primer =~ s/Y/[CT]/g;
  $reg_primer =~ s/S/[GC]/g;
  $reg_primer =~ s/W/[AT]/g;
  $reg_primer =~ s/K/[GT]/g;
  $reg_primer =~ s/M/[AC]/g;
  $reg_primer =~ s/B/[CGT]/g;
  $reg_primer =~ s/D/[AGT]/g;
  $reg_primer =~ s/H/[ACT]/g;
  $reg_primer =~ s/V/[ACG]/g;
  $reg_primer =~ s/N/[ATCGN]/g;

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

print "\nscan fastq\n";

my @threads = ();

for my $key (keys %H_primers) {
  push (@threads, threads->create (\&thread_fct, $key));
}

foreach (@threads) {
  $_->join();
}




exit(0);

sub thread_fct {

  my $key = shift;

  print "scan fastq $H_primers{$key}\n";

  my $path_file = $ARGV[2] . '/' . $H_primers{$key};

  open (my $FH_fastq, "<$ARGV[0]");
  open (my $FH_out, ">>$path_file");

  my $titre;
  my $seq;
  my $ind_ligne = 0;

  while (my $ligne = <$FH_fastq>) {
    chomp $ligne;

    if ($ind_ligne % 4 == 0) {
      $titre = $ligne;
    }

    if ($ind_ligne % 4 == 1) {
      $seq = $ligne;
    }

    if ($ind_ligne % 4 == 3) {

      my $rev_trans_seq = $seq;
      $rev_trans_seq = reverse $rev_trans_seq;
      $rev_trans_seq =~ tr/ATCG/TAGC/;

      #---
      
      if ($seq =~ /$key/) {
        $ligne = substr $ligne, $+[1], $+[2] - $-[2];
        print $FH_out "$titre\n$2\n+\n$ligne\n";
      }    
      elsif ($rev_trans_seq =~ /$key/) {
	$ligne = reverse $ligne;
        $ligne = substr $ligne, $+[1], $+[2] - $-[2];
        print $FH_out "$titre\n$2\n+\n$ligne\n";
      }
    }

    $ind_ligne++;

    if ($ind_ligne % 1000000 == 0) {
      print "line $H_primers{$key} $ind_ligne\n";
    }

  }

  close $FH_out;
  close $FH_fastq;
}




#######



my @args = @ARGV;

my @threads = ();

for my $arg (@args){
  push (@threads, threads->create (\&thread_func, $arg));
}

foreach (@threads) {
  $_->join(); # blocks until this thread exits
}
exit(0);

# this is the main sub where all the threads start
sub thread_func {
  my $arg = shift;
  print $arg;
}
   
   
   
#######

   



#for my $key (keys %H_primers) {
#
#  print "\nscan fastq $H_primers{$key}\n";
#
#  my $path_file = $ARGV[2] . '/' . $H_primers{$key};
#
#  open (my $FH_fastq, "<$ARGV[0]");
#  open (my $FH_out, ">>$path_file");
#
#  my $titre;
#  my $seq;
#  my $ind_ligne = 0;
#
#  while (my $ligne = <$FH_fastq>) {
#    chomp $ligne;
#
#    if ($ind_ligne % 4 == 0) {
#      $titre = $ligne;
#    }
#
#    if ($ind_ligne % 4 == 1) {
#      $seq = $ligne;
#    }
#
#    if ($ind_ligne % 4 == 3) {
#
#      my $rev_trans_seq = $seq;
#      $rev_trans_seq = reverse $rev_trans_seq;
#      $rev_trans_seq =~ tr/ATCG/TAGC/;
#
#      #---
#      
#      if ($seq =~ /$key/) {
#        $ligne = substr $ligne, $+[1], $+[2] - $-[2];
#        print $FH_out "$titre\n$2\n+\n$ligne\n";
#      }    
#      elsif ($rev_trans_seq =~ /$key/) {
#	$ligne = reverse $ligne;
#        $ligne = substr $ligne, $+[1], $+[2] - $-[2];
#        print $FH_out "$titre\n$2\n+\n$ligne\n";
#      }
#    }
#
#    $ind_ligne++;
#
#    if ($ind_ligne % 1000000 == 0) {
#      print "line $ind_ligne\n";
#    }
#
#  }
#
#  close $FH_out;
#  close $FH_fastq;
#}
#
#
#
#
#
#
