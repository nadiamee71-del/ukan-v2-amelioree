import 'package:flutter/material.dart';
import '../models/nutrition.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

class CaloriesGoalPage extends StatefulWidget {
  const CaloriesGoalPage({super.key});

  @override
  State<CaloriesGoalPage> createState() => _CaloriesGoalPageState();
}

class _CaloriesGoalPageState extends State<CaloriesGoalPage> {
  final _nutritionNotifier = NutritionNotifier();
  static const int _targetCaloriesPerDay = 2000;

  @override
  void initState() {
    super.initState();
    _nutritionNotifier.addListener(_onDataChanged);
    AlterEgoPageDetector.setupPageContext(UkanPage.objectifCalories);
  }

  @override
  void dispose() {
    _nutritionNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  List<bool?> _getWeeklyStatus() {
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

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todaySummary = _nutritionNotifier.summaryForDate(today);
    final calories = todaySummary.totalCalories;
    final remaining = (_targetCaloriesPerDay - calories).clamp(0, _targetCaloriesPerDay);
    final progress = (calories / _targetCaloriesPerDay).clamp(0.0, 1.0);
    final weeklyStatus = _getWeeklyStatus();

    String status;
    Color statusColor;
    if (calories == 0) {
      status = 'Aucun repas enregistré';
      statusColor = Colors.white54;
    } else if (calories >= 1600 && calories <= 2400) {
      status = 'Dans la bonne zone ! 🎯';
      statusColor = Colors.green;
    } else if (calories < 1600) {
      status = 'En dessous de l\'objectif';
      statusColor = Colors.orange;
    } else {
      status = 'Au-dessus de l\'objectif';
      statusColor = Colors.red;
    }

    // Groupement des repas par type
    final mealsByType = <MealType, List<MealEntry>>{
      MealType.breakfast: [],
      MealType.lunch: [],
      MealType.snack: [],
      MealType.dinner: [],
    };
    
    for (final meal in todaySummary.meals) {
      mealsByType[meal.type]?.add(meal);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainCard(
                    calories: calories,
                    remaining: remaining,
                    progress: progress,
                    status: status,
                    statusColor: statusColor,
                  ),
                  const SizedBox(height: 20),
                  _buildWeeklyTable(weeklyStatus),
                  const SizedBox(height: 20),
                  _buildMealBreakdown(mealsByType),
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
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_fire_department,
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
                    'Objectif Calories',
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
    required int calories,
    required int remaining,
    required double progress,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.15),
            const Color(0xFFFF8C42).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$calories',
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
                  '/ $_targetCaloriesPerDay kcal',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Consommées',
                  value: '$calories kcal',
                  color: const Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Restantes',
                  value: '$remaining kcal',
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  statusColor == Colors.green ? Icons.check_circle : Icons.info_outline,
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
          colors: [const Color(0xFF1E1E2E), const Color(0xFF161622)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_week, color: const Color(0xFFFF6B35), size: 20),
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
                        color: isToday ? const Color(0xFFFF6B35) : Colors.white60,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? const Color(0xFFFF6B35) : Colors.white.withOpacity(0.4),
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
                            ? Text('—', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14))
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

  Widget _buildMealBreakdown(Map<MealType, List<MealEntry>> mealsByType) {
    int _totalForType(MealType type) {
      return mealsByType[type]?.fold<int>(0, (sum, meal) => sum + meal.calories) ?? 0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1E2E), const Color(0xFF161622)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, color: const Color(0xFFFF6B35), size: 20),
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
          _buildMealRow(Icons.wb_sunny, 'Petit-déjeuner', _totalForType(MealType.breakfast), mealsByType[MealType.breakfast] ?? []),
          _buildMealRow(Icons.lunch_dining, 'Déjeuner', _totalForType(MealType.lunch), mealsByType[MealType.lunch] ?? []),
          _buildMealRow(Icons.cookie, 'Collation', _totalForType(MealType.snack), mealsByType[MealType.snack] ?? []),
          _buildMealRow(Icons.dinner_dining, 'Dîner', _totalForType(MealType.dinner), mealsByType[MealType.dinner] ?? []),
        ],
      ),
    );
  }

  Widget _buildMealRow(IconData icon, String label, int calories, List<MealEntry> meals) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFFF6B35), size: 18),
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
                  color: calories > 0 
                      ? const Color(0xFFFF6B35).withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$calories kcal',
                  style: TextStyle(
                    color: calories > 0 ? const Color(0xFFFF6B35) : Colors.white.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (meals.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...meals.map((meal) => Padding(
              padding: const EdgeInsets.only(left: 44, top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      meal.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${meal.calories} kcal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
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
