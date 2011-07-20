WindowsAzure::Storage
=====================
A small library for working with Windows Azure storage from Perl.

Currently only two operations are implemented: [Put Blob](http://msdn.microsoft.com/en-us/library/dd179451.aspx) and [Get Blob](http://msdn.microsoft.com/en-us/library/dd179440.aspx), but the request signing code should generalize.

Usage
=====

    c:\>echo foo > test.txt

    c:\>perl uploadblob.pl smarxtest XLqv1...== "testcontainer/blob.txt" test.txt

    c:\>perl dumpblob.pl smarxtest XLqv1...== "testcontainer/blob.txt"
    foo