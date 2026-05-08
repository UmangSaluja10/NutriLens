import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class ProteinGoalScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onUpdated;
  const ProteinGoalScreen({super.key, required this.profile, required this.onUpdated});
  @override
  State<ProteinGoalScreen> createState() => _ProteinGoalScreenState();
}

class _ProteinGoalScreenState extends State<ProteinGoalScreen> {
  late String _bodyType;
  late String _activity;
  late double _weight;
  late int _selectedGoal;
  bool _saving = false;

  static const _bodyTypes = [
    {'value': 'skinny',     'label': 'Skinny',     'icon': '🦴'},
    {'value': 'skinny_fat', 'label': 'Skinny Fat', 'icon': '🫙'},
    {'value': 'fat',        'label': 'Overweight', 'icon': '⚖️'},
    {'value': 'athletic',   'label': 'Athletic',   'icon': '💪'},
  ];

  @override
  void initState() {
    super.initState();
    _bodyType = widget.profile.bodyType;
    _activity = widget.profile.activityLevel;
    _weight   = widget.profile.weightKg;
    _selectedGoal = widget.profile.dailyProteinLimit;
  }

  ProteinRange get _range {
    final temp = widget.profile.copyWith(
        bodyType: _bodyType, activityLevel: _activity, weightKg: _weight);
    return temp.proteinRange;
  }

  String _bodyExplain() {
    final w = _weight;
    final active = _activity == 'active';
    switch (_bodyType) {
      case 'skinny':
        return active
            ? 'Skinny + Active: 1.5–2× body weight = ${(w*1.5).round()}–${(w*2).round()}g'
            : 'Skinny + Sedentary: 1× body weight = ${w.round()}g';
      case 'skinny_fat':
        return active
            ? 'Skinny Fat + Active: (1.5–2× BW) − 10–20g = ${(w*1.5-20).round()}–${(w*2-10).round()}g'
            : 'Skinny Fat + Sedentary: BW − 10g = ${(w-10).round()}g';
      case 'fat':
        return active
            ? 'Overweight + Active: (1.5–2× BW) − 40–50g = ${(w*1.5-50).round()}–${(w*2-40).round()}g'
            : 'Overweight + Sedentary: BW − 20–25g = ${(w-25).round()}–${(w-20).round()}g';
      case 'athletic':
        return active
            ? 'Athletic + Active: 1.8–2.2× BW = ${(w*1.8).round()}–${(w*2.2).round()}g'
            : 'Athletic + Sedentary: 1.2–1.5× BW = ${(w*1.2).round()}–${(w*1.5).round()}g';
      default: return '';
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = widget.profile.copyWith(
        bodyType: _bodyType,
        activityLevel: _activity,
        dailyProteinLimit: _selectedGoal,
      );
      await AuthService.updateProfile(updated);
      widget.onUpdated();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Protein goal updated!'),
          backgroundColor: Color(0xFF2D6A4F)));
      Navigator.pop(context);
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        title: const Text('Protein Goal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Weight display ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200)),
            child: Row(children: [
              const Icon(Icons.monitor_weight_outlined, color: Color(0xFF2D6A4F)),
              const SizedBox(width: 12),
              Text('Body Weight: ${_weight.round()} kg',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ]),
          ),

          const SizedBox(height: 20),

          // ── Body type selector ─────────────────────────────────────────────
          const Text('Body Type',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                  color: Color(0xFF1B4332))),
          const SizedBox(height: 10),
          Row(children: _bodyTypes.map((b) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _bodyType = b['value']!;
                  _selectedGoal = _range.mid;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _bodyType == b['value']
                      ? const Color(0xFF2D6A4F) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _bodyType == b['value']
                        ? const Color(0xFF2D6A4F) : Colors.grey.shade300,
                  ),
                ),
                child: Column(children: [
                  Text(b['icon']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(b['label']!,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: _bodyType == b['value'] ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center),
                ]),
              ),
            ),
          )).toList()),

          const SizedBox(height: 20),

          // ── Activity selector ──────────────────────────────────────────────
          const Text('Activity Level',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                  color: Color(0xFF1B4332))),
          const SizedBox(height: 10),
          Row(children: [
            _ActivityBtn('🪑', 'Sedentary', 'sedentary', _activity, () {
              setState(() { _activity = 'sedentary'; _selectedGoal = _range.mid; });
            }),
            const SizedBox(width: 12),
            _ActivityBtn('🏋️', 'Active', 'active', _activity, () {
              setState(() { _activity = 'active'; _selectedGoal = _range.mid; });
            }),
          ]),

          const SizedBox(height: 20),

          // ── Explanation box ────────────────────────────────────────────────
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2D6A4F).withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📊 Recommended Range',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1B4332))),
              const SizedBox(height: 6),
              Text(range.label,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                      color: Color(0xFF2D6A4F))),
              const SizedBox(height: 6),
              Text(_bodyExplain(),
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),

          const SizedBox(height: 20),

          // ── Goal slider ────────────────────────────────────────────────────
          const Text('Set Your Daily Goal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                  color: Color(0xFF1B4332))),
          const SizedBox(height: 6),
          Text('Drag to pick a value within your recommended range',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text('${_selectedGoal}g / day',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                      color: Color(0xFF2D6A4F))),
              Slider(
                value: _selectedGoal.toDouble(),
                min: (range.min - 20).clamp(10, 400).toDouble(),
                max: (range.max + 20).clamp(20, 500).toDouble(),
                divisions: ((range.max + 20) - (range.min - 20)).clamp(1, 480),
                activeColor: const Color(0xFF2D6A4F),
                onChanged: (v) => setState(() => _selectedGoal = v.round()),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Min: ${range.min}g',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                Text('Rec: ${range.mid}g',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF2D6A4F),
                        fontWeight: FontWeight.w600)),
                Text('Max: ${range.max}g',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ]),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save Goal ($_selectedGoal g/day)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _ActivityBtn extends StatelessWidget {
  final String emoji, label, value, current;
  final VoidCallback onTap;
  const _ActivityBtn(this.emoji, this.label, this.value, this.current, this.onTap);
  @override
  Widget build(BuildContext context) {
    final sel = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF2D6A4F) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: sel ? const Color(0xFF2D6A4F) : Colors.grey.shade300),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13,
                color: sel ? Colors.white : Colors.black87)),
          ]),
        ),
      ),
    );
  }
}