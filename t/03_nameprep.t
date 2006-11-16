use strict;
use Test::More 'no_plan';

use Unicode::String;
use Net::IDN::Nameprep;

my(@from, @to);

push @from, [ qw(012d 0111 014b) ]; push @to, [ qw(012d 0111 014b) ];

for my $i (0..$#from) {
    my $in  = join '', map { chr hex $_ } @{$from[$i]};
    my $out = join '', map { chr hex $_ } @{$to[$i]};
    is nameprep($in), $out, "$in -> $out";
}
