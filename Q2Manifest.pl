#!/DCEG/Resources/Tools/perl/5.18.0/bin/perl -w
use strict;
use warnings;

#input
#output
#usage

@ARGV==4 or die "wrong number of arguments";

my $project_dir =$ARGV[0];
my $manifest_fullpath=$ARGV[1];
my $manifest_input=$ARGV[2];
my $manifest_output=$ARGV[3];

my @lines;

read_manifest ($manifest_fullpath, \@lines);
check_input(\@lines);
create_manifest($project_dir,$manifest_output,\@lines);

sub read_manifest{
	my ($manifest_fullpath, $lines)=@_;

	open my $in, "<:encoding(UTF-8)", $manifest_fullpath or die "$manifest_fullpath: $!";
	@$lines = <$in>; close $in;
	chomp @$lines;
}

sub check_input{
	my ($lines)=@_;
	my $n=1;
	my @header; my @sampleids; my @metavalues;
	my %seen;

	foreach (@lines){
		my @rows = split('\t',$_);

		if ($n==1){
			foreach (@rows){
				push (@header,$_);
			}
		} else{
			push(@sampleids,$rows[0]); shift @rows;
			foreach (@rows){
				push(@metavalues,$_);
			};
		};
		$n++;
	}

	#First variable must be SampleID or the manifest will not be accepted.
	#If any other value found, error for the user to check the manifest re-try
	if($header[0] ne "#SampleID"){
		print "First column must be #SampleID - check file and re-submit";
		exit;
	}

	#Sample IDs must be unique or the manifest will not be accepted.
	#If there are duplicate sample ID's, print them to user and re-try
	my @duplicates;
	foreach my $sample (@sampleids){
		$seen{$sample}++;
		if($seen{$sample}>1){
			push(@duplicates,$sample);
		}
	}

	if(scalar @duplicates>0){
		print "\nThere were duplicate ID's found in your manifest - correct and resubmit:\n";
		print join( ',', @duplicates); print"\n\n";
	}


	#All other cell rules
}

sub create_manifest{
	my ($project_dir, $manifest_output, $lines)=@_;

	open my $fh, ">$manifest_output";

	foreach (@lines) {
		my @columns = split('\t',$_);
#print "or here @columns\n\n";
		my $n=0;
		until ($n+1 > scalar(@columns)){
			print $fh "$columns[$n]\t";
			$n++;
		}
		print $fh "\n";
	}
}
exit;