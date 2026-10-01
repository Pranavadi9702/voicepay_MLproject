import numpy as np
import pandas as pd
import librosa
import os
from tensorflow.keras.models import load_model
from sklearn.preprocessing import StandardScaler
import joblib  # For loading the saved scaler

# Load the trained model
MODEL_PATH = "deepfake_voice_detector.h5"
model = load_model(MODEL_PATH)

# Load the saved scaler for consistent feature scaling
SCALER_PATH = "scaler.pkl"
scaler = joblib.load(SCALER_PATH)

# =========================
# Feature Extraction Function
# =========================
def extract_features_from_audio(file_path):
    try:
        y, sr = librosa.load(file_path, sr=None)  # Load audio file
        features = {
            'chroma_stft': np.mean(librosa.feature.chroma_stft(y=y, sr=sr)),
            'rms': np.mean(librosa.feature.rms(y=y)),
            'spectral_centroid': np.mean(librosa.feature.spectral_centroid(y=y, sr=sr)),
            'spectral_bandwidth': np.mean(librosa.feature.spectral_bandwidth(y=y, sr=sr)),
            'rolloff': np.mean(librosa.feature.spectral_rolloff(y=y, sr=sr)),
            'zero_crossing_rate': np.mean(librosa.feature.zero_crossing_rate(y))
        }

        # Extract 20 MFCCs (same as your dataset's MFCC features)
        mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=20)
        for i in range(20):
            features[f'mfcc{i+1}'] = np.mean(mfccs[i])

        # Convert features into a DataFrame for scaling
        features_df = pd.DataFrame([features])
        features_scaled = scaler.transform(features_df)

        return features_scaled
    except Exception as e:
        print(f"Error extracting features from {file_path}: {e}")
        return None

# =========================
# Prediction Function
# =========================
def predict_audio_deepfake(file_path):
    features = extract_features_from_audio(file_path)
    if features is not None:
        prediction = model.predict(features)
        result = "Real" if prediction[0][0] < 0.5 else "Fake"
        print(f"Prediction for {os.path.basename(file_path)}: {result}")
    else:
        print("Failed to extract features. Please check the audio file.")

# =========================
# Batch Prediction for Multiple Files
# =========================
def batch_predict(folder_path):
    for filename in os.listdir(folder_path):
        if filename.endswith(".mp3") or filename.endswith(".wav"):
            predict_audio_deepfake(os.path.join(folder_path, filename))

# Example usage
if __name__ == "__main__":
    AUDIO_PATH = r"C:\Users\prana\OneDrive\Desktop\thackur\thackur\backend\Standard recording 1.mp3"
    predict_audio_deepfake(AUDIO_PATH)

    # For batch prediction
    AUDIO_FOLDER_PATH = r"C:\Users\prana\OneDrive\Desktop\thackur\thackur\backend\test_audios"
    batch_predict(AUDIO_FOLDER_PATH)
