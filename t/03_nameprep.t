use strict;
use Test::More 'no_plan';

use Net::IDN::Nameprep;

my(@from, @to);
push @from, [ qw(012d 0111 014b) ]; push @to, [ qw(012d 0111 014b) ];
push @from, [ qw(304b 3099 ff21) ]; push @to, [ qw(304c 0061) ];

for my $i (0..$#from) {
    my $in  = join '', map { chr hex $_ } @{$from[$i]};
    my $out = join '', map { chr hex $_ } @{$to[$i]};
    is nameprep($in), $out, "$in -> $out";
}

my @prohibited;
push @prohibited, [ qw(012d 0040) ];

for my $p (@prohibited) {
    my $in = join '', map { chr hex $_ } @{$p};
    eval { nameprep $in };
    ok $@, $@;
}

