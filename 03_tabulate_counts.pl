#!/usr/bin/perl
#
# read in uniq files of barcodes for different timepoints
# read in barcode-ORF assembly files
# write counts file organized by position, amino acid, codon

if ($#ARGV != 1) {
  print "usage: script.pl bc_ORF_assembly_file counts_file \n";
  exit;
}

$bc_ORF_in = $ARGV[0];
$counts_file = $ARGV[1];

print "bc-ORF assembly file: $bc_ORF_in\n" ;
print "counts file: $counts_file\n" ;

open(CF, $counts_file) ;
$line = <CF> ;
@spline = split (/,/, $line) ;
if ($spline[0] eq "barcode") {
  $nindex = @spline - 1;
  for ($i=1;$i<=$nindex;$i++) {
    print "index $i\: $spline[$i]\n" ;
    $index[$i-1]=$spline[$i] ;
  }
} else {
  print "Error: expected \"barcode\" at first line of counts file\n" ;
  exit ;
}

close(CF) ;

open(BCF, $bc_ORF_in) ;

open(OUTF, ">03Mpro.out") ;

print OUTF "Position, aa mutation, codon mutation, indexes:" ;
for ($i=0; $i<$nindex; $i++) {
  print OUTF ",$index[$i]" ;
}
print OUTF "\n" ;

$line = <BCF> ;

while ($line = <BCF>) {
  chomp($line) ;
  @spline = split (/,/, $line) ;
  $nspline = @spline ;
  $pos = $spline[0];
  $codon_mut = $spline[2];
  $aa_mut = $spline[1];
  for ($i=0; $i<$nindex; $i++) {
    $count[$i]=0;
  }
  if ($nspline > 3) {
    for ($i=3;$i<$nspline;$i++) {   
      $bc_cur = $spline[$i] ;
      $inseq = $counts_file ;
      $searchresult = `grep $bc_cur $inseq` ;
      chomp($searchresult) ;
      @splresult = split(/,/, $searchresult) ;
      if ($splresult[1]>0) {
        print "search result: $searchresult\n" ;
      }
      for ($k=1; $k<=$nindex; $k++) {
        $count[$k-1]=$count[$k-1]+$splresult[$k] ;
      }
    }
    print OUTF "$pos,$aa_mut,$codon_mut,$bc_cur" ;
    for ($i=0;$i<$nindex;$i++) {
      print OUTF "\,$count[$i]" ;
    }
    print OUTF "\n" ;
  }
}

close(BCF) ;
close(OUTF) ;
