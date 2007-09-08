# $Id$

use utf8;
use strict;

use Test::More tests => 4;
use Net::IDN::Encode;

is(domain_to_unicode('faerber.muc.de'),'faerber.muc.de');
is(domain_to_unicode('xn--frber-gra.muc.de'),'färber.muc.de');
is(domain_to_unicode('xn--frber-gra.muc.de'),'färber.muc.de');
is(domain_to_unicode('xn--fiq80yua78t.tw'),'中央大学.tw');
