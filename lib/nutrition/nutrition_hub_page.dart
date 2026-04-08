import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../features/nutrition/repas_courses_page.dart';
import '../features/nutrition/meal_planner_page.dart';
import '../features/nutrition/calculator/numeric_calculator_page.dart';
import '../features/nutrition/calculator/calculator_page.dart';
import '../features/nutrition/food_icons_library_page.dart';
import '../foodscan_ia/foodscan_home_page.dart';
import '../foodscan_ia/foodscan_photo_demo_page.dart';
import '../foodscan_ia/foodscan_voice_demo_page.dart';
import '../add_meal_page.dart';
import '../models/nutrition.dart';
import 'recipes_feed_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// NUTRITION HUB™ - Page d'accueil immersive Nutrition
/// Point d'entrée vers tout l'univers Nutrition de Ukan
/// ═══════════════════════════════════════════════════════════════════════════

// Palette de couleurs Nutrition - Noir & Or sobre
const Color _primaryGreen = Color(0xFF4ECDC4); // Vert-cyan plus doux
const Color _secondaryGreen = Color(0xFF3DB9B1);
const Color _accentOrange = Color(0xFFE8A838); // Orange doré plus sobre
const Color _accentYellow = Color(0xFFFFC300); // Or principal
const Color _premiumGold = Color(0xFFFFC300);
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

class NutritionHubPage extends StatefulWidget {
  const NutritionHubPage({super.key});

  @override
  State<NutritionHubPage> createState() => _NutritionHubPageState();
}

class _NutritionHubPageState extends State<NutritionHubPage> with TickerProviderStateMixin {
  final _nutritionNotifier = NutritionNotifier();
  
  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Demo data
  int _freeScansRemaining = 3;
  int _streakDays = 5;
  
  // Objectifs (démo)
  static const int _goalCalories = 2200;
  static const int _goalProtein = 120;
  static const int _goalCarbs = 250;
  static const int _goalFat = 70;

  @override
  void initState() {
    super.initState();
    _nutritionNotifier.addListener(_onDataChanged);
    _initAnimations();
  }

  void _initAnimations() {
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Float animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nutritionNotifier.removeListener(_onDataChanged);
    _pulseController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final summary = _nutritionNotifier.summaryForDate(today);
    
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Background
          _buildBackground(),
          
          // Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                _buildSliverAppBar(),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FoodScan Hero Section
                        _buildFoodScanHero(),
                        const SizedBox(height: 24),
                        
                        // Today's Summary
                        _buildTodaySummary(summary),
                        const SizedBox(height: 24),
                        
                        // Quick Access Grid
                        _buildQuickAccessSection(),
                        const SizedBox(height: 24),
                        
                        // Daily Tip
                        _buildDailyTip(summary),
                        const SizedBox(height: 24),
                        
                        // Streaks & Goals
                        _buildStreaksSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _primaryGreen.withOpacity(0.1),
                _darkBg,
                _darkBg,
              ],
            ),
          ),
        ),
        
        // Floating particles
        ...List.generate(20, (index) {
          final random = math.Random(index);
          return AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Positioned(
                left: random.nextDouble() * MediaQuery.of(context).size.width,
                top: random.nextDouble() * MediaQuery.of(context).size.height * 0.5 +
                     _floatAnimation.value * (random.nextBool() ? 1 : -1),
                child: Container(
                  width: 4 + random.nextDouble() * 6,
                  height: 4 + random.nextDouble() * 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: [_primaryGreen, _accentOrange, _accentYellow][random.nextInt(3)]
                        .withOpacity(0.2 * random.nextDouble()),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _cardBg.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_primaryGreen, _secondaryGreen]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Nutrition',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardBg.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFoodScanHero() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _premiumGold.withOpacity(0.2),
                  _accentOrange.withOpacity(0.1),
                  _cardBg,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _premiumGold.withOpacity(_glowAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _premiumGold.withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_premiumGold, _accentOrange],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _premiumGold.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [_premiumGold, _accentOrange],
                                ).createShader(bounds),
                                child: const Text(
                                  'FoodScan IA™',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _premiumGold,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Analyse nutritionnelle instantanée par IA',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Features buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildFoodScanFeatureButton(
                        icon: Icons.camera_alt,
                        label: 'Photo',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FoodScanPhotoDemoPage()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFoodScanFeatureButton(
                        icon: Icons.mic,
                        label: 'Voix',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FoodScanVoiceDemoPage()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFoodScanFeatureButton(
                        icon: Icons.analytics,
                        label: 'Analyse',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FoodScanHomePage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // CTA Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _showFoodScanTrialDialog();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_premiumGold, _accentOrange],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _premiumGold.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          _freeScansRemaining > 0
                              ? 'ESSAYER GRATUITEMENT ($_freeScansRemaining scans)'
                              : 'S\'ABONNER POUR ILLIMITÉ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodScanFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _darkBg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _premiumGold.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _premiumGold, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(NutritionDaySummary summary) {
    final caloriesProgress = (summary.totalCalories / _goalCalories).clamp(0.0, 1.0);
    final proteinProgress = (summary.totalProtein / _goalProtein).clamp(0.0, 1.0);
    final carbsProgress = (summary.totalCarbs / _goalCarbs).clamp(0.0, 1.0);
    final fatProgress = (summary.totalFats / _goalFat).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_cardBg, _cardBgLight]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.today, color: _primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Aujourd\'hui',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AddMealPage(date: DateTime.now())),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.add, color: _primaryGreen, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Ajouter',
                      style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Calories ring
          Row(
            children: [
              // Progress ring
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: caloriesProgress,
                        strokeWidth: 8,
                        backgroundColor: _darkBg,
                        valueColor: AlwaysStoppedAnimation(
                          caloriesProgress >= 1.0 ? _primaryGreen : _accentOrange,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(caloriesProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              
              // Calories text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${summary.totalCalories} / $_goalCalories',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'calories',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Macros row
          Row(
            children: [
              Expanded(
                child: _buildMacroChip(
                  emoji: '🥩',
                  label: 'Prot.',
                  value: '${summary.totalProtein}g',
                  progress: proteinProgress,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroChip(
                  emoji: '🍞',
                  label: 'Gluc.',
                  value: '${summary.totalCarbs}g',
                  progress: carbsProgress,
                  color: Colors.amber.shade400,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroChip(
                  emoji: '🥑',
                  label: 'Lip.',
                  value: '${summary.totalFats}g',
                  progress: fatProgress,
                  color: Colors.green.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip({
    required String emoji,
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _darkBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: _darkBg,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    // Palette sombre uniforme (noir/doré)
    const Color cardBgDark = Color(0xFF161B22);
    const Color goldAccent = Color(0xFFFFC300);
    const Color borderDark = Color(0xFF30363D);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant_menu, color: goldAccent, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Accès rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // First row
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.restaurant_menu,
                title: 'Repas & Courses',
                subtitle: '2.0',
                iconColor: goldAccent,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RepasCoursesPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.calendar_month,
                title: 'Planning',
                subtitle: 'Semaine',
                iconColor: goldAccent,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MealPlannerPage()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Second row
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.shopping_cart,
                title: 'Liste',
                subtitle: 'Courses',
                iconColor: goldAccent,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RepasCoursesPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.calculate,
                title: 'Calculatrice',
                subtitle: 'Nutrition',
                iconColor: goldAccent,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NumericCalculatorPage()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Third row
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.auto_graph,
                title: 'Simulateur',
                subtitle: 'Semaine',
                iconColor: goldAccent,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NutritionSimulatorPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.add_circle,
                title: 'Ajouter',
                subtitle: 'Repas',
                iconColor: goldAccent,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AddMealPage(date: DateTime.now())),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Fourth row - Recettes & Fil + Bibliothèque Icônes
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.explore,
                title: 'Recettes & Fil',
                subtitle: 'Explorer',
                iconColor: const Color(0xFFFF9F43), // Orange
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RecipesFeedPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.emoji_food_beverage,
                title: 'Bibliothèque',
                subtitle: 'Icônes',
                iconColor: const Color(0xFF4ECDC4), // Vert-cyan
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FoodIconsLibraryPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    // Palette sombre uniforme
    const Color cardBgDark = Color(0xFF161B22);
    const Color borderDark = Color(0xFF30363D);
    const Color goldAccent = Color(0xFFFFC300);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderDark, width: 1.5),
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B949E), // textMuted
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTip(NutritionDaySummary summary) {
    // Generate tip based on data
    String tip;
    String emoji;
    
    final proteinProgress = summary.totalProtein / _goalProtein;
    final caloriesProgress = summary.totalCalories / _goalCalories;
    
    if (proteinProgress >= 0.8) {
      tip = 'Excellent ! Tu as atteint ${(proteinProgress * 100).toInt()}% de tes protéines aujourd\'hui. Continue comme ça ! 💪';
      emoji = '🎯';
    } else if (caloriesProgress < 0.3 && DateTime.now().hour > 12) {
      tip = 'N\'oublie pas de manger ! Tu n\'as consommé que ${(caloriesProgress * 100).toInt()}% de tes calories.';
      emoji = '⚠️';
    } else if (summary.meals.isEmpty) {
      tip = 'Commence ta journée en ajoutant ton premier repas ! Utilise FoodScan pour une analyse rapide.';
      emoji = '🌅';
    } else {
      tip = 'Pense à varier tes sources de protéines et à inclure des légumes à chaque repas.';
      emoji = '💡';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _premiumGold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _premiumGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conseil du jour',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _premiumGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
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
                  color: _premiumGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department, color: _premiumGold, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Objectifs & Streaks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Streak counter - Style sobre noir/or
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _premiumGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _premiumGold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: _premiumGold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '$_streakDays jours',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _premiumGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'consécutifs avec objectif atteint !',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Weekly progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progression semaine',
                    style: TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                    ),
                  ),
                  Text(
                    '75%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 8,
                  backgroundColor: _cardBgLight,
                  valueColor: AlwaysStoppedAnimation(_primaryGreen.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Days of week - Style sobre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final isCompleted = index < 5;
              final isToday = index == 5;
              
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? _primaryGreen.withOpacity(0.8)
                      : (isToday ? _premiumGold.withOpacity(0.15) : _cardBgLight),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted 
                        ? _primaryGreen.withOpacity(0.5)
                        : (isToday ? _premiumGold.withOpacity(0.5) : _borderColor),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: _darkBg, size: 18)
                      : Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isToday ? _premiumGold : _textMuted,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showFoodScanTrialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_premiumGold, _accentOrange]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'FoodScan IA™',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_freeScansRemaining > 0) ...[
              Text(
                'Tu as $_freeScansRemaining scans gratuits restants !',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
              ),
              const SizedBox(height: 16),
              _buildTrialFeature('📸 Scan photo d\'assiette'),
              _buildTrialFeature('🎤 Analyse vocale'),
              _buildTrialFeature('📊 Rapport nutritionnel complet'),
              _buildTrialFeature('🤖 Suggestions IA personnalisées'),
            ] else ...[
              Text(
                'Tu as utilisé tous tes scans gratuits.',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
              ),
              const SizedBox(height: 16),
              Text(
                'Passe à Premium pour des scans illimités !',
                style: TextStyle(color: _premiumGold, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Plus tard',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_freeScansRemaining > 0) {
                setState(() => _freeScansRemaining--);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FoodScanHomePage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité Premium - Abonnement requis'),
                    backgroundColor: _premiumGold,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _premiumGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_freeScansRemaining > 0 ? 'Essayer maintenant' : 'S\'abonner'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: _primaryGreen, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}


