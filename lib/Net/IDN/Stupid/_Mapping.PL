#!perl

use strict;
use utf8;

open UnicodeData, '<', "data/UnicodeData.txt" or
  die "Cannot open data/UnicodeData.txt: $!";

my %width;
my %ccc;
my %nfc;
my %lc;

while(<UnicodeData>) {
  chomp;
  my($cp,$name,$ccc,$map,$simple_lc) = (split /\s*;\s*/)[0,1,3,5,13)];
  $cp = hex $cp;

  if($ccc) {
    $ccc{$cp} = int($ccc);
  }

  if($map =~ m/^<(?:wide|narrow)>\s*(.*)/i) {
    $width{$cp} = h2a($1);
  }

  if($map =~ m/^[[:xdigit:]]/) {
    $nfc{$cp} = h2a($map);
  }

  if($simple_lc) {
    $lc{$cp} = h2a($simple_lc)
  }
}

open SpecialCasing, '<', "data/SpecialCasing.txt" or
  die "Cannot open data/SpecialCasing.txt";
my %np;

while(<SpecialCasing>) {
  chomp;
  s/\s*#.*//; next unless m/\S/;
  my($cp,$uc,$lc,$ucfirst) = split /\s*;\s*/;
  my($from,$to) = map { hex } split /\.+/, $cp;
  $lc{$_} = $lc foreach($to ? ($from..$to+1) : ($from,));
}

open DNormalizationProps, '<', "data/DerivedNormalizationProps.txt" or
  die "Cannot open data/DerivedNormalizationProps.txt";
my %np;

while(<DNormalizationProps>) {
  chomp;
  s/\s*#.*//; next unless m/\S/;
  my($cp,$d,$v) = split /\s*;\s*/;
  my($from,$to) = map { hex } split /\.+/, $cp;
  $np{lc $d}{$_} = $v foreach($to ? ($from..$to+1) : ($from,));
}

my $fn = $0; $fn =~ s/(\.PL)?$/.pm/;
print STDERR "generating $fn.\n" if -t STDERR;
open STDOUT, ">", $fn or die "Cannot open '$fn': $!";

binmode STDOUT, ':utf8';
while(<DATA>) { last if m/^__BREAK__$/; print; }


print "\nsub MapWidth {\n";
print "  my \$s = shift;\n";
print "  \$s =~ tr/", join('/',h2q(%width)), "/;\n";
print "  return \$s;\n";
print "}\n";

print "\nsub lcNFC {\n";
print "  use utf8;\n";
print "  my \$s = shift;\n";
print "  utf8::upgrade(\$s); \$s = lc \$s;\n";
print "  \$s =~ s/(.?[",a2q(keys(%{$np{'nfc_qc'}}),
  keys(%{$np{'full_composition_exclusion'}}),
  keys(%ccc)),"]+)/ _nfc(\$1) /ge;\n";
print "  return \$s;\n";
print "}\n";

my %com;
foreach( grep {!exists $np{'full_composition_exclusion'}->{$_}} 
    grep { scalar(@{$nfc{$_}}) == 2 }
    keys %nfc) {
  my($l,$c) = @{$nfc{$_}};
  $com{$c}->{$l} = $_;
}

print "my \%_com = (";
foreach my $l (sort {$a<=>$b} keys %com) {
  printf "0x%02X", $l;
  print  "=>{";
  foreach my $c (sort {$a<=>$b} keys %{$com{$l}}) {
    printf "0x%02X=>0x%02X,", $c, $com{$l}->{$c};
  }
  print  "},";
}
print ");\n";


foreach(values %nfc) {
 for(my $c=0; $c<=$#{$_}; $c++) {
   if(exists $nfc{$_->[$c]}) {
     splice @{$_}, $c, 1, @{$nfc{$_->[$c]}};
     redo; 	## recursively decompose!
   }
 }
}

print "my \%_dec = ( ";
print join ", ",
  map { sprintf "0x%02X=>[%s]", $_,
    join ',', map { sprintf "0x%02X", $_ } @{$nfc{$_}}
  } sort {$a<=>$b} keys %nfc;
print ");\n";

print "my \%_ccc = (";
print join ",", map { sprintf "0x%02X => %d", $_, $ccc{$_} } sort {$a<=>$b} keys %ccc;
print ");\n";


while(<DATA>) { print; }
exit(0);

sub _ {
  my $cp = shift;
  my $c = chr $cp;

#  return $c				if ($cp < 0x80 && $c !~ m/[^[:alnum:]]/) or ($cp >= 0x80 and !$ccc{$cp});
  return sprintf '\x%02X', $cp 		if $cp < 0x80;
  return sprintf '\x{%X}', $cp;
}

sub h2a { # hex to array(ref)
  return [ map { hex $_ } split /\s+/, shift ];
}

sub a2q { # array/list of codepoints to quoted string
  my %data = map { ($_ => 1) } @_;
  my @data = map { [$_,$_] } sort { $a <=> $b } keys %data;

  for(my $d = $#data; $d>0; $d--) {
    splice @data, $d-1, 2, 
        [$data[$d-1]->[0], $data[$d]->[1]]
      if $data[$d-1]->[1]+1 == $data[$d]->[0];
  }

  my $o = '';
  foreach(@data) {
    $o .= _($_->[0]);
    if($_->[0] != $_->[1]) {
      if($_->[0] + 1 < $_->[1]) {
        $o .= '-';
      }
      $o .= _($_->[1]);
    }
  }
  return $o;
}

sub h2q { # hash to quoted string(s)
  my %map = @_;
  foreach(keys %map) {
    die sprintf 'U+04X does not map to a single code point', $_
     if scalar(@{$map{$_}}) != 1;
  }

  my @data = map { [$_, $_, $map{$_}->[0], $map{$_}->[0]] }
    sort { $a <=> $b } keys %map;

  for(my $d = $#data; $d>0; $d--) {
    splice @data, $d-1, 2, 
        [$data[$d-1]->[0], $data[$d]->[1],
         $data[$d-1]->[2], $data[$d]->[3] ]
      if ($data[$d-1]->[1]+1 == $data[$d]->[0])
       &&($data[$d-1]->[3]+1 == $data[$d]->[2])
  }
  
  my $tr1 = '';
  my $tr2 = '';
  
  foreach(@data) {
    $tr1 .= _($_->[0]);
    $tr2 .= _($_->[2]);
    if($_->[0] != $_->[1]) {
      if($_->[0] + 1 < $_->[1]) {
        $tr1 .= '-';
        $tr2 .= '-';
      }
      $tr1 .= _($_->[1]);
      $tr2 .= _($_->[3]);
    }
  }

  return ($tr1,$tr2);
}

__DATA__
package Net::IDN::Stupid::_Mapping;

use utf8;
use strict;

use Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = ('lcNFC', 'MapWidth');
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

__BREAK__

my $SBase = 0xAC00;
my $LBase = 0x1100;
my $VBase = 0x1161;
my $TBase = 0x11A7;

my $LCount = 19;
my $VCount = 21;
my $TCount = 28;

my $NCount = $VCount * $TCount;
my $SCount = $LCount * $NCount;

sub _dec_hangul {
  my $si = (shift) - $SBase;

  my $l = int( $si / $NCount);
  my $v = int(($si % $NCount) / $TCount);
  my $t =      $si % $TCount;

  return ($LBase + $l, $VBase + $v, ($t ? $TBase + $t : ()));
}

sub _nfc {
  my @cp = map { ord } split //, shift;

  ## decompose
  @cp = map { exists($_dec{$_}) ? @{$_dec{$_}} : 
   ($_ >= $SBase and $_ < $SBase+$SCount) ? _dec_hangul($_) : $_ } @cp;

  ## reorder
  for(my $c=0; $c<=$#cp-1; $c++) {
    next if !$_ccc{$cp[$c]};
    my $l = $c; while($l<$#cp and $_ccc{$cp[$l+1]}) {$l++};
    if($l > $c) {
      splice @cp, $c, $l-$c+1,
	sort { $_ccc{$a} <=> $_ccc{$b} }
          @cp[$c..$l];
      $c = $l;
    }
  }

  ## compose 
  C: for(my $c=1; $c<=$#cp; $c++) {

    ## NB: As Hangul L,V,LV,T have Ccc:0, we only have to look at the previous character
    ##     furthermore, Hangul sequences are never blocked
    if($cp[$c] >= $VBase and $cp[$c] < $VBase+$VCount
        and $cp[$c-1] >= $LBase and $cp[$c-1] < $LBase+$LCount) {	# found Hangul L+V
      splice @cp, $c-1, 2, ($cp[$c-1]-$LBase) * $NCount + ($cp[$c]-$VBase) * $TCount + $SBase;
      $c--; next;
    }

    if($cp[$c] >= $TBase and $cp[$c] < $TBase+$TCount
        and $cp[$c-1] >= $SBase and $cp[$c-1] < $SBase+$SCount
        and !(($cp[$c-1]-$SBase) % $TCount)) {			# found Hangul LV+T
      splice @cp, $c-1, 2, $cp[$c-1] + $cp[$c]-$TBase;
      $c--; next;
    }

    next unless $_com{$cp[$c]};					# no other combination defined
    next if $_ccc{$cp[$c-1]} and $_ccc{$cp[$c-1]} >= ($_ccc{$cp[$c]} || -1); # blocked

    for(my $l=$c-1; $l>=0; $l--) {
      if(!$_ccc{$cp[$l]} and $_com{$cp[$c]}->{$cp[$l]}) {	# found starter with composition
        $cp[$l] = $_com{$cp[$c]}->{$cp[$l]};
        splice @cp, $c, 1; 
	$c--; next;
      }
    }
  };

  return join '', map { chr } @cp;
}

1;

__END__
