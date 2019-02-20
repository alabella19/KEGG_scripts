#!/usr/bin/perl
use Data::Dumper;
use Cwd;
$Data::Dumper::Sortkeys = 1;

#This script combines the gene name, tAI value, gc3 value and nc value for each gene from the output files
if($#ARGV<0){
	print "*******************************************\nSyntax: post_s_test_combine.pl species_name ";
	exit;
}

$spec = $ARGV[0];
$tAI_file = $spec.".stest.txt";
$kegg_file = $spec.".kegg";

open (INPUT, $tAI_file);
@tAI_in = <INPUT>;
close(INPUT);

open (INPUT, $kegg_file);
@kegg_in = <INPUT>;
close(INPUT);


foreach $line (@tAI_in){
	if($line !~ /gene_id/){
		$line =~ s/\n//g;
		@line = split('\t',$line);
		$gene = $line[0];
		$this_tai = $line[1];

		@gene = split('\s', $gene);
		$gene = $gene[0];
		$gene =~ s/-mRNA-\d+//;
		$tAI_hash{$gene}=$this_tai;
		
		$this_nc=$line[2];
		$nc_hash{$gene} = $this_nc;
		$this_gc3=$line[3];
		$gc3_hash{$gene} = $this_gc3;
	}
}

#print Dumper \%gc3_hash;
#exit;

foreach $line (@kegg_in){
	if($line =~ /\t/){
		@line = split('\t',$line);
		$gene = $line[0];
		$kegg = $line[1];
		$kegg =~ s/\n//;
		@gene = split('=',$gene);
		$gene = $gene[1];
		$gene =~ s/_CDS//;
		$kegg_hash{$gene}=$kegg
	}
}

#print Dumper \%kegg_hash;
#exit;
foreach $gene (keys %tAI_hash){
	$this_tAI = $tAI_hash{$gene};
	$this_nc = $nc_hash{$gene};
	$this_gc3 = $gc3_hash{$gene};
	if(exists $kegg_hash{$gene}){
		$this_kegg = $kegg_hash{$gene};	
	}else{
		$this_kegg = "NA";
	}
	$line = "$gene\t$this_tAI\t$this_nc\t$this_gc3\t$this_kegg\n";
	push(@results,$line);
		
}

open FILE, ">", "$spec.kegg.stest.txt";
print FILE "gene_id\ttAI\tnc\tgc3\tkegg\n";
print FILE @results;
close FILE;

