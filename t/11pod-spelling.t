use strict;
use utf8;
use Test::Spelling;

add_stopwords(map { split /\s+/ } <DATA>);
all_pod_files_spelling_ok();

__END__
Punycode
Bootstring
IDNA
Nameprep
Claus Färber
Tatsuhiko Miyagawa
Internationalised
