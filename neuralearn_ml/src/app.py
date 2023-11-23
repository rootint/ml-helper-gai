from flask import Flask, request, abort, jsonify
from script import generate

app = Flask(__name__)

@app.route('/')
def index():
    return "Hello, World!"

@app.route('/api/v1/model/v1/send', methods=['POST'])
def model_send():
    if not request.json or not 'prompt' in request.json:
        abort(400)
    
    prompt = request.json['prompt']
    answer = generate(prompt)
    return jsonify({'answer': answer}), 200

if __name__ == '__main__':
    app.run(debug=True)