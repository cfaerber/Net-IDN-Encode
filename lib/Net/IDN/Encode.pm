package Net::IDN::Encode;

use strict;
use utf8;
use warnings;

our $VERSION = "1.999_20120108";
$VERSION = eval $VERSION;

use Carp;
use Exporter;

our @ISA = ('Exporter');
our @EXPORT = ();
our %EXPORT_TAGS = (
  'all'	 => [
      'to_ascii',
      'to_unicode',
      'domain_to_ascii',
      'domain_to_unicode',
      'email_to_ascii',
      'email_to_unicode',
    ],
  '_var' => [
      '$IDNA_PREFIX',
      '$IDNA_DOT',
      '$IDNA_ATSIGN',
    ]
);
Exporter::export_ok_tags(keys %EXPORT_TAGS);

use Net::IDN::Punycode 1 ();

our ($IDNA_PREFIX,$IDNA_DOT,$IDNA_ATSIGN);
*IDNA_PREFIX 	= \'xn--';
*IDNA_DOT	= \qr/[\.。．｡]/;
*IDNA_ATSIGN	= \qr/[\@＠]/;

require Net::IDN::UTS46; # after declaration of vars!

sub to_ascii {
  my($label,%param) = @_;
  croak 'Invalid label' if $label =~ m/$IDNA_DOT/o;
  eval { $label = Net::IDN::UTS46::to_ascii(@_) };
  die $@ if $@ and ($label =~ m/\P{ASCII}/);
  return $label;
}

sub to_unicode {
  my($label,%param) = @_;
  croak 'Invalid label' if $label =~ m/$IDNA_DOT/o;
  eval { $label = Net::IDN::UTS46::to_unicode(@_) };
  die $@ if $@ and ($label =~ m/\P{ASCII}/);
  return $label;
}

sub _domain {
  my ($domain,$to_function,$ascii,%param) = @_;
  $param{'UseSTD3ASCIIRules'} = 1 unless exists $param{'UseSTD3ASCIIRules'};

  my $even_odd = 1;
  return join '',
    map { $even_odd++ % 2 ? $to_function->($_, %param) : $ascii ? '.' : $_ }
      split /($IDNA_DOT)/o, $domain;
}

sub _email {
  my ($email,$to_function,$ascii,%param) = @_;
  return $email if !defined($email) || $email eq '';

  $email =~ m/^(
	(?(?!$IDNA_ATSIGN|").|(?!))+
	|
	"(?:(?:[^"]|\\.)*[^\\])?"
      )
      (?:
	($IDNA_ATSIGN)
   	(?:([^\[\]]*)|(\[.*\]))?
      )?$/xo || croak "Invalid email address";
  my($local_part,$at,$domain,$domain_literal) = ($1,$2,$3);

  $local_part =~ m/\P{ASCII}/ && croak "Non-ASCII characters in local-part";
  $domain_literal =~ m/\P{ASCII}/ && croak "Non-ASCII characters in domain-literal" if $domain_literal;

  $domain = $to_function->($domain,%param) if $domain;
  $at = '@' if $ascii;

  return ($domain || $domain_literal)
    ? ($local_part.$at.($domain || $domain_literal))
    : ($local_part);
}

sub domain_to_ascii { _domain(shift, \&to_ascii, 1, @_) }
sub domain_to_unicode { _domain(shift, \&to_unicode, 0, @_) }

sub email_to_ascii   { _email(shift, \&domain_to_ascii, 1, @_) }
sub email_to_unicode { _email(shift, \&domain_to_unicode, 0, @_) }

1;

__END__

=encoding utf8

=head1 NAME

Net::IDN::Encode - Internationalizing Domain Names in Applications (IDNA)

=head1 SYNOPSIS

  use Net::IDN::Encode ':all';
  my $a = domain_to_ascii("müller.example.org");
  my $e = email_to_ascii("POSTMASTER@例。テスト");
  my $u = domain_to_unicode('EXAMPLE.XN--11B5BS3A9AJ6G');

=head1 DESCRIPTION

This module provides an easy-to-use interface for encoding and
decoding Internationalized Domain Names (IDNs).

IDNs use characters drawn from a large repertoire (Unicode), but
IDNA allows the non-ASCII characters to be represented using only
the ASCII characters already allowed in so-called host names today
(letter-digit-hypen, C</[A-Z0-9-]/i>).

Use this module if you just want to convert domain names (or email addresses),
using whatever IDNA standard is the best choice at the moment.

=head1 FUNCTIONS

By default, this module does not export any subroutines. You may
use the C<:all> tag to import everything. You can also use regular
expressions such as C</^to_/> or C</^email_/> to select some of
the functions, see L<Exporter> for details.

The following functions are available:

=over

=item to_ascii( $label, %param )

Converts a single label C<$label> to ASCII. Will throw an exception on invalid
input. If C<$label> is already a valid ASCII domain label (including most
NON-LDH labels such as those used for SRV records and fake A-labels), this
function will never fail but return C<$label> as-is if conversion would fail.

This function takes the following optional parameters (C<%param>):

=over

=item AllowUnassigned

(boolean) If set to a true value, unassigned code points in the label are
allowed. While maximizing the compatibility with future versions of Unicode
and/or IDNA, this option is also dangerous: Characters added in future versions
of Unicode might have properties that affect the conversion; you might
therefore end up with a conversion that is incompatible with later standards.
Therefore, set this to false unless you know what you are doing.

The default is false.

=item UseSTD3ASCIIRules

(boolean) If set to a true value, checks the label for compliance with S<STD 3>
(S<RFC 1123>) syntax for host name parts. The exact checks done depend on the
IDNA standard used. Usually, you will want to set this to true.

Please note that UseSTD3ASCIIRules only affects the conversion between ASCII
labels (A-labels) and Unicode labels (U-labels). Labels that are in ASCII may
still be passed-through as-is.

For historical reasons, the default is false (unlike C<domain_to_ascii>).

=item TransitionalProcessing

(boolean) If set to true, the conversion will be compatible with IDNA2003. This
only affects four characters: C<'ß'> (U+00DF), 'ς' (U+03C2), ZWJ (U+200D) and
ZWNJ (U+200C). Usually, you will want to set this to false.

The default is false.

=back

This function does not handle strings that consist of multiple labels (such as
domain names). Use C<domain_to_ascii> instead.

=item to_unicode( $label, %param )

Converts a single label C<$label> to Unicode. Will throw an exception on
invalid input. If C<$label> is an ASCII label (including most NON-LDH labels
such as those used for SRV records), this function will not fail but return
C<$label> as-is if conversion would fail.

This function takes the same optional parameters as C<to_ascii>,
with the same defaults.

If C<$label> is already in ASCII, this function will never fail but return
C<$label> as is as a last resort (i.e. pass-through).

This function takes the following optional parameters (C<%param>):

=over

=item AllowUnassigned

=item UseSTD3ASCIIRules

See C<to_unicode> above. Please note that there is no C<TransitionalProcessing>
for C<to_unicode>.

=back

This function does not handle strings that consist of multiple labels (such as
domain names). Use C<domain_to_unicode> instead.

=item domain_to_ascii( $label, %param )

Converts all labels of the hostname C<$domain> (with labels seperated by dots)
to ASCII (using C<to_ascii>). Will throw an exception on invalid input.

This function takes the following optional parameters (C<%param>):

=over

=item AllowUnassigned

=item TransitionalProcessing

See C<to_unicode> above.

=item UseSTD3ASCIIRules

(boolean) If set to a true value, checks the label for compliance with S<STD 3>
(S<RFC 1123>) syntax for host name parts.

The default is true (unlike C<to_ascii>).

=back

This function will convert all dots to ASCII, i.e. to U+002E (full stop). The
following characters are recognized as dots: U+002E (full stop), U+3002
(ideographic full stop), U+FF0E (fullwidth full stop), U+FF61 (halfwidth
ideographic full stop).

=item domain_to_unicode( $domain, %param )

Converts all labels of the hostname C<$domain> (with labels seperated by dots)
to Unicode. Will throw an exception on invalid input.

This function takes the same optional parameters as C<domain_to_ascii>,
with the same defaults.

This function takes the following optional parameters (C<%param>):

=over

=item AllowUnassigned

=item UseSTD3ASCIIRules

See C<domain_to_unicode> above. Please note that there is no C<TransitionalProcessing>
for C<domain_to_unicode>.

=back

This function will preserve the original version of dots.  The following
characters are recognized as dots: U+002E (full stop), U+3002 (ideographic full
stop), U+FF0E (fullwidth full stop), U+FF61 (halfwidth ideographic full stop).

=item email_to_ascii( $email, %param )

Converts the domain part (right hand side, separated by an at sign) of an S<RFC
2821>/2822 email address to ASCII, using C<domain_to_ascii>. May throw an
exception on invalid input.

It takes the same parameters as C<domain_to_ascii>.

This function currently does not handle internationalization of the local-part
(left hand side). Future versions of this module might implement an ASCII
conversion for the local-part, should one be standardized.

This function will convert the at sign to ASCII, i.e. to U+0040 (commercial
at), as well as label separators.  The follwing characters are recognized as at
signs: U+0040 (commercial at), U+FF20 (fullwidth commercial at).

=item email_to_unicode( $email, %param )

Converts the domain part (right hand side, separated by an at sign) of an S<RFC
2821>/2822 email address to Unicode, using C<domain_to_unicode>. May throw an
exception on invalid input.

It takes the same parameters as C<domain_to_unicode>.

This function currently does not handle internationalization of the local-part
(left hand side).  Future versions of this module might implement a conversion
from ASCII for the local-part, should one be standardized.

This function will preserve the original version of at signs (and label
separators). The follwing characters are recognized as at signs: U+0040
(commercial at), U+FF20 (fullwidth commercial at).

=back

=head1 AUTHOR

Claus FE<auml>rber <CFAERBER@cpan.org>

=head1 LICENSE

Copyright 2007-2012 Claus FE<auml>rber.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::IDN::Punycode>, L<Net::IDN::UTS46>, L<Net::IDN::IDNA2003>,
L<Net::IDN::IDNA2008>, S<UTS #46> (L<http://www.unicode.org/reports/tr46/>),
S<RFC 5890> (L<http://tools.ietf.org/html/rfc5890>).

=cut
