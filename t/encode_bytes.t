use bytes;
use strict;

BEGIN { binmode STDOUT, ':utf8'; binmode STDERR, ':utf8'; }

use Test::More tests => 1+6;
use Test::NoWarnings;

use Net::IDN::Stupid qw(:all);

is(stupid_to_ascii('mueller'),'mueller');
is(stupid_to_ascii('xn--mller-kva'),'xn--mller-kva');
is(stupid_to_ascii('müller'),'xn--mller-kva');

is(stupid_to_unicode('mueller'),'mueller');
is(stupid_to_unicode('xn--mller-kva'),'müller');
is(stupid_to_unicode('müller'),'müller');
