import 'package:flutter/material.dart';
import '../models/goals.dart';
import '../models/nutrition.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

class ProteinGoalPage extends StatefulWidget {
  const ProteinGoalPage({super.key});

  @override
  State<ProteinGoalPage> createState() => _ProteinGoalPageState();
}

class _ProteinGoalPageState extends State<ProteinGoalPage> {
  final _goalsNotifier = DailyGoalsNotifier();
  final _nutritionNotifier = NutritionNotifier();

  @override
  void initState() {
    super.initState();
    _goalsNotifier.addListener(_onDataChanged);
    _nutritionNotifier.addListener(_onDataChanged);
    // AlterEgoPageDetector.setupPageContext(UkanPage.objectifProteines);
  }

  @override
  void dispose() {
    _goalsNotifier.removeListener(_onDataChanged);
    _nutritionNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  List<bool?> _getWeeklyStatus() {
    final now = DateTime.now();
    final goal = _goalsNotifier.proteinGoalGrams;
    final proteinData = _goalsNotifier.proteinTotalsForLast7Days();
    
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final protein = proteinData[dateOnly] ?? 0;
      if (protein == 0) return null;
      return protein >= goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final proteinGrams = _goalsNotifier.totalProteinForDate(today).toDouble();
    final proteinGoal = _goalsNotifier.proteinGoalGrams;
    final progress = proteinGoal > 0 ? (proteinGrams / proteinGoal).clamp(0.0, 1.0) : 0.0;
    final remaining = (proteinGoal.toDouble() - proteinGrams).clamp(0.0, proteinGoal.toDouble());
    final weeklyStatus = _getWeeklyStatus();
    
    final todaySummary = _nutritionNotifier.summaryForDate(today);

    String status;
    Color statusColor;
    if (proteinGrams == 0) {
      status = 'Aucune protéine enregistrée';
      statusColor = Colors.white54;
    } else if (progress >= 1.0) {
      status = 'Objectif atteint ! 💪';
      statusColor = Colors.green;
    } else if (progress >= 0.7) {
      status = 'Tu y es presque !';
      statusColor = const Color(0xFFFF9800);
    } else {
      status = 'Continue tes efforts';
      statusColor = const Color(0xFFFF9800);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte principale
                  _buildMainCard(
                    proteinGrams: proteinGrams,
                    proteinGoal: proteinGoal,
                    progress: progress,
                    remaining: remaining,
                    status: status,
                    statusColor: statusColor,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tableau semaine
                  _buildWeeklyTable(weeklyStatus),
                  
                  const SizedBox(height: 20),
                  
                  // Répartition par repas
                  _buildMealBreakdown(todaySummary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Objectif Protéines',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Suivi quotidien',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard({
    required double proteinGrams,
    required int proteinGoal,
    required double progress,
    required double remaining,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withOpacity(0.15),
            const Color(0xFFFF5722).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Valeur principale
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${proteinGrams.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '/ $proteinGoal g',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : const Color(0xFFFF9800),
              ),
              minHeight: 10,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Consommées',
                  value: '${proteinGrams.toStringAsFixed(0)} g',
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Restantes',
                  value: '${remaining.toStringAsFixed(0)} g',
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  progress >= 1.0 ? Icons.check_circle : Icons.info_outline,
                  color: statusColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTable(List<bool?> statuses) {
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final now = DateTime.now();
    
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
              Icon(Icons.calendar_view_week, color: const Color(0xFFFF9800), size: 20),
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
          Row(
            children: List.generate(7, (i) {
              final date = now.subtract(Duration(days: now.weekday - 1 - i));
              final isToday = date.day == now.day && date.month == now.month;
              final status = i < statuses.length ? statuses[i] : null;
              
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dayNames[i],
                      style: TextStyle(
                        color: isToday ? const Color(0xFFFF9800) : Colors.white60,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? const Color(0xFFFF9800) : Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
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
                                  fontSize: 14,
                                ),
                              )
                            : Icon(
                                status ? Icons.check : Icons.close,
                                size: 18,
                                color: status ? Colors.green : Colors.red,
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMealBreakdown(NutritionDaySummary todaySummary) {
    final mealsByType = <MealType, int>{
      MealType.breakfast: 0,
      MealType.lunch: 0,
      MealType.snack: 0,
      MealType.dinner: 0,
    };
    
    for (final meal in todaySummary.meals) {
      mealsByType[meal.type] = (mealsByType[meal.type] ?? 0) + meal.protein;
    }

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
              Icon(Icons.pie_chart_outline, color: const Color(0xFFFF9800), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Répartition par repas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMealRow(Icons.wb_sunny, 'Petit-déjeuner', mealsByType[MealType.breakfast] ?? 0),
          _buildMealRow(Icons.lunch_dining, 'Déjeuner', mealsByType[MealType.lunch] ?? 0),
          _buildMealRow(Icons.cookie, 'Collation', mealsByType[MealType.snack] ?? 0),
          _buildMealRow(Icons.dinner_dining, 'Dîner', mealsByType[MealType.dinner] ?? 0),
        ],
      ),
    );
  }

  Widget _buildMealRow(IconData icon, String label, int protein) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFF9800), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: protein > 0 
                  ? const Color(0xFFFF9800).withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$protein g',
              style: TextStyle(
                color: protein > 0 ? const Color(0xFFFF9800) : Colors.white.withOpacity(0.4),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

