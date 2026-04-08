import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_library_item.dart';
import '../models/workout_session.dart';
import '../models/workout_session_storage.dart';
import '../components/exercise_icon_helper.dart';
import '../services/difficulty_service.dart';
import '../models/difficulty_entry.dart';

/// Page de statistiques et graphiques d'un exercice
/// Design sombre style iOS pro avec 4 onglets
class ExerciseStatsPage extends StatefulWidget {
  final ExerciseLibraryItem exercise;

  const ExerciseStatsPage({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseStatsPage> createState() => _ExerciseStatsPageState();
}

class _ExerciseStatsPageState extends State<ExerciseStatsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ExercisePerformance> _performances = [];
  List<DifficultyEntry> _difficulties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final sessions = await WorkoutSessionStorage.getAllSessions();
    final performances = <ExercisePerformance>[];

    for (final session in sessions) {
      for (final performance in session.exercises) {
        if (performance.exerciseId == widget.exercise.id) {
          performances.add(performance);
        }
      }
    }

    final difficulties = await DifficultyService().getByExercise(widget.exercise.id);

    // Si aucune donnée réelle, ajouter des données démo
    if (performances.isEmpty) {
      performances.addAll(_generateDemoPerformances());
    }
    if (difficulties.isEmpty) {
      _difficulties = _generateDemoDifficulties();
    } else {
      _difficulties = difficulties;
    }

    setState(() {
      _performances = performances;
      _isLoading = false;
    });
  }

  // Génère des performances de démo pour l'affichage
  List<ExercisePerformance> _generateDemoPerformances() {
    final now = DateTime.now();
    return [
      ExercisePerformance(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        startedAt: now.subtract(const Duration(days: 28)),
        completedAt: now.subtract(const Duration(days: 28)),
        sets: [
          ExerciseSet(setNumber: 1, reps: 10, weight: 15, restSeconds: 60, completedAt: now.subtract(const Duration(days: 28))),
          ExerciseSet(setNumber: 2, reps: 10, weight: 15, restSeconds: 60, completedAt: now.subtract(const Duration(days: 28))),
          ExerciseSet(setNumber: 3, reps: 8, weight: 15, restSeconds: 60, completedAt: now.subtract(const Duration(days: 28))),
        ],
      ),
      ExercisePerformance(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        startedAt: now.subtract(const Duration(days: 21)),
        completedAt: now.subtract(const Duration(days: 21)),
        sets: [
          ExerciseSet(setNumber: 1, reps: 12, weight: 17.5, restSeconds: 60, completedAt: now.subtract(const Duration(days: 21))),
          ExerciseSet(setNumber: 2, reps: 11, weight: 17.5, restSeconds: 60, completedAt: now.subtract(const Duration(days: 21))),
          ExerciseSet(setNumber: 3, reps: 10, weight: 17.5, restSeconds: 60, completedAt: now.subtract(const Duration(days: 21))),
        ],
      ),
      ExercisePerformance(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        startedAt: now.subtract(const Duration(days: 14)),
        completedAt: now.subtract(const Duration(days: 14)),
        sets: [
          ExerciseSet(setNumber: 1, reps: 12, weight: 20, restSeconds: 90, completedAt: now.subtract(const Duration(days: 14))),
          ExerciseSet(setNumber: 2, reps: 12, weight: 20, restSeconds: 90, completedAt: now.subtract(const Duration(days: 14))),
          ExerciseSet(setNumber: 3, reps: 10, weight: 20, restSeconds: 90, completedAt: now.subtract(const Duration(days: 14))),
          ExerciseSet(setNumber: 4, reps: 8, weight: 20, restSeconds: 90, completedAt: now.subtract(const Duration(days: 14))),
        ],
      ),
      ExercisePerformance(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        startedAt: now.subtract(const Duration(days: 7)),
        completedAt: now.subtract(const Duration(days: 7)),
        sets: [
          ExerciseSet(setNumber: 1, reps: 12, weight: 22.5, restSeconds: 90, completedAt: now.subtract(const Duration(days: 7))),
          ExerciseSet(setNumber: 2, reps: 12, weight: 22.5, restSeconds: 90, completedAt: now.subtract(const Duration(days: 7))),
          ExerciseSet(setNumber: 3, reps: 11, weight: 22.5, restSeconds: 90, completedAt: now.subtract(const Duration(days: 7))),
          ExerciseSet(setNumber: 4, reps: 10, weight: 22.5, restSeconds: 90, completedAt: now.subtract(const Duration(days: 7))),
        ],
      ),
      ExercisePerformance(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        startedAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(days: 2)),
        sets: [
          ExerciseSet(setNumber: 1, reps: 15, weight: 25, restSeconds: 90, completedAt: now.subtract(const Duration(days: 2))),
          ExerciseSet(setNumber: 2, reps: 14, weight: 25, restSeconds: 90, completedAt: now.subtract(const Duration(days: 2))),
          ExerciseSet(setNumber: 3, reps: 12, weight: 25, restSeconds: 90, completedAt: now.subtract(const Duration(days: 2))),
          ExerciseSet(setNumber: 4, reps: 10, weight: 25, restSeconds: 90, completedAt: now.subtract(const Duration(days: 2))),
        ],
      ),
    ];
  }

  List<DifficultyEntry> _generateDemoDifficulties() {
    final now = DateTime.now();
    return [
      DifficultyEntry(
        id: 'demo1',
        exerciseId: widget.exercise.id,
        sessionId: 'demo_session_1',
        level: 6,
        date: now.subtract(const Duration(days: 28)),
      ),
      DifficultyEntry(
        id: 'demo2',
        exerciseId: widget.exercise.id,
        sessionId: 'demo_session_2',
        level: 7,
        date: now.subtract(const Duration(days: 21)),
      ),
      DifficultyEntry(
        id: 'demo3',
        exerciseId: widget.exercise.id,
        sessionId: 'demo_session_3',
        level: 7,
        date: now.subtract(const Duration(days: 14)),
      ),
      DifficultyEntry(
        id: 'demo4',
        exerciseId: widget.exercise.id,
        sessionId: 'demo_session_4',
        level: 8,
        date: now.subtract(const Duration(days: 7)),
      ),
      DifficultyEntry(
        id: 'demo5',
        exerciseId: widget.exercise.id,
        sessionId: 'demo_session_5',
        level: 8,
        date: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.exercise.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFC300),
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          indicatorColor: const Color(0xFFFFC300),
          indicatorWeight: 3,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Résumé'),
            Tab(text: 'Progression'),
            Tab(text: 'Records'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC300)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildResumeTab(),
                _buildProgressionTab(),
                _buildRecordsTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ONGLET RÉSUMÉ
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildResumeTab() {
    final allSets = <ExerciseSet>[];
    for (final perf in _performances) {
      allSets.addAll(perf.sets);
    }

    final totalReps = allSets.fold(0, (sum, set) => sum + (set.reps ?? 0));
    final totalVolume = allSets.fold(0.0, (sum, set) {
      if (set.weight != null && set.reps != null) {
        return sum + (set.weight! * set.reps!);
      }
      return sum;
    });
    final totalSessions = _performances.length;
    final avgDifficulty = _difficulties.isNotEmpty
        ? _difficulties.map((d) => d.level.toDouble()).reduce((a, b) => a + b) / _difficulties.length
        : null;
    
    // Dernière séance
    final lastSession = _performances.isNotEmpty 
        ? _performances.reduce((a, b) => 
            (a.completedAt ?? a.startedAt ?? DateTime(2000)).isAfter(b.completedAt ?? b.startedAt ?? DateTime(2000)) ? a : b)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte exercice avec infos
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFC300).withOpacity(0.15),
                  const Color(0xFFFFC300).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ExerciseIconHelper.buildExerciseAvatar(
                      widget.exercise.name,
                      widget.exercise.category,
                      size: 70,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.exercise.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.exercise.category,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Muscles ciblés
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: widget.exercise.muscles.map((muscle) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC300).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                muscle,
                                style: const TextStyle(
                                  color: Color(0xFFFFC300),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.exercise.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.exercise.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Badge "Données démo"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  'Données de démonstration',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Statistiques rapides
          Row(
            children: [
              Expanded(child: _QuickStatCard(
                icon: Icons.fitness_center,
                value: '$totalSessions',
                label: 'Séances',
                color: Colors.blue,
              )),
              const SizedBox(width: 12),
              Expanded(child: _QuickStatCard(
                icon: Icons.repeat,
                value: '$totalReps',
                label: 'Reps totales',
                color: Colors.green,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _QuickStatCard(
                icon: Icons.trending_up,
                value: '${(totalVolume / 1000).toStringAsFixed(1)}t',
                label: 'Volume total',
                color: Colors.orange,
              )),
              const SizedBox(width: 12),
              Expanded(child: _QuickStatCard(
                icon: Icons.speed,
                value: avgDifficulty != null ? '${avgDifficulty.toStringAsFixed(1)}/10' : '-',
                label: 'Diff. moyenne',
                color: Colors.purple,
              )),
            ],
          ),
          const SizedBox(height: 24),
          
          // Dernière séance
          if (lastSession != null) ...[
            Row(
              children: [
                const Icon(Icons.history, color: Color(0xFFFFC300), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Dernière séance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE dd MMMM', 'fr_FR').format(lastSession.completedAt ?? lastSession.startedAt ?? DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MiniStatChip(
                        icon: Icons.layers,
                        value: '${lastSession.sets.length} séries',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _MiniStatChip(
                        icon: Icons.repeat,
                        value: '${lastSession.sets.fold(0, (sum, s) => sum + (s.reps ?? 0))} reps',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      if (lastSession.sets.any((s) => s.weight != null))
                        _MiniStatChip(
                          icon: Icons.fitness_center,
                          value: '${lastSession.sets.where((s) => s.weight != null).map((s) => s.weight!).reduce((a, b) => a > b ? a : b)} kg max',
                          color: Colors.orange,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          
          // Conseils
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFFFFC300), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Conseils',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.trending_up,
            title: 'Progression',
            description: 'Augmentez la charge de 2.5kg quand vous atteignez 12 reps facilement',
            color: Colors.green,
          ),
          _TipCard(
            icon: Icons.timer,
            title: 'Repos',
            description: 'Repos de 60-90s pour l\'hypertrophie, 2-3min pour la force',
            color: Colors.blue,
          ),
          _TipCard(
            icon: Icons.repeat,
            title: 'Fréquence',
            description: 'Entraînez ce groupe musculaire 2x par semaine pour des résultats optimaux',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ONGLET PROGRESSION
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProgressionTab() {
    if (_performances.isEmpty) {
      return _buildEmptyState('Pas de progression', 'Faites plus de séances !');
    }

    // Préparer les données pour le graphique
    final dataPoints = <MapEntry<DateTime, double>>[];
    for (final perf in _performances) {
      for (final set in perf.sets) {
        if (set.weight != null && set.completedAt != null) {
          dataPoints.add(MapEntry(set.completedAt!, set.weight!));
        }
      }
    }
    dataPoints.sort((a, b) => a.key.compareTo(b.key));

    // Calculer la progression
    double? firstWeight;
    double? lastWeight;
    if (dataPoints.isNotEmpty) {
      firstWeight = dataPoints.first.value;
      lastWeight = dataPoints.last.value;
    }
    final progression = firstWeight != null && lastWeight != null
        ? ((lastWeight - firstWeight) / firstWeight * 100)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur de progression
          if (progression != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: progression >= 0
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: progression >= 0 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    progression >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: progression >= 0 ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progression >= 0 ? '+' : ''}${progression.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: progression >= 0 ? Colors.green : Colors.red,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Depuis la première séance',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Graphique
          const Text(
            '📈 Évolution de la charge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: dataPoints.isEmpty
                ? Center(
                    child: Text(
                      'Pas de données de charge',
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  )
                : _buildSimpleLineChart(dataPoints),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ONGLET RECORDS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRecordsTab() {
    if (_performances.isEmpty) {
      return _buildEmptyState('Pas de records', 'Battez vos premiers records !');
    }

    final allSets = <ExerciseSet>[];
    for (final perf in _performances) {
      allSets.addAll(perf.sets);
    }

    // Trouver les records
    ExerciseSet? bestWeightSet;
    ExerciseSet? bestRepsSet;
    ExerciseSet? bestTimeSet;
    ExerciseSet? bestVolumeSet;
    double maxWeight = 0;
    int maxReps = 0;
    int maxDuration = 0;
    double maxVolume = 0;

    for (final set in allSets) {
      if (set.weight != null && set.weight! > maxWeight) {
        maxWeight = set.weight!;
        bestWeightSet = set;
      }
      if (set.reps != null && set.reps! > maxReps) {
        maxReps = set.reps!;
        bestRepsSet = set;
      }
      if (set.durationSeconds != null && set.durationSeconds! > maxDuration) {
        maxDuration = set.durationSeconds!;
        bestTimeSet = set;
      }
      if (set.weight != null && set.reps != null) {
        final volume = set.weight! * set.reps!;
        if (volume > maxVolume) {
          maxVolume = volume;
          bestVolumeSet = set;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Color(0xFFFFC300), size: 28),
              SizedBox(width: 8),
              Text(
                'Mes Records Personnels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (bestWeightSet != null)
            _RecordCard(
              icon: Icons.fitness_center,
              title: 'Charge maximale',
              value: '${bestWeightSet.weight} kg',
              subtitle: bestWeightSet.completedAt != null
                  ? 'Le ${DateFormat('dd/MM/yyyy').format(bestWeightSet.completedAt!)}'
                  : null,
              color: const Color(0xFFFFC300),
            ),
          if (bestRepsSet != null)
            _RecordCard(
              icon: Icons.repeat,
              title: 'Maximum de répétitions',
              value: '${bestRepsSet.reps} reps',
              subtitle: bestRepsSet.weight != null ? 'à ${bestRepsSet.weight} kg' : null,
              color: Colors.green,
            ),
          if (bestVolumeSet != null)
            _RecordCard(
              icon: Icons.trending_up,
              title: 'Meilleur volume (1 série)',
              value: '${maxVolume.toStringAsFixed(0)} kg',
              subtitle: '${bestVolumeSet.reps} reps × ${bestVolumeSet.weight} kg',
              color: Colors.blue,
            ),
          if (bestTimeSet != null)
            _RecordCard(
              icon: Icons.timer,
              title: 'Temps maximum',
              value: _formatDuration(bestTimeSet.durationSeconds!),
              subtitle: bestTimeSet.completedAt != null
                  ? 'Le ${DateFormat('dd/MM/yyyy').format(bestTimeSet.completedAt!)}'
                  : null,
              color: Colors.purple,
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ONGLET HISTORIQUE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHistoryTab() {
    if (_performances.isEmpty) {
      return _buildEmptyState('Pas d\'historique', 'Vos séances apparaîtront ici');
    }

    // Trier par date décroissante
    final sortedPerformances = List<ExercisePerformance>.from(_performances)
      ..sort((a, b) => (b.completedAt ?? b.startedAt ?? DateTime.now())
          .compareTo(a.completedAt ?? a.startedAt ?? DateTime.now()));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedPerformances.length,
      itemBuilder: (context, index) {
        final perf = sortedPerformances[index];
        final date = perf.completedAt ?? perf.startedAt ?? DateTime.now();
        final totalReps = perf.sets.fold(0, (sum, s) => sum + (s.reps ?? 0));
        final totalVolume = perf.sets.fold(0.0, (sum, s) {
          if (s.weight != null && s.reps != null) {
            return sum + (s.weight! * s.reps!);
          }
          return sum;
        });

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            iconColor: Colors.white54,
            collapsedIconColor: Colors.white54,
            title: Text(
              DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(date),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${perf.sets.length} séries • $totalReps reps • ${totalVolume.toStringAsFixed(0)} kg',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            children: [
              // Tableau des séries
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // En-tête
                    Row(
                      children: [
                        Expanded(child: Text('Série', style: _headerStyle)),
                        Expanded(child: Text('Reps', style: _headerStyle, textAlign: TextAlign.center)),
                        Expanded(child: Text('Charge', style: _headerStyle, textAlign: TextAlign.center)),
                        Expanded(child: Text('Repos', style: _headerStyle, textAlign: TextAlign.end)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    // Séries
                    ...perf.sets.map((set) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text('${set.setNumber}', style: _cellStyle)),
                            Expanded(child: Text('${set.reps ?? '-'}', style: _cellStyle, textAlign: TextAlign.center)),
                            Expanded(child: Text(set.weight != null ? '${set.weight} kg' : '-', style: _cellStyle, textAlign: TextAlign.center)),
                            Expanded(child: Text(set.restSeconds != null ? '${set.restSeconds}s' : '-', style: _cellStyle, textAlign: TextAlign.end)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle get _headerStyle => TextStyle(
    color: Colors.white.withOpacity(0.5),
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  TextStyle get _cellStyle => const TextStyle(
    color: Colors.white,
    fontSize: 13,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGETS UTILITAIRES
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildSimpleLineChart(List<MapEntry<DateTime, double>> dataPoints) {
    return CustomPaint(
      painter: _LineChartPainter(dataPoints),
      child: const SizedBox.expand(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _RecordCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.emoji_events, color: color.withOpacity(0.5), size: 32),
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.3,
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

class _LineChartPainter extends CustomPainter {
  final List<MapEntry<DateTime, double>> dataPoints;

  _LineChartPainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFFFC300)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFC300).withOpacity(0.3),
          const Color(0xFFFFC300).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final minWeight = dataPoints.map((e) => e.value).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxWeight = dataPoints.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.1;
    final weightRange = maxWeight - minWeight;
    final padding = 20.0;
    final chartWidth = size.width - 2 * padding;
    final chartHeight = size.height - 2 * padding;

    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = padding + (i / (dataPoints.length - 1).clamp(1, double.infinity)) * chartWidth;
      final normalizedWeight = (dataPoints[i].value - minWeight) / (weightRange > 0 ? weightRange : 1);
      final y = size.height - padding - normalizedWeight * chartHeight;
      points.add(Offset(x, y));
    }

    // Dessiner la zone sous la courbe
    final fillPath = Path();
    fillPath.moveTo(points[0].dx, size.height - padding);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height - padding);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Dessiner la ligne
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Dessiner les points
    final pointPaint = Paint()
      ..color = const Color(0xFFFFC300)
      ..style = PaintingStyle.fill;
    final pointBorderPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 6, pointBorderPaint);
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
