# $Id$

use bytes;
use strict;

use Test::More tests => 4;
use Net::IDN::Encode;

is(email_to_unicode('claus@faerber.muc.de'),'claus@faerber.muc.de');
is(email_to_unicode('claus@xn--frber-gra.muc.de'),'claus@färber.muc.de');
is(email_to_unicode(''),undef);
is(email_to_unicode('test'),'test');
