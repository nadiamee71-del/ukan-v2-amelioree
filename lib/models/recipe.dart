import 'package:flutter/foundation.dart';
import 'nutrition.dart';
import '../data/fake_images.dart';

/// Catégorie de recette
enum RecipeCategory {
  weightLoss, // Perte de poids
  muscleGain, // Prise de masse
  energy, // Énergie
  healthy, // Équilibré / Santé
  quick, // Rapide
  vegetarian, // Végétarien
  other, // Autre
}

/// Extension pour obtenir le nom affiché de la catégorie
extension RecipeCategoryExtension on RecipeCategory {
  String get displayName {
    switch (this) {
      case RecipeCategory.weightLoss:
        return 'Perte de poids';
      case RecipeCategory.muscleGain:
        return 'Prise de masse';
      case RecipeCategory.energy:
        return 'Énergie';
      case RecipeCategory.healthy:
        return 'Équilibré';
      case RecipeCategory.quick:
        return 'Rapide';
      case RecipeCategory.vegetarian:
        return 'Végétarien';
      case RecipeCategory.other:
        return 'Autre';
    }
  }
}

/// Niveau de difficulté d'une recette
enum RecipeDifficulty {
  easy,
  medium,
  hard,
}

extension RecipeDifficultyExtension on RecipeDifficulty {
  String get displayName {
    switch (this) {
      case RecipeDifficulty.easy:
        return 'Facile';
      case RecipeDifficulty.medium:
        return 'Moyen';
      case RecipeDifficulty.hard:
        return 'Difficile';
    }
  }

  String get emoji {
    switch (this) {
      case RecipeDifficulty.easy:
        return '🟢';
      case RecipeDifficulty.medium:
        return '🟡';
      case RecipeDifficulty.hard:
        return '🔴';
    }
  }
}

/// Modèle de recette
class Recipe {
  final String id;
  final String name;
  final MealType typeRepas; // petit-déjeuner, déjeuner, collation, dîner
  final String description;
  final String ingredients; // texte multiligne
  final String steps; // texte multiligne
  final int? calories; // approximatives
  final int? proteines; // g
  final int? glucides; // g
  final int? lipides; // g
  final List<String> allergens; // ex: ["gluten", "lactose", "arachide"]
  final String? imagePath; // chemin local ou URL (image principale)
  final List<String> additionalImages; // Photos supplémentaires
  final String? videoUrl; // URL vidéo (démo)
  final bool isUserRecipe; // true si créée par l'utilisateur
  final bool isSharedWithCommunity; // true si partagée avec la communauté
  final String? ownerUserId; // ID utilisateur (simulé en démo)
  final DateTime createdAt;
  final RecipeCategory category; // Catégorie de la recette
  final bool isFavorite;
  final String mediaType; // 'image', 'video', 'file'
  final int portions; // Nombre de personnes
  final int? prepTimeMinutes; // Temps de préparation en minutes
  final int? cookTimeMinutes; // Temps de cuisson en minutes
  final RecipeDifficulty difficulty; // Niveau de difficulté

  const Recipe({
    required this.id,
    required this.name,
    required this.typeRepas,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.calories,
    this.proteines,
    this.glucides,
    this.lipides,
    this.allergens = const [],
    this.imagePath,
    this.additionalImages = const [],
    this.videoUrl,
    required this.isUserRecipe,
    required this.isSharedWithCommunity,
    this.ownerUserId,
    required this.createdAt,
    this.category = RecipeCategory.other,
    this.isFavorite = false,
    this.mediaType = 'image',
    this.portions = 1,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.difficulty = RecipeDifficulty.easy,
  });

  /// Retourne l'image à afficher (utilise getRandomRecipeImage si imagePath est null ou vide)
  String get displayImage {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return imagePath!;
    }
    return getRandomRecipeImage();
  }

  /// Temps total (préparation + cuisson)
  int? get totalTimeMinutes {
    if (prepTimeMinutes == null && cookTimeMinutes == null) return null;
    return (prepTimeMinutes ?? 0) + (cookTimeMinutes ?? 0);
  }

  /// Crée une copie de la recette avec des valeurs modifiées
  Recipe copyWith({
    String? id,
    String? name,
    MealType? typeRepas,
    String? description,
    String? ingredients,
    String? steps,
    int? calories,
    int? proteines,
    int? glucides,
    int? lipides,
    List<String>? allergens,
    String? imagePath,
    List<String>? additionalImages,
    String? videoUrl,
    bool? isUserRecipe,
    bool? isSharedWithCommunity,
    String? ownerUserId,
    DateTime? createdAt,
    RecipeCategory? category,
    bool? isFavorite,
    String? mediaType,
    int? portions,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    RecipeDifficulty? difficulty,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      typeRepas: typeRepas ?? this.typeRepas,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      proteines: proteines ?? this.proteines,
      glucides: glucides ?? this.glucides,
      lipides: lipides ?? this.lipides,
      allergens: allergens ?? this.allergens,
      imagePath: imagePath ?? this.imagePath,
      additionalImages: additionalImages ?? this.additionalImages,
      videoUrl: videoUrl ?? this.videoUrl,
      isUserRecipe: isUserRecipe ?? this.isUserRecipe,
      isSharedWithCommunity: isSharedWithCommunity ?? this.isSharedWithCommunity,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      mediaType: mediaType ?? this.mediaType,
      portions: portions ?? this.portions,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

/// Notifier pour gérer les recettes (en mémoire)
class RecipeNotifier extends ChangeNotifier {
  static final RecipeNotifier _instance = RecipeNotifier._internal();
  factory RecipeNotifier() => _instance;
  RecipeNotifier._internal() {
    // Initialiser avec quelques recettes de démo pour la communauté
    _initializeDemoRecipes();
  }

  final List<Recipe> _recipes = [];
  static const String _currentUserId = 'user_demo_123'; // ID simulé

  void _initializeDemoRecipes() {
    _recipes.addAll([
      Recipe(
        id: 'demo_1',
        name: 'Porridge avoine-banane',
        typeRepas: MealType.breakfast,
        description: 'Un petit-déjeuner équilibré et rassasiant',
        ingredients: '• 50g de flocons d\'avoine\n• 1 banane\n• 200ml de lait d\'amande\n• 1 cuillère de miel\n• Cannelle',
        steps: '1. Faire chauffer le lait dans une casserole\n2. Ajouter les flocons d\'avoine et cuire 5 min\n3. Écraser la banane et l\'ajouter\n4. Servir avec miel et cannelle',
        calories: 380,
        proteines: 12,
        glucides: 65,
        lipides: 8,
        allergens: ['gluten'],
        imagePath: getRandomRecipeImage(),
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'community_user_1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        category: RecipeCategory.healthy,
        portions: 1,
      ),
      Recipe(
        id: 'demo_2',
        name: 'Salade de poulet grillé',
        typeRepas: MealType.lunch,
        description: 'Salade complète et protéinée',
        ingredients: '• 150g de blanc de poulet\n• Salade verte\n• Tomates cerises\n• Concombre\n• Avocat\n• Vinaigrette légère',
        steps: '1. Griller le poulet\n2. Couper les légumes\n3. Mélanger la salade\n4. Ajouter le poulet et l\'avocat\n5. Arroser de vinaigrette',
        calories: 450,
        proteines: 35,
        glucides: 15,
        lipides: 20,
        allergens: [],
        imagePath: getRandomRecipeImage(),
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'community_user_2',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        category: RecipeCategory.weightLoss,
        portions: 1,
      ),
      Recipe(
        id: 'demo_3',
        name: 'Smoothie protéiné',
        typeRepas: MealType.snack,
        description: 'Collation rapide et nutritive',
        ingredients: '• 1 banane\n• 30g de protéine en poudre\n• 200ml de lait\n• 1 cuillère de beurre de cacahuète\n• Glaçons',
        steps: '1. Mettre tous les ingrédients dans un blender\n2. Mixer jusqu\'à obtenir une texture lisse\n3. Servir frais',
        calories: 320,
        proteines: 28,
        glucides: 35,
        lipides: 8,
        allergens: ['lactose', 'arachide'],
        imagePath: getRandomRecipeImage(),
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'community_user_3',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        category: RecipeCategory.muscleGain,
        portions: 1,
      ),
      Recipe(
        id: 'demo_4',
        name: 'Bol énergétique matinal',
        typeRepas: MealType.breakfast,
        description: 'Petit-déjeuner riche en énergie pour bien démarrer la journée',
        ingredients: '• 60g de flocons d\'avoine\n• 1 banane\n• 20g de noix\n• 1 cuillère de miel\n• Fruits rouges',
        steps: '1. Préparer les flocons d\'avoine\n2. Ajouter la banane et les noix\n3. Arroser de miel\n4. Garnir de fruits rouges',
        calories: 420,
        proteines: 15,
        glucides: 70,
        lipides: 12,
        allergens: ['gluten', 'fruits à coque'],
        imagePath: getRandomRecipeImage(),
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'community_user_4',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        category: RecipeCategory.energy,
        portions: 1,
      ),
      Recipe(
        id: 'demo_5',
        name: 'Omelette protéinée',
        typeRepas: MealType.breakfast,
        description: 'Riche en protéines pour la prise de masse',
        ingredients: '• 3 œufs\n• 50g de blanc de poulet\n• Fromage allégé\n• Épinards\n• Tomates',
        steps: '1. Battre les œufs\n2. Faire revenir le poulet\n3. Ajouter les œufs et les légumes\n4. Cuire et servir',
        calories: 380,
        proteines: 42,
        glucides: 8,
        lipides: 18,
        allergens: ['œufs', 'lactose'],
        imagePath: getRandomRecipeImage(),
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'community_user_5',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        category: RecipeCategory.muscleGain,
        portions: 1,
      ),
      Recipe(
        id: 'demo_6',
        name: 'Salade de légumes verts',
        typeRepas: MealType.lunch,
        description: 'Légère et équilibrée pour la perte de poids',
        ingredients: '• Salade verte\n• Concombre\n• Tomates\n• Poivrons\n• Vinaigrette légère',
        steps: '1. Laver et couper les légumes\n2. Mélanger la salade\n3. Arroser de vinaigrette',
        calories: 180,
        proteines: 5,
        glucides: 20,
        lipides: 8,
        allergens: [],
        imagePath: getRandomRecipeImage(),
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'community_user_6',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        category: RecipeCategory.weightLoss,
        portions: 2,
      ),
      Recipe(
        id: 'demo_7',
        name: 'Bowl végétarien complet',
        typeRepas: MealType.dinner,
        description: 'Repas végétarien équilibré et complet',
        ingredients: '• Quinoa\n• Légumes grillés\n• Avocat\n• Graines de courge\n• Sauce tahini',
        steps: '1. Cuire le quinoa\n2. Griller les légumes\n3. Assembler le bowl\n4. Ajouter l\'avocat et les graines',
        calories: 480,
        proteines: 18,
        glucides: 55,
        lipides: 20,
        allergens: [],
        imagePath: getRandomRecipeImage(),
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'community_user_7',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        category: RecipeCategory.vegetarian,
        portions: 1,
      ),
      Recipe(
        id: 'demo_8',
        name: 'Wrap rapide poulet',
        typeRepas: MealType.lunch,
        description: 'Repas rapide et équilibré',
        ingredients: '• Tortilla complète\n• 100g de poulet\n• Légumes\n• Sauce légère',
        steps: '1. Préparer le poulet\n2. Garnir la tortilla\n3. Rouler et servir',
        calories: 350,
        proteines: 28,
        glucides: 35,
        lipides: 10,
        allergens: ['gluten'],
        imagePath: getRandomRecipeImage(),
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'community_user_8',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        category: RecipeCategory.quick,
        portions: 2,
      ),
    ]);
  }

  /// Récupère toutes les recettes de l'utilisateur
  List<Recipe> getUserRecipes() {
    return _recipes.where((r) => r.isUserRecipe && r.ownerUserId == _currentUserId).toList();
  }

  /// Récupère les recettes de la communauté
  List<Recipe> getCommunityRecipes() {
    return _recipes.where((r) => r.isSharedWithCommunity).toList();
  }

  /// Ajoute une recette
  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  /// Met à jour une recette
  void updateRecipe(Recipe recipe) {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _recipes[index] = recipe;
      notifyListeners();
    }
  }

  /// Supprime une recette
  void removeRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Récupère une recette par ID
  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Récupère les recettes favorites
  List<Recipe> getFavoriteRecipes() {
    return _recipes.where((r) => r.isFavorite).toList();
  }

  /// Bascule l'état favori d'une recette
  void toggleFavorite(String id) {
    final index = _recipes.indexWhere((r) => r.id == id);
    if (index != -1) {
      final recipe = _recipes[index];
      _recipes[index] = recipe.copyWith(isFavorite: !recipe.isFavorite);
      notifyListeners();
    }
  }

  /// Copie une recette de la communauté vers les recettes utilisateur
  void copyToUserRecipes(String recipeId) {
    final recipe = getRecipeById(recipeId);
    if (recipe != null) {
      final copiedRecipe = recipe.copyWith(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        isUserRecipe: true,
        isSharedWithCommunity: false,
        ownerUserId: _currentUserId,
        createdAt: DateTime.now(),
      );
      addRecipe(copiedRecipe);
    }
  }
}
