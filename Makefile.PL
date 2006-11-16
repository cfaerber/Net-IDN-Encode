use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Net::IDN::Nameprep',
    'VERSION_FROM' => 'lib/Net/IDN/Nameprep.pm', # finds $VERSION
    'PREREQ_PM' => {
	Unicode::Normalize => 0,
	Test::More => 0.18,
    },
);
