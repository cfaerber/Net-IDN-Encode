# $Id$

use bytes;
use strict;

use Test::More tests => 3;
use Net::IDN::Encode;

is(Net::IDN::Encode::_to_unicode('faerber'),'faerber');
is(Net::IDN::Encode::_to_unicode('xn--frber-gra'),'färber');
is(Net::IDN::Encode::_to_unicode('xn--frber-gra'),'färber');
