import json
from config import NUTRITION_DATA_PATH

# Load nutrition data once at startup
with open(NUTRITION_DATA_PATH, "r") as f:
    nutrition_data = json.load(f)

print(f"[NutritionService] Loaded nutrition data for {len(nutrition_data)} foods.")


def get_nutrition(food_name: str) -> dict:
    """
    Looks up nutrition data for a given food name.
    Normalizes the name (lowercase, spaces → underscores).
    Returns nutrition dict or 'not available' placeholders.
    """
    # Normalize: lowercase and replace spaces with underscores
    normalized = food_name.lower().replace(" ", "_").replace("-", "_")

    if normalized in nutrition_data:
        return nutrition_data[normalized]

    # Try partial match — e.g. "apple_pie" in "apple_pie_slice"
    for key in nutrition_data:
        if normalized in key or key in normalized:
            return nutrition_data[key]

    # Fallback
    return {
        "calories": "N/A",
        "protein": "N/A",
        "carbs": "N/A",
        "fat": "N/A"
    }