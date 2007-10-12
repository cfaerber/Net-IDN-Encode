# $Id$

use utf8;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::IDN::Encode',
    'DISTNAME'		=> 'Net-IDN-tools',
    'VERSION_FROM'	=> 'lib/Net/IDN/Encode.pm', # finds $VERSION
    'PREREQ_PM'		=> {
		'Unicode::Stringprep' => 1.00,
	},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => 'modules for handling of Internationalised Domain Names in Applications (IDNA)',
       AUTHOR   => 'Claus Färber <CFAERBER@cpan.org>') : ()),
);

sub MY::postamble {
return <<EOF
release: release-sf release-cpan

release-cpan:
	cpan-upload \$(DISTVNAME).tar\$(SUFFIX)

release-sf:
	sf-upload -groupid 112466 -packageid 245143 -r \$(VERSION) -cf Changes -nf README -f \$(DISTVNAME).tar\$(SUFFIX)
EOF
}
