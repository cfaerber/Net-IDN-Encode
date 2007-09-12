# $Id$

use bytes;
use strict;

use Test::More tests => 5;
use Net::IDN::Encode;

is(email_to_ascii('claus@faerber.muc.de'),'claus@faerber.muc.de');
is(email_to_ascii('claus@xn--frber-gra.muc.de'),'claus@xn--frber-gra.muc.de');
is(email_to_ascii('claus@färber.muc.de'),'claus@xn--frber-gra.muc.de');
is(email_to_ascii(''), undef);
is(email_to_ascii('test'), 'test');
