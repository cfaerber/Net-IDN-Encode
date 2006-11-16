use strict;
use Test::More 'no_plan';

use Encode::Punycode;
use Encode;

my @input = read_sample('t/sample.txt');
for (@input) {
    my($utf8, $punycode) = @$_;
    is encode('Punycode', $utf8), $punycode;
    is decode('Punycode', $punycode), $utf8;
}

sub read_sample {
    open my $fh, shift;
    local $/ = '';
    my @input;
    while (my $block = <$fh>) {
        next if $block !~ /Punycode:/;
        my @unicode = $block =~ /u\+([0-9a-f]{4})/gi;
        my $punycode = ($block =~ /Punycode: (.+?)\n$/s)[0];
        push @input, [ join('', map chr(hex($_)), @unicode), $punycode ];
    }
    return @input;
}


