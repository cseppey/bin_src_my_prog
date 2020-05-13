#! /usr/bin/perl


use strict;
use warnings;


open (my $FH_fastq, "<$ARGV[0]");

open (my $FH_corect, ">$ARGV[1]");

my $name;
my $seq;

my $ind_ln = 0;

while (my $line = <$FH_fastq>) {
  
  if ($ind_ln % 4 == 0) {
    $name = $line;
  }

  if ($ind_ln % 4 == 1) {
    $seq = $line;
  }

  if ($ind_ln % 4 == 3) {
    chomp $line;
    if ($line !~ /^$/) {
      print $FH_corect "$name$seq+\n$line\n";
    }
  }

  $ind_ln++;
}


## bash verification line
# find *c* |
# while read file
# do
#   nbef=`wc -l ${file%c*}.fq |
#   cut -d' ' -f1`
#
#   naft=`wc -l $file |
#   cut -d' ' -f1`
#
#   diff=`echo "scale=3;($nbef - $naft) / 4" |
#   bc`
#
#   q=`grep -c '^$' ${file%c*}.fq`
#
#   w=`echo "scale=3;$q / 2" |
#   bc`
#
#   if [ $w == $diff ]
#   then
#     echo ok
#   else
#     echo not ok
#   fi
# done |
# sort |
# uniq -c |
# sort -n


