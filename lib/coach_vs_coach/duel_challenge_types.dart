/// Mapping des spécialités aux types de défis compatibles
class DuelChallengeTypes {
  /// Types de défis disponibles par spécialité
  static const Map<String, List<String>> specialtyToChallenges = {
    'Perte de poids': [
      'Perte de poids',
      'Cardio',
      'Déficit calorique',
      'Endurance',
      'Brûler des calories',
    ],
    'Prise de masse': [
      'Prise de masse',
      'Force',
      'Volume musculaire',
      'Hypertrophie',
      'Développement musculaire',
    ],
    'CrossFit': [
      'Force',
      'Endurance',
      'WOD',
      'Performance globale',
      'Résistance',
    ],
    'Post-partum': [
      'Récupération',
      'Tonification',
      'Renforcement du plancher pelvien',
      'Remise en forme douce',
      'Stabilité',
    ],
    'Endurance': [
      'Endurance',
      'Cardio',
      'Distance',
      'Résistance',
      'Performance aérobie',
    ],
    'Yoga & Mobilité': [
      'Flexibilité',
      'Mobilité',
      'Équilibre',
      'Détente',
      'Posture',
    ],
    'Cardio & Endurance': [
      'Cardio',
      'Endurance',
      'Brûler des calories',
      'Résistance',
      'Performance aérobie',
    ],
    'Remise en forme': [
      'Remise en forme',
      'Tonification',
      'Endurance',
      'Force',
      'Condition physique',
    ],
  };

  /// Tous les types de défis uniques
  static List<String> get allChallengeTypes {
    final allTypes = <String>{};
    for (final challenges in specialtyToChallenges.values) {
      allTypes.addAll(challenges);
    }
    return allTypes.toList()..sort();
  }

  /// Obtenir les types de défis compatibles pour une spécialité
  static List<String> getChallengesForSpecialty(String specialty) {
    return specialtyToChallenges[specialty] ??
        [
          'Force',
          'Endurance',
          'Cardio',
        ]; // Par défaut si spécialité non trouvée
  }

  /// Vérifier si un type de défi est compatible avec une spécialité
  static bool isChallengeCompatibleWithSpecialty(
      String challengeType, String specialty) {
    final compatibleChallenges = getChallengesForSpecialty(specialty);
    return compatibleChallenges.contains(challengeType);
  }
}




