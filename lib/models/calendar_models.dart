/// Modèles de données pour le calendrier d'exercices Ukan
/// Mode démo : stockage en mémoire uniquement

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TYPES D'OBJECTIFS
// ─────────────────────────────────────────────────────────────────────────────

enum CalendarGoalType {
  weightLoss,      // Perte de poids
  muscleGain,      // Prise de masse
  performance,     // Performance (ex: +20kg au squat)
  measurement,     // Mensuration (tour de taille, etc.)
  habit,           // Habitude (s'entraîner X fois/semaine)
  custom,          // Personnalisé
}

extension CalendarGoalTypeExtension on CalendarGoalType {
  String get displayName {
    switch (this) {
      case CalendarGoalType.weightLoss:
        return 'Perte de poids';
      case CalendarGoalType.muscleGain:
        return 'Prise de masse';
      case CalendarGoalType.performance:
        return 'Performance';
      case CalendarGoalType.measurement:
        return 'Mensuration';
      case CalendarGoalType.habit:
        return 'Habitude';
      case CalendarGoalType.custom:
        return 'Personnalisé';
    }
  }

  IconData get icon {
    switch (this) {
      case CalendarGoalType.weightLoss:
        return Icons.trending_down;
      case CalendarGoalType.muscleGain:
        return Icons.trending_up;
      case CalendarGoalType.performance:
        return Icons.emoji_events;
      case CalendarGoalType.measurement:
        return Icons.straighten;
      case CalendarGoalType.habit:
        return Icons.repeat;
      case CalendarGoalType.custom:
        return Icons.flag;
    }
  }

  Color get color {
    switch (this) {
      case CalendarGoalType.weightLoss:
        return const Color(0xFF4CAF50);
      case CalendarGoalType.muscleGain:
        return const Color(0xFF2196F3);
      case CalendarGoalType.performance:
        return const Color(0xFFFFC107);
      case CalendarGoalType.measurement:
        return const Color(0xFF9C27B0);
      case CalendarGoalType.habit:
        return const Color(0xFFFF5722);
      case CalendarGoalType.custom:
        return const Color(0xFF607D8B);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SÉRIE D'EXERCICE
// ─────────────────────────────────────────────────────────────────────────────

class ExerciseSet {
  final int setNumber;
  final int? reps;
  final double? weight;
  final Duration? restTime;
  final Duration? timeUnderTension;  // Pour gainage / chrono
  final String? notes;

  const ExerciseSet({
    required this.setNumber,
    this.reps,
    this.weight,
    this.restTime,
    this.timeUnderTension,
    this.notes,
  });

  ExerciseSet copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    Duration? restTime,
    Duration? timeUnderTension,
    String? notes,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      timeUnderTension: timeUnderTension ?? this.timeUnderTension,
      notes: notes ?? this.notes,
    );
  }

  String get summary {
    final parts = <String>[];
    if (reps != null) parts.add('$reps reps');
    if (weight != null) parts.add('${weight!.toStringAsFixed(1)} kg');
    if (timeUnderTension != null) {
      parts.add('${timeUnderTension!.inSeconds}s');
    }
    return parts.isEmpty ? 'Série $setNumber' : parts.join(' × ');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SNAPSHOT MENSURATIONS / POIDS
// ─────────────────────────────────────────────────────────────────────────────

class BodyMetricsSnapshot {
  final String id;
  final DateTime measuredAt;
  final double? weightKg;
  final double? bodyFatPercent;
  final double? waistCm;
  final double? hipsCm;
  final double? chestCm;
  final double? armsCm;
  final double? thighsCm;
  final String? notes;
  final List<String> photoPaths;

  const BodyMetricsSnapshot({
    required this.id,
    required this.measuredAt,
    this.weightKg,
    this.bodyFatPercent,
    this.waistCm,
    this.hipsCm,
    this.chestCm,
    this.armsCm,
    this.thighsCm,
    this.notes,
    this.photoPaths = const [],
  });

  BodyMetricsSnapshot copyWith({
    String? id,
    DateTime? measuredAt,
    double? weightKg,
    double? bodyFatPercent,
    double? waistCm,
    double? hipsCm,
    double? chestCm,
    double? armsCm,
    double? thighsCm,
    String? notes,
    List<String>? photoPaths,
  }) {
    return BodyMetricsSnapshot(
      id: id ?? this.id,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      chestCm: chestCm ?? this.chestCm,
      armsCm: armsCm ?? this.armsCm,
      thighsCm: thighsCm ?? this.thighsCm,
      notes: notes ?? this.notes,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  bool get hasAnyMeasurement => 
    weightKg != null || 
    bodyFatPercent != null || 
    waistCm != null || 
    hipsCm != null ||
    chestCm != null ||
    armsCm != null ||
    thighsCm != null;
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRÉE HISTORIQUE D'EXERCICE (UN EXERCICE FAIT UN JOUR DONNÉ)
// ─────────────────────────────────────────────────────────────────────────────

class ExerciseHistoryEntry {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String? exerciseCategory;
  final String? muscleGroup;
  final DateTime date;
  final List<ExerciseSet> sets;
  final double? perceivedDifficulty;  // Échelle 1-10 (RPE)
  final String? notes;
  final List<String> photoPaths;
  final Duration? totalDuration;

  const ExerciseHistoryEntry({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseCategory,
    this.muscleGroup,
    required this.date,
    required this.sets,
    this.perceivedDifficulty,
    this.notes,
    this.photoPaths = const [],
    this.totalDuration,
  });

  ExerciseHistoryEntry copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    String? exerciseCategory,
    String? muscleGroup,
    DateTime? date,
    List<ExerciseSet>? sets,
    double? perceivedDifficulty,
    String? notes,
    List<String>? photoPaths,
    Duration? totalDuration,
  }) {
    return ExerciseHistoryEntry(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseCategory: exerciseCategory ?? this.exerciseCategory,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      date: date ?? this.date,
      sets: sets ?? this.sets,
      perceivedDifficulty: perceivedDifficulty ?? this.perceivedDifficulty,
      notes: notes ?? this.notes,
      photoPaths: photoPaths ?? this.photoPaths,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  /// Volume total (somme des kg × reps)
  double get totalVolume {
    double volume = 0;
    for (final set in sets) {
      if (set.reps != null && set.weight != null) {
        volume += set.reps! * set.weight!;
      }
    }
    return volume;
  }

  /// Résumé des séries
  String get setsSummary {
    if (sets.isEmpty) return 'Aucune série';
    final repsStr = sets.where((s) => s.reps != null).map((s) => s.reps).join('/');
    final maxWeight = sets.where((s) => s.weight != null).map((s) => s.weight!).fold<double>(0, (a, b) => a > b ? a : b);
    if (repsStr.isEmpty) return '${sets.length} séries';
    return '${sets.length} séries – $repsStr reps${maxWeight > 0 ? ' – ${maxWeight.toStringAsFixed(0)} kg max' : ''}';
  }

  /// Couleur de difficulté
  Color get difficultyColor {
    if (perceivedDifficulty == null) return Colors.grey;
    if (perceivedDifficulty! <= 3) return Colors.green;
    if (perceivedDifficulty! <= 5) return Colors.lightGreen;
    if (perceivedDifficulty! <= 7) return Colors.orange;
    if (perceivedDifficulty! <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  /// Label de difficulté
  String get difficultyLabel {
    if (perceivedDifficulty == null) return 'Non évaluée';
    if (perceivedDifficulty! <= 2) return 'Très facile';
    if (perceivedDifficulty! <= 4) return 'Facile';
    if (perceivedDifficulty! <= 6) return 'Modéré';
    if (perceivedDifficulty! <= 8) return 'Difficile';
    return 'Très difficile';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RAPPEL D'OBJECTIF (STYLE DOCTOLIB)
// ─────────────────────────────────────────────────────────────────────────────

class GoalReminder {
  final String id;
  final DateTime reminderDateTime;
  final String? customMessage;
  final bool isSent;

  const GoalReminder({
    required this.id,
    required this.reminderDateTime,
    this.customMessage,
    this.isSent = false,
  });

  GoalReminder copyWith({
    String? id,
    DateTime? reminderDateTime,
    String? customMessage,
    bool? isSent,
  }) {
    return GoalReminder(
      id: id ?? this.id,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      customMessage: customMessage ?? this.customMessage,
      isSent: isSent ?? this.isSent,
    );
  }

  /// Vérifie si le rappel est dû
  bool isDue(DateTime now) => !isSent && reminderDateTime.isBefore(now);

  /// Temps restant avant le rappel
  Duration timeUntil(DateTime now) => reminderDateTime.difference(now);
}

// ─────────────────────────────────────────────────────────────────────────────
// OBJECTIF CALENDRIER
// ─────────────────────────────────────────────────────────────────────────────

class CalendarGoal {
  final String id;
  final String title;
  final String? description;
  final DateTime targetDate;
  final DateTime createdAt;
  final double? targetValue;
  final String? unit;  // kg, cm, reps, etc.
  final double? startValue;
  final double? currentValue;
  final CalendarGoalType type;
  final List<GoalReminder> reminders;
  final bool isCompleted;
  final String? linkedExerciseId;  // Lien avec un exercice spécifique

  const CalendarGoal({
    required this.id,
    required this.title,
    this.description,
    required this.targetDate,
    required this.createdAt,
    this.targetValue,
    this.unit,
    this.startValue,
    this.currentValue,
    required this.type,
    this.reminders = const [],
    this.isCompleted = false,
    this.linkedExerciseId,
  });

  CalendarGoal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? targetDate,
    DateTime? createdAt,
    double? targetValue,
    String? unit,
    double? startValue,
    double? currentValue,
    CalendarGoalType? type,
    List<GoalReminder>? reminders,
    bool? isCompleted,
    String? linkedExerciseId,
  }) {
    return CalendarGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      startValue: startValue ?? this.startValue,
      currentValue: currentValue ?? this.currentValue,
      type: type ?? this.type,
      reminders: reminders ?? this.reminders,
      isCompleted: isCompleted ?? this.isCompleted,
      linkedExerciseId: linkedExerciseId ?? this.linkedExerciseId,
    );
  }

  /// Progression vers l'objectif (0.0 à 1.0)
  double get progress {
    if (startValue == null || targetValue == null || currentValue == null) {
      return isCompleted ? 1.0 : 0.0;
    }
    final total = (targetValue! - startValue!).abs();
    if (total == 0) return isCompleted ? 1.0 : 0.0;
    final current = (currentValue! - startValue!).abs();
    return (current / total).clamp(0.0, 1.0);
  }

  /// Jours restants
  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  /// Est en retard ?
  bool get isOverdue => daysRemaining < 0 && !isCompleted;

  /// Label de statut
  String get statusLabel {
    if (isCompleted) return '✅ Atteint';
    if (isOverdue) return '⏰ En retard';
    if (daysRemaining == 0) return '🎯 Jour J !';
    if (daysRemaining <= 7) return '📅 $daysRemaining j restants';
    return '📆 $daysRemaining jours';
  }

  /// Couleur de statut
  Color get statusColor {
    if (isCompleted) return Colors.green;
    if (isOverdue) return Colors.red;
    if (daysRemaining <= 3) return Colors.orange;
    return Colors.blue;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DONNÉES D'UN JOUR DU CALENDRIER (AGRÉGATION)
// ─────────────────────────────────────────────────────────────────────────────

class CalendarDayData {
  final DateTime date;
  final List<ExerciseHistoryEntry> exercises;
  final List<CalendarGoal> goals;
  final BodyMetricsSnapshot? bodyMetrics;

  const CalendarDayData({
    required this.date,
    this.exercises = const [],
    this.goals = const [],
    this.bodyMetrics,
  });

  bool get hasData => exercises.isNotEmpty || goals.isNotEmpty || bodyMetrics != null;

  bool get hasExercises => exercises.isNotEmpty;
  bool get hasGoals => goals.isNotEmpty;
  bool get hasMetrics => bodyMetrics != null;

  /// Volume total du jour
  double get totalVolume {
    return exercises.fold(0.0, (sum, e) => sum + e.totalVolume);
  }

  /// Nombre total de séries
  int get totalSets {
    return exercises.fold(0, (sum, e) => sum + e.sets.length);
  }

  /// Difficulté moyenne
  double? get averageDifficulty {
    final withDifficulty = exercises.where((e) => e.perceivedDifficulty != null).toList();
    if (withDifficulty.isEmpty) return null;
    return withDifficulty.fold(0.0, (sum, e) => sum + e.perceivedDifficulty!) / withDifficulty.length;
  }
}





