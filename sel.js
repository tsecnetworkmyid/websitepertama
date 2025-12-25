#!/usr/bin/env node
const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec, spawn } = require('child_process');
const os = require('os');

// ================= CONFIGURATION =================
const PORT = 8080;
const PASSWORD = 'admin123'; // Ganti password ini!
const UPLOAD_DIR = './uploads';
// =================================================

// Create upload directory if not exists
if (!fs.existsSync(UPLOAD_DIR)) {
    fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

// Authentication middleware
function requireAuth(req, res) {
    const auth = req.headers.authorization;
    if (!auth || !auth.startsWith('Basic ')) {
        res.writeHead(401, { 'WWW-Authenticate': 'Basic realm="File Manager"' });
        res.end('Authentication required');
        return false;
    }
    
    const credentials = Buffer.from(auth.slice(6), 'base64').toString();
    if (credentials !== `admin:${PASSWORD}`) {
        res.writeHead(401, { 'WWW-Authenticate': 'Basic realm="File Manager"' });
        res.end('Invalid credentials');
        return false;
    }
    
    return true;
}

// HTML Template
const htmlTemplate = (content) => `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Node.js File Manager</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1a1a2e; color: #e6e6e6; line-height: 1.6; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { background: #162447; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .header h1 { color: #00adb5; margin-bottom: 10px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .stat-card { background: #0f3460; padding: 15px; border-radius: 8px; }
        .tabs { display: flex; gap: 5px; background: #0f3460; padding: 10px; border-radius: 8px; margin: 20px 0; }
        .tab { padding: 10px 20px; background: #1a1a2e; border: none; color: #e6e6e6; cursor: pointer; border-radius: 5px; }
        .tab.active { background: #00adb5; }
        .content { background: #0f3460; padding: 20px; border-radius: 10px; margin-top: 20px; }
        .file-list { display: grid; gap: 10px; }
        .file-item { display: flex; justify-content: space-between; align-items: center; background: #1a1a2e; padding: 15px; border-radius: 8px; }
        .file-info { flex: 1; }
        .file-actions { display: flex; gap: 10px; }
        .btn { padding: 8px 16px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; }
        .btn-primary { background: #00adb5; color: white; }
        .btn-danger { background: #e84545; color: white; }
        .btn-success { background: #16c79a; color: white; }
        .btn-warning { background: #ff9a00; color: white; }
        .form-group { margin-bottom: 15px; }
        input, textarea, select { width: 100%; padding: 10px; background: #1a1a2e; border: 1px solid #00adb5; border-radius: 5px; color: white; }
        .terminal { background: #000; color: #0f0; font-family: monospace; padding: 15px; border-radius: 5px; height: 400px; overflow-y: auto; }
        .terminal-input { display: flex; margin-top: 10px; }
        .terminal-input input { flex: 1; background: #000; border: 1px solid #00adb5; color: #0f0; }
        .alert { padding: 15px; border-radius: 5px; margin: 10px 0; }
        .alert-success { background: #16c79a; }
        .alert-danger { background: #e84545; }
        .alert-info { background: #00adb5; }
        .file-icon { margin-right: 10px; }
        pre { background: #1a1a2e; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .drag-area { border: 2px dashed #00adb5; padding: 40px; text-align: center; border-radius: 10px; margin: 20px 0; }
        .upload-progress { width: 100%; background: #1a1a2e; border-radius: 5px; overflow: hidden; margin: 10px 0; }
        .progress-bar { height: 20px; background: #00adb5; width: 0%; transition: width 0.3s; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); }
        .modal-content { background: #0f3460; margin: 10% auto; padding: 20px; width: 80%; max-width: 600px; border-radius: 10px; }
        .close { float: right; font-size: 24px; cursor: pointer; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #1a1a2e; }
        th { background: #162447; }
        tr:hover { background: #1a1a2e; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📁 Node.js File Manager</h1>
            <div class="stats" id="stats"></div>
        </div>
        
        <div class="tabs">
            <button class="tab active" onclick="showTab('files')">📂 Files</button>
            <button class="tab" onclick="showTab('terminal')">💻 Terminal</button>
            <button class="tab" onclick="showTab('upload')">⬆️ Upload</button>
            <button class="tab" onclick="showTab('system')">📊 System Info</button>
            <button class="tab" onclick="showTab('network')">🌐 Network</button>
        </div>
        
        ${content}
    </div>
    
    <script>
        // Tab switching
        function showTab(tabName) {
            document.querySelectorAll('.tab-content').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.tab').forEach(el => el.classList.remove('active'));
            document.getElementById(tabName).style.display = 'block';
            event.target.classList.add('active');
            
            // Refresh data for specific tabs
            if (tabName === 'files') loadFiles();
            if (tabName === 'system') loadSystemInfo();
            if (tabName === 'network') loadNetworkInfo();
        }
        
        // File operations
        async function deleteFile(filename) {
            if (!confirm('Delete ' + filename + '?')) return;
            const res = await fetch('/delete?file=' + encodeURIComponent(filename));
            const result = await res.text();
            alert(result);
            loadFiles();
        }
        
        async function downloadFile(filename) {
            window.open('/download?file=' + encodeURIComponent(filename), '_blank');
        }
        
        async function viewFile(filename) {
            const res = await fetch('/view?file=' + encodeURIComponent(filename));
            const content = await res.text();
            document.getElementById('viewContent').textContent = content;
            document.getElementById('viewModal').style.display = 'block';
        }
        
        async function executeCommand() {
            const cmd = document.getElementById('command').value;
            const res = await fetch('/exec', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command: cmd })
            });
            const result = await res.text();
            document.getElementById('terminalOutput').innerHTML += '> ' + cmd + '\\n' + result + '\\n';
            document.getElementById('terminalOutput').scrollTop = document.getElementById('terminalOutput').scrollHeight;
            document.getElementById('command').value = '';
        }
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            loadFiles();
            loadSystemInfo();
            document.getElementById('command').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') executeCommand();
            });
        });
        
        // Close modal
        function closeModal() {
            document.getElementById('viewModal').style.display = 'none';
        }
        
        // Upload with progress
        async function uploadFile() {
            const fileInput = document.getElementById('fileUpload');
            const formData = new FormData();
            
            for (let file of fileInput.files) {
                formData.append('files', file);
            }
            
            const xhr = new XMLHttpRequest();
            xhr.upload.addEventListener('progress', function(e) {
                if (e.lengthComputable) {
                    const percent = (e.loaded / e.total) * 100;
                    document.getElementById('progressBar').style.width = percent + '%';
                }
            });
            
            xhr.addEventListener('load', function() {
                alert('Upload complete!');
                loadFiles();
            });
            
            xhr.open('POST', '/upload');
            xhr.send(formData);
        }
        
        // Drag and drop
        const dragArea = document.getElementById('dragArea');
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dragArea.addEventListener(eventName, preventDefaults, false);
        });
        
        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }
        
        ['dragenter', 'dragover'].forEach(eventName => {
            dragArea.addEventListener(eventName, highlight, false);
        });
        
        ['dragleave', 'drop'].forEach(eventName => {
            dragArea.addEventListener(eventName, unhighlight, false);
        });
        
        function highlight() {
            dragArea.style.backgroundColor = '#0f3460';
        }
        
        function unhighlight() {
            dragArea.style.backgroundColor = 'transparent';
        }
        
        dragArea.addEventListener('drop', handleDrop, false);
        
        function handleDrop(e) {
            const dt = e.dataTransfer;
            const files = dt.files;
            document.getElementById('fileUpload').files = files;
            
            // Auto-upload
            uploadFile();
        }
        
        // Load functions
        async function loadFiles() {
            const res = await fetch('/list');
            const files = await res.json();
            
            let html = '<div class="file-list">';
            files.forEach(file => {
                const icon = file.isDir ? '📁' : file.name.endsWith('.js') ? '📜' : 
                             file.name.endsWith('.json') ? '📄' : '📄';
                const size = file.isDir ? '' : formatBytes(file.size);
                
                html += \`
                    <div class="file-item">
                        <div class="file-info">
                            <span class="file-icon">\${icon}</span>
                            <strong>\${file.name}</strong>
                            <span style="color: #888; margin-left: 10px;">\${size}</span>
                            <span style="color: #aaa; margin-left: 10px;">\${file.modified}</span>
                        </div>
                        <div class="file-actions">
                            \${!file.isDir ? \`<button class="btn btn-primary" onclick="viewFile('\${file.name}')">View</button>\` : ''}
                            \${!file.isDir ? \`<button class="btn btn-success" onclick="downloadFile('\${file.name}')">Download</button>\` : ''}
                            <button class="btn btn-danger" onclick="deleteFile('\${file.name}')">Delete</button>
                        </div>
                    </div>
                \`;
            });
            html += '</div>';
            document.getElementById('filesContent').innerHTML = html;
            
            // Update stats
            const totalSize = files.reduce((sum, file) => sum + file.size, 0);
            document.getElementById('stats').innerHTML = \`
                <div class="stat-card">📁 Files: \${files.length}</div>
                <div class="stat-card">💾 Total Size: \${formatBytes(totalSize)}</div>
                <div class="stat-card">👤 User: \${files[0]?.user || 'N/A'}</div>
                <div class="stat-card">📁 Current Dir: \${files[0]?.path || '.'}</div>
            \`;
        }
        
        async function loadSystemInfo() {
            const res = await fetch('/sysinfo');
            const info = await res.json();
            
            let html = '<table>';
            for (const [key, value] of Object.entries(info)) {
                html += \`<tr><td><strong>\${key}</strong></td><td>\${value}</td></tr>\`;
            }
            html += '</table>';
            document.getElementById('systemContent').innerHTML = html;
        }
        
        async function loadNetworkInfo() {
            const res = await fetch('/network');
            const info = await res.json();
            
            let html = '<h3>Network Interfaces</h3>';
            for (const [iface, details] of Object.entries(info.interfaces)) {
                html += \`<h4>\${iface}</h4><pre>\${JSON.stringify(details, null, 2)}</pre>\`;
            }
            
            html += '<h3>Connections</h3><pre>' + info.connections + '</pre>';
            document.getElementById('networkContent').innerHTML = html;
        }
        
        function formatBytes(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }
    </script>
</body>
</html>
`;

const server = http.createServer((req, res) => {
    // Authentication check for all routes except login
    if (req.url !== '/login' && !requireAuth(req, res)) {
        return;
    }
    
    // Route handling
    const url = new URL(req.url, `http://${req.headers.host}`);
    
    if (req.method === 'GET') {
        switch(url.pathname) {
            case '/':
            case '/login':
                serveDashboard(req, res);
                break;
            case '/list':
                listFiles(req, res);
                break;
            case '/view':
                viewFile(req, res);
                break;
            case '/download':
                downloadFile(req, res);
                break;
            case '/sysinfo':
                getSystemInfo(req, res);
                break;
            case '/network':
                getNetworkInfo(req, res);
                break;
            default:
                res.writeHead(404);
                res.end('Not Found');
        }
    } else if (req.method === 'POST') {
        switch(url.pathname) {
            case '/upload':
                handleUpload(req, res);
                break;
            case '/exec':
                handleCommand(req, res);
                break;
            case '/delete':
                handleDelete(req, res);
                break;
            default:
                res.writeHead(404);
                res.end('Not Found');
        }
    }
});

// Serve dashboard
function serveDashboard(req, res) {
    const content = `
        <div id="files" class="tab-content" style="display: block;">
            <h2>📂 File Browser</h2>
            <div id="filesContent">Loading files...</div>
        </div>
        
        <div id="terminal" class="tab-content" style="display: none;">
            <h2>💻 Terminal</h2>
            <div class="terminal" id="terminalOutput">$ ${os.userInfo().username}@${os.hostname()}</div>
            <div class="terminal-input">
                <input type="text" id="command" placeholder="Enter command (ls, pwd, cat, etc)">
                <button class="btn btn-primary" onclick="executeCommand()">Execute</button>
            </div>
        </div>
        
        <div id="upload" class="tab-content" style="display: none;">
            <h2>⬆️ File Upload</h2>
            <div class="drag-area" id="dragArea">
                <h3>Drag & Drop Files Here</h3>
                <p>or</p>
                <input type="file" id="fileUpload" multiple>
                <button class="btn btn-success" onclick="uploadFile()">Upload Files</button>
                <div class="upload-progress">
                    <div class="progress-bar" id="progressBar"></div>
                </div>
            </div>
        </div>
        
        <div id="system" class="tab-content" style="display: none;">
            <h2>📊 System Information</h2>
            <div id="systemContent">Loading system info...</div>
        </div>
        
        <div id="network" class="tab-content" style="display: none;">
            <h2>🌐 Network Information</h2>
            <div id="networkContent">Loading network info...</div>
        </div>
        
        <!-- View File Modal -->
        <div id="viewModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal()">&times;</span>
                <h3>File Content</h3>
                <pre id="viewContent"></pre>
            </div>
        </div>
    `;
    
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(htmlTemplate(content));
}

// List files in current directory
function listFiles(req, res) {
    const currentDir = process.cwd();
    fs.readdir(currentDir, { withFileTypes: true }, (err, files) => {
        if (err) {
            res.writeHead(500);
            res.end(JSON.stringify({ error: err.message }));
            return;
        }
        
        const fileList = files.map(file => ({
            name: file.name,
            isDir: file.isDirectory(),
            size: file.isDirectory() ? 0 : fs.statSync(path.join(currentDir, file.name)).size,
            modified: fs.statSync(path.join(currentDir, file.name)).mtime.toLocaleString(),
            path: currentDir,
            user: os.userInfo().username
        }));
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(fileList));
    });
}

// View file content
function viewFile(req, res) {
    const file = new URL(req.url, `http://${req.headers.host}`).searchParams.get('file');
    
    if (!file || file.includes('..')) {
        res.writeHead(400);
        res.end('Invalid filename');
        return;
    }
    
    fs.readFile(file, 'utf8', (err, data) => {
        if (err) {
            res.writeHead(500);
            res.end('Error reading file');
            return;
        }
        
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end(data);
    });
}

// Download file
function downloadFile(req, res) {
    const file = new URL(req.url, `http://${req.headers.host}`).searchParams.get('file');
    
    if (!file || file.includes('..')) {
        res.writeHead(400);
        res.end('Invalid filename');
        return;
    }
    
    if (!fs.existsSync(file)) {
        res.writeHead(404);
        res.end('File not found');
        return;
    }
    
    res.writeHead(200, {
        'Content-Type': 'application/octet-stream',
        'Content-Disposition': `attachment; filename="${path.basename(file)}"`
    });
    
    fs.createReadStream(file).pipe(res);
}

// Handle file upload
function handleUpload(req, res) {
    let body = [];
    req.on('data', chunk => body.push(chunk));
    req.on('end', () => {
        // Simple multipart parsing (for demo only)
        const data = Buffer.concat(body);
        const boundary = req.headers['content-type'].split('=')[1];
        const parts = data.toString().split(`--${boundary}`);
        
        parts.forEach(part => {
            if (part.includes('Content-Disposition: form-data')) {
                const match = part.match(/name="files"; filename="([^"]+)"/);
                if (match) {
                    const filename = match[1];
                    const contentStart = part.indexOf('\r\n\r\n') + 4;
                    const contentEnd = part.lastIndexOf('\r\n');
                    const fileContent = part.substring(contentStart, contentEnd);
                    
                    fs.writeFileSync(path.join(UPLOAD_DIR, filename), fileContent);
                }
            }
        });
        
        res.writeHead(200);
        res.end('Files uploaded successfully');
    });
}

// Execute command
function handleCommand(req, res) {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
        const { command } = JSON.parse(body);
        
        if (!command) {
            res.writeHead(400);
            res.end('No command provided');
            return;
        }
        
        // Security: limit dangerous commands
        const dangerous = ['rm -rf', 'mkfs', 'dd', 'shutdown', 'halt'];
        if (dangerous.some(cmd => command.includes(cmd))) {
            res.writeHead(403);
            res.end('Command not allowed');
            return;
        }
        
        exec(command, { timeout: 10000 }, (error, stdout, stderr) => {
            if (error) {
                res.writeHead(200);
                res.end(`Error: ${error.message}\n${stderr}`);
                return;
            }
            res.writeHead(200);
            res.end(stdout || stderr || 'Command executed (no output)');
        });
    });
}

// Get system information
function getSystemInfo(req, res) {
    const info = {
        'Hostname': os.hostname(),
        'Platform': os.platform(),
        'Architecture': os.arch(),
        'CPU Cores': os.cpus().length,
        'Total Memory': `${(os.totalmem() / 1024 / 1024 / 1024).toFixed(2)} GB`,
        'Free Memory': `${(os.freemem() / 1024 / 1024 / 1024).toFixed(2)} GB`,
        'Uptime': `${(os.uptime() / 3600).toFixed(2)} hours`,
        'User Info': os.userInfo().username,
        'Home Directory': os.homedir(),
        'Current Directory': process.cwd(),
        'Node Version': process.version,
        'Process ID': process.pid,
        'Load Average': os.loadavg().map(l => l.toFixed(2)).join(', ')
    };
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(info));
}

// Get network information
function getNetworkInfo(req, res) {
    exec('netstat -tulpn 2>/dev/null || ss -tulpn 2>/dev/null', (error, stdout) => {
        const info = {
            interfaces: os.networkInterfaces(),
            connections: stdout || 'No connection info available'
        };
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(info));
    });
}

// Delete file
function handleDelete(req, res) {
    const file = new URL(req.url, `http://${req.headers.host}`).searchParams.get('file');
    
    if (!file || file.includes('..')) {
        res.writeHead(400);
        res.end('Invalid filename');
        return;
    }
    
    fs.unlink(file, (err) => {
        if (err) {
            res.writeHead(500);
            res.end(`Error deleting file: ${err.message}`);
            return;
        }
        
        res.writeHead(200);
        res.end('File deleted successfully');
    });
}

// Start server
server.listen(PORT, () => {
    console.log(`
    📁 Node.js File Manager started!
    
    🔗 Local: http://localhost:${PORT}
    🌐 Network: http://YOUR_IP:${PORT}
    
    👤 Username: admin
    🔐 Password: ${PASSWORD}
    
    ⚠️  Change the password in the code!
    `);
    
    // Auto-open in browser (if on desktop)
    if (process.platform === 'darwin') {
        exec(`open http://localhost:${PORT}`);
    } else if (process.platform === 'win32') {
        exec(`start http://localhost:${PORT}`);
    } else if (process.platform === 'linux') {
        exec(`xdg-open http://localhost:${PORT}`);
    }
});
