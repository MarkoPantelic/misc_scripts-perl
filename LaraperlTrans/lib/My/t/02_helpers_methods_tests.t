use strict;
use warnings;
use v5.10;

use Test::Simple tests =>1;

use My::Helpers qw(trim);

ok ( trim('  whatever         ') eq 'whatever' );
