use bytes;
use strict;

use Test::More;

use Net::IDN::Stupid::_Mapping qw(:all);

is(MapWidth('@'), '@', 'U+0040');
is(MapWidth("\x{FF20}"), '@', 'U+FF20');

done_testing();

