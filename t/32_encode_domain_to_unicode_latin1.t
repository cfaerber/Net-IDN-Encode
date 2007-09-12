# $Id$

use bytes;
use strict;

use Test::More tests => 3;
use Net::IDN::Encode;

is(domain_to_unicode('faerber.muc.de'),'faerber.muc.de');
is(domain_to_unicode('xn--frber-gra.muc.de'),'färber.muc.de');
is(domain_to_unicode('xn--frber-gra.muc.de'),'färber.muc.de');
