# $Id$

use 5.006;

use utf8;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Encode::Punycode',
    'VERSION_FROM'	=> 'lib/Encode/Punycode.pm', # finds $VERSION
    'PREREQ_PM'		=> {
    		'Encode' => 1,
		'Net::IDN::Punycode' => 0.99,
	},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => 'Encode plugin for Punycode (RFC 3492)',
       AUTHOR   => 'Claus Färber <CFAERBER@cpan.org>',
       LICENSE  => 'perl',
      ) : ()),
);

sub MY::postamble {
return <<EOF
release: release-sf release-cpan

release-cpan:
	cpan-upload \$(DISTVNAME).tar\$(SUFFIX)

release-sf:
	sf-upload -groupid 112466 -packageid 248782 -r \$(VERSION) -cf Changes -nf README -f \$(DISTVNAME).tar\$(SUFFIX)
EOF
}
