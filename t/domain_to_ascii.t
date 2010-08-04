use utf8;
use strict;

use Test::More;
use Test::NoWarnings;

use Net::IDN::Encode qw(:all);

my @domain_to_ascii = (
  ['single label', 'müller', 'xn--mller-kva', 0, 1],
  ['mixed dots', 'www.a.b。c．d｡com', 'www.a.b.c.d.com', 0, 1],
  ['blank (without STD3 rules)', 'www.a ä o ö u ü.org', 'www.xn--a  o  u -1za7prc.org', 0, 0],
  ['blank (with STD3 rules)', 'www.a ä o ö u ü.org', undef, 0, 1],
  ['zero-length label', 'www..com', undef, 0, 1],
  ['terminating dot', 'www.example.com..', 'www.example.com.', 0, 1],
);

plan tests => (@domain_to_ascii + 1);

for (@domain_to_ascii) {
  my ($comment,$in,$out,$allowunassigned,$usestd3asciirules) = @$_;
  my %param = (
    AllowUnassigned => $allowunassigned,
    UseSTD3ASCIIRules => $usestd3asciirules
  );
  is(eval{domain_to_ascii($in, %param)}, $out, $comment);
}
