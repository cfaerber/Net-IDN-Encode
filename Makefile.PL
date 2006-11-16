use ExtUtils::MakeMaker;
require 5.7.3;
WriteMakefile(
    'NAME'      => 'Encode::Punycode',
    'VERSION_FROM' => 'lib/Encode/Punycode.pm', # finds $VERSION
    'PREREQ_PM' => {
	'Test::More' => 0.32,
	'IDNA::Punycode' => 0,
    },
);
