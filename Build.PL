use 5.006;

use strict;
use utf8;

use Module::Build;

my $b = Module::Build->new(
	'module_name'	=> 'Net::IDN::Encode',

	'license'	=> 'perl',
	'dist_author'	=> 'Claus Färber <CFAERBER@cpan.org>',
	'dist_abstract' => 'Internationalizing Domain Names in Applications (UTS #46)',

	'sign'		=> 1,
	'create_license' => 1,
	'create_makefile_pl' => 'traditional',

	'requires'	=> {
		'Unicode::Normalize' => 1,
		'perl'	=> 5.008_003,
	},
	'build_requires' => {
		'Test::More' => 0, 
		'Test::NoWarnings' => 0,
	},
	'PL_Files' => {
		'lib/Unicode/UTS46/Mapping.PL'  => 'lib/Unicode/UTS46/Mapping.pm',
		'lib/Unicode/UTS46/GenTests.PL'	 => [	't/uts46_to_ascii-transitional.t', 't/uts46_to_ascii-nontransitional.t',
							't/uts46_to_unicode-transitional.t', 't/uts46_to_unicode-nontransitional.t', ],
	},
	'no_index' => {
		'directory' => ['eg', 'data']
	},
	'resources' => {
		'homepage' => 'http://search.cpan.org/dist/Net-IDN-Encode',
		'repository' => 'http://github.com/cfaerber/Net-IDN-Encode',
	},
);

$b->create_build_script;
