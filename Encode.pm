package Net::IDN::Encode;

use strict;
require v5.6.0;

our $VERSION = '0.02';
$VERSION = eval $VERSION;

use Carp;
use Exporter;
use Net::IDN::Nameprep;
use IDNA::Punycode;

our @ISA = ('Exporter');
our @EXPORT = (
  'domain_to_ascii',
  'domain_to_unicode',
  'email_to_ascii',
  'email_to_unicode',
);

=head1 NAME

Net::IDN::Encode - Encoding/Decoding of Internationalized Domain Names (IDNs).

=head1 SYNOPSIS

  use Net::IDN::Encode;
  $ascii = domain_to_ascii('müller.example.org');

=head1 DESCRIPTION

The "Net::IDN::Encode" module provides an easy-to-use interface
for Internationalized Domain Names (IDNs).

=cut

our $IDNA_prefix = 'xn--';

sub _to_ascii {
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
    (?:([^\[\]]*)|(\[.*\]))?)?$/x || die "Invalid email address";
  my($local_part,$domain,$domain_literal) = ($1,$2,$3);

  $local_part =~ m/[^\x00-\x7F]/ && die "Invalid email address";
  $domain_literal =~ m/[^\x00-\x7F]/ && die "Invalid email address" if $domain_literal;

  $domain = _domain($domain,$_to_function,@param) if $domain;

  return ($domain || $domain_literal)
    ? ($local_part.'@'.($domain || $domain_literal))
    : ($local_part);
}

=head1 FUNCTIONS

=head2 domain_to_ascii( $domain )

Converts all labels of the hostname C<$domain> (with labels
seperated by full stops) to ASCII. May throw an exception on
invalid input.

=head2 domain_to_unicode( $domain )

Converts all labels of the hostname C<$domain> (with labels
seperated by full stops) to Unicode. May throw an exception on
invalid input.

=head2 email_to_ascii( $email )

Converts the domain part (right hand side) of the RFC 2821/2822
email address to ASCII. May throw an exception on invalid input.

This function currently does not handle internationalization of
the local-part (left hand side).

=head2 email_to_unicode( $email )

Converts the domain part (right hand side) of the RFC 2821/2822
email address to Unicode. May throw an exception on invalid input.

This function currently does not handle internationalization of
the local-part (left hand side).

=cut

sub domain_to_ascii { _domain(shift,\&_to_ascii) }
sub domain_to_unicode { _domain(shift,\&_to_unicode) }

sub email_to_ascii { _email(shift,\&_to_ascii) }
sub email_to_unicode { _email(shift,\&_to_unicode) }

=head1 BUGS

This module relies on modules that should be considered ALPHA.

=head1 AUTHOR

Claus A. Färber <perl@faerber.muc.de>

=head1 COPYRIGHT

Copyright © 2004 Claus A. Färber All rights reserved. This program
is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
