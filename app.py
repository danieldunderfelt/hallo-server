from flask import Flask, request, render_template, jsonify
import os
import subprocess
from datetime import datetime

app = Flask(__name__)
UPLOAD_FOLDER = '/app/uploads'
OUTPUT_FOLDER = '/app/output'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@app.route('/')
def upload_form():
    return render_template('upload.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'source_image' not in request.files or 'driving_audio' not in request.files:
        return jsonify({'status': 'error', 'message': 'No file part'})

    source_image = request.files['source_image']
    driving_audio = request.files['driving_audio']

    if source_image.filename == '' or driving_audio.filename == '':
        return jsonify({'status': 'error', 'message': 'No selected file'})

    source_image_path = os.path.join(UPLOAD_FOLDER, source_image.filename)
    driving_audio_path = os.path.join(UPLOAD_FOLDER, driving_audio.filename)

    source_image.save(source_image_path)
    driving_audio.save(driving_audio_path)

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    output_video = f"{OUTPUT_FOLDER}/{timestamp}.mp4"

    # Run the inference script
    result = subprocess.run(
        ['python', 'scripts/inference.py', '--source_image', source_image_path, '--driving_audio', driving_audio_path, "--output", output_video,],
        capture_output=True,
        text=True
    )

    if result.returncode == 0:
        return jsonify({'status': 'success', 'output_url': f'http://localhost:5000/app/{timestamp}.mp4'})
    else:
        return jsonify({'status': 'error', 'message': result.stderr})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
