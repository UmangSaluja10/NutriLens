import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_PATH          = os.path.join(BASE_DIR, "model", "food_nutrition_model.keras")
CLASS_NAMES_PATH    = os.path.join(BASE_DIR, "model", "class_names.json")
NUTRITION_DATA_PATH = os.path.join(BASE_DIR, "model", "nutrition_data.json")

IMG_SIZE = 224

# Set this as an environment variable on Railway
# Format: https://drive.google.com/uc?export=download&id=YOUR_FILE_ID
MODEL_DOWNLOAD_URL = os.environ.get(
    "MODEL_DOWNLOAD_URL",
    "https://drive.google.com/uc?export=1XqLzOPLY4cm7B3Otu3fJLmrmPlIOWeNO"
)