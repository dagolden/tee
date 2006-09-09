package Tee;

$VERSION     = "0.10";
@ISA         = qw (Exporter);
@EXPORT      = qw (tee);

use strict;
use Exporter ();
use File::Spec;
use Probe::Perl;
# use warnings; # only for Perl >= 5.6

use constant PTEE => "ptee";

#--------------------------------------------------------------------------#
# Platform independent ptee invocation
#--------------------------------------------------------------------------#

my $p = Probe::Perl->new;
my $perl = $p->find_perl_interpreter;
my $ptee_cmd;
my $to_devnull = " > " . File::Spec->devnull . " 2>&1";
for my $path ( split($p->config('path_sep'), $ENV{PATH}) ) {
    my $try_ptee = File::Spec->catfile( $path, PTEE );
    next unless -r $try_ptee;
    if ( system("$try_ptee -V $to_devnull" ) == 0 ) {
        $ptee_cmd = $try_ptee;
        last;
    }
    if ( system("$perl $try_ptee -V $to_devnull") == 0 ) {
        $ptee_cmd = "$perl $try_ptee";
        last;
    }
}

die "Couldn't find a working " . PTEE . "\n" unless $ptee_cmd;

#--------------------------------------------------------------------------#
# Functions
#--------------------------------------------------------------------------#

sub tee {
    my $command = shift;
    my $options;
    $options = shift if (ref $_[0] eq 'HASH');
    my $file = shift;
    my $redirect = $options->{stderr} ? " 2>&1 " : q{};
    my $append = $options->{append} ? " -a " : q{};
    system( "$command $redirect | $ptee_cmd $append $file" );
}

1; # modules must be true

__END__
#--------------------------------------------------------------------------#
# main pod documentation 
#--------------------------------------------------------------------------#

=begin wikidoc

= NAME

Tee - Pure Perl emulation of GNU tee

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

= BUGS

Please report any bugs or feature using the CPAN Request Tracker.  
Bugs can be submitted by email to C<bug-Tee@rt.cpan.org> or 
through the web interface at 
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Tee>

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= AUTHOR

David A. Golden (DAGOLDEN)

dagolden@cpan.org

http://www.dagolden.org/

= COPYRIGHT AND LICENSE

Copyright (c) 2006 by David A. Golden

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


= DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=end wikidoc

=cut
