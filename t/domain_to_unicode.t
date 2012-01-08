use utf8;
use strict;

BEGIN { binmode STDOUT, ':utf8'; binmode STDERR, ':utf8'; }

use Test::More tests => 1 + 6;
use Test::NoWarnings;

use Net::IDN::Encode qw(:all);

is(eval{domain_to_unicode('xn--mller-kva')} || $@, 'müller', 'single label (to_unicode)');
is(eval{domain_to_unicode('www.jürg.xn--mller-kva.com', )} || $@, 'www.jürg.müller.com', 'mixed utf8/ace/ascii (to_unicode)');
is(eval{domain_to_unicode('www.a.b。c．d｡com', )} || $@, 'www.a.b。c．d｡com', 'mixed dots (to_unicode)');
is(eval{domain_to_unicode('www.xn--a o u -1za7prc.org', 'UseSTD3ASCIIRules' => 0)}, undef, 'blank (without STD3 rules) (to_unicode)');
is(eval{domain_to_unicode('www.xn--a o u -1za7prc.org', 'UseSTD3ASCIIRules' => 1)}, undef, 'blank (with STD3 rules) (to_unicode)');

is(eval{domain_to_unicode('_test._srv.xn--mller-kva.example.com')}, '_test._srv.müller.example.com', 'SRV record');
