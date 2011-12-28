use strict;
use Test::More;

eval "use Test::Pod::Coverage;";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

plan tests => 4;
pod_coverage_ok('Net::IDN::Encode', 'Net::IDN::Encode is covered by POD' );
pod_coverage_ok('Net::IDN::Punycode', 'Net::IDN::Punycode is covered by POD' );

pod_coverage_ok('Net::IDN::UTS46', { 'trustme' => [ qr/^(to_ascii|to_unicode|mapping)$/ ] });
pod_coverage_ok('Net::IDN::UTS46::Mapping', { 'trustme' => [ qr/^(Is|Map)/ ] });
