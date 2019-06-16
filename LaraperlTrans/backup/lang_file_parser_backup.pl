#!/usr/bin/perl

# ====================================================
# 		     LaraperlTrans
# ----------------------------------------------------
# Perform conversion of Laravel's translation function 
# trans('lang.key') form to __('lang.value').
# ====================================================

use strict;
use warnings;
use diagnostics;
use v5.10;
use Data::Dumper qw(Dumper);


my (%dictionary);

my $translation_filepath = './data/original_data/youbox/lang/en/admin/auth.php';
my $file_to_conv_path = './data/original_data/youbox/all.blade.php';


# helper functions

sub  trim { 
#php like trim
	
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s; 
};

sub file_contents_slurp {
	# slurp file contents into single variable
	
	scalar(@_ == 1) || die "Invalid number of arguments received in file_contents_slurp";

	my $filepath = shift;

	my $content;
	open(my $fh, '<', $filepath) or die "cannot open $filepath";
	{
		local $/;
		$content = <$fh>;
	}
	close($fh);	

	return $content;
}


sub lang_file_to_hash {
# parse lang file from $filepath and put values into
# $dictionary where key is complex and extracted from $filepath 
	
	scalar(@_ == 2) || die "Invalid number of arguments received in lang_file_to_hash";
	my $filepath = shift;
	my $dictionary = shift;

	my $filekey = "admin"; # TODO: get complex key

	my $content = file_contents_slurp($filepath); 

	while ($content =~ m/^\s*(['"])(?<key>.+?)\1\s*  # match array key surrounded by quotes 
			     =>  
			     \s*(['"])(?<val>.+?)\3\s*   # match array value surrounded by quotes
			     				 # m - do not ignore \n, s -  as a single string
			     /xsgm ) {                     

		if(defined $+{key} && defined $+{val}) {
			$dictionary{$filekey}{$+{key}} = $+{val};
		}
	}

	close(FILE);
}


sub get_all_lang_files_paths() {

}


sub make_translation {
	# perform translation form Laravel's trans() func to __() func
	scalar(@_ == 2) || die "Invalid number of arguments received in lang_file_to_hash";
	my $filepath = shift;
	my $dictionary = shift;

	say "filepath of file to convert = $filepath";

	open(FILE, $filepath) || die "Couldn't open the file '$filepath'\n";

	while(<FILE>) {
		#print $_;
		if ($_ =~ m/(trans\((['"].*?['"])\s*,?\s*(\w{1}|\[.*?\])?\))/g) { #m/(trans\('.*?'\))/g;

			if(defined $1) {
				say "MATCHED $1 in $_";
				say "key => $2";
				my $s = $2;
				$s =~ s/['"]//g;
				my @translation_arr = (split /\./, $s);
				my $translation = $translation_arr[-1];
				say "translation key = " . $translation;
				say "trans sentence => " . $dictionary{'admin'}{$translation};
			}
		}
	}

	close(FILE);	
}


sub main {
	lang_file_to_hash($translation_filepath, \%dictionary);
	#make_translation($file_to_conv_path, \%dictionary);
}

my $datestring = localtime(time);
say "Started at $datestring";
main();
print Dumper \%dictionary;
$datestring = localtime(time);
say "Ended at $datestring";


# TRASH:

=pod
	foreach $key (keys %{$dictionary{$filekey}}) {
		$val = $dictionary{$filekey}{$key};
		print $key . " >>> " . $val . "\n";
	}
=cut
