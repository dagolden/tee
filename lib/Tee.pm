package Tee;

$Tee::VERSION     = '0.13_51';
$Tee::VERSION     = eval $Tee::VERSION; ## no critic
@Tee::ISA         = qw (Exporter);
@Tee::EXPORT      = qw (tee);

use strict;
use Exporter ();
use Probe::Perl;
# use warnings; # only for Perl >= 5.6


#--------------------------------------------------------------------------#
# Platform independent ptee invocation
#--------------------------------------------------------------------------#

my $perl = Probe::Perl->find_perl_interpreter;
my $ptee_cmd = "$perl -MTee::App -e run --";

#--------------------------------------------------------------------------#
# Functions
#--------------------------------------------------------------------------#

sub tee {
    my $command = shift;
    my $options;
    $options = shift if (ref $_[0] eq 'HASH');
    my $files = join(" ", @_);
    my $redirect = $options->{stderr} ? " 2>&1 " : q{};
    my $append = $options->{append} ? " -a " : q{};
    system( "$command $redirect | $ptee_cmd $append $files" );
}

1; # modules must be true

__END__
#--------------------------------------------------------------------------#
# main pod documentation 
#--------------------------------------------------------------------------#

=begin wikidoc

= NAME

Tee - Pure Perl emulation of GNU tee

= VERSION

This documentation refers to version %%VERSION%%

= SYNOPSIS

 # from Perl
 use Tee;
 tee( $command, @files );
 
 # from the command line
 $ cat README.txt | ptee COPY.txt

= DESCRIPTION

The {Tee} distribution provides the [ptee] program, a pure Perl emulation of
the standard GNU tool {tee}.  It is designed to be a platform-independent
replacement for operating systems without a native {tee} program.  As with
{tee}, it passes input received on STDIN through to STDOUT while also writing a
copy of the input to one or more files.  By default, files will be overwritten.

Unlike {tee}, {ptee} does not support ignoring interrupts, as signal handling
is not sufficiently portable.

The {Tee} module provides a convenience function that may be used in place of
{system()} to redirect commands through {ptee}. 

= USAGE

== {tee()}

  tee( $command, @filenames );
  tee( $command, \%options, @filenames );

Executes the given command via {system()}, but pipes it through [ptee] to copy
output to the list of files.  Unlike with {system()}, the command must be a
string as the command shell is used for redirection and piping.  The return
value of {system()} is passed through, but reflects the success of 
the {ptee} command, which isn't very useful.

The second argument may be a hash-reference of options.  Recognized options
include:

* stderr -- redirects STDERR to STDOUT before piping to [ptee] (default: false)
* append -- passes the {-a} flag to [ptee] to append instead of overwriting
(default: false)

= LIMITATIONS

Because of the way that {Tee} uses pipes, it is limited to capturing a single
input stream, either STDOUT alone or both STDOUT and STDERR combined.  A good,
portable alternative for capturing these streams from a command separately is
[IPC::Run3], though it does not allow passing it through to a terminal at the
same time.

= SEE ALSO

* [ptee]
* IPC::Run3
* IO::Tee

= BUGS

Please report any bugs or feature using the CPAN Request Tracker.  
Bugs can be submitted through the web interface at 
[http://rt.cpan.org/Dist/Display.html?Queue=Tee]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= AUTHOR

David A. Golden (DAGOLDEN)

= COPYRIGHT AND LICENSE

Copyright (c) 2006-2008 by David A. Golden. All rights reserved.

Licensed under Apache License, Version 2.0 (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a 
copy of the License from http://www.apache.org/licenses/LICENSE-2.0

Files produced as output though the use of this software, shall not be
considered Derivative Works, but shall be considered the original work of the
Licensor.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end wikidoc

=cut
