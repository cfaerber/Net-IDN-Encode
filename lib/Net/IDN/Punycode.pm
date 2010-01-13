package Net::IDN::Punycode;

use 5.006;

use strict;
use utf8;
use warnings;

use Exporter;
our $VERSION = "1.000";

our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = qw(encode_punycode decode_punycode);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

eval { 
  require XSLoader;
  XSLoader::load('Net::IDN::Punycode'); 
};

if (!defined(&encode_punycode)) {
  require Net::IDN::Punycode::PP;
  Net::IDN::Punycode::PP->import(qw(:all));
}

1;
__END__

=head1 NAME

Net::IDN::Punycode - A Bootstring encoding of Unicode for IDNA (S<RFC 3492>)

=head1 SYNOPSIS

  use Net::IDN::Punycode qw(:all);
  $punycode = encode_punycode($unicode);
  $unicode  = decode_punycode($punycode);

=head1 DESCRIPTION

This module implements the Punycode encoding. Punycode is an
instance of a more general algorithm called Bootstring, which
allows strings composed from a small set of "basic" code points to
uniquely represent any string of code points drawn from a larger
set.  Punycode is Bootstring with particular parameter values
appropriate for IDNA.

Note that this module does not do any string preparation as
specified by I<nameprep>/I<stringprep>. It does not do add any
prefix or suffix, either.

=head1 FUNCTIONS

No functions are exported by default. You can use the tag C<:all>
or import them individually.

The following functions are available:

=over 4

=item encode_punycode($input)

Decodes C<$input> with Punycode and returns the result.

This function will throw an exception on invalid input.

=item decode_punycode($input)

Decodes C<$input> with Punycode and returns the result.

This function will throw an exception on invalid input.

=back

=head1 AUTHORS

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt> (versions 0.01 to 0.02)

Claus FE<auml>rber E<lt>CFAERBER@cpan.orgE<gt> (from version 1.00)

=head1 LICENSE

Copyright 2002-2004 Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

Copyright 2007-2010 Claus FE<auml>rber E<lt>CFAERBER@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

S<RFC 3492> (L<http://www.ietf.org/rfc/rfc3492.txt>),
L<IETF::ACE>, L<Convert::RACE>

=cut
