from flask import Flask, request, render_template, jsonify
import os, json
from datetime import datetime

app = Flask(__name__)
DATA_FILE = 'miners.json'

@app.route('/')
def index():
    data = {}
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE) as f:
            data = json.load(f)
    return render_template('index.html', miners=data)

@app.route('/report', methods=['POST'])
def report():
    info = request.json
    info['timestamp'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    data = {}

    if os.path.exists(DATA_FILE):
        with open(DATA_FILE) as f:
            data = json.load(f)

    data[info['worker']] = info

    with open(DATA_FILE, 'w') as f:
        json.dump(data, f, indent=2)
    return jsonify({"status": "ok"})
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050)
