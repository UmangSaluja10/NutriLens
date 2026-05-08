import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import 'protein_goal_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onUpdated;
  const ProfileScreen({super.key, required this.profile, required this.onUpdated});

  Color _bmiColor() {
    switch (profile.bmiCategory) {
      case 'Underweight': return Colors.blue.shade700;
      case 'Normal':      return Colors.green.shade700;
      case 'Overweight':  return Colors.orange.shade700;
      default:            return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        automaticallyImplyLeading: false,
        title: const Text('Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: () async {
              await AuthService.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Avatar + name
          Center(child: Column(children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF2D6A4F),
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 34, color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(profile.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                    color: Color(0xFF1B4332))),
            Text(profile.email,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ])),

          const SizedBox(height: 24),

          // BMI card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _bmiColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bmiColor().withOpacity(0.3)),
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('BMI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                    color: Colors.black54)),
                Text(profile.bmi.toStringAsFixed(1),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                        color: _bmiColor())),
                Text(profile.bmiCategory,
                    style: TextStyle(color: _bmiColor(), fontWeight: FontWeight.w600)),
              ]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _InfoChip('${profile.heightCm.round()} cm', Icons.height),
                const SizedBox(height: 8),
                _InfoChip('${profile.weightKg.round()} kg', Icons.monitor_weight_outlined),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // Body type + activity
          _SectionCard('Body Profile', [
            _Row('Body Type', _labelOf(profile.bodyType)),
            _Row('Activity', profile.activityLevel == 'active' ? 'Active 🏋️' : 'Sedentary 🪑'),
            _Row('Recommended Protein', profile.proteinRange.label),
          ]),

          const SizedBox(height: 12),

          // Daily limits
          _SectionCard('Daily Limits', [
            _Row('Calories', '${profile.dailyCalorieLimit} kcal'),
            _Row('Protein',  '${profile.dailyProteinLimit}g'),
            _Row('Carbs',    '${profile.dailyCarbLimit}g'),
            _Row('Fat',      '${profile.dailyFatLimit}g'),
          ]),

          const SizedBox(height: 20),

          // Set protein goal button
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ProteinGoalScreen(
                      profile: profile, onUpdated: onUpdated))),
              icon: const Icon(Icons.track_changes),
              label: const Text('Adjust Protein Goal',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton.icon(
              onPressed: () async { await AuthService.signOut(); },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _labelOf(String bt) {
    switch (bt) {
      case 'skinny':     return 'Skinny 🦴';
      case 'skinny_fat': return 'Skinny Fat 🫙';
      case 'fat':        return 'Overweight ⚖️';
      case 'athletic':   return 'Athletic 💪';
      default:           return bt;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label; final IconData icon;
  const _InfoChip(this.label, this.icon);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: Colors.black45),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  ]);
}

class _SectionCard extends StatelessWidget {
  final String title; final List<Widget> rows;
  const _SectionCard(this.title, this.rows);
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
          color: Color(0xFF1B4332))),
      const Divider(height: 16),
      ...rows,
    ]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );
}