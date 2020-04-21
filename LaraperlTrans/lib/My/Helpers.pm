package My::Helpers;
use strict;
use warnings;
use v5.10;
use Data::Dumper qw(Dumper);

use Exporter qw(import); 
our @EXPORT_OK = qw(trim file_contents_slurp autovivication_insert);

sub  trim {
        #php like trim

        my $s = shift;
        $s =~ s/^\s+|\s+$//g;
        return $s;
};


sub file_contents_slurp {
        # slurp file contents into single variable

        (@_ == 1) || die "Invalid number of arguments received in file_contents_slurp()";

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

sub uniq {
        # Remove duplicate values from array.
        my %seen;
        grep !$seen{$_}++, @_;
}


