# Copyright (c) 2008 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

use 5.006;
use strict;
use warnings;
use lib 'inc';
eval "require Pod::WikiDoc";
my $class = $@ ? "Module::Build" : "Module::Build::WikiDoc";
eval "require $class";
my $build = $class->new( 
    module_name => 'Tee',
    dist_author => 'David Golden <dagolden@cpan.org>',
    license => 'apache',
    create_readme => 1,
    create_makefile_pl  => 'traditional',
    requires => {
      'perl' => 0, # not specified
      'Exporter' => 0,
      'File::Basename' => 0,
      'Getopt::Long' => 2.37, # 2.20 in perl 5.00504; 2.25 in perl 5.006002; 2.35 in perl 5.008008; 
      'IO::File' => 0,
      'Probe::Perl' => 0.01,
    },
    build_requires => {
      'File::Spec' => 3.2701, # 0.8 in perl 5.00504; 0.86 in perl 5.006002; 3.12 in perl 5.008008; 3.2701 is new
      'File::Temp' => 0.20, # 0.14 in perl 5.006002; 0.16 in perl 5.008008; 0.20 is new
      'IO::CaptureOutput' => 1.1,
      'Test::More' => 0.62, # 0.47 in perl 5.006002; 0.62 in perl 5.008008; 
    },
    meta_add            => { 
        no_index => { 
            directory => [ qw/ examples inc t /],
        } 
    },
);
$build->create_build_script;
