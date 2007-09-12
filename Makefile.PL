# $Id$

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::IDN::Encode',
    'DISTNAME'		=> 'Net-IDN-tools',
    'VERSION_FROM'	=> 'lib/Net/IDN/Encode.pm', # finds $VERSION
    'PREREQ_PM'		=> {
		'Unicode::Normalize' => 0.01,
	},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => 'modules for handling of Internationalised Domain Names in Applications (IDNA)',
       AUTHOR   => 'Claus Färber <perl@cfaerber.name>') : ()),
);
