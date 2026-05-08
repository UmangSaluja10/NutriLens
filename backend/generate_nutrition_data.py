"""
Run this script ONCE to generate a full nutrition_data.json
covering all 101 Food101 classes.

Usage:
  python generate_nutrition_data.py

It will overwrite backend/model/nutrition_data.json
"""

import json
import os

# All 101 Food101 class names (underscore format matching class_names.json)
# Nutrition values are approximate per 100g serving
NUTRITION_MAP = {
    "apple_pie":            {"calories": 237, "protein": 2,  "carbs": 34, "fat": 11},
    "baby_back_ribs":       {"calories": 290, "protein": 20, "carbs": 0,  "fat": 22},
    "baklava":              {"calories": 428, "protein": 6,  "carbs": 52, "fat": 23},
    "beef_carpaccio":       {"calories": 160, "protein": 20, "carbs": 0,  "fat": 9},
    "beef_tartare":         {"calories": 196, "protein": 20, "carbs": 2,  "fat": 12},
    "beet_salad":           {"calories": 74,  "protein": 2,  "carbs": 13, "fat": 2},
    "beignets":             {"calories": 320, "protein": 5,  "carbs": 38, "fat": 17},
    "bibimbap":             {"calories": 150, "protein": 8,  "carbs": 22, "fat": 4},
    "bread_pudding":        {"calories": 218, "protein": 6,  "carbs": 32, "fat": 8},
    "breakfast_burrito":    {"calories": 305, "protein": 14, "carbs": 30, "fat": 14},
    "bruschetta":           {"calories": 195, "protein": 6,  "carbs": 28, "fat": 7},
    "caesar_salad":         {"calories": 190, "protein": 5,  "carbs": 10, "fat": 15},
    "cannoli":              {"calories": 350, "protein": 7,  "carbs": 35, "fat": 20},
    "caprese_salad":        {"calories": 140, "protein": 8,  "carbs": 5,  "fat": 10},
    "carrot_cake":          {"calories": 415, "protein": 4,  "carbs": 55, "fat": 20},
    "ceviche":              {"calories": 90,  "protein": 14, "carbs": 5,  "fat": 2},
    "cheese_plate":         {"calories": 370, "protein": 22, "carbs": 2,  "fat": 30},
    "cheesecake":           {"calories": 320, "protein": 5,  "carbs": 30, "fat": 20},
    "chicken_curry":        {"calories": 195, "protein": 16, "carbs": 8,  "fat": 11},
    "chicken_quesadilla":   {"calories": 280, "protein": 17, "carbs": 22, "fat": 13},
    "chicken_wings":        {"calories": 290, "protein": 27, "carbs": 0,  "fat": 20},
    "chocolate_cake":       {"calories": 367, "protein": 4,  "carbs": 51, "fat": 17},
    "chocolate_mousse":     {"calories": 250, "protein": 4,  "carbs": 26, "fat": 15},
    "churros":              {"calories": 370, "protein": 5,  "carbs": 50, "fat": 17},
    "clam_chowder":         {"calories": 130, "protein": 7,  "carbs": 14, "fat": 5},
    "club_sandwich":        {"calories": 295, "protein": 18, "carbs": 24, "fat": 13},
    "crab_cakes":           {"calories": 218, "protein": 16, "carbs": 14, "fat": 11},
    "creme_brulee":         {"calories": 311, "protein": 4,  "carbs": 28, "fat": 20},
    "croque_madame":        {"calories": 330, "protein": 18, "carbs": 22, "fat": 19},
    "cup_cakes":            {"calories": 380, "protein": 4,  "carbs": 55, "fat": 16},
    "deviled_eggs":         {"calories": 185, "protein": 11, "carbs": 2,  "fat": 14},
    "donuts":               {"calories": 410, "protein": 5,  "carbs": 50, "fat": 22},
    "dumplings":            {"calories": 170, "protein": 8,  "carbs": 22, "fat": 6},
    "edamame":              {"calories": 122, "protein": 11, "carbs": 10, "fat": 5},
    "eggs_benedict":        {"calories": 290, "protein": 15, "carbs": 18, "fat": 18},
    "escargots":            {"calories": 155, "protein": 16, "carbs": 2,  "fat": 9},
    "falafel":              {"calories": 333, "protein": 13, "carbs": 32, "fat": 18},
    "filet_mignon":         {"calories": 271, "protein": 26, "carbs": 0,  "fat": 18},
    "fish_and_chips":       {"calories": 312, "protein": 14, "carbs": 32, "fat": 14},
    "foie_gras":            {"calories": 462, "protein": 11, "carbs": 5,  "fat": 44},
    "french_fries":         {"calories": 312, "protein": 3,  "carbs": 41, "fat": 15},
    "french_onion_soup":    {"calories": 160, "protein": 6,  "carbs": 18, "fat": 7},
    "french_toast":         {"calories": 228, "protein": 7,  "carbs": 28, "fat": 10},
    "fried_calamari":       {"calories": 250, "protein": 16, "carbs": 16, "fat": 13},
    "fried_rice":           {"calories": 280, "protein": 4,  "carbs": 55, "fat": 2},
    "frozen_yogurt":        {"calories": 159, "protein": 4,  "carbs": 30, "fat": 3},
    "garlic_bread":         {"calories": 350, "protein": 8,  "carbs": 44, "fat": 16},
    "gnocchi":              {"calories": 130, "protein": 3,  "carbs": 27, "fat": 1},
    "greek_salad":          {"calories": 110, "protein": 3,  "carbs": 8,  "fat": 8},
    "grilled_cheese_sandwich": {"calories": 390, "protein": 16, "carbs": 30, "fat": 24},
    "grilled_salmon":       {"calories": 208, "protein": 28, "carbs": 0,  "fat": 10},
    "guacamole":            {"calories": 155, "protein": 2,  "carbs": 9,  "fat": 14},
    "gyoza":                {"calories": 215, "protein": 9,  "carbs": 24, "fat": 9},
    "hamburger":            {"calories": 295, "protein": 17, "carbs": 30, "fat": 14},
    "hot_and_sour_soup":    {"calories": 95,  "protein": 5,  "carbs": 12, "fat": 3},
    "hot_dog":              {"calories": 295, "protein": 10, "carbs": 24, "fat": 17},
    "huevos_rancheros":     {"calories": 260, "protein": 12, "carbs": 22, "fat": 14},
    "hummus":               {"calories": 177, "protein": 8,  "carbs": 20, "fat": 10},
    "ice_cream":            {"calories": 207, "protein": 3,  "carbs": 24, "fat": 11},
    "lasagna":              {"calories": 185, "protein": 11, "carbs": 18, "fat": 8},
    "lobster_bisque":       {"calories": 185, "protein": 10, "carbs": 12, "fat": 11},
    "lobster_roll_sandwich": {"calories": 280, "protein": 18, "carbs": 28, "fat": 10},
    "macaroni_and_cheese":  {"calories": 350, "protein": 12, "carbs": 44, "fat": 14},
    "macarons":             {"calories": 410, "protein": 6,  "carbs": 60, "fat": 16},
    "miso_soup":            {"calories": 40,  "protein": 3,  "carbs": 5,  "fat": 1},
    "mussels":              {"calories": 172, "protein": 24, "carbs": 7,  "fat": 5},
    "nachos":               {"calories": 345, "protein": 10, "carbs": 38, "fat": 18},
    "omelette":             {"calories": 154, "protein": 11, "carbs": 1,  "fat": 12},
    "onion_rings":          {"calories": 352, "protein": 4,  "carbs": 40, "fat": 20},
    "oysters":              {"calories": 81,  "protein": 9,  "carbs": 5,  "fat": 2},
    "pad_thai":             {"calories": 230, "protein": 10, "carbs": 32, "fat": 7},
    "paella":               {"calories": 205, "protein": 13, "carbs": 26, "fat": 5},
    "pancakes":             {"calories": 227, "protein": 6,  "carbs": 35, "fat": 8},
    "panna_cotta":          {"calories": 258, "protein": 3,  "carbs": 28, "fat": 15},
    "peking_duck":          {"calories": 337, "protein": 19, "carbs": 0,  "fat": 28},
    "pho":                  {"calories": 215, "protein": 15, "carbs": 28, "fat": 4},
    "pizza":                {"calories": 285, "protein": 12, "carbs": 36, "fat": 10},
    "pork_chop":            {"calories": 231, "protein": 25, "carbs": 0,  "fat": 14},
    "poutine":              {"calories": 425, "protein": 12, "carbs": 48, "fat": 21},
    "prime_rib":            {"calories": 338, "protein": 27, "carbs": 0,  "fat": 25},
    "pulled_pork_sandwich": {"calories": 330, "protein": 22, "carbs": 30, "fat": 12},
    "ramen":                {"calories": 190, "protein": 8,  "carbs": 28, "fat": 5},
    "ravioli":              {"calories": 220, "protein": 9,  "carbs": 30, "fat": 8},
    "red_velvet_cake":      {"calories": 386, "protein": 4,  "carbs": 52, "fat": 18},
    "risotto":              {"calories": 185, "protein": 5,  "carbs": 32, "fat": 5},
    "samosa":               {"calories": 308, "protein": 7,  "carbs": 38, "fat": 15},
    "sashimi":              {"calories": 130, "protein": 20, "carbs": 0,  "fat": 5},
    "scallops":             {"calories": 111, "protein": 21, "carbs": 5,  "fat": 1},
    "seaweed_salad":        {"calories": 70,  "protein": 2,  "carbs": 12, "fat": 2},
    "shrimp_and_grits":     {"calories": 265, "protein": 18, "carbs": 26, "fat": 9},
    "spaghetti_bolognese":  {"calories": 230, "protein": 13, "carbs": 26, "fat": 8},
    "spaghetti_carbonara":  {"calories": 350, "protein": 14, "carbs": 38, "fat": 16},
    "spring_rolls":         {"calories": 165, "protein": 5,  "carbs": 20, "fat": 8},
    "steak":                {"calories": 271, "protein": 26, "carbs": 0,  "fat": 18},
    "strawberry_shortcake": {"calories": 310, "protein": 4,  "carbs": 42, "fat": 14},
    "sushi":                {"calories": 145, "protein": 6,  "carbs": 26, "fat": 2},
    "tacos":                {"calories": 210, "protein": 10, "carbs": 22, "fat": 9},
    "takoyaki":             {"calories": 235, "protein": 9,  "carbs": 28, "fat": 10},
    "tiramisu":             {"calories": 283, "protein": 5,  "carbs": 28, "fat": 17},
    "tuna_tartare":         {"calories": 130, "protein": 22, "carbs": 2,  "fat": 4},
    "waffles":              {"calories": 291, "protein": 8,  "carbs": 40, "fat": 12},
}

OUTPUT_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "model", "nutrition_data.json"
)

with open(OUTPUT_PATH, "w") as f:
    json.dump(NUTRITION_MAP, f, indent=2)

print(f"✅ nutrition_data.json updated with {len(NUTRITION_MAP)} food entries.")
print(f"📁 Saved to: {OUTPUT_PATH}")