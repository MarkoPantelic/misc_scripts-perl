use strict;
use warnings;
use v5.10;

use Test::Simple tests =>1;

use My::Logic qw(make_parent_trans_key);

ok ( make_parent_trans_key('en', '/var/www/laravel-project/application/lang/en/langfile.php') eq 'langfile' );
