#!/usr/bin/perl

use strict;
use utf8;
use warnings;

use Module::Build;

my $b = Module::Build->new(
	'module_name'	=> 'Encode::Punycode',
	'dist_author'	=> 'Claus Färber <CFAERBER@cpan.org>',
	'license'	=> 'perl',
	
	'sign'		=> 1,
	'create_license' => 1,
	'create_makefile_pl' => 'traditional',

	'requires'	=> {
		'Net::IDN::Punycode' => 1,
    		'Encode' => 1,
	},
	'build_requires' => {
		'Test::More' => 0,
		'Test::NoWarnings' => 0,
	},
	'no_index' => {
		'directory' => 'eg'
	},
	'resources' => {
		'homepage' => 'http://search.cpan.org/dist/Encode-Punycode',
		'repository' => 'http://github.com/cfaerber/Encode-Punycode',
	},
);

$b->create_build_script;
