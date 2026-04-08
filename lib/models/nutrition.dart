import 'package:flutter/foundation.dart';

/// Type de repas
enum MealType {
  breakfast, // Petit-déjeuner
  lunch, // Déjeuner
  dinner, // Dîner
  snack, // Collation
}

/// Extension pour obtenir le nom affiché du type de repas
extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Petit-déjeuner';
      case MealType.lunch:
        return 'Déjeuner';
      case MealType.dinner:
        return 'Dîner';
      case MealType.snack:
        return 'Collation';
    }
  }
}

/// Entrée de repas dans le journal nutritionnel
class MealEntry {
  final String id;
  final DateTime date; // uniquement la date (sans l'heure précise)
  final MealType type;
  final String title; // ex: "Porridge + banane"
  final int calories; // kcal
  final int protein; // g
  final int carbs; // g
  final int fats; // g
  final String? notes; // optionnel
  final String? photoUrl; // pour plus tard, on laisse en String nullable

  const MealEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.notes,
    this.photoUrl,
  });
}

/// Résumé nutritionnel d'une journée
class NutritionDaySummary {
  final DateTime date;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFats;
  final List<MealEntry> meals;

  const NutritionDaySummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.meals,
  });
}

/// Notifier pour gérer les repas (en mémoire)
class NutritionNotifier extends ChangeNotifier {
  static final NutritionNotifier _instance = NutritionNotifier._internal();
  factory NutritionNotifier() => _instance;
  NutritionNotifier._internal();

  final List<MealEntry> _meals = [];

  /// Récupère les repas pour une date donnée
  List<MealEntry> mealsForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _meals.where((m) {
      final md = DateTime(m.date.year, m.date.month, m.date.day);
      return md == d;
    }).toList();
  }

  /// Récupère le résumé nutritionnel pour une date donnée
  NutritionDaySummary summaryForDate(DateTime date) {
    final meals = mealsForDate(date);
    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fats = 0;

    for (final m in meals) {
      calories += m.calories;
      protein += m.protein;
      carbs += m.carbs;
      fats += m.fats;
    }

    return NutritionDaySummary(
      date: DateTime(date.year, date.month, date.day),
      totalCalories: calories,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFats: fats,
      meals: meals,
    );
  }

  /// Ajoute un repas
  void addMeal(MealEntry meal) {
    _meals.add(meal);
    notifyListeners();
  }

  /// Supprime un repas (pour plus tard si nécessaire)
  void removeMeal(String id) {
    _meals.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}









