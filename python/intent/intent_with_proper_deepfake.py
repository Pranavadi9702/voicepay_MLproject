import os
import speech_recognition as sr
import numpy as np
import librosa
import tensorflow as tf
import pickle
import re
from tensorflow.keras.preprocessing.sequence import pad_sequences
from proper_deepfake import DeepfakeDetector

intent_model = tf.keras.models.load_model("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/intent/updated_intent_model.h5")

with open("tokenizer.pkl", "rb") as handle:
    tokenizer = pickle.load(handle)

with open("label_encoder.pkl", "rb") as handle:
    label_encoder = pickle.load(handle)

with open("max_length.pkl", "rb") as handle:
    max_length = pickle.load(handle)


entity_model = tf.keras.models.load_model("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/intent/updated_entity_model.h5")


deepfake_detector = DeepfakeDetector("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/best_deepfake_model.keras")


def speech_to_text():
    recognizer = sr.Recognizer()
    with sr.Microphone() as source:
        print("\n🎤 Speak now...")
        recognizer.adjust_for_ambient_noise(source)
        audio = recognizer.listen(source)

    audio_file = "temp_voice_command.wav"
    
    # Save the audio to a file
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
    result = deepfake_detector.predict_audio_deepfake(audio_file)
    if result == "FAKE(AI Voice)":
        print("🚨 Deepfake detected. Terminating process.")
        return False
    print("✅ Voice verified as REAL(Human Voice). Proceeding to intent recognition.")
    return True


def classify_intent(text):
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
    # ML-based entity extraction
    sequence = tokenizer.texts_to_sequences([text])
    padded_sequence = pad_sequences(sequence, maxlen=max_length, padding="post")
    prediction = entity_model.predict(padded_sequence)

    extracted_entities = {}

    amount_match = re.search(r"(\$?\d+)", text)  
    if amount_match:
        extracted_entities["amount"] = amount_match.group(1)

    recipient_match = re.search(r"to (\w+)", text)  
    if recipient_match:
        extracted_entities["recipient"] = recipient_match.group(1)

    return extracted_entities


def main():
    print("\n🔹 **Voice Command Execution** 🔹\n")

    while True:
        input("\n🔵 Press Enter to record a command...")

        # Step 1: Record Speech and Save as Audio File
        user_text, audio_file = speech_to_text()

        if user_text:
            # Step 2: Deepfake Verification
            if not verify_voice(audio_file):
                print("❌ Exiting due to Deepfake detection.")
                continue

            # Step 3: Intent Recognition
            detected_intent, confidence = classify_intent(user_text)

            # Step 4: Entity Extraction
            detected_entities = extract_entities(user_text)

            print(f"\n✅ Detected Intent: '{detected_intent}' (Confidence: {confidence:.2f}) 🚀")

            # Display extracted entities
            if detected_entities:
                print("\n🔍 Extracted Entities:")
                for key, value in detected_entities.items():
                    print(f"   ➤ {key.capitalize()}: {value}")
            else:
                print("🔍 No entities detected.")

            # Handle unknown intent
            if detected_intent == "Unknown":
                print("🤔 Sorry, I couldn't understand your intent clearly.")
            else:
                print(f"🎯 Recognized Intent: {detected_intent} with {confidence:.2f} confidence")

        else:
            print("❌ No speech detected. Try again.")


if __name__ == "__main__":
    main()
