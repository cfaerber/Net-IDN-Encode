use 5.006;

use strict;
use utf8;

use Module::Build;

my $b = Module::Build->new(
	'module_name'	=> 'IDNA::Punycode',
	'license'	=> 'perl',
	'dist_author'	=> 'Claus Färber <CFAERBER@cpan.org>',

	'sign'		=> 1,
	'create_license' => 1,
	'create_makefile_pl' => 'traditional',

	'requires'	=> {
		'Net::IDN::Nameprep' => 1,
		'Net::IDN::Punycode' => 1,
	},
	'build_requires' => {
		'Test::More' => 0, 
		'Test::NoWarnings' => 0,
	},
	'resources' => {
		'homepage' => 'http://search.cpan.org/dist/Net-IDN-Encode',
		'repository' => 'http://github.com/cfaerber/Net-IDN-Encode',
	},
);

$b->create_build_script;
