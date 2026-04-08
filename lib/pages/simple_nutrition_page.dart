import 'package:flutter/material.dart';
import '../models/nutrition.dart';
import '../models/goals.dart';
import '../models/user_profile.dart';
import '../add_meal_page.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

// Couleurs professionnelles : Marron pour DashboardTab
const Color _marronPrincipal = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonce = Color(0xFF5D4037); // Material Brown 700
const Color _marronClair = Color(0xFFA1887F); // Material Brown 300

// Objectifs par défaut (démo)
const int _defaultCaloriesGoal = 2000;
const int _defaultProteinGoal = 120;
const int _defaultCarbsGoal = 250;
const int _defaultFatsGoal = 65;

// Suggestions de repas (démo)
class _MealSuggestion {
  final String title;
  final MealType mealType;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final List<String> allergens; // Allergènes contenus
  final bool isVegetarian;

  const _MealSuggestion({
    required this.title,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.allergens = const [],
    this.isVegetarian = false,
  });
}

class SimpleNutritionPage extends StatefulWidget {
  const SimpleNutritionPage({super.key});

  @override
  State<SimpleNutritionPage> createState() => _SimpleNutritionPageState();
}

class _SimpleNutritionPageState extends State<SimpleNutritionPage> {
  final _nutritionNotifier = NutritionNotifier();
  final _goalsNotifier = DailyGoalsNotifier();
  final _profileNotifier = UserProfileNotifier();

  // Suggestions de repas (démo)
  static final List<_MealSuggestion> _allSuggestions = [
    _MealSuggestion(
      title: 'Bol protéiné matin',
      mealType: MealType.breakfast,
      calories: 420,
      protein: 25,
      carbs: 45,
      fats: 12,
      allergens: ['lactose'],
      isVegetarian: true,
    ),
    _MealSuggestion(
      title: 'Porridge avoine-banane',
      mealType: MealType.breakfast,
      calories: 380,
      protein: 12,
      carbs: 65,
      fats: 8,
      allergens: ['gluten'],
      isVegetarian: true,
    ),
    _MealSuggestion(
      title: 'Déjeuner équilibré poulet / riz / légumes',
      mealType: MealType.lunch,
      calories: 550,
      protein: 40,
      carbs: 60,
      fats: 15,
      allergens: [],
      isVegetarian: false,
    ),
    _MealSuggestion(
      title: 'Salade complète végétarienne',
      mealType: MealType.lunch,
      calories: 480,
      protein: 20,
      carbs: 45,
      fats: 22,
      allergens: [],
      isVegetarian: true,
    ),
    _MealSuggestion(
      title: 'Smoothie protéiné',
      mealType: MealType.snack,
      calories: 320,
      protein: 28,
      carbs: 35,
      fats: 8,
      allergens: ['lactose', 'arachide'],
      isVegetarian: true,
    ),
    _MealSuggestion(
      title: 'Barre protéinée maison',
      mealType: MealType.snack,
      calories: 250,
      protein: 15,
      carbs: 30,
      fats: 8,
      allergens: ['gluten', 'arachide'],
      isVegetarian: true,
    ),
    _MealSuggestion(
      title: 'Saumon + légumes vapeur + riz',
      mealType: MealType.dinner,
      calories: 520,
      protein: 35,
      carbs: 55,
      fats: 18,
      allergens: [],
      isVegetarian: false,
    ),
    _MealSuggestion(
      title: 'Bowl végétarien protéiné',
      mealType: MealType.dinner,
      calories: 450,
      protein: 22,
      carbs: 50,
      fats: 16,
      allergens: [],
      isVegetarian: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nutritionNotifier.addListener(_onDataChanged);
    _goalsNotifier.addListener(_onDataChanged);
    _profileNotifier.addListener(_onDataChanged);
    // Détecter la page pour l'Alter Ego
    AlterEgoPageDetector.setupPageContext(UkanPage.nutritionDuJour);
  }

  @override
  void dispose() {
    _nutritionNotifier.removeListener(_onDataChanged);
    _goalsNotifier.removeListener(_onDataChanged);
    _profileNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  // Simuler les allergies/préférences de l'utilisateur (démo)
  List<String> _getUserAllergies() {
    // En démo, on peut simuler ou récupérer depuis le profil
    // Pour l'instant, retourner une liste vide ou avec quelques exemples
    return []; // Peut être modifié pour tester le filtrage
  }

  bool _isUserVegetarian() {
    // En démo, simuler ou récupérer depuis le profil
    return false; // Peut être modifié pour tester le filtrage
  }

  // Filtrer les suggestions selon allergies/préférences
  List<_MealSuggestion> _getFilteredSuggestions() {
    final allergies = _getUserAllergies();
    final isVegetarian = _isUserVegetarian();

    return _allSuggestions.where((suggestion) {
      // Exclure si contient des allergènes de l'utilisateur
      if (allergies.isNotEmpty) {
        final hasAllergen = suggestion.allergens.any((allergen) => allergies.contains(allergen));
        if (hasAllergen) return false;
      }

      // Si végétarien, exclure les suggestions non végétariennes
      if (isVegetarian && !suggestion.isVegetarian) return false;

      return true;
    }).toList();
  }

  void _useSuggestion(_MealSuggestion suggestion) {
    final mealEntry = MealEntry(
      id: 'suggestion_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      type: suggestion.mealType,
      title: suggestion.title,
      calories: suggestion.calories,
      protein: suggestion.protein,
      carbs: suggestion.carbs,
      fats: suggestion.fats,
    );

    _nutritionNotifier.addMeal(mealEntry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${suggestion.title} ajouté à ton repas du jour'),
        backgroundColor: _marronPrincipal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todaySummary = _nutritionNotifier.summaryForDate(today);

    // Objectifs (récupérer depuis goals ou utiliser les valeurs par défaut)
    final caloriesGoal = _defaultCaloriesGoal;
    final proteinGoal = _goalsNotifier.proteinGoalGrams > 0 
        ? _goalsNotifier.proteinGoalGrams 
        : _defaultProteinGoal;
    final carbsGoal = _defaultCarbsGoal;
    final fatsGoal = _defaultFatsGoal;

    // Progressions
    final caloriesProgress = (todaySummary.totalCalories / caloriesGoal).clamp(0.0, 1.0);
    final proteinProgress = (todaySummary.totalProtein / proteinGoal).clamp(0.0, 1.0);
    final carbsProgress = (todaySummary.totalCarbs / carbsGoal).clamp(0.0, 1.0);
    final fatsProgress = (todaySummary.totalFats / fatsGoal).clamp(0.0, 1.0);

    // Grouper les repas par type
    final mealsByType = <MealType, List<MealEntry>>{
      MealType.breakfast: [],
      MealType.lunch: [],
      MealType.snack: [],
      MealType.dinner: [],
    };

    for (final meal in todaySummary.meals) {
      mealsByType[meal.type]?.add(meal);
    }

    // Calculer les totaux par repas
    int _totalForType(MealType type, int Function(MealEntry) getter) {
      return mealsByType[type]?.fold<int>(0, (sum, meal) => sum + getter(meal)) ?? 0;
    }

    final filteredSuggestions = _getFilteredSuggestions();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: _marronFonce,
        foregroundColor: Colors.white,
        title: const Text('Repas & Courses'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddMealPage(date: today),
                ),
              );
            },
            tooltip: 'Ajouter un repas',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé global avec barres de progression
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      _marronPrincipal.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _marronPrincipal.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résumé du jour',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Calories
                    _MacroProgressCard(
                      label: 'Calories',
                      current: todaySummary.totalCalories,
                      goal: caloriesGoal,
                      unit: 'kcal',
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orange,
                      progress: caloriesProgress,
                    ),
                    const SizedBox(height: 16),
                    // Protéines
                    _MacroProgressCard(
                      label: 'Protéines',
                      current: todaySummary.totalProtein,
                      goal: proteinGoal,
                      unit: 'g',
                      icon: Icons.fitness_center_rounded,
                      color: Colors.green,
                      progress: proteinProgress,
                    ),
                    const SizedBox(height: 16),
                    // Glucides
                    _MacroProgressCard(
                      label: 'Glucides',
                      current: todaySummary.totalCarbs,
                      goal: carbsGoal,
                      unit: 'g',
                      icon: Icons.eco_rounded,
                      color: Colors.blue,
                      progress: carbsProgress,
                    ),
                    const SizedBox(height: 16),
                    // Lipides
                    _MacroProgressCard(
                      label: 'Lipides',
                      current: todaySummary.totalFats,
                      goal: fatsGoal,
                      unit: 'g',
                      icon: Icons.water_drop_rounded,
                      color: Colors.purple,
                      progress: fatsProgress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Repas par type
              _MealTypeSection(
                mealType: MealType.breakfast,
                meals: mealsByType[MealType.breakfast] ?? [],
                totalCalories: _totalForType(MealType.breakfast, (m) => m.calories),
                totalProtein: _totalForType(MealType.breakfast, (m) => m.protein),
                totalCarbs: _totalForType(MealType.breakfast, (m) => m.carbs),
                totalFats: _totalForType(MealType.breakfast, (m) => m.fats),
              ),
              const SizedBox(height: 16),
              _MealTypeSection(
                mealType: MealType.lunch,
                meals: mealsByType[MealType.lunch] ?? [],
                totalCalories: _totalForType(MealType.lunch, (m) => m.calories),
                totalProtein: _totalForType(MealType.lunch, (m) => m.protein),
                totalCarbs: _totalForType(MealType.lunch, (m) => m.carbs),
                totalFats: _totalForType(MealType.lunch, (m) => m.fats),
              ),
              const SizedBox(height: 16),
              _MealTypeSection(
                mealType: MealType.snack,
                meals: mealsByType[MealType.snack] ?? [],
                totalCalories: _totalForType(MealType.snack, (m) => m.calories),
                totalProtein: _totalForType(MealType.snack, (m) => m.protein),
                totalCarbs: _totalForType(MealType.snack, (m) => m.carbs),
                totalFats: _totalForType(MealType.snack, (m) => m.fats),
              ),
              const SizedBox(height: 16),
              _MealTypeSection(
                mealType: MealType.dinner,
                meals: mealsByType[MealType.dinner] ?? [],
                totalCalories: _totalForType(MealType.dinner, (m) => m.calories),
                totalProtein: _totalForType(MealType.dinner, (m) => m.protein),
                totalCarbs: _totalForType(MealType.dinner, (m) => m.carbs),
                totalFats: _totalForType(MealType.dinner, (m) => m.fats),
              ),
              const SizedBox(height: 32),
              // Suggestions de repas
              const Text(
                'Idées de repas pour aujourd\'hui',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              if (filteredSuggestions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      'Aucune suggestion disponible selon tes préférences',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...filteredSuggestions.take(4).map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealSuggestionCard(
                    suggestion: suggestion,
                    onUse: () => _useSuggestion(suggestion),
                  ),
                )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroProgressCard extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;

  const _MacroProgressCard({
    required this.label,
    required this.current,
    required this.goal,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$current / $goal $unit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: progress >= 1.0 ? Colors.green.shade700 : color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green.shade600 : color,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _MealTypeSection extends StatelessWidget {
  final MealType mealType;
  final List<MealEntry> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFats;

  const _MealTypeSection({
    required this.mealType,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });

  IconData _getIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.snack:
        return Icons.cookie;
      case MealType.dinner:
        return Icons.dinner_dining;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIcon(mealType),
                color: _marronPrincipal,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mealType.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Aucun repas enregistré',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          else ...[
            const SizedBox(height: 16),
            // Totaux du repas
            Row(
              children: [
                Expanded(
                  child: _MacroChip(
                    label: 'Cal',
                    value: '$totalCalories',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroChip(
                    label: 'P',
                    value: '${totalProtein}g',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroChip(
                    label: 'G',
                    value: '${totalCarbs}g',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroChip(
                    label: 'L',
                    value: '${totalFats}g',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Liste des repas
            ...meals.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      meal.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${meal.calories} kcal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSuggestionCard extends StatelessWidget {
  final _MealSuggestion suggestion;
  final VoidCallback onUse;

  const _MealSuggestionCard({
    required this.suggestion,
    required this.onUse,
  });

  IconData _getIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.snack:
        return Icons.cookie;
      case MealType.dinner:
        return Icons.dinner_dining;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _marronPrincipal.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _marronPrincipal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(suggestion.mealType),
              color: _marronPrincipal,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.mealType.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SuggestionMacro(label: 'Cal', value: '${suggestion.calories}', color: Colors.orange),
                    const SizedBox(width: 8),
                    _SuggestionMacro(label: 'P', value: '${suggestion.protein}g', color: Colors.green),
                    const SizedBox(width: 8),
                    _SuggestionMacro(label: 'G', value: '${suggestion.carbs}g', color: Colors.blue),
                    const SizedBox(width: 8),
                    _SuggestionMacro(label: 'L', value: '${suggestion.fats}g', color: Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onUse,
            style: ElevatedButton.styleFrom(
              backgroundColor: _marronPrincipal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ajouter',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionMacro extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SuggestionMacro({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
