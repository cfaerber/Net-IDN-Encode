# $Id$

use utf8;
use strict;

use Test::More tests => 16;
use IDNA::Punycode;

is(encode_punycode('faerber'),'faerber');
is(encode_punycode('xn--frber-gra'),'xn--frber-gra');
is(encode_punycode('färber'),'xn--frber-gra');
is(encode_punycode('中央大学'),'xn--fiq80yua78t');

is(decode_punycode('faerber'),'faerber');
is(decode_punycode('xn--frber-gra'),'färber');
is(decode_punycode('färber'),'färber');
is(decode_punycode('xn--fiq80yua78t'),'中央大学');

idn_prefix('yo--'); # yo, man

is(encode_punycode('faerber'),'faerber');
is(encode_punycode('yo--frber-gra'),'yo--frber-gra');
is(encode_punycode('färber'),'yo--frber-gra');
is(encode_punycode('中央大学'),'yo--fiq80yua78t');

is(decode_punycode('faerber'),'faerber');
is(decode_punycode('yo--frber-gra'),'färber');
is(decode_punycode('färber'),'färber');
is(decode_punycode('yo--fiq80yua78t'),'中央大学');
