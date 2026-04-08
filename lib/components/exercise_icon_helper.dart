import 'package:flutter/material.dart';

/// Helper pour générer des icônes d'exercices et groupes musculaires
/// Style iOS Fitness - Design premium avec silhouettes
class ExerciseIconHelper {
  /// Couleurs par groupe musculaire (style iOS)
  static Color getColorForMuscleGroup(String category) {
    switch (category.toLowerCase()) {
      case 'abdominaux':
      case 'abdos':
        return const Color(0xFF34C759); // Vert iOS
      case 'pectoraux':
      case 'pecs':
        return const Color(0xFFFF3B30); // Rouge iOS
      case 'dos':
      case 'back':
        return const Color(0xFFFF9500); // Orange iOS
      case 'jambes':
      case 'legs':
        return const Color(0xFF5856D6); // Violet iOS
      case 'biceps':
        return const Color(0xFFFF2D55); // Rose iOS
      case 'triceps':
        return const Color(0xFF5AC8FA); // Bleu clair iOS
      case 'deltoïdes':
      case 'épaules':
      case 'shoulders':
        return const Color(0xFFFFCC00); // Jaune iOS
      default:
        return const Color(0xFF8E8E93); // Gris iOS
    }
  }

  /// Icône par groupe musculaire (style iOS Fitness)
  static IconData getIconForMuscleGroup(String category) {
    switch (category.toLowerCase()) {
      case 'abdominaux':
      case 'abdos':
        return Icons.fitness_center; // Icône générique pour l'instant
      case 'pectoraux':
      case 'pecs':
        return Icons.fitness_center;
      case 'dos':
      case 'back':
        return Icons.fitness_center;
      case 'jambes':
      case 'legs':
        return Icons.fitness_center;
      case 'biceps':
        return Icons.fitness_center;
      case 'triceps':
        return Icons.fitness_center;
      case 'deltoïdes':
      case 'épaules':
      case 'shoulders':
        return Icons.fitness_center;
      default:
        return Icons.fitness_center;
    }
  }

  /// Crée un avatar circulaire pour un groupe musculaire
  static Widget buildMuscleGroupAvatar(String category, {double size = 48}) {
    final color = getColorForMuscleGroup(category);
    final icon = getIconForMuscleGroup(category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.5,
      ),
    );
  }

  /// Crée un avatar circulaire pour un exercice
  static Widget buildExerciseAvatar(String exerciseName, String category, {double size = 48}) {
    final color = getColorForMuscleGroup(category);
    
    // Utiliser la première lettre du nom de l'exercice comme fallback
    final initial = exerciseName.isNotEmpty ? exerciseName[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Liste des catégories musculaires principales (ordre iOS Fitness)
  static List<String> get muscleGroups => [
    'Abdominaux',
    'Pectoraux',
    'Dos',
    'Jambes',
    'Biceps',
    'Triceps',
    'Deltoïdes',
    'Autres',
  ];
}











