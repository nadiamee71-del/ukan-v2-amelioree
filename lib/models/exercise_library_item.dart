import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Niveau de difficulté d'un exercice
enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced,
}

extension ExerciseDifficultyX on ExerciseDifficulty {
  String get displayName {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return 'Débutant';
      case ExerciseDifficulty.intermediate:
        return 'Intermédiaire';
      case ExerciseDifficulty.advanced:
        return 'Avancé';
    }
  }

  Color get color {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return Colors.green;
      case ExerciseDifficulty.intermediate:
        return Colors.orange;
      case ExerciseDifficulty.advanced:
        return Colors.red;
    }
  }
}

/// Modèle d'un exercice dans la bibliothèque
/// (Différent du modèle Exercise des programmes d'entraînement)
class ExerciseLibraryItem {
  final String id;
  final String name;
  final String category; // ex : "Full body", "Jambes", "Cardio"
  final ExerciseDifficulty difficulty;
  final String description; // Description globale
  final List<String> steps; // Instructions étape par étape
  final String? imageAsset; // Chemin vers une image locale
  final String? videoAsset; // Optionnel, pour une pseudo-vidéo de démo
  final String? youtubeUrl; // Optionnel, lien YouTube pour la démo
  final List<String> muscles; // ex : "Quadriceps", "Fessiers"
  final String muscleGroup; // Groupe musculaire principal : 'Abdominaux', 'Pectoraux', 'Dos', etc.
  final String equipment; // Type de matériel : 'poids du corps', 'haltères', 'barre', 'machine', 'cardio'
  final bool isBodyweight; // true si exercice au poids du corps
  final bool isPremium; // Si l'exercice fait partie d'un pack payant
  final String? packId; // Identifiant du pack vidéo auquel il appartient, si premium

  // Nouveaux champs pour exercices personnels
  final bool isOfficial; // true = exercice Ukan officiel, false = exercice perso
  final bool isUserCreated; // true si créé par l'utilisateur
  final String? ownerUserId; // id de l'utilisateur propriétaire (démo: "demo-user")
  final bool isShared; // maquette : l'utilisateur "partage" son exercice à la communauté (UI only)
  final String? perceivedDifficulty; // "Très facile", "Facile", "Moyen", "Difficile", "Très difficile"
  final String? videoUrl; // URL ou chemin local de la vidéo, accessible pour les utilisateurs Premium
  
  // Champs optionnels pour exercices personnels
  final List<String>? secondaryMuscles; // Muscles secondaires
  final String? commonMistakes; // Erreurs fréquentes
  final String? tips; // Conseils

  const ExerciseLibraryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.steps,
    this.imageAsset,
    this.videoAsset,
    this.youtubeUrl,
    required this.muscles,
    required this.muscleGroup,
    required this.equipment,
    this.isBodyweight = false,
    this.isPremium = false,
    this.packId,
    this.isOfficial = true, // Par défaut, les exercices existants sont officiels
    this.isUserCreated = false,
    this.ownerUserId,
    this.isShared = false,
    this.perceivedDifficulty,
    this.videoUrl,
    this.secondaryMuscles,
    this.commonMistakes,
    this.tips,
  });
}

