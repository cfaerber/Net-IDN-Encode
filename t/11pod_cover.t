use strict;
use Test::More;

eval "use Test::Pod::Coverage;";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

plan tests => 1;
pod_coverage_ok('Net::IDN::Punycode', 'Net::IDN::Punycode is covered by POD' );
