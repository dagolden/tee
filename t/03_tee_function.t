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
my ($got_stdout, $got_stderr);

$ENV{PATH} = join( $path_sep, 'scripts', split( $path_sep, $ENV{PATH} ) );

#--------------------------------------------------------------------------#
# Begin test plan
#--------------------------------------------------------------------------#

plan tests =>  7 ;

require_ok( "Tee" );
Tee->import;

can_ok( "main", "tee" );

ok( -r $hello, 
    "hello script readable" 
);

# check direct output of helloworld

run3 "$perl $hello", undef, \$got_stdout, \$got_stderr;

is( $got_stdout, expected("STDOUT"), 
    "hello world program output (direct)"
);

# check tee of STDOUT
truncate $tempfh, 0;
tee("$perl $hello", $tempname);

open FH, "< $tempname";
$got_stdout = do { local $/; <FH> };
close FH;

is( $got_stdout, expected("STDOUT"), 
    "hello world program output (tee file)"
);

# check tee of both STDOUT and STDERR
truncate $tempfh, 0;
tee("$perl $hello", { stderr => 1 }, $tempname);

open FH, "< $tempname";
$got_stdout = do { local $/; <FH> };
close FH;

is( $got_stdout, expected("STDOUT") . expected("STDERR"), 
    "hello world program output (tee file with stderr)"
);

# check tee of both with append
tee("$perl $hello", { stderr => 1, append => 1 }, $tempname);

open FH, "< $tempname";
$got_stdout = do { local $/; <FH> };
close FH;

is( $got_stdout, (expected("STDOUT") . expected("STDERR")) x 2, 
    "hello world program output (tee file with stderr and append)"
);
