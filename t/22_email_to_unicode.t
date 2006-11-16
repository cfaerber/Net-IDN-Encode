use utf8;
use strict;

use Test::More tests => 7;
use Net::IDN::Encode;

is(email_to_unicode('claus@faerber.muc.de'),'claus@faerber.muc.de');
is(email_to_unicode('claus＠faerber.muc.de'),'claus@faerber.muc.de');
is(email_to_unicode('claus@xn--frber-gra.muc.de'),'claus@färber.muc.de');
is(email_to_unicode('claus＠xn--frber-gra.muc.de'),'claus@färber.muc.de');
is(email_to_unicode('test@xn--fiq80yua78t.tw'),'test@中央大学.tw');
is(email_to_unicode(''),undef);
is(email_to_unicode('test'),'test');
