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

no warnings 'experimental'; # for given/when

# dependencies for importing modules
use File::Basename qw(dirname basename);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';

# module which implements main logic
use My::Logic qw(lang_file_to_hash make_translation make_parent_trans_key); 

# global dictionary for all translation key -> value pairs, global overwrite value
my (%dictionary, $overwrite);


sub lang_trans_wanted {
	# Callback function for File::Find
	# Traverse 'lang/$lang/' directory and store array data from .php files 
	# (lang files) into %dictionary.
	
        my $lang = "en";

        if(-f && $_ =~ /^.+\.php$/ ) {
                my $filepath = $_; # option 'no_chdir' in find() must be set for this assignment;

		# DEBUG
		#say "dirname " . $File::Find::dir . ", abs path $filepath";

		# get parent part of translation string (in string form 'parent_folder/file')
		my $pp_trans_key = make_parent_trans_key($lang, $filepath);

		lang_file_to_hash($filepath, \%dictionary, $pp_trans_key); 
        }

}


sub conv_files_wanted {
	# Callback function for File::Find
	# Traverse specified directories and perform conversions on php files

        if(-f && $_ =~ /^.+\.php$/ ) {
                my $filepath = $_; # option 'no_chdir' in find() must be set for this assignment;
		
		if(not $overwrite) {
			my $file_basename = basename($filepath);
			say("\n\n>>>>>>> $file_basename\n");	
		}

		make_translation($filepath, \%dictionary, $overwrite);
        }

}


sub optparse {
	#primitive options parsing
	
	# set defaults
	$overwrite = 0;
	my $lang_dir_path = '';
	my $process_dirs_paths = '';
	my $generate_json = 0;

	foreach my $arg (@ARGV) {

		given($arg) {
			when ($_ eq '--overwrite' || $_ eq '-w') {
				$overwrite = 1;
			}	
			when ($_ =~ m/--lang-dir-path=(.*)/) {
				$lang_dir_path = $1;			
			}	
			when ($_ =~ m/--process-dirs-paths=(.*)/) {
				$process_dirs_paths = $1;
			}	
			when ($_ =~ m/--generate-json/ || $_ eq '-j') {
				$generate_json = $1;
			}	
			default {
				say "invalid argument option specified '$arg'";
				exit(1);
			}
		}

	}

	return ($overwrite, $lang_dir_path, $process_dirs_paths, $generate_json);
}



sub main() {
	my ($lang_dir_path, $process_dirs_paths, $generate_json);
	($overwrite, $lang_dir_path, $process_dirs_paths, $generate_json) = optparse();

	#die('temp end');

	my $lang_directory_path = '/home/marko/Programming/Projects/misc_scripts-perl/LaraperlTrans/data/original_data/youbox/lang';
	my @controllers_and_blade_dirs = ('/home/marko/Programming/Projects/misc_scripts-perl/LaraperlTrans/data/original_data/youbox/resources/views'); 

	# check if specified directories exist:
	-d $lang_directory_path || die("Wrong path specified, not a directory -> '$lang_directory_path'"); 	

	foreach my $dirpath (@controllers_and_blade_dirs) {
		-d $dirpath || die("Wrong path specified, not a directory -> '$dirpath'"); 	
	}
	
	find({ wanted => \&lang_trans_wanted, no_chdir => 1 }, $lang_directory_path);
	find({ wanted => \&conv_files_wanted, no_chdir => 1 }, @controllers_and_blade_dirs);

	# DEBUG - print populated translation dictionary
	#print Dumper \%dictionary;
}


# Run the script and time it.
my $datestring = localtime(time);
say "Started at $datestring";

main();

$datestring = localtime(time);
say "Ended at $datestring";
