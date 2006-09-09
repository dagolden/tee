package t::Expected;
@EXPORT = qw( expected );
@ISA = qw( Exporter );
use strict;
use Exporter;

my %expected = (
    "STDOUT" => "# STDOUT: hello world\n",
    "STDERR" => "# STDERR: goodbye, cruel world\n",
);

sub expected {
    return $expected{+shift};
}

1;
