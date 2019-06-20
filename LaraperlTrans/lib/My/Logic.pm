package My::Logic;
use strict;
use warnings;
use v5.10;
use Data::Dumper qw(Dumper);
use File::Basename;
use File::Copy "mv";

use Exporter qw(import); 
our @EXPORT_OK = qw(lang_file_to_hash make_translation get_key_from_filepath);


sub  trim { 
	#php like trim
	
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s; 
};


sub file_contents_slurp {
	# slurp file contents into single variable
	
	scalar(@_ == 1) || die "Invalid number of arguments received in file_contents_slurp()";

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


sub get_key_from_filepath {
	# NOT USED NOW !@@@@@!!!
	# return possibly complex key from filepath 
	# e.g. if filepath 'application/resources/lang/en/admin/auth.php' return 'auth'
	
	scalar(@_ == 1) || die "Invalid number of arguments received in get_key_from_filepath()";
	my $filepath = shift;
	my @suffixlist = ('.php');

	my ($name, $path, $suffix) = fileparse($filepath, @suffixlist);
	return $name;
}


sub autovivication_insert {
	# recursive function to dynamicaly populate a hash with nested value
	# using autovivication 
	
	my ($val, $final_key, $ref, $head, @tail) = @_;

	if (@tail) { 
		autovivication_insert($val, $final_key, \%{$ref->{$head}}, @tail) 
	}
	else {            
		$ref->{$head}{$final_key} = $val;      
	}
}


sub lang_file_to_hash {
	# parse lang file from $filepath and put values into
	# $dictionary where key is complex and extracted from $filepath 
	
	scalar(@_ < 3) && die "Invalid number of arguments received in lang_file_to_hash()";
	#my ($filepath, $dictionary, @parent_key_parts) = @_; # FOR TRANS KEY AS ARRAY
	my ($filepath, $dictionary, $parent_key_part) = @_;

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
	
	my $f1 = shift;
	my $s3 = shift;
	my $dictionary = shift;

	if(defined $dictionary->{$s3}) {
		return "__('" . $dictionary->{$s3} . "')";
	}
	say "$0 - Log->Error: Key '$s3' not found.";
	return $f1;
}


sub make_translation {
	# perform translation form Laravel's trans() func to __() func
	
	scalar(@_ == 3) || die "Invalid number of arguments received in lang_file_to_hash";
	my $filepath = shift;
	my $dictionary = shift;
	my $overwrite = shift;

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
		my $match = $_ =~ s/$find_trans_re/fsub($1, $3, $dictionary)/xeg; 

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
