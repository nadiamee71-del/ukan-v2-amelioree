import 'package:flutter/foundation.dart';
import '../coach_personality/coach_personality_model.dart';

/// Modèle représentant une étape d'exercice dans une séance d'entraînement
class WorkoutStep {
  final String id;
  final String title;
  final String description;
  final int? durationSeconds; // Durée de l'exercice en secondes (null si pas de durée fixe)
  final int? restSeconds; // Temps de repos après l'exercice en secondes
  final String? imageAsset; // Chemin vers une image locale (optionnel)
  final String? videoUrl; // URL de vidéo (optionnel)
  final CoachStyle? coachStyleOverride; // Style de coach spécifique pour cette étape (optionnel)

  const WorkoutStep({
    required this.id,
    required this.title,
    required this.description,
    this.durationSeconds,
    this.restSeconds,
    this.imageAsset,
    this.videoUrl,
    this.coachStyleOverride,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'durationSeconds': durationSeconds,
        'restSeconds': restSeconds,
        'imageAsset': imageAsset,
        'videoUrl': videoUrl,
        'coachStyleOverride': coachStyleOverride?.toString(),
      };

  factory WorkoutStep.fromJson(Map<String, dynamic> json) {
    CoachStyle? coachStyle;
    if (json['coachStyleOverride'] != null) {
      try {
        coachStyle = CoachStyle.values.firstWhere(
          (e) => e.toString() == json['coachStyleOverride'],
        );
      } catch (e) {
        coachStyle = null;
      }
    }
    return WorkoutStep(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationSeconds: json['durationSeconds'] as int?,
      restSeconds: json['restSeconds'] as int?,
      imageAsset: json['imageAsset'] as String?,
      videoUrl: json['videoUrl'] as String?,
      coachStyleOverride: coachStyle,
    );
  }

  WorkoutStep copyWith({
    String? id,
    String? title,
    String? description,
    int? durationSeconds,
    int? restSeconds,
    String? imageAsset,
    String? videoUrl,
    CoachStyle? coachStyleOverride,
  }) {
    return WorkoutStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      imageAsset: imageAsset ?? this.imageAsset,
      videoUrl: videoUrl ?? this.videoUrl,
      coachStyleOverride: coachStyleOverride ?? this.coachStyleOverride,
    );
  }
}

