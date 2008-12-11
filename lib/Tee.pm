# Copyright (c) 2008 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

package Tee;
use strict;

$Tee::VERSION     = '0.13_51';
$Tee::VERSION     = eval $Tee::VERSION; ## no critic
@Tee::ISA         = qw (Exporter);
@Tee::EXPORT      = qw (tee);

use Exporter ();
use IO::File;

sub tee {
    my $command = shift;
    my $options;
    $options = shift if (ref $_[0] eq 'HASH');

    my $mode = $options->{append} ? ">>" : ">";
    my $redirect = $options->{stderr} ? " 2>&1 " : q{};

    my @files;
    for my $file ( @_ ) {
        my $f = IO::File->new("$mode $file") 
            or die "Could't open '$file' for writing: $!'";
        push @files, $f;
    }

    local *COMMAND_FH;
    open COMMAND_FH, "$command $redirect |" or die;
    my $buffer;
    my $buffer_size = 1024;
    while ( sysread( COMMAND_FH, $buffer, $buffer_size ) > 0 ) {
        for my $fh ( *STDOUT, @files ) {
            syswrite $fh, $buffer;
        }
    }
    
    close COMMAND_FH; # to get $?
    my $status = $?;
    my $exit = $status ? 0 : 1; 
    
    close for @files;

    return wantarray ? ($exit, $status) : $exit;
}

1;

__END__

=begin wikidoc

= NAME

Tee - Pure Perl emulation of GNU tee

= VERSION

This documentation describes version %%VERSION%%.

= SYNOPSIS

 # from Perl
 use Tee;
 tee( $command, @files );
 
 # from the command line
 $ cat README.txt | ptee COPY.txt

= DESCRIPTION

The {Tee} distribution provides a pure Perl emulation of the standard GNU tool
{tee}.  It is designed to be a platform-independent replacement for operating
systems without a native {tee} program.  As with {tee}, it passes input
received on STDIN through to STDOUT while also writing a copy of the input to
one or more files.  By default, files will be overwritten.

In addition to this module, the distribution also provides the [ptee] program
for a command line replacement for {tee}.  Unlike {tee}, {ptee} does not
support ignoring interrupts, as signal handling is not sufficiently portable.

= USAGE

== {tee()}

  tee( $command, @filenames );
  tee( $command, \%options, @filenames );

Executes the given command, teeing output to STDOUT and a list of files.
Unlike with {system()}, the command must be a string as the command shell is
used for redirection and piping.  It returns true if the command has an exit
status of zero and false otherwise.  The exit status is preserved in {$?}.

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

= BUGS

Please report any bugs or feature using the CPAN Request Tracker.  
Bugs can be submitted through the web interface at 
[http://rt.cpan.org/Dist/Display.html?Queue=Tee]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= SEE ALSO

* [ptee]
* IPC::Run3
* IO::Tee

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

