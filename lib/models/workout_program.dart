import 'package:flutter/foundation.dart';

/// Modèle représentant un exercice dans un programme d'entraînement
class ProgramExercise {
  final String exerciseId; // ID de l'exercice depuis la bibliothèque
  final String exerciseName; // Nom de l'exercice
  final int? targetSets; // Nombre de séries cibles (ex: 4)
  final int? targetReps; // Nombre de répétitions cibles (ex: 20, null si "max reps")
  final bool isMaxReps; // Si true, l'objectif est "max reps"
  final double? targetWeight; // Poids cible (optionnel)
  final String? notes; // Notes pour cet exercice dans le programme

  ProgramExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.targetSets,
    this.targetReps,
    this.isMaxReps = false,
    this.targetWeight,
    this.notes,
  });

  String get targetDescription {
    if (targetSets == null) return '';
    if (isMaxReps) {
      return '$targetSets x max reps';
    } else if (targetReps != null) {
      return '$targetSets x $targetReps reps';
    }
    return '$targetSets séries';
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'isMaxReps': isMaxReps,
        'targetWeight': targetWeight,
        'notes': notes,
      };

  factory ProgramExercise.fromJson(Map<String, dynamic> json) => ProgramExercise(
        exerciseId: json['exerciseId'] as String,
        exerciseName: json['exerciseName'] as String,
        targetSets: json['targetSets'] as int?,
        targetReps: json['targetReps'] as int?,
        isMaxReps: json['isMaxReps'] as bool? ?? false,
        targetWeight: (json['targetWeight'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );

  ProgramExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? targetSets,
    int? targetReps,
    bool? isMaxReps,
    double? targetWeight,
    String? notes,
  }) {
    return ProgramExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      isMaxReps: isMaxReps ?? this.isMaxReps,
      targetWeight: targetWeight ?? this.targetWeight,
      notes: notes ?? this.notes,
    );
  }
}

/// Modèle représentant un jour d'entraînement dans un programme
class ProgramDay {
  final String id;
  final String name; // Ex: "Jour 1 - Pectoraux/Biceps"
  final int dayNumber; // Numéro du jour (1, 2, 3...)
  final List<ProgramExercise> exercises; // Liste des exercices pour ce jour
  final String? notes; // Notes pour ce jour

  ProgramDay({
    required this.id,
    required this.name,
    required this.dayNumber,
    required this.exercises,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dayNumber': dayNumber,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'notes': notes,
      };

  factory ProgramDay.fromJson(Map<String, dynamic> json) => ProgramDay(
        id: json['id'] as String,
        name: json['name'] as String,
        dayNumber: json['dayNumber'] as int,
        exercises: (json['exercises'] as List)
            .map((e) => ProgramExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
      );

  ProgramDay copyWith({
    String? id,
    String? name,
    int? dayNumber,
    List<ProgramExercise>? exercises,
    String? notes,
  }) {
    return ProgramDay(
      id: id ?? this.id,
      name: name ?? this.name,
      dayNumber: dayNumber ?? this.dayNumber,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
    );
  }
}

/// Modèle représentant un programme d'entraînement complet
class WorkoutProgram {
  final String id;
  final String name; // Ex: "Prise de masse - Split - 3 jours"
  final String? objective; // Ex: "Objectif: prise de volume sur 3 séances par semaine"
  final int sessionsPerWeek; // Nombre de séances par semaine
  final List<ProgramDay> days; // Liste des jours d'entraînement
  final String? colorCode; // Code couleur (ex: "F" pour Fullbody, "P" pour Prise de masse)
  final ColorType colorType; // Type de couleur (blue, red, green, orange, etc.)
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkoutProgram({
    required this.id,
    required this.name,
    this.objective,
    required this.sessionsPerWeek,
    required this.days,
    this.colorCode,
    this.colorType = ColorType.blue,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'objective': objective,
        'sessionsPerWeek': sessionsPerWeek,
        'days': days.map((d) => d.toJson()).toList(),
        'colorCode': colorCode,
        'colorType': colorType.toString(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    ColorType colorType = ColorType.blue;
    try {
      colorType = ColorType.values.firstWhere(
        (e) => e.toString() == json['colorType'],
        orElse: () => ColorType.blue,
      );
    } catch (e) {
      // Utiliser la valeur par défaut
    }

    return WorkoutProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      objective: json['objective'] as String?,
      sessionsPerWeek: json['sessionsPerWeek'] as int,
      days: (json['days'] as List)
          .map((d) => ProgramDay.fromJson(d as Map<String, dynamic>))
          .toList(),
      colorCode: json['colorCode'] as String?,
      colorType: colorType,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  WorkoutProgram copyWith({
    String? id,
    String? name,
    String? objective,
    int? sessionsPerWeek,
    List<ProgramDay>? days,
    String? colorCode,
    ColorType? colorType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      objective: objective ?? this.objective,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      days: days ?? this.days,
      colorCode: colorCode ?? this.colorCode,
      colorType: colorType ?? this.colorType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Type de couleur pour les programmes
enum ColorType {
  blue,
  red,
  green,
  orange,
  brown,
  purple,
  yellow,
}

extension ColorTypeExtension on ColorType {
  String get displayName {
    switch (this) {
      case ColorType.blue:
        return 'Bleu';
      case ColorType.red:
        return 'Rouge';
      case ColorType.green:
        return 'Vert';
      case ColorType.orange:
        return 'Orange';
      case ColorType.brown:
        return 'Marron';
      case ColorType.purple:
        return 'Violet';
      case ColorType.yellow:
        return 'Jaune';
    }
  }
}











