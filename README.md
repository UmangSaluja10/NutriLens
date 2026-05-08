# NutriLens 🥗
### AI-Powered Smart Food Nutrition Analyzer

A full-stack mobile application that detects food from images using a CNN model and provides estimated nutritional information, daily tracking, and personalized health suggestions.

---

## Features

- 📸 **Food Recognition** — Snap or upload a food photo, CNN model identifies it (101 food categories)
- 🧮 **Nutrition Analysis** — Calories, Protein, Carbs, Fat per serving
- 📊 **Dashboard** — 7-day nutrition chart, daily macro progress bars
- 🎯 **Personalized Protein Goal** — Based on body type (Skinny/Skinny Fat/Overweight/Athletic), gender, and activity level
- ⚠️ **Diet Warnings** — Alerts when carbs or fat exceed your daily limits
- 🎉 **Goal Celebrations** — Congratulates you by name when protein goal is met
- 📅 **Daily History** — Date-wise meal log with totals
- 👤 **User Profiles** — BMI calculator, body type, activity level
- 🔐 **Authentication** — Email/password signup & login with persistent sessions

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) — Web + Android |
| Backend | Flask (Python) |
| ML Model | TensorFlow / Keras — MobileNetV2 transfer learning |
| Dataset | Food101 (101 classes, ~75k images) |
| Database | Firebase Firestore |
| Auth | Firebase Authentication |

---

## Project Structure

```
smart-nutrition-app/
├── backend/                    # Flask REST API
│   ├── app.py                  # Entry point
│   ├── config.py               # Paths & settings
│   ├── requirements.txt        # Python dependencies
│   ├── routes/
│   │   ├── predict.py          # POST /predict
│   │   └── health.py           # GET /health
│   ├── services/
│   │   ├── predictor.py        # Model inference
│   │   └── nutrition_service.py
│   └── model/
│       ├── class_names.json    # 101 food class labels
│       └── nutrition_data.json # Nutrition lookup table
│
├── flutter_app/                # Flutter frontend
│   └── lib/
│       ├── main.dart
│       ├── models/
│       ├── screens/
│       ├── services/
│       └── widgets/
│
└── ml/
    └── NutrientApp.ipynb       # Model training (Google Colab)
```

---

## Setup

### Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt
python generate_nutrition_data.py
python app.py
```

### Flutter App

```bash
cd flutter_app
flutter pub get
flutterfire configure         # connects Firebase
flutter run -d chrome
```

### Required: Firebase Setup
1. Create project at console.firebase.google.com
2. Enable **Email/Password** Authentication
3. Enable **Firestore Database** (test mode)
4. Download `google-services.json` → place in `flutter_app/android/app/`
5. Run `flutterfire configure` to generate `firebase_options.dart`

> ⚠️ `firebase_options.dart` and `google-services.json` are in `.gitignore` — you must generate these yourself.

---

## Model

- **Architecture:** MobileNetV2 (transfer learning, ImageNet weights)
- **Dataset:** Food101 via TensorFlow Datasets
- **Input:** 224×224 RGB images
- **Output:** 101 food classes (softmax)
- **Training:** 5 epochs, val_accuracy ~55%
- **Model file:** `food_nutrition_model.keras` (not in repo — too large)

> The trained model file is excluded from the repo due to size. Train it yourself using `ml/NutrientApp.ipynb` on Google Colab (free T4 GPU, ~30 min).

---

## API

### `POST /predict`
```
Request:  multipart/form-data { image: <file> }
Response: { "food": "spring_rolls", "confidence": 0.82,
            "nutrition": { "calories": 165, "protein": 5, "carbs": 20, "fat": 8 } }
```

### `GET /health`
```
Response: { "status": "ok", "model_loaded": true, "classes_loaded": 101 }
```

---

## Protein Goal Logic

| Body Type | Sedentary (Male) | Active (Male) | Sedentary (Female) | Active (Female) |
|-----------|-----------------|---------------|-------------------|----------------|
| Skinny | 1× BW | 1.5–2× BW | 0.8× BW | 1.2–1.6× BW |
| Skinny Fat | BW−10g | (1.5–2×BW)−10–20g | BW−15g | (1.2–1.6×BW)−10–15g |
| Overweight | BW−20–25g | (1.5–2×BW)−40–50g | BW−25–30g | (1.2–1.6×BW)−35–45g |
| Athletic | 1.2–1.5× BW | 1.8–2.2× BW | 1.0–1.2× BW | 1.4–1.8× BW |

---

## Disclaimer

Nutrition values are AI estimates and not medically accurate.
This application is for educational/demo purposes only.

---

*Built with Flutter + Flask + TensorFlow*
