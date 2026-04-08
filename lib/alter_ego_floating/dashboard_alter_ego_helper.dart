import 'package:flutter/foundation.dart';
import 'alter_ego_service.dart' show AlterEgoService, AlterEgoPosition, AlterEgoPose;
import '../models/steps.dart';
import '../models/workout_history.dart';
import '../models/goals.dart';

/// Helper pour gérer les réactions de l'Alter Ego sur le Dashboard
class DashboardAlterEgoHelper {
  final AlterEgoService _service = AlterEgoService();

  /// Calcule la progression en pourcentage des pas
  static double _getStepsProgress(int currentSteps, int goalSteps) {
    if (goalSteps == 0) return 0.0;
    return (currentSteps / goalSteps).clamp(0.0, 1.0);
  }

  /// Calcule la progression en pourcentage des séances
  static double _getSessionsProgress(int currentSessions, int goalSessions) {
    if (goalSessions == 0) return 0.0;
    return (currentSessions / goalSessions).clamp(0.0, 1.0);
  }

  /// Détermine le message et la pose selon la progression globale
  /// Inclut maintenant les calories et l'eau
  Future<void> reactToProgress({
    required int currentSteps,
    required int goalSteps,
    required int currentSessions,
    required int goalSessions,
    required double waterProgress,
    required bool isFirstVisit,
    int? currentCalories,
    int? goalCalories,
  }) async {
    try {
    final stepsProgress = _getStepsProgress(currentSteps, goalSteps);
    final sessionsProgress = _getSessionsProgress(currentSessions, goalSessions);
    final overallProgress = (stepsProgress + sessionsProgress) / 2;

    // Message d'accueil pour la première visite
    if (isFirstVisit) {
      await _service.moveToPosition(
        AlterEgoPosition.topRight,
        message: "Salut ! Voici tes défis de la semaine. On va les battre ensemble ! 💪",
        pose: AlterEgoPose.salut,
      );
      return;
    }

    // Réactions selon la progression des pas
    if (stepsProgress >= 1.0) {
      // Objectif de pas atteint
      await _service.moveToPosition(
        AlterEgoPosition.topRight,
        message: "Incroyable ! Tu as battu ton objectif de pas ! Félicitations ! 🎉",
        pose: AlterEgoPose.applaudit,
      );
    } else if (stepsProgress >= 0.75) {
      // Bonne progression
      await _service.moveToPosition(
        AlterEgoPosition.topRight,
        message: "Excellent travail ! Tu es à ${(stepsProgress * 100).toInt()}% de tes pas. Continue comme ça ! 👏",
        pose: AlterEgoPose.felicite,
      );
    } else if (stepsProgress >= 0.30) {
      // Progression moyenne
      if (sessionsProgress < 0.3) {
        await _service.moveToPosition(
          AlterEgoPosition.topRight,
          message: "Allez, on commence la semaine en force ! Chaque pas compte. 💪",
          pose: AlterEgoPose.encourage,
        );
      } else {
        await _service.moveToPosition(
          AlterEgoPosition.topRight,
          message: "Tu progresses bien ! Encore ${((1 - stepsProgress) * goalSteps).toInt()} pas pour atteindre ton objectif. 🔥",
          pose: AlterEgoPose.clindoeil,
        );
      }
    } else {
      // Progression lente
      await _service.moveToPosition(
        AlterEgoPosition.topRight,
        message: "N'oublie pas tes objectifs. Un petit effort aujourd'hui ? 👟",
        pose: AlterEgoPose.alerte,
      );
    }

    // Commenter les calories si fournies
    if (currentCalories != null && goalCalories != null && goalCalories > 0) {
      final caloriesProgress = (currentCalories / goalCalories).clamp(0.0, 1.0);
      if (caloriesProgress >= 1.0) {
        Future.delayed(const Duration(seconds: 5), () async {
          try {
            await _service.showMessage(
              "Excellent ! Tu as atteint ton objectif de calories ! 🔥",
              pose: AlterEgoPose.felicite,
            );
          } catch (e) {
            debugPrint('Erreur message calories: $e');
          }
        });
      } else if (caloriesProgress < 0.6) {
        Future.delayed(const Duration(seconds: 5), () async {
          try {
            await _service.showMessage(
              "Tu es à ${(caloriesProgress * 100).toInt()}% de ton objectif calories. Continue ! 💪",
              pose: AlterEgoPose.encourage,
            );
          } catch (e) {
            debugPrint('Erreur message calories: $e');
          }
        });
      }
    }

    // Rappel d'hydratation si besoin
    if (waterProgress < 0.5) {
      Future.delayed(const Duration(seconds: 6), () async {
        try {
          await _service.showMessage(
            "N'oublie pas de boire de l'eau, c'est important ! Tu es à ${(waterProgress * 100).toInt()}% de ton objectif. 💧",
            pose: AlterEgoPose.reflechit,
          );
        } catch (e) {
          debugPrint('Erreur rappel hydratation: $e');
        }
      });
    } else if (waterProgress >= 1.0) {
      Future.delayed(const Duration(seconds: 6), () async {
        try {
          await _service.showMessage(
            "Super ! Tu as bien bu de l'eau aujourd'hui ! 💧",
            pose: AlterEgoPose.felicite,
          );
        } catch (e) {
          debugPrint('Erreur message eau: $e');
        }
      });
    }

    // Encourager à utiliser Santé & Blessures et Premium
    Future.delayed(const Duration(seconds: 10), () async {
      try {
        await _service.showMessage(
          "Pense à utiliser Santé & Blessures et découvre le Coach IA Premium pour un entraînement optimisé ! 🛡️✨",
          pose: AlterEgoPose.reflechit,
        );
      } catch (e) {
        debugPrint('Erreur message sécurité: $e');
      }
    });
    } catch (e) {
      debugPrint('Erreur reactToProgress: $e');
    }
  }
}

