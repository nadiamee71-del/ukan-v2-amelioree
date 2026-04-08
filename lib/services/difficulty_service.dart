import '../models/difficulty_entry.dart';

/// Service pour gérer les évaluations de difficulté (stockage en mémoire pour l'instant)
class DifficultyService {
  static final DifficultyService _instance = DifficultyService._internal();
  factory DifficultyService() => _instance;
  DifficultyService._internal();

  // Stockage en mémoire (sera remplacé par une base de données plus tard)
  final List<DifficultyEntry> _entries = [];

  /// Enregistre une nouvelle évaluation de difficulté
  Future<void> saveDifficulty(DifficultyEntry entry) async {
    // Vérifier si une entrée avec le même id existe déjà
    final existingIndex = _entries.indexWhere((e) => e.id == entry.id);
    if (existingIndex >= 0) {
      _entries[existingIndex] = entry;
    } else {
      _entries.add(entry);
    }
  }

  /// Récupère toutes les évaluations de difficulté
  Future<List<DifficultyEntry>> getAll() async {
    return List.unmodifiable(_entries);
  }

  /// Récupère toutes les évaluations pour une séance donnée
  Future<List<DifficultyEntry>> getBySession(String sessionId) async {
    return _entries.where((entry) => entry.sessionId == sessionId).toList();
  }

  /// Récupère toutes les évaluations pour un exercice donné
  Future<List<DifficultyEntry>> getByExercise(String exerciseId) async {
    return _entries.where((entry) => entry.exerciseId == exerciseId).toList();
  }

  /// Récupère toutes les évaluations pour une date donnée
  Future<List<DifficultyEntry>> getByDate(DateTime date) async {
    return _entries.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  /// Supprime une évaluation de difficulté
  Future<void> deleteDifficulty(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
  }
}
