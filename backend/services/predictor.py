import numpy as np
import tensorflow as tf
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
import json
from config import MODEL_PATH, CLASS_NAMES_PATH, IMG_SIZE

# Load model and class names ONCE at startup (not on every request)
print("[Predictor] Loading model...")
model = tf.keras.models.load_model(MODEL_PATH)
print("[Predictor] Model loaded successfully.")

with open(CLASS_NAMES_PATH, "r") as f:
    class_names = json.load(f)
print(f"[Predictor] Loaded {len(class_names)} class names.")


def predict_from_bytes(image_bytes: bytes) -> dict:
    """
    Takes raw image bytes, preprocesses them, runs inference.
    Returns predicted food name and confidence score.
    """
    import io
    from PIL import Image

    # Open image from bytes
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((IMG_SIZE, IMG_SIZE))

    # Convert to array and preprocess (same as training)
    img_array = np.array(img, dtype=np.float32)
    img_array = np.expand_dims(img_array, axis=0)          # shape: (1, 224, 224, 3)
    img_array = preprocess_input(img_array)                 # MobileNetV2 normalization

    # Run inference
    prediction = model.predict(img_array, verbose=0)
    predicted_index = int(np.argmax(prediction))
    confidence = float(np.max(prediction))
    predicted_food = class_names[predicted_index]

    return {
        "food": predicted_food,
        "confidence": round(confidence, 4)
    }