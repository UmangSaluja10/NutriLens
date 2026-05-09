import os
import gdown
from config import MODEL_PATH, MODEL_DOWNLOAD_URL


def download_model_if_missing():
    """
    Downloads the Keras model from Google Drive if not already present.
    Called once at server startup before the model is loaded.
    Uses gdown which handles Google Drive's virus-scan confirmation automatically.
    """
    if os.path.exists(MODEL_PATH):
        size_mb = os.path.getsize(MODEL_PATH) / (1024 * 1024)
        print(f"[ModelDownloader] Model already exists ({size_mb:.1f} MB). Skipping download.")
        return

    print("[ModelDownloader] Model not found. Starting download from Google Drive...")
    os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)

    try:
        # Extract file ID from the URL
        if "id=" in MODEL_DOWNLOAD_URL:
            file_id = MODEL_DOWNLOAD_URL.split("id=")[-1].split("&")[0]
        else:
            # Handle /file/d/ID/view format
            file_id = MODEL_DOWNLOAD_URL.split("/d/")[1].split("/")[0]

        print(f"[ModelDownloader] Downloading file ID: {file_id}")

        gdown.download(
            id=file_id,
            output=MODEL_PATH,
            quiet=False,        # shows progress bar in logs
            fuzzy=True,         # handles various Google Drive URL formats
        )

        size_mb = os.path.getsize(MODEL_PATH) / (1024 * 1024)
        print(f"[ModelDownloader] Download complete! Model size: {size_mb:.1f} MB")

    except Exception as e:
        print(f"[ModelDownloader] ERROR: Download failed — {e}")
        print("[ModelDownloader] The /predict endpoint will not work without the model.")
        # Don't crash the server — health endpoint still works