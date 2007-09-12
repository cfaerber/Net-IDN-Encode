package Net::IDN::Nameprep::Prohibited;

use strict;
require 5.006_000;
our $VERSION = '0.01';

my $table = <<'EOF';
0000-002C
002E-002F
003A-0040
005B-0060
007B-007F
0080-009F
00A0
1680
2000
2001
2002
2003
2004
2005
2006
2007
2008
2009
200A
200B
200E
200F
2028
2029
202A
202B
202C
202D
202E
202F
206A
206B
206C
206D
206E
206F
2FF0-2FFF
3000
3002
D800-DFFF
E000-F8FF
FFF9
FFFA
FFFB
FFFC
FFFD
FFFE-FFFF
1FFFE-1FFFF
2FFFE-2FFFF
3FFFE-3FFFF
4FFFE-4FFFF
5FFFE-5FFFF
6FFFE-6FFFF
7FFFE-7FFFF
8FFFE-8FFFF
9FFFE-9FFFF
AFFFE-AFFFF
BFFFE-BFFFF
CFFFE-CFFFF
DFFFE-DFFFF
EFFFE-EFFFF
F0000-FFFFD
FFFFE-FFFFF
100000-10FFFD
10FFFE-10FFFF
EOF
    ;

my @prohibited;
while ($table =~ m/^(.*)$/gm) {
    # XXX inefficient
    my($from, $to) = split /-/, $1;
    if (defined $to) {
	$prohibited[$_] = 1 for hex($from) .. hex($to);
    } else {
	$prohibited[hex $from] = 1;
    }
}

sub prohibited {
    my($class, $code) = @_;
    return exists $prohibited[$code];
}

1;

__END__

=head1 NAME

Net::IDN::Nameprep::Prohibited - Nameprep prohibited table

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::IDN::Mapping>

=cut
