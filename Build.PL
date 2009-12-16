use 5.006;

use strict;
use utf8;

use Module::Build;

my $b = Module::Build->new(
	'module_name'	=> 'Net::IDN::Encode',
	'license'	=> 'perl',

	'sign'		=> 1,
	'create_license' => 1,
	'create_makefile_pl' => 'traditional',

	'requires'	=> {
		'perl' => 5.006,
		'Unicode::Stringprep' => 0.30,
	},
	'recommends'	=> {
		'perl' => 5.008003,
	},
	'conflicts'	=> {
#		'Encode::Punycode' => '< 0.99',
#		'IDNA::Punycode' => '< 0.99',
#		'Net::IDN::Nameprep' => '< 0.99',
	},
	'build_requires' => {
		'Test::More' => 0, 
		'Test::NoWarnings' => 0,
	},
	'no_index' => {
		'directory' => 'eg'
	},
	'resources' => {
		'homepage' => 'http://search.cpan.org/dist/Net-IDN-Encode',
		'repository' => 'http://github.com/cfaerber/Net-IDN-Encode',
	},
);

$b->create_build_script;
