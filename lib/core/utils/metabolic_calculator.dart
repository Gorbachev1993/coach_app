class MetabolicProfile {
  final double bmr;
  final double tdee;
  final int targetCalories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final double waterIntakeLiters;
  final String bodyType;

  MetabolicProfile({
    required this.bmr, required this.tdee, required this.targetCalories,
    required this.proteinGrams, required this.carbsGrams,
    required this.fatGrams, required this.waterIntakeLiters,
    required this.bodyType,
  });

  Map<String, dynamic> toJson() => {
    'bmr': bmr, 'tdee': tdee, 'targetCalories': targetCalories,
    'proteinGrams': proteinGrams, 'carbsGrams': carbsGrams,
    'fatGrams': fatGrams, 'waterIntakeLiters': waterIntakeLiters,
    'bodyType': bodyType,
  };
}

class MetabolicCalculator {
  static MetabolicProfile calculateFullProfile({
    required String gender, required int age,
    required double weightKg, required double heightCm,
    required String experienceLevel, required double bodyFatPercentage,
    required String jobType, required int workoutsPerWeek,
    required List<String> workoutTypes, required double waistCm,
    required double hipCm, required String goal,
  }) {
    double bmr;
    if (gender == 'male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    if (bodyFatPercentage > 0) {
      double leanMass = weightKg * (1 - bodyFatPercentage / 100);
      double katchBmr = 370 + (21.6 * leanMass);
      bmr = (bmr * 0.4 + katchBmr * 0.6);
    }

    double pal = 1.2;
    Map<String, double> jobPAL = {
      'sedentary': 0.0, 'standing': 0.15,
      'light_manual': 0.25, 'heavy_manual': 0.4,
    };
    pal += jobPAL[jobType] ?? 0.0;

    Map<String, double> workoutIntensity = {
      'HIIT': 0.1, 'step': 0.08, 'sculpt': 0.07, 'private': 0.09,
    };
    double weeklyPAL = 0;
    for (String type in workoutTypes) {
      weeklyPAL += workoutIntensity[type] ?? 0.05;
    }
    pal += weeklyPAL * (workoutsPerWeek / 7);

    Map<String, double> expFactors = {
      'beginner': 1.15, 'intermediate': 1.0,
      'advanced': 0.88, 'elite': 0.82,
    };
    double expFactor = expFactors[experienceLevel] ?? 1.0;

    double whr = waistCm / hipCm;
    double healthFactor = whr > 0.9 ? 0.95 : 1.0;
    double tdee = bmr * pal * expFactor * healthFactor;

    Map<String, double> goals = {
      'extreme_weight_loss': 0.75, 'moderate_weight_loss': 0.85,
      'recomposition': 0.95, 'maintenance': 1.0,
      'lean_bulk': 1.07, 'aggressive_bulk': 1.15,
    };
    int targetCal = (tdee * (goals[goal] ?? 1.0)).round();

    int proteinG = (weightKg * 2.2).round();
    int fatG = ((targetCal * 0.25) / 9).round();
    int carbG = ((targetCal - (proteinG * 4) - (fatG * 9)) / 4).round();
    double waterL = weightKg * 0.033;

    String bodyType;
    if (gender == 'male') {
      if (bodyFatPercentage < 15 && whr < 0.9) bodyType = 'Ectomorphe';
      else if (bodyFatPercentage < 25) bodyType = 'Mésomorphe';
      else bodyType = 'Endomorphe';
    } else {
      if (bodyFatPercentage < 23 && whr < 0.8) bodyType = 'Ectomorphe';
      else if (bodyFatPercentage < 33) bodyType = 'Mésomorphe';
      else bodyType = 'Endomorphe';
    }

    return MetabolicProfile(
      bmr: bmr, tdee: tdee, targetCalories: targetCal,
      proteinGrams: proteinG, carbsGrams: carbG, fatGrams: fatG,
      waterIntakeLiters: waterL, bodyType: bodyType,
    );
  }
}
