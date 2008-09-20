# $Id$

use 5.006;

use utf8;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::IDN::Encode',
    'VERSION_FROM'	=> 'lib/Net/IDN/Encode.pm', # finds $VERSION
    'PREREQ_PM'		=> {
		'Unicode::Stringprep'	=> 1.00,
		'perl'			=> 5.006,
	},
    'ABSTRACT'		=> 'handle Internationalised Domain Names in Applications (IDNA)',
    'AUTHOR'		=> 'Claus Faerber <CFAERBER@cpan.org>',
    'LICENSE'		=> 'perl',
    'SIGN'		=> 1,
);

sub MY::postamble {
return <<EOF
release: release-sf release-cpan

release-cpan:
	cpan-upload \$(DISTVNAME).tar\$(SUFFIX)

release-sf:
	sf-upload -groupid 112466 -packageid 121685 -r \$(VERSION) -cf Changes -nf README -f \$(DISTVNAME).tar\$(SUFFIX)

.PRECIOUS: META.yml

EOF
}
