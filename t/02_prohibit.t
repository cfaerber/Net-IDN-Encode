use strict;
use Test::More 'no_plan';

use Net::IDN::Nameprep::Prohibited;

my @ok  = ('0041');
my @not = ('0000', '00a0');

for my $ok (@ok) {
    ok(! Net::IDN::Nameprep::Prohibited->prohibited(hex $ok), "not prohibited - $ok");
}

for my $not (@not) {
    ok(Net::IDN::Nameprep::Prohibited->prohibited(hex $not), "prohibited - $not");
}

