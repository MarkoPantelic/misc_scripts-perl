use strict;
use warnings;
use v5.10;

use Test::Simple tests =>1;

use My::Logic qw(get_key_from_filepath);

ok ( get_key_from_filepath('/path/to/file/admin/something.php') eq 'something' );
