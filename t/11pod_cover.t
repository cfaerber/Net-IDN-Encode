use strict;
use Test::More;

eval "use Test::Pod::Coverage;";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

plan tests => 2;
pod_coverage_ok('Net::IDN::Punycode', 'Net::IDN::Punycode is covered by POD' );
pod_coverage_ok('Net::IDN::Stupid', { 'trustme' => [ qr/^(to_ascii|to_unicode|mapping)$/ ] });
