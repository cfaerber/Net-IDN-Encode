# $Id$

package Unicode::Stringprep;

use strict;
use utf8;
require 5.006_000;

our $VERSION = '0.99_20070912';
$VERSION = eval $VERSION;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(stringprep);

use Carp;

use Unicode::Normalize;
use Unicode::Stringprep::BiDi;

sub _compile {
  my $unicode_version = shift;
  my $mapping_tables = shift;
  my $unicode_normalization = uc shift;
  my $prohibited_tables = shift;
  my $bidi_check = shift;

  croak 'Unsupported UNICODE version '.$unicode_version.'.' 
    unless $unicode_version == 3.2;

  $unicode_normalization =~ s/^NF//;
  croak 'Unsupported UNICODE normalization (NF)'.$unicode_normalization.'.' 
    unless $unicode_normalization eq '' ||
           $unicode_normalization eq 'KC';

  sub _mapping_tables {
    my $map = shift;
    while(@_) {
      my $data = shift;
      if(ref($data) eq 'HASH') { %{$map} = (%{$map},%{$data}) }
      elsif(ref($data) eq 'ARRAY') { _mapping_tables($map,@{$data}) }
      else{ $map->{$data} = shift };
    }
  }

  my %map = ();
  _mapping_tables(\%map,$mapping_tables);

  my $mapping="";

  sub _mapping_compile {
    my $map = shift;
    if($#_ <= 8) {
      return 'if('.
        join('}elsif(',
	  map {
	    my $replace = $map->{$_};
	    $replace =~ s/(.)/sprintf('\x{%04X}',ord($1))/ge;
	    '$d=='.$_.'){$e="'.$replace.'";'
	  } @_ ).
	'}else{next MAPPING;}'; 
    } else {
      my @a = splice @_, 0, int($#_/2);
      return 'if($d<'.$_[0].'){'.
        _mapping_compile($map,@a).
	'}else{'.
        _mapping_compile($map,@_).
	'};';
    }
  }

  if(%map) {
    $mapping = 'MAPPING: for(my $pos=length($string);$pos>=0;$pos--) {'.
      'my $d=ord(substr($string,$pos,1)); my $e=undef;'.
      _mapping_compile(\%map,sort { $a <=> $b } keys %map).
      'substr($string,$pos,1) = $e'.
      '}';
  }

  print STDERR "---\n$mapping\n---";

  my $subroutine = sub {
    my $string = shift;
    if($mapping) {
      eval $mapping;
    };

    return $string;
  };

  return $subroutine;
}

sub new {
  my $self  = shift;
  my $class = ref($self) || $self;
  return bless _compile(@_), $class;
}

1;
__END__

=head1 NAME

Unicode::Stringprep - IDN nameprep tools

=head1 SYNOPSIS

  use Unicode::Stringprep;

  my $prepper = Unicode::Stringprep->new();
  $output =  $prepper->($input)

=head1 DESCRIPTION

Blah blah.

=head1 FUNCTIONS

=over 4

=item new

=back

=head1 BUGS

There may be plenty of Bugs. Please lemme know if you find any.

=head1 AUTHOR

Claus Färber <CFAERBER@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Unicode::Normalize>, http://www.ietf.org/rfc/rfc3492.txt

=cut
