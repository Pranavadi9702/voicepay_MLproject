import pandas as pd
import numpy as np
import tensorflow as tf
import pickle
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from sklearn.preprocessing import LabelEncoder

# ✅ Load dataset
df = pd.read_csv("/Users/dhavalbhagat/Desktop/VoicePay/thackur/python/intent/main_intent_dataset.csv")  

# ✅ Extract columns
utterances = df["Utterance"].values
intents = df["Intent"].values

# ✅ Encode labels (convert intent categories into numbers)
label_encoder = LabelEncoder()
encoded_labels = label_encoder.fit_transform(intents)

# ✅ Tokenize text data
tokenizer = Tokenizer(num_words=5000, oov_token="<OOV>")
tokenizer.fit_on_texts(utterances)
sequences = tokenizer.texts_to_sequences(utterances)

# ✅ Pad sequences to ensure uniform input size

max_length = max(len(seq) for seq in sequences)  # Get max sequence length
padded_sequences = pad_sequences(sequences, maxlen=max_length, padding="post")

# ✅ Save tokenizer, label encoder, and max_length
with open("tokenizer.pkl", "wb") as handle:
    pickle.dump(tokenizer, handle)

with open("label_encoder.pkl", "wb") as handle:
    pickle.dump(label_encoder, handle)

with open("max_length.pkl", "wb") as handle:
    pickle.dump(max_length, handle)

# ✅ Define the model
model = tf.keras.models.Sequential([
    tf.keras.layers.Embedding(input_dim=5000, output_dim=32, input_length=max_length),
    tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(32, return_sequences=True)),  # LSTM for better accuracy
    tf.keras.layers.GlobalAveragePooling1D(),
    tf.keras.layers.Dense(32, activation="relu"),
    tf.keras.layers.Dense(len(set(intents)), activation="softmax")  
])

# ✅ Compile the model
model.compile(loss="sparse_categorical_crossentropy", optimizer="adam", metrics=["accuracy"])

# ✅ Train the model
model.fit(padded_sequences, np.array(encoded_labels), epochs=15, validation_split=0.2, batch_size=16)

# ✅ Save the trained model
model.save("updated_entity_model.h5")
print("✅ Model trained and saved as intent_model.h5 🎯")
