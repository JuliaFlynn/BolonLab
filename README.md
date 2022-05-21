# BolonLab
Deep Mutational Scanning Analysis scripts

This is the pipeline used in the paper "Comprehensive fitness landscape of SARS-CoV-2 Mpro reveals insights into viral resistance mechanisms." It takes raw fastq files generated on Illumina deep sequencing platforms and counts Mpro alleles.

1) 01_fastq_parse.pl

The 01_fastq_parse.pl script reads in the single end fastq file and outputs the barcodes and index sequences for each Mpro read:

usage: script.pl fastq PHRED_cutoff constant_check rev_comp(-1)

#read in single end fastq file and outputs sequences that match constant region and have PHRED>cutoff #output bc and index sequences to parsed files #output unparsed sequences as leftover.fastq

2) sort output file by index

usage sort 01Mpro.out > 01Mpro_sort.out

3) 02_parse_identifiers.pl

usage: script.pl 01Mpro_sort.out

#reads in sorted barcode file and for each index sequence outputs the tabulation of reads of each barocde as 02Mpro.out

4) 03_tabulate_counts.pl

03_tabulate_counts.pl calls the 02Mpro.out flie and the barcode-ORF assembly file and outputs the tabluation for each mutation organized by position, amino acid, codon, for each index
