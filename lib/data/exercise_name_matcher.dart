import '../models/exercise_library_item.dart';
import 'demo_exercises.dart';

/// Helper pour matcher les noms d'exercices dans les descriptions de séances
class ExerciseNameMatcher {
  /// Extrait les noms d'exercices d'une description
  /// et retourne les ExerciseLibraryItem correspondants
  static List<ExerciseLibraryItem> findExercisesInDescription(String description) {
    final exercises = <ExerciseLibraryItem>[];
    final lowerDescription = description.toLowerCase();
    
    // Mapping des mots-clés vers les IDs d'exercices
    final keywordToExerciseId = {
      'squat': 'squat_bodyweight',
      'squats': 'squat_bodyweight',
      'pompe': 'pushup',
      'pompes': 'pushup',
      'gainage': 'plank',
      'planche': 'plank',
      'plank': 'plank',
      'fente': 'lunges',
      'fentes': 'lunges',
      'lunges': 'lunges',
      'burpee': 'burpee',
      'burpees': 'burpee',
      'rowing': 'row_bodyweight', // Cherche dans la bibliothèque
      'row': 'row_bodyweight',
      'cardio': null, // Trop générique
      'étirement': null,
      'étirements': null,
      'mobilité': null,
      'échauffement': null,
    };
    
    // Chercher les exercices dans la description
    for (final entry in keywordToExerciseId.entries) {
      if (entry.value == null) continue;
      
      final keyword = entry.key;
      if (lowerDescription.contains(keyword)) {
        final exercise = _findExerciseById(entry.value!);
        if (exercise != null && !exercises.contains(exercise)) {
          exercises.add(exercise);
        }
      }
    }
    
    return exercises;
  }
  
  /// Trouve un exercice par son ID
  static ExerciseLibraryItem? _findExerciseById(String id) {
    try {
      return DemoExercises.allExercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Récupère un exercice par son nom (fuzzy matching)
  static ExerciseLibraryItem? findExerciseByName(String name) {
    final lowerName = name.toLowerCase().trim();
    
    // Essayer un match exact d'abord
    try {
      return DemoExercises.allExercises.firstWhere(
        (e) => e.name.toLowerCase() == lowerName,
      );
    } catch (e) {
      // Essayer un match partiel
      try {
        return DemoExercises.allExercises.firstWhere(
          (e) => e.name.toLowerCase().contains(lowerName) || 
                 lowerName.contains(e.name.toLowerCase()),
        );
      } catch (e) {
        return null;
      }
    }
  }
}

