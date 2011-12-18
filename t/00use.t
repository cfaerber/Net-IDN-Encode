use strict;
use Test::More tests => 1 + 6;
use Test::NoWarnings;

use_ok 'Unicode::UTS46';
use_ok 'Unicode::UTS46::Mapping';

use_ok 'Net::IDN::Punycode';
use_ok 'Net::IDN::Punycode::PP';
use_ok 'Net::IDN::Encode';

use_ok 'Net::IDN::BiDi';
