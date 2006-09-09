package Tee;

$VERSION     = "0.01";
@ISA         = qw (Exporter);
@EXPORT      = qw (tee);

use strict;
use Exporter ();
use Carp;
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
    if ( -x $try_ptee || 
         system("$try_ptee -V $to_devnull" ) == 0 ) {
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
    system( "$command $redirect | $ptee_cmd $file" );
}

1; # modules must be true

__END__
#--------------------------------------------------------------------------#
# main pod documentation 
#--------------------------------------------------------------------------#

=begin wikidoc

= NAME

Tee - Put abstract here 

= SYNOPSIS

 use Tee;
 blah blah blah

= DESCRIPTION

Description...

= USAGE

Usage...

= BUGS

Please report any bugs or feature using the CPAN Request Tracker.  
Bugs can be submitted by email to C<bug-DISTNAME@rt.cpan.org> or 
through the web interface at 
L<http://rt.cpan.org/Public/Dist/Display.html?Name=DISTNAME>

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
