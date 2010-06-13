use utf8;
use strict;

use Test::More;
use Test::NoWarnings;

use Net::IDN::Encode qw(:all);

my @domain_to_unicode = (
  ['single label', 'xn--mller-kva', 'müller', 0, 1],
  ['mixed utf8/ace/ascii', 'www.jürg.xn--mller-kva.com', 'www.jürg.müller.com', 0, 1],
  ['mixed dots', 'www.a.b。c．d｡com', 'www.a.b。c．d｡com', 0, 1],
  ['blank (without STD3 rules)', 'www.xn--a  o  u -1za7prc.org', 'www.a ä o ö u ü.org', 0, 0],
  ['blank (with STD3 rules)', 'www.xn--a  o  u -1za7prc.org', 'www.xn--a  o  u -1za7prc.org', 0, 1],
);

plan tests => (@domain_to_unicode + 1);

for (@domain_to_unicode) {
  my ($comment,$in,$out,$allowunassigned,$usestd3asciirules) = @$_;
  my %param = (
    AllowUnassigned => $allowunassigned,
    UseSTD3ASCIIRules => $usestd3asciirules
  );
  is(domain_to_unicode($in, %param), $out, $comment);
}
