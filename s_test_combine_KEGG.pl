#!/usr/bin/perl
use Data::Dumper;
use Cwd;
$Data::Dumper::Sortkeys = 1;

#This script combines the gene name, tAI value, gc3 value and nc value for each gene from the output files
if($#ARGV<0){
	print "*******************************************\nSyntax: s_test_combine.pl species_name ";
	exit;
}

$spec = $ARGV[0];
$tAI_file = $spec."_output_tAI_file.txt";
$gc3_file = $spec.".gc3";
$nc_file = $spec.".nc.txt";
$kegg_file = $spec.".kegg";

open (INPUT, $tAI_file);
@tAI_in = <INPUT>;
close(INPUT);

open (INPUT, $gc3_file);
@gc3_in = <INPUT>;
close(INPUT);

open (INPUT, $nc_file);
@nc_in = <INPUT>;
close(INPUT);

open (INPUT, $kegg_file);
@kegg_in = <INPUT>;
close(INPUT);


foreach $line (@tAI_in){
	if($line !~ /genes_names/){
		$line =~ s/\r\n//g;
		@line = split('\t',$line);
		$gene = $line[0];
		$this_tai = $line[1];
		@gene = split('\s', $gene);
		$gene = $gene[0];
		$gene =~ s/-mRNA-\d+//;
		$tAI_hash{$gene}=$this_tai;
	}
}

#print Dumper \%tAI_hash;
$first = 0;
foreach $line (@nc_in){
	if($line =~ /---------------/ && $first == 0){
		$first = 1;	
	}elsif($line =~ /---------------/ && $first == 1){
		last;	
	}else{
			$line =~ s/\n//g;
			@line = split('\s+',$line);
			$gene = $line[0];
			$gene =~ s/-mRNA-\d+//;
			$this_nc = $line[5];
			$nc_hash{$gene} = $this_nc;
	}
}


#print Dumper \%nc_hash;

foreach $line (@gc3_in){
	$line =~ s/\n//g;
	@line = split('\t',$line);
	$gene = $line[0];
	@gene = split('\s+',$gene);
	$gene = $gene[0];
	$this_gc3 = $line[3];
	$this_gc3 =~ s/\%//g;
	$gene =~ s/-mRNA-\d+//;
	$gc3_hash{$gene} = $this_gc3;
}

#print Dumper \%gc3_hash;

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

open FILE, ">", "$spec.stest.txt";
print FILE "gene_id\ttAI\tnc\tgc3\tkegg\n";
print FILE @results;
close FILE;

