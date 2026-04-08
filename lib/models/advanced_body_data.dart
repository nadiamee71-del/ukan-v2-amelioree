import 'package:flutter/foundation.dart';

/// Modèle pour les données corporelles avancées
class AdvancedBodyData {
  // Informations générales
  double? weight; // kg
  double? height; // cm
  double? bmi; // Calculé automatiquement
  double? bodyFat; // %
  String? bodyType; // ectomorphe, mésomorphe, endomorphe
  String? gender; // homme, femme (pour estimation body fat)

  // Mensurations
  double? chest; // Tour de poitrine
  double? waist; // Tour de taille
  double? hips; // Tour de hanches
  double? arm; // Tour de bras
  double? thigh; // Tour de cuisses
  double? calf; // Tour de mollets

  // Informations médicales
  String? bloodType; // A+, A-, B+, B-, O+, O-, AB+, AB-
  String? allergies;
  String? healthIssues;
  String? medications;

  // Niveau de forme
  String? fitnessLevel; // Débutant, Intermédiaire, Avancé
  String? sessionDifficulty; // Facile, Moyen, Intense

  AdvancedBodyData({
    this.weight,
    this.height,
    this.bmi,
    this.bodyFat,
    this.bodyType,
    this.gender,
    this.chest,
    this.waist,
    this.hips,
    this.arm,
    this.thigh,
    this.calf,
    this.bloodType,
    this.allergies,
    this.healthIssues,
    this.medications,
    this.fitnessLevel,
    this.sessionDifficulty,
  });

  /// Calcule l'IMC automatiquement
  double? calculateBMI() {
    if (weight == null || height == null || height == 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// Estime le body fat si non fourni
  double estimateBodyFat() {
    if (bodyFat != null) return bodyFat!;
    
    // Estimation basique selon le genre
    if (gender == 'femme') {
      return 25.0; // Estimation par défaut pour femme
    } else {
      return 18.0; // Estimation par défaut pour homme
    }
  }

  AdvancedBodyData copyWith({
    double? weight,
    double? height,
    double? bmi,
    double? bodyFat,
    String? bodyType,
    String? gender,
    double? chest,
    double? waist,
    double? hips,
    double? arm,
    double? thigh,
    double? calf,
    String? bloodType,
    String? allergies,
    String? healthIssues,
    String? medications,
    String? fitnessLevel,
    String? sessionDifficulty,
  }) {
    return AdvancedBodyData(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      bodyFat: bodyFat ?? this.bodyFat,
      bodyType: bodyType ?? this.bodyType,
      gender: gender ?? this.gender,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      arm: arm ?? this.arm,
      thigh: thigh ?? this.thigh,
      calf: calf ?? this.calf,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      healthIssues: healthIssues ?? this.healthIssues,
      medications: medications ?? this.medications,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      sessionDifficulty: sessionDifficulty ?? this.sessionDifficulty,
    );
  }
}

/// Entrée d'historique mensuel
class MonthlyHistoryEntry {
  final int month; // 1, 2, 3, 6, 9, 12
  final double weight;
  final double bmi;
  final double bodyFat;
  final DateTime date;

  MonthlyHistoryEntry({
    required this.month,
    required this.weight,
    required this.bmi,
    required this.bodyFat,
    required this.date,
  });
}

/// Notifier pour gérer les données corporelles avancées
class AdvancedBodyDataNotifier extends ChangeNotifier {
  static final AdvancedBodyDataNotifier _instance = AdvancedBodyDataNotifier._internal();
  factory AdvancedBodyDataNotifier() => _instance;
  AdvancedBodyDataNotifier._internal() {
    _initializeDemoData();
  }

  AdvancedBodyData _data = AdvancedBodyData();
  final List<MonthlyHistoryEntry> _history = [];

  AdvancedBodyData get data => _data;

  List<MonthlyHistoryEntry> get history => List.unmodifiable(_history);

  void _initializeDemoData() {
    // Données de démo
    _data = AdvancedBodyData(
      weight: 75.0,
      height: 175.0,
      bodyFat: 18.0,
      bodyType: 'mésomorphe',
      gender: 'homme',
      chest: 100.0,
      waist: 85.0,
      hips: 95.0,
      arm: 32.0,
      thigh: 58.0,
      calf: 38.0,
      bloodType: 'O+',
      allergies: 'Aucune',
      healthIssues: 'Aucun',
      medications: 'Aucun',
      fitnessLevel: 'Intermédiaire',
      sessionDifficulty: 'Moyen',
    );
    _data.bmi = _data.calculateBMI();

    // Historique de démo
    final now = DateTime.now();
    _history.addAll([
      MonthlyHistoryEntry(month: 1, weight: 78.0, bmi: 25.5, bodyFat: 20.0, date: now.subtract(const Duration(days: 330))),
      MonthlyHistoryEntry(month: 2, weight: 76.5, bmi: 25.0, bodyFat: 19.5, date: now.subtract(const Duration(days: 300))),
      MonthlyHistoryEntry(month: 3, weight: 76.0, bmi: 24.8, bodyFat: 19.0, date: now.subtract(const Duration(days: 270))),
      MonthlyHistoryEntry(month: 6, weight: 75.5, bmi: 24.7, bodyFat: 18.5, date: now.subtract(const Duration(days: 180))),
      MonthlyHistoryEntry(month: 9, weight: 75.2, bmi: 24.6, bodyFat: 18.2, date: now.subtract(const Duration(days: 90))),
      MonthlyHistoryEntry(month: 12, weight: 75.0, bmi: 24.5, bodyFat: 18.0, date: now),
    ]);
  }

  void updateData(AdvancedBodyData newData) {
    // Recalculer l'IMC si poids ou taille changent
    if (newData.weight != _data.weight || newData.height != _data.height) {
      newData.bmi = newData.calculateBMI();
    }
    
    // Estimer body fat si non fourni
    if (newData.bodyFat == null) {
      newData.bodyFat = newData.estimateBodyFat();
    }

    _data = newData;
    notifyListeners();
  }

  void updateWeight(double weight) {
    _data = _data.copyWith(weight: weight);
    _data.bmi = _data.calculateBMI();
    notifyListeners();
  }

  void updateHeight(double height) {
    _data = _data.copyWith(height: height);
    _data.bmi = _data.calculateBMI();
    notifyListeners();
  }
}

