#!/opt/local/bin/perl -w

use strict;

if($#ARGV < 0) {
  print $#ARGV;
  print STDERR "Useage: $0 < kmer length > < inputFasta1 > < inputFasta2 >\n";
  exit;
}

my $k = $ARGV[0];
my $fastafile1 = $ARGV[1];
my $fastafile2 = $ARGV[2];

my @alphabet = ("A","C","G","T");
#print "$k @alphabet\n";

my @kmerlist = @alphabet;
for (my $i = 1; $i < $k; $i++) {
#  print "$i\n";
  my @newlist;
  foreach my $word (@kmerlist){
    foreach my $letter (@alphabet){
      my $newWord = $word.$letter;
      #      print "$word + $letter = $newWord\n";
      push (@newlist, $newWord);
    }
  }
  @kmerlist = @newlist;
#  push(@kmerlist,@newlist);
}
print STDERR "Kmers @kmerlist\n";
my @cleanList;
my %seen;

foreach my $kmer (@kmerlist){
  if ($kmer ne ""){
    if (!exists($seen{$kmer})){
      push(@cleanList,$kmer);
      $seen{$kmer} = 1;
    }
  }
}
@kmerlist = @cleanList;
print STDERR "KmersClean @kmerlist\n";
my $numKmers = $#kmerlist +1;
print STDERR "Found $numKmers Kmers.\n";

my $string = "";
my $header = "";
#print "EnsID\tGene\tSeq\tLength";
#foreach my $kmer (@kmerlist){
#    print "\t$kmer";
#}
#print "\n";
my %counts1;
my %counts2;
my $gene1num = 0;
my $kmerspace1 = 0;
open(IN1,$fastafile1);
while(<IN1>){
    chomp $_;
    $_ =~ s/\r\n/\n/g;
    $_ =~ s/\r//g;
    if ($_ =~ /^([ACTGN]+)$/){
	chomp $_;
	$string .= $1;
    } elsif ($_ =~ /^>(.+)$/){
	if ($string ne ""){
	    $gene1num ++;
#	    print "$header\t$string\t".length($string);
	    foreach my $kmer (@kmerlist){
#		my $kmercount = () = $string =~ /$kmer/g;
		my $kmercount = () = $string =~ /(?=\Q$kmer\E)/g;
		$counts1{$kmer} += $kmercount;
	    }
#	    print "\n";
	    $kmerspace1 += (length($string) - $k + 1);
	}
	$header = $1;
	$header =~ s/\|/\t/g;
	$string = "";
    }
}
open(IN2,$fastafile2);
my $gene2num = 0;
my $kmerspace2 = 0;
while(<IN2>){
    chomp $_;
    $_ =~ s/\r\n/\n/g;
    $_ =~ s/\r//g;
    if ($_ =~ /^([ACTGN]+)$/){
	chomp $_;
	$string .= $1;
    } elsif ($_ =~ /^>(.+)$/){
	if ($string ne ""){
	    $gene2num ++;
#	    print "$header\t$string\t".length($string);
	    foreach my $kmer (@kmerlist){
#		my $kmercount = () = $string =~ /$kmer/g;
		my $kmercount = () = $string =~ /(?=\Q$kmer\E)/g;
		$counts2{$kmer} += $kmercount;
	    }
	    $kmerspace2 += (length($string) - $k + 1);
#	    print "\n";
	}
	$header = $1;
	$header =~ s/\|/\t/g;
	$string = "";
    }
}

print STDERR "$kmerspace1\t$kmerspace2\n";

print "Kmer\tKmerCounts $fastafile1\tSeqNum $fastafile1\tKmerSpace $fastafile1\tLengthNormCounts $fastafile1\tKmerCounts $fastafile2\tSeqNum $fastafile2\tKmerSpace $fastafile2\tLengthNormCounts $fastafile2\tTI ($fastafile1 NormCounts)/($fastafile2 NormCounts)\n";
foreach my $kmer (@kmerlist){
    my $numratio1 = $counts1{$kmer}/$gene1num;
    my $numratio2 = $counts2{$kmer}/$gene2num;
    my $lengthratio1 = $counts1{$kmer}/$kmerspace1;
    my $lengthratio2 = $counts2{$kmer}/$kmerspace2;
    my $TI = 0;
    if ($lengthratio2 > 0){
	$TI = $lengthratio1/$lengthratio2;
    }
    print "$kmer\t$counts1{$kmer}\t$gene1num\t$kmerspace1\t$lengthratio1\t$counts2{$kmer}\t$gene2num\t$kmerspace2\t$lengthratio2\t$TI\n";
}
