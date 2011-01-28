use strict;
use warnings;
package Tee::App;
# ABSTRACT: Implementation of ptee

use Exporter ();
use File::Basename qw/basename/;
use Getopt::Long;
use IO::File;
our @ISA = 'Exporter';
our @EXPORT = qw/run/;

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

=end wikidoc

=cut
