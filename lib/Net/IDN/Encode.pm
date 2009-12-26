package Net::IDN::Encode;

use strict;
use utf8;
use warnings;
require 5.006_000;

our $VERSION = '0.99_20091226';
$VERSION = eval $VERSION;

use Carp;
use Exporter;
use Net::IDN::Nameprep;
use Net::IDN::Punycode;

our @ISA = ('Exporter');
our @EXPORT = (
  'domain_to_ascii',
  'domain_to_unicode',
  'email_to_ascii',
  'email_to_unicode',
);

our $IDNA_prefix = 'xn--';

sub _to_ascii {
  use bytes;
  no warnings qw(utf8); # needed for perl v5.6.x

  my ($label,%param) = @_;

  if($label =~ m/[^\x00-\x7F]/) {
    $label = nameprep($label);
  }

  if($param{'UseSTD3ASCIIRules'}) {
    croak 'Invalid domain name (toASCII, step 3)' if 
      $label =~ m/^-/ ||
      $label =~ m/-$/ || 
      $label =~ m/[\x00-\x2C\x2E-\x2F\x3A-\x40\x5B-\x60\x7B-\x7F]/;
  }

  if($label =~ m/[^\x00-\x7F]/) {
    croak 'Invalid label (toASCII, step 5)' if $label =~ m/^$IDNA_prefix/;
    return $IDNA_prefix.encode_punycode($label);
  } else {
    return $label;
  }
}

sub _to_unicode {
  use bytes;

  my ($label,%param) = @_;
  my $orig = $label;

  return eval {
    if($label =~ m/[^\x00-\x7F]/) {
      $label = nameprep($label);
    }

    my $save3 = $label;
    die unless $label =~ s/^$IDNA_prefix//;

    $label = decode_punycode($label);
    
    my $save6 = _to_ascii($label,%param);

    die unless uc($save6) eq uc($save3);

    $label;
  } || $orig;
}

sub _domain {
  use utf8;
  my ($domain,$_to_function,@param) = @_;
  return undef unless $domain;
  return join '.',
    grep { croak 'Invalid domain name' if length($_) > 63 && !m/[^\x00-\x7F]/; 1 }
      map { $_to_function->($_, @param, 'UseSTD3ASCIIRules' => 1) }
        split /[\.。．｡]/, $domain;
}

sub _email {
  use utf8;
  my ($email,$_to_function,@param) = @_;
  return undef unless $email;

  $email =~ m/^([^"\@＠]+|"(?:(?:[^"]|\\.)*[^\\])?")(?:[\@＠]
    (?:([^\[\]]*)|(\[.*\]))?)?$/x || croak "Invalid email address";
  my($local_part,$domain,$domain_literal) = ($1,$2,$3);

  $local_part =~ m/[^\x00-\x7F]/ && croak "Invalid email address";
  $domain_literal =~ m/[^\x00-\x7F]/ && croak "Invalid email address" if $domain_literal;

  $domain = _domain($domain,$_to_function,@param) if $domain;

  return ($domain || $domain_literal)
    ? ($local_part.'@'.($domain || $domain_literal))
    : ($local_part);
}

sub domain_to_ascii { _domain(shift,\&_to_ascii) }
sub domain_to_unicode { _domain(shift,\&_to_unicode) }

sub email_to_ascii { _email(shift,\&_to_ascii) }
sub email_to_unicode { _email(shift,\&_to_unicode) }

1;

__END__

=head1 NAME

Net::IDN::Encode - Internationalizing Domain Names in Applications (S<RFC 3490>)

=head1 SYNOPSIS

  use Net::IDN::Encode;
  $ascii = domain_to_ascii("m\xFCller.example.org");
  $ascii = domain_to_ascii("\x{4f8b}.\x{30c6}\x{30b9}\x{30c8}");

=head1 DESCRIPTION

This module provides an easy-to-use interface for encoding and
decoding Internationalized Domain Names (IDNs).

IDNs use characters drawn from a large repertoire (Unicode), but
IDNA allows the non-ASCII characters to be represented using only
the ASCII characters already allowed in so-called host names today
(letter-digit-hypen, C</[A-Z0-9-]/i>).

=head1 FUNCTIONS

The following functions are exported by default.

=over

=item domain_to_ascii( $domain )

Converts all labels of the hostname C<$domain> (with labels
seperated by dots) to ASCII. Will throw an exception on invalid
input.

The following characters are recognized as dots: U+002E (full
stop), U+3002 (ideographic full stop), U+FF0E (fullwidth full
stop), U+FF61 (halfwidth ideographic full stop).

=item domain_to_unicode( $domain )

Converts all labels of the hostname C<$domain> (with labels
seperated by dots) to Unicode. Will throw an exception on invalid
input.

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

Copyright 2007-2009 Claus FE<auml>rber.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::IDN::Nameprep>, L<Net::IDN::Punycode>, S<RFC 3490>
(L<http://www.ietf.org/rfc/rfc3490.txt>)

=cut
