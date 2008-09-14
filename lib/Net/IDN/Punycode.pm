# $Id$

package Net::IDN::Punycode;

use strict;
use utf8;
use warnings;
require 5.006_000;

our $VERSION = '0.99_20071012';
$VERSION = eval $VERSION;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(encode_punycode decode_punycode);

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
my $BasicRE   = qr/[\x00-\x7f]/;

sub _croak { require Carp; Carp::croak(@_); }

sub _digit_value {
    my $code = shift;
    return ord($code) - ord("A") if $code =~ /[A-Z]/;
    return ord($code) - ord("a") if $code =~ /[a-z]/;
    return ord($code) - ord("0") + 26 if $code =~ /[0-9]/;
    return;
}

sub _code_point {
    my $digit = shift;
    return $digit + ord('a') if 0 <= $digit && $digit <= 25;
    return $digit + ord('0') - 26 if 26 <= $digit && $digit <= 36;
    die 'NOT COME HERE';
}

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
    my $code = shift;

    my $n      = INITIAL_N;
    my $i      = 0;
    my $bias   = INITIAL_BIAS;
    my @output;

    if ($code =~ s/(.*)$Delimiter//o) {
	push @output, map ord, split //, $1;
	return _croak('non-basic code point') unless $1 =~ /^$BasicRE*$/o;
    }

    while ($code) {
	my $oldi = $i;
	my $w    = 1;
    LOOP:
	for (my $k = BASE; 1; $k += BASE) {
	    my $cp = substr($code, 0, 1, '');
	    my $digit = _digit_value($cp);
	    defined $digit or return _croak("invalid punycode input");
	    $i += $digit * $w;
	    my $t = ($k <= $bias) ? TMIN
		: ($k >= $bias + TMAX) ? TMAX : $k - $bias;
	    last LOOP if $digit < $t;
	    $w *= (BASE - $t);
	}
	$bias = _adapt($i - $oldi, @output + 1, $oldi == 0);
	warn "bias becomes $bias" if $DEBUG;
	$n += $i / (@output + 1);
	$i = $i % (@output + 1);
	splice(@output, $i, 0, $n);
	warn join " ", map sprintf('%04x', $_), @output if $DEBUG;
	$i++;
    }
    return join '', map chr, @output;
}

sub encode_punycode {
    my $input = shift;
    # my @input = split //, $input; # doesn't work in 5.6.x!
    my @input = map substr($input, $_, 1), 0..length($input)-1;

    my $n     = INITIAL_N;
    my $delta = 0;
    my $bias  = INITIAL_BIAS;

    my @output;
    my @basic = grep /$BasicRE/, @input;
    my $h = my $b = @basic;
    push @output, @basic, $Delimiter if $b > 0;
    warn "basic codepoints: (@output)" if $DEBUG;

    while ($h < @input) {
	my $m = _min(grep { $_ >= $n } map ord, @input);
	warn sprintf "next code point to insert is %04x", $m if $DEBUG;
	$delta += ($m - $n) * ($h + 1);
	$n = $m;
	for my $i (@input) {
	    my $c = ord($i);
	    $delta++ if $c < $n;
	    if ($c == $n) {
		my $q = $delta;
	    LOOP:
		for (my $k = BASE; 1; $k += BASE) {
		    my $t = ($k <= $bias) ? TMIN :
			($k >= $bias + TMAX) ? TMAX : $k - $bias;
		    last LOOP if $q < $t;
		    my $cp = _code_point($t + (($q - $t) % (BASE - $t)));
		    push @output, chr($cp);
		    $q = ($q - $t) / (BASE - $t);
		}
		push @output, chr(_code_point($q));
		$bias = _adapt($delta, $h + 1, $h == $b);
		warn "bias becomes $bias" if $DEBUG;
		$delta = 0;
		$h++;
	    }
	}
	$delta++;
	$n++;
    }
    return join '', @output;
}

sub _min {
    my $min = shift;
    for (@_) { $min = $_ if $_ <= $min }
    return $min;
}

1;
__END__

=encoding utf8

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

=head1 AUTHORS/LICENSE

Copyright © 2002-2004 Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>
Copyright © 2007-2008 Claus Färber E<lt>CFAERBER@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

S<RFC 3492> L<http://www.ietf.org/rfc/rfc3492.txt>,
L<IETF::ACE>, L<Convert::RACE>

=cut
