from flask import Flask
from flask_cors import CORS
from routes.predict import predict_bp
from routes.health import health_bp

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

app.register_blueprint(predict_bp)
app.register_blueprint(health_bp)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)