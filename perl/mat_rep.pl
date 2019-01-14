#! /usr/bin/perl


use warnings;
use strict;
use List::MoreUtils qw(uniq);


#---
# ouverture des file handler

open (my $DBC_FH, "<$ARGV[0]");
#my @lignes_dbc = <$DBC_FH>;

open (my $OP_FH, ">$ARGV[1]");

#---
# extraction des cluster et echs

print "extraction cluster, echs\n";

my (@clusters, @echs, @joins);

my $index = 1;
while (my $ligne_dbc = <$DBC_FH>) { 
  
  if ($index % 100 == 0) {
    print "ligne $index\n"; 
  }

  unless (($ligne_dbc =~ /^seqnum/) || ($ligne_dbc =~ /\t0\t/) || ($ligne_dbc =~ /\|/)) {
    
    my @part_ligne = split /\t/, $ligne_dbc;
    push @clusters, $part_ligne[1];

    my @part_ligne2 = split / /, $part_ligne[2];
    push @echs, $part_ligne2[2];

    push @joins, join '_', $part_ligne[1], $part_ligne2[2];
  }

  $index++;
}

close $DBC_FH;

#---
# écriture de la matrice

print "écriture matrice\n";

@echs = uniq @echs;
@echs = sort @echs;

@clusters = uniq @clusters;
@clusters = sort {$a <=> $b} @clusters;
my $max = $clusters[-1];

for my $cluster (@clusters) {
  print $OP_FH "\t$cluster";
}

$index = 0;
for my $ech (@echs) {

  if ($index % 5 == 0) {
    print "ech $index / $#echs\n";
  }

  print $OP_FH "\n$ech";
  my @occs = grep {/$ech/} @joins;

  my %counts;
  $counts{$_}++ for @occs;

  for my $cluster (@clusters) {
    my $join = join '_', $cluster, $ech;
    if (exists $counts{$join}) {
      print $OP_FH "\t$counts{$join}";
    }
    else {
      print $OP_FH "\t0";
    }
  }

  $index++;
}
  
close $OP_FH;



