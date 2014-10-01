#!perl -w

use WindowsAzure::Storage;

$verbose = 1; 

die "Usage: listcontainers.pl <account> <key>" unless @ARGV == 2;
my ($account, $key) = @ARGV;

my $res = WindowsAzure::Storage::listcontainers($account, $key);

die "ERROR: getting container list\n" . $res->as_string unless $res->code == 200;

$rs=$res->as_string;

if ($rs=~m!<Name>([^<]+)</Name>!) {
    $name=$1;
    print "Enumerating container $name...\n" if $verbose;
    
    my $bres = WindowsAzure::Storage::listblobs($account, $key, $name);

    die "ERROR:\n" . $bres->as_string unless $bres->code == 200;

    $brs=$bres->as_string;

    if ($brs=~m!<Name>([^<]+)</Name>!) {
	$bname=$1;
	print "Checking blob $bname...\n" if $verbose;
	
	my $breq = new HTTP::Request('GET', "http://$account.blob.core.windows.net/$name/$bname");
	
	$cres=(new LWP::UserAgent)->request($breq);

	if ($cres->code == 200) { 
	    print "*** Public access blob $name/$bname (wget http://$account.blob.core.windows.net/$name/$bname)\n\n";
	}
    }

}

