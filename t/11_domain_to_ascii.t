use utf8;
use strict;

use Test::More tests => 4;
use Net::IDN::Encode;

is(domain_to_ascii('faerber.muc.de'),'faerber.muc.de');
is(domain_to_ascii('xn--frber-gra.muc.de'),'xn--frber-gra.muc.de');
is(domain_to_ascii('färber.muc.de'),'xn--frber-gra.muc.de');
is(domain_to_ascii('中央大学.tw'),'xn--fiq80yua78t.tw');
