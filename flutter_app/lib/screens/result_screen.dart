import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/nutrition_card.dart';

class ResultScreen extends StatefulWidget {
  final Meal meal;
  final Uint8List imageBytes;
  final double confidence;
  final UserProfile profile;
  final VoidCallback onMealSaved; // ← triggers tab switch to Dashboard

  const ResultScreen({
    super.key,
    required this.meal,
    required this.imageBytes,
    required this.confidence,
    required this.profile,
    required this.onMealSaved,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saved = false, _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirestoreService.saveMeal(widget.meal);
      if (!mounted) return;
      setState(() => _saved = true);

      final proteinMet = await _checkProteinCelebration();
      if (!mounted) return;

      if (!proteinMet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Meal saved! Returning to Dashboard...'),
            backgroundColor: Color(0xFF2D6A4F),
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        _returnToDashboard();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save: $e'),
        backgroundColor: Colors.red.shade700,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _checkProteinCelebration() async {
    final meals = await FirestoreService.streamMealsForDate(
            widget.profile.uid, widget.meal.date)
        .first;
    final totalProt = meals.fold(0, (s, m) => s + m.protein);

    if (totalProt >= widget.profile.dailyProteinLimit && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 Goal Achieved!',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20)),
          content: Text(
            'Amazing, ${widget.profile.name.split(' ').first}!\n\n'
            'You hit your protein goal of '
            '${widget.profile.dailyProteinLimit}g today! Keep it up! 💪',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                _returnToDashboard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Dashboard 💪'),
            ),
          ],
        ),
      );
      return true;
    }
    return false;
  }

  // ── Pop only ResultScreen, then call onMealSaved to switch tab ────
  void _returnToDashboard() {
    Navigator.pop(context);   // pop ResultScreen only — AnalyzeScreen is inline, NOT a route
    widget.onMealSaved();     // tell DashboardScreen to switch bottom nav to tab 0
  }

  Color _confColor(double c) => c >= 0.75
      ? Colors.green.shade700
      : c >= 0.50
          ? Colors.orange.shade700
          : Colors.red.shade700;

  String _confLabel(double c) => c >= 0.75
      ? 'High confidence'
      : c >= 0.50
          ? 'Medium confidence'
          : 'Low confidence';

  @override
  Widget build(BuildContext context) {
    final m = widget.meal;
    final c = widget.confidence;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        title: const Text('Nutrition Result',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(widget.imageBytes,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // Food name + confidence badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(m.displayName,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B4332))),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _confColor(c)
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                            color: _confColor(c)
                                .withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${(c * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _confColor(c)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_confLabel(c),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text('Estimated Nutrition (per serving)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            const SizedBox(height: 12),

            // Nutrition grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                NutritionCard(
                    label: 'Calories',
                    value: m.calories.toString(),
                    unit: 'kcal',
                    color: Colors.orange.shade700,
                    icon: Icons.local_fire_department),
                NutritionCard(
                    label: 'Protein',
                    value: m.protein.toString(),
                    unit: 'grams',
                    color: Colors.blue.shade700,
                    icon: Icons.fitness_center),
                NutritionCard(
                    label: 'Carbs',
                    value: m.carbs.toString(),
                    unit: 'grams',
                    color: Colors.amber.shade700,
                    icon: Icons.grain),
                NutritionCard(
                    label: 'Fat',
                    value: m.fat.toString(),
                    unit: 'grams',
                    color: Colors.red.shade400,
                    icon: Icons.water_drop_outlined),
              ],
            ),

            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: (_saved || _saving) ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white))
                    : Icon(_saved
                        ? Icons.check
                        : Icons.bookmark_add_outlined),
                label: Text(
                  _saved
                      ? 'Saved — Going to Dashboard...'
                      : 'Save to Daily Log',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saved
                      ? Colors.grey.shade400
                      : const Color(0xFF2D6A4F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Back button (without saving)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back without saving'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D6A4F),
                  side: const BorderSide(
                      color: Color(0xFF2D6A4F)),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}