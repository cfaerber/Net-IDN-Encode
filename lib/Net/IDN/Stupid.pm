package Net::IDN::Stupid;

use strict;
use utf8;
use warnings;

our $VERSION = "1.009_20111231";
$VERSION = eval $VERSION;

use Carp;
use Exporter;

use Net::IDN::Punycode 1.009 ();

our @ISA = ('Exporter');
our @EXPORT = ();
our @EXPORT_OK = (
  'stupid_to_ascii',
  'stupid_to_unicode',
);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

sub stupid_to_ascii {
  my($label,%param) = @_;
  croak 'Invalid label' if $label =~ m/$Net::IDN::Punycode::IDNA_dot/oi 
	or $label =~ m/^$Net::IDN::Punycode::IDNA_prefix.*\P{ASCII}/oi;

  if($label =~ m/\P{ASCII}/) {
    $label = $Net::IDN::Punycode::IDNA_prefix.Net::IDN::Punycode::encode_punycode($label);
  }
  return $label;
}

sub stupid_to_unicode {
  my($label,%param) = @_;
  croak 'Invalid label' if $label =~ m/$Net::IDN::Punycode::IDNA_dot/oi;

  if($label =~ m/^$Net::IDN::Punycode::IDNA_prefix(.+)$/oi) {
    eval { $label = Net::IDN::Punycode::decode_punycode($1); }
  }
  return $label;
}

*to_ascii = \&stupid_to_ascii;
*to_unicode = \&stupid_to_unicode;

1;

__END__

=encoding utf8

=head1 NAME

Net::IDN::Stupid - Stupid implementation of Internationalized Domain Names (IDNA)

=head1 SYNOPSIS

  use Net::IDN::Stupid ':all';
  my $a = domain_to_ascii("müller.example.org");
  my $e = email_to_ascii("POSTMASTER@例。テスト");
  my $u = domain_to_unicode('EXAMPLE.XN--11B5BS3A9AJ6G');

=head1 DESCRIPTION

This module provides a high-level interface for converting domain
name labels, without any preparation.  Use this module only if you
know that your internationalized domain names are valid and in
cannonical format (or if you don't care).

Usually, it is not a good idea to leave out the prepration. You
might end up with a converted domain name that is not
interoperable or even poses security issues due to spoofing. The
name of the module reminds you of this issue.

On the plus side, this module has few dependencies, is fast, and
is even compatible with perl 5.6 (whereas the other modules
require perl 5.8 or 5.12).


For a more complete IDNA implementation, see L<Net::IDN::Encode>.

=head1 FUNCTIONS

By default, this module does not export any subroutines. You may
use the C<:all> tag to import everything.

You can omit the C<'stupid_'> prefix when accessing the functions
with a full-qualified module name (e.g. you can access
C<stupid_to_unicode> as C<Net::IDN::Stupid::stupid_to_unicode> or
C<Net::IDN::Stupid::to_unicode>. 

The following functions are available:

=over

=item stupid_to_ascii( $label )

Converts a single label C<$label> to ASCII. Will throw an exception on invalid
input. If C<$label> is already in ASCII, this function will never fail but
return C<$label> as is as a last resort.

=item stupid_to_unicode( $label )

Converts a single label C<$label> to Unicode.  Will throw an exception on
invalid input. If C<$label> is in ASCII, this function will never fail but
return C<$label> as is as a last resort.

If C<$label> is already in ASCII, this function will never fail but return
C<$label> as is as a last resort (i.e. pass-through).

=back

=head1 AUTHOR

Claus FE<auml>rber <CFAERBER@cpan.org>

=head1 LICENSE

Copyright 2007-2011 Claus FE<auml>rber.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::IDN::Punycode>, L<Net::IDN::Encode>

=cut
