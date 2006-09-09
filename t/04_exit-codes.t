# Tee tests
use strict;
use File::Spec;
use File::Temp;
use IPC::Run3;
use Probe::Perl;
use Test::More;
use t::Expected;

#--------------------------------------------------------------------------#
# autoflush to keep output in order
#--------------------------------------------------------------------------#

my $stdout = select(STDERR);
$|=1;
select($stdout);
$|=1;

#--------------------------------------------------------------------------#
# Declarations
#--------------------------------------------------------------------------#

my $pp = Probe::Perl->new;
my $perl = $pp->find_perl_interpreter;
my $path_sep = $pp->config("path_sep");
my $succeed = File::Spec->catfile(qw/ t succeed.pl /);
my $fail = File::Spec->catfile(qw/ t fail.pl /);
my $tempfh = File::Temp->new();

$ENV{PATH} = join( $path_sep, 'scripts', split( $path_sep, $ENV{PATH} ) );

#--------------------------------------------------------------------------#
# Begin test plan
#--------------------------------------------------------------------------#

plan skip_all => "exit code passthrough not supported";
#plan tests =>  4 ;

require_ok( "Tee" );
Tee->import;

can_ok( "main", "tee" );

is( tee("$perl $succeed", $tempfh), 0,
    "passthrough exit 0"
);

is( tee("$perl $fail", $tempfh), 1,
    "passthrough exit 1"
);
