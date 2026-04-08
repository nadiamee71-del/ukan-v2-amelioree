import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'models/workout_history.dart';
import 'models/nutrition.dart';
import 'models/user_profile.dart';
import 'models/goals.dart';
import 'models/steps.dart';
import 'add_sleep_page.dart';
import 'add_steps_page.dart';
import 'alter_ego_floating/alter_ego_page_detector.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with SingleTickerProviderStateMixin {
  static const int _targetCaloriesPerDay = 2000;
  static const int _stepsGoal = 8000;

  final _historyNotifier = WorkoutHistoryNotifier();
  final _nutritionNotifier = NutritionNotifier();
  final _profileNotifier = UserProfileNotifier();
  final _goalsNotifier = DailyGoalsNotifier();
  final _stepsNotifier = StepsNotifier();
  
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
    _historyNotifier.addListener(_onDataChanged);
    _nutritionNotifier.addListener(_onDataChanged);
    _profileNotifier.addListener(_onDataChanged);
    _goalsNotifier.addListener(_onDataChanged);
    _stepsNotifier.addListener(_onDataChanged);
    AlterEgoPageDetector.setupPageContext(UkanPage.statistiques);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _historyNotifier.removeListener(_onDataChanged);
    _nutritionNotifier.removeListener(_onDataChanged);
    _profileNotifier.removeListener(_onDataChanged);
    _goalsNotifier.removeListener(_onDataChanged);
    _stepsNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Onglets
          _buildTabBar(),
          
          // Contenu
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCaloriesTab(),
                _buildHydrationTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final goalsAchieved = _calculateWeeklyGoalsAchieved();
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mes Statistiques',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Semaine du ${_getWeekRange()}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Objectif principal
            _buildMainGoalCard(),
            const SizedBox(height: 12),
            // Résumé objectifs semaine
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFC300).withOpacity(0.15),
                    const Color(0xFFFF8C00).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFC300).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC300), Color(0xFFFF9500)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Objectifs atteints cette semaine',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${goalsAchieved.achieved} / ${goalsAchieved.total}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCircularProgress(
                    goalsAchieved.total > 0
                        ? goalsAchieved.achieved / goalsAchieved.total
                        : 0.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(double progress) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.8
                    ? Colors.green
                    : progress >= 0.5
                        ? const Color(0xFFFFC300)
                        : Colors.orange,
              ),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainGoalCard() {
    final profile = _profileNotifier.profile;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(0.15),
            const Color(0xFF4ECDC4).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getGoalIcon(profile.mainGoal),
              color: const Color(0xFF4ECDC4),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mon objectif principal',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.mainGoal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (profile.deadline.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 10, color: Color(0xFFFFC300)),
                  const SizedBox(width: 4),
                  Text(
                    profile.deadline,
                    style: const TextStyle(
                      color: Color(0xFFFFC300),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC300), Color(0xFFFF9500)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Vue\nglobale', height: 50),
          Tab(text: 'Calories', height: 50),
          Tab(text: 'Hydratation', height: 50),
          Tab(text: 'Activité', height: 50),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET VUE GLOBALE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tableau jour par jour
          _buildWeeklyTable(),
          
          const SizedBox(height: 24),
          
          // Courbe d'évolution globale
          _buildEvolutionChart(),
          
          const SizedBox(height: 24),
          
          // Résumé par catégorie
          _buildCategorySummary(),
        ],
      ),
    );
  }

  Widget _buildWeeklyTable() {
    final now = DateTime.now();
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E2E),
            const Color(0xFF161622),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_week, color: const Color(0xFFFFC300), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Objectifs de la semaine',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // En-têtes
          Row(
            children: [
              const SizedBox(width: 40),
              ...List.generate(7, (i) {
                final date = now.subtract(Duration(days: now.weekday - 1 - i));
                final isToday = date.day == now.day && date.month == now.month;
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        dayNames[i],
                        style: TextStyle(
                          color: isToday ? const Color(0xFFFFC300) : Colors.white60,
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isToday ? const Color(0xFFFFC300) : Colors.white.withOpacity(0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Lignes par objectif
          _buildObjectiveRow('🔥', 'Calories', _getCaloriesStatus()),
          _buildObjectiveRow('💧', 'Hydratation', _getHydrationStatus()),
          _buildObjectiveRow('🏃', 'Pas', _getStepsStatus()),
          _buildObjectiveRow('🥩', 'Protéines', _getProteinStatus()),
          _buildObjectiveRow('😴', 'Sommeil', _getSleepStatus()),
          _buildObjectiveRow('💪', 'Séances', _getWorkoutStatus()),
        ],
      ),
    );
  }

  Widget _buildObjectiveRow(String emoji, String label, List<bool?> statuses) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
              ],
            ),
          ),
          ...List.generate(7, (i) {
            final status = i < statuses.length ? statuses[i] : null;
            return Expanded(
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: status == null
                        ? Colors.white.withOpacity(0.05)
                        : status
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: status == null
                          ? Colors.white.withOpacity(0.1)
                          : status
                              ? Colors.green.withOpacity(0.5)
                              : Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Center(
                    child: status == null
                        ? Text(
                            '—',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          )
                        : Icon(
                            status ? Icons.check : Icons.close,
                            size: 16,
                            color: status ? Colors.green : Colors.red,
                          ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEvolutionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E2E),
            const Color(0xFF161622),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: const Color(0xFFFFC300), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Évolution de la semaine',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _WeeklyChartPainter(
                caloriesData: _getCaloriesData(),
                hydrationData: _getHydrationData(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Calories', Colors.orange),
              const SizedBox(width: 24),
              _buildLegendItem('Hydratation', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySummary() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard(
              '🔥',
              'Calories',
              _calculateWeeklyCaloriesAverage(),
              'kcal/jour',
              _targetCaloriesPerDay.toDouble(),
              Colors.orange,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(
              '💧',
              'Hydratation',
              _calculateWeeklyHydrationAverage(),
              'L/jour',
              _goalsNotifier.waterGoalLiters,
              Colors.blue,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard(
              '🏃',
              'Pas',
              _calculateWeeklyStepsAverage(),
              'pas/jour',
              _stepsGoal.toDouble(),
              Colors.green,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(
              '😴',
              'Sommeil',
              _calculateWeeklySleepAverage(),
              'h/nuit',
              _goalsNotifier.sleepGoalHours,
              Colors.purple,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String emoji,
    String title,
    double value,
    String unit,
    double goal,
    Color color,
  ) {
    final progress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;
    final achieved = value >= goal * 0.8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              if (achieved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 12),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} $unit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET CALORIES
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCaloriesTab() {
    final now = DateTime.now();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          // Graphique calories
          _buildDetailChart(
            'Calories consommées',
            Icons.local_fire_department,
            Colors.orange,
            _getCaloriesData(),
            _targetCaloriesPerDay.toDouble(),
            'kcal',
          ),
          
          const SizedBox(height: 20),
          
          // Détails jour par jour
          ...List.generate(7, (i) {
            final date = now.subtract(Duration(days: 6 - i));
            final summary = _nutritionNotifier.summaryForDate(date);
            final calories = summary.totalCalories.toDouble();
            final achieved = calories >= _targetCaloriesPerDay * 0.8 && 
                            calories <= _targetCaloriesPerDay * 1.2;
            
            return _buildDayDetailCard(
              date,
              '${calories.round()} kcal',
              achieved,
              calories / _targetCaloriesPerDay,
              Colors.orange,
              subtitle: 'Objectif: $_targetCaloriesPerDay kcal',
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET HYDRATATION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHydrationTab() {
    final now = DateTime.now();
    final waterData = _goalsNotifier.waterTotalsForLast7Days();
    final waterGoalLiters = _goalsNotifier.waterGoalLiters;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          // Graphique hydratation
          _buildDetailChart(
            'Hydratation',
            Icons.water_drop,
            Colors.blue,
            _getHydrationData(),
            waterGoalLiters,
            'L',
          ),
          
          const SizedBox(height: 20),
          
          // Détails jour par jour
          ...List.generate(7, (i) {
            final date = now.subtract(Duration(days: 6 - i));
            final dateOnly = DateTime(date.year, date.month, date.day);
            final totalMl = waterData[dateOnly] ?? 0;
            final liters = totalMl / 1000.0;
            final achieved = liters >= waterGoalLiters;
            
            return _buildDayDetailCard(
              date,
              '${liters.toStringAsFixed(1)} L',
              achieved,
              liters / waterGoalLiters,
              Colors.blue,
              subtitle: 'Objectif: ${waterGoalLiters.toStringAsFixed(1)} L',
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET ACTIVITÉ
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildActivityTab() {
    final now = DateTime.now();
    final stepsData = _stepsNotifier.totalsForLast7Days();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          // Stats rapides
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  '🏃',
                  'Pas cette semaine',
                  '${_calculateTotalWeeklySteps()}',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  '💪',
                  'Séances',
                  '${_calculateWeeklyWorkouts()}',
                  const Color(0xFFFFC300),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Détails pas jour par jour
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1E2E),
                  const Color(0xFF161622),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_walk, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Pas quotidiens',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddStepsPage()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ajouter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(7, (i) {
                  final date = now.subtract(Duration(days: 6 - i));
                  final dateOnly = DateTime(date.year, date.month, date.day);
                  final steps = stepsData[dateOnly] ?? 0;
                  final achieved = steps >= _stepsGoal;
                  
                  return _buildCompactDayRow(
                    date,
                    '$steps pas',
                    achieved,
                    steps / _stepsGoal,
                    Colors.green,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChart(
    String title,
    IconData icon,
    Color color,
    List<double> data,
    double goal,
    String unit,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E2E),
            const Color(0xFF161622),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _BarChartPainter(
                data: data,
                goal: goal,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Objectif: ${goal.toStringAsFixed(unit == 'L' ? 1 : 0)} $unit',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetailCard(
    DateTime date,
    String value,
    bool achieved,
    double progress,
    Color color, {
    String? subtitle,
  }) {
    final dayNames = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    final isToday = date.day == DateTime.now().day && 
                    date.month == DateTime.now().month;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(achieved ? 0.15 : 0.05),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? const Color(0xFFFFC300)
              : achieved
                  ? Colors.green.withOpacity(0.3)
                  : color.withOpacity(0.2),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Date
          Container(
            width: 50,
            child: Column(
              children: [
                Text(
                  dayNames[date.weekday % 7],
                  style: TextStyle(
                    color: isToday ? const Color(0xFFFFC300) : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isToday ? const Color(0xFFFFC300) : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Barre de progression
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achieved ? Colors.green : color,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Statut
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: achieved
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              achieved ? Icons.check : Icons.close,
              color: achieved ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDayRow(
    DateTime date,
    String value,
    bool achieved,
    double progress,
    Color color,
  ) {
    final dayNames = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    final isToday = date.day == DateTime.now().day && 
                    date.month == DateTime.now().month;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${dayNames[date.weekday % 7]} ${date.day}',
              style: TextStyle(
                color: isToday ? const Color(0xFFFFC300) : Colors.white70,
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  achieved ? Colors.green : color,
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            achieved ? Icons.check_circle : Icons.remove_circle_outline,
            color: achieved ? Colors.green : Colors.white30,
            size: 18,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CALCULS
  // ═══════════════════════════════════════════════════════════════════════════

  String _getWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.day}/${monday.month} - ${sunday.day}/${sunday.month}';
  }

  ({int achieved, int total}) _calculateWeeklyGoalsAchieved() {
    int achieved = 0;
    int total = 0;

    // Calories (7 jours)
    for (final status in _getCaloriesStatus()) {
      if (status != null) {
        total++;
        if (status) achieved++;
      }
    }

    // Hydratation (7 jours)
    for (final status in _getHydrationStatus()) {
      if (status != null) {
        total++;
        if (status) achieved++;
      }
    }

    // Pas (7 jours)
    for (final status in _getStepsStatus()) {
      if (status != null) {
        total++;
        if (status) achieved++;
      }
    }

    return (achieved: achieved, total: total);
  }

  List<bool?> _getCaloriesStatus() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;
      final summary = _nutritionNotifier.summaryForDate(date);
      final calories = summary.totalCalories;
      if (calories == 0) return null;
      return calories >= _targetCaloriesPerDay * 0.8 && 
             calories <= _targetCaloriesPerDay * 1.2;
    });
  }

  List<bool?> _getHydrationStatus() {
    final now = DateTime.now();
    final waterData = _goalsNotifier.waterTotalsForLast7Days();
    final goal = (_goalsNotifier.waterGoalLiters * 1000).round();
    
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final totalMl = waterData[dateOnly] ?? 0;
      if (totalMl == 0) return null;
      return totalMl >= goal;
    });
  }

  List<bool?> _getStepsStatus() {
    final now = DateTime.now();
    final stepsData = _stepsNotifier.totalsForLast7Days();
    
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final steps = stepsData[dateOnly] ?? 0;
      if (steps == 0) return null;
      return steps >= _stepsGoal;
    });
  }

  List<bool?> _getProteinStatus() {
    final now = DateTime.now();
    final proteinData = _goalsNotifier.proteinTotalsForLast7Days();
    final goal = _goalsNotifier.proteinGoalGrams;
    
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final protein = proteinData[dateOnly] ?? 0;
      if (protein == 0) return null;
      return protein >= goal;
    });
  }

  List<bool?> _getSleepStatus() {
    final sleepEntries = _goalsNotifier.sleepEntriesForLast7Days();
    final goal = _goalsNotifier.sleepGoalHours;
    final now = DateTime.now();
    
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;
      
      final entry = sleepEntries.where((e) => 
        e.date.year == date.year && 
        e.date.month == date.month && 
        e.date.day == date.day
      ).firstOrNull;
      
      if (entry == null) return null;
      final hours = entry.durationMinutes / 60.0;
      return (hours - goal).abs() <= 1.0;
    });
  }

  List<bool?> _getWorkoutStatus() {
    final now = DateTime.now();
    final entries = _historyNotifier.allEntries();
    
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;
      
      final hasWorkout = entries.any((e) => 
        e.date.year == date.year && 
        e.date.month == date.month && 
        e.date.day == date.day
      );
      
      return hasWorkout ? true : null;
    });
  }

  List<double> _getCaloriesData() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final summary = _nutritionNotifier.summaryForDate(date);
      return summary.totalCalories.toDouble();
    });
  }

  List<double> _getHydrationData() {
    final now = DateTime.now();
    final waterData = _goalsNotifier.waterTotalsForLast7Days();
    
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      return (waterData[dateOnly] ?? 0) / 1000.0;
    });
  }

  double _calculateWeeklyCaloriesAverage() {
    final data = _getCaloriesData();
    final validData = data.where((v) => v > 0).toList();
    if (validData.isEmpty) return 0;
    return validData.reduce((a, b) => a + b) / validData.length;
  }

  double _calculateWeeklyHydrationAverage() {
    final data = _getHydrationData();
    final validData = data.where((v) => v > 0).toList();
    if (validData.isEmpty) return 0;
    return validData.reduce((a, b) => a + b) / validData.length;
  }

  double _calculateWeeklyStepsAverage() {
    final now = DateTime.now();
    final stepsData = _stepsNotifier.totalsForLast7Days();
    int total = 0;
    int count = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final steps = stepsData[dateOnly] ?? 0;
      if (steps > 0) {
        total += steps;
        count++;
      }
    }
    
    return count > 0 ? total / count : 0;
  }

  double _calculateWeeklySleepAverage() {
    final sleepEntries = _goalsNotifier.sleepEntriesForLast7Days();
    if (sleepEntries.isEmpty) return 0;
    
    final totalMinutes = sleepEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.durationMinutes,
    );
    
    return totalMinutes / 60.0 / sleepEntries.length;
  }

  int _calculateTotalWeeklySteps() {
    final stepsData = _stepsNotifier.totalsForLast7Days();
    return stepsData.values.fold<int>(0, (sum, steps) => sum + steps);
  }

  int _calculateWeeklyWorkouts() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final entries = _historyNotifier.allEntries();
    
    return entries.where((e) => 
      e.date.isAfter(monday.subtract(const Duration(days: 1))) &&
      e.date.isBefore(now.add(const Duration(days: 1)))
    ).length;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAINTERS POUR GRAPHIQUES
// ═══════════════════════════════════════════════════════════════════════════

class _WeeklyChartPainter extends CustomPainter {
  final List<double> caloriesData;
  final List<double> hydrationData;

  _WeeklyChartPainter({
    required this.caloriesData,
    required this.hydrationData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final caloriesPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final hydrationPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Normaliser les données
    final maxCalories = caloriesData.isNotEmpty 
        ? caloriesData.reduce((a, b) => a > b ? a : b)
        : 1.0;
    final maxHydration = hydrationData.isNotEmpty
        ? hydrationData.reduce((a, b) => a > b ? a : b)
        : 1.0;

    // Dessiner les courbes
    _drawCurve(canvas, size, caloriesData, maxCalories > 0 ? maxCalories : 1, caloriesPaint);
    _drawCurve(canvas, size, hydrationData.map((v) => v * 1000).toList(), maxHydration > 0 ? maxHydration * 1000 : 1, hydrationPaint);

    // Dessiner les points
    _drawPoints(canvas, size, caloriesData, maxCalories > 0 ? maxCalories : 1, Colors.orange);
    _drawPoints(canvas, size, hydrationData.map((v) => v * 1000).toList(), maxHydration > 0 ? maxHydration * 1000 : 1, Colors.blue);
  }

  void _drawCurve(Canvas canvas, Size size, List<double> data, double maxValue, Paint paint) {
    if (data.isEmpty) return;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue * size.height * 0.8);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawPoints(Canvas canvas, Size size, List<double> data, double maxValue, Color color) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue * size.height * 0.8);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final double goal;
  final Color color;

  _BarChartPainter({
    required this.data,
    required this.goal,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = data.isNotEmpty 
        ? [data.reduce((a, b) => a > b ? a : b), goal].reduce((a, b) => a > b ? a : b)
        : goal;
    
    final barWidth = (size.width - (data.length - 1) * 8) / data.length;
    final dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    // Dessiner la ligne d'objectif
    final goalY = size.height - 20 - (goal / maxValue * (size.height - 40));
    final goalPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(0, goalY),
      Offset(size.width, goalY),
      goalPaint,
    );

    // Dessiner les barres
    for (int i = 0; i < data.length; i++) {
      final x = i * (barWidth + 8);
      final barHeight = data[i] / maxValue * (size.height - 40);
      final y = size.height - 20 - barHeight;

      final barPaint = Paint()
        ..color = data[i] >= goal ? Colors.green : color
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      // Dessiner le label du jour
      final textPainter = TextPainter(
        text: TextSpan(
          text: dayNames[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
