import 'package:flutter/material.dart';
import 'calculator/models_demo.dart';

/// Planning alimentaire visuel façon "emploi du temps"
/// Avec swipe horizontal pour naviguer entre les jours
class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  late PageController _pageController;
  int _currentDayIndex = 0;
  
  // Les jours de la semaine
  final List<String> _days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  
  // Types de repas
  final List<_MealType> _mealTypes = [
    _MealType(name: 'Petit-déjeuner', icon: Icons.wb_sunny, color: const Color(0xFFFFB74D)),
    _MealType(name: 'Déjeuner', icon: Icons.restaurant, color: const Color(0xFF4FC3F7)),
    _MealType(name: 'Collation', icon: Icons.apple, color: const Color(0xFFA5D6A7)),
    _MealType(name: 'Dîner', icon: Icons.nightlight_round, color: const Color(0xFFCE93D8)),
  ];
  
  // Planning démo (recettes par jour et par repas)
  late Map<int, Map<String, _MealPlanEntry?>> _weekPlan;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _initDemoWeekPlan();
  }

  void _initDemoWeekPlan() {
    _weekPlan = {};
    for (int i = 0; i < 7; i++) {
      _weekPlan[i] = {};
      for (var meal in _mealTypes) {
        _weekPlan[i]![meal.name] = null;
      }
    }
    
    // Remplir avec des recettes démo
    _weekPlan[0]!['Petit-déjeuner'] = _MealPlanEntry(
      title: 'Bowl Avoine Banane',
      imageAsset: 'assets/images/foodscan/bowl_avoine_choco.png',
      calories: 350,
    );
    _weekPlan[0]!['Déjeuner'] = _MealPlanEntry(
      title: 'Poulet Grillé & Riz',
      imageAsset: 'assets/images/foodscan/salade_poulet_scan.png',
      calories: 520,
    );
    _weekPlan[0]!['Collation'] = _MealPlanEntry(
      title: 'Smoothie Fraise',
      imageAsset: 'assets/images/foodscan/smoothie_fraise.png',
      calories: 180,
    );
    _weekPlan[0]!['Dîner'] = _MealPlanEntry(
      title: 'Omelette Légumes',
      imageAsset: 'assets/images/foodscan/burger_scan.png',
      calories: 380,
    );
    
    _weekPlan[1]!['Petit-déjeuner'] = _MealPlanEntry(
      title: 'Pancakes Protéinés',
      imageAsset: 'assets/images/foodscan/pates_bolo_scan.png',
      calories: 420,
    );
    _weekPlan[1]!['Déjeuner'] = _MealPlanEntry(
      title: 'Salade César',
      imageAsset: 'assets/images/foodscan/salade_poulet_scan.png',
      calories: 450,
    );
    
    _weekPlan[2]!['Petit-déjeuner'] = _MealPlanEntry(
      title: 'Tartines Avocat',
      imageAsset: 'assets/images/foodscan/smoothie_fraise.png',
      calories: 380,
    );
    _weekPlan[2]!['Déjeuner'] = _MealPlanEntry(
      title: 'Pâtes Bolo Légères',
      imageAsset: 'assets/images/foodscan/pates_bolo_scan.png',
      calories: 580,
    );
    _weekPlan[2]!['Dîner'] = _MealPlanEntry(
      title: 'Soupe Légumes',
      imageAsset: 'assets/images/foodscan/salade_poulet_scan.png',
      calories: 250,
    );
    
    _weekPlan[3]!['Petit-déjeuner'] = _MealPlanEntry(
      title: 'Granola Yaourt',
      imageAsset: 'assets/images/foodscan/bowl_avoine_choco.png',
      calories: 320,
    );
    
    _weekPlan[4]!['Déjeuner'] = _MealPlanEntry(
      title: 'Buddha Bowl',
      imageAsset: 'assets/images/foodscan/salade_poulet_scan.png',
      calories: 490,
    );
    _weekPlan[4]!['Dîner'] = _MealPlanEntry(
      title: 'Wrap Poulet',
      imageAsset: 'assets/images/foodscan/burger_scan.png',
      calories: 420,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0A0E27);
    const Color accentYellow = Color(0xFFFFC300);
    
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mon Planning Repas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: accentYellow),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicateur de jours en haut (dots)
          _buildDayIndicator(accentYellow),
          const SizedBox(height: 8),
          
          // Titre du jour actuel
          Text(
            _days[_currentDayIndex],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Swipe ← → pour changer de jour',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          
          // Planning swipeable
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentDayIndex = index);
              },
              itemCount: 7,
              itemBuilder: (context, dayIndex) {
                return _buildDaySchedule(dayIndex, accentYellow);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayIndicator(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          final isActive = index == _currentDayIndex;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 32 : 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? accent : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isActive
                  ? Center(
                      child: Text(
                        _days[index].substring(0, 1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDaySchedule(int dayIndex, Color accent) {
    final dayPlan = _weekPlan[dayIndex]!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A),
            const Color(0xFF0F1225),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _mealTypes.map((mealType) {
            final entry = dayPlan[mealType.name];
            return _buildMealSlot(mealType, entry, dayIndex);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMealSlot(_MealType mealType, _MealPlanEntry? entry, int dayIndex) {
    return GestureDetector(
      onTap: () => _showEditMealDialog(dayIndex, mealType),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              mealType.color.withOpacity(0.15),
              mealType.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mealType.color.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Barre colorée à gauche
            Container(
              width: 6,
              height: 100,
              decoration: BoxDecoration(
                color: mealType.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            
            // Icône du repas
            Container(
              width: 50,
              height: 100,
              alignment: Alignment.center,
              child: Icon(
                mealType.icon,
                color: mealType.color,
                size: 28,
              ),
            ),
            
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mealType.name,
                      style: TextStyle(
                        color: mealType.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (entry != null) ...[
                      Text(
                        entry.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.calories} kcal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.white.withOpacity(0.4),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ajouter un repas',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Image miniature
            if (entry != null)
              Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: mealType.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    entry.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: mealType.color.withOpacity(0.3),
                      child: Icon(mealType.icon, color: Colors.white),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.white.withOpacity(0.3),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditMealDialog(int dayIndex, _MealType mealType) {
    // Liste de recettes démo
    final demoRecipes = [
      _MealPlanEntry(title: 'Bowl Avoine Banane', imageAsset: 'assets/images/foodscan/bowl_avoine_choco.png', calories: 350),
      _MealPlanEntry(title: 'Poulet Grillé & Riz', imageAsset: 'assets/images/foodscan/salade_poulet_scan.png', calories: 520),
      _MealPlanEntry(title: 'Smoothie Fraise', imageAsset: 'assets/images/foodscan/smoothie_fraise.png', calories: 180),
      _MealPlanEntry(title: 'Pâtes Bolo Légères', imageAsset: 'assets/images/foodscan/pates_bolo_scan.png', calories: 580),
      _MealPlanEntry(title: 'Salade César', imageAsset: 'assets/images/foodscan/salade_poulet_scan.png', calories: 450),
      _MealPlanEntry(title: 'Wrap Poulet', imageAsset: 'assets/images/foodscan/burger_scan.png', calories: 420),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(
              '${mealType.name} - ${_days[dayIndex]}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Option supprimer si repas existant
            if (_weekPlan[dayIndex]![mealType.name] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _weekPlan[dayIndex]![mealType.name] = null;
                    });
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Supprimer ce repas', style: TextStyle(color: Colors.red)),
                ),
              ),
            
            const Divider(color: Colors.white24),
            
            // Liste des recettes
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: demoRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = demoRecipes[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _weekPlan[dayIndex]![mealType.name] = recipe;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1225),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: mealType.color.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              recipe.imageAsset,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: mealType.color.withOpacity(0.3),
                                child: Icon(mealType.icon, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${recipe.calories} kcal',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.add_circle, color: mealType.color, size: 28),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealType {
  final String name;
  final IconData icon;
  final Color color;

  _MealType({required this.name, required this.icon, required this.color});
}

class _MealPlanEntry {
  final String title;
  final String imageAsset;
  final int calories;

  _MealPlanEntry({required this.title, required this.imageAsset, required this.calories});
}








