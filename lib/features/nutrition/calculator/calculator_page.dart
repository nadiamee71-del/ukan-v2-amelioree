import 'package:flutter/material.dart';
import 'models_demo.dart';

/// Simulateur nutritionnel avec sliders personnes/jours
/// Pour planifier les quantités, budget et nutrition sur plusieurs jours
class NutritionSimulatorPage extends StatefulWidget {
  final List<DemoFoodEntry> initialEntries; // pour précharger avec les repas du jour

  const NutritionSimulatorPage({
    super.key,
    this.initialEntries = const [],
  });

  @override
  State<NutritionSimulatorPage> createState() =>
      _NutritionSimulatorPageState();
}

class _NutritionSimulatorPageState
    extends State<NutritionSimulatorPage> {
  int _nbPersons = 2; // par défaut : couple
  int _nbDays = 7;
  double _budgetMax = 50;
  late final List<DemoIngredient> _allIngredients;
  final List<DemoFoodEntry> _entries = [];
  
  // PageController pour le swipe
  final PageController _pageController = PageController();
  int _currentTabIndex = 0;

  // objectifs journaliers (démo)
  static const double _goalKcalPerDay = 2000;
  static const double _goalProteinPerDay = 120;
  static const double _goalCarbsPerDay = 250;
  static const double _goalFatPerDay = 70;

  @override
  void initState() {
    super.initState();
    _allIngredients = buildDemoIngredients();
    // On clone pour éviter les références partagées
    _entries.addAll(widget.initialEntries.map((e) => DemoFoodEntry(
      ingredient: e.ingredient,
      quantityGrams: e.quantityGrams,
    )));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- Calculs ---

  // Multiplicateur global pour passer d'une journée/personne à Semaine/Groupe
  double get _multiplier => (_nbPersons * _nbDays).toDouble();

  double get totalKcalWeek => _entries.fold(0.0, (sum, e) => sum + e.totalKcal) * _multiplier;
  double get totalProteinWeek => _entries.fold(0.0, (sum, e) => sum + e.totalProtein) * _multiplier;
  double get totalCarbsWeek => _entries.fold(0.0, (sum, e) => sum + e.totalCarbs) * _multiplier;
  double get totalFatWeek => _entries.fold(0.0, (sum, e) => sum + e.totalFat) * _multiplier;
  double get totalPriceWeek => _entries.fold(0.0, (sum, e) => sum + e.totalPrice) * _multiplier;

  double get totalVegetablesKg => _entries.where((e) => e.ingredient.category == DemoIngredientCategory.vegetables)
      .fold(0.0, (sum, e) => sum + e.quantityGrams) * _multiplier / 1000;
  
  double get totalProteinsKg => _entries.where((e) => e.ingredient.category == DemoIngredientCategory.proteins)
      .fold(0.0, (sum, e) => sum + e.quantityGrams) * _multiplier / 1000;
      
  double get totalCarbsKg => _entries.where((e) => e.ingredient.category == DemoIngredientCategory.carbs)
      .fold(0.0, (sum, e) => sum + e.quantityGrams) * _multiplier / 1000;

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF050505);
    const Color accentYellow = Color(0xFFFFC300);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Simulateur Nutrition",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.grey),
                        onPressed: () => _showInfoDialog(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calculate, color: accentYellow),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // PILLS (Personnes)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildPill("Seul (1)", 1),
                  const SizedBox(width: 8),
                  _buildPill("Couple (2)", 2),
                  const SizedBox(width: 8),
                  _buildPill("Famille (4)", 4),
                  const SizedBox(width: 8),
                  _buildPill("Custom", -1, isCustom: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SLIDERS
            _buildSlider("Nombre de personnes : $_nbPersons", _nbPersons.toDouble(), 1, 8, 7, (val) {
              setState(() => _nbPersons = val.toInt());
            }),
            _buildSlider("Nombre de jours : $_nbDays", _nbDays.toDouble(), 1, 7, 6, (val) {
              setState(() => _nbDays = val.toInt());
            }),
            const SizedBox(height: 20),

            // ONGLETS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTabItem("Quantités", 0),
                  _buildTabItem("Budget €", 1),
                  _buildTabItem("Nutrition", 2),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CONTENU SWIPE
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentTabIndex = index);
                },
                children: [
                  _buildQuantitiesTab(),
                  _buildBudgetTab(),
                  _buildNutritionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Internes ---

  Widget _buildPill(String label, int value, {bool isCustom = false}) {
    bool isActive = isCustom 
        ? (_nbPersons != 1 && _nbPersons != 2 && _nbPersons != 4)
        : (_nbPersons == value);
    
    return GestureDetector(
      onTap: () {
        if (!isCustom) {
          setState(() => _nbPersons = value);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFC300) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? const Color(0xFFFFC300) : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, int divisions, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFFFC300),
              inactiveTrackColor: Colors.grey.shade800,
              thumbColor: const Color(0xFFFFC300),
              overlayColor: const Color(0xFFFFC300).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isActive = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: isActive ? BoxDecoration(
            color: const Color(0xFFFFC300),
            borderRadius: BorderRadius.circular(25),
          ) : null,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKangourouCard({required Widget content}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(0),
                    ),
                  ),
                  child: Text(
                    'Pour $_nbPersons personne${_nbPersons > 1 ? 's' : ''} sur $_nbDays jour${_nbDays > 1 ? 's' : ''}, il te faudra :',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/images/fitpro_logo_boxeur_replie.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
        onPressed: _openAddFoodBottomSheet,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Ajouter un aliment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  // --- Onglets ---

  Widget _buildQuantitiesTab() {
    final maxKg = [totalVegetablesKg, totalProteinsKg, totalCarbsKg].reduce((curr, next) => curr > next ? curr : next);
    // Avoid division by zero
    final safeMax = maxKg > 0 ? maxKg : 1.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildKangourouCard(
            content: Column(
              children: [
                _buildQtyRow("🥦", "Légumes", totalVegetablesKg, safeMax, Colors.green),
                const SizedBox(height: 12),
                _buildQtyRow("🍗", "Protéines", totalProteinsKg, safeMax, Colors.orange),
                const SizedBox(height: 12),
                _buildQtyRow("🍚", "Féculents", totalCarbsKg, safeMax, Colors.white),
                const SizedBox(height: 16),
                Text(
                  "Total : ${totalVegetablesKg.toStringAsFixed(1)}kg lég. / ${totalProteinsKg.toStringAsFixed(1)}kg prot.",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildAddButton(),
          _buildEntriesList(),
        ],
      ),
    );
  }

  Widget _buildQtyRow(String emoji, String label, double val, double max, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(6)),
                  ),
                  FractionallySizedBox(
                    widthFactor: (val / max).clamp(0.0, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            "${val.toStringAsFixed(1)} kg",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetTab() {
    final priceWeek = totalPriceWeek;
    final pricePerDay = _nbDays > 0 ? priceWeek / _nbDays : 0.0;
    final pricePerMeal = (_nbDays * 2) > 0 ? priceWeek / (_nbDays * 2) : 0.0;
    
    final ratio = _budgetMax > 0 ? (priceWeek / _budgetMax).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildKangourouCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Semaine estimée :", style: TextStyle(color: Colors.grey)),
                Text("${priceWeek.toStringAsFixed(2)} €", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Soit ${pricePerDay.toStringAsFixed(2)} € / jour", style: const TextStyle(color: Colors.white70)),
                Text("≈ ${pricePerMeal.toStringAsFixed(2)} € / repas", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                const Text("Budget max (€)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: const Color(0xFF222222),
                    color: ratio > 1 ? Colors.red : const Color(0xFFFFC300),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(8)),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Définir budget max',
                      labelStyle: TextStyle(color: Colors.grey),
                      suffixText: '€',
                      suffixStyle: TextStyle(color: Colors.white),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _budgetMax = double.tryParse(val) ?? 50;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildAddButton(),
          _buildEntriesList(),
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    final kcalDay = _nbDays > 0 ? totalKcalWeek / _nbDays : 0.0;
    final protDay = _nbDays > 0 ? totalProteinWeek / _nbDays : 0.0;
    final carbsDay = _nbDays > 0 ? totalCarbsWeek / _nbDays : 0.0;
    final fatDay = _nbDays > 0 ? totalFatWeek / _nbDays : 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildKangourouCard(
            content: Column(
              children: [
                _buildMacroProgress("Calories", kcalDay, _goalKcalPerDay * _nbPersons, "kcal", const Color(0xFFFFC300)),
                const SizedBox(height: 12),
                _buildMacroProgress("Protéines", protDay, _goalProteinPerDay * _nbPersons, "g", Colors.blue),
                const SizedBox(height: 12),
                _buildMacroProgress("Glucides", carbsDay, _goalCarbsPerDay * _nbPersons, "g", Colors.orange),
                const SizedBox(height: 12),
                _buildMacroProgress("Lipides", fatDay, _goalFatPerDay * _nbPersons, "g", Colors.purple),
              ],
            ),
          ),
          _buildAddButton(),
          _buildEntriesList(),
        ],
      ),
    );
  }

  Widget _buildMacroProgress(String label, double val, double goal, String unit, Color color) {
    final percent = goal > 0 ? (val / goal) : 0.0;
    final displayPercent = (percent * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text("${val.toInt()} / ${goal.toInt()} $unit", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF222222),
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: Text("$displayPercent %", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildEntriesList() {
    if (_entries.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Aliments de base (1 pers / 1 jour) :", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ..._entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(e.ingredient.category.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.ingredient.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("${e.quantityGrams.toInt()} ${e.ingredient.unit.label}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      _entries.remove(e);
                    });
                  },
                )
              ],
            ),
          )),
        ],
      ),
    );
  }

  // --- Add Food Logic ---

  void _openAddFoodBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddFoodSheet(
        allIngredients: _allIngredients,
        onAdd: (entry) {
          setState(() {
            _entries.add(entry);
          });
        },
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text("Simulateur", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Ce simulateur permet d'estimer vos besoins en quantités, budget et nutrition.\n\n"
          "Les calculs se basent sur les repas d'une personne sur une journée, multipliés par le nombre de personnes et de jours.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }
}

class _AddFoodSheet extends StatefulWidget {
  final List<DemoIngredient> allIngredients;
  final Function(DemoFoodEntry) onAdd;

  const _AddFoodSheet({required this.allIngredients, required this.onAdd});

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> with SingleTickerProviderStateMixin {
  DemoIngredient? _selectedIngredient;
  double _quantity = 100;
  
  // Catégories : enum + catégories personnalisées
  late List<_CategoryItem> _categories;
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialiser avec les catégories de l'enum + possibilité d'ajouter
    _categories = DemoIngredientCategory.values.map((cat) => _CategoryItem(
      category: cat,
      isCustom: false,
    )).toList();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {
        _selectedTabIndex = _tabController.index;
        _selectedIngredient = null; // Réinitialiser la sélection d'aliment
      });
    }
  }

  void _addCustomCategory() {
    showDialog(
      context: context,
      builder: (context) => _AddCategoryDialog(
        onAdd: (name, emoji) {
          setState(() {
            final newCategory = _CategoryItem(
              category: null,
              isCustom: true,
              customName: name,
              customEmoji: emoji,
            );
            _categories.add(newCategory);
            _tabController.dispose();
            _tabController = TabController(length: _categories.length, vsync: this);
            _tabController.addListener(_handleTabChange);
            _tabController.animateTo(_categories.length - 1);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  DemoIngredientCategory? _getCurrentCategory() {
    if (_selectedTabIndex >= _categories.length) return null;
    return _categories[_selectedTabIndex].category;
  }

  List<DemoIngredient> _getFilteredIngredients() {
    final currentCat = _getCurrentCategory();
    if (currentCat == null) {
      // Catégorie personnalisée vide pour l'instant (on pourrait ajouter des aliments personnalisés plus tard)
      return [];
    }
    return widget.allIngredients
        .where((i) => i.category == currentCat)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredIngredients = _getFilteredIngredients();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 40, height: 4, color: Colors.grey, margin: const EdgeInsets.only(bottom: 16)),
          const Text("Ajouter un aliment", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Onglets swipeables horizontaux
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: const Color(0xFFFFC300),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFFFFC300),
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 13),
                    tabs: _categories.map((cat) {
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat.displayEmoji),
                            const SizedBox(width: 6),
                            Text(cat.displayLabel),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Bouton "+" pour ajouter une catégorie
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: _addCustomCategory,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFC300),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFFFFC300),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu swipeable par onglet
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const PageScrollPhysics(),
              children: _categories.map((cat) {
                final catIngredients = cat.category != null
                    ? widget.allIngredients.where((i) => i.category == cat.category).toList()
                    : <DemoIngredient>[];
                
                if (catIngredients.isEmpty && cat.isCustom) {
                  // Catégorie personnalisée vide
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.displayEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Catégorie "${cat.displayLabel}"',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Aucun aliment dans cette catégorie pour le moment',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: catIngredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = catIngredients[index];
                    final isSel = _selectedIngredient == ingredient;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIngredient = ingredient),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFFC300).withOpacity(0.2) : const Color(0xFF222222),
                          borderRadius: BorderRadius.circular(12),
                          border: isSel ? Border.all(color: const Color(0xFFFFC300), width: 2) : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ingredient.name,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                            if (isSel) const Icon(Icons.check_circle, color: Color(0xFFFFC300)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Quantité & Valider
          if (_selectedIngredient != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quantité (${_selectedIngredient!.unit.label})",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() { if (_quantity > 10) _quantity -= 10; }),
                            icon: const Icon(Icons.remove, color: Colors.white),
                          ),
                          Text("${_quantity.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => setState(() => _quantity += 10),
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onAdd(DemoFoodEntry(
                          ingredient: _selectedIngredient!,
                          quantityGrams: _quantity,
                        ));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("VALIDER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Modèle pour représenter une catégorie (enum ou personnalisée)
class _CategoryItem {
  final DemoIngredientCategory? category;
  final bool isCustom;
  final String? customName;
  final String? customEmoji;

  _CategoryItem({
    required this.category,
    required this.isCustom,
    this.customName,
    this.customEmoji,
  });

  String get displayLabel {
    if (isCustom && customName != null) {
      return customName!;
    }
    return category?.label ?? 'Autre';
  }

  String get displayEmoji {
    if (isCustom && customEmoji != null) {
      return customEmoji!;
    }
    return category?.emoji ?? '📦';
  }
}

// Dialog pour ajouter une catégorie personnalisée
class _AddCategoryDialog extends StatefulWidget {
  final Function(String name, String emoji) onAdd;

  const _AddCategoryDialog({required this.onAdd});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController(text: '📦');
  
  final List<String> _suggestedEmojis = ['🌶️', '🧄', '🧅', '🥑', '🍄', '🌿', '🌱', '🥒', '🌽', '🥕', '🍠', '🥬'];

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF222222),
      title: const Text(
        'Nouvelle catégorie',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nom de la catégorie',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFC300)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFC300)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emojiController,
            style: const TextStyle(fontSize: 24),
            maxLength: 2,
            decoration: const InputDecoration(
              labelText: 'Emoji',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFC300)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFC300)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _suggestedEmojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _emojiController.text = emoji;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              widget.onAdd(
                _nameController.text.trim(),
                _emojiController.text.trim().isNotEmpty ? _emojiController.text.trim() : '📦',
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC300),
          ),
          child: const Text('Ajouter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

