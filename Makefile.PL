# $Id$

use 5.006;

use utf8;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME'		=> 'Net::IDN::Encode',
	'ABSTRACT'	=> 'handle Internationalised Domain Names in Applications (IDNA)',
	'VERSION_FROM'	=> 'lib/Net/IDN/Encode.pm', # finds $VERSION
	'PREREQ_PM'	=> {
		'Unicode::Stringprep'	=> 0.30,
	    },
	'AUTHOR'	=> 'Claus Faerber <CFAERBER@cpan.org>',
	'LICENSE'	=> 'perl',

$ExtUtils::MakeMaker::VERSION < 6.18 ? () : (
	'SIGN'		=> 1,
    ),

$ExtUtils::MakeMaker::VERSION < 6.45 ? () : (
	'META_MERGE'	=> { 
		'requires'	=> {
			'perl'	=> 5.006,
		    },

		'recommends'	=> {
			'perl'	=> 5.008003,
		    },

		'conflicts'	=> {
			'IDNA::Punycode' => '< 0.99',
			'Encode::Punycode' => '< 0.99',
			'Net::IDN::Nameprep' => '< 0.99',
		    },

		'build_requires' => {
			'Test::More' => 0, 
			'Test::NoWarnings' => 0,
		    },
	    },
    ),
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
