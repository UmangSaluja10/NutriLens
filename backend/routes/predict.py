from flask import Blueprint, request, jsonify
from services.predictor import predict_from_bytes
from services.nutrition_service import get_nutrition

predict_bp = Blueprint("predict", __name__)


@predict_bp.route("/predict", methods=["POST"])
def predict():
    # 1. Validate image is present
    if "image" not in request.files:
        return jsonify({"error": "No image provided. Send image as multipart/form-data with key 'image'."}), 400

    image_file = request.files["image"]

    if image_file.filename == "":
        return jsonify({"error": "Empty filename. Please select an image."}), 400

    # 2. Read image bytes (image is NOT saved to disk)
    image_bytes = image_file.read()

    # 3. Run prediction
    try:
        result = predict_from_bytes(image_bytes)
    except Exception as e:
        return jsonify({"error": f"Prediction failed: {str(e)}"}), 500

    # 4. Get nutrition data
    nutrition = get_nutrition(result["food"])

    # 5. Return combined response
    return jsonify({
        "food": result["food"],
        "confidence": result["confidence"],
        "nutrition": nutrition
    }), 200