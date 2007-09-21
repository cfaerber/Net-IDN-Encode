# $Id$

package Net::IDN::Nameprep;

use strict;
use utf8;
require 5.006_000;

our $VERSION = '0.99_20070912';
$VERSION = eval $VERSION;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(nameprep);

use Net::IDN::Stringprep;

use Net::IDN::Stringprep::Prohibited;
use Net::IDN::Stringprep::Mapping;

*nameprep = Net::IDN::Stringprep->new(
  3.2,
  [ 
    @Net::IDN::Stringprep::Mapping::B1, 
    @Net::IDN::Stringprep::Mapping::B2 
  ],
  'KC',
  [
    @Net::IDN::Stringprep::Prohibited::C12,
    @Net::IDN::Stringprep::Prohibited::C22,
    @Net::IDN::Stringprep::Prohibited::C3,
    @Net::IDN::Stringprep::Prohibited::C4,
    @Net::IDN::Stringprep::Prohibited::C5,
    @Net::IDN::Stringprep::Prohibited::C6,
    @Net::IDN::Stringprep::Prohibited::C7,
    @Net::IDN::Stringprep::Prohibited::C8,
    @Net::IDN::Stringprep::Prohibited::C9
  ],
  1,
);

1;
__END__

=head1 NAME

Net::IDN::Nameprep - IDN nameprep tools

=head1 SYNOPSIS

  use Net::IDN::Nameprep;
  $output = nameprep $input;

=head1 DESCRIPTION

Net::IDN::Nameprep implements IDN nameprep specification. This module
exports only one function called C<nameprep>.

There comes C<NO WARRANTY> with this module.

=head1 FUNCTIONS

=over 4

=item nameprep

  $prepared = nameprep $utf8;

accepts UTF8 encoded string, and returns nameprep-ed UTF8 encoded
string. It might throw an exception in case of error ("String %s
contains prohibited character: %s").

=back

=head1 BUGS

There may be plenty of Bugs. Please lemme know if you find any.

=head1 AUTHOR

Claus Färber <perl@cfaerber.name>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Unicode::Normalize>, http://www.ietf.org/rfc/rfc3492.txt

=cut
