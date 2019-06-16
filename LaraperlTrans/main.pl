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
use File::Find;
use File::Basename;

# dependencies for importing modules
use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';

# module which implements main logic
use My::Logic qw(lang_file_to_hash make_translation); 

# global dictionary for all translation key -> value pairs
my (%dictionary, $overwrite);



sub make_parent_trans_key {
	# create translation parent key string in form 'parent_folder/file'
	
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

	# USE THIS COMMENTED OUT PART IF YOU WANT TO PASS AN ARRAY INSTEAD OF CONSTRUCTED STRING AS $trans_key
	#my @suffixlist = ".php";
	#my ($filename, $path, $suffix) = fileparse($filepath, @suffixlist);
	#$subparts[-1] = $filename; #TODO: get filename using split -> #(split('.', $subparts[-1]))[0];
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

		# for trans string in form 'parent_folder/file'
		my $trans_key = make_parent_trans_key(@subparts);

		lang_file_to_hash($filepath, \%dictionary, $trans_key); 
        }

}


sub conv_files_wanted {

        if(-f && $_ =~ /^.+\.php$/ ) {
                my $filepath = $_; # option 'no_chdir' in find() must be set for this assignment;
		say "filepath -> $filepath";

		#make_translation($filepath, \%dictionary, $overwrite);
        }

}



sub main() {
	$overwrite = 0;

	my $lang_directory_path = '/home/marko/Programming/Projects/LaraperlTrans/data/original_data/youbox/lang';
	my @controllers_and_blade_dirs = ("/var/www/youbox/application/resources/views");
	
	find({ wanted => \&lang_trans_wanted, no_chdir => 1 }, $lang_directory_path);
	#find({ wanted => \&conv_files_wanted, no_chdir => 1 }, @controllers_and_blade_dirs);

	my $path_to_file_to_convert = './data/original_data/youbox/all.blade.php';
	make_translation($path_to_file_to_convert, \%dictionary, $overwrite);

	# DEBUG - print populated translation dictionary
	#print Dumper \%dictionary;
}


# Run script and time it's start and finish.
my $datestring = localtime(time);
say "Started at $datestring";

main();

$datestring = localtime(time);
say "Ended at $datestring";
