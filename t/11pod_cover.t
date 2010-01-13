use strict;
use Test::More tests => 2;

eval "use Test::Pod::Coverage;";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

pod_coverage_ok('Net::IDN::Encode', 'Net::IDN::Encode is covered by POD' );
pod_coverage_ok('Net::IDN::Punycode', 'Net::IDN::Punycode is covered by POD' );
