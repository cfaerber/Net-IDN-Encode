# $Id$

use bytes;
use strict;

use Test::More tests => 3;
use Net::IDN::Encode;

is(domain_to_ascii('faerber.muc.de'),'faerber.muc.de');
is(domain_to_ascii('xn--frber-gra.muc.de'),'xn--frber-gra.muc.de');
is(domain_to_ascii('färber.muc.de'),'xn--frber-gra.muc.de');
