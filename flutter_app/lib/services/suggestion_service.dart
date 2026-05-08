import '../models/meal.dart';
import '../models/user_profile.dart';

class SuggestionService {
  static List<Map<String, dynamic>> getSuggestions(
      List<Meal> meals, UserProfile profile) {
    if (meals.isEmpty) {
      return [
        {'msg': '📸 Log your first meal to get personalised suggestions!', 'type': 'info'}
      ];
    }

    final cal  = meals.fold(0, (s, m) => s + m.calories);
    final prot = meals.fold(0, (s, m) => s + m.protein);
    final carb = meals.fold(0, (s, m) => s + m.carbs);
    final fat  = meals.fold(0, (s, m) => s + m.fat);

    final List<Map<String, dynamic>> tips = [];

    // Protein goal met / exceeded (celebrate!)
    if (prot >= profile.dailyProteinLimit) {
      tips.add({
        'msg': '🎉 Amazing, ${profile.name}! You hit your protein goal of ${profile.dailyProteinLimit}g today!',
        'type': 'success'
      });
    } else {
      final rem = profile.dailyProteinLimit - prot;
      tips.add({
        'msg': '💪 ${rem}g more protein to hit your goal of ${profile.dailyProteinLimit}g today.',
        'type': 'info'
      });
    }

    // Carbs warning
    if (carb > profile.dailyCarbLimit) {
      tips.add({
        'msg': '⚠️ Carb intake (${carb}g) exceeds your limit of ${profile.dailyCarbLimit}g. You are going out of your diet plan!',
        'type': 'warning'
      });
    }

    // Fat warning
    if (fat > profile.dailyFatLimit) {
      tips.add({
        'msg': '⚠️ Fat intake (${fat}g) exceeds your limit of ${profile.dailyFatLimit}g. You are going out of your diet plan!',
        'type': 'warning'
      });
    }

    // Calorie warning
    if (cal > profile.dailyCalorieLimit) {
      tips.add({
        'msg': '🔥 Calories (${cal} kcal) exceed your limit of ${profile.dailyCalorieLimit} kcal today.',
        'type': 'warning'
      });
    } else if (cal < 800) {
      tips.add({
        'msg': '🍽️ Very low calorie intake (${cal} kcal). Make sure you\'re eating enough!',
        'type': 'info'
      });
    }

    return tips;
  }
}