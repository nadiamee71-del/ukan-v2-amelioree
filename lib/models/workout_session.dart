import 'package:flutter/foundation.dart';

/// Type de série d'exercice
enum SetType {
  reps,          // Séries classiques : reps + charge
  time,          // Séries en temps (gainage, chaise…)
  mixed,         // éventuellement : reps + temps
}

/// Modèle représentant une série d'exercice (série avec répétitions, charge, etc.)
class ExerciseSet {
  final int setNumber; // Numéro de la série (1, 2, 3...)
  final SetType type; // Type de série (reps, time, mixed)
  final int? reps; // Nombre de répétitions
  final double? weight; // Charge en kg
  final int? durationSeconds; // Durée en secondes (pour séries en temps)
  final int? restSeconds; // Temps de repos en secondes
  final String? notes; // Notes optionnelles pour cette série
  final DateTime? completedAt; // Heure de fin de la série
  final bool isBestSet; // Marquer comme meilleure série (record perso)

  ExerciseSet({
    required this.setNumber,
    this.type = SetType.reps,
    this.reps,
    this.weight,
    this.durationSeconds,
    this.restSeconds,
    this.notes,
    this.completedAt,
    this.isBestSet = false,
  });

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'type': type.name,
        'reps': reps,
        'weight': weight,
        'durationSeconds': durationSeconds,
        'restSeconds': restSeconds,
        'notes': notes,
        'completedAt': completedAt?.toIso8601String(),
        'isBestSet': isBestSet,
      };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    // Gérer la compatibilité avec les anciennes données
    SetType type = SetType.reps;
    if (json['type'] != null) {
      try {
        type = SetType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => SetType.reps,
        );
      } catch (e) {
        // Si type non trouvé, déterminer selon les données
        if (json['durationSeconds'] != null) {
          type = SetType.time;
        } else if (json['reps'] != null) {
          type = SetType.reps;
        }
      }
    } else {
      // Ancien format : déterminer le type selon les données
      if (json['durationSeconds'] != null) {
        type = SetType.time;
      }
    }

    return ExerciseSet(
      setNumber: json['setNumber'] as int,
      type: type,
      reps: json['reps'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      durationSeconds: json['durationSeconds'] as int?,
      restSeconds: json['restSeconds'] as int?,
      notes: json['notes'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isBestSet: json['isBestSet'] as bool? ?? false,
    );
  }

  ExerciseSet copyWith({
    int? setNumber,
    SetType? type,
    int? reps,
    double? weight,
    int? durationSeconds,
    int? restSeconds,
    String? notes,
    DateTime? completedAt,
    bool? isBestSet,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      type: type ?? this.type,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      isBestSet: isBestSet ?? this.isBestSet,
    );
  }
}

/// Modèle représentant la performance d'un exercice dans une séance
class ExercisePerformance {
  final String exerciseId; // ID de l'exercice depuis la bibliothèque
  final String exerciseName; // Nom de l'exercice (pour référence)
  final List<ExerciseSet> sets; // Liste des séries effectuées
  final String? notes; // Notes générales pour cet exercice dans la séance
  final DateTime? startedAt; // Heure de début de l'exercice
  final DateTime? completedAt; // Heure de fin de l'exercice

  ExercisePerformance({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    this.notes,
    this.startedAt,
    this.completedAt,
  });

  // Calculer le volume total (somme de toutes les charges × répétitions)
  double get totalVolume {
    return sets.fold(0.0, (sum, set) {
      if (set.weight != null && set.reps != null) {
        return sum + (set.weight! * set.reps!);
      }
      return sum;
    });
  }

  // Calculer la charge maximale (1RM estimé ou max de la séance)
  double? get maxWeight {
    final weights = sets.where((s) => s.weight != null).map((s) => s.weight!).toList();
    return weights.isEmpty ? null : weights.reduce((a, b) => a > b ? a : b);
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'sets': sets.map((s) => s.toJson()).toList(),
        'notes': notes,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory ExercisePerformance.fromJson(Map<String, dynamic> json) => ExercisePerformance(
        exerciseId: json['exerciseId'] as String,
        exerciseName: json['exerciseName'] as String,
        sets: (json['sets'] as List<dynamic>)
            .map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );

  ExercisePerformance copyWith({
    String? exerciseId,
    String? exerciseName,
    List<ExerciseSet>? sets,
    String? notes,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ExercisePerformance(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Modèle représentant une séance d'entraînement complète
class WorkoutSession {
  final String id; // ID unique de la séance
  final String? name; // Nom optionnel de la séance
  final DateTime startTime; // Heure de début
  final DateTime? endTime; // Heure de fin
  final List<ExercisePerformance> exercises; // Liste des exercices effectués
  final String? notes; // Notes générales sur la séance
  final String? programId; // ID du programme si la séance fait partie d'un programme

  WorkoutSession({
    required this.id,
    this.name,
    required this.startTime,
    this.endTime,
    required this.exercises,
    this.notes,
    this.programId,
  });

  // Durée de la séance en minutes
  int? get durationMinutes {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  // Volume total de la séance (somme de tous les volumes d'exercices)
  double get totalVolume {
    return exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'notes': notes,
        'programId': programId,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String,
        name: json['name'] as String?,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => ExercisePerformance.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
        programId: json['programId'] as String?,
      );

  WorkoutSession copyWith({
    String? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<ExercisePerformance>? exercises,
    String? notes,
    String? programId,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      programId: programId ?? this.programId,
    );
  }
}
