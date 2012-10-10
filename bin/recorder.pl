#!/usr/bin/perl

# TODO: Validate required options exist

use Getopt::Long;
use Foscorder::Recorder;

my %options;

GetOptions (\%options, 'name=s', 'url=s', 'username=s', 'password=s', 'file_size=i', 'keep_days=i');

my $recorder = Foscorder::Recorder->new(\%options);

$recorder->record();


