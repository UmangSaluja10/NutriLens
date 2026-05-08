import 'package:flutter/material.dart';

class NutritionCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final IconData icon;

  const NutritionCard({super.key, required this.label, required this.value,
      required this.unit, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 8),
        Text(value == '0' ? '–' : value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(unit, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center),
      ]),
    );
  }
}