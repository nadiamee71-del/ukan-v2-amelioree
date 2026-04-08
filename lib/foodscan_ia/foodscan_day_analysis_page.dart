import 'package:flutter/material.dart';
import '../models/nutrition.dart';
import '../models/goals.dart';
import '../models/steps.dart';
import '../models/workout_history.dart';

/// Page analyse complète de la journée (démo)
class FoodScanDayAnalysisPage extends StatelessWidget {
  const FoodScanDayAnalysisPage({super.key});

  String _generateAnalysis({
    required int calories,
    required int caloriesGoal,
    required int protein,
    required int proteinGoal,
    required int waterMl,
    required double waterGoalLiters,
    required int steps,
    required int stepsGoal,
    required int workoutCount,
  }) {
    final caloriesRatio = caloriesGoal > 0 ? (calories / caloriesGoal) : 0.0;
    final proteinRatio = proteinGoal > 0 ? (protein / proteinGoal) : 0.0;
    final waterRatio = waterGoalLiters > 0 ? (waterMl / (waterGoalLiters * 1000)) : 0.0;
    final stepsRatio = stepsGoal > 0 ? (steps / stepsGoal) : 0.0;

    final List<String> points = [];

    // Calories
    if (caloriesRatio < 0.8) {
      points.add('Tu es en dessous de ton objectif de calories (${caloriesRatio.toStringAsFixed(0)}%). C\'est plutôt bien si tu vises une perte de poids.');
    } else if (caloriesRatio > 1.2) {
      points.add('Tu as dépassé ton objectif de calories aujourd\'hui (${(caloriesRatio * 100).toStringAsFixed(0)}%). Pas grave, mais demain on peut rééquilibrer.');
    } else {
      points.add('Tes calories sont dans la bonne zone. Continue comme ça !');
    }

    // Protéines
    if (proteinRatio < 0.7) {
      points.add('Protéines un peu basses (${proteinRatio.toStringAsFixed(0)}% de l\'objectif). Essaie d\'ajouter une source protéinée au prochain repas.');
    } else if (proteinRatio >= 1.0) {
      points.add('Excellent niveau de protéines ! Tu es au-dessus de ton objectif.');
    } else {
      points.add('Protéines correctes, proche de l\'objectif.');
    }

    // Hydratation
    if (waterRatio < 0.6) {
      points.add('Hydratation insuffisante. Pense à boire plus d\'eau dans la journée.');
    } else if (waterRatio >= 1.0) {
      points.add('Hydratation parfaite ! Tu as atteint ton objectif d\'eau.');
    } else {
      points.add('Hydratation correcte, continue à boire régulièrement.');
    }

    // Pas
    if (steps < 4000) {
      points.add('Pas assez de pas aujourd\'hui. Essaie de marcher un peu plus si possible.');
    } else if (steps >= stepsGoal) {
      points.add('Excellent ! Tu as atteint ton objectif de pas pour aujourd\'hui.');
    } else {
      points.add('Bonne activité, continue à bouger.');
    }

    // Séances
    if (workoutCount > 0) {
      points.add('Super ! Tu as fait $workoutCount séance${workoutCount > 1 ? 's' : ''} aujourd\'hui. Excellent travail !');
    } else {
      points.add('Pas de séance enregistrée aujourd\'hui. Pense à bouger un peu si tu peux.');
    }

    return points.join(' ');
  }

  String _generateSummaryNote({
    required int calories,
    required int caloriesGoal,
    required int protein,
    required int proteinGoal,
    required int waterMl,
    required double waterGoalLiters,
    required int steps,
    required int stepsGoal,
    required int workoutCount,
  }) {
    final caloriesRatio = caloriesGoal > 0 ? (calories / caloriesGoal) : 0.0;
    final proteinRatio = proteinGoal > 0 ? (protein / proteinGoal) : 0.0;
    final waterRatio = waterGoalLiters > 0 ? (waterMl / (waterGoalLiters * 1000)) : 0.0;
    final stepsRatio = stepsGoal > 0 ? (steps / stepsGoal) : 0.0;

    int score = 0;
    if (caloriesRatio >= 0.8 && caloriesRatio <= 1.2) score += 2;
    if (proteinRatio >= 0.7) score += 2;
    if (waterRatio >= 0.7) score += 2;
    if (stepsRatio >= 0.7) score += 2;
    if (workoutCount > 0) score += 2;

    if (score >= 8) {
      return 'En résumé : journée plutôt équilibrée et active. Continue comme ça, tu es sur la bonne voie ! 💪';
    } else if (score >= 5) {
      return 'En résumé : journée correcte avec quelques points à améliorer. Demain sera encore mieux ! 🌟';
    } else {
      return 'En résumé : journée à surveiller. Pas de stress, demain est un nouveau jour pour repartir du bon pied ! 💚';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Récupérer les données
    final nutritionNotifier = NutritionNotifier();
    final goalsNotifier = DailyGoalsNotifier();
    final stepsNotifier = StepsNotifier();
    final workoutNotifier = WorkoutHistoryNotifier();

    final nutritionSummary = nutritionNotifier.summaryForDate(today);
    final calories = nutritionSummary.totalCalories;
    const caloriesGoal = 2000;
    final protein = goalsNotifier.totalProteinForDate(today);
    final proteinGoal = goalsNotifier.proteinGoalGrams;
    final waterMl = goalsNotifier.totalWaterForDate(today);
    final waterGoalLiters = goalsNotifier.waterGoalLiters;
    
    // Récupérer les pas du jour
    int steps = 0;
    try {
      steps = stepsNotifier.totalForDate(today);
    } catch (e) {
      steps = 0;
    }
    const stepsGoal = 8000;

    // Séances du jour
    final allWorkouts = workoutNotifier.allEntries();
    final todayWorkouts = allWorkouts.where((w) {
      final wDate = DateTime(w.date.year, w.date.month, w.date.day);
      return wDate == today;
    }).toList();
    final workoutCount = todayWorkouts.length;

    // Générer l'analyse
    final analysis = _generateAnalysis(
      calories: calories,
      caloriesGoal: caloriesGoal,
      protein: protein,
      proteinGoal: proteinGoal,
      waterMl: waterMl,
      waterGoalLiters: waterGoalLiters,
      steps: steps,
      stepsGoal: stepsGoal,
      workoutCount: workoutCount,
    );

    final summaryNote = _generateSummaryNote(
      calories: calories,
      caloriesGoal: caloriesGoal,
      protein: protein,
      proteinGoal: proteinGoal,
      waterMl: waterMl,
      waterGoalLiters: waterGoalLiters,
      steps: steps,
      stepsGoal: stepsGoal,
      workoutCount: workoutCount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Analyse de ma journée (démo)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte Résumé chiffré
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC300).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: Color(0xFFFFC300),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Résumé chiffré',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SummaryRow(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: Colors.orange,
                      label: 'Calories',
                      value: '$calories / $caloriesGoal kcal',
                      progress: caloriesGoal > 0 ? (calories / caloriesGoal).clamp(0.0, 1.0) : 0.0,
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      icon: Icons.fastfood_rounded,
                      iconColor: Colors.purple,
                      label: 'Protéines',
                      value: 'P: $protein g / $proteinGoal g',
                      progress: proteinGoal > 0 ? (protein / proteinGoal).clamp(0.0, 1.0) : 0.0,
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      icon: Icons.water_drop_rounded,
                      iconColor: Colors.blue,
                      label: 'Eau',
                      value: '${(waterMl / 1000.0).toStringAsFixed(1)} L / ${waterGoalLiters.toStringAsFixed(1)} L',
                      progress: waterGoalLiters > 0 ? (waterMl / (waterGoalLiters * 1000)).clamp(0.0, 1.0) : 0.0,
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      icon: Icons.directions_walk_rounded,
                      iconColor: Colors.green,
                      label: 'Pas',
                      value: '$steps pas / $stepsGoal',
                      progress: stepsGoal > 0 ? (steps / stepsGoal).clamp(0.0, 1.0) : 0.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Carte Analyse automatique
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Analyse automatique (démo)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      analysis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Carte Note IA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF111111),
                      const Color(0xFF2A2A2A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC300).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: Color(0xFFFFC300),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Note IA (démo)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      summaryNote,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double progress;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey.shade200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0
                    ? Colors.green.shade500
                    : progress >= 0.7
                        ? Colors.orange.shade500
                        : Colors.red.shade400,
              ),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

