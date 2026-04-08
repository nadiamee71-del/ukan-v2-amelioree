import 'package:flutter/material.dart';
import 'match_profile.dart';

/// ─────────────────────────────────────────────
/// Calcul de compatibilité pour Buddy Workout
/// ─────────────────────────────────────────────

/// Résultat du calcul de compatibilité avec explication
class CompatibilityResult {
  final int score; // 0-100
  final List<CompatibilityReason> reasons;
  final Map<String, int> detailedScores; // Scores par catégorie

  CompatibilityResult({
    required this.score,
    required this.reasons,
    this.detailedScores = const {},
  });
}

/// Raison de compatibilité
class CompatibilityReason {
  final String text;
  final bool isPositive;
  final int points;

  CompatibilityReason({
    required this.text,
    required this.isPositive,
    required this.points,
  });
}

/// Calcule la compatibilité entre deux profils
CompatibilityResult calculateCompatibility(MatchProfile user, MatchProfile other) {
  final reasons = <CompatibilityReason>[];
  int totalScore = 0;
  final detailedScores = <String, int>{};

  // 1. Compatibilité niveau (+20 points max)
  int levelScore = 0;
  if (user.level == other.level) {
    levelScore = 20;
    reasons.add(CompatibilityReason(
      text: 'Même niveau : ${user.level}',
      isPositive: true,
      points: 20,
    ));
  } else {
    final levels = ['Débutant', 'Intermédiaire', 'Confirmé', 'Expert'];
    final index1 = levels.indexOf(user.level);
    final index2 = levels.indexOf(other.level);
    if ((index1 - index2).abs() == 1) {
      levelScore = 12;
      reasons.add(CompatibilityReason(
        text: 'Niveaux proches : ${user.level} / ${other.level}',
        isPositive: true,
        points: 12,
      ));
    } else {
      reasons.add(CompatibilityReason(
        text: 'Niveaux différents',
        isPositive: false,
        points: 0,
      ));
    }
  }
  totalScore += levelScore;
  detailedScores['Niveau'] = (levelScore / 20 * 100).round();

  // 2. Compatibilité objectifs (+20 points max)
  final commonGoals = user.goals.where((g) => other.goals.contains(g)).toList();
  final goalScore = (commonGoals.length * 7).clamp(0, 20);
  if (goalScore > 0) {
    totalScore += goalScore;
    reasons.add(CompatibilityReason(
      text: 'Objectifs communs : ${commonGoals.take(2).join(', ')}',
      isPositive: true,
      points: goalScore,
    ));
  } else {
    reasons.add(CompatibilityReason(
      text: 'Objectifs différents',
      isPositive: false,
      points: 0,
    ));
  }
  detailedScores['Objectifs'] = (goalScore / 20 * 100).round();

  // 3. Compatibilité sports (+20 points max)
  final userSports = user.sportPreferences.keys.toList();
  final otherSports = other.sportPreferences.keys.toList();
  final commonSports = userSports.where((s) => otherSports.contains(s)).toList();
  final sportScore = (commonSports.length * 7).clamp(0, 20);
  if (sportScore > 0) {
    totalScore += sportScore;
    reasons.add(CompatibilityReason(
      text: 'Sports en commun : ${commonSports.take(2).join(', ')}',
      isPositive: true,
      points: sportScore,
    ));
  }
  detailedScores['Sports'] = (sportScore / 20 * 100).round();

  // 4. Compatibilité disponibilité (+10 points)
  int availScore = 0;
  if (user.availability == other.availability || 
      user.availability == 'Flexible' || 
      other.availability == 'Flexible') {
    availScore = 10;
    reasons.add(CompatibilityReason(
      text: 'Disponibilité compatible : ${other.availability}',
      isPositive: true,
      points: 10,
    ));
  } else {
    reasons.add(CompatibilityReason(
      text: 'Disponibilités différentes',
      isPositive: false,
      points: 0,
    ));
  }
  totalScore += availScore;
  detailedScores['Disponibilité'] = (availScore / 10 * 100).round();

  // 5. Compatibilité distance (+10 points)
  final distanceScore = (10 - (other.distance / 2)).clamp(0, 10).toInt();
  totalScore += distanceScore;
  if (other.distance < 3) {
    reasons.add(CompatibilityReason(
      text: 'Très proche : ${other.distance.toStringAsFixed(1)} km',
      isPositive: true,
      points: distanceScore,
    ));
  } else if (other.distance < 5) {
    reasons.add(CompatibilityReason(
      text: 'Distance raisonnable : ${other.distance.toStringAsFixed(1)} km',
      isPositive: true,
      points: distanceScore,
    ));
  }
  detailedScores['Distance'] = (distanceScore / 10 * 100).round();

  // 6. Compatibilité équipement (+10 points max)
  final commonEquipment = user.equipment.where((e) => other.equipment.contains(e)).toList();
  final equipScore = (commonEquipment.length * 3).clamp(0, 10);
  if (equipScore > 0) {
    totalScore += equipScore;
    reasons.add(CompatibilityReason(
      text: 'Équipement similaire : ${commonEquipment.take(2).join(', ')}',
      isPositive: true,
      points: equipScore,
    ));
  }
  detailedScores['Matériel'] = (equipScore / 10 * 100).round();

  // 7. Compatibilité motivation (+10 points)
  int motivScore = 0;
  final motivations = ['Détendu', 'Motivé', 'Très motivé', 'Compétiteur'];
  final userMotivIndex = motivations.indexOf(user.motivation);
  final otherMotivIndex = motivations.indexOf(other.motivation);
  if (userMotivIndex >= 0 && otherMotivIndex >= 0) {
    final diff = (userMotivIndex - otherMotivIndex).abs();
    if (diff == 0) {
      motivScore = 10;
      reasons.add(CompatibilityReason(
        text: 'Même niveau de motivation',
        isPositive: true,
        points: 10,
      ));
    } else if (diff == 1) {
      motivScore = 6;
    }
  }
  totalScore += motivScore;
  detailedScores['Motivation'] = (motivScore / 10 * 100).round();

  final finalScore = totalScore.clamp(0, 100);
  return CompatibilityResult(
    score: finalScore,
    reasons: reasons,
    detailedScores: detailedScores,
  );
}

/// Obtient le label et la couleur pour un score de compatibilité
CompatibilityLabel getCompatibilityLabel(int score) {
  if (score >= 80) {
    return CompatibilityLabel(
      text: 'Excellent match',
      color: const Color(0xFF4A7C59), // Vert olive
    );
  } else if (score >= 65) {
    return CompatibilityLabel(
      text: 'Très compatible',
      color: const Color(0xFF6B8E7E), // Vert sauge
    );
  } else if (score >= 50) {
    return CompatibilityLabel(
      text: 'Compatible',
      color: const Color(0xFF475569), // Bleu ardoise
    );
  } else {
    return CompatibilityLabel(
      text: 'À découvrir',
      color: const Color(0xFF64748B), // Gris slate
    );
  }
}

class CompatibilityLabel {
  final String text;
  final Color color;

  CompatibilityLabel({
    required this.text,
    required this.color,
  });
}

/// Génère un message de match personnalisé
String generateMatchMessage(MatchProfile user, MatchProfile other, int score) {
  if (score >= 85) {
    return 'Parfait ! Vous avez énormément de points communs !';
  } else if (score >= 70) {
    return 'Super match ! Vous partagez les mêmes objectifs.';
  } else if (score >= 55) {
    return 'Bonne compatibilité ! Vous pourriez bien vous entendre.';
  } else {
    return 'Profil intéressant à découvrir !';
  }
}
