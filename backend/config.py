import os

# Base directory of the backend
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Model paths
MODEL_PATH = os.path.join(BASE_DIR, "model", "food_nutrition_model.keras")
CLASS_NAMES_PATH = os.path.join(BASE_DIR, "model", "class_names.json")
NUTRITION_DATA_PATH = os.path.join(BASE_DIR, "model", "nutrition_data.json")

# Image settings (must match what you trained with)
IMG_SIZE = 224