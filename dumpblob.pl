#!perl -w

use WindowsAzure::Storage;

die "Usage: dumpblob.pl <account> <key> <full/path/to/blob>" unless @ARGV == 3;
my ($account, $key, $path, $filename) = @ARGV;

my $res = WindowsAzure::Storage::download($account, $key, $path);
die "ERROR:\n" . $res->as_string unless $res->code == 200;
print $res->content;