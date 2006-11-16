package Encode::Punycode;

use strict;
our $VERSION = 0.02;

require Encode;
use base qw(Encode::Encoding);
__PACKAGE__->Define('Punycode', 'punycode');

require IDNA::Punycode;

sub encode {
    my($obj, $str, $chk) = @_;
    $str = IDNA::Punycode::encode_punycode($str);
    $_[1] = '' if $chk;
    return $str;
}

sub decode {
    my($obj, $str, $chk) = @_;
    $str = IDNA::Punycode::decode_punycode($str);
    $_[1] = '' if $chk;
    return $str;
}

1;
__END__

=head1 NAME

Encode::Punycode - Encode plugin for Punycode encodings

=head1 SYNOPSIS

  use Encode::Punycode;
  use Encode;

  $unicode  = decode('Punycode', $punycode);
  $punycode = encode('Punycode', $unicode);

=head1 DESCRIPTION

Encode::Punycode is an Encode plugin, which allows you to encode
Unicode strings into Punycode. Punycode is an efficient encoding
(ACE) of Unicode for use with IDNA.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://www.ietf.org/internet-drafts/draft-ietf-idn-punycode-01.txt

L<IDNA::Punycode>

=cut
