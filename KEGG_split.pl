#!/usr/bin/perl
use Data::Dumper;
use Cwd;
$Data::Dumper::Sortkeys = 1;

#takes the kegg file and splits it by species
if($#ARGV<0){
	print "*******************************************\nSyntax: KEGG_split.pl all_keggs";
	exit;
}

$cwd= getcwd;
$kegg_file=$ARGV[0];

open (INPUT, $kegg_file);
@kegg = <INPUT>;
close(INPUT);

$first = 0;

foreach $line (@kegg){
	if($line =~ /\.ko/){
		
		if($first != 0){
			print "making file $spec.kegg\n";
			open FILE, ">", "$spec.kegg";
			print FILE @this_array;
			close FILE;	
			#exit;
		}
		
		#print Dumper \@this_array;
		
		$spec = $line; 
		@spec = split('\s', $spec);
		$spec = $spec[0];
		@spec = split('\.ko', $spec);
		$spec = $spec[0];
		if($first == 0){
			$first = 1;
		}
		#print "species is $spec\n";
		@this_array = "";
		
		
		@first_gene = split('\t', $line);
		$first_len = scalar(@first_gene);
		if($first_len > 1){
			#there is a KEGG designation for this first gene 
			#print Dumper \@first_gene;
			$kegg = $first_gene[1];
			$gene = $first_gene[0];
			@gene = split('\s', $gene);
			$gene_len = scalar(@gene);
			$gene = $gene[($gene_len-1)];
			#print "gene is $gene\n";
			$gene =~ s/-//;
			$gene =~ s/\h//g;
			$new_line = "$gene\t$kegg\n";
		}else{
			$gene = $first_gene[0];
			@gene = split('\s', $gene);
			$gene_len = scalar(@gene);
			$gene = $gene[($gene_len-1)];
			#print "gene is $gene\n";
			$gene =~ s/-//;
			$gene =~ s/\h//g;
			$new_line = "$gene\n";
		}
		#print "new line is :$new_line:";
		push(@this_array, $new_line);
	}else{
		$line =~ s/^-//;
		push(@this_array, $line);
	}
	
}

