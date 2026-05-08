import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../services/suggestion_service.dart';

class HistoryScreen extends StatefulWidget {
  final UserProfile profile;
  const HistoryScreen({super.key, required this.profile});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late String _date;

  @override
  void initState() {
    super.initState();
    _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String get _displayDate {
    final dt = DateFormat('yyyy-MM-dd').parse(_date);
    return DateFormat('EEEE, MMM d').format(dt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_date),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2D6A4F))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = DateFormat('yyyy-MM-dd').format(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        automaticallyImplyLeading: false,
        title: const Text('Daily Log',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today, color: Colors.white),
              onPressed: _pickDate),
        ],
      ),
      body: StreamBuilder<List<Meal>>(
        stream: FirestoreService.streamMealsForDate(widget.profile.uid, _date),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2D6A4F)));
          }
          final meals = snap.data ?? [];
          final sugg = SuggestionService.getSuggestions(meals, widget.profile);
          final totCal  = meals.fold(0, (s, m) => s + m.calories);
          final totProt = meals.fold(0, (s, m) => s + m.protein);
          final totCarb = meals.fold(0, (s, m) => s + m.carbs);
          final totFat  = meals.fold(0, (s, m) => s + m.fat);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Date row
              Row(children: [
                const Icon(Icons.today, color: Color(0xFF2D6A4F), size: 18),
                const SizedBox(width: 8),
                Text(_displayDate,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                        color: Color(0xFF1B4332))),
                const Spacer(),
                TextButton(onPressed: _pickDate,
                    child: const Text('Change', style: TextStyle(color: Color(0xFF2D6A4F)))),
              ]),
              const SizedBox(height: 12),

              // Daily totals
              if (meals.isNotEmpty) ...[
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2D6A4F), Color(0xFF40916C)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Daily Totals',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('$totCal kcal',
                        style: const TextStyle(color: Colors.white, fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _Chip('Protein', '${totProt}g', Colors.blue.shade200),
                      _Chip('Carbs',   '${totCarb}g', Colors.amber.shade200),
                      _Chip('Fat',     '${totFat}g',  Colors.red.shade200),
                    ]),
                  ]),
                ),
                const SizedBox(height: 14),
              ],

              // Suggestions
              ...sugg.map((s) => _SuggBanner(s['msg'], s['type'])),
              const SizedBox(height: 12),

              // Meal list
              Row(children: [
                const Text('Meals', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: Color(0xFF1B4332))),
                const Spacer(),
                Text('${meals.length} meal${meals.length == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ]),
              const SizedBox(height: 8),

              if (meals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(children: [
                      Icon(Icons.no_food, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text('No meals logged.',
                          style: TextStyle(color: Colors.grey.shade400)),
                    ]),
                  ),
                )
              else
                ...meals.map((m) => _MealTile(
                  meal: m,
                  onDelete: () async {
                    if (m.id != null) {
                      await FirestoreService.deleteMeal(widget.profile.uid, m.id!);
                    }
                  },
                )),
            ]),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label, value; final Color color;
  const _Chip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
  ]);
}

class _SuggBanner extends StatelessWidget {
  final String msg, type;
  const _SuggBanner(this.msg, this.type);
  @override
  Widget build(BuildContext context) {
    Color bg, border;
    if (type == 'success') { bg = Colors.green.shade50; border = Colors.green.shade300; }
    else if (type == 'warning') { bg = Colors.orange.shade50; border = Colors.orange.shade300; }
    else { bg = const Color(0xFFF0F7F4); border = const Color(0xFF95D5B2); }
    return Container(
      width: double.infinity, margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border)),
      child: Text(msg, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _MealTile extends StatelessWidget {
  final Meal meal; final VoidCallback onDelete;
  const _MealTile({required this.meal, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2D6A4F).withOpacity(0.1),
          child: const Icon(Icons.restaurant, color: Color(0xFF2D6A4F), size: 20),
        ),
        title: Text(meal.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${meal.calories} kcal · P:${meal.protein}g · C:${meal.carbs}g · F:${meal.fat}g',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Delete meal?'),
            content: Text('Remove ${meal.displayName} from your log?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () { Navigator.pop(context); onDelete(); },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          )),
        ),
      ),
    );
  }
}