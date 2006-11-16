package Net::IDN::Nameprep;

use strict;
require v5.6.0;
our $VERSION = '0.02';
our @ISA    = qw(Exporter);
our @EXPORT = qw(nameprep);

use Net::IDN::Nameprep::Mapping;
use Net::IDN::Nameprep::Prohibited;

use Unicode::Normalize;

sub mapping {
    my $input = shift;
    my $mapped;
    for my $i (0..length($input)-1) {
	my $char = substr($input, $i, 1);
	$mapped .= join '', map chr, Net::IDN::Nameprep::Mapping->mapping(ord($char));
    }
    return $mapped;
}

sub check_prohibited {
    my $input = shift;
    for my $i (0..length($input)-1) {
	my $char = substr($input, $i, 1);
	if (Net::IDN::Nameprep::Prohibited->prohibited(ord($char))) {
	    require Carp;
	    Carp::croak("String contains prohibited character: U+". sprintf '%04x', ord $char);
	}
    }
}

sub nameprep {
    my $input = shift;
    my $output = NFKC mapping $input;
    check_prohibited $output;
    return $output;
}

1;
__END__

=head1 NAME

Net::IDN::Nameprep - IDN nameprep tools

=head1 SYNOPSIS

  use Net::IDN::Nameprep;
  $output = nameprep $input;

=head1 DESCRIPTION

B<THIS IS ALPHA SOFTWARE. NEEDS MORE TESTING!>

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

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Unicode::Normalize>, L<Convert::RACE>, L<Convert::DUDE>, http://www.i-d-n.net/draft/draft-ietf-idn-nameprep-03.txt

=cut
