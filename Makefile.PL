use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::IDN::Encode',
    'VERSION_FROM'	=> 'Encode.pm', # finds $VERSION
    'PREREQ_PM'		=> {
		'Net::IDN::Nameprep' => 0.02,
		'IDNA::Punycode' => 0.02,
	},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Encode.pm', # retrieve abstract from module
       AUTHOR     => 'Claus Färber <perl@faerber.muc.de>') : ()),
);
