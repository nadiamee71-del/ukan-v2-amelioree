import 'package:flutter/material.dart';
import 'models/steps.dart';
import 'dart:async';

class PedometerPage extends StatefulWidget {
  const PedometerPage({super.key});

  @override
  State<PedometerPage> createState() => _PedometerPageState();
}

class _PedometerPageState extends State<PedometerPage> {
  final _stepsNotifier = StepsNotifier();
  Timer? _refreshTimer;
  int _currentSteps = 0;

  @override
  void initState() {
    super.initState();
    _stepsNotifier.addListener(_onStepsChanged);
    _updateCurrentSteps();
    // Rafraîchir toutes les secondes pour voir les pas en temps réel
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCurrentSteps();
    });
  }

  @override
  void dispose() {
    _stepsNotifier.removeListener(_onStepsChanged);
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _onStepsChanged() {
    setState(() {
      _updateCurrentSteps();
    });
  }

  void _updateCurrentSteps() {
    final today = DateTime.now();
    _currentSteps = _stepsNotifier.totalForDate(today);
    setState(() {});
  }

  void _toggleAutoMode(bool value) {
    setState(() {
      _stepsNotifier.setAutoMode(value);
    });
  }

  String _formatDayName(int weekday) {
    const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return days[weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todaySteps = _stepsNotifier.totalForDate(today);
    final weekData = _stepsNotifier.totalsForLast7Days();
    final goal = 8000; // Objectif par défaut
    final progress = (todaySteps / goal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Podomètre'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compteur principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icône podomètre
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _stepsNotifier.isCounting 
                          ? const Color(0xFFFFC300).withOpacity(0.2)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_walk,
                      size: 40,
                      color: _stepsNotifier.isCounting 
                          ? const Color(0xFFFFC300)
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Nombre de pas
                  Text(
                    _currentSteps.toString(),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'pas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Barre de progression
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Objectif : $goal pas',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: progress >= 1.0 
                                  ? Colors.green.shade700
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 
                                ? Colors.green.shade700
                                : const Color(0xFFFFC300),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Mode automatique (Switch)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mode automatique',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _stepsNotifier.autoModeEnabled
                                    ? 'Le comptage démarre automatiquement'
                                    : 'Le comptage est manuel',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _stepsNotifier.autoModeEnabled,
                          onChanged: _toggleAutoMode,
                          activeColor: const Color(0xFFFFC300),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _stepsNotifier.isCounting 
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _stepsNotifier.isCounting 
                            ? Colors.green.shade300
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _stepsNotifier.isCounting ? Icons.check_circle : Icons.pause_circle,
                          color: _stepsNotifier.isCounting 
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _stepsNotifier.isCounting 
                              ? 'Comptage actif ✓'
                              : 'Comptage arrêté',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _stepsNotifier.isCounting 
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Graphique d'évolution (7 jours)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Évolution (7 derniers jours)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (weekData.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Aucune donnée disponible.\nDémarre le comptage pour voir ton évolution.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: weekData.entries.toList().map((entry) {
                          final date = entry.key;
                          final steps = entry.value;
                          final maxSteps = weekData.values.isEmpty 
                              ? 1 
                              : weekData.values.reduce((a, b) => a > b ? a : b);
                          final heightRatio = maxSteps == 0 
                              ? 0.0 
                              : (steps / (maxSteps > goal ? maxSteps : goal)).clamp(0.0, 1.0);
                          
                          final isToday = _dateOnly(date) == _dateOnly(today);
                          
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Barre
                                  Expanded(
                                    child: FractionallySizedBox(
                                      heightFactor: heightRatio,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isToday 
                                              ? const Color(0xFFFFC300)
                                              : (steps >= goal
                                                  ? Colors.green.shade600
                                                  : Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Valeur
                                  Text(
                                    steps.toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isToday 
                                          ? const Color(0xFFFFC300)
                                          : Colors.grey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  // Jour
                                  Text(
                                    _formatDayName(date.weekday),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                      color: isToday 
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistiques du jour
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aujourd\'hui',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _StatRow(
                    icon: Icons.directions_walk,
                    label: 'Pas totaux',
                    value: '$todaySteps pas',
                  ),
                  const SizedBox(height: 16),
                  
                  _StatRow(
                    icon: Icons.trending_up,
                    label: 'Objectif',
                    value: '$goal pas',
                    valueColor: progress >= 1.0 
                        ? Colors.green.shade700
                        : Colors.black87,
                  ),
                  const SizedBox(height: 16),
                  
                  _StatRow(
                    icon: Icons.settings,
                    label: 'Mode',
                    value: _stepsNotifier.autoModeEnabled ? 'Automatique' : 'Manuel',
                    valueColor: _stepsNotifier.autoModeEnabled
                        ? const Color(0xFFFFC300)
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  _StatRow(
                    icon: Icons.remove_red_eye,
                    label: 'Statut',
                    value: _stepsNotifier.isCounting ? 'Comptage actif' : 'Comptage arrêté',
                    valueColor: _stepsNotifier.isCounting 
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

