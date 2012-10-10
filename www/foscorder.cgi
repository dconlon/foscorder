#!/usr/bin/perl

use warnings;
use strict;
use CGI qw/:push/;

my $STORE = "/home/dconlon/foscorder/";

my $q = CGI->new;

my $action = $q->param('action');

if ($action eq "play") {
    play($q);
} else {
    error("Not yet implemented");
}

sub play {
    my $q    = shift;
    my $file = $q->param("file");
    
    return error("404 No file specified") unless $file;
    
    open(FH, join("/", $STORE, $file)) || return error("404 Not Found");

    print multipart_init(-boundary=>'--ipcam');

    while(<FH>) {
        print $_;
    }
}

sub error {
    my $status = shift;
    print $q->header( -type => "text/html", -status => $status );
}
