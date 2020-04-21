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
use lib dirname(dirname abs_path $0) . '/LaraperlTrans/lib';

# module which implements main logic
use My::Logic qw(lang_file_to_hash make_translation make_parent_trans_key put_trans_strings_into_buffer); 

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


sub generate_json_wanted {
	# generate JSON lang file from all __('trans') values

	if(-f && $_ =~ /^.+\.php$/ ) {
		my $filepath = $_; # option 'no_chdir' in find() must be set for this assignment;
		#say $filepath;
		put_trans_strings_into_buffer($filepath, \%dictionary);
	}

}


sub generate_json_lang_file {
	# genate JSON lang file from __('') strings in views and controllers.

	my ($target_filepath, @controllers_and_blade_dirs) = @_;

	# get translation keys
	find({ wanted => \&generate_json_wanted, no_chdir => 1 }, @controllers_and_blade_dirs);

	my @keys_from_dict = ( keys %dictionary );
	my @keys_for_json = sort { lc($a) cmp lc($b) } @keys_from_dict;

	#my $target_filepath = 'en.json'; #"/tmp/.__temp_$fname"; #"${fpath_dir}.__temp_$fname";
	open(FILE_OUT,'>', $target_filepath) || die "Couldn't create the file '~/custom_file'. err -> $! \n";

	my $num_of_keys = scalar @keys_for_json;

	# write to JSON file
	print FILE_OUT "{\n";
	for(my $i = 0; $i<$num_of_keys; ++$i) {
		print FILE_OUT "\t" . '"' . $keys_for_json[$i] . '"' . ': ""';
		if($i<($num_of_keys - 1)) {
			print FILE_OUT ",";
		}
		print FILE_OUT "\n";
	}
	print FILE_OUT "}\n";
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
				$generate_json = 1;
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

	my $lang_directory_path = 'data/TestProject/lang';
	my @controllers_and_blade_dirs = (
		'data/TestProject/views',
		'data/TestProject/Controllers'
	); 

	# check if specified directories exist:
	-d $lang_directory_path || die("Wrong path specified, not a directory -> '$lang_directory_path'"); 	

	foreach my $dirpath (@controllers_and_blade_dirs) {
		-d $dirpath || die("Wrong path specified, not a directory -> '$dirpath'"); 	
	}

	if($generate_json) {
		generate_json_lang_file('en.json', @controllers_and_blade_dirs);
	}
	else {
		find({ wanted => \&lang_trans_wanted, no_chdir => 1 }, $lang_directory_path);
		find({ wanted => \&conv_files_wanted, no_chdir => 1 }, @controllers_and_blade_dirs);
	}

	# DEBUG - print populated translation dictionary
	#print Dumper \%dictionary;
}


# Run the script and time it.
my $datestring = localtime(time);
say "Started at $datestring";

main();

$datestring = localtime(time);
say "Ended at $datestring";
