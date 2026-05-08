import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String? id;
  final String userId;
  final String food;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String date;
  final DateTime timestamp;

  Meal({
    this.id,
    required this.userId,
    required this.food,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
    required this.timestamp,
  });

  factory Meal.fromPrediction(Map<String, dynamic> json, String userId) {
    final n = json['nutrition'] as Map<String, dynamic>;
    final now = DateTime.now();
    return Meal(
      userId: userId,
      food: json['food'] ?? 'Unknown',
      calories: _toInt(n['calories']),
      protein: _toInt(n['protein']),
      carbs: _toInt(n['carbs']),
      fat: _toInt(n['fat']),
      date: '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}',
      timestamp: now,
    );
  }

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Meal(
      id: doc.id,
      userId: d['userId'] ?? '',
      food: d['food'] ?? '',
      calories: _toInt(d['calories']),
      protein: _toInt(d['protein']),
      carbs: _toInt(d['carbs']),
      fat: _toInt(d['fat']),
      date: d['date'] ?? '',
      timestamp: (d['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'food': food,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'date': date,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  static int _toInt(dynamic v) {
    if (v == null || v == 'N/A') return 0;
    return int.tryParse(v.toString()) ?? 0;
  }

  String get displayName => food
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}