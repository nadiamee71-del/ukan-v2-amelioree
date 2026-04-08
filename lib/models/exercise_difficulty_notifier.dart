import 'package:flutter/foundation.dart';

/// Niveaux de difficulté ressentie
enum PerceivedDifficulty {
  veryEasy,
  easy,
  medium,
  hard,
  veryHard,
}

extension PerceivedDifficultyX on PerceivedDifficulty {
  String get displayName {
    switch (this) {
      case PerceivedDifficulty.veryEasy:
        return 'Très facile';
      case PerceivedDifficulty.easy:
        return 'Facile';
      case PerceivedDifficulty.medium:
        return 'Moyen';
      case PerceivedDifficulty.hard:
        return 'Difficile';
      case PerceivedDifficulty.veryHard:
        return 'Très difficile';
    }
  }

  String get value {
    switch (this) {
      case PerceivedDifficulty.veryEasy:
        return 'Très facile';
      case PerceivedDifficulty.easy:
        return 'Facile';
      case PerceivedDifficulty.medium:
        return 'Moyen';
      case PerceivedDifficulty.hard:
        return 'Difficile';
      case PerceivedDifficulty.veryHard:
        return 'Très difficile';
    }
  }
}

/// Entrée de difficulté ressentie pour un exercice
class ExerciseDifficultyEntry {
  final String exerciseId;
  final String exerciseName;
  final PerceivedDifficulty difficulty;
  final DateTime date;

  ExerciseDifficultyEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.difficulty,
    required this.date,
  });
}

/// Notifier pour gérer les difficultés ressenties par exercice (mode démo)
class ExerciseDifficultyNotifier extends ChangeNotifier {
  static final ExerciseDifficultyNotifier _instance = ExerciseDifficultyNotifier._internal();
  factory ExerciseDifficultyNotifier() => _instance;
  ExerciseDifficultyNotifier._internal();

  final List<ExerciseDifficultyEntry> _entries = [];

  /// Liste de toutes les entrées
  List<ExerciseDifficultyEntry> get allEntries => List.unmodifiable(_entries);

  /// Ajoute une difficulté ressentie pour un exercice
  void addDifficultyEntry({
    required String exerciseId,
    required String exerciseName,
    required PerceivedDifficulty difficulty,
  }) {
    _entries.add(ExerciseDifficultyEntry(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      difficulty: difficulty,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Récupère la dernière difficulté ressentie pour un exercice
  PerceivedDifficulty? getLastDifficulty(String exerciseId) {
    final entries = _entries.where((e) => e.exerciseId == exerciseId).toList();
    if (entries.isEmpty) return null;
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries.first.difficulty;
  }

  /// Récupère la difficulté ressentie moyenne pour un exercice
  PerceivedDifficulty? getAverageDifficulty(String exerciseId) {
    final entries = _entries.where((e) => e.exerciseId == exerciseId).toList();
    if (entries.isEmpty) return null;

    // Calculer la moyenne (1=veryEasy, 5=veryHard)
    final sum = entries.fold<int>(0, (sum, entry) {
      switch (entry.difficulty) {
        case PerceivedDifficulty.veryEasy:
          return sum + 1;
        case PerceivedDifficulty.easy:
          return sum + 2;
        case PerceivedDifficulty.medium:
          return sum + 3;
        case PerceivedDifficulty.hard:
          return sum + 4;
        case PerceivedDifficulty.veryHard:
          return sum + 5;
      }
    });

    final average = (sum / entries.length).round();

    switch (average) {
      case 1:
        return PerceivedDifficulty.veryEasy;
      case 2:
        return PerceivedDifficulty.easy;
      case 3:
        return PerceivedDifficulty.medium;
      case 4:
        return PerceivedDifficulty.hard;
      case 5:
        return PerceivedDifficulty.veryHard;
      default:
        return PerceivedDifficulty.medium;
    }
  }

  /// Récupère toutes les difficultés pour un exercice
  List<ExerciseDifficultyEntry> getDifficultiesForExercise(String exerciseId) {
    return _entries.where((e) => e.exerciseId == exerciseId).toList();
  }

  /// Vérifie si une difficulté a déjà été notée pour un exercice
  bool hasDifficultyEntry(String exerciseId) {
    return _entries.any((e) => e.exerciseId == exerciseId);
  }
}

