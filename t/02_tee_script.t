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

plan tests =>  9 ;

my $perl = Probe::Perl->find_perl_interpreter;
my $hello = File::Spec->catfile(qw/t helloworld.pl/);
my $tee = File::Spec->catfile(qw/scripts ptee/);
my $tempfh = File::Temp->new;
my $tempname = $tempfh->filename;
my ($got_stdout, $got_stderr);

ok( -r $hello, 
    "hello script readable" 
);

ok( -r $tee, 
    "tee script readable" 
);

# check direct output of hello world
run3 "$perl $hello", undef, \$got_stdout, \$got_stderr;

is( $got_stdout, expected("STDOUT"),
    "hello world program output (direct)"
);

# check output through ptee
truncate $tempfh, 0;
run3 "$perl $hello | $perl $tee $tempname", undef, \$got_stdout, \$got_stderr;

is( $got_stdout, expected("STDOUT"),
    "hello world program output (tee stdout)"
);

open FH, "< $tempname";
$got_stdout = do { local $/; <FH> };
close FH;

is( $got_stdout, expected("STDOUT"),
    "hello world program output (tee file)"
);

# check appended output
run3 "$perl $hello | $perl $tee -a $tempname", undef, \$got_stdout, \$got_stderr;

open FH, "< $tempname";
$got_stdout = do { local $/; <FH> };
close FH;

is( $got_stdout, expected("STDOUT") x 2,
    "hello world program output (tee -a)"
);

run3 "$perl $hello | $perl $tee --append $tempname", undef, \$got_stdout, \$got_stderr;

open FH, "< $tempname" or die "Can't open $tempname for reading";

$got_stdout = do { local $/; <FH> };
close FH;

is( $got_stdout, expected("STDOUT") x 3,
    "hello world program output (tee --append)"
);

# check multiple files
my $temp2 = File::Temp->new;
truncate $tempfh, 0;
run3 "$perl $hello | $perl $tee $tempname $temp2", undef, \$got_stdout, \$got_stderr;

open FH, "< $tempname";
$got_stdout = do { local $/; <FH> };
close FH;

is( $got_stdout, expected("STDOUT"),
    "hello world program output (tee file1 file2 [1])"
);

open FH, "< $temp2";
$got_stdout = do { local $/; <FH> };
close FH;

is( $got_stdout, expected("STDOUT"),
    "hello world program output (tee file1 file2 [2])"
);

