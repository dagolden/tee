# Copyright (c) 2008 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

package Tee::App;
use strict;
use Exporter ();
use File::Basename qw/basename/;
use Getopt::Long;
use IO::File;

@Tee::App::ISA = 'Exporter';
@Tee::App::EXPORT = qw/run/;
$Tee::App::VERSION = '0.13_51';
$Tee::App::VERSION = eval $Tee::App::VERSION; ## no critic

#--------------------------------------------------------------------------#
# define help text
#--------------------------------------------------------------------------#

my $help_text = <<'END_HELP';

 ptee [OPTIONS]... [FILENAMES]...

 OPTIONS:
 
    --append or -a
        append to file(s) rather than overwrite

    --help or -h
        give usage information

    --version or -V
        print the version number of this program

END_HELP

$help_text =~ s/\A.+?( ptee.*)/$1/ms;

sub run {

  #--------------------------------------------------------------------------#
  # process command line
  #--------------------------------------------------------------------------#

  my %opts;
  GetOptions( \%opts,
      'version|V',
      'help|h|?',
      'append|a',
  );

  #--------------------------------------------------------------------------#
  # options
  #--------------------------------------------------------------------------#

  if ($opts{version}) {
      print basename($0), " $main::VERSION\n";
      exit 0;
  }

  if ($opts{help}) {
      print "Usage:\n$help_text";
      exit 1;
  }

  my $mode = $opts{append} ? ">>" : ">";

  #--------------------------------------------------------------------------#
  # Setup list of filehandles
  #--------------------------------------------------------------------------#

  my $stdout = IO::Handle->new->fdopen(fileno(STDOUT),"w");
  my @files = $stdout;

  for my $file ( @ARGV ) {
      my $f = IO::File->new("$mode $file") 
          or die "Could't open '$file' for writing: $!'";
      push @files, $f;
  }

  #--------------------------------------------------------------------------#
  # Tee input to the filehandle list
  #--------------------------------------------------------------------------#

  my $buffer_size = 1024;
  my $buffer;

  while ( sysread( STDIN, $buffer, $buffer_size ) > 0 ) {
      for my $fh ( @files ) {
          syswrite $fh, $buffer;
      }
  }
  return;
}

1;

__END__

=begin wikidoc

= NAME

Tee::App - Pure Perl emulation of GNU tee

= VERSION

This documentation refers to version %%VERSION%%

= DESCRIPTION

Guts of the {ptee} command.

= SEE ALSO

* [ptee]

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
