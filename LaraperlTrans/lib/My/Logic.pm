package My::Logic;
use strict;
use warnings;
use v5.10;
use Data::Dumper qw(Dumper);
use File::Basename;
use File::Copy "mv";

use My::Helpers qw(trim file_contents_slurp autovivication_insert);

use Exporter qw(import); 
our @EXPORT_OK = qw(lang_file_to_hash make_translation get_key_from_filepath make_parent_trans_key);


sub lang_file_to_hash {
	# parse lang file from $filepath and put values into
	# $dictionary where key is complex and extracted from $filepath 
	
	(@_ < 3) && die "Invalid number of arguments received in lang_file_to_hash()";
	my ($filepath, $dictionary, $parent_key_part) = @_; # @parent_key_parts FROM TRANS KEY AS ARRAY

	#my $filekey = get_key_from_filepath($filepath); # NOT USED NOW

	my $content = file_contents_slurp($filepath); 

	while ($content =~ m/^\s*(['"])(?<key>.+?)\1\s*  # match array key surrounded by quotes 
			     =>  
			     \s*(['"])(?<val>.+?)\3\s*   # match array value surrounded by quotes
			     				 # m - do not ignore \n, s -  as a single string
			     /xsgm ) {                     

		if(defined $+{key} && defined $+{val}) {
			#$dictionary->{$filekey}{$+{key}} = $+{val}; # NOT USED NOW

			#autovivication_insert($+{val}, $+{key}, $dictionary, @parent_key_parts); # FOR TRANS KEY AS ARRAY
			
			my $translation_key = $parent_key_part . '.' . $+{key}; 
			$dictionary->{$translation_key} = $+{val};
		}
	}

	close(FILE);
	return $dictionary;
}


sub fsub {	
	# substitute inside regex substitution
	
	my ($f1, $s3, $dictionary, $overwrite, $err_report) = @_;

	if(defined $dictionary->{$s3}) {
		return "__('" . $dictionary->{$s3} . "')";
	}
	if($overwrite == 0 || ($err_report && $err_report < 2) ) {
		say "Error!!!:         Key '$s3' not found.";
	}
	if($err_report && $err_report > 2) {
		#TODO: save error report to array and display it at the end of processing
	}

	return $f1;
}


sub make_lang_subparts_arr
{
	# create array subparts from lang file path
	my $lang = shift;	
	my $filepath = shift;

	say "lang -> $lang";
	say "filepath -> $filepath";

	my @parts = split("/lang/$lang/", $filepath);
	scalar(@parts) >= 2 || die "Error! Laravel 'lang' folder path is unexpected!";

	my $lang_branch = $parts[-1];
	my @subparts = split("/", $lang_branch);

	return @subparts;
}


sub ptk_from_array
{
        # create translation parent key string in string form
        # 'parent_folder/filename' from supplied array parts

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


sub make_parent_trans_key {
        # create translation parent key string in string form
        # 'parent_folder/filename' from supplied filepath

	my $lang = shift;	
	my $filepath = shift;

	my @subparts = make_lang_subparts_arr($lang, $filepath);

	return ptk_from_array(@subparts);

}


sub make_translation {
	# perform translation form Laravel's trans() func to __() func
	
	(@_ == 3) || die "Invalid number of arguments received in lang_file_to_hash";
	my ($filepath, $dictionary, $overwrite) = @_;

	open(FILE, $filepath) || die "Couldn't open the file '$filepath'\n"; my ($fname, $fpath_dir) = fileparse($filepath);

	my $temp_filepath = "/tmp/.__temp_$fname"; #"${fpath_dir}.__temp_$fname";
	open(FILE_OUT,'>', $temp_filepath) || die "Couldn't create the file '~/custom_file'. err -> $! \n";

	my $find_trans_re = qr/(
				  trans\(
				     (['"])(.+?)\2\s*         # capture translation key
			     	     ,?\s*
			     	     (\w+?|\[.*?\])?          # capture optional trans() parameter(s)
			     	  \)
			       )/x;

	while(<FILE>) {
		#if ($_ =~ m/(trans\((['"])(.+?)\2\s*
		#	     ,?\s*
		#	     (\w+?|\[.*?\])?
		#	     \))/xg) {

		my $untainted_line = $_;
		my $match = $_ =~ s/$find_trans_re/fsub($1, $3, $dictionary, $overwrite)/xeg; 

		if($overwrite == 0 && $match) {
			print "Would substitute: ";
			say trim($untainted_line);
			print "With:             ";
			say trim($_);
		}

		print FILE_OUT $_;
	}

	close(FILE);	
	close(FILE_OUT);

	# TODO: here rewind FILE and do a manual copy/overwrite
	if($overwrite == 1) {
		say "Overwriting file $filepath";
		my $err_msg = "Couldn't perform regex substitution on the file $filepath. ";

		unlink($filepath) || die $err_msg . $!;

		# TODO: keep permissions of original $filepath file 
		mv($temp_filepath, $filepath) || die $err_msg . $!;	
		say "File overwritten successfully";
	}
}

1; # module truthness
