from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import speech_recognition as sr
import numpy as np
import tensorflow as tf
import pickle
import re
from tensorflow.keras.preprocessing.sequence import pad_sequences
from proper_deepfake import DeepfakeDetector
import tempfile
import socket

socket.setdefaulttimeout(3000)

app = Flask(__name__)
CORS(app)

intent_to_icon = {
    "pay via QR code": "1001",      # pay via QR code
    "pay via contacts": "1002",     # pay via contacts
    "pay via UPI ID": "1003",       # pay via UPI ID
    "transaction history": "1004",  # transaction history
    "show my QR code": "1005",      # show my QR code
    "pay to self": "1006",          # pay to self
    "pay via number": "1007",       # pay via number
    "bank_transfer": "1008",        # bank_transfer
}

# Initialize variables
intent_model = None
tokenizer = None
label_encoder = None
max_length = None
entity_model = None
deepfake_detector = None

def load_models():
    """Load all required models and data."""
    global intent_model, tokenizer, label_encoder, max_length, entity_model, deepfake_detector
    
    try:
        # Load intent model
        intent_model = tf.keras.models.load_model("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/intent/updated_intent_model.h5")
        print("✅ Intent model loaded successfully")

        # Load tokenizer
        with open("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/intent/tokenizer.pkl", "rb") as handle:
            tokenizer = pickle.load(handle)
        print("✅ Tokenizer loaded successfully")

        # Load label encoder
        with open("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/intent/label_encoder.pkl", "rb") as handle:
            label_encoder = pickle.load(handle)
        print("✅ Label encoder loaded successfully")
        print("Available labels:", label_encoder.classes_)

        # Load max length
        with open("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/intent/max_length.pkl", "rb") as handle:
            max_length = pickle.load(handle)
        print("✅ Max length loaded successfully")

        # Load entity model
        entity_model = tf.keras.models.load_model("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/intent/updated_entity_model.h5")
        print("✅ Entity model loaded successfully")

        # Initialize deepfake detector
        deepfake_detector = DeepfakeDetector()
        print("✅ Deepfake detector initialized successfully")

    except Exception as e:
        print(f"❌ Error loading models: {str(e)}")
        raise

# Load models when the app starts
try:
    load_models()
except Exception as e:
    print(f"Failed to load models: {str(e)}")
    # You might want to handle this error differently based on your needs


def speech_to_text():
    """Record speech and return text + audio file path."""
    recognizer = sr.Recognizer()

    with sr.Microphone() as source:
        print("\n🎤 Speak now...")
        recognizer.adjust_for_ambient_noise(source)
        audio = recognizer.listen(source)

    audio_file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav").name

    # Save audio to a file
    with open(audio_file, "wb") as f:
        f.write(audio.get_wav_data())

    try:
        text = recognizer.recognize_google(audio).lower()
        print(f"📢 Recognized: {text}")
        return text, audio_file
    except sr.UnknownValueError:
        print("❌ Could not understand audio.")
        return "", audio_file
    except sr.RequestError:
        print("⚠️ Speech Recognition service unavailable.")
        return "", audio_file


def verify_voice(audio_file):
    """Verify if the audio is deepfake or real."""
    result = deepfake_detector.predict_audio_deepfake(audio_file)
    if result == "FAKE(AI Voice)":
        print("🚨 Deepfake detected.")
        return False, "Deepfake detected"
    
    print("✅ Voice verified as REAL(Human Voice).")
    return True, "Voice verified as REAL"


def classify_intent(text):
    """Classify the intent from the recognized text."""
    sequence = tokenizer.texts_to_sequences([text])
    padded_sequence = pad_sequences(sequence, maxlen=max_length, padding="post")
    prediction = intent_model.predict(padded_sequence)

    predicted_label = np.argmax(prediction)
    intent = label_encoder.inverse_transform([predicted_label])[0]
    confidence = np.max(prediction)

    if confidence > 0.6:
        return intent, confidence
    else:
        return "Unknown", confidence


def extract_entities(text):
    """Extract entities using ML and regex."""
    sequence = tokenizer.texts_to_sequences([text])
    padded_sequence = pad_sequences(sequence, maxlen=max_length, padding="post")
    prediction = entity_model.predict(padded_sequence)

    extracted_entities = {}

    # Regex-based entity extraction
    amount_match = re.search(r"(\$?\d+)", text)  # Extract amounts (e.g., $100, 50)
    if amount_match:
        extracted_entities["amount"] = amount_match.group(1)

    recipient_match = re.search(r"to (\w+)", text)  # Extract recipient names
    if recipient_match:
        extracted_entities["recipient"] = recipient_match.group(1)

    return extracted_entities


@app.route("/")
def home():
    """Welcome route."""
    return jsonify({"message": "Welcome to the Deepfake Detection, Intent Recognition, and Entity Extraction API"})


@app.route("/process_audio", methods=["POST"])
def process_audio():
    """Process uploaded audio file for deepfake detection, intent, and entities."""
    global intent_to_icon
    temp_audio_file = None
    try:
        # Check if models are loaded
        if not all([intent_model, tokenizer, label_encoder, max_length, entity_model, deepfake_detector]):
            print("❌ Models not loaded properly")
            return jsonify({
                "error": "Models not loaded. Please restart the server."
            }), 503

        if "audio" not in request.files:
            print("❌ No audio file in request")
            return jsonify({"error": "No audio file provided"}), 400

        # Save the uploaded audio file
        audio = request.files["audio"]
        if audio.filename == '':
            print("❌ No selected file")
            return jsonify({"error": "No selected file"}), 400
            
        print(f"📥 Received audio file: {audio.filename}")
        
        # Create temp directory if it doesn't exist
        temp_dir = tempfile.gettempdir()
        temp_audio_file = os.path.join(temp_dir, f"audio_{os.urandom(4).hex()}.wav")
        
        try:
            audio.save(temp_audio_file)
            print(f"✅ Saved audio to: {temp_audio_file}")
        except Exception as e:
            print(f"❌ Error saving audio file: {str(e)}")
            return jsonify({
                "error": "Failed to save audio file. Please try again."
            }), 500

        # Step 1: Verify if the audio is deepfake
        print("🔍 Verifying voice...")
        try:
            is_real, verification_msg = verify_voice(temp_audio_file)
        except Exception as e:
            print(f"❌ Error during voice verification: {str(e)}")
            return jsonify({
                "error": "Failed to verify voice. Please try again."
            }), 500

        if not is_real:
            print("❌ Deepfake detected")
            if os.path.exists(temp_audio_file):
                os.remove(temp_audio_file)
            return jsonify({
                "result": "Deepfake detected",
                "message": verification_msg
            }), 403

        # Step 2: Convert speech to text
        print("🎤 Converting speech to text...")
        recognizer = sr.Recognizer()
        
        try:
            with sr.AudioFile(temp_audio_file) as source:
                print("📂 Reading audio file...")
                audio = recognizer.record(source)
                print("🎯 Attempting transcription...")
                text = recognizer.recognize_google(audio).lower()
                print(f"✅ Transcribed text: {text}")
        except sr.UnknownValueError:
            print("❌ Could not understand audio")
            if os.path.exists(temp_audio_file):
                os.remove(temp_audio_file)
            return jsonify({
                "error": "Could not understand audio. Please speak clearly."
            }), 400
        except sr.RequestError as e:
            print(f"❌ Speech recognition service error: {e}")
            if os.path.exists(temp_audio_file):
                os.remove(temp_audio_file)
            return jsonify({
                "error": "Speech recognition service unavailable. Please try again."
            }), 503
        except Exception as e:
            print(f"❌ Error during transcription: {str(e)}")
            if os.path.exists(temp_audio_file):
                os.remove(temp_audio_file)
            return jsonify({
                "error": f"Transcription error: {str(e)}"
            }), 500

        if not text:
            print("❌ No text was recognized")
            if os.path.exists(temp_audio_file):
                os.remove(temp_audio_file)
            return jsonify({
                "error": "No text was recognized from the audio"
            }), 400

        # Step 3: Intent Classification
        print("🔍 Classifying intent...")
        try:
            detected_intent, confidence = classify_intent(text)
            print(f"✅ Detected intent: {detected_intent} with confidence: {confidence}")
        except Exception as e:
            print(f"❌ Error during intent classification: {str(e)}")
            if os.path.exists(temp_audio_file):
                os.remove(temp_audio_file)
            return jsonify({
                "error": "Failed to classify intent. Please try again."
            }), 500
        
        icon_code = intent_to_icon.get(detected_intent, None)

        # Step 4: Entity Extraction
        print("🔍 Extracting entities...")
        try:
            detected_entities = extract_entities(text)
            print(f"✅ Extracted entities: {detected_entities}")
        except Exception as e:
            print(f"❌ Error during entity extraction: {str(e)}")
            if os.path.exists(temp_audio_file):
                os.remove(temp_audio_file)
            return jsonify({
                "error": "Failed to extract entities. Please try again."
            }), 500

        # Clean up temp audio file
        if os.path.exists(temp_audio_file):
            try:
                os.remove(temp_audio_file)
                print("🧹 Cleaned up temporary file")
            except Exception as e:
                print(f"⚠️ Warning: Failed to remove temporary file: {str(e)}")

        # Return JSON response
        response = {
            "intent": detected_intent,
            "confidence": float(confidence),
            "entities": detected_entities,
            "deepfake_verification": verification_msg,
            "text": text,
            "icon_code": icon_code 
        }
        print("icon code:",icon_code)
        print("✅ Successfully processed audio")
        return jsonify(response), 200

    except Exception as e:
        print(f"❌ Error processing audio: {str(e)}")
        import traceback
        print(f"Stack trace: {traceback.format_exc()}")
        if temp_audio_file and os.path.exists(temp_audio_file):
            try:
                os.remove(temp_audio_file)
            except Exception as cleanup_error:
                print(f"⚠️ Warning: Failed to remove temporary file: {str(cleanup_error)}")
        return jsonify({
            "error": f"An error occurred while processing the audio: {str(e)}"
        }), 500


if __name__ == "__main__":
    app.run(host="192.168.29.32", port=5001, debug=True)
