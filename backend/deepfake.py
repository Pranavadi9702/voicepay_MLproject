import pandas as pd
import numpy as np
import librosa
import os
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.models import Sequential, load_model

# Load dataset
CSV_PATH = "C:/Users/prana/OneDrive/Desktop/thackur/thackur/backend/KAGGLE/DATASET-balanced.csv"

# Load CSV file
df = pd.read_csv(CSV_PATH)

# Separate features and labels
X = df.drop('LABEL', axis=1).values   # Extract all features
y = df['LABEL'].values                # Extract labels

# Encode labels (convert 'real' and 'fake' into 0 and 1)
label_encoder = LabelEncoder()
y = label_encoder.fit_transform(y)

# Data normalization (essential for better convergence)
scaler = StandardScaler()
X = scaler.fit_transform(X)

# Split dataset into train and test sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Model architecture
model = Sequential([
    layers.Input(shape=(X_train.shape[1],)),   # Input layer
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.3),
    layers.Dense(64, activation='relu'),
    layers.Dropout(0.3),
    layers.Dense(32, activation='relu'),
    layers.Dense(1, activation='sigmoid')      # Sigmoid for binary classification
])

# Compile the model
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Model training
history = model.fit(X_train, y_train, epochs=30, batch_size=32, validation_split=0.2)

# Model evaluation
test_loss, test_accuracy = model.evaluate(X_test, y_test)
print(f"Test Accuracy: {test_accuracy * 100:.2f}%")

# Save the model
model.save("deepfake_voice_detector.h5")

# Predict and check sample outputs
sample_prediction = model.predict(X_test[:5])
print(f"Sample Predictions: {np.round(sample_prediction).flatten()}")

# Inference function
def predict_deepfake(features):
    features = np.array(features).reshape(1, -1)  # Reshape for model input
    features = scaler.transform(features)         # Normalize
    prediction = model.predict(features)
    return "Real" if prediction[0][0] < 0.5 else "Fake"

# Example usage
sample_features = X_test[0]  # Use a sample from test data
print(f"Prediction for sample: {predict_deepfake(sample_features)}")

# =========================
# New Function for Audio File Upload
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
        print(f"Error extracting features: {e}")
        return None

# Function to predict audio deepfake
def predict_audio_deepfake(file_path):
    features = extract_features_from_audio(file_path)
    if features is not None:
        prediction = model.predict(features)
        result = "Real" if prediction[0][0] < 0.5 else "Fake"
        print(f"Prediction for {os.path.basename(file_path)}: {result}")
    else:
        print("Failed to extract features. Please check the audio file.")

# Example usage
AUDIO_PATH = r"C:\Users\prana\OneDrive\Desktop\thackur\thackur\backend\Standard recording 1.mp3"
predict_audio_deepfake(AUDIO_PATH)
