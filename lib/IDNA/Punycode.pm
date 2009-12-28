package IDNA::Punycode;

use strict;
use utf8;
use warnings;

our $VERSION = '0.99_20091231';
$VERSION = eval $VERSION;

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
		local $Net::IDN::Encode::IDNA_prefix = $PREFIX;
		return Net::IDN::Encode::_to_unicode(shift);
	} else {
		return Net::IDN::Punycode::decode_punycode(shift);
	}
}

sub encode_punycode {
	if ($PREFIX) {
		local $Net::IDN::Encode::IDNA_prefix = $PREFIX;
		return Net::IDN::Encode::_to_ascii(shift);
	} else {
		return Net::IDN::Punycode::encode_punycode(shift);
	}
}

1;
__END__

=head1 NAME

IDNA::Punycode - DEPRECATED module for IDNA and Punyode

=head1 DESCRIPTION

This module is deprecated.

Please use L<Net::IDN::Encode> to handle full domain names and
L<Net::IDN::Punycode> for raw I<Punycode> encoding.

This module is provided for compatibility with earlier versions of
C<IDNA::Punycode>.

=head1 FUNCTIONS

The following functions are imported by default. If you also C<use Net::IDN::Punycode>,
be sure to disable import from this module:

  use IDNA::Punycode();

=over

=item idn_prefix($prefix)

Sets C<$IDNA::Punycode::PREFIX> to C<$prefix>.

B<Do not use this function> in larger applications or environments
in which multiple application share global variables (such as
L<mod_perl>). Instead, set the variable locally:

  local $IDNA::Punycode::PREFIX = 'yo--';

=item encode_punycode($input)

If C<$IDNA::Punycode::PREFIX> is C<''>, encodes C<$input> with
Punycode.

If C<$IDNA::Punycode::PREFIX> is not C<''>, encodes C<$input> with
Punycode and adds the prefix if C<$input> does contain non-base
characters (S<i. e.> characters above U+007F). If C<$input> does
not contain any non-base characters, it is returned as-is.

This function does not do any string preparation as specified by
I<nameprep> or other I<stringprep> profiles.  Use
L<Net::IDN::Encode> if you just want to convert a domain name.

This function will croak on invalid input.

=item decode_punycode($input)

If C<$IDNA::Punycode::PREFIX> is C<''>, decodes C<$input> with
Punycode.

If C<$IDNA::Punycode::PREFIX> is not C<''>, checks whether
C<$input> starts with the prefix. If C<$input> starts with the
prefix, the prefix is removed and the remainder is decoded with
Punycode. If C<$input> does not start with the prefix, it is
returned as-is.

Of course, this function does not do any string preparation as
specified by I<nameprep> or other I<stringprep> profiles (or some
sort of de-preparation).

This function will croak on invalid input.

=back

=head1 AUTHORS

Claus FE<auml>rber <CFAERBER@cpan.org>

Previous version written by Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>
and extended by Robert Urban E<lt>urban@UNIX-Beratung.deE<gt>.

=head1 LICENSE

Copyright 2007-2009 Claus FE<auml>rber.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Encode>, L<Net::IDN::Encode>, L<Net::IDN::Punycode>,
S<RFC 3492> (L<http://www.ietf.org/rfc/rfc3492.txt>)

=cut
