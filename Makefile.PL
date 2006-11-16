use ExtUtils::MakeMaker;
require 5.6.0;
WriteMakefile(
    'NAME'      => 'IDNA::Punycode',
    'VERSION_FROM' => 'lib/IDNA/Punycode.pm', # finds $VERSION
    'PREREQ_PM' => {
	'Test::More' => 0.32,
    },
);
