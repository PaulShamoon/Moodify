from flask import Flask, request, jsonify
from deepface import DeepFace
import cv2
import numpy as np

app = Flask(__name__)

@app.route('/analyze', methods=['POST'])
def analyze():
    try:
        # Read the uploaded image from the request
        file = request.files['image']
        image = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(image, cv2.IMREAD_COLOR)

        # Perform emotion analysis on the image from user
        result = DeepFace.analyze(img, actions=['emotion'])

        emotion_probabilities = result[0]['emotion']
        total = sum(emotion_probabilities.values())
        normalized_probabilities = {k: (v / total) for k, v in emotion_probabilities.items()}

        #Main emotion (the emotion that is predicted with the highest probability) is the dominant emotion!
        emotion = result[0]['dominant_emotion']

        return jsonify({
            'emotion': emotion,
            'probabilities': normalized_probabilities
        }), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)