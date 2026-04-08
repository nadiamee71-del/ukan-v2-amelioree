import 'package:flutter/material.dart';
import 'calculator/calculator_page.dart'; // NutritionSimulatorPage
import 'calculator/models_demo.dart';
import 'calculator/numeric_calculator_page.dart'; // NumericCalculatorPage (pavé numérique)
import 'meal_planner_page.dart';
import 'widgets/day_summary_card.dart';
import 'widgets/meal_card.dart';
import 'widgets/shopping_list_tab.dart';

class RepasCoursesPage extends StatefulWidget {
  const RepasCoursesPage({super.key});

  @override
  State<RepasCoursesPage> createState() => _RepasCoursesPageState();
}

class _RepasCoursesPageState extends State<RepasCoursesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Données de repas démo (State local)
  final Map<String, List<DemoFoodEntry>> _meals = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 onglets maintenant
    _initDemoMeals();
  }

  void _initDemoMeals() {
    // Charger des ingrédients depuis la base démo
    final all = buildDemoIngredients();
    
    // Helpers pour trouver ingrédient
    DemoIngredient getIng(String id) => all.firstWhere((i) => i.id == id, orElse: () => all.first);

    _meals['Petit-déjeuner'] = [
      DemoFoodEntry(ingredient: getIng('carb_avoine'), quantityGrams: 60),
      DemoFoodEntry(ingredient: getIng('fruit_banane'), quantityGrams: 100),
      DemoFoodEntry(ingredient: getIng('dairy_skyr'), quantityGrams: 100),
    ];

    _meals['Déjeuner'] = [
      DemoFoodEntry(ingredient: getIng('prot_poulet'), quantityGrams: 150),
      DemoFoodEntry(ingredient: getIng('carb_riz'), quantityGrams: 200),
      DemoFoodEntry(ingredient: getIng('veg_brocoli'), quantityGrams: 150),
    ];

    _meals['Dîner'] = [
      DemoFoodEntry(ingredient: getIng('egg_oeuf'), quantityGrams: 2), // 2 oeufs
      DemoFoodEntry(ingredient: getIng('veg_salade'), quantityGrams: 100),
      DemoFoodEntry(ingredient: getIng('veg_tomate'), quantityGrams: 100),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Logic Calculs ---

  double get _dayTotalKcal {
    return _meals.values.expand((e) => e).fold(0.0, (sum, e) => sum + e.totalKcal);
  }
  double get _dayTotalProt {
    return _meals.values.expand((e) => e).fold(0.0, (sum, e) => sum + e.totalProtein);
  }
  double get _dayTotalCarbs {
    return _meals.values.expand((e) => e).fold(0.0, (sum, e) => sum + e.totalCarbs);
  }
  double get _dayTotalFat {
    return _meals.values.expand((e) => e).fold(0.0, (sum, e) => sum + e.totalFat);
  }
  double get _dayTotalPrice {
    return _meals.values.expand((e) => e).fold(0.0, (sum, e) => sum + e.totalPrice);
  }

  void _openSimulatorWithAll() {
    final allEntries = _meals.values.expand((e) => e).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NutritionSimulatorPage(initialEntries: allEntries),
      ),
    );
  }

  void _openSimulatorWithMeal(List<DemoFoodEntry> entries) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NutritionSimulatorPage(initialEntries: entries),
      ),
    );
  }

  void _openNumericCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NumericCalculatorPage(),
      ),
    );
  }

  void _openMealPlanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MealPlannerPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Style mode sombre global pour cette section
    const Color darkBg = Color(0xFF050505);
    const Color accentYellow = Color(0xFFFFC300);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        title: const Text('Repas & Courses 2.0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Bouton calculatrice avec pavé numérique
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentYellow, accentYellow.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentYellow.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
              tooltip: 'Calculatrice avec pavé numérique',
              onPressed: _openNumericCalculator,
            ),
          ),
          // Bouton planning alimentaire
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4FC3F7),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF4FC3F7),
                  size: 22,
                ),
              ),
              tooltip: 'Planning alimentaire',
              onPressed: _openMealPlanner,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre d'onglets custom
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: accentYellow,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Repas'),
                Tab(text: 'Courses'),
                Tab(text: 'Planning'),
              ],
            ),
          ),

          // Contenu Swipe
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet 1 : Repas
                ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    DaySummaryCard(
                      totalKcal: _dayTotalKcal,
                      totalProtein: _dayTotalProt,
                      totalCarbs: _dayTotalCarbs,
                      totalFat: _dayTotalFat,
                      totalPrice: _dayTotalPrice,
                    ),
                    ..._meals.entries.map((entry) {
                      return MealCard(
                        title: entry.key,
                        subtitle: 'Recette perso', // ou vide
                        entries: entry.value,
                        onUpdateQuantity: (foodEntry, newQty) {
                          setState(() {
                            foodEntry.quantityGrams = newQty;
                          });
                        },
                        onSendToCalculator: () => _openSimulatorWithMeal(entry.value),
                      );
                    }),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _openSimulatorWithAll,
                        icon: const Icon(Icons.auto_graph),
                        label: const Text('Simulateur Nutrition'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: accentYellow,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                // Onglet 2 : Courses
                const ShoppingListTab(),

                // Onglet 3 : Planning alimentaire intégré
                _buildPlanningTab(accentYellow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningTab(Color accent) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card d'introduction
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4FC3F7).withOpacity(0.2),
                  const Color(0xFF4FC3F7).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Planning Alimentaire',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Organise ta semaine facilement',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openMealPlanner,
                    icon: const Icon(Icons.open_in_new, size: 20),
                    label: const Text('Ouvrir le Planning'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Aperçu des repas de la semaine
          const Text(
            'Aperçu de la semaine',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Mini cartes pour chaque jour
          ...List.generate(7, (index) {
            final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
            final colors = [
              const Color(0xFFFFB74D),
              const Color(0xFF4FC3F7),
              const Color(0xFFA5D6A7),
              const Color(0xFFCE93D8),
              const Color(0xFFFF8A65),
              const Color(0xFF90CAF9),
              const Color(0xFFF48FB1),
            ];
            
            return GestureDetector(
              onTap: _openMealPlanner,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                    left: BorderSide(color: colors[index], width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors[index].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          days[index].substring(0, 2),
                          style: TextStyle(
                            color: colors[index],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            days[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            index < 3 ? '4 repas planifiés' : 'Cliquez pour planifier',
                            style: TextStyle(
                              color: index < 3 ? Colors.green : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      index < 3 ? Icons.check_circle : Icons.add_circle_outline,
                      color: index < 3 ? Colors.green : colors[index],
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Calculatrice section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(0.2),
                  accent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calculate, color: Colors.black, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calculatrice Nutrition',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pavé numérique + Mode Expert',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openNumericCalculator,
                    icon: const Icon(Icons.dialpad, size: 20),
                    label: const Text('Ouvrir la Calculatrice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

