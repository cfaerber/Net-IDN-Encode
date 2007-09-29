# $Id: 09encode_punycode.t 60 2007-09-29 19:03:40Z cfaerber $

use strict;
use Test::More tests => 2;

use_ok 'IDNA::Punycode';

use_ok 'Encode::Punycode';
