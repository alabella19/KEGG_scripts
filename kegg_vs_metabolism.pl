#!/usr/bin/perl
use Data::Dumper;
use Cwd;
$Data::Dumper::Sortkeys = 1;

#this script takes the results from getting the KEGGs for a pathway and creates a file for analysis
if($#ARGV<0){
	print "*******************************************\nSyntax: kegg_vs_metabolism.pl file.names.to.process ";
	exit;
}

$suffix = $ARGV[0];

#print "suffix is $suffix\n";

#this is the file with the metabolism information
#will have to mannually change the column for now
open (INPUT, "metabolism_species.txt");
@met_data_inp = <INPUT>;
close(INPUT);

#get rid of header
shift(@met_data_inp);

#USE THIS TO SET THE COLUMN YOU WANT FOR THE METABOLISM DATA!!!
$col=4;

foreach $line (@met_data_inp){
	@line = split('\t',$line);
	$spec = $line[0];
	$met = $line[$col];
	
	$met_data{$spec}=$met;
	
}

#print Dumper \%met_data;


opendir my $dir, "." or die "Cannot open directory: $!";
my @files = readdir $dir;
closedir $dir;

push(@all_results, "species	gene_id	tAI	nc	gc3	kegg	quant	met_state\n");


foreach $file (@files){
	if($file =~ /$suffix/ && $file !~ /results/){
		#print $file;
		open (INPUT, "$file");
		@kegg_results=<INPUT>;
		close(INPUT);
		
		$spec = $file;
		$spec =~ s/.kegg//g;
		$spec =~ s/.$suffix//g;
		$spec =~ s/_\d+//g;
		#print "$spec\n";
		if(exists $met_data{$spec}){
			$met_state= $met_data{$spec};
		}else{
			$met_state="NA";
		}
		
		#print "$spec\t$met_state\n";
		foreach $line (@kegg_results){
			$line =~s/\n//g;
			$line = "$spec\t$line\t$met_state\n";
			push(@all_results, $line);
		}
	}
}


open FILE, ">", "results.$suffix";
print FILE @all_results;
close FILE;

