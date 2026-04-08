import 'package:flutter/foundation.dart';

/// ─────────────────────────────────────────────
/// Profil de match pour Buddy Workout
/// ─────────────────────────────────────────────

class MatchProfile {
  final String id;
  final String name;
  final int age;
  final String? photoUrl;
  final String level; // Débutant, Intermédiaire, Avancé, Expert
  final List<String> goals; // Objectifs sportifs
  final String availability; // Matin, Après-midi, Soir, Flexible
  final double? latitude;
  final double? longitude;
  final String city;
  final double distance; // Distance en km
  final Map<String, dynamic> sportPreferences; // Type de sport préféré
  final String sportCharacter; // Motivé, Relax, Compétitif, Social
  final int compatibilityScore; // Score de compatibilité (0-100)
  final DateTime createdAt;
  
  // Nouveaux champs pour Buddy Workout PRO
  final List<String> equipment; // Matériel disponible
  final String motivation; // Niveau de motivation
  final String trainingFrequency; // Fréquence d'entraînement
  final String? bio; // Description personnelle
  final String? gender; // Genre

  MatchProfile({
    required this.id,
    required this.name,
    required this.age,
    this.photoUrl,
    required this.level,
    required this.goals,
    required this.availability,
    this.latitude,
    this.longitude,
    required this.city,
    required this.distance,
    required this.sportPreferences,
    required this.sportCharacter,
    required this.compatibilityScore,
    required this.createdAt,
    this.equipment = const [],
    this.motivation = 'Motivé',
    this.trainingFrequency = '3x/semaine',
    this.bio,
    this.gender,
  });

  MatchProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? photoUrl,
    String? level,
    List<String>? goals,
    String? availability,
    double? latitude,
    double? longitude,
    String? city,
    double? distance,
    Map<String, dynamic>? sportPreferences,
    String? sportCharacter,
    int? compatibilityScore,
    DateTime? createdAt,
    List<String>? equipment,
    String? motivation,
    String? trainingFrequency,
    String? bio,
    String? gender,
  }) {
    return MatchProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      level: level ?? this.level,
      goals: goals ?? this.goals,
      availability: availability ?? this.availability,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      distance: distance ?? this.distance,
      sportPreferences: sportPreferences ?? this.sportPreferences,
      sportCharacter: sportCharacter ?? this.sportCharacter,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      createdAt: createdAt ?? this.createdAt,
      equipment: equipment ?? this.equipment,
      motivation: motivation ?? this.motivation,
      trainingFrequency: trainingFrequency ?? this.trainingFrequency,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
    );
  }
}

/// ─────────────────────────────────────────────
/// Résultat de match
/// ─────────────────────────────────────────────

class MatchResult {
  final MatchProfile profile;
  final int compatibilityScore;
  final List<String> commonGoals;
  final String matchReason;

  MatchResult({
    required this.profile,
    required this.compatibilityScore,
    required this.commonGoals,
    required this.matchReason,
  });
}

/// ─────────────────────────────────────────────
/// Options de profil Buddy Workout
/// ─────────────────────────────────────────────

class BuddyProfileOptions {
  static const List<String> levels = [
    'Débutant',
    'Intermédiaire',
    'Confirmé',
    'Expert',
  ];

  static const List<String> goals = [
    'Perte de poids',
    'Prise de masse',
    'Endurance',
    'Tonification',
    'Bien-être',
    'Performance',
    'Remise en forme',
    'Cardio',
  ];

  static const List<String> sports = [
    'Musculation',
    'Running',
    'HIIT',
    'Yoga',
    'CrossFit',
    'Natation',
    'Vélo',
    'Boxe',
    'Pilates',
    'Stretching',
    'Danse',
    'Tennis',
  ];

  static const List<String> equipment = [
    'Haltères',
    'Barre',
    'Banc',
    'Élastiques',
    'Tapis',
    'Corde à sauter',
    'Kettlebell',
    'Barre de traction',
    'Vélo d\'appartement',
    'Tapis de course',
    'Rameur',
    'TRX',
  ];

  static const List<String> availabilities = [
    'Matin',
    'Midi',
    'Après-midi',
    'Soir',
    'Week-end',
    'Flexible',
  ];

  static const List<String> motivations = [
    'Détendu',
    'Motivé',
    'Très motivé',
    'Compétiteur',
  ];

  static const List<String> frequencies = [
    '1x/semaine',
    '2-3x/semaine',
    '4-5x/semaine',
    'Tous les jours',
  ];

  static const List<String> distances = [
    '1 km',
    '3 km',
    '5 km',
    '10 km',
    '20 km',
    'Illimité',
  ];
}
