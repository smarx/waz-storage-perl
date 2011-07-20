#!perl -w

use WindowsAzure::Storage;

die "Usage: putblob.pl <account> <key> <full/path/to/blob> <filename>" unless @ARGV == 4;
my ($account, $key, $path, $filename) = @ARGV;

my $res = WindowsAzure::Storage::upload($account, $key, $path, $filename);
die "ERROR:\n" . $res->as_string unless $res->code == 201;