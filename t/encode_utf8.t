use utf8;
use strict;

BEGIN { binmode STDOUT, ':utf8'; binmode STDERR, ':utf8'; }

use Test::More tests => 1+10;
use Test::NoWarnings;

use Net::IDN::Stupid qw(:all);

is(stupid_to_ascii('mueller'),'mueller');
is(stupid_to_ascii('xn--mller-kva'),'xn--mller-kva');
is(stupid_to_ascii('müller'),'xn--mller-kva');
is(stupid_to_ascii('中央大学'),'xn--fiq80yua78t');

is(eval{ stupid_to_ascii('xn--例')  }, undef);
is(eval{ stupid_to_ascii('xn--例')  }, undef);

is(stupid_to_unicode('mueller'),'mueller');
is(stupid_to_unicode('xn--mller-kva'),'müller');
is(stupid_to_unicode('müller'),'müller');
is(stupid_to_unicode('xn--fiq80yua78t'),'中央大学');
