import 'package:flutter/material.dart';
import '../models/goals.dart';
import '../add_sleep_page.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

class SleepGoalPage extends StatefulWidget {
  const SleepGoalPage({super.key});

  @override
  State<SleepGoalPage> createState() => _SleepGoalPageState();
}

class _SleepGoalPageState extends State<SleepGoalPage> {
  final _goalsNotifier = DailyGoalsNotifier();

  @override
  void initState() {
    super.initState();
    _goalsNotifier.addListener(_onDataChanged);
    AlterEgoPageDetector.setupPageContext(UkanPage.objectifSommeil);
  }

  @override
  void dispose() {
    _goalsNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  List<bool?> _getWeeklyStatus() {
    final now = DateTime.now();
    final sleepEntries = _goalsNotifier.sleepEntriesForLast7Days();
    final goal = _goalsNotifier.sleepGoalHours;
    
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

  @override
  Widget build(BuildContext context) {
    final lastSleep = _goalsNotifier.lastSleepEntry();
    final sleepGoalHours = _goalsNotifier.sleepGoalHours;
    final progress = lastSleep != null 
        ? (lastSleep.durationMinutes / (sleepGoalHours * 60)).clamp(0.0, 1.0)
        : 0.0;
    final weeklyStatus = _getWeeklyStatus();

    String status;
    Color statusColor;
    if (lastSleep == null) {
      status = 'Aucun sommeil enregistré';
      statusColor = Colors.white54;
    } else if (progress >= 0.9 && progress <= 1.1) {
      status = 'Excellent sommeil ! 😴';
      statusColor = Colors.green;
    } else if (progress >= 0.7) {
      status = 'Bon sommeil';
      statusColor = const Color(0xFF7C4DFF);
    } else {
      status = 'Sommeil insuffisant';
      statusColor = Colors.orange;
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
                    lastSleep: lastSleep,
                    sleepGoalHours: sleepGoalHours,
                    progress: progress,
                    status: status,
                    statusColor: statusColor,
                  ),
                  const SizedBox(height: 20),
                  _buildAddSleepSection(context),
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
                  colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bedtime,
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
                    'Objectif Sommeil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Dernière nuit',
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
    required SleepEntry? lastSleep,
    required double sleepGoalHours,
    required double progress,
    required String status,
    required Color statusColor,
  }) {
    String durationText;
    if (lastSleep != null) {
      final durationHours = (lastSleep.durationMinutes / 60).floor();
      final durationMins = lastSleep.durationMinutes % 60;
      durationText = '${durationHours}h${durationMins.toString().padLeft(2, '0')}';
    } else {
      durationText = '—';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C4DFF).withOpacity(0.15),
            const Color(0xFF536DFE).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C4DFF).withOpacity(0.3),
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
                          progress >= 0.9 ? Colors.green : const Color(0xFF7C4DFF),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bedtime, color: Color(0xFF7C4DFF), size: 28),
                    const SizedBox(height: 8),
                    Text(
                      durationText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Objectif : ${sleepGoalHours.toStringAsFixed(0)}h',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                  progress >= 0.9 ? Icons.check_circle : Icons.bedtime,
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
          if (lastSleep != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSleepInfo(
                    Icons.nightlight_round,
                    'Couché',
                    _formatTime(lastSleep.bedTime),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSleepInfo(
                    Icons.wb_sunny,
                    'Levé',
                    _formatTime(lastSleep.wakeTime),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSleepInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF7C4DFF), size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSleepSection(BuildContext context) {
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
              Icon(Icons.add_circle_outline, color: const Color(0xFF7C4DFF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Enregistrer mon sommeil',
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
                  MaterialPageRoute(builder: (_) => const AddSleepPage()),
                );
              },
              icon: const Icon(Icons.bedtime_outlined),
              label: const Text('Ajouter mon sommeil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
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
              Icon(Icons.calendar_view_week, color: const Color(0xFF7C4DFF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Sommeil de la semaine',
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
                        color: isToday ? const Color(0xFF7C4DFF) : Colors.white60,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? const Color(0xFF7C4DFF) : Colors.white.withOpacity(0.4),
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
                                : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: status == null
                              ? Colors.white.withOpacity(0.1)
                              : status
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.orange.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: status == null
                            ? Text('—', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14))
                            : Icon(
                                status ? Icons.check : Icons.remove,
                                size: 18,
                                color: status ? Colors.green : Colors.orange,
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
