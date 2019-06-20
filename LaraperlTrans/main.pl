#!/usr/bin/perl

# ====================================================
# 		     LaraperlTrans
# ----------------------------------------------------
# Perform conversion of Laravel's translation function 
# trans('lang.key') form to __('lang.value') or 
# @lang('lang.value').
# ====================================================

use strict;
use warnings;
use diagnostics;
use v5.10;
use Data::Dumper qw(Dumper);
use File::Find;
use File::Basename;

# dependencies for importing modules
use File::Basename qw(dirname basename);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';

# module which implements main logic
use My::Logic qw(lang_file_to_hash make_translation); 

# global dictionary for all translation key -> value pairs, global overwrite value
my (%dictionary, $overwrite);



sub make_parent_trans_key {
	# create translation parent key string in string form 
	# 'parent_folder/filename' or in array form 
	# ('parent_folder', 'filename')
	
	my @subparts = @_;

	my $has_dir = 0;
	my $trans_key = '';

	$has_dir = 1 if scalar(@subparts) > 1;
	if($has_dir) {
		$trans_key .= $subparts[0] . '/';	
	}

	for (my $i=0; $i<scalar(@subparts); $i++) {
		next if $i==0 && $has_dir;
		my $key_last = $subparts[$i];
		$key_last =~ s/\.php//; 
		$trans_key .= $key_last;
	}

	return $trans_key;
}


sub lang_trans_wanted {
	# Callback function for File::Find
	# Traverse 'lang/$lang/' directory and store data from .php files 
	# (lang files) into %dictionary.
	
        my $lang = "en";

        if(-f && $_ =~ /^.+\.php$/ ) {
                my $filepath = $_; # option 'no_chdir' in find() must be set for this assignment;
		# DEBUG
		#say "dirname " . $File::Find::dir;
		#say "path $filepath";

                my @parts = split("/lang/$lang/", $filepath);
		scalar(@parts) >= 2 || die "Error! Laravel 'lang' folder path is unexpected!";

                my $lang_branch = $parts[-1];
                my @subparts = split("/", $lang_branch);

		# get parent part of translation string (in string form 'parent_folder/file')
		my $pp_trans_key = make_parent_trans_key(@subparts);

		lang_file_to_hash($filepath, \%dictionary, $pp_trans_key); 
        }

}


sub conv_files_wanted {

        if(-f && $_ =~ /^.+\.php$/ ) {
                my $filepath = $_; # option 'no_chdir' in find() must be set for this assignment;
		#say "filepath -> $filepath";
		
		if(not $overwrite) {
			my $file_basename = basename($filepath);
			say("\n\n>>>>>>> $file_basename\n");	
		}

		make_translation($filepath, \%dictionary, $overwrite);
        }

}



sub main() {
	$overwrite = 0;

	my $lang_directory_path = '/home/marko/Programming/Projects/LaraperlTrans/data/original_data/youbox/lang';
	my @controllers_and_blade_dirs = ('/home/marko/Programming/Projects/misc_scripts-perl/LaraperlTrans/data/original_data/youbox/resources/views'); 
	
	find({ wanted => \&lang_trans_wanted, no_chdir => 1 }, $lang_directory_path);
	find({ wanted => \&conv_files_wanted, no_chdir => 1 }, @controllers_and_blade_dirs);

	#my $path_to_file_to_convert = './data/original_data/youbox/all.blade.php';
	#make_translation($path_to_file_to_convert, \%dictionary, $overwrite);

	# DEBUG - print populated translation dictionary
	#print Dumper \%dictionary;
}


# Run the script and time it.
my $datestring = localtime(time);
say "Started at $datestring";

main();

$datestring = localtime(time);
say "Ended at $datestring";
