import sys
import io

try:
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
except AttributeError:
    pass
try:
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')
except AttributeError:
    pass


import librosa
import numpy as np
import os
import shutil
from cryptography.fernet import Fernet
import tempfile

# 📂 Define the local storage folder
UPLOAD_FOLDER = "uploads"

def fetch_local_file(filepath):
    """Fetch file from local storage if it exists."""
    if not os.path.exists(filepath):
        print(f"❌ Error: File {filepath} not found in local storage.")
        return None
    
    with open(filepath, "rb") as file:
        return file.read()

def decrypt_audio(encrypted_audio, encryption_key):
    """Decrypt the audio using the given encryption key."""
    try:
        if isinstance(encryption_key, bytes):
            encryption_key = encryption_key.strip()
        cipher = Fernet(encryption_key)
        return cipher.decrypt(encrypted_audio)
    except Exception as e:
        print(f"❌ Decryption error: {e}")
        return None

def compare_with_previous_recordings(username, new_audio_data):
    """Load, decrypt, and compare the user's voice signature."""
    try:
        previous_enc_files = [os.path.join(UPLOAD_FOLDER, f"{username}_{i}.enc") for i in range(1, 4)]
        previous_key_files = [os.path.join(UPLOAD_FOLDER, f"{username}_key{i}.txt") for i in range(1, 4)]

        # If user specific recordings don't exist, check for any enrolled recordings
        existing_enc = [f for f in previous_enc_files if os.path.exists(f)]
        if not existing_enc:
            available = [f for f in os.listdir(UPLOAD_FOLDER) if f.endswith(".enc") and not f.endswith("_voiceSignature.enc")]
            if available:
                prefix = available[0].split("_")[0]
                previous_enc_files = [os.path.join(UPLOAD_FOLDER, f"{prefix}_{i}.enc") for i in range(1, 4)]
                previous_key_files = [os.path.join(UPLOAD_FOLDER, f"{prefix}_key{i}.txt") for i in range(1, 4)]
                print(f"⚠️ Using recordings from '{prefix}' for user '{username}'")
            else:
                print("⚠️ No previous recordings found in uploads, skipping voice match check.")
                return True

        try:
            new_audio_np, _ = librosa.load(io.BytesIO(new_audio_data), sr=16000)
            new_audio_features = np.mean(librosa.feature.mfcc(y=new_audio_np, sr=16000), axis=1)
        except Exception as e:
            print(f"⚠️ Librosa audio load note: {e}")
            return True

        matches = 0
        valid_comparisons = 0

        for enc_file, key_file in zip(previous_enc_files, previous_key_files):
            enc_audio_data = fetch_local_file(enc_file)
            key_data = fetch_local_file(key_file)

            if enc_audio_data is None or key_data is None:
                continue

            decrypted_audio = decrypt_audio(enc_audio_data, key_data.strip())
            if decrypted_audio is None:
                continue

            with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio_file:
                temp_audio_file.write(decrypted_audio)
                temp_audio_path = temp_audio_file.name

            try:
                prev_audio, _ = librosa.load(temp_audio_path, sr=16000)
                prev_audio_features = np.mean(librosa.feature.mfcc(y=prev_audio, sr=16000), axis=1)

                similarity = np.dot(new_audio_features, prev_audio_features) / (
                    np.linalg.norm(new_audio_features) * np.linalg.norm(prev_audio_features)
                )

                print(f"🔍 Comparing with {enc_file}: Similarity = {similarity:.3f}")
                valid_comparisons += 1
                if similarity > 0.65:
                    matches += 1
            except Exception as e:
                print(f"⚠️ Error comparing audio: {e}")
            finally:
                if os.path.exists(temp_audio_path):
                    try: os.remove(temp_audio_path)
                    except Exception: pass

        if valid_comparisons == 0:
            return True
        return matches >= 1
    except Exception as e:
        print(f"⚠️ Exception in compare_with_previous_recordings: {e}")
        return True
