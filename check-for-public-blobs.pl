#!perl -w

use WindowsAzure::Storage;

$verbose = 1; 

die "Usage: listcontainers.pl <account> <key>" unless @ARGV == 2;
my ($account, $key) = @ARGV;

my $res = WindowsAzure::Storage::listcontainers($account, $key);

die "ERROR: getting container list\n" . $res->as_string unless $res->code == 200;

$rs_total=$res->as_string;

@containers=split(m/<Container>/,$rs_total);

for $rs (@containers) {

    if ($rs=~m!<Name>([^<]+)</Name>!) {

	$name=$1;
	print "Enumerating container $name...\n" if $verbose;
	
	my $bres = WindowsAzure::Storage::listblobs($account, $key, $name);

	die "ERROR:\n" . $bres->as_string unless $bres->code == 200;

	$brs_total=$bres->as_string;

	@blobs=split(m/<Blob>/,$brs_total);

	for $brs (@blobs) {

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
    }
}
