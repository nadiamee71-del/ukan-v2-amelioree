/// Page d'exécution d'une séance d'entraînement
/// Avec chronomètres prédéfinis, bouton GO, et indicateurs de progression

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_program.dart';
import '../widgets/difficulty_rating_dialog.dart';

class WorkoutExecutionPage extends StatefulWidget {
  final WorkoutProgram program;
  final ProgramDay day;

  const WorkoutExecutionPage({
    super.key,
    required this.program,
    required this.day,
  });

  @override
  State<WorkoutExecutionPage> createState() => _WorkoutExecutionPageState();
}

class _WorkoutExecutionPageState extends State<WorkoutExecutionPage>
    with TickerProviderStateMixin {
  // État de la séance
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _isResting = false;
  bool _isWorkoutStarted = false;
  bool _isWorkoutFinished = false;
  
  // Difficultés enregistrées par exercice
  final Map<int, double> _exerciseDifficulties = {};
  final Map<int, String> _exerciseNotes = {};

  // Timer
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalRestSeconds = 90; // Par défaut 1min30
  bool _isTimerRunning = false;

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Chronomètres prédéfinis
  final List<int> _presetTimers = [30, 60, 90, 120, 180]; // en secondes

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  ProgramExercise get _currentExercise =>
      widget.day.exercises[_currentExerciseIndex];

  int get _totalExercises => widget.day.exercises.length;

  int get _totalSets => _currentExercise.targetSets ?? 1;

  double get _overallProgress {
    int totalSets = 0;
    int completedSets = 0;

    for (int i = 0; i < widget.day.exercises.length; i++) {
      final sets = widget.day.exercises[i].targetSets ?? 1;
      totalSets += sets;
      if (i < _currentExerciseIndex) {
        completedSets += sets;
      } else if (i == _currentExerciseIndex) {
        completedSets += _currentSetIndex;
      }
    }

    return totalSets > 0 ? completedSets / totalSets : 0;
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutStarted = true;
    });
    HapticFeedback.heavyImpact();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = seconds;
      _totalRestSeconds = seconds;
      _isTimerRunning = true;
      _isResting = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        // Vibration aux dernières secondes
        if (_remainingSeconds <= 3 && _remainingSeconds > 0) {
          HapticFeedback.lightImpact();
        }
      } else {
        _onTimerComplete();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _isResting = false;
    });
    HapticFeedback.heavyImpact();
    _showTimerCompleteDialog();
  }

  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_off,
              color: Color(0xFFFFC300),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '⏰ REPOS TERMINÉ !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prêt pour la série ${_currentSetIndex + 1} ?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'C\'EST PARTI ! 💪',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeSet() {
    HapticFeedback.mediumImpact();

    if (_currentSetIndex < _totalSets - 1) {
      // Encore des séries à faire
      setState(() {
        _currentSetIndex++;
      });
      // Démarrer le repos automatiquement
      _startTimer(_totalRestSeconds);
    } else {
      // Toutes les séries terminées pour cet exercice
      _completeExercise();
    }
  }

  void _completeExercise() async {
    // Notification de fin d'exercice avec vibration forte
    HapticFeedback.heavyImpact();
    
    // Afficher une notification visuelle avant le popup
    _showDifficultyNotification();
    
    // Attendre un peu pour la notification
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Afficher le popup de difficulté
    final result = await DifficultyRatingDialog.show(
      context,
      exerciseName: _currentExercise.exerciseName,
    );
    
    // Stocker la difficulté et la note
    if (result != null) {
      _exerciseDifficulties[_currentExerciseIndex] = result.difficulty;
      if (result.note != null) {
        _exerciseNotes[_currentExerciseIndex] = result.note!;
      }
      
      // Notification de confirmation
      HapticFeedback.mediumImpact();
      _showDifficultySavedNotification(result.difficulty);
    }
    
    if (_currentExerciseIndex < _totalExercises - 1) {
      // Passer à l'exercice suivant
      setState(() {
        _currentExerciseIndex++;
        _currentSetIndex = 0;
      });
      _showExerciseCompleteDialog();
    } else {
      // Séance terminée !
      _completeWorkout();
    }
  }
  
  void _showDifficultyNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.speed, color: Color(0xFFFFC300)),
            const SizedBox(width: 12),
            const Text(
              'Évaluez la difficulté de l\'exercice !',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  void _showDifficultySavedNotification(double difficulty) {
    final color = difficulty <= 4 ? Colors.green : 
                  difficulty <= 7 ? Colors.orange : Colors.red;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: color),
            const SizedBox(width: 12),
            Text(
              'Difficulté ${difficulty.toInt()}/10 enregistrée ✓',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showExerciseCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '✅ EXERCICE TERMINÉ !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prochain : ${_currentExercise.exerciseName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CONTINUER →',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeWorkout() {
    setState(() {
      _isWorkoutFinished = true;
    });
    HapticFeedback.heavyImpact();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
          widget.day.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isWorkoutStarted && !_isWorkoutFinished)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitConfirmation(),
            ),
        ],
      ),
      body: SafeArea(
        child: _isWorkoutFinished
            ? _buildWorkoutComplete()
            : _isWorkoutStarted
                ? _buildWorkoutInProgress()
                : _buildWorkoutStart(),
      ),
    );
  }

  Widget _buildWorkoutStart() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // En-tête du programme
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFC300).withOpacity(0.2),
                  const Color(0xFFFFC300).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.program.name,
                  style: const TextStyle(
                    color: Color(0xFFFFC300),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.day.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _InfoChip(
                      icon: Icons.fitness_center,
                      label: '${widget.day.exercises.length} exercices',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.repeat,
                      label: '${_calculateTotalSets()} séries',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Liste des exercices
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '📋 Programme de la séance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          ...widget.day.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return _ExercisePreviewCard(
              index: index + 1,
              exercise: exercise,
            );
          }),

          const SizedBox(height: 32),

          // Bouton GO
          ScaleTransition(
            scale: _pulseAnimation,
            child: SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                onPressed: _startWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFFFFC300).withOpacity(0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 36),
                    SizedBox(width: 12),
                    Text(
                      'COMMENCER',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWorkoutInProgress() {
    return Column(
      children: [
        // Barre de progression globale
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1A1A1A),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${(_overallProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFFFFC300),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _overallProgress,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFFFC300)),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Exercice ${_currentExerciseIndex + 1}/$_totalExercises',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Contenu principal
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Exercice actuel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFC300).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Nom de l'exercice
                      Text(
                        _currentExercise.exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Série actuelle
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC300).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Série ${_currentSetIndex + 1} / $_totalSets',
                          style: const TextStyle(
                            color: Color(0xFFFFC300),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Objectif
                      Text(
                        _currentExercise.targetDescription,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),

                      if (_currentExercise.notes != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _currentExercise.notes!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Timer de repos
                if (_isResting) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '😴 REPOS',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _totalRestSeconds > 0
                                ? _remainingSeconds / _totalRestSeconds
                                : 0,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.orange),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _stopTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.3),
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('STOP'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                _stopTimer();
                                setState(() => _isResting = false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('PASSER →'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Chronomètres prédéfinis
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '⏱️ Chronomètre repos',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetTimers.map((seconds) {
                      final label = seconds < 60
                          ? '${seconds}s'
                          : seconds == 60
                              ? '1min'
                              : '${seconds ~/ 60}m${seconds % 60 > 0 ? '${seconds % 60}s' : ''}';
                      return _TimerButton(
                        label: label,
                        onTap: () => _startTimer(seconds),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Indicateur de difficulté à venir (dernière série)
                if (!_isResting && _currentSetIndex == _totalSets - 1)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.orange, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🔔 Dernière série !',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Évaluation de difficulté après cette série',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bouton série terminée
                if (!_isResting)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: _completeSet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentSetIndex == _totalSets - 1 
                                ? const Color(0xFFFFC300) 
                                : Colors.green,
                            foregroundColor: _currentSetIndex == _totalSets - 1 
                                ? Colors.black 
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _currentSetIndex == _totalSets - 1 
                                    ? Icons.speed 
                                    : Icons.check, 
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _currentSetIndex == _totalSets - 1 
                                    ? 'TERMINER & ÉVALUER 🔔' 
                                    : 'SÉRIE TERMINÉE ✓',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutComplete() {
    // Calculer la difficulté moyenne
    double? avgDifficulty;
    if (_exerciseDifficulties.isNotEmpty) {
      avgDifficulty = _exerciseDifficulties.values.reduce((a, b) => a + b) / 
                      _exerciseDifficulties.length;
    }
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFC300),
              size: 100,
            ),
            const SizedBox(height: 24),
            const Text(
              '🎉 SÉANCE TERMINÉE !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.day.name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _StatRow(
                    icon: Icons.fitness_center,
                    label: 'Exercices',
                    value: '${widget.day.exercises.length}',
                  ),
                  const Divider(color: Colors.white12),
                  _StatRow(
                    icon: Icons.repeat,
                    label: 'Séries totales',
                    value: '${_calculateTotalSets()}',
                  ),
                  if (avgDifficulty != null) ...[
                    const Divider(color: Colors.white12),
                    _StatRow(
                      icon: Icons.speed,
                      label: 'Difficulté moyenne',
                      value: '${avgDifficulty.toStringAsFixed(1)}/10',
                    ),
                  ],
                ],
              ),
            ),
            
            // Résumé des difficultés par exercice
            if (_exerciseDifficulties.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Difficulté par exercice',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.day.exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      final diff = _exerciseDifficulties[index];
                      final note = _exerciseNotes[index];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    exercise.exerciseName,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _DifficultyIndicator(difficulty: diff),
                              ],
                            ),
                            if (note != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      note,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'TERMINER',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalSets() {
    return widget.day.exercises.fold(0, (sum, e) => sum + (e.targetSets ?? 1));
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Quitter la séance ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Ta progression ne sera pas sauvegardée.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CONTINUER'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('QUITTER'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS AUXILIAIRES
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExercisePreviewCard extends StatelessWidget {
  final int index;
  final ProgramExercise exercise;

  const _ExercisePreviewCard({
    required this.index,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Color(0xFFFFC300),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.targetDescription,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
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

class _TimerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC300), size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyIndicator extends StatelessWidget {
  final double? difficulty;

  const _DifficultyIndicator({this.difficulty});

  Color _getColor(double value) {
    if (value <= 2) return Colors.green;
    if (value <= 4) return Colors.lightGreen;
    if (value <= 6) return Colors.yellow;
    if (value <= 8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (difficulty == null) {
      return Text(
        '-',
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 12,
        ),
      );
    }

    final color = _getColor(difficulty!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${difficulty!.toInt()}/10',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

