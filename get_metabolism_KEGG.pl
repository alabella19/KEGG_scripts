#!/usr/bin/perl
use Data::Dumper;
use Cwd;
$Data::Dumper::Sortkeys = 1;

#This_script gets the "metabolism" processes from the kegg pathway file and counts the number of that instance
if($#ARGV<0){
	print "*******************************************\nSyntax: get_metabolism_KEGG.pl genome.stest.txt.kegg.txt";
	exit;
}

$kegg_file = $ARGV[0];
$spec=$kegg_file;

$spec =~ s/.stest.txt.kegg.txt//;

open (INPUT, $kegg_file);
@kegg_in = <INPUT>;
close(INPUT);

shift(@kegg_in);

foreach $line (@kegg_in){
	@line=split('\"',$line);
	$procs=$line[9];
	@procs=split(',',$procs);
	foreach $proc (@procs){
		if($proc =~ /metabolism/){
			#this process contains the word metabolism 
			#does it exist in the hash?
			if(exists $met_hash{$proc}){
				$val=$met_hash{$proc};
				$val=$val+1;
				$met_hash{$proc} = $val;
			}else{
				$met_hash{$proc}=1;	
			}
		}
	}

}

print Dumper \%met_hash;

open FILE, ">", "$spec.keggmet.txt";
foreach $met (keys %met_hash){
	$val=$met_hash{$met};
	print FILE "$met\t$val\n";
}
close FILE;

