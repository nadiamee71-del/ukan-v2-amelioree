import 'package:flutter/foundation.dart';

import 'user_profile.dart';
import 'workout_history.dart';
import 'nutrition.dart';

/// Modèle représentant une version "moi futur" avancée (mode démo)
class FutureSelfAdvanced {
  /// Objectif principal (ex: "Perte de poids", "Prise de masse")
  final String goal;

  /// Poids cible en kg
  final double? targetWeightKg;

  /// Nombre de séances par semaine visé
  final int targetSessionsPerWeek;

  /// Date objectif
  final DateTime targetDate;

  /// Score estimé de réalisation (0 à 100)
  final int estimatedFutureScore;

  /// Message court venant du "moi futur"
  final String futureMessage;

  const FutureSelfAdvanced({
    required this.goal,
    required this.targetWeightKg,
    required this.targetSessionsPerWeek,
    required this.targetDate,
    required this.estimatedFutureScore,
    required this.futureMessage,
  });

  /// Génère une version "moi futur" à partir des données actuelles
  static FutureSelfAdvanced compute({
    required UserProfile profile,
    required WeeklyWorkoutSummary weekSummary,
    required NutritionDaySummary todaySummary,
  }) {
    const targetHorizonDays = 90; // projection à 3 mois (démo)
    final now = DateTime.now();
    final targetDate = now.add(const Duration(days: targetHorizonDays));

    // 1. Score séances (max 60 points)
    final targetSessions = profile.sessionsPerWeek > 0
        ? profile.sessionsPerWeek
        : 3; // par défaut 3
    final sessionsRatio =
        targetSessions > 0 ? weekSummary.sessionsCount / targetSessions : 0.0;
    final sessionsScore = (sessionsRatio.clamp(0.0, 1.5) / 1.5 * 60).round();

    // 2. Score nutrition (max 40 points)
    const targetCalories = 2000; // démo simple
    final calories = todaySummary.totalCalories;
    final diffRatio =
        (calories - targetCalories).abs() / targetCalories.clamp(1, 999999);
    final nutritionFactor = (1.0 - diffRatio).clamp(0.0, 1.0);
    final nutritionScore = (nutritionFactor * 40).round();

    final estimatedScore =
        (sessionsScore + nutritionScore).clamp(0, 100).toInt();

    final goal = profile.mainGoal;
    final targetWeight = profile.targetWeight;

    String message;
    if (estimatedScore < 30) {
      message =
          'Je viens du futur… et je te dis qu’on peut faire beaucoup mieux. Commence petit, mais commence dès cette semaine.';
    } else if (estimatedScore < 60) {
      message =
          'Tu es sur la bonne voie. En gardant ce rythme, tu seras déjà une version plus forte de toi-même dans quelques semaines.';
    } else if (estimatedScore < 85) {
      message =
          'Continue exactement comme ça. Ton futur moi est fier de ta constance et de ton sérieux.';
    } else {
      message =
          'Tu écrases déjà les objectifs. Mon seul conseil : garde ce niveau sans te blesser et n’oublie pas de te reposer.';
    }

    return FutureSelfAdvanced(
      goal: goal,
      targetWeightKg: targetWeight,
      targetSessionsPerWeek: targetSessions,
      targetDate: targetDate,
      estimatedFutureScore: estimatedScore,
      futureMessage: message,
    );
  }
}










