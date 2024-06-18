from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/animate', methods=['POST'])
def animate():
    data = request.json
    source_image = data['source_image']
    driving_audio = data['driving_audio']

    # Run the inference script
    result = subprocess.run(
        ['python', 'scripts/inference.py', '--source_image', source_image, '--driving_audio', driving_audio],
        capture_output=True,
        text=True
    )

    if result.returncode == 0:
        return jsonify({'status': 'success', 'output': '/app/.cache/output.mp4'})
    else:
        return jsonify({'status': 'error', 'message': result.stderr})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
