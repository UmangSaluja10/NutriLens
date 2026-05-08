class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String gender;        // 'male' | 'female'
  final double heightCm;
  final double weightKg;
  final String bodyType;       // 'skinny' | 'skinny_fat' | 'fat' | 'athletic'
  final String activityLevel;  // 'sedentary' | 'active'

  final int dailyCalorieLimit;
  final int dailyProteinLimit;
  final int dailyCarbLimit;
  final int dailyFatLimit;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.gender = 'male',
    this.heightCm = 170,
    this.weightKg = 70,
    this.bodyType = 'skinny',
    this.activityLevel = 'sedentary',
    this.dailyCalorieLimit = 2000,
    this.dailyProteinLimit = 70,
    this.dailyCarbLimit = 250,
    this.dailyFatLimit = 65,
  });

  double get bmi {
    if (heightCm <= 0) return 0;
    final h = heightCm / 100;
    return weightKg / (h * h);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  // ── Protein range ──────────────────────────────────────────────────────────
  // Female multipliers are ~20% lower than male across all body types,
  // reflecting lower average muscle mass and different metabolic needs.
  //
  // Male logic (your original spec):
  //   skinny    sedentary: 1×BW        active: 1.5–2×BW
  //   skinny_fat sedentary: BW−10g     active: (1.5–2×BW)−10–20g
  //   fat       sedentary: BW−20–25g   active: (1.5–2×BW)−40–50g
  //   athletic  sedentary: 1.2–1.5×BW  active: 1.8–2.2×BW
  //
  // Female logic (−20% on multipliers, adjusted deductions):
  //   skinny    sedentary: 0.8×BW       active: 1.2–1.6×BW
  //   skinny_fat sedentary: BW−15g      active: (1.2–1.6×BW)−10–15g
  //   fat       sedentary: BW−25–30g    active: (1.2–1.6×BW)−35–45g
  //   athletic  sedentary: 1.0–1.2×BW   active: 1.4–1.8×BW

  ProteinRange get proteinRange {
    final w = weightKg;
    final bool active = activityLevel == 'active';
    final bool female = gender == 'female';

    if (female) {
      switch (bodyType) {
        case 'skinny':
          return active
              ? ProteinRange((w * 1.2).round(), (w * 1.6).round())
              : ProteinRange((w * 0.8).round(), (w * 0.8).round());
        case 'skinny_fat':
          return active
              ? ProteinRange((w * 1.2 - 15).round(), (w * 1.6 - 10).round())
              : ProteinRange((w - 15).round(), (w - 15).round());
        case 'fat':
          return active
              ? ProteinRange((w * 1.2 - 45).round(), (w * 1.6 - 35).round())
              : ProteinRange((w - 30).round(), (w - 25).round());
        case 'athletic':
          return active
              ? ProteinRange((w * 1.4).round(), (w * 1.8).round())
              : ProteinRange((w * 1.0).round(), (w * 1.2).round());
        default:
          return ProteinRange((w * 0.8).round(), (w * 1.2).round());
      }
    } else {
      // Male (original spec)
      switch (bodyType) {
        case 'skinny':
          return active
              ? ProteinRange((w * 1.5).round(), (w * 2.0).round())
              : ProteinRange(w.round(), w.round());
        case 'skinny_fat':
          return active
              ? ProteinRange((w * 1.5 - 20).round(), (w * 2.0 - 10).round())
              : ProteinRange((w - 10).round(), (w - 10).round());
        case 'fat':
          return active
              ? ProteinRange((w * 1.5 - 50).round(), (w * 2.0 - 40).round())
              : ProteinRange((w - 25).round(), (w - 20).round());
        case 'athletic':
          return active
              ? ProteinRange((w * 1.8).round(), (w * 2.2).round())
              : ProteinRange((w * 1.2).round(), (w * 1.5).round());
        default:
          return ProteinRange(w.round(), (w * 1.5).round());
      }
    }
  }

  int get recommendedProtein => proteinRange.mid;

  factory UserProfile.fromFirestore(Map<String, dynamic> d, String uid) =>
      UserProfile(
        uid: uid,
        name: d['name'] ?? '',
        email: d['email'] ?? '',
        gender: d['gender'] ?? 'male',
        heightCm: (d['heightCm'] ?? 170).toDouble(),
        weightKg: (d['weightKg'] ?? 70).toDouble(),
        bodyType: d['bodyType'] ?? 'skinny',
        activityLevel: d['activityLevel'] ?? 'sedentary',
        dailyCalorieLimit: d['dailyCalorieLimit'] ?? 2000,
        dailyProteinLimit: d['dailyProteinLimit'] ?? 70,
        dailyCarbLimit: d['dailyCarbLimit'] ?? 250,
        dailyFatLimit: d['dailyFatLimit'] ?? 65,
      );

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'bodyType': bodyType,
        'activityLevel': activityLevel,
        'dailyCalorieLimit': dailyCalorieLimit,
        'dailyProteinLimit': dailyProteinLimit,
        'dailyCarbLimit': dailyCarbLimit,
        'dailyFatLimit': dailyFatLimit,
      };

  UserProfile copyWith({
    String? name,
    String? email,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? bodyType,
    String? activityLevel,
    int? dailyCalorieLimit,
    int? dailyProteinLimit,
    int? dailyCarbLimit,
    int? dailyFatLimit,
  }) =>
      UserProfile(
        uid: uid,
        name: name ?? this.name,
        email: email ?? this.email,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        bodyType: bodyType ?? this.bodyType,
        activityLevel: activityLevel ?? this.activityLevel,
        dailyCalorieLimit: dailyCalorieLimit ?? this.dailyCalorieLimit,
        dailyProteinLimit: dailyProteinLimit ?? this.dailyProteinLimit,
        dailyCarbLimit: dailyCarbLimit ?? this.dailyCarbLimit,
        dailyFatLimit: dailyFatLimit ?? this.dailyFatLimit,
      );
}

class ProteinRange {
  final int min;
  final int max;
  const ProteinRange(this.min, this.max);
  int get mid => min == max ? min : ((min + max) / 2).round();
  String get label => min == max ? '${min}g' : '${min}–${max}g';
}