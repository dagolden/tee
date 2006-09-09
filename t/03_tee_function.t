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
my $hello = File::Spec->catfile(qw/t helloworld.pl/);
my $tee = File::Spec->catfile(qw/scripts ptee/);
my $tempfh = File::Temp->new;
my $tempname = $tempfh->filename;
my $got;

$ENV{PATH} = join( $path_sep, 'scripts', split( $path_sep, $ENV{PATH} ) );

#--------------------------------------------------------------------------#
# Begin test plan
#--------------------------------------------------------------------------#

plan tests =>  6 ;

require_ok( "Tee" );
Tee->import;

can_ok( "main", "tee" );

ok( -r $hello, 
    "hello script readable" 
);

# check direct output of helloworld

run3 "$perl $hello", undef, \$got;

is( $got, expected("STDOUT"), 
    "hello world program output (direct)"
);

# check tee of STDOUT
truncate $tempfh, 0;
tee("$perl $hello", $tempname);

open FH, "< $tempname";
$got = do { local $/; <FH> };
close FH;

is( $got, expected("STDOUT"), 
    "hello world program output (tee file)"
);

# check tee of both STDOUT and STDERR
truncate $tempfh, 0;
tee("$perl $hello", { stderr => 1 }, $tempname);

open FH, "< $tempname";
$got = do { local $/; <FH> };
close FH;

is( $got, expected("STDOUT") . expected("STDERR"), 
    "hello world program output (tee file with stderr)"
);

