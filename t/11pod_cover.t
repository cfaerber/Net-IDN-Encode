use strict;
use Test::More;

eval "use Test::Pod::Coverage;";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

plan tests => 2;
pod_coverage_ok('Net::IDN::UTS46', { 'trustme' => [ qr/^(to_ascii|to_unicode|mapping)$/ ] });
pod_coverage_ok('Net::IDN::UTS46::Mapping', { 'trustme' => [ qr/^(Is|Map)/ ] });
