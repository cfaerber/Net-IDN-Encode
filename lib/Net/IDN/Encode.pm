package Net::IDN::Encode;

use strict;
use utf8;
use warnings;

our $VERSION = "1.100";
$VERSION = eval $VERSION;

use Carp;
use Exporter;

use Net::IDN::Nameprep 1.1 ();
use Net::IDN::Punycode 1 ();

our @ISA = ('Exporter');
our @EXPORT = ();
our @EXPORT_OK = (
  'to_ascii', 'to_unicode',
  'domain_to_ascii',
  'domain_to_unicode',
  'email_to_ascii',
  'email_to_unicode',
);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

our $IDNA_prefix = 'xn--';
our $DOT = qr/[\.。．｡]/;

sub to_ascii {
  use bytes;
  no warnings qw(utf8); # needed for perl v5.6.x

  my ($label,%param) = @_;

  if($label =~ m/[^\x00-\x7F]/) {
    $label = Net::IDN::Nameprep::nameprep($label,%param);
  }

  if($param{'UseSTD3ASCIIRules'}) {
    croak 'Invalid label (toASCII, step 3)' if
      $label =~ m/^-/ ||
      $label =~ m/-$/ ||
      $label =~ m/[\x00-\x2C\x2E-\x2F\x3A-\x40\x5B-\x60\x7B-\x7F]/;
  }

  if($label =~ m/[^\x00-\x7F]/) {
    croak 'Invalid label (toASCII, step 5)' if $label =~ m/^$IDNA_prefix/io;
    $label = $IDNA_prefix.(Net::IDN::Punycode::encode_punycode($label));
  }

  croak 'Invalid label length (toASCII, step 8)' if
    length($label) == 0 ||
    length($label) > 63;

  return $label;
}

sub to_unicode {
  use bytes;

  my ($label,%param) = @_;
  my $orig = $label;

  return eval {
    if($label =~ m/[^\x00-\x7F]/) {
      $label = Net::IDN::Nameprep::nameprep($label,%param);
    }

    my $save3 = $label;
    croak 'Missing IDNA prefix (ToUnicode, step 3)'
      unless $label =~ s/^$IDNA_prefix//io;
    $label = Net::IDN::Punycode::decode_punycode($label);

    my $save6 = to_ascii($label,%param);

    croak 'Invalid label (ToUnicode, step 7)' unless uc($save6) eq uc($save3);

    $label;
  } || $orig;
}

sub domain_to_ascii {
  my ($domain,%param) = @_;
  $param{'UseSTD3ASCIIRules'} = 1 unless exists $param{'UseSTD3ASCIIRules'};
  $domain = join '.',
    map { to_ascii($_, %param) }
      split /$DOT/o, $domain;
  croak 'Invalid domain length' if length($domain) > 255;
  return $domain;
}

sub domain_to_unicode {
  my ($domain,%param) = @_;
  $param{'UseSTD3ASCIIRules'} = 1 unless exists $param{'UseSTD3ASCIIRules'};
  return join '',
    map { /$DOT/o ? $_ : to_unicode($_, %param) }
      split /($DOT+)/o, $domain;
}

sub _email {
  use utf8;
  my ($email,$to_function,@param) = @_;
  return $email if !defined($email) || $email eq '';

  $email =~ m/^([^"\@＠]+|"(?:(?:[^"]|\\.)*[^\\])?")(?:[\@＠]
    (?:([^\[\]]*)|(\[.*\]))?)?$/x || croak "Invalid email address";
  my($local_part,$domain,$domain_literal) = ($1,$2,$3);

  $local_part =~ m/[^\x00-\x7F]/ && croak "Invalid email address";
  $domain_literal =~ m/[^\x00-\x7F]/ && croak "Invalid email address" if $domain_literal;

  $domain = $to_function->($domain,@param) if $domain;

  return ($domain || $domain_literal)
    ? ($local_part.'@'.($domain || $domain_literal))
    : ($local_part);
}

sub email_to_ascii { _email(shift,\&domain_to_ascii) }
sub email_to_unicode { _email(shift,\&domain_to_unicode) }

1;

__END__

=encoding utf8

=head1 NAME

Net::IDN::Encode - Internationalizing Domain Names in Applications (S<RFC 3490>)

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

=head1 FUNCTIONS

By default, this module does not export any subroutines. You may
use the C<:all> tag to import everything. You can also use regular
expressions such as C</^to_/> or C</^email_/> to select some of
the functions, see L<Exporter> for details.

The following functions are available:

=over

=item to_ascii( $label [, AllowUnassigned => 0] [, UseSTD3ASCIIRules => 1 ] )

Converts a single label C<$label> to ASCII. Will throw an
exception on invalid input.

This function takes the following optional parameters:

=over

=item AllowUnassigned

(boolean) If set to a false value, unassigned code points in the label are not allowed.

The default is determinated by C<Net::IDN::Nameprep::nameprep>.

=item UseSTD3ASCIIRules

(boolean) If set to a true value, checks the label for compliance with S<STD 3>
(S<RFC 1123>) syntax for host name parts.

The default is false (unlike C<domain_to_ascii>).

=back

This function does not try to handle strings that consist of
multiple labels (such as domain names).

=item to_unicode( $label [, AllowUnassigned => 0] [, UseSTD3ASCIIRules => 1 ] )

Converts a single label C<$label> to Unicode. Any input is valid.

This function takes the same optional parameters as C<to_ascii>,
with the same defaults.

This function does not try to handle strings that consist of
multiple labels (such as domain names).

=item domain_to_ascii( $label [, AllowUnassigned => 0] [, UseSTD3ASCIIRules => 1 ] )

Converts all labels of the hostname C<$domain> (with labels
seperated by dots) to ASCII. Will throw an exception on invalid
input.

This function takes the following optional parameters:

=over

=item AllowUnassigned

(boolean) If set to a false value, unassigned code points in the label are not allowed.

The default determinated by C<Net::IDN::Nameprep::nameprep>.

=item UseSTD3ASCIIRules

(boolean) If set to a true value, checks the label for compliance with S<STD 3>
(S<RFC 1123>) syntax for host name parts.

The default is true (unlike C<to_ascii>).

=back

The following characters are recognized as dots: U+002E (full
stop), U+3002 (ideographic full stop), U+FF0E (fullwidth full
stop), U+FF61 (halfwidth ideographic full stop).

=item domain_to_unicode( $domain [, AllowUnassigned => 0] [, UseSTD3ASCIIRules => 1 ] )

Converts all labels of the hostname C<$domain> (with labels
seperated by dots) to Unicode. Any input is valid.

This function takes the same optional parameters as C<domain_to_ascii>,
with the same defaults.

The following characters are recognized as dots: U+002E (full
stop), U+3002 (ideographic full stop), U+FF0E (fullwidth full
stop), U+FF61 (halfwidth ideographic full stop).

=item email_to_ascii( $email )

Converts the domain part (right hand side, separated by an
at sign) of the S<RFC 2821>/2822 email address to ASCII. May throw an
exception on invalid input.

This function currently does not handle internationalization of
the local-part (left hand side). This may change in future versions.

The follwing characters are recognized as at signs: U+0040
(commercial at), U+FF20 (fullwidth commercial at).

=item email_to_unicode( $email )

Converts the domain part (right hand side, separated by an
at sign) of the S<RFC 2821>/2822 email address to Unicode. May throw
an exception on invalid input.

This function currently does not handle internationalization of
the local-part (left hand side). This may change in future versions.

The follwing characters are recognized as at signs: U+0040
(commercial at), U+FF20 (fullwidth commercial at).

=back

=head1 AUTHOR

Claus FE<auml>rber <CFAERBER@cpan.org>

=head1 LICENSE

Copyright 2007-2010 Claus FE<auml>rber.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::IDN::Nameprep>, L<Net::IDN::Punycode>, S<RFC 3490>
(L<http://www.ietf.org/rfc/rfc3490.txt>)

=cut
