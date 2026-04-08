enum DemoIngredientCategory {
  vegetables,
  proteins,
  carbs,
  dairy,
  eggs,
  tubers,
  nuts,
  fruit,
}

extension DemoIngredientCategoryExtension on DemoIngredientCategory {
  String get label {
    switch (this) {
      case DemoIngredientCategory.vegetables: return 'Légumes';
      case DemoIngredientCategory.proteins: return 'Protéines';
      case DemoIngredientCategory.carbs: return 'Féculents';
      case DemoIngredientCategory.dairy: return 'Laitages';
      case DemoIngredientCategory.eggs: return 'Œufs';
      case DemoIngredientCategory.tubers: return 'Tubercules';
      case DemoIngredientCategory.nuts: return 'Oléagineux';
      case DemoIngredientCategory.fruit: return 'Fruits';
    }
  }

  String get emoji {
    switch (this) {
      case DemoIngredientCategory.vegetables: return '🥦';
      case DemoIngredientCategory.proteins: return '🍗';
      case DemoIngredientCategory.carbs: return '🍚';
      case DemoIngredientCategory.dairy: return '🥛';
      case DemoIngredientCategory.eggs: return '🥚';
      case DemoIngredientCategory.tubers: return '🥔';
      case DemoIngredientCategory.nuts: return '🥜';
      case DemoIngredientCategory.fruit: return '🍎';
    }
  }
}

enum DemoUnit {
  gram,
  milliliter,
  piece,
}

extension DemoUnitExtension on DemoUnit {
  String get label {
    switch (this) {
      case DemoUnit.gram: return 'g';
      case DemoUnit.milliliter: return 'ml';
      case DemoUnit.piece: return 'pièce';
    }
  }
}

class DemoIngredient {
  final String id;
  final String name;
  final DemoIngredientCategory category;
  final DemoUnit unit;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double pricePerKg; // prix en €/kg (ou €/L, ou €/pièce si unit=piece)

  const DemoIngredient({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.pricePerKg,
  });
}

class DemoFoodEntry {
  final DemoIngredient ingredient;
  double quantityGrams; // ou ml, ou nb pièces

  DemoFoodEntry({
    required this.ingredient,
    required this.quantityGrams,
  });
  
  // Helpers calculs
  double get totalKcal => (quantityGrams * ingredient.kcalPer100g) / 100;
  double get totalProtein => (quantityGrams * ingredient.proteinPer100g) / 100;
  double get totalCarbs => (quantityGrams * ingredient.carbsPer100g) / 100;
  double get totalFat => (quantityGrams * ingredient.fatPer100g) / 100;
  double get totalPrice => (quantityGrams * ingredient.pricePerKg) / 1000;
}

List<DemoIngredient> buildDemoIngredients() {
  return [
    // Légumes
    const DemoIngredient(id: 'veg_brocoli', name: 'Brocoli', category: DemoIngredientCategory.vegetables, unit: DemoUnit.gram, kcalPer100g: 34, proteinPer100g: 2.8, carbsPer100g: 7, fatPer100g: 0.4, pricePerKg: 2.50),
    const DemoIngredient(id: 'veg_carotte', name: 'Carottes', category: DemoIngredientCategory.vegetables, unit: DemoUnit.gram, kcalPer100g: 41, proteinPer100g: 0.9, carbsPer100g: 10, fatPer100g: 0.2, pricePerKg: 1.20),
    const DemoIngredient(id: 'veg_courgette', name: 'Courgette', category: DemoIngredientCategory.vegetables, unit: DemoUnit.gram, kcalPer100g: 17, proteinPer100g: 1.2, carbsPer100g: 3, fatPer100g: 0.3, pricePerKg: 1.80),
    const DemoIngredient(id: 'veg_poivron', name: 'Poivron', category: DemoIngredientCategory.vegetables, unit: DemoUnit.gram, kcalPer100g: 20, proteinPer100g: 0.9, carbsPer100g: 4.6, fatPer100g: 0.2, pricePerKg: 3.50),
    const DemoIngredient(id: 'veg_salade', name: 'Salade', category: DemoIngredientCategory.vegetables, unit: DemoUnit.gram, kcalPer100g: 15, proteinPer100g: 1.4, carbsPer100g: 2.9, fatPer100g: 0.2, pricePerKg: 4.00),
    const DemoIngredient(id: 'veg_tomate', name: 'Tomates cerise', category: DemoIngredientCategory.vegetables, unit: DemoUnit.gram, kcalPer100g: 18, proteinPer100g: 0.9, carbsPer100g: 3.9, fatPer100g: 0.2, pricePerKg: 3.00),
    const DemoIngredient(id: 'veg_oignon', name: 'Oignon', category: DemoIngredientCategory.vegetables, unit: DemoUnit.gram, kcalPer100g: 40, proteinPer100g: 1.1, carbsPer100g: 9, fatPer100g: 0.1, pricePerKg: 1.50),

    // Protéines
    const DemoIngredient(id: 'prot_poulet', name: 'Blanc de poulet', category: DemoIngredientCategory.proteins, unit: DemoUnit.gram, kcalPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, pricePerKg: 12.00),
    const DemoIngredient(id: 'prot_steak', name: 'Steak haché 5%', category: DemoIngredientCategory.proteins, unit: DemoUnit.gram, kcalPer100g: 130, proteinPer100g: 21, carbsPer100g: 0, fatPer100g: 5, pricePerKg: 15.00),
    const DemoIngredient(id: 'prot_saumon', name: 'Saumon', category: DemoIngredientCategory.proteins, unit: DemoUnit.gram, kcalPer100g: 208, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 13, pricePerKg: 22.00),
    const DemoIngredient(id: 'prot_tofu', name: 'Tofu nature', category: DemoIngredientCategory.proteins, unit: DemoUnit.gram, kcalPer100g: 76, proteinPer100g: 8, carbsPer100g: 1.9, fatPer100g: 4.8, pricePerKg: 8.00),

    // Féculents
    const DemoIngredient(id: 'carb_riz', name: 'Riz basmati (cuit)', category: DemoIngredientCategory.carbs, unit: DemoUnit.gram, kcalPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28, fatPer100g: 0.3, pricePerKg: 2.00), // prix sec ramené au cuit approx
    const DemoIngredient(id: 'carb_pates', name: 'Pâtes complètes', category: DemoIngredientCategory.carbs, unit: DemoUnit.gram, kcalPer100g: 124, proteinPer100g: 5, carbsPer100g: 25, fatPer100g: 0.5, pricePerKg: 1.80),
    const DemoIngredient(id: 'carb_quinoa', name: 'Quinoa', category: DemoIngredientCategory.carbs, unit: DemoUnit.gram, kcalPer100g: 120, proteinPer100g: 4.4, carbsPer100g: 21, fatPer100g: 1.9, pricePerKg: 6.00),
    const DemoIngredient(id: 'carb_avoine', name: 'Flocons d\'avoine', category: DemoIngredientCategory.carbs, unit: DemoUnit.gram, kcalPer100g: 389, proteinPer100g: 16.9, carbsPer100g: 66, fatPer100g: 6.9, pricePerKg: 3.50),

    // Œufs
    const DemoIngredient(id: 'egg_oeuf', name: 'Œufs', category: DemoIngredientCategory.eggs, unit: DemoUnit.piece, kcalPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11, pricePerKg: 4.00), // Approx 1 oeuf = 50g

    // Fruits
    const DemoIngredient(id: 'fruit_banane', name: 'Banane', category: DemoIngredientCategory.fruit, unit: DemoUnit.gram, kcalPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 22.8, fatPer100g: 0.3, pricePerKg: 1.90),
    const DemoIngredient(id: 'fruit_pomme', name: 'Pomme', category: DemoIngredientCategory.fruit, unit: DemoUnit.gram, kcalPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatPer100g: 0.2, pricePerKg: 2.50),

    // Autres
    const DemoIngredient(id: 'nut_amande', name: 'Amandes', category: DemoIngredientCategory.nuts, unit: DemoUnit.gram, kcalPer100g: 579, proteinPer100g: 21, carbsPer100g: 22, fatPer100g: 50, pricePerKg: 18.00),
    const DemoIngredient(id: 'dairy_skyr', name: 'Skyr', category: DemoIngredientCategory.dairy, unit: DemoUnit.gram, kcalPer100g: 57, proteinPer100g: 10, carbsPer100g: 4, fatPer100g: 0.2, pricePerKg: 5.50),
  ];
}








