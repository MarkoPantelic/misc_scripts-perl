
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
			print "FOUND";
			$dictionary{$filekey}{$+{key}} = $+{val};
		}
	}

	close(FILE);
	return %dictionary;
}


sub get_all_lang_files_paths() {

}


sub make_translation {
	# perform translation form Laravel's trans() func to __() func
	scalar(@_ == 2) || die "Invalid number of arguments received in lang_file_to_hash";
	my $filepath = shift;
	my $dictionary = shift;

	print "filepath of file to convert = $filepath\n";

	open(FILE, $filepath) || die "Couldn't open the file '$filepath'\n";

	while(<FILE>) {
		#print $_;
		if ($_ =~ m/(trans\((['"].*?['"])\s*,?\s*(\w{1}|\[.*?\])?\))/g) { #m/(trans\('.*?'\))/g;

			if(defined $1) {
				print "MATCHED $1 in $_ \n";
				print "key => $2 \n";
				my $s = $2;
				$s =~ s/['"]//g;
				my @translation_arr = (split /\./, $s);
				my $translation = $translation_arr[-1];
				print "translation key = " . $translation . "\n";
				print "trans sentence => " . $dictionary{'admin'}{$translation} . "\n";
			}
		}
	}

	close(FILE);	
}


# TRASH:

=pod
	foreach $key (keys %{$dictionary{$filekey}}) {
		$val = $dictionary{$filekey}{$key};
		print $key . " >>> " . $val . "\n";
	}
=cut

1;