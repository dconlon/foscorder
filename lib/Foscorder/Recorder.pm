package Foscorder::Recorder;

use warnings;
use strict;
use LWP;
use Carp;
use File::Path qw(make_path);

sub new {
    my $class = shift;
    my $args  = shift || {};
    
    my $self = bless $args, $class;
    
    my $ua = LWP::UserAgent->new();
        
    $ua->add_handler( response_data => sub {
        my($response, $ua, $h, $data) = @_;
        
        die $response->status_line unless $response->is_success();

        $self->data($data);
    });

    $self->{ua} = $ua;
    
    $self->{file_size} ||= (1024 * 1024 * 10);
        
    return $self;
}

sub get_output_fh {
    my $self = shift;
    
    my ($year, $month, $day, $hour, $min, $sec) = sub {($_[5]+1900, $_[4]+1, $_[3], $_[2], $_[1], $_[0] )}->(localtime);
    
    my $dir  = join('/', $self->{name}, $year, $month, $day);
    my $file = sprintf("%s_%s-%02d-%02d-%02d%02d%02d.mjpeg", $self->{name}, $year, $month, $day, $hour, $min, $sec);
    my $path = join('/', $dir, $file);
    
    make_path($dir);
    
    local *FH;
        
    open(FH, ">", $path) || die "Cannot open $path for write: $!";

    return *FH;
}

sub record {
    my $self = shift;
    while(1) {
        $self->record_one_file();
    }
}

sub record_one_file {
    my $self = shift;
    
    $self->{bytes_written} = 0;
    
    $self->{output_fh} = $self->get_output_fh();
            
    my $url = $self->{url} . sprintf("/videostream.cgi?resolution=32&rate=14&user=%s&pwd=%s", $self->{username}, $self->{password});
    
    $self->{ua}->get($url);
}

sub data {
    my ($self, $data) = @_;
    
    # Increment bytes_written
    {
        use bytes;
        my $size = length($data);
        $self->{bytes_written} += $size;
    }
    
    my $fh = $self->{output_fh};
            
    if ($self->{bytes_written} > $self->{file_size}) {
        # Once file size is reached, finish this file at end of next JPEG
        my ($end, $start) = split(/--ipcam/, $data);
        if ($end && $start) {
            print $fh $end;
            croak "file_size reached";
        }
    }
    
    print $fh $data;
    
    return 1;
}

1