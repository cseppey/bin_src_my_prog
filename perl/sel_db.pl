#! /usr/bin/perl

use strict;
use warnings;
use integer;
use List::MoreUtils qw(uniq);


# ARGV[0]: dir in;
# ARGV[1]: prefix out;
# ARGV[2]: primer fwd 5'>3' rev 5'>3';
# facultative:
# ARGV[3]: length min;
# ARGV[4]: length max;
# ARGV[5]: full;
# ARGV[6]: derep
# ARGV[7]: with primers

opendir (my $DH, "$ARGV[0]");
my @noms_fasta = grep {!/^\.+$/} readdir $DH;
closedir $DH;

@noms_fasta = sort @noms_fasta;


#---
# nom database

my $nom_BD = $ARGV[1];

open (my $BD_FH, ">$nom_BD.fa");
open (my $DOUBLON_FH, ">$nom_BD.dbl");


#---
# sélection des primer

open (my $PRIMER_FH, "<$ARGV[2]");

my $primer_fwd;
my $primer_rev;

my $ind = 0;
while (my $primer = <$PRIMER_FH>) {

  chomp $primer;

  if ($ind == 0) {
    $primer_fwd = $primer;
  }

  if ($ind == 1) { 
    $primer_rev = $primer;
  }

  $ind++;
}

#---

my $l_fwd = $primer_fwd;
my $l_rev = $primer_rev;

my @primer_fwd_pieces = $primer_fwd;
my @primer_rev_pieces = $primer_rev;

if (($#ARGV > 4) && ($ARGV[5] eq 'full')) {
  if ($primer_fwd_pieces[0] ne 'NULL') {
    $l_fwd =~ s/\[\w*?\]/N/g;
    $l_fwd = length $l_fwd;
    my $l_sub = $l_fwd;
    
    while ($l_sub >= $l_fwd / 2) {
    
      if ($primer_fwd =~ /^\[/) {
        $primer_fwd =~ s/^\[\w*?\]//;
      }
      else {
        $primer_fwd = substr $primer_fwd, 1;
      }
      
      push @primer_fwd_pieces, $primer_fwd;
      $l_sub = $primer_fwd;
      print "$primer_fwd\n";
      $l_sub =~ s/\[\w*?\]/N/g;
      $l_sub = length $l_sub;
    
    }
  }

  #---

  if ($primer_rev_pieces[0] ne 'NULL') {
    $l_rev =~ s/\[\w*?\]/N/g;
    $l_rev = length $l_rev;
    my $l_sub = $l_rev;

    while ($l_sub >= $l_rev / 2) {
    
      if ($primer_rev =~ /\]$/) {
        $primer_rev =~ s/\[\w*?\]$//;
      }
      else {
        $primer_rev = reverse $primer_rev;
        $primer_rev = substr $primer_rev, 1;
        $primer_rev = reverse $primer_rev;
      }
      
      push @primer_rev_pieces, $primer_rev;
      $l_sub = $primer_rev;
      print "$primer_rev\n";
      $l_sub =~ s/\[\w*?\]/N/g;
      $l_sub = length $l_sub;
    
    }
  }

}


#---
# hash building

my %hash;

for my $nom_fasta (@noms_fasta) {
  print ">>$nom_fasta\n";
  
  open (my $IN_FH, "$ARGV[0]/$nom_fasta");

  my $ind = 0;
  my $titre;
  while (my $ligne = <$IN_FH>) {

    chomp $ligne;
    
    if ($ligne =~ /^>/) {
      $titre = $ligne;

      $ind++;
      if ($ind % 10000 == 0) {
        print "\n$ind";
      }

    }
    
    else {
      my $seq;
      if ($ligne =~ /($primer_fwd_pieces[0])(.*?)($primer_rev_pieces[0])/) {
	if ($ARGV[7] eq 'with') {
	  $seq = $1 . $2 . $3;
	} else {
	  $seq = $2;
	}
	if ((length $seq >= $ARGV[3]) & (length $seq <= $ARGV[4])) {
	  push @{$hash{$seq}}, $titre;
        }
      } else {

        #---
        # test if primer fit

        my $stop = 0;

        for my $sub_fwd (@primer_fwd_pieces) {
          for my $sub_rev (@primer_rev_pieces) {

	    if ($ligne =~ /^($sub_fwd)(.*?)($sub_rev)$/) { # pmoA style
	      if($ARGV[7] eq 'with') {
	        $seq = $1 . $2 . $3;
	      } else {
		$seq = $2;
	      }
	      if ((length $seq >= $ARGV[3]) & (length $seq <= $ARGV[4])) {
	        push @{$hash{$seq}}, $titre;
                $stop++;
	      }
              last;
      	    }

          }
          if ($stop != 0) {
            last;
          }
        }
        
      }

    }
  
  }

  close $IN_FH;
}


#---
# dereplication et écriture

print "\n\nderep and writing\n";

my $ind_seq = 0;
my $ind_dbl = 1;
for my $seq (keys %hash) {

  my $ind_titre = 0;

  for my $titre (@{$hash{$seq}}) {
    $titre =~ s/\r//;
    if ($ARGV[6] eq 'derep') {
      if ($#{$hash{$seq}} > 0) {
        if ($ind_titre == 0) {
          print $BD_FH "$titre _$ind_dbl\_\n$seq\n";
        }
        else {
          print $DOUBLON_FH "$titre _$ind_dbl\_\n";
          if ($ind_titre == $#{$hash{$seq}}) {
            print $DOUBLON_FH "\n";
            $ind_dbl++;
          }
        }
      }
      else {
        print $BD_FH "$titre\n$seq\n";
      }
    } 
    else {
      print $BD_FH "$titre\n$seq\n";
    }

    $ind_titre++;
    
  }

  $ind_seq++;
  if ($ind_seq % 1000 == 0) {
    print "\n$ind_seq";
  }
}




