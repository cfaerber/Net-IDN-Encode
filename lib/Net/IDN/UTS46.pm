package Net::IDN::UTS46;

require 5.008_001;

use strict;
use utf8;
use warnings;

use Carp;

our $VERSION = "1.900_20111218";
$VERSION = eval $VERSION;

our $IDNA_prefix = 'xn--';

use Unicode::Normalize 1 ();
use Net::IDN::Punycode 1 ();
use Net::IDN::UTS46::Mapping 5.002 ('/^(Map|Is).*/');				# UTS #46 is only defined from Unicode 5.2.0

sub to_unicode {
  my ($label, %param) = @_;
  no warnings 'utf8';

  $param{'TransitionalProcessing'} = 0;
  $label = process($label, %param);
  return $label;
}

sub to_ascii {
  my ($label, %param) = @_;
  no warnings 'utf8';

  my $pass_through = $label !~ m/[^\p{ASCII}\x2E\x{FF0E}\x{3002}\x{FF61}]/;

# 1. Apply appropriate processing
# 2. Break the result into labels at U+002E full stop;
#
  my @ll = process($label, %param);

# 3. Convert each label with non-ASCII characters into Punycode [RFC3492].
#
  foreach(@ll) {
    if(m/\P{ASCII}/) {
      eval { $_ = $IDNA_prefix . Net::IDN::Punycode::encode_punycode($_) };
      die "$@ [A3]" if $@;
      $pass_through = 0;
    }
  }

# 4. Verify DNS length restrictions.
#
  $label = join '.', @ll unless $pass_through;

  croak "label too long: '$1' [A4]" if $label =~ m/([^\.]{64,})/;
  croak "label empty: '$label' [A4]" if $label =~ m/\.\./;
  croak "domain name too long: '$label' [A4]" if $label =~ m/.{253}[^\.]/;
  croak "domain name empty: '$label' [A4]" if $label !~ m/[^\.]/ && !$pass_through && !$param{'TransitionalProcessing'};

  return $label;
}

sub process {
  my ($label, %param) = @_;
  no warnings 'utf8';

  $param{'TransitionalProcessing'} = 0	unless exists $param{'TransitionalProcessing'};
  $param{'UseSTD3ASCIIRules'} = 0	unless exists $param{'UseSTD3ASCIIRules'};
  $param{'AllowUnassigned'} = 0		unless exists $param{'AllowUnassigned'};

# 1. Map
#   - disallowed
#
  if($param{'AllowUnassigned'}) {
    $label =~ m/^(\P{IsDisallowed}}|\P{Assigned})*$/ and croak sprintf('disallowed character U+%04X', ord($1));
  } else {
    $label =~ m/(\p{IsDisallowed})/ and croak sprintf('disallowed character U+%04X', ord($1));
    $label =~ m/(\P{Assigned})/ and croak sprintf('unassigned character U+%04X (in this version of perl)', ord($1));
  }

  if($param{'UseSTD3ASCIIRules'}) {
    $label =~ m/(\p{IsDisallowedSTD3Valid})/ and croak sprintf('disallowed_STD3_valid character U+%04X', ord($1));
    $label =~ m/(\p{IsDisallowedSTD3Mapped})/ and croak sprintf('disallowed_STD3_mapped character U+%04X', ord($1));
  };

#   - ignored
#
  $label = MapIgnored($label);
  ## $label = MapDisallowedSTD3Ignored($label)	if(!$param{'UseSTD3ASCIIRules'});

#   - mapped
#
  $label = MapMapped($label);
  $label = MapDisallowedSTD3Mapped($label) 	if(!$param{'UseSTD3ASCIIRules'});

#  - deviation
  $label = MapDeviation($label)			if($param{'TransitionalProcessing'});

# 2. Normalize
#
  $label = Unicode::Normalize::NFC($label);

# 3. Break
#
  my @ll = split /\./, $label, -1;

# 4. Convert/Validate
#
  my $bidi = 0;

  foreach (@ll) {
    if(m/^$IDNA_prefix(\p{ASCII}+)$/oi) {
      $_ = Net::IDN::Punycode::decode_punycode($1);
      _validate_label($_,%param, 'TransitionalProcessing' => 0);
    } else {
      _validate_label($_,%param,'_AssumeNFC' => 1);
    }
    $bidi++ if !$bidi && m/[\p{Bc:R}\p{Bc:AL}\p{Bc:AN}]/;
  }

  if($bidi) {
    foreach(@ll) {
      _validate_bidi($_,%param);
    }
  }

  foreach(@ll) {
    _validate_contextj($_,%param);
  }

# Done: Join and return
#
  return wantarray ? (@ll) : join('.', @ll);
}

sub _validate_label {
  my($l,%param) = @_;
  no warnings 'utf8';

  $l eq Unicode::Normalize::NFC($l)	or croak "not in Unicode Normalization Form NFC [V1]" unless $param{'_AssumeNFC'};

  $l =~ m/^..--/			and croak "contains U+002D HYPHEN-MINUS in both third and forth position [V2]";
  $l =~ m/^-/				and croak "begins with U+002D HYPHEN-MINUS [V3]";
  $l =~ m/-$/				and croak "ends with U+002D HYPHEN-MINUS [V3]";
  $l =~ m/\./				and croak "contains U+0023 FULL STOP [V4]";
  $l =~ m/^\p{IsMark}/			and croak "begins with General_Category=Mark [V5]";

  if($param{'AllowUnassigned'}) {
    if($param{'TransitionalProcessing'}) {
      $l =~ m/[^\p{IsValid}\P{Assigned}]/			and croak "contains character that is not valid [V6]";
    } else {
      $l =~ m/[^\p{IsValid}\p{IsDeviation}\P{Assigned}]/	and croak "contains charachter that is not either valid or deviation [V6]";
    }
  } else {
    if($param{'TransitionalProcessing'}) {
      $l =~ m/[^\p{IsValid}]/					and croak "contains character that is not valid [V6]";
    } else {
      $l =~ m/[^\p{IsValid}\p{IsDeviation}]/			and croak "contains charachter that is not either valid or deviation [V6]";
    }
  }

  return 1;
}

sub _validate_bidi {
  my($l,%param) = @_;
  no warnings 'utf8';
  return 1 unless length($l);

  $l =~ m/^(?:(\p{Bc:L})|\p{Bc:R}|\p{Bc:AL})/ or die 'starts with character of wrong bidi class [B1]';

  if(!defined $1) { # RTL
    $l =~ m/[^\p{Bc:R}\p{Bc:AL}\p{Bc:AN}\p{Bc:EN}\p{Bc:ES}\p{Bc:CS}\p{Bc:ET}\p{Bc:ON}\p{Bc:BN}\p{Bc:NSM}]/ and croak 'contains characters with wrong bidi class for RTL [B2]';
    $l =~ m/[\p{Bc:R}\p{Bc:AL}\p{Bc:EN}\p{Bc:AN}][\p{Bc:NSM}\P{Assigned}]*$/ or croak 'ends with character of wrong bidi class for RTL [B3]';
    $l =~ m/\p{Bc:EN}.*\p{Bc:AN}|\p{Bc:AN}.*\p{Bc:EN}/ and croak 'contains characters with both bidi class EN and AN [B4]';
  } else { # LTR
    $l =~ m/[^\p{Bc:L}\p{Bc:EN}\p{Bc:ES}\p{Bc:CS}\p{Bc:ET}\p{Bc:ON}\p{Bc:BN}\p{Bc:NSM}]/ and croak 'contains characters with wrong bidi class for LTR [B5]';
    $l =~ m/[\p{Bc:L}\p{Bc:EN}][\p{Bc:NSM}\P{Assigned}]*$/ or croak 'ends with character of wrong bidi class for LTR [B6]';
  }
  return 1;
}

sub _validate_contextj {
  my($l,%param) = @_;
  no warnings 'utf8';
  return 1 unless defined($l) && length($l);

# catch ContextJ characters without defined rule (currently none)
#
  $l =~ m/([^\x{200C}\x{200D}\P{Join_Control}])/ and croak sprintf "contains CONTEXTJ character U+%04X without defined rule [C1]", ord($1);

# RFC 5892, Appendix A.1. ZERO WIDTH NON-JOINER
#    Code point:
#       U+200C
# 
#    Overview:
#       This may occur in a formally cursive script (such as Arabic) in a
#       context where it breaks a cursive connection as required for
#       orthographic rules, as in the Persian language, for example.  It
#       also may occur in Indic scripts in a consonant-conjunct context
#       (immediately following a virama), to control required display of
#       such conjuncts.
# 
# 
#    Lookup:
#       True
#
#    Rule Set:
#       False;
#       If Canonical_Combining_Class(Before(cp)) .eq.  Virama Then True;
#       If RegExpMatch((Joining_Type:{L,D})(Joining_Type:T)*\u200C
#          (Joining_Type:T)*(Joining_Type:{R,D})) Then True;

  $l =~ m/
	\p{Ccc:Virama}
	\x{200C}
     |
	[\p{JoiningType:L}\p{JoiningType:D}]\p{JoiningType:T}*
	\x{200C}
	\p{JoiningType:T}*[\p{JoiningType:R}\p{JoiningType:D}]
     |
	(\x{200C})
    /x and defined($1) and croak sprintf "rule for CONTEXTJ character U+%04X not satisfied [C2]", ord($1);

# RFC 5892, Appendix A.2. ZERO WIDTH JOINER
#
#    Code point:
#       U+200D
# 
#    Overview:
#       This may occur in Indic scripts in a consonant-conjunct context
#       (immediately following a virama), to control required display of
#       such conjuncts.
# 
#    Lookup:
#       True

#    Rule Set:
#       False;
#       If Canonical_Combining_Class(Before(cp)) .eq.  Virama Then True;

#  $l =~ m/(?:^|\P{Ccc:Virama})(\x{200D})/ and croak sprintf "rule for CONTEXTJ character U+%04X not satisfied [C2]", ord($1);
  $l =~ m/
	\p{Ccc:Virama}
	\x{200D}
     |
	(\x{200D})
    /x and defined($1) and croak sprintf "rule for CONTEXTJ character U+%04X not satisfied [C2]", ord($1);
}
