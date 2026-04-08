import 'package:flutter/foundation.dart';

/// ─────────────────────────────────────────────
/// Modèle d'entrée de composition corporelle
/// ─────────────────────────────────────────────

class BodyEntry {
  final String id;
  final DateTime date; // normalisée AAAA-MM-JJ
  final double weight; // kg
  final double waist; // cm
  final double hips; // cm
  final double chest; // cm
  final double bodyFatEstimate; // %

  BodyEntry({
    required this.id,
    required DateTime date,
    required this.weight,
    required this.waist,
    required this.hips,
    required this.chest,
    required this.bodyFatEstimate,
  }) : date = DateTime(date.year, date.month, date.day);
}

/// Helper interne pour normaliser une date (AAAA-MM-JJ)
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// ─────────────────────────────────────────────
/// Notifier pour la composition corporelle
/// ─────────────────────────────────────────────

class BodyCompositionNotifier extends ChangeNotifier {
  static final BodyCompositionNotifier _instance = BodyCompositionNotifier._internal();
  factory BodyCompositionNotifier() => _instance;
  BodyCompositionNotifier._internal();

  final List<BodyEntry> _entries = [];

  void addEntry({
    required DateTime date,
    required double weight,
    required double waist,
    required double hips,
    required double chest,
    double? bodyFatEstimate,
  }) {
    // Calcul estimé du body fat si non fourni (formule simplifiée)
    final bf = bodyFatEstimate ?? _estimateBodyFat(weight, waist, hips, chest);

    final entry = BodyEntry(
      id: 'body_${DateTime.now().microsecondsSinceEpoch}',
      date: date,
      weight: weight,
      waist: waist,
      hips: hips,
      chest: chest,
      bodyFatEstimate: bf,
    );

    _entries.add(entry);
    // Trier par date décroissante
    _entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // Formule simplifiée d'estimation du body fat (démo)
  double _estimateBodyFat(double weight, double waist, double hips, double chest) {
    // Estimation basique basée sur le tour de taille et le poids
    // Ceci est une approximation, pas une mesure précise
    final bmi = weight / ((1.75) * (1.75)); // IMC approximatif
    final waistRatio = waist / 100; // Conversion en m
    final estimatedBF = (bmi * 1.2) + (waistRatio * 5) - 10;
    return estimatedBF.clamp(5.0, 40.0); // Entre 5% et 40%
  }

  BodyEntry? lastEntry() {
    if (_entries.isEmpty) return null;
    return _entries.first; // Déjà trié par date décroissante
  }

  List<BodyEntry> last7Days() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _entries.where((entry) => entry.date.isAfter(sevenDaysAgo) || 
        _dateOnly(entry.date) == _dateOnly(sevenDaysAgo)).toList();
  }

  Map<DateTime, double> weightEvolutionForLast7Days() {
    final entries = last7Days();
    final Map<DateTime, double> result = {};
    for (final entry in entries) {
      final d = _dateOnly(entry.date);
      result[d] = entry.weight;
    }
    return result;
  }

  Map<DateTime, double> waistEvolutionForLast7Days() {
    final entries = last7Days();
    final Map<DateTime, double> result = {};
    for (final entry in entries) {
      final d = _dateOnly(entry.date);
      result[d] = entry.waist;
    }
    return result;
  }

  Map<DateTime, double> bodyFatEvolutionForLast7Days() {
    final entries = last7Days();
    final Map<DateTime, double> result = {};
    for (final entry in entries) {
      final d = _dateOnly(entry.date);
      result[d] = entry.bodyFatEstimate;
    }
    return result;
  }
}









