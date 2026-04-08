import 'package:flutter/foundation.dart';
import 'exercise_library_item.dart';

/// Notifier pour gérer les exercices personnels de l'utilisateur (mode démo)
class UserExercisesNotifier extends ChangeNotifier {
  static final UserExercisesNotifier _instance = UserExercisesNotifier._internal();
  factory UserExercisesNotifier() => _instance;
  UserExercisesNotifier._internal();

  final List<ExerciseLibraryItem> _userExercises = [];
  static const String _demoUserId = 'demo-user';

  /// ID de l'utilisateur actuel (démo)
  String get currentUserId => _demoUserId;

  /// Liste de tous les exercices personnels de l'utilisateur
  List<ExerciseLibraryItem> get userExercises => List.unmodifiable(_userExercises);

  /// Ajoute un exercice personnel
  void addUserExercise(ExerciseLibraryItem exercise) {
    _userExercises.add(exercise);
    notifyListeners();
  }

  /// Met à jour un exercice personnel
  void updateUserExercise(String exerciseId, ExerciseLibraryItem updatedExercise) {
    final index = _userExercises.indexWhere((e) => e.id == exerciseId);
    if (index != -1) {
      _userExercises[index] = updatedExercise;
      notifyListeners();
    }
  }

  /// Supprime un exercice personnel
  void deleteUserExercise(String exerciseId) {
    _userExercises.removeWhere((e) => e.id == exerciseId);
    notifyListeners();
  }

  /// Vérifie si un exercice appartient à l'utilisateur actuel
  bool isUserExercise(String exerciseId) {
    return _userExercises.any((e) => e.id == exerciseId);
  }

  /// Récupère un exercice personnel par son ID
  ExerciseLibraryItem? getUserExerciseById(String exerciseId) {
    try {
      return _userExercises.firstWhere((e) => e.id == exerciseId);
    } catch (e) {
      return null;
    }
  }

  /// Toggle le partage d'un exercice (maquette)
  void toggleExerciseShare(String exerciseId) {
    final index = _userExercises.indexWhere((e) => e.id == exerciseId);
    if (index != -1) {
      final exercise = _userExercises[index];
      _userExercises[index] = ExerciseLibraryItem(
        id: exercise.id,
        name: exercise.name,
        category: exercise.category,
        difficulty: exercise.difficulty,
        description: exercise.description,
        muscleGroup: exercise.muscleGroup,
        equipment: exercise.equipment,
        isBodyweight: exercise.isBodyweight,
        steps: exercise.steps,
        imageAsset: exercise.imageAsset,
        videoAsset: exercise.videoAsset,
        youtubeUrl: exercise.youtubeUrl,
        muscles: exercise.muscles,
        isPremium: exercise.isPremium,
        packId: exercise.packId,
        isOfficial: exercise.isOfficial,
        isUserCreated: exercise.isUserCreated,
        ownerUserId: exercise.ownerUserId,
        isShared: !exercise.isShared,
        perceivedDifficulty: exercise.perceivedDifficulty,
        videoUrl: exercise.videoUrl,
        secondaryMuscles: exercise.secondaryMuscles,
        commonMistakes: exercise.commonMistakes,
        tips: exercise.tips,
      );
      notifyListeners();
    }
  }
}

