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
      'Exporter' => 0,
      'File::Basename' => 0,
      'Getopt::Long' => 2.2,  
      'IO::File' => 0,
      'Probe::Perl' => 0.01,
    },
    build_requires => {
      'File::Spec' => 3.27, 
      'File::Temp' => 0.20, 
      'IO::CaptureOutput' => 1.09,
      'Test::More' => 0.47, # 0.47 in perl 5.006002
    },
    meta_add            => { 
        no_index => { 
            directory => [ qw/ examples inc t /],
        } 
    },
);
$build->create_build_script;
