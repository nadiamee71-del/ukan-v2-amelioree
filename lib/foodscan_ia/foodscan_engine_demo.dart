import 'package:flutter/foundation.dart';

/// Résultat d'une analyse FoodScan IA
class FoodScanResult {
  final String label;          // nom du plat détecté
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int portionGrams;
  final int confidence;        // 0–100
  final String note;           // petit texte explicatif

  const FoodScanResult({
    required this.label,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.portionGrams,
    required this.confidence,
    required this.note,
  });
}

/// Moteur IA démo pour FoodScan™
/// Analyse locale sans dépendance externe
class FoodScanEngineDemo {
  /// Analyse depuis un label de photo (simulé)
  static FoodScanResult fromPhotoLabel(String label) {
    final lowerLabel = label.toLowerCase();
    
    // Salade / Poulet
    if (lowerLabel.contains('salade') || lowerLabel.contains('poulet')) {
      return FoodScanResult(
        label: 'Salade de poulet',
        calories: 320,
        protein: 28,
        carbs: 18,
        fat: 12,
        portionGrams: 280,
        confidence: 85,
        note: 'Repas équilibré avec protéines et légumes.',
      );
    }
    
    // Pizza
    if (lowerLabel.contains('pizza')) {
      return FoodScanResult(
        label: 'Pizza',
        calories: 720,
        protein: 28,
        carbs: 88,
        fat: 30,
        portionGrams: 320,
        confidence: 88,
        note: 'Portion moyenne de pizza classique.',
      );
    }
    
    // Burger
    if (lowerLabel.contains('burger') || lowerLabel.contains('hamburger')) {
      return FoodScanResult(
        label: 'Burger',
        calories: 680,
        protein: 32,
        carbs: 48,
        fat: 38,
        portionGrams: 290,
        confidence: 82,
        note: 'Burger classique avec frites (estimé).',
      );
    }
    
    // Pâtes
    if (lowerLabel.contains('pâte') || lowerLabel.contains('pasta') || lowerLabel.contains('bolo')) {
      return FoodScanResult(
        label: 'Pâtes bolognaise',
        calories: 580,
        protein: 24,
        carbs: 82,
        fat: 15,
        portionGrams: 350,
        confidence: 80,
        note: 'Portion généreuse de pâtes avec sauce.',
      );
    }
    
    // Riz
    if (lowerLabel.contains('riz')) {
      return FoodScanResult(
        label: 'Riz avec accompagnement',
        calories: 450,
        protein: 18,
        carbs: 75,
        fat: 10,
        portionGrams: 300,
        confidence: 75,
        note: 'Riz blanc avec légumes et protéine.',
      );
    }
    
    // Poisson
    if (lowerLabel.contains('poisson') || lowerLabel.contains('saumon') || lowerLabel.contains('thon')) {
      return FoodScanResult(
        label: 'Poisson avec légumes',
        calories: 380,
        protein: 35,
        carbs: 12,
        fat: 18,
        portionGrams: 250,
        confidence: 78,
        note: 'Repas riche en protéines et oméga-3.',
      );
    }
    
    // Par défaut : repas varié
    return FoodScanResult(
      label: 'Repas varié',
      calories: 520,
      protein: 22,
      carbs: 58,
      fat: 20,
      portionGrams: 300,
      confidence: 72,
      note: 'Repas équilibré détecté.',
    );
  }

  /// Analyse depuis une description textuelle
  static FoodScanResult fromTextDescription(String text, {String portionHint = ''}) {
    final lowerText = text.toLowerCase();
    final lowerPortion = portionHint.toLowerCase();
    
    // Multiplicateur de portion
    double portionMultiplier = 1.0;
    if (lowerPortion.contains('petite') || lowerText.contains('petit')) {
      portionMultiplier = 0.7;
    } else if (lowerPortion.contains('grande') || lowerText.contains('grand')) {
      portionMultiplier = 1.3;
    } else if (lowerText.contains('beaucoup') || lowerText.contains('énorme')) {
      portionMultiplier = 1.5;
    }
    
    // Détection des aliments
    int baseCalories = 400;
    int baseProtein = 20;
    int baseCarbs = 50;
    int baseFat = 15;
    String detectedLabel = 'Repas varié';
    int confidence = 75;
    
    // Protéines
    if (lowerText.contains('poulet') || lowerText.contains('chicken')) {
      baseCalories += 150;
      baseProtein += 25;
      baseFat += 5;
      detectedLabel = 'Poulet';
    }
    if (lowerText.contains('boeuf') || lowerText.contains('steak') || lowerText.contains('viande')) {
      baseCalories += 180;
      baseProtein += 28;
      baseFat += 8;
      detectedLabel = 'Viande';
    }
    if (lowerText.contains('poisson') || lowerText.contains('saumon') || lowerText.contains('thon')) {
      baseCalories += 120;
      baseProtein += 22;
      baseFat += 6;
      detectedLabel = 'Poisson';
    }
    if (lowerText.contains('oeuf') || lowerText.contains('egg')) {
      baseCalories += 80;
      baseProtein += 12;
      baseFat += 5;
      if (detectedLabel == 'Repas varié') detectedLabel = 'Oeufs';
    }
    
    // Glucides
    if (lowerText.contains('pâte') || lowerText.contains('pasta')) {
      baseCalories += 200;
      baseCarbs += 60;
      detectedLabel = detectedLabel == 'Repas varié' ? 'Pâtes' : '$detectedLabel + Pâtes';
    }
    if (lowerText.contains('riz')) {
      baseCalories += 150;
      baseCarbs += 50;
      detectedLabel = detectedLabel == 'Repas varié' ? 'Riz' : '$detectedLabel + Riz';
    }
    if (lowerText.contains('pain') || lowerText.contains('bread')) {
      baseCalories += 100;
      baseCarbs += 40;
    }
    if (lowerText.contains('pomme de terre') || lowerText.contains('patate') || lowerText.contains('frite')) {
      baseCalories += 120;
      baseCarbs += 35;
      baseFat += 5;
    }
    
    // Légumes
    if (lowerText.contains('légume') || lowerText.contains('salade') || lowerText.contains('vert')) {
      baseCalories += 30;
      baseCarbs += 8;
      confidence += 3;
    }
    
    // Sucré / Dessert
    if (lowerText.contains('dessert') || lowerText.contains('gâteau') || lowerText.contains('sucré') || lowerText.contains('chocolat')) {
      baseCalories += 200;
      baseCarbs += 40;
      baseFat += 8;
      detectedLabel = detectedLabel == 'Repas varié' ? 'Dessert' : '$detectedLabel + Dessert';
    }
    
    // Sauce / Gras
    if (lowerText.contains('sauce') || lowerText.contains('carbonara') || lowerText.contains('crème')) {
      baseCalories += 80;
      baseFat += 10;
    }
    
    // Calcul final avec multiplicateur
    final finalCalories = (baseCalories * portionMultiplier).round();
    final finalProtein = (baseProtein * portionMultiplier).round();
    final finalCarbs = (baseCarbs * portionMultiplier).round();
    final finalFat = (baseFat * portionMultiplier).round();
    final finalPortion = (300 * portionMultiplier).round();
    
    // Note personnalisée
    String note = 'Analyse basée sur ta description.';
    if (portionMultiplier < 1.0) {
      note = 'Portion réduite détectée.';
    } else if (portionMultiplier > 1.2) {
      note = 'Portion généreuse détectée.';
    }
    
    return FoodScanResult(
      label: detectedLabel,
      calories: finalCalories,
      protein: finalProtein,
      carbs: finalCarbs,
      fat: finalFat,
      portionGrams: finalPortion,
      confidence: confidence,
      note: note,
    );
  }
}







