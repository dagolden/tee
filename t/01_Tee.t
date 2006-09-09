# Tee tests
use strict;

#--------------------------------------------------------------------------#
# autoflush to keep output in order
#--------------------------------------------------------------------------#

my $stdout = select(STDERR);
$|++;
select($stdout);
$|++;

#--------------------------------------------------------------------------#
use Probe::Perl;
use Test::More;

plan tests =>  1 ;

my $pp = Probe::Perl->new;
my $perl = $pp->find_perl_interpreter;
my $path_sep = $pp->config("path_sep");
$ENV{PATH} = join( $path_sep, 'scripts', split( $path_sep, $ENV{PATH} ) );

require_ok( 'Tee' );

