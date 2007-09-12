package IDNA::Punycode;

use strict;
our $VERSION = 0.99_20070910;

require Exporter;
our @ISA	= qw(Exporter);
our @EXPORT 	= qw(encode_punycode decode_punycode idn_prefix);

use Net::IDN::Punycode();
use Net::IDN::Encode();

our $PREFIX = 'xn--';

sub idn_prefix {
	$PREFIX = shift;
}

sub decode_punycode {
	if ($PREFIX) {
		local $Net::IDN::Encode::IDNA_Prefix = $PREFIX;
		return Net::IDN::Encode::_to_ascii(shift);
	} else {
		return Net::IDN::Punycode::decode_punycode($code);
	}
}

sub encode_punycode {
	if ($PREFIX) {
		local $Net::IDN::Encode::IDNA_Prefix = $PREFIX;
		return Net::IDN::Encode::_to_unicode(shift);
	} else {
		return Net::IDN::Punycode::encode_punycode($code);
	}
}

1;
__END__

=head1 NAME

IDNA::Punycode -- DEPRECATED module for IDNA/Punyode encoding/decoding

This module is deprecated. Please use L<Net::IDN::Encode> to encode/decode
domain names and L<Net::IDN::Punycode> for raw PUNYCODE encoding.

This module is provided for compatibility with earlier versions of
IDNA::Punycode.

=head1 AUTHORS

Claus FÃ¤rber E<lt>perl@cfaerber.nameE<gt>

The original IDNA::Punycode module was written by
Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt> and extended by 
Robert Urban E<lt>urban@UNIX-Beratung.deE<gt>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::IDN::Encode>, L<Net::IDN::Punycode>

=cut
