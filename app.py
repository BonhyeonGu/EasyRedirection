from flask import Flask, redirect, request, jsonify, abort, render_template
import json
import os
import hashlib

app = Flask(__name__)
JSON_FILE = './vol/routes.json'
PASSWORD_FILE = './vol/password.txt'

# 비밀번호 파일에서 비밀번호 해시를 가져옵니다.
def load_password_hash():
    if not os.path.exists(PASSWORD_FILE):
        raise FileNotFoundError(f"Password file '{PASSWORD_FILE}' not found.")
    with open(PASSWORD_FILE, 'r') as file:
        password = file.read().strip()
    return hashlib.sha256(password.encode()).hexdigest()

PASSWORD_HASH = load_password_hash()


def readJson():
    if not os.path.exists(JSON_FILE):
        with open(JSON_FILE, 'w') as file:
            json.dump({}, file, indent=4)
    with open(JSON_FILE, 'r') as file:
        return json.load(file)


def writeJson(routes):
    with open(JSON_FILE, 'w') as file:
        json.dump(routes, file, indent=4)


@app.route('/')
def index():
    routes = readJson()
    return render_template('index.html', routes=routes)


@app.route('/update-routes', methods=['POST'])
def update_routes():
    data = request.get_json()
    if not isinstance(data, dict) or 'password' not in data or 'routes' not in data:
        return jsonify({"error": "Invalid request format."}), 400

    # 비밀번호 확인
    password = data['password']
    if hashlib.sha256(password.encode()).hexdigest() != PASSWORD_HASH:
        return jsonify({"error": "Invalid password."}), 403

    new_routes = data['routes']
    if not isinstance(new_routes, dict):
        return jsonify({"error": "The provided routes data must be a JSON object."}), 400

    writeJson(new_routes)
    return jsonify({"message": "Routes have been updated successfully."})


@app.route('/<path:subpath>')
def dynamic_redirect(subpath):
    routes = readJson()
    if subpath in routes:
        destination = routes[subpath].get("url")
        if destination:
            return redirect(destination)
    return abort(404)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)