import 'package:flutter/foundation.dart';

/// ─────────────────────────────────────────────
/// Filtres de recherche pour Chat Match™
/// ─────────────────────────────────────────────

class MatchFilters {
  String? level; // Débutant, Intermédiaire, Avancé, Tous
  List<String> goals; // Objectifs filtrés
  String? availability; // Matin, Après-midi, Soir, Flexible, Tous
  double? maxDistance; // Distance maximale en km
  String? sportCharacter; // Motivé, Relax, Compétitif, Social, Tous
  int? minAge;
  int? maxAge;
  String? gender; // Homme, Femme, Autre, Tous
  String? city; // Ville
  List<String> sportInterests; // Centres d'intérêt sportifs
  int? maxCompatibilityScore; // Score de compatibilité maximal (0-100)
  List<String> accessories; // Accessoires possédés
  List<String> targetDifficulties; // Difficultés visées

  MatchFilters({
    this.level,
    this.goals = const [],
    this.availability,
    this.maxDistance,
    this.sportCharacter,
    this.minAge,
    this.maxAge,
    this.gender,
    this.city,
    this.sportInterests = const [],
    this.maxCompatibilityScore,
    this.accessories = const [],
    this.targetDifficulties = const [],
  });

  MatchFilters copyWith({
    String? level,
    List<String>? goals,
    String? availability,
    double? maxDistance,
    String? sportCharacter,
    int? minAge,
    int? maxAge,
    String? gender,
    String? city,
    List<String>? sportInterests,
    int? maxCompatibilityScore,
    List<String>? accessories,
    List<String>? targetDifficulties,
  }) {
    return MatchFilters(
      level: level ?? this.level,
      goals: goals ?? this.goals,
      availability: availability ?? this.availability,
      maxDistance: maxDistance ?? this.maxDistance,
      sportCharacter: sportCharacter ?? this.sportCharacter,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      sportInterests: sportInterests ?? this.sportInterests,
      maxCompatibilityScore: maxCompatibilityScore ?? this.maxCompatibilityScore,
      accessories: accessories ?? this.accessories,
      targetDifficulties: targetDifficulties ?? this.targetDifficulties,
    );
  }

  void reset() {
    level = null;
    goals = [];
    availability = null;
    maxDistance = null;
    sportCharacter = null;
    minAge = null;
    maxAge = null;
    gender = null;
    city = null;
    sportInterests = [];
    maxCompatibilityScore = null;
    accessories = [];
    targetDifficulties = [];
  }
}









