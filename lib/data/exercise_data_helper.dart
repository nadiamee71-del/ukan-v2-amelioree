import '../models/exercise.dart';
import '../models/exercise_library_item.dart';

/// Helper pour enrichir les exercices avec les données complètes
class ExerciseDataHelper {
  /// Convertit un ExerciseLibraryItem en ExerciseLibrary avec données enrichies
  static ExerciseLibrary enrichExercise(ExerciseLibraryItem item) {
    // Récupérer les données enrichies selon l'ID (seulement pour exercices officiels)
    final enriched = item.isOfficial ? _getEnrichedData(item.id) : {};
    
    // Pour les exercices personnels, utiliser les champs directement
    // Pour les exercices officiels, utiliser les données enrichies si disponibles
    final secondaryMuscles = item.isUserCreated && item.secondaryMuscles != null
        ? item.secondaryMuscles!
        : ((enriched['secondaryMuscles'] as List<dynamic>?)?.cast<String>() ?? <String>[]);
    
    final commonMistakes = item.isUserCreated && item.commonMistakes != null
        ? [item.commonMistakes!]
        : ((enriched['commonMistakes'] as List<dynamic>?)?.cast<String>() ?? <String>[]);
    
    final tips = item.isUserCreated && item.tips != null
        ? [item.tips!]
        : ((enriched['tips'] as List<dynamic>?)?.cast<String>() ?? <String>[]);
    
    final videoUrl = item.videoUrl ?? item.youtubeUrl ?? item.videoAsset;
    
    return ExerciseLibrary(
      id: item.id,
      name: item.name,
      category: _normalizeCategory(item.category),
      equipment: enriched['equipment'] ?? 'Poids du corps',
      difficulty: item.difficulty,
      mainMuscles: item.muscles,
      secondaryMuscles: secondaryMuscles,
      videoUrl: videoUrl,
      imageUrls: item.imageAsset != null ? [item.imageAsset!] : [],
      description: item.description,
      steps: item.steps,
      commonMistakes: commonMistakes,
      tips: tips,
    );
  }

  /// Normalise la catégorie
  static String _normalizeCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('jambes') || lower.contains('legs')) {
      return 'Bas du corps';
    }
    if (lower.contains('haut') || lower.contains('upper')) {
      return 'Haut du corps';
    }
    if (lower.contains('full') || lower.contains('complet')) {
      return 'Full body';
    }
    if (lower.contains('cardio')) {
      return 'Cardio';
    }
    if (lower.contains('abdo') || lower.contains('core')) {
      return 'Abdominaux';
    }
    return category;
  }

  /// Récupère les données enrichies selon l'ID de l'exercice
  static Map<String, dynamic> _getEnrichedData(String exerciseId) {
    switch (exerciseId) {
      case 'squat_bodyweight':
        return {
          'equipment': 'Poids du corps',
          'secondaryMuscles': ['Ischio-jambiers', 'Abdominaux'],
          'commonMistakes': [
            'Genoux qui rentrent vers l\'intérieur',
            'Dos arrondi',
            'Talons qui se décollent du sol',
            'Ne pas descendre assez bas',
          ],
          'tips': [
            'Garde le dos droit et le regard vers l\'avant',
            'Descends jusqu\'à ce que tes cuisses soient parallèles au sol',
            'Pousse sur les talons pour remonter',
            'Contracte les fessiers en remontant',
          ],
        };

      case 'pushup':
        return {
          'equipment': 'Poids du corps',
          'secondaryMuscles': ['Abdominaux', 'Dos'],
          'commonMistakes': [
            'Fesses trop hautes ou trop basses',
            'Tête qui tombe vers le sol',
            'Mouvement incomplet (ne pas descendre assez)',
            'Respiration bloquée',
          ],
          'tips': [
            'Garde le corps aligné de la tête aux pieds',
            'Descends jusqu\'à frôler le sol avec la poitrine',
            'Expire en montant, inspire en descendant',
            'Pour débuter, tu peux faire sur les genoux',
          ],
        };

      case 'plank':
        return {
          'equipment': 'Poids du corps',
          'secondaryMuscles': ['Épaules', 'Dos'],
          'commonMistakes': [
            'Fesses trop hautes',
            'Creux du dos trop prononcé',
            'Tête qui tombe',
            'Respiration bloquée',
          ],
          'tips': [
            'Garde le corps droit comme une planche',
            'Contracte les abdos et les fessiers',
            'Respire normalement',
            'Commence par 20-30 secondes et augmente progressivement',
          ],
        };

      case 'lunges':
        return {
          'equipment': 'Poids du corps',
          'secondaryMuscles': ['Ischio-jambiers', 'Abdominaux'],
          'commonMistakes': [
            'Genou avant qui dépasse les orteils',
            'Corps qui penche vers l\'avant',
            'Pas trop petit',
            'Déséquilibre',
          ],
          'tips': [
            'Fais un pas assez grand pour que le genou avant soit à 90°',
            'Garde le torse droit',
            'Pousse sur le talon avant pour remonter',
            'Alterne les jambes de manière équilibrée',
          ],
        };

      case 'burpee':
        return {
          'equipment': 'Poids du corps',
          'secondaryMuscles': ['Épaules', 'Triceps', 'Quadriceps'],
          'commonMistakes': [
            'Mouvement trop rapide et mal exécuté',
            'Saut trop faible à la fin',
            'Planche mal positionnée',
            'Respiration non contrôlée',
          ],
          'tips': [
            'Prends le temps de bien exécuter chaque phase',
            'Saute haut à la fin pour maximiser l\'effort',
            'Commence lentement pour maîtriser le mouvement',
            'Respire régulièrement',
          ],
        };

      case 'deadlift':
        return {
          'equipment': 'Haltères',
          'secondaryMuscles': ['Ischio-jambiers', 'Trapèzes', 'Avant-bras'],
          'commonMistakes': [
            'Dos arrondi',
            'Barre trop éloignée du corps',
            'Genoux qui partent trop en avant',
            'Charge trop lourde',
          ],
          'tips': [
            'Garde le dos droit tout au long du mouvement',
            'La barre doit rester proche de tes jambes',
            'Pousse avec les jambes, pas avec le dos',
            'Commence avec une charge légère pour maîtriser la technique',
          ],
        };

      case 'bench_press':
        return {
          'equipment': 'Barre',
          'secondaryMuscles': ['Triceps', 'Épaules'],
          'commonMistakes': [
            'Rebond sur la poitrine',
            'Épaules qui se décollent du banc',
            'Amplitude incomplète',
            'Charge trop lourde',
          ],
          'tips': [
            'Contrôle la descente lentement',
            'Garde les épaules et les fessiers en contact avec le banc',
            'Descends jusqu\'à frôler la poitrine',
            'Expire en poussant',
          ],
        };

      default:
        return {
          'equipment': 'Poids du corps',
          'secondaryMuscles': [],
          'commonMistakes': [],
          'tips': [],
        };
    }
  }
}

