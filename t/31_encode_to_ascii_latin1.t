# $Id$

use bytes;
use strict;

use Test::More tests => 3;
use Net::IDN::Encode;

is(Net::IDN::Encode::_to_ascii('faerber'),'faerber');
is(Net::IDN::Encode::_to_ascii('xn--frber-gra'),'xn--frber-gra');
is(Net::IDN::Encode::_to_ascii('färber'),'xn--frber-gra');
