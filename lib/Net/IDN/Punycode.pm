package Net::IDN::Punycode;

use 5.8.3;

use strict;
use utf8;
use warnings;

require DynaLoader;
require Exporter;

use Carp;

our $VERSION = "1.00";

our @ISA    = qw(Exporter DynaLoader);
our @EXPORT = qw(encode_punycode decode_punycode);

bootstrap Net::IDN::Punycode;

use integer;

our $DEBUG = 0;

use constant BASE => 36;
use constant TMIN => 1;
use constant TMAX => 26;
use constant SKEW => 38;
use constant DAMP => 700;
use constant INITIAL_BIAS => 72;
use constant INITIAL_N => 128;

my $Delimiter = chr 0x2D;
my $BasicRE   = "\x00-\x7f";
my $PunyRE    = "A-Za-z0-9";

sub _adapt {
    my($delta, $numpoints, $firsttime) = @_;
    $delta = $firsttime ? $delta / DAMP : $delta / 2;
    $delta += $delta / $numpoints;
    my $k = 0;
    while ($delta > ((BASE - TMIN) * TMAX) / 2) {
	$delta /= BASE - TMIN;
	$k += BASE;
    }
    return $k + (((BASE - TMIN + 1) * $delta) / ($delta + SKEW));
}

sub decode_punycode {
    my $input = shift;

    my $n      = INITIAL_N;
    my $i      = 0;
    my $bias   = INITIAL_BIAS;
    my @output;

    return undef unless defined $input;
    return '' unless length $input;

    if($input =~ s/(.*)$Delimiter//os) {
      my $base_chars = $1;
      die 'non-basic characters in input' 
        if $base_chars =~ m/[^$BasicRE]/os;
      push @output, split //, $base_chars;
    }
    my $code = $input;

    croak('invalid punycode code point') if $code =~ m/[^$PunyRE]/os;

    utf8::downgrade($input);	## handling failure of downgrade is more expensive than
				## doing the above regexp w/ utf8 semantics

    while(length $code)
    {
	my $oldi = $i;
	my $w    = 1;
    LOOP:
	for (my $k = BASE; 1; $k += BASE) {
	    my $cp = substr($code, 0, 1, '');
	    my $digit = ord $cp;
		
	    ## NB: this depends on the PunyRE catching invalid digit characters
	    ## before they turn up here
	    ##
	    $digit = $digit < 0x40 ? $digit + (26-0x30) : ($digit & 0x1f) -1;

	    $i += $digit * $w;
	    my $t =  $k - $bias;
	    $t = $t < TMIN ? TMIN : $t > TMAX ? TMAX : $t;

	    last LOOP if $digit < $t;
	    $w *= (BASE - $t);
	}
	$bias = _adapt($i - $oldi, @output + 1, $oldi == 0);
	warn "bias becomes $bias" if $DEBUG;
	$n += $i / (@output + 1);
	$i = $i % (@output + 1);
	splice(@output, $i, 0, chr($n));
	warn join " ", map sprintf('%04x', $_), @output if $DEBUG;
	$i++;
    }
    return join '', @output;
}

sub _noxs_encode_punycode {
    my $input = shift;
    my $input_length = length $input;

    ## my $output = join '', $input =~ m/([$BasicRE]+)/og; ## slower
    my $output = $input; $output =~ s/[^$BasicRE]+//ogs;

    my $h = my $b = length $output;
    $output .= $Delimiter if $b > 0;
    warn "basic codepoints: ($output)" if $DEBUG;
    utf8::downgrade($output);	## no unnecessary use of utf8 semantics

    my @input = map ord, split //, $input;
    my @chars = sort grep { $_ >= INITIAL_N } @input;

    my $n = INITIAL_N;
    my $delta = 0;
    my $bias = INITIAL_BIAS;

    foreach my $m (@chars) {
 	next if $m < $n;
	#local $DEBUG = 1;
	warn sprintf "next code point to insert is %04x", $m if $DEBUG;

	$delta += ($m - $n) * ($h + 1);
	$n = $m;
	for(my $i = 0; $i < $input_length; $i++)
	{
	    my $c = $input[$i];
	    $delta++ if $c < $n;
	    if ($c == $n) {
		my $q = $delta;
	    LOOP:
		for (my $k = BASE; 1; $k += BASE) {
		    my $t = $k - $bias;
	            $t = $t < TMIN ? TMIN : $t > TMAX ? TMAX : $t;

		    last LOOP if $q < $t;

                    my $o = $t + (($q - $t) % (BASE - $t));
                    $output .= chr $o + ($o < 26 ? 0x61 : 0x30-26);

		    $q = ($q - $t) / (BASE - $t);
		}
		die "input exceeds punycode limit" if $q > BASE;
                $output .= chr $q + ($q < 26 ? 0x61 : 0x30-26);

		$bias = _adapt($delta, $h + 1, $h == $b);
		warn "bias becomes $bias" if $DEBUG;
		$delta = 0;
		$h++;
	    }
	}
	$delta++;
	$n++;
    }
    return $output;
}

1;
__END__

=head1 NAME

Net::IDN::Punycode - A Bootstring encoding of Unicode for IDNA (S<RFC 3492>)

=head1 SYNOPSIS

  use Net::IDN::Punycode;
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

The following functions are exported by default.

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

Copyright 2007-2009 Claus FE<auml>rber E<lt>CFAERBER@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

S<RFC 3492> (L<http://www.ietf.org/rfc/rfc3492.txt>),
L<IETF::ACE>, L<Convert::RACE>

=cut
