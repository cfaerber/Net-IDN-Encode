use strict;
use utf8;
use warnings;

BEGIN { binmode STDOUT, ':utf8'; binmode STDERR, ':utf8'; }

use Test::More;
use Net::IDN::UTS46 (':all');

BEGIN { 
	plan skip_all => 'no XS version' if eval {
		\&Net::IDN::Punycode::encode_punycode ==
		\&Net::IDN::Punycode::PP::encode_punycode; }

}
use Test::NoWarnings;

plan tests => 1 + 4;
no warnings 'utf8';

my %p = ("TransitionalProcessing" => "0");

is(eval{uts46_to_ascii("xn--0.pt", %p)},	undef,	"to_ascii\(\'xn\-\-0\.pt\'\)\ throws\ error\ A3\ \[data\/IdnaTest\.txt\:256\]") or ($@ and diag($@));
is(eval{uts46_to_unicode("xn--0.pt", %p)},	undef,	"to_unicode\(\'xn\-\-0\.pt\'\)\ throws\ error\ A3\ \[data\/IdnaTest\.txt\:256\]") or ($@ and diag($@));
is(eval{Net::IDN::Punycode::decode_punycode(0)},undef,	"decode_punycode(0) throws error") or ($@ and diag($@));
is(eval{uts46_to_unicode("xn--u19a")},		'ꯀ',	"to_unicode\(\'xn\-\-u19a\'\)");

exit(0);
