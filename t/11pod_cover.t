use strict;
use Test::More;

eval "use Test::Pod::Coverage;";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

plan tests => 5;
pod_coverage_ok('Net::IDN::Encode', 'Net::IDN::Encode is covered by POD' );
pod_coverage_ok('Net::IDN::Punycode', 'Net::IDN::Punycode is covered by POD' );
pod_coverage_ok('Net::IDN::Punycode::PP', 'Net::IDN::Punycode is covered by POD' );

TODO: {
local $TODO = 'document Net::IDN::UTS46';
pod_coverage_ok('Net::IDN::UTS46', 'Net::IDN::UTS46 is covered by POD' );
pod_coverage_ok('Net::IDN::UTS46::Mapping', 'Net::IDN::UTS46::Mapping is covered by POD' );
}
