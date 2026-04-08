import 'package:flutter/material.dart';
import '../models/goals.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

class HydrationGoalPage extends StatefulWidget {
  const HydrationGoalPage({super.key});

  @override
  State<HydrationGoalPage> createState() => _HydrationGoalPageState();
}

class _HydrationGoalPageState extends State<HydrationGoalPage> {
  final _goalsNotifier = DailyGoalsNotifier();
  final _millilitersController = TextEditingController(text: '250');

  @override
  void initState() {
    super.initState();
    _goalsNotifier.addListener(_onDataChanged);
    AlterEgoPageDetector.setupPageContext(UkanPage.objectifHydratation);
  }

  @override
  void dispose() {
    _goalsNotifier.removeListener(_onDataChanged);
    _millilitersController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  void _quickAdd(int milliliters) {
    final today = DateTime.now();
    HydrationNotifier().addWater(date: today, milliliters: milliliters);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$milliliters ml ajoutés 💧'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF00BCD4),
      ),
    );
  }

  void _addWater() {
    final milliliters = int.tryParse(_millilitersController.text.trim());
    if (milliliters == null || milliliters <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une quantité valide.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final today = DateTime.now();
    HydrationNotifier().addWater(date: today, milliliters: milliliters);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$milliliters ml ajoutés 💧'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF00BCD4),
      ),
    );

    _millilitersController.text = '250';
  }

  List<bool?> _getWeeklyStatus() {
    final now = DateTime.now();
    final waterData = _goalsNotifier.waterTotalsForLast7Days();
    final goalMl = (_goalsNotifier.waterGoalLiters * 1000).round();
    
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final totalMl = waterData[dateOnly] ?? 0;
      if (totalMl == 0) return null;
      return totalMl >= goalMl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final totalMl = _goalsNotifier.totalWaterForDate(today);
    final goalMl = (_goalsNotifier.waterGoalLiters * 1000).round();
    final totalL = (totalMl / 1000.0).toStringAsFixed(1);
    final goalL = _goalsNotifier.waterGoalLiters.toStringAsFixed(1);
    final progress = _goalsNotifier.waterProgressForDate(today).clamp(0.0, 1.0);
    final remainingMl = (goalMl - totalMl).clamp(0, goalMl);
    final remainingL = (remainingMl / 1000.0).toStringAsFixed(1);
    final weeklyStatus = _getWeeklyStatus();
    
    String status;
    Color statusColor;
    if (totalMl == 0) {
      status = 'Commence à t\'hydrater !';
      statusColor = Colors.white54;
    } else if (progress >= 1.0) {
      status = 'Objectif atteint ! 💧';
      statusColor = Colors.green;
    } else if (progress >= 0.7) {
      status = 'Tu y es presque !';
      statusColor = const Color(0xFF00BCD4);
    } else {
      status = 'Hydrate-toi encore';
      statusColor = const Color(0xFF00BCD4);
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
                    totalL: totalL,
                    goalL: goalL,
                    remainingL: remainingL,
                    progress: progress,
                    status: status,
                    statusColor: statusColor,
                  ),
                  const SizedBox(height: 20),
                  _buildQuickAddSection(),
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
                  colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.water_drop,
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
                    'Objectif Hydratation',
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
    required String totalL,
    required String goalL,
    required String remainingL,
    required double progress,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BCD4).withOpacity(0.15),
            const Color(0xFF0097A7).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00BCD4).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalL,
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
                  '/ $goalL L',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 20,
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
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : const Color(0xFF00BCD4),
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Bue aujourd\'hui',
                  value: '$totalL L',
                  color: const Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Restante',
                  value: '$remainingL L',
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
                  progress >= 1.0 ? Icons.check_circle : Icons.water_drop,
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

  Widget _buildQuickAddSection() {
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
              Icon(Icons.add_circle_outline, color: const Color(0xFF00BCD4), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ajouter de l\'eau',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildQuickAddButton('250 ml', 250)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickAddButton('500 ml', 500)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickAddButton('1 L', 1000)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _millilitersController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Quantité (ml)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addWater,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ajouter',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String label, int ml) {
    return OutlinedButton(
      onPressed: () => _quickAdd(ml),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF00BCD4),
        side: BorderSide(color: const Color(0xFF00BCD4).withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
              Icon(Icons.calendar_view_week, color: const Color(0xFF00BCD4), size: 20),
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
                        color: isToday ? const Color(0xFF00BCD4) : Colors.white60,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? const Color(0xFF00BCD4) : Colors.white.withOpacity(0.4),
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
