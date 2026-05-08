from flask import Blueprint, jsonify
from services.predictor import model, class_names

health_bp = Blueprint("health", __name__)


@health_bp.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "model_loaded": model is not None,
        "classes_loaded": len(class_names)
    }), 200