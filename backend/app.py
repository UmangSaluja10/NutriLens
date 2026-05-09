import os
from flask import Flask
from flask_cors import CORS
from model_downloader import download_model_if_missing

# Download model BEFORE importing predictor
# (predictor.py loads the model at import time)
download_model_if_missing()

from routes.predict import predict_bp
from routes.health import health_bp

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

app.register_blueprint(predict_bp)
app.register_blueprint(health_bp)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=False, host="0.0.0.0", port=port)