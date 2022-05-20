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
$index[1]="ATCACGAT";
$index[2]="CGATGTAT";
$index[3]="TTAGGCAT";
$index[4]="TGACCAAT";
$index[5]="ACAGTGAT";
$index[6]="GCCAATAT";
$index[7]="CAGATCAT";
$index[8]="ACTTGAAT";
$index[9]="GATCAGAT";
$index[10]="TAGCTTAT";
$start_index=1;
$end_index=10;


if ($#ARGV != 0) {
  print "usage: script.pl inputfile\n" ;
  exit;
}

$bc_in = $ARGV[0];

open(INF, $bc_in) ;
open(OUTF, ">", "02Mpro.out") ;
open(DUMPF, ">>", "02leftover.out") ;

print OUTF "barcode" ;
for ($i=$start_index; $i<=$end_index;$i++) {
  print OUTF "\,$index[$i]" ;
}
print OUTF "\,invalid index\n" ;

$oldbc="";
for($i=$start_index;$i<=$end_index;$i++) {
  $count[$i]=0;
}
$count[0]=0;
while ($line = <INF>) {
  chomp($line) ;
  @spline = split(/,/, $line) ;
  $bc=$spline[0];
  $cur_index=$spline[1];
  if ($bc eq $oldbc) {
    $cur_i=0 ;
    for ($i=$start_index; $i<=$end_index;$i++){ 
      if ($cur_index eq $index[$i]) {
        $cur_i=$i ;
      }
    }
    $count[$cur_i]++ ;
  } else {
    print OUTF "$oldbc" ;
    $oldbc=$bc ;
    for ($i=$start_index; $i<=$end_index;$i++) {
      print OUTF "\,$count[$i]" ; 
      $count[$i]=0 ;
    }
    print OUTF "\,$count[0]\n" ;
    $count[0]=0;
    $cur_i=0 ;
    for ($i=$start_index; $i<=$end_index;$i++) { 
      if ($cur_index eq $index[$i]) {
        $cur_i=$i ;
      }
    }
    $count[$cur_i]++ ;
  }
}
print OUTF "$oldbc" ;
$oldbc=$bc ;
for ($i=$start_index; $i<=$end_index;$i++) {
  print OUTF "\,$count[$i]" ; 
}
print OUTF "\,$count[0]\n" ;


close(INF) ;
close(DUMPF) ;
close(OUTF) ;
