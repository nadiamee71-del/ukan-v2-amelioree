part of ukan_main;

class DashboardTab extends StatefulWidget {
  final VoidCallback onOpenNextWorkout;

  const DashboardTab({super.key, required this.onOpenNextWorkout});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

// Couleurs de marque / accents : lisibles dans les deux thèmes → constantes.
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryCyan = Color(0xFF22D3EE);

// Couleurs dépendantes du thème global (clair/sombre). Sans BuildContext (ces
// noms sont partagés dans la bibliothèque ukan_main via `part of`), on lit le
// singleton ThemeNotifier ; le MaterialApp se reconstruit au changement de mode.
Color get _darkBg => ThemeNotifier().isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFF5F6F8);
Color get _cardBg => ThemeNotifier().isDarkMode ? const Color(0xFF161B22) : Colors.white;
Color get _cardBgLight => ThemeNotifier().isDarkMode ? const Color(0xFF21262D) : const Color(0xFFEFF1F4);
Color get _textLight => ThemeNotifier().isDarkMode ? const Color(0xFFF0F6FC) : const Color(0xFF1A1D21);
Color get _textMuted => ThemeNotifier().isDarkMode ? const Color(0xFF8B949E) : const Color(0xFF6B7280);
Color get _borderColor => ThemeNotifier().isDarkMode ? const Color(0xFF30363D) : const Color(0xFFE2E5EA);

// Couleurs d'accent pour les icônes (conservées mais atténuées)
const Color _accentPurple = Color(0xFFA855F7);
const Color _accentBlue = Color(0xFF58A6FF);
const Color _accentGreen = Color(0xFF4ECDC4);
const Color _accentOrange = Color(0xFFFF9F43);
const Color _accentRed = Color(0xFFFF6B6B);

// Anciennes couleurs (pour compatibilité temporaire)
const Color _violetPrincipal = Color(0xFFA855F7);
const Color _violetClair = Color(0xFFBA68C8);
const Color _marronPrincipal = Color(0xFF8D6E63);
const Color _marronFonce = Color(0xFF5D4037);
const Color _marronClair = Color(0xFFA1887F);

// Modèles pour les repas et la liste de courses
class MealItem {
  final String title;
  final int calories;
  final double price;
  final List<String> ingredients;

  MealItem({
    required this.title,
    required this.calories,
    required this.price,
    required this.ingredients,
  });
}

class GroceryCategory {
  final String title;
  final List<String> items;

  GroceryCategory({
    required this.title,
    required this.items,
  });
}

// Modèle pour un aliment dans la calculatrice
class CalculatorFoodItem {
  String name;
  double quantity; // en g ou ml
  String unit; // 'g', 'ml', ou 'portion'
  double calories;
  double protein; // en g
  double carbs; // en g
  double fat; // en g
  double price; // en €

  CalculatorFoodItem({
    this.name = '',
    this.quantity = 0.0,
    this.unit = 'g',
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.price = 0.0,
  });

  CalculatorFoodItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? price,
  }) {
    return CalculatorFoodItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      price: price ?? this.price,
    );
  }
}

class _DashboardTabState extends State<DashboardTab> with TickerProviderStateMixin {
  static const int _targetSessionsPerWeek = 3;
  static const int _targetCaloriesPerDay = 2000;
  static const int _stepsGoal = 8000;

  final _historyNotifier = WorkoutHistoryNotifier();
  final _nutritionNotifier = NutritionNotifier();
  final _goalsNotifier = DailyGoalsNotifier();
  final _stepsNotifier = StepsNotifier();
  final _alterEgoHelper = DashboardAlterEgoHelper();
  final _alterEgoService = AlterEgoService();
  bool _hasWelcomed = false;

  // Liste de courses modifiable
  List<GroceryCategory> _customGroceryList = [];

  // Totaux de la calculatrice
  double _calculatorCalories = 0.0;
  double _calculatorPrice = 0.0;

  // Liste des aliments dans la calculatrice
  List<CalculatorFoodItem> _calculatorFoodItems = [];
  int? _selectedFoodIndex; // null = nouvel aliment

  // Données codées en dur pour les repas
  final MealItem _breakfast = MealItem(
    title: 'Bowl avoine chocolat banane',
    calories: 450,
    price: 2.90,
    ingredients: [
      'Flocons d\'avoine',
      'Banane',
      'Lait ou boisson végétale',
      'Pépites de chocolat noir',
    ],
  );

  final MealItem _lunch = MealItem(
    title: 'Poulet curry + riz basmati',
    calories: 720,
    price: 4.80,
    ingredients: [
      'Filet de poulet',
      'Riz basmati',
      'Crème légère ou coco',
      'Épices curry',
      'Oignon',
    ],
  );

  final MealItem _dinner = MealItem(
    title: 'Omelette légumes + salade',
    calories: 610,
    price: 3.20,
    ingredients: [
      'Oeufs',
      'Poivrons / oignons',
      'Tomates cerise',
      'Salade verte',
    ],
  );

  // Liste de courses automatique (base) + personnalisée
  List<GroceryCategory> get _groceryList {
    final baseList = [
      GroceryCategory(
        title: '🥬 Légumes',
        items: [
          'Oignon',
          'Poivrons',
          'Salade',
          'Tomates cerise',
        ],
      ),
      GroceryCategory(
        title: '🍎 Fruits',
        items: [
          'Banane',
        ],
      ),
      GroceryCategory(
        title: '🥩 Protéines',
        items: [
          'Filet de poulet',
          'Œufs',
        ],
      ),
      GroceryCategory(
        title: '🥛 Produits laitiers / végétaux',
        items: [
          'Lait ou boisson végétale',
          'Crème légère ou coco',
        ],
      ),
      GroceryCategory(
        title: '🍞 Féculents',
        items: [
          'Riz basmati',
          'Flocons d\'avoine',
        ],
      ),
      GroceryCategory(
        title: '🍫 Divers',
        items: [
          'Pépites de chocolat noir',
          'Épices curry',
        ],
      ),
    ];

    // Fusionner avec les courses personnalisées
    final mergedList = <GroceryCategory>[];
    final allCategories = [...baseList, ..._customGroceryList];
    
    // Grouper par titre de catégorie
    final categoryMap = <String, List<String>>{};
    for (var category in allCategories) {
      if (categoryMap.containsKey(category.title)) {
        categoryMap[category.title]!.addAll(category.items);
      } else {
        categoryMap[category.title] = List<String>.from(category.items);
      }
    }

    // Créer la liste fusionnée
    for (var entry in categoryMap.entries) {
      mergedList.add(GroceryCategory(
        title: entry.key,
        items: entry.value.toSet().toList(), // Supprimer les doublons
      ));
    }

    return mergedList;
  }

  int get _totalCalories => (_breakfast.calories + _lunch.calories + _dinner.calories + _calculatorCalories).round();
  double get _totalPrice => _breakfast.price + _lunch.price + _dinner.price + _calculatorPrice;

  String _formatPrice(double price) => price.toStringAsFixed(2).replaceAll('.', ',');

  @override
  void initState() {
    super.initState();
    _historyNotifier.addListener(_onDataChanged);
    _nutritionNotifier.addListener(_onDataChanged);
    _goalsNotifier.addListener(_onDataChanged);
    _stepsNotifier.addListener(_onDataChanged);
    // Démarrer le compteur de pas automatique
    _stepsNotifier.startCounting();
    // Détecter la page pour l'Alter Ego
    AlterEgoPageDetector.setupPageContext(UkanPage.accueil);
    // Positionner l'Alter Ego en haut à droite pour cet écran
    try {
      _alterEgoService.setVisible(true); // Activer l'Alter Ego
      _alterEgoService.setPosition(AlterEgoPosition.topRight);
      // Message de bienvenue au premier affichage - VÉRIFIEZ QUE CET APPEL EST LÀ !
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _updateAlterEgoReaction();
            }
          });
        }
      });
    } catch (e) {
      debugPrint('Erreur initialisation Alter Ego: $e');
      // Désactiver l'Alter Ego en cas d'erreur
      _alterEgoService.setVisible(false);
    }
  }

  @override
  void dispose() {
    _historyNotifier.removeListener(_onDataChanged);
    _nutritionNotifier.removeListener(_onDataChanged);
    _goalsNotifier.removeListener(_onDataChanged);
    _stepsNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
    // Mettre à jour les réactions de l'Alter Ego quand les données changent
    _updateAlterEgoReaction();
  }

  // Helper pour obtenir la couleur de texte selon le thème
  Color _getTextColor() {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;
    return isDarkMode ? Colors.white : Colors.black87;
  }

  // Helper pour obtenir la couleur de texte secondaire selon le thème
  Color _getSecondaryTextColor() {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;
    return isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
  }

  void _updateAlterEgoReaction() {
    try {
      final weekSummary = _historyNotifier.summaryForWeek(DateTime.now());
      final today = DateTime.now();
      final currentSteps = _stepsNotifier.totalForDate(today);
      final waterProgress = _goalsNotifier.waterProgressForDate(today);
      
      _alterEgoHelper.reactToProgress(
        currentSteps: currentSteps,
        goalSteps: _stepsGoal,
        currentSessions: weekSummary.sessionsCount,
        goalSessions: _targetSessionsPerWeek,
        waterProgress: waterProgress,
        isFirstVisit: !_hasWelcomed,
      );
      
      if (!_hasWelcomed) {
        _hasWelcomed = true;
      }
    } catch (e) {
      debugPrint('Erreur mise à jour Alter Ego: $e');
    }
  }

  String _formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final difference = today.difference(targetDate).inDays;

    if (targetDate == today) {
      return 'Aujourd\'hui';
    } else if (targetDate == yesterday) {
      return 'Hier';
    } else if (difference > 0) {
      return 'Il y a $difference jour${difference > 1 ? 's' : ''}';
    } else {
      return 'Dans ${-difference} jour${-difference > 1 ? 's' : ''}';
    }
  }

  int _calculateUkanScore(WeeklyWorkoutSummary weekSummary, int todayCalories) {
    // sessionsScore max 50 points
    final sessionsRatio = weekSummary.sessionsCount / _targetSessionsPerWeek;
    final sessionsScore = (sessionsRatio.clamp(0.0, 1.0) * 50).round();

    // nutritionScore max 30 points
    final diffRatio = (todayCalories - _targetCaloriesPerDay).abs() / _targetCaloriesPerDay;
    final nutritionFactor = (1.0 - diffRatio).clamp(0.0, 1.0);
    final nutritionScore = (nutritionFactor * 30).round();

    // Bonus hydratation (+10 points si objectif atteint)
    final today = DateTime.now();
    final waterProgress = _goalsNotifier.waterProgressForDate(today);
    final hydrationBonus = waterProgress >= 1.0 ? 10 : 0;

    // Bonus protéines (+10 points si objectif atteint)
    final proteinProgress = _goalsNotifier.proteinProgressForDate(today);
    final proteinBonus = proteinProgress >= 1.0 ? 10 : 0;

    // Bonus sommeil (+10 points si dernière nuit dans l'objectif)
    final lastSleep = _goalsNotifier.lastSleepEntry();
    final sleepBonus = lastSleep != null && 
        (lastSleep.durationMinutes / 60.0) >= (_goalsNotifier.sleepGoalHours - 1.0) &&
        (lastSleep.durationMinutes / 60.0) <= (_goalsNotifier.sleepGoalHours + 1.0)
        ? 10 : 0;

    final fitProScore = (sessionsScore + nutritionScore + hydrationBonus + proteinBonus + sleepBonus).clamp(0, 100);
    return fitProScore;
  }

  String _getUkanScoreText(int score) {
    if (score < 40) {
      return 'On pose les bases.';
    } else if (score < 70) {
      return 'Tu es sur une bonne dynamique.';
    } else {
      return 'Excellent rythme, continue comme ça.';
    }
  }

  String _getCaloriesStatus(int calories) {
    if (calories == 0) {
      return 'Pas encore de repas enregistrés.';
    } else if (calories >= 1600 && calories <= 2400) {
      return 'Dans la bonne zone.';
    } else if (calories < 1600) {
      return 'Très en dessous de l\'objectif.';
    } else {
      return 'Au-dessus de l\'objectif.';
    }
  }

  Color _getCaloriesStatusColor(int calories) {
    if (calories == 0) {
      return Colors.black54;
    } else if (calories >= 1600 && calories <= 2400) {
      return Colors.green.shade700;
    } else if (calories < 1600) {
      return Colors.orange.shade700;
    } else {
      return Colors.red.shade600;
    }
  }

  // État pour le bouton de navigation sélectionné ('planning' par défaut, 'stats')
  // RESTE ACTIF après retour de la page (comme Explorer/Mes suivis)
  // 'planning' est sélectionné par défaut comme 'Explorer' dans FeedPage
  String _selectedNavButton = 'planning';

  @override
  Widget build(BuildContext context) {
    final weekSummary = _historyNotifier.summaryForWeek(DateTime.now());
    final todaySummary = _nutritionNotifier.summaryForDate(DateTime.now());
    
    // Couleurs identiques à FeedPage pour uniformité
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textMuted = Color(0xFF8B949E);
    const double uniformBorderRadius = 16.0;
    const double uniformBorderWidth = 1.5;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Boutons "Planning" / "Statistiques" - MÊME STYLE que "Explorer / Mes suivis"
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Conteneur pill IDENTIQUE à FeedPage
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardBgLight,
                    borderRadius: BorderRadius.circular(uniformBorderRadius),
                    border: Border.all(
                      color: cardBgLight.withOpacity(0.5),
                      width: uniformBorderWidth,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton "Planning" - style IDENTIQUE à _TabButton de FeedPage
                      // RESTE ACTIF après navigation (comme Explorer/Mes suivis)
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedNavButton = 'planning');
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PlanningPage()),
                            );
                            // Ne PAS remettre à null - le bouton reste actif
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedNavButton == 'planning' 
                                ? primaryGold.withOpacity(0.15) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(uniformBorderRadius),
                            border: Border.all(
                              color: _selectedNavButton == 'planning' 
                                  ? primaryGold 
                                  : Colors.transparent,
                              width: uniformBorderWidth,
                            ),
                          ),
                          child: Text(
                            'Planning',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedNavButton == 'planning' 
                                  ? FontWeight.w700 
                                  : FontWeight.w500,
                              color: _selectedNavButton == 'planning' 
                                  ? primaryGold 
                                  : textMuted,
                            ),
                          ),
                        ),
                      ),
                      // Bouton "Statistiques" - style IDENTIQUE à _TabButton de FeedPage
                      // RESTE ACTIF après navigation (comme Explorer/Mes suivis)
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedNavButton = 'stats');
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const StatsPage()),
                            );
                            // Ne PAS remettre à null - le bouton reste actif
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedNavButton == 'stats' 
                                ? primaryGold.withOpacity(0.15) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(uniformBorderRadius),
                            border: Border.all(
                              color: _selectedNavButton == 'stats' 
                                  ? primaryGold 
                                  : Colors.transparent,
                              width: uniformBorderWidth,
                            ),
                          ),
                          child: Text(
                            'Statistiques',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedNavButton == 'stats' 
                                  ? FontWeight.w700 
                                  : FontWeight.w500,
                              color: _selectedNavButton == 'stats' 
                                  ? primaryGold 
                                  : textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton Messages à droite (même position que "Mon livre de recettes")
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MessageInboxPage(
                          currentUserId: 'user_1',
                          isCoach: false,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardBgLight,
                      borderRadius: BorderRadius.circular(uniformBorderRadius),
                      border: Border.all(
                        color: primaryGold.withOpacity(0.3),
                        width: uniformBorderWidth,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.message_outlined,
                      size: 20,
                      color: primaryGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider - même style que FeedPage
          Container(
            height: 1,
            color: const Color(0xFF30363D),
          ),
          const SizedBox(height: 8),
          
          // Contenu du Dashboard directement affiché
          _buildDashboardContent(weekSummary, todaySummary),
        ],
      ),
    );
  }

  /// Contenu du Dashboard (contenu original) - Palette sombre uniforme
  Widget _buildDashboardContent(WeeklyWorkoutSummary weekSummary, NutritionDaySummary todaySummary) {
    final profileNotifier = UserProfileNotifier();
    final profile = profileNotifier.profile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Objectif Principal
        _buildMainGoalSection(profile),
        const SizedBox(height: 20),
        
        // Section Objectifs de la semaine (tags dorés)
        _buildWeeklyGoalsSection(profile),
        const SizedBox(height: 20),
        
        // Widget Progression globale
        _buildWeeklyProgressWidget(weekSummary, todaySummary, profile),
        const SizedBox(height: 24),
        
        Text(
          'Mes Objectifs Personnels',
          style: TextStyle(
            fontSize: 13,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 12),
        // 2 conteneurs côte à côte avec 2 cartes chacun
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conteneur gauche : Objectif séance + Objectif calories
            Expanded(
              child: Column(
                children: [
                  _buildSessionsGoalCard(weekSummary),
                  const SizedBox(height: 16),
                  _buildCaloriesGoalCard(todaySummary),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Conteneur droit : Hydratation + Protéine
            Expanded(
              child: Column(
                children: [
                  _buildHydrationCard(),
                  const SizedBox(height: 16),
                  _buildProteinCard(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Section Activité de la semaine
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: _accentPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Activité de la semaine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textLight,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Nombre de séances par jour (L → D)',
          style: TextStyle(
            fontSize: 13,
            color: _textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildWeekGraph(weekSummary),
        ),
        const SizedBox(height: 32),
        // Section Distance / Pas du jour
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                color: _accentGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Distance / Pas du jour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textLight,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Grand cercle de progression des pas
        _buildStepsCard(),
        const SizedBox(height: 32),
        // Section Sommeil
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bedtime_rounded,
                color: _accentBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Sommeil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textLight,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Sommeil
        _buildSleepCard(),
        const SizedBox(height: 30),
      ],
    );
  }

  /// Section Objectif Principal (affiché en haut du dashboard)
  Widget _buildMainGoalSection(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryGold.withOpacity(0.15),
            _primaryGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getGoalIcon(profile.mainGoal),
              color: _primaryGold,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Objectif principal',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.mainGoal,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textLight,
                  ),
                ),
                if (profile.deadline.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: _primaryGold),
                      const SizedBox(width: 4),
                      Text(
                        'Échéance : ${profile.deadline}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _primaryGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(String goal) {
    final lowerGoal = goal.toLowerCase();
    if (lowerGoal.contains('perte') || lowerGoal.contains('maigrir')) {
      return Icons.trending_down_rounded;
    } else if (lowerGoal.contains('muscle') || lowerGoal.contains('prise')) {
      return Icons.fitness_center;
    } else if (lowerGoal.contains('sécher') || lowerGoal.contains('sec')) {
      return Icons.local_fire_department;
    } else if (lowerGoal.contains('endurance') || lowerGoal.contains('cardio')) {
      return Icons.directions_run;
    } else if (lowerGoal.contains('maintien') || lowerGoal.contains('forme')) {
      return Icons.favorite;
    }
    return Icons.emoji_events;
  }

  /// Section Objectifs de la semaine (grille professionnelle)
  Widget _buildWeeklyGoalsSection(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flag_rounded, color: _primaryGold, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Objectifs de la semaine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grille 2x3 des objectifs hebdomadaires
          Row(
            children: [
              Expanded(child: _buildGoalCard(Icons.fitness_center, 'Séances', '${profile.sessionsPerWeek}', '/sem', _primaryGold)),
              const SizedBox(width: 10),
              Expanded(child: _buildGoalCard(Icons.local_fire_department, 'Calories', '${profile.caloriesGoalPerDay}', 'kcal/j', _primaryOrange)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildGoalCard(Icons.directions_walk, 'Pas', '${profile.stepsGoalPerDay}', '/jour', _primaryGreen)),
              const SizedBox(width: 10),
              Expanded(child: _buildGoalCard(Icons.route, 'Distance', '${profile.distanceGoalPerWeek}', 'km/sem', _primaryBlue)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildGoalCard(Icons.water_drop, 'Hydratation', '${profile.waterGoalLiters}', 'L/jour', _primaryCyan)),
              const SizedBox(width: 10),
              Expanded(child: _buildGoalCard(Icons.bedtime, 'Sommeil', '${profile.sleepGoalHours}', 'h/nuit', _accentPurple)),
            ],
          ),
          // Objectifs secondaires (si présents)
          if (profile.secondaryGoals.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Objectifs secondaires',
              style: TextStyle(
                fontSize: 12,
                color: _textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.secondaryGoals
                  .split('\n')
                  .where((goal) => goal.trim().isNotEmpty)
                  .map((goal) => _buildSecondaryGoalTag(goal.trim()))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard(IconData icon, String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: _textMuted,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 10,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryGoalTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _accentPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentPurple.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _accentPurple,
        ),
      ),
    );
  }

  /// Widget Progression globale de la semaine
  Widget _buildWeeklyProgressWidget(
    WeeklyWorkoutSummary weekSummary,
    NutritionDaySummary todaySummary,
    UserProfile profile,
  ) {
    // Calculer la progression pour chaque objectif
    final sessionsProgress = (weekSummary.sessionsCount / profile.sessionsPerWeek).clamp(0.0, 1.0);
    final stepsProgress = (_stepsNotifier.totalForDate(DateTime.now()) / profile.stepsGoalPerDay).clamp(0.0, 1.0);
    final waterProgress = _goalsNotifier.waterProgressForDate(DateTime.now()).clamp(0.0, 1.0);
    final caloriesProgress = (todaySummary.totalCalories / profile.caloriesGoalPerDay).clamp(0.0, 1.0);
    
    // Calculer la moyenne de progression
    final totalProgress = (sessionsProgress + stepsProgress + waterProgress + caloriesProgress) / 4;
    final progressPercent = (totalProgress * 100).round();
    
    // Compter les objectifs atteints
    int achievedCount = 0;
    if (sessionsProgress >= 1.0) achievedCount++;
    if (stepsProgress >= 1.0) achievedCount++;
    if (waterProgress >= 1.0) achievedCount++;
    if (caloriesProgress >= 1.0) achievedCount++;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentGreen.withOpacity(0.15),
            _accentGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded, color: _accentGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Progression de mes objectifs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor(totalProgress).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$progressPercent%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _getProgressColor(totalProgress),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de progression globale
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalProgress,
              minHeight: 12,
              backgroundColor: _cardBgLight,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(totalProgress)),
            ),
          ),
          const SizedBox(height: 12),
          // Détails des objectifs atteints
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$achievedCount / 4 objectifs atteints',
                style: TextStyle(
                  fontSize: 13,
                  color: _textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  _buildMiniProgressIndicator('🏋️', sessionsProgress),
                  const SizedBox(width: 8),
                  _buildMiniProgressIndicator('👣', stepsProgress),
                  const SizedBox(width: 8),
                  _buildMiniProgressIndicator('💧', waterProgress),
                  const SizedBox(width: 8),
                  _buildMiniProgressIndicator('🔥', caloriesProgress),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return _accentGreen;
    if (progress >= 0.5) return _primaryGold;
    if (progress >= 0.25) return _accentOrange;
    return _accentRed;
  }

  Widget _buildMiniProgressIndicator(String emoji, double progress) {
    final isAchieved = progress >= 1.0;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isAchieved ? _accentGreen.withOpacity(0.2) : _cardBgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAchieved ? _accentGreen : _borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          if (isAchieved) ...[
            const SizedBox(width: 2),
            const Icon(Icons.check, size: 10, color: _accentGreen),
          ],
        ],
      ),
    );
  }

  // Widget pour afficher un repas
  Widget _buildMealTile({
    required BuildContext context,
    required IconData icon,
    required String mealType,
    required MealItem meal,
  }) {
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                  color: _marronPrincipal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
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
                      mealType,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                    const SizedBox(height: 2),
                              Text(
                      meal.title,
                                style: const TextStyle(
                        fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _marronPrincipal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${meal.calories} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _marronPrincipal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
          const Text(
            'Ingrédients :',
            style: TextStyle(
                          fontSize: 13,
              fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: meal.ingredients.map((ingredient) {
              return InkWell(
                onTap: () => _showIngredientCalculatorDialog(context, ingredient),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _marronPrincipal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ingredient,
                        style: TextStyle(
                          fontSize: 12,
                          color: _marronFonce,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.add_circle_outline,
                        size: 14,
                        color: _marronPrincipal,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix : ${_formatPrice(meal.price)} €',
                      style: TextStyle(
                  fontSize: 14,
                        fontWeight: FontWeight.w600,
                  color: _marronPrincipal,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _addToCalculator(meal.calories.toDouble(), meal.price);
                },
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text(
                  'Envoyer à la calculatrice',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: _marronPrincipal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Ajouter une valeur à la calculatrice (appelé depuis les boutons)
  void _addToCalculator(double calories, double price) {
    setState(() {
      _calculatorCalories += calories;
      _calculatorPrice += price;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          calories > 0
              ? '$calories kcal ajoutés'
              : price > 0
                  ? '${_formatPrice(price)} € ajoutés'
                  : 'Valeur ajoutée',
        ),
        backgroundColor: _marronPrincipal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Réinitialiser les totaux de la calculatrice
  void _resetCalculator() {
    setState(() {
      _calculatorCalories = 0.0;
      _calculatorPrice = 0.0;
    });
  }

  // Afficher le dialogue pour ajouter un ingrédient à la calculatrice
  void _showIngredientCalculatorDialog(BuildContext context, String ingredientName) {
    final quantityController = TextEditingController();
    final caloriesController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ajouter $ingredientName à la calculatrice',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantité (g)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: caloriesController,
                  decoration: InputDecoration(
                    labelText: 'Calories',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Prix (€)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
            ),
                        const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final quantity = double.tryParse(quantityController.text) ?? 0.0;
                      final calories = double.tryParse(caloriesController.text) ?? 0.0;
                      final price = double.tryParse(priceController.text) ?? 0.0;
                      if (quantity > 0 || calories > 0 || price > 0) {
                        _addToCalculator(calories, price);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _marronPrincipal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ajouter'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      quantityController.dispose();
      caloriesController.dispose();
      priceController.dispose();
    });
  }

  // Afficher le dialogue pour ajouter des courses
  void _showAddGroceryDialog(BuildContext context) {
    final itemController = TextEditingController();
    String selectedCategory = '🥬 Légumes';

    final categories = [
      '🥬 Légumes',
      '🍎 Fruits',
      '🥩 Protéines',
      '🥛 Produits laitiers / végétaux',
      '🍞 Féculents',
      '🍫 Divers',
      '🧂 Condiments',
      '🌿 Herbes',
      '🥤 Boissons',
      '🧊 Surgelés',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return WillPopScope(
            onWillPop: () async {
              itemController.dispose();
              return true;
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        const Text(
                        'Ajouter des courses',
                          style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
            ),
            const SizedBox(height: 24),
                  const Text(
                    'Catégorie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _marronPrincipal.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Article à ajouter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: itemController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Carottes, Pommes, Thon...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _marronPrincipal.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _marronPrincipal, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                    onPressed: () {
                        if (itemController.text.trim().isNotEmpty) {
                          final item = itemController.text.trim();
                          // Trouver ou créer la catégorie
                          final existingCategoryIndex = _customGroceryList.indexWhere(
                            (cat) => cat.title == selectedCategory,
                          );

                          if (existingCategoryIndex >= 0) {
                            // Ajouter à la catégorie existante
                            final existingItems = List<String>.from(
                              _customGroceryList[existingCategoryIndex].items,
                            );
                            if (!existingItems.contains(item)) {
                              existingItems.add(item);
                              _customGroceryList[existingCategoryIndex] = GroceryCategory(
                                title: selectedCategory,
                                items: existingItems,
                              );
                            }
                          } else {
                            // Créer une nouvelle catégorie
                            _customGroceryList.add(GroceryCategory(
                              title: selectedCategory,
                              items: [item],
                            ));
                          }

                          itemController.dispose();
                          setState(() {});
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$item ajouté à la liste de courses'),
                              backgroundColor: _marronPrincipal,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _marronPrincipal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                      ),
                        elevation: 0,
                    ),
                      child: const Text(
                        'Ajouter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                  ),
                ),
            ),
                  ),
                  const SizedBox(height: 16),
          ],
        ),
      ),
    );
        },
      ),
    ).then((_) {
      itemController.dispose();
    });
  }

  // Afficher le dialogue pour ajouter un article de courses à la calculatrice
  void _showGroceryItemCalculatorDialog(BuildContext context, String itemName) {
    _showIngredientCalculatorDialog(context, itemName);
  }

  // Méthodes de build pour les cartes d'objectifs
  static const Color _violetPrincipal = Color(0xFF9C27B0);
  static const Color _marronPrincipal = Color(0xFF8D6E63);
  static const Color _marronFonce = Color(0xFF5D4037);

  Widget _buildSessionsGoalCard(WeeklyWorkoutSummary weekSummary) {
    final sessionsCount = weekSummary.sessionsCount;
    final progress = (sessionsCount / _targetSessionsPerWeek).clamp(0.0, 1.0);
    final isComplete = progress >= 1.0;

    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SessionsGoalPage()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 145,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _accentPurple.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.fitness_center, color: _accentPurple, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Séances',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textLight,
                      ),
                    ),
                  ),
                  if (isComplete)
                    const Icon(Icons.check_circle, color: _accentGreen, size: 20),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$sessionsCount',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _accentPurple,
                    ),
                  ),
                  Text(
                    ' / $_targetSessionsPerWeek',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: _cardBgLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? _accentGreen : _accentPurple,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesGoalCard(NutritionDaySummary todaySummary) {
    final calories = todaySummary.totalCalories;
    final progress = (calories / _targetCaloriesPerDay).clamp(0.0, 1.0);
    final isGood = calories >= 1600 && calories <= 2400;

    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CaloriesGoalPage()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 145,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _accentOrange.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_fire_department, color: _accentOrange, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Calories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textLight,
                      ),
                    ),
                  ),
                  if (isGood)
                    const Icon(Icons.check_circle, color: _accentGreen, size: 20),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$calories',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _accentOrange,
                    ),
                  ),
                  Text(
                    ' / $_targetCaloriesPerDay',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: _cardBgLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isGood ? _accentGreen : _accentOrange,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHydrationCard() {
    return Builder(
      builder: (context) {
        final today = DateTime.now();
        final waterProgress = _goalsNotifier.waterProgressForDate(today).clamp(0.0, 1.0);
        final waterMl = _goalsNotifier.totalWaterForDate(today);
        final waterLiters = waterMl / 1000.0;
        final waterGoal = _goalsNotifier.waterGoalLiters;
        final isComplete = waterProgress >= 1.0;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HydrationGoalPage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 145,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _accentBlue.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accentBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.water_drop, color: _accentBlue, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hydratation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textLight,
                        ),
                      ),
                    ),
                    if (isComplete)
                      const Icon(Icons.check_circle, color: _accentGreen, size: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      waterLiters.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _accentBlue,
                      ),
                    ),
                    Text(
                      ' / ${waterGoal.toStringAsFixed(1)} L',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: waterProgress,
                    backgroundColor: _cardBgLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? _accentGreen : _accentBlue,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProteinCard() {
    return Builder(
      builder: (context) {
        final today = DateTime.now();
        final proteinProgress = _goalsNotifier.proteinProgressForDate(today).clamp(0.0, 1.0);
        final proteinGrams = _goalsNotifier.totalProteinForDate(today);
        final proteinGoal = _goalsNotifier.proteinGoalGrams;
        final isComplete = proteinProgress >= 1.0;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProteinGoalPage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 145,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _primaryGold.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant, color: _primaryGold, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Protéines',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textLight,
                        ),
                      ),
                    ),
                    if (isComplete)
                      const Icon(Icons.check_circle, color: _accentGreen, size: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${proteinGrams.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _primaryGold,
                      ),
                    ),
                    Text(
                      ' / $proteinGoal g',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: proteinProgress,
                    backgroundColor: _cardBgLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? _accentGreen : _primaryGold,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekGraph(WeeklyWorkoutSummary weekSummary) {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final weekday = index + 1;
        final count = weekSummary.sessionsPerWeekday[weekday] ?? 0;
        final maxCount = weekSummary.sessionsPerWeekday.values.isNotEmpty
            ? weekSummary.sessionsPerWeekday.values.reduce((a, b) => a > b ? a : b)
            : 1;
        final barHeight = maxCount > 0
            ? (12.0 + (count / maxCount * 48.0)).clamp(12.0, 60.0)
            : 12.0;
        final isToday = today.weekday == weekday;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: barHeight,
              decoration: BoxDecoration(
                color: count > 0 ? _accentPurple : _cardBgLight,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: _primaryGold, width: 2)
                    : null,
              ),
              child: count > 0
                  ? Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isToday ? _primaryGold.withOpacity(0.2) : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                days[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isToday
                      ? _primaryGold
                      : count > 0
                          ? _textLight
                          : _textMuted,
                  fontWeight: isToday || count > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepsCard() {
    return Builder(
      builder: (context) {
        final today = DateTime.now();
        final currentSteps = _stepsNotifier.totalForDate(today);
        final progress = (currentSteps / _stepsGoal).clamp(0.0, 1.0);
        final isComplete = progress >= 1.0;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StepsGoalPage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _accentGreen.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accentGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.directions_walk, color: _accentGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currentSteps.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]} ',
                            ),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _accentGreen,
                            ),
                          ),
                          Text(
                            ' / $_stepsGoal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: _cardBgLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(_accentGreen),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: _accentGreen, size: 24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepCard() {
    return Builder(
      builder: (context) {
        final lastSleep = _goalsNotifier.lastSleepEntry();
        final sleepGoal = _goalsNotifier.sleepGoalHours;
        final progress = lastSleep != null
            ? (lastSleep.durationMinutes / (sleepGoal * 60)).clamp(0.0, 1.0)
            : 0.0;
        final isGoodSleep = progress >= 0.9 && progress <= 1.1;

        String durationText;
        if (lastSleep != null) {
          final hours = (lastSleep.durationMinutes / 60).floor();
          final mins = lastSleep.durationMinutes % 60;
          durationText = '${hours}h${mins.toString().padLeft(2, '0')}';
        } else {
          durationText = '—';
        }

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SleepGoalPage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _accentBlue.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bedtime, color: _accentBlue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            durationText,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _accentBlue,
                            ),
                          ),
                          if (lastSleep != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Objectif: ${sleepGoal.toStringAsFixed(0)}h',
                              style: TextStyle(
                                fontSize: 12,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastSleep != null ? 'Dernière nuit' : 'Aucune donnée',
                        style: TextStyle(
                          fontSize: 13,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (lastSleep != null && isGoodSleep)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: _accentGreen, size: 24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _LastMealsList extends StatelessWidget {
  final List<MealEntry> meals;

  const _LastMealsList({required this.meals});

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return const Text(
        'Aucun repas ajouté pour aujourd\'hui.',
        style: TextStyle(
          fontSize: 13,
          color: Colors.black54,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Trier les repas par ID (ordre d'ajout) et prendre les 3 derniers
    final sortedMeals = List<MealEntry>.from(meals);
    sortedMeals.sort((a, b) => b.id.compareTo(a.id)); // Plus récent en premier
    final lastMeals = sortedMeals.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lastMeals.map((meal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _marronPrincipal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${meal.type.displayName} : ${meal.title} – ${meal.calories} kcal',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFC300),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextWorkoutCard extends StatelessWidget {
  const _NextWorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _marronPrincipal,
            _marronFonce,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _violetPrincipal.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFC300),
                  Color(0xFFFFD700),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC300).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Colors.black87,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full body – Niveau intermédiaire',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFFFFC300),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Aujourd\'hui • 18h30 – 45 minutes',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFFFC300),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
