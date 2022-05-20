#!/usr/bin/perl
#
# read in fastq file with identifiers as index
# check for confidence in barcode
# check for presence of a constant region
# record identifier
# If pass, then output barcode and identifier with option to rev. comp. bc
#
#
# VARIABLES TO ADJUST
$bc_start=0;
$bc_length=18;
$index_length=8;

sub revcomp {
  my($inseq, $outseq, $l, $p, $q, $inchar, $outchar);
  $inseq = $_[0] ;
  $l = length($inseq) ;
  $outseq = "" ;
  for ($p=$l-1;$p>=0;$p=$p-1) {
    $inchar = substr($inseq,$p,1) ;
    $outchar = "Z" ;
    if ($inchar eq "A") {$outchar="T"} ;
    if ($inchar eq "C") {$outchar="G"} ;
    if ($inchar eq "G") {$outchar="C"} ;
    if ($inchar eq "T") {$outchar="A"} ;
    $outseq = $outseq . $outchar ;
  }
  $outseq ;
}



if ($#ARGV != 3) {
  print "usage: script.pl fastq PHRED_cutoff constant_check rev_comp(-1)\n" ;
  exit;
}

$fastq_in = $ARGV[0];
$phred_cut = $ARGV[1];
$constant_check = $ARGV[2];
$rev_check = $ARGV[3];
print "phred cut: $phred_cut\n" ;
print "fastq file: $fastq_in\n" ;
print "constant check: $constant_check\n" ;
if ($rev_check<0) {
  $test="TRUE" ;
} else {
  $test="FALSE" ;
}
print "rev comp barcode $rev_check $test\n" ;

open(INF, $fastq_in) ;
open(OUTF, ">", "01Mpro.out") ;
open(DUMPF, ">>", "leftover.fastq") ;

$check=0;
$ngood=0;
$nqbad=0;
$npbad=0;
while ($line = <INF>) {
  chomp($line) ;
  $check++ ;
  if ($check == 1) {
    $line1=$line ;
  }
  if ($check == 2) {
    $seq = $line ;
    $line2 = $line ;
  }
  if ($check == 3) {$line3=$line} ;
  if ($check == 4) {
    $line4 = $line ;
    $qual = $line ;
    $check = 0 ;
# determine if phred scores of bc and index pass cutoff
    $q1 = substr($qual,$bc_start,$bc_length) ;
    @qc = split (//, $q1) ;
    $testposition=0 ;
    $quality_ok = 1 ;
    foreach (@qc) {
      $qval = ord($_);
      $qval = $qval - 33 ;
      if ($qval < $phred_cut) {$quality_ok=0} ;
    }
    if ($quality_ok == 1) {
#      print "quality ok, $seq\n" ;
# check to see if constant region is a match
      $parsed_ok = 0 ;
      if(index($seq,$constant_check)>=0) {
        $parsed_ok = 1 ;
        $bc = substr($seq,$bc_start,$bc_length) ;
        $l =length($line1) ;
        $index = substr($line1,$l-$index_length,$index_length) ;
        $outbc=$bc;
        if ($rev_check<0){
          $outbc=&revcomp($bc) ;
        }
        print OUTF "$outbc\,$index\n" ;
        $ngood++;
      }
    }
    if ($quality_ok < 1) {
      print DUMPF "qbad\,$bc\,$index\n" ;
      $nqbad++;
    }
    if ($parsed_ok < 1) {
      print DUMPF "const_bad\,$bc\,$index\n" ;
      $npbad++;
    }
  }
}


close(INF) ;
close(DUMPF) ;
close(OUTF) ;
open(SUMF, ">", "01Mpro.sum") ;
  print SUMF "N good: $ngood\n" ;
  print SUMF "N quality bad: $nqbad\n" ;
  print SUMF "N constant missing: $npbad\n" ;
close(SUMF) ;
