select(STDERR);
$|++;
select(STDOUT);
$|++;
print STDOUT "# STDOUT: hello world\n";
print STDERR "# STDERR: goodbye, cruel world\n";
