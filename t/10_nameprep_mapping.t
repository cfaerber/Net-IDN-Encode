use strict;
use Test::More tests => 3;

use Unicode::String;
use Net::IDN::Nameprep::Mapping;

my(@from, @to);

push @from, '0041'; push @to, [ '0061' ];
push @from, '00ad'; push @to, [ ];
push @from, '00df'; push @to, [ '0073', '0073' ];

for my $i (0..$#from) {
    my $code = hex $from[$i];
    my @mapped = Net::IDN::Nameprep::Mapping->mapping($code);
    my @output = map { hex } @{$to[$i]};
    ok eq_array(\@mapped, \@output);
}
