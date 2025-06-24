' VBScript CGI File Manager with Download
Option Explicit

Dim fso, folder, file, path, fs, fileToDownload
Set fso = CreateObject("Scripting.FileSystemObject")
Set fs = CreateObject("Scripting.FileSystemObject")

' Parse QUERY_STRING
Dim qs, params, i, kv, key, val
path = "C:\"  ' Default path
fileToDownload = ""

qs = WScript.Arguments.Named("QUERY_STRING")

If qs <> "" Then
    params = Split(qs, "&")
    For i = 0 To UBound(params)
        kv = Split(params(i), "=")
        If UBound(kv) = 1 Then
            key = LCase(kv(0))
            val = Replace(kv(1), "%20", " ")
            val = Replace(val, "/", "\")
            Select Case key
                Case "path": path = val
                Case "download": fileToDownload = val
            End Select
        End If
    Next
End If

' DOWNLOAD handler
If fileToDownload <> "" Then
    If fso.FileExists(fileToDownload) Then
        WScript.Echo "Content-Type: application/octet-stream"
        WScript.Echo "Content-Disposition: attachment; filename=""" & fso.GetFile(fileToDownload).Name & """"
        WScript.Echo ""
        Dim fileObj, stream
        Set fileObj = fso.OpenTextFile(fileToDownload, 1, False)
        Do Until fileObj.AtEndOfStream
            WScript.StdOut.Write fileObj.Read(1024)
        Loop
        fileObj.Close
    Else
        WScript.Echo "Status: 404 Not Found"
        WScript.Echo "Content-Type: text/plain"
        WScript.Echo ""
        WScript.Echo "File not found."
    End If
    WScript.Quit
End If

' HTML Output
WScript.Echo "Content-Type: text/html"
WScript.Echo ""
WScript.Echo "<html><head><title>WSL File Manager</title><style>"
WScript.Echo "body { background:#111; color:#0f0; font-family:Consolas, monospace; padding:20px; }"
WScript.Echo "a { color:#0ff; text-decoration:none; } table{border-collapse:collapse;width:100%;}"
WScript.Echo "td,th{border:1px solid #333;padding:8px;} th{background:#222;}"
WScript.Echo "</style></head><body>"
WScript.Echo "<h2>📁 Path: " & path & "</h2>"
WScript.Echo "<table><tr><th>Name</th><th>Type</th><th>Size</th><th>Action</th></tr>"

If fso.FolderExists(path) Then
    Set folder = fso.GetFolder(path)

    ' Parent dir
    If folder.Path <> folder.Drive & "\" Then
        WScript.Echo "<tr><td colspan=4><a href='filemanager.vbs?path=" & ServerURLEncode(folder.ParentFolder.Path) & "'>🔼 .. (Parent)</a></td></tr>"
    End If

    ' Subfolders
    For Each file In folder.SubFolders
        WScript.Echo "<tr><td><a href='filemanager.vbs?path=" & ServerURLEncode(file.Path) & "'>📁 " & file.Name & "</a></td><td>Folder</td><td>-</td><td>-</td></tr>"
    Next

    ' Files
    For Each file In folder.Files
        WScript.Echo "<tr><td>📄 " & file.Name & "</td><td>File</td><td>" & file.Size & " bytes</td>"
        WScript.Echo "<td><a href='filemanager.vbs?download=" & ServerURLEncode(file.Path) & "'>⬇ Download</a></td></tr>"
    Next

Else
    WScript.Echo "<tr><td colspan='4'><b>Folder not found</b></td></tr>"
End If

WScript.Echo "</table></body></html>"

' --- URL Encoder (manual, subset) ---
Function ServerURLEncode(str)
    Dim temp
    temp = Replace(str, "\", "/")
    temp = Replace(temp, ":", "%3A")
    temp = Replace(temp, " ", "%20")
    ServerURLEncode = temp
End Function
