package WindowsAzure::Storage;
use strict;
use warnings;

use HTTP::Request::Common qw($DYNAMIC_FILE_UPLOAD);
$HTTP::Request::Common::DYNAMIC_FILE_UPLOAD = 1;
use LWP::UserAgent;
use HTTP::Date;
use Data::Dumper;
use URI::QueryParam;
use Digest::SHA qw(hmac_sha256_base64);
use MIME::Base64;

sub sign_request ($$)
{
    my ($req, $key) = @_;
    
    $req->header('x-ms-version', '2009-09-19');
    $req->header('x-ms-date', time2str());
    
    my $canonicalized_headers = join "", map { lc($_) . ':' . $req->header($_) . "\n" } sort grep {/^x-ms/} keys %{$req->headers};
    
    my $account = ($req->uri->authority =~ /^([^.]*)/ and $1);
    my $canonicalized_resource = "/$account@{[$req->uri->path]}";
    $canonicalized_resource .= join "", map { "\n" . lc($_) . ':' . join(',', sort $req->uri->query_param($_)) } sort $req->uri->query_param;
    
    chomp(my $string_to_sign = <<END);
@{[$req->method]}
@{[$req->header('Content-Encoding')]}
@{[$req->header('Content-Language')]}
@{[$req->header('Content-Length')]}
@{[$req->header('Content-MD5')]}
@{[$req->header('Content-Type')]}
@{[$req->header('Date')]}
@{[$req->header('If-Modified-Since')]}
@{[$req->header('If-Match')]}
@{[$req->header('If-None-Match')]}
@{[$req->header('If-Unmodified-Since')]}
@{[$req->header('Range')]}
$canonicalized_headers$canonicalized_resource
END
    my $signature = hmac_sha256_base64($string_to_sign, decode_base64($key));
    $signature .= '=' x (4 - (length($signature) % 4));
    
    $req->authorization("SharedKey $account:$signature");
}

sub upload($$$$)
{
    my ($account, $key, $path, $filename) = @_;
    my $req = new HTTP::Request('PUT', "http://$account.blob.core.windows.net/$path");
    $req->header('x-ms-blob-type', 'BlockBlob');
    $req->content_length(-s $filename);
    sign_request($req, $key);
    open my $fh, "<$filename" or die "Unable to open '$filename'.";
    binmode $fh;
    $req->content(sub
    {
        my $chunk;
        return $chunk if read $fh, $chunk, 1024;
        close $fh;
        return undef;
    });
    return (new LWP::UserAgent)->request($req);
}

sub download($$$)
{
    my ($account, $key, $path) = @_;
    my $req = new HTTP::Request('GET', "http://$account.blob.core.windows.net/$path");
    sign_request($req, $key);
    return (new LWP::UserAgent)->request($req);
}