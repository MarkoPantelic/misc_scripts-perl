use warnings;
use strict;
use v5.10;

#use Path::Iterator::Rule;
use File::Find;
use File::Basename;

print "OK\n";

sub lang_trans_wanted
{
	my $lang = "en";

	if(-f && $_ =~ /^.+\.php$/ ) {
		my $filepath = $_; # option no_chdir must be set;
		#say "dirname " . $File::Find::dir; 

		say "path $filepath";	

		my @parts = split("/lang/$lang/", $filepath);
		my $lang_branch_part = @parts[-1];
		my @subparts = split("/", $lang_branch_part);

		my @suffixlist = ".php";
		my ($filename, $path, $suffix) = fileparse($filepath, @suffixlist);
		$subparts[-1] = $filename; #(split('.', $subparts[-1]))[0];		

		say "PARTS:";
		foreach my $part (@subparts) {
			say $part;
		}
	}

}

my @directories = ('/home/marko/Programming/Projects/LaraperlTrans/data/original_data/youbox/lang');
find({ wanted => \&lang_trans_wanted, no_chdir => 1}, @directories);

