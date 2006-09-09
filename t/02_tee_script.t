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

plan tests =>  5 ;

my $perl = Probe::Perl->find_perl_interpreter;
my $hello = File::Spec->catfile(qw/t helloworld.pl/);
my $tee = File::Spec->catfile(qw/scripts ptee/);
my $tempfh = File::Temp->new;
my $tempname = $tempfh->filename;
my $got;

ok( -r $hello, 
    "hello script readable" 
);

ok( -r $tee, 
    "tee script readable" 
);

# check direct output of hello world
run3 "$perl $hello", undef, \$got;

is( $got, expected("STDOUT"),
    "hello world program output (direct)"
);

# check output through ptee
truncate $tempfh, 0;
run3 "$perl $hello | $perl $tee $tempname", undef, \$got;

is( $got, expected("STDOUT"),
    "hello world program output (tee stdout)"
);

open FH, "< $tempname";
$got = do { local $/; <FH> };
close FH;

is( $got, expected("STDOUT"),
    "hello world program output (tee file)"
);

