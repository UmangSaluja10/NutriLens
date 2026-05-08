import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference _mealsRef(String uid) =>
      _db.collection('users').doc(uid).collection('meals');

  // ── Save ──────────────────────────────────────────────────────────────────
  static Future<void> saveMeal(Meal meal) async {
    await _mealsRef(meal.userId).add(meal.toFirestore());
  }

  // ── Stream meals for a date (live, sorted client-side) ────────────────────
  // NOTE: We do NOT use .orderBy() here because combining .where('date') +
  // .orderBy('timestamp') requires a composite Firestore index.
  // Sorting is done on the client after the snapshot arrives — same result,
  // no index needed.
  static Stream<List<Meal>> streamMealsForDate(String uid, String date) {
    return _mealsRef(uid)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snap) {
      final meals = snap.docs.map((d) => Meal.fromFirestore(d)).toList();
      // Sort by timestamp ascending on the client
      meals.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return meals;
    });
  }

  // ── Fetch last 7 days totals (for dashboard chart) ────────────────────────
  static Future<Map<String, Map<String, int>>> getLast7DaysTotals(
      String uid) async {
    final now = DateTime.now();
    final Map<String, Map<String, int>> result = {};

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

      final snap =
          await _mealsRef(uid).where('date', isEqualTo: dateStr).get();

      final meals = snap.docs.map((d) => Meal.fromFirestore(d)).toList();
      result[dateStr] = {
        'calories': meals.fold(0, (s, m) => s + m.calories),
        'protein': meals.fold(0, (s, m) => s + m.protein),
        'carbs': meals.fold(0, (s, m) => s + m.carbs),
        'fat': meals.fold(0, (s, m) => s + m.fat),
      };
    }
    return result;
  }

  // ── Delete a meal ─────────────────────────────────────────────────────────
  static Future<void> deleteMeal(String uid, String mealId) async {
    await _mealsRef(uid).doc(mealId).delete();
  }
}