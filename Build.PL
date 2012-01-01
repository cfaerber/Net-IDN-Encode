use 5.006;

use strict;
use utf8;

use Module::Build;

my $b = Module::Build->new(
	'module_name'	=> 'Net::IDN::UTS46',

	'license'	=> 'perl',
	'dist_author'	=> 'Claus Färber <CFAERBER@cpan.org>',
	'dist_abstract' => 'Unicode IDNA Compatibility Processing (UTS #46)',

	'sign'		=> 1,
	'create_license' => 1,
	'create_makefile_pl' => 'traditional',

	'requires'	=> {
		'Net::IDN::Punycode' => 1.009,
		'Unicode::Normalize' => 1,
		'perl'	=> 5.008_003,
	},
	'build_requires' => {
		'Test::More' => 0, 
		'Test::NoWarnings' => 0,
	},
	'PL_Files' => {
		'lib/Unicode/UTS46/Mapping.PL'  => 'lib/Unicode/UTS46/Mapping.pm',
		'lib/Unicode/UTS46/GenTests.PL'	 => [
			't/uts46_to_ascii.t',
			't/uts46_to_ascii-trans.t',
			't/uts46_to_unicode.t',
		]
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
