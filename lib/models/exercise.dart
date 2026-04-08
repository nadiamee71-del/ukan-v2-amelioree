import 'exercise_library_item.dart';

/// Modèle complet d'un exercice pour la bibliothèque Ukan
/// Utilisé dans la bibliothèque d'exercices avec toutes les informations détaillées
/// (Différent du modèle Exercise dans coach_programs.dart qui est pour les programmes)
class ExerciseLibrary {
  final String id;
  final String name;
  final String category; // Bas du corps / Haut du corps / Full body / Cardio / etc.
  final String equipment; // Poids du corps / Haltères / Élastique / Barre / etc.
  final ExerciseDifficulty difficulty; // Débutant / Intermédiaire / Avancé
  final List<String> mainMuscles; // Muscles principaux sollicités
  final List<String> secondaryMuscles; // Muscles secondaires
  final String? videoUrl; // URL de la vidéo (optionnel)
  final List<String> imageUrls; // Liste d'URLs d'images (optionnel)
  final String description; // Description globale de l'exercice
  final List<String> steps; // Instructions étape par étape (1., 2., 3.…)
  final List<String> commonMistakes; // Erreurs fréquentes à éviter
  final List<String> tips; // Conseils pour bien exécuter l'exercice

  const ExerciseLibrary({
    required this.id,
    required this.name,
    required this.category,
    required this.equipment,
    required this.difficulty,
    required this.mainMuscles,
    this.secondaryMuscles = const [],
    this.videoUrl,
    this.imageUrls = const [],
    required this.description,
    required this.steps,
    this.commonMistakes = const [],
    this.tips = const [],
  });

  /// Convertit un ExerciseLibraryItem en ExerciseLibrary
  factory ExerciseLibrary.fromLibraryItem(ExerciseLibraryItem item) {
    return ExerciseLibrary(
      id: item.id,
      name: item.name,
      category: item.category,
      equipment: 'Poids du corps', // Par défaut
      difficulty: item.difficulty,
      mainMuscles: item.muscles,
      secondaryMuscles: [],
      videoUrl: item.youtubeUrl,
      imageUrls: item.imageAsset != null ? [item.imageAsset!] : [],
      description: item.description,
      steps: item.steps,
      commonMistakes: [],
      tips: [],
    );
  }

  /// Convertit un ExerciseLibrary en ExerciseLibraryItem (pour compatibilité)
  ExerciseLibraryItem toLibraryItem() {
    // Déterminer le groupe musculaire et l'équipement à partir de la catégorie
    String muscleGroup = 'Autres';
    String equipment = 'poids du corps';
    bool isBodyweight = true;

    if (category.toLowerCase().contains('jambes')) {
      muscleGroup = 'Jambes';
    } else if (category.toLowerCase().contains('haut') || category.toLowerCase().contains('pecto')) {
      muscleGroup = 'Pectoraux';
    } else if (category.toLowerCase().contains('abdo')) {
      muscleGroup = 'Abdominaux';
    } else if (category.toLowerCase().contains('cardio')) {
      muscleGroup = 'Cardio';
      equipment = 'cardio';
      isBodyweight = false;
    }

    return ExerciseLibraryItem(
      id: id,
      name: name,
      category: category,
      difficulty: difficulty,
      description: description,
      steps: steps,
      imageAsset: imageUrls.isNotEmpty ? imageUrls.first : null,
      videoAsset: null,
      youtubeUrl: videoUrl,
      muscles: mainMuscles,
      muscleGroup: muscleGroup,
      equipment: equipment,
      isBodyweight: isBodyweight,
      isPremium: false,
      packId: null,
    );
  }
}

