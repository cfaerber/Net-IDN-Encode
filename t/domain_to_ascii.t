use utf8;
use strict;

use Net::IDN::Encode qw(:all);

use Test::More tests => 1 + 5;
use Test::NoWarnings;

use Net::IDN::Encode qw(:all);

binmode Test::More->builder->output,         ":utf8";
binmode Test::More->builder->failure_output, ":utf8";
binmode Test::More->builder->todo_output,    ":utf8";

is(eval{to_ascii('müller')} || $@, 'xn--mller-kva', 'single label');
is(eval{to_ascii('www.jürg.xn--mller-kva.com', )} || $@, 'www.xn--jrg-hoa.xn--mller-kva.com', 'mixed utf8/ace/ascii');
is(eval{to_ascii('www.a.b。c．d｡com', )} || $@, 'www.a.b.c.d.com', 'mixed dots');
is(eval{to_ascii('www.xn--a o u -1za7prc.org', 'UseSTD3ASCIIRules' => 0)}, undef, 'blank (without STD3 rules)');
is(eval{to_ascii('www.xn--a o u -1za7prc.org', 'UseSTD3ASCIIRules' => 1)}, undef, 'blank (with STD3 rules)');
