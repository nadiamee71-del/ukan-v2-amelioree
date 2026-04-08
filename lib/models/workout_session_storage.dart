import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_session.dart';
import 'workout_program.dart';

/// Service de stockage persistant pour les séances d'entraînement
class WorkoutSessionStorage {
  static const String _sessionsKey = 'workout_sessions';
  static const String _programsKey = 'workout_programs';

  /// Sauvegarder une séance
  static Future<void> saveSession(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllSessions();
    
    // Remplacer ou ajouter la séance
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }
    
    // Trier par date (plus récent en premier)
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    // Sauvegarder
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(jsonList));
  }

  /// Récupérer toutes les séances
  static Future<List<WorkoutSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => WorkoutSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors du chargement des séances: $e');
      return [];
    }
  }

  /// Récupérer une séance par ID
  static Future<WorkoutSession?> getSessionById(String id) async {
    final sessions = await getAllSessions();
    try {
      return sessions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Supprimer une séance
  static Future<void> deleteSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllSessions();
    sessions.removeWhere((s) => s.id == id);
    
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(jsonList));
  }

  /// Supprimer toutes les séances
  static Future<void> deleteAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
  }

  /// Récupérer toutes les performances d'un exercice spécifique
  static Future<List<ExercisePerformance>> getExercisePerformances(String exerciseId) async {
    final sessions = await getAllSessions();
    final performances = <ExercisePerformance>[];
    
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        if (exercise.exerciseId == exerciseId) {
          performances.add(exercise);
        }
      }
    }
    
    // Trier par date (plus récent en premier)
    performances.sort((a, b) {
      final aDate = a.completedAt ?? a.startedAt ?? DateTime.now();
      final bDate = b.completedAt ?? b.startedAt ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    
    return performances;
  }

  /// Récupérer l'historique d'un exercice avec les séances associées
  static Future<List<MapEntry<WorkoutSession, ExercisePerformance>>> getExerciseHistory(
      String exerciseId) async {
    final sessions = await getAllSessions();
    final history = <MapEntry<WorkoutSession, ExercisePerformance>>[];
    
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        if (exercise.exerciseId == exerciseId) {
          history.add(MapEntry(session, exercise));
        }
      }
    }
    
    // Trier par date (plus récent en premier)
    history.sort((a, b) {
      return b.key.startTime.compareTo(a.key.startTime);
    });
    
    return history;
  }

  // ========== GESTION DES PROGRAMMES ==========

  /// Sauvegarder un programme
  static Future<void> saveProgram(WorkoutProgram program) async {
    final prefs = await SharedPreferences.getInstance();
    final programs = await getAllPrograms();
    
    // Remplacer ou ajouter le programme
    final index = programs.indexWhere((p) => p.id == program.id);
    if (index >= 0) {
      programs[index] = program.copyWith(updatedAt: DateTime.now());
    } else {
      programs.add(program);
    }
    
    // Trier par date de création (plus récent en premier)
    programs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Sauvegarder
    final jsonList = programs.map((p) => p.toJson()).toList();
    await prefs.setString(_programsKey, jsonEncode(jsonList));
  }

  /// Récupérer tous les programmes
  static Future<List<WorkoutProgram>> getAllPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_programsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => WorkoutProgram.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors du chargement des programmes: $e');
      return [];
    }
  }

  /// Récupérer un programme par ID
  static Future<WorkoutProgram?> getProgramById(String id) async {
    final programs = await getAllPrograms();
    try {
      return programs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Supprimer un programme
  static Future<void> deleteProgram(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final programs = await getAllPrograms();
    programs.removeWhere((p) => p.id == id);
    
    final jsonList = programs.map((p) => p.toJson()).toList();
    await prefs.setString(_programsKey, jsonEncode(jsonList));
  }

  /// Supprimer tous les programmes
  static Future<void> deleteAllPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_programsKey);
  }
}

