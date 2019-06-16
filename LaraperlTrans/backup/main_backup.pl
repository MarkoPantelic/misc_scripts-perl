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

# dependencies for importing modules
use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';

use My::Logic qw(lang_file_to_hash make_translation); 


sub main() {
	my (%dictionary);

	my $translation_filepath = './data/original_data/youbox/lang/en/admin/auth.php';
	my $file_to_conv_path = './data/original_data/youbox/all.blade.php';

	lang_file_to_hash($translation_filepath, \%dictionary); 
	make_translation($file_to_conv_path, \%dictionary);

	print Dumper \%dictionary;
}


# Run script and timeit
my $datestring = localtime(time);
say "Started at $datestring";

main();

$datestring = localtime(time);
say "Ended at $datestring";
