import 'package:flutter/material.dart';
import '../models/steps.dart';
import '../add_steps_page.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

class StepsGoalPage extends StatefulWidget {
  const StepsGoalPage({super.key});

  @override
  State<StepsGoalPage> createState() => _StepsGoalPageState();
}

class _StepsGoalPageState extends State<StepsGoalPage> {
  final _stepsNotifier = StepsNotifier();
  static const int _stepsGoal = 8000;

  @override
  void initState() {
    super.initState();
    _stepsNotifier.addListener(_onStepsChanged);
    AlterEgoPageDetector.setupPageContext(UkanPage.objectifPas);
  }

  @override
  void dispose() {
    _stepsNotifier.removeListener(_onStepsChanged);
    super.dispose();
  }

  void _onStepsChanged() {
    setState(() {});
  }

  List<bool?> _getWeeklyStatus() {
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

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final totalSteps = _stepsNotifier.totalForDate(today);
    final progress = (totalSteps / _stepsGoal).clamp(0.0, 1.0);
    final remainingSteps = (_stepsGoal - totalSteps).clamp(0, _stepsGoal);
    final weeklyStatus = _getWeeklyStatus();
    
    String status;
    Color statusColor;
    if (totalSteps == 0) {
      status = 'Aucun pas enregistré';
      statusColor = Colors.white54;
    } else if (totalSteps >= _stepsGoal) {
      status = 'Objectif atteint ! 🎉';
      statusColor = Colors.green;
    } else if (progress >= 0.7) {
      status = 'Tu y es presque !';
      statusColor = const Color(0xFF4CAF50);
    } else if (progress >= 0.5) {
      status = 'Bien joué, continue !';
      statusColor = const Color(0xFF8BC34A);
    } else {
      status = 'En route vers l\'objectif';
      statusColor = const Color(0xFF8BC34A);
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
                    totalSteps: totalSteps,
                    remainingSteps: remainingSteps,
                    progress: progress,
                    status: status,
                    statusColor: statusColor,
                  ),
                  const SizedBox(height: 20),
                  _buildAddStepsSection(context),
                  const SizedBox(height: 20),
                  _buildWeeklyTable(weeklyStatus),
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
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_walk,
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
                    'Objectif Pas',
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
    required int totalSteps,
    required int remainingSteps,
    required double progress,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.15),
            const Color(0xFF8BC34A).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Cercle de progression
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 14,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? Colors.green : const Color(0xFF4CAF50),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalSteps.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]} ',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'pas',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Objectif : $_stepsGoal pas',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Effectués',
                  value: '$totalSteps',
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Restants',
                  value: '$remainingSteps',
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
                  progress >= 1.0 ? Icons.check_circle : Icons.directions_walk,
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

  Widget _buildAddStepsSection(BuildContext context) {
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
              Icon(Icons.add_circle_outline, color: const Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Enregistrer mes pas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddStepsPage()),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Ajouter des pas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              Icon(Icons.calendar_view_week, color: const Color(0xFF4CAF50), size: 20),
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
                        color: isToday ? const Color(0xFF4CAF50) : Colors.white60,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.4),
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
}
