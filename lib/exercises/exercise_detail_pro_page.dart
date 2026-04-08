import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_library_item.dart';
import '../models/workout_session.dart';
import '../models/workout_session_storage.dart';
import '../components/exercise_icon_helper.dart';
import '../components/difficulty_form.dart';
import '../services/difficulty_service.dart';
import '../models/difficulty_entry.dart';
import 'exercise_series_dialog.dart';
import 'exercise_stats_page.dart';

/// Page de détail d'un exercice - Version PRO
/// Design sombre style iOS avec toutes les fonctionnalités
class ExerciseDetailProPage extends StatefulWidget {
  final ExerciseLibraryItem exercise;
  final String? sessionId; // ID de la séance en cours (optionnel)

  const ExerciseDetailProPage({
    super.key,
    required this.exercise,
    this.sessionId,
  });

  @override
  State<ExerciseDetailProPage> createState() => _ExerciseDetailProPageState();
}

class _ExerciseDetailProPageState extends State<ExerciseDetailProPage> {
  List<ExerciseSet> _sets = [];
  bool _isLoading = true;
  List<int> _selectedRestTimes = []; // Plusieurs temps de repos possibles
  Map<int, int> _activeRestTimers = {}; // Map: setNumber -> restTimeSeconds
  DifficultyEntry? _currentDifficulty;
  int _defaultRestSeconds = 90; // Temps de repos par défaut

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
    _loadDifficulty();
  }

  Future<void> _loadExerciseData() async {
    setState(() {
      _isLoading = true;
    });

    // Charger les séries depuis les séances existantes pour cet exercice
    final sessions = await WorkoutSessionStorage.getAllSessions();
    final today = DateTime.now();
    final todaySessions = sessions.where((s) {
      final sessionDate = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      return sessionDate == todayDate;
    }).toList();

    // Récupérer les séries d'aujourd'hui pour cet exercice
    final todaySets = <ExerciseSet>[];
    for (final session in todaySessions) {
      for (final performance in session.exercises) {
        if (performance.exerciseId == widget.exercise.id) {
          todaySets.addAll(performance.sets);
        }
      }
    }

    setState(() {
      _sets = todaySets;
      _isLoading = false;
    });
  }

  Future<void> _loadDifficulty() async {
    final difficulties = await DifficultyService().getByExercise(widget.exercise.id);
    if (difficulties.isNotEmpty) {
      // Prendre la dernière difficulté enregistrée aujourd'hui
      final today = DateTime.now();
      final todayDifficulties = difficulties.where((d) {
        final diffDate = DateTime(d.date.year, d.date.month, d.date.day);
        final todayDate = DateTime(today.year, today.month, today.day);
        return diffDate == todayDate;
      }).toList();

      if (todayDifficulties.isNotEmpty) {
        setState(() {
          _currentDifficulty = todayDifficulties.last;
        });
      }
    }
  }

  void _addSeries() {
    // Récupérer la dernière série pour copier
    final lastSet = _sets.isNotEmpty ? _sets.last : null;
    
    showDialog(
      context: context,
      builder: (context) => ExerciseSeriesDialog(
        previousReps: lastSet?.reps,
        previousWeight: lastSet?.weight,
        previousIsBodyweight: lastSet?.weight == null,
        previousDurationSeconds: lastSet?.durationSeconds,
        allowTimeMode: true, // Permettre le mode temps
        onSave: (reps, weight, isBodyweight, durationSeconds, isBestSet, restSeconds) async {
          // Utiliser le temps de repos sélectionné dans la modale, ou le dernier de la liste, ou 90s par défaut
          final restTime = restSeconds ?? 
              (_selectedRestTimes.isNotEmpty ? _selectedRestTimes.last : 90);
          
          final newSet = ExerciseSet(
            setNumber: _sets.length + 1,
            type: durationSeconds != null ? SetType.time : SetType.reps,
            reps: reps,
            weight: isBodyweight ? null : weight,
            durationSeconds: durationSeconds,
            restSeconds: restTime,
            completedAt: DateTime.now(),
            isBestSet: isBestSet,
          );
          
          // Ajouter un chrono de repos pour cette série si un temps de repos est défini
          if (restTime > 0) {
            setState(() {
              _activeRestTimers[newSet.setNumber] = restTime;
            });
          }

          setState(() {
            _sets.add(newSet);
          });

          // Sauvegarder dans une séance
          await _saveToSession(newSet);
        },
      ),
    );
  }

  Future<void> _saveToSession(ExerciseSet set) async {
    final sessions = await WorkoutSessionStorage.getAllSessions();
    final today = DateTime.now();
    
    // Trouver ou créer une séance pour aujourd'hui
    WorkoutSession? todaySession;
    for (final session in sessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      if (sessionDate == todayDate) {
        todaySession = session;
        break;
      }
    }

    if (todaySession == null) {
      // Créer une nouvelle séance
      todaySession = WorkoutSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Séance du ${DateFormat('dd/MM/yyyy').format(today)}',
        startTime: today,
        exercises: [],
      );
    }

    // Ajouter ou mettre à jour la performance de l'exercice
    final exerciseIndex = todaySession.exercises.indexWhere(
      (e) => e.exerciseId == widget.exercise.id,
    );

    if (exerciseIndex >= 0) {
      // Mettre à jour l'exercice existant
      final existingPerformance = todaySession.exercises[exerciseIndex];
      final updatedSets = List<ExerciseSet>.from(existingPerformance.sets)..add(set);
      todaySession.exercises[exerciseIndex] = ExercisePerformance(
        exerciseId: existingPerformance.exerciseId,
        exerciseName: existingPerformance.exerciseName,
        sets: updatedSets,
        notes: existingPerformance.notes,
        startedAt: existingPerformance.startedAt,
        completedAt: DateTime.now(),
      );
    } else {
      // Ajouter un nouvel exercice
      todaySession.exercises.add(
        ExercisePerformance(
          exerciseId: widget.exercise.id,
          exerciseName: widget.exercise.name,
          sets: [set],
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
        ),
      );
    }

    await WorkoutSessionStorage.saveSession(todaySession);
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => DifficultyForm(
        exerciseId: widget.exercise.id,
        sessionId: widget.sessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
        onSave: (entry) async {
          await DifficultyService().saveDifficulty(entry);
          _loadDifficulty();
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showStats() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseStatsPage(exercise: widget.exercise),
      ),
    );
  }

  void _showPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PreferencesSheet(
        exerciseName: widget.exercise.name,
        onRestTimeChanged: (seconds) {
          setState(() {
            _defaultRestSeconds = seconds;
          });
        },
        currentRestTime: _defaultRestSeconds,
      ),
    );
  }

  int get _totalReps {
    return _sets.fold(0, (sum, set) => sum + (set.reps ?? 0));
  }

  double get _totalVolume {
    return _sets.fold(0.0, (sum, set) {
      if (set.weight != null && set.reps != null) {
        return sum + (set.weight! * set.reps!);
      }
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Détail de l\'exercice',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStats,
            tooltip: 'Statistiques',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showPreferences,
            tooltip: 'Préférences',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec icône et nom
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Objectif de la séance
                  _buildObjective(),
                  const SizedBox(height: 24),

                  // Résumé (si séries existantes)
                  if (_sets.isNotEmpty) ...[
                    _buildSummary(),
                    const SizedBox(height: 24),
                  ],

                  // Liste des séries ou message vide
                  if (_sets.isEmpty)
                    _buildEmptyState()
                  else
                    _buildSetsList(),

                  const SizedBox(height: 24),

                  // Widget de difficulté ressentie
                  _buildDifficultySection(),
                  const SizedBox(height: 20),
                  
                  // Section conseils et astuces
                  _buildTipsSection(),
                  const SizedBox(height: 20),
                  
                  // Section actions rapides
                  _buildQuickActionsSection(),
                  
                  // Espace pour la barre fixe en bas + FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
      // Barre fixe en bas simplifiée
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Bouton repos
              GestureDetector(
                onTap: _showRestTimeSettings,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Color(0xFF007AFF), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Repos',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Affichage chrono actif si présent
              if (_activeRestTimers.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.hourglass_bottom, color: Color(0xFF007AFF), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_activeRestTimers.length} chrono${_activeRestTimers.length > 1 ? 's' : ''} actif${_activeRestTimers.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSeries,
        backgroundColor: const Color(0xFF007AFF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter une série',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Icône de l'exercice
        ExerciseIconHelper.buildExerciseAvatar(
          widget.exercise.name,
          widget.exercise.category,
          size: 80,
        ),
        const SizedBox(width: 20),
        // Nom de l'exercice
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exercise.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.exercise.category,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildObjective() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag,
            color: Color(0xFFFFC300),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Objectif de la séance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '4 x max reps${_selectedRestTimes.isNotEmpty ? ' - repos ${_selectedRestTimes.map((t) => _formatRestTime(t)).join(", ")}' : " - repos 1'30"}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final today = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateFormat('dd/MM yyyy').format(today)} – Total $_totalReps reps – ${_totalVolume.toStringAsFixed(0)} kg',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_outlined,
              size: 36,
              color: Color(0xFFFFC300),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Prêt à commencer ?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur "+ Ajouter une série" pour enregistrer votre première série.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          // Conseils rapides
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFFFFC300), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Conseil : Commencez avec une charge légère pour vous échauffer.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
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

  Widget _buildSetsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Séries',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ..._sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return _SetCard(
            setNumber: index + 1,
            set: set,
            onDelete: () {
              setState(() {
                _sets.removeAt(index);
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildDifficultySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Difficulté ressentie pour cette séance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentDifficulty != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(_currentDifficulty!.level).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_currentDifficulty!.level}/10',
                    style: TextStyle(
                      color: _getDifficultyColor(_currentDifficulty!.level),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _showDifficultyDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentDifficulty != null ? 'Modifier la difficulté' : 'Enregistrer la difficulté',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC300).withOpacity(0.15),
            const Color(0xFFFFC300).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFC300).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Color(0xFFFFC300), size: 22),
              SizedBox(width: 10),
              Text(
                'Conseils pour cet exercice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('💪', 'Gardez le dos droit pendant tout le mouvement'),
          const SizedBox(height: 8),
          _buildTipItem('🎯', 'Concentrez-vous sur la contraction musculaire'),
          const SizedBox(height: 8),
          _buildTipItem('⏱️', 'Respectez vos temps de repos entre les séries'),
        ],
      ),
    );
  }
  
  Widget _buildTipItem(String emoji, String tip) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            tip,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.history,
                label: 'Historique',
                color: const Color(0xFF007AFF),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Historique bientôt disponible')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.show_chart,
                label: 'Progression',
                color: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Graphiques bientôt disponibles')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.flag_outlined,
                label: 'Défi',
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Créez un défi pour cet exercice')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  String _formatRestTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}\'${secs.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Lance un timer de repos rapide - Clic direct sur un preset
  void _showRestTimeSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickRestTimerSheet(
        onSelectAndStart: (seconds) {
          Navigator.of(context).pop();
          _startRestTimer(seconds);
        },
      ),
    );
  }

  /// Démarre le timer de repos
  void _startRestTimer(int seconds) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActiveRestTimerSheet(
        initialSeconds: seconds,
        onComplete: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text('Repos terminé ! C\'est reparti ! 💪'),
                ],
              ),
              backgroundColor: const Color(0xFF34C759),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Carte d'une série
class _SetCard extends StatelessWidget {
  final int setNumber;
  final ExerciseSet set;
  final VoidCallback onDelete;

  const _SetCard({
    required this.setNumber,
    required this.set,
    required this.onDelete,
  });

  String _formatRestTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}\'${secs.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: set.isBestSet
            ? const Color(0xFFFFC300).withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: set.isBestSet
              ? const Color(0xFFFFC300)
              : Colors.white.withOpacity(0.1),
          width: set.isBestSet ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: set.isBestSet
                      ? const Color(0xFFFFC300).withOpacity(0.3)
                      : const Color(0xFF007AFF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$setNumber',
                    style: TextStyle(
                      color: set.isBestSet
                          ? const Color(0xFFFFC300)
                          : const Color(0xFF007AFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (set.isBestSet)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC300),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      set.type == SetType.time
                          ? 'Série $setNumber : ${_formatDuration(set.durationSeconds ?? 0)}'
                          : 'Série $setNumber : ${set.reps ?? 0} reps${set.weight != null ? ' x ${set.weight} kg' : ' (PDC)'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (set.isBestSet) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC300),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Record',
                        style: TextStyle(
                          color: Color(0xFFFFC300),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (set.restSeconds != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Repos : ${_formatRestTime(set.restSeconds!)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGETS DE TIMER DE REPOS RAPIDE
// ============================================================================

/// Bottom sheet pour sélectionner rapidement un temps de repos et le lancer
class _QuickRestTimerSheet extends StatefulWidget {
  final Function(int seconds) onSelectAndStart;

  const _QuickRestTimerSheet({required this.onSelectAndStart});

  @override
  State<_QuickRestTimerSheet> createState() => _QuickRestTimerSheetState();
}

class _QuickRestTimerSheetState extends State<_QuickRestTimerSheet> {
  final TextEditingController _customMinController = TextEditingController(text: '1');
  final TextEditingController _customSecController = TextEditingController(text: '30');

  static const List<Map<String, dynamic>> _presets = [
    {'seconds': 30, 'label': '30s', 'color': Colors.green},
    {'seconds': 60, 'label': '1 min', 'color': Colors.blue},
    {'seconds': 90, 'label': '1:30', 'color': Colors.blue},
    {'seconds': 120, 'label': '2 min', 'color': Colors.orange},
    {'seconds': 180, 'label': '3 min', 'color': Colors.red},
  ];

  @override
  void dispose() {
    _customMinController.dispose();
    _customSecController.dispose();
    super.dispose();
  }

  void _startCustomTimer() {
    final min = int.tryParse(_customMinController.text) ?? 0;
    final sec = int.tryParse(_customSecController.text) ?? 0;
    final totalSeconds = (min * 60) + sec;
    if (totalSeconds > 0) {
      widget.onSelectAndStart(totalSeconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timer, color: Color(0xFF007AFF), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timer de repos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Tape sur une durée pour lancer',
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
          const SizedBox(height: 20),
          
          // Presets
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _presets.map((preset) {
              return GestureDetector(
                onTap: () => widget.onSelectAndStart(preset['seconds'] as int),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: (preset['color'] as Color).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: preset['color'] as Color,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: preset['color'] as Color,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preset['label'] as String,
                      style: TextStyle(
                        color: preset['color'] as Color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Custom time input
          Row(
            children: [
              const Text(
                '⏱️  Temps personnalisé :',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Minutes
              SizedBox(
                width: 50,
                height: 40,
                child: TextField(
                  controller: _customMinController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'min',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
              // Seconds
              SizedBox(
                width: 50,
                height: 40,
                child: TextField(
                  controller: _customSecController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  'sec',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              // Start button
              GestureDetector(
                onTap: _startCustomTimer,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.black, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'GO',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet affichant le timer actif
class _ActiveRestTimerSheet extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _ActiveRestTimerSheet({
    required this.initialSeconds,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<_ActiveRestTimerSheet> createState() => _ActiveRestTimerSheetState();
}

class _ActiveRestTimerSheetState extends State<_ActiveRestTimerSheet> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        widget.onComplete();
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _addTime(int seconds) {
    setState(() => _remainingSeconds += seconds);
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  double get _progress => _remainingSeconds / widget.initialSeconds;

  @override
  Widget build(BuildContext context) {
    final isLowTime = _remainingSeconds <= 5 && _remainingSeconds > 0;
    final progressColor = isLowTime ? Colors.red : const Color(0xFF34C759);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer circulaire (taille réduite)
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle de fond
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  // Cercle de progression
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                  // Temps
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          color: isLowTime ? Colors.red : Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        _isPaused ? 'EN PAUSE' : 'REPOS',
                        style: TextStyle(
                          color: _isPaused ? Colors.orange : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Boutons +15s / Pause / -15s
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TimerActionButton(
                  icon: Icons.remove,
                  label: '-15s',
                  onTap: () => _addTime(-15),
                  color: Colors.red,
                ),
                GestureDetector(
                  onTap: _togglePause,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isPaused ? const Color(0xFF34C759) : const Color(0xFFFF9500),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isPaused ? const Color(0xFF34C759) : const Color(0xFFFF9500)).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                _TimerActionButton(
                  icon: Icons.add,
                  label: '+15s',
                  onTap: () => _addTime(15),
                  color: const Color(0xFF34C759),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bouton annuler
            TextButton(
              onPressed: widget.onCancel,
              child: const Text(
                'Annuler le repos',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _TimerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour les préférences de l'exercice
class _PreferencesSheet extends StatefulWidget {
  final String exerciseName;
  final Function(int) onRestTimeChanged;
  final int currentRestTime;

  const _PreferencesSheet({
    required this.exerciseName,
    required this.onRestTimeChanged,
    required this.currentRestTime,
  });

  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<_PreferencesSheet> {
  late int _restTime;
  bool _autoStartTimer = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  String _weightUnit = 'kg';
  int _defaultReps = 12;
  double _incrementWeight = 2.5;
  
  // Rappels
  bool _remindersEnabled = true;
  String _reminderFrequency = 'daily'; // 'minute', 'hourly', 'daily', 'weekly', 'monthly'
  int _reminderValue = 1;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  List<int> _reminderDays = [1, 3, 5]; // Lundi, Mercredi, Vendredi

  @override
  void initState() {
    super.initState();
    _restTime = widget.currentRestTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Color(0xFFFFC300),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Préférences',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.exerciseName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),

          // Contenu scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Temps de repos
                  _buildSectionTitle('⏱️ Temps de repos par défaut'),
                  const SizedBox(height: 12),
                  _buildRestTimeSelector(),
                  const SizedBox(height: 24),

                  // Section Timer
                  _buildSectionTitle('🔔 Timer automatique'),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    'Démarrer auto après série',
                    'Lance le timer automatiquement',
                    _autoStartTimer,
                    (v) => setState(() => _autoStartTimer = v),
                    Icons.play_circle_outline,
                  ),
                  _buildSwitchTile(
                    'Vibration',
                    'Vibre à la fin du repos',
                    _vibrationEnabled,
                    (v) => setState(() => _vibrationEnabled = v),
                    Icons.vibration,
                  ),
                  _buildSwitchTile(
                    'Son',
                    'Alerte sonore à la fin',
                    _soundEnabled,
                    (v) => setState(() => _soundEnabled = v),
                    Icons.volume_up,
                  ),
                  const SizedBox(height: 24),

                  // Section Unités
                  _buildSectionTitle('⚖️ Unités & valeurs'),
                  const SizedBox(height: 12),
                  _buildUnitSelector(),
                  const SizedBox(height: 16),
                  _buildIncrementSelector(),
                  const SizedBox(height: 16),
                  _buildDefaultRepsSelector(),
                  const SizedBox(height: 24),

                  // Section Rappels
                  _buildSectionTitle('🔔 Rappels & Notifications'),
                  const SizedBox(height: 12),
                  _buildRemindersSection(),
                  const SizedBox(height: 24),

                  // Section Objectif
                  _buildSectionTitle('🎯 Objectif personnel'),
                  const SizedBox(height: 12),
                  _buildGoalCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bouton Sauvegarder
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onRestTimeChanged(_restTime);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Préférences sauvegardées'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'SAUVEGARDER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRestTimeSelector() {
    final presets = [30, 60, 90, 120, 180];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: presets.map((seconds) {
        final isSelected = _restTime == seconds;
        final label = seconds < 60
            ? '${seconds}s'
            : seconds == 60
                ? '1 min'
                : '${seconds ~/ 60}m${seconds % 60 > 0 ? ' ${seconds % 60}s' : ''}';
        return GestureDetector(
          onTap: () => setState(() => _restTime = seconds),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFC300) : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFFFC300) : Colors.white12,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFFC300),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.straighten, color: Colors.white54, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Unité de poids',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          ToggleButtons(
            isSelected: [_weightUnit == 'kg', _weightUnit == 'lbs'],
            onPressed: (index) {
              setState(() {
                _weightUnit = index == 0 ? 'kg' : 'lbs';
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.black,
            fillColor: const Color(0xFFFFC300),
            color: Colors.white54,
            constraints: const BoxConstraints(minWidth: 50, minHeight: 36),
            children: const [Text('kg'), Text('lbs')],
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementSelector() {
    final increments = [1.0, 2.5, 5.0, 10.0];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle_outline, color: Colors.white54, size: 22),
              const SizedBox(width: 12),
              Text(
                'Incrément de poids : ${_incrementWeight.toStringAsFixed(1)} $_weightUnit',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: increments.map((inc) {
              final isSelected = _incrementWeight == inc;
              return GestureDetector(
                onTap: () => setState(() => _incrementWeight = inc),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFC300) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFC300) : Colors.white24,
                    ),
                  ),
                  child: Text(
                    '+${inc.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDefaultRepsSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat, color: Colors.white54, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Reps par défaut',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _defaultReps > 1
                    ? () => setState(() => _defaultReps--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.white54,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_defaultReps',
                  style: const TextStyle(
                    color: Color(0xFFFFC300),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _defaultReps++),
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.white54,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection() {
    final frequencies = [
      {'id': 'minute', 'label': 'Minutes', 'icon': '⏱️'},
      {'id': 'hourly', 'label': 'Heures', 'icon': '🕐'},
      {'id': 'daily', 'label': 'Jours', 'icon': '📅'},
      {'id': 'weekly', 'label': 'Semaines', 'icon': '📆'},
      {'id': 'monthly', 'label': 'Mois', 'icon': '🗓️'},
    ];

    final weekDays = [
      {'id': 1, 'label': 'L'},
      {'id': 2, 'label': 'M'},
      {'id': 3, 'label': 'M'},
      {'id': 4, 'label': 'J'},
      {'id': 5, 'label': 'V'},
      {'id': 6, 'label': 'S'},
      {'id': 7, 'label': 'D'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle principal
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _remindersEnabled 
                      ? const Color(0xFFFFC300).withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: _remindersEnabled 
                      ? const Color(0xFFFFC300)
                      : Colors.white54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activer les rappels',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Reçois des notifications pour cet exercice',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _remindersEnabled,
                onChanged: (v) => setState(() => _remindersEnabled = v),
                activeColor: const Color(0xFFFFC300),
              ),
            ],
          ),

          if (_remindersEnabled) ...[
            const SizedBox(height: 20),
            
            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 16),

            // Fréquence
            const Text(
              'Fréquence du rappel',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            
            // Sélecteur de fréquence
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: frequencies.map((freq) {
                  final isSelected = _reminderFrequency == freq['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _reminderFrequency = freq['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFFFFC300)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFFFFC300)
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              freq['icon'] as String,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              freq['label'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),

            // Valeur numérique (Toutes les X ...)
            Row(
              children: [
                const Text(
                  'Toutes les',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_reminderValue > 1) {
                              setState(() => _reminderValue--);
                            }
                          },
                          child: const Center(
                            child: Icon(Icons.remove, color: Colors.white54, size: 18),
                          ),
                        ),
                      ),
                      Text(
                        '$_reminderValue',
                        style: const TextStyle(
                          color: Color(0xFFFFC300),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _reminderValue++),
                          child: const Center(
                            child: Icon(Icons.add, color: Colors.white54, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getFrequencyLabel(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),

            // Heure du rappel (si daily, weekly ou monthly)
            if (_reminderFrequency == 'daily' || 
                _reminderFrequency == 'weekly' || 
                _reminderFrequency == 'monthly') ...[
              const SizedBox(height: 16),
              
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white54, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Heure :',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFFFC300),
                                surface: Color(0xFF1A1A1A),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setState(() => _reminderTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Color(0xFFFFC300),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit, color: Color(0xFFFFC300), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Jours de la semaine (si weekly)
            if (_reminderFrequency == 'weekly') ...[
              const SizedBox(height: 16),
              
              const Text(
                'Jours de rappel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: weekDays.map((day) {
                  final isSelected = _reminderDays.contains(day['id']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _reminderDays.remove(day['id']);
                        } else {
                          _reminderDays.add(day['id'] as int);
                        }
                      });
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFFFC300)
                            : const Color(0xFF1A1A1A),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFFFFC300)
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),
            
            // Résumé du rappel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFFC300), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getReminderSummary(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getFrequencyLabel() {
    switch (_reminderFrequency) {
      case 'minute':
        return _reminderValue == 1 ? 'minute' : 'minutes';
      case 'hourly':
        return _reminderValue == 1 ? 'heure' : 'heures';
      case 'daily':
        return _reminderValue == 1 ? 'jour' : 'jours';
      case 'weekly':
        return _reminderValue == 1 ? 'semaine' : 'semaines';
      case 'monthly':
        return _reminderValue == 1 ? 'mois' : 'mois';
      default:
        return '';
    }
  }

  String _getReminderSummary() {
    final timeStr = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
    
    switch (_reminderFrequency) {
      case 'minute':
        return 'Tu recevras un rappel toutes les $_reminderValue ${_getFrequencyLabel()}.';
      case 'hourly':
        return 'Tu recevras un rappel toutes les $_reminderValue ${_getFrequencyLabel()}.';
      case 'daily':
        if (_reminderValue == 1) {
          return 'Tu recevras un rappel chaque jour à $timeStr.';
        }
        return 'Tu recevras un rappel tous les $_reminderValue jours à $timeStr.';
      case 'weekly':
        final days = _reminderDays.map((d) {
          switch (d) {
            case 1: return 'Lun';
            case 2: return 'Mar';
            case 3: return 'Mer';
            case 4: return 'Jeu';
            case 5: return 'Ven';
            case 6: return 'Sam';
            case 7: return 'Dim';
            default: return '';
          }
        }).join(', ');
        return 'Rappel les $days à $timeStr.';
      case 'monthly':
        return 'Tu recevras un rappel chaque mois à $timeStr.';
      default:
        return '';
    }
  }

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC300).withOpacity(0.15),
            const Color(0xFFFFC300).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: Color(0xFFFFC300)),
              const SizedBox(width: 8),
              const Text(
                'Définir un objectif',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BIENTÔT',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Fixe-toi un objectif de charge, de reps ou de volume sur cet exercice avec une date limite.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGoalChip('🏋️ +10 kg'),
              const SizedBox(width: 8),
              _buildGoalChip('💪 15 reps'),
              const SizedBox(width: 8),
              _buildGoalChip('📈 Volume'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }
}

