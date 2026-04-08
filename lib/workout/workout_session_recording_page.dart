import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../models/workout_session_storage.dart';
import '../models/exercise_library_item.dart';
import '../exercises/exercise_library_page.dart';
import 'package:intl/intl.dart';

/// Page d'enregistrement d'une séance d'entraînement en temps réel
class WorkoutSessionRecordingPage extends StatefulWidget {
  final WorkoutSession? initialSession;
  
  const WorkoutSessionRecordingPage({super.key, this.initialSession});

  @override
  State<WorkoutSessionRecordingPage> createState() => _WorkoutSessionRecordingPageState();
}

class _WorkoutSessionRecordingPageState extends State<WorkoutSessionRecordingPage> {
  late WorkoutSession _session;
  final List<ExercisePerformance> _exercises = [];
  ExercisePerformance? _currentExercise;
  ExerciseSet? _currentSet;
  Timer? _sessionTimer;
  Timer? _restTimer;
  int _sessionSeconds = 0;
  int _restSeconds = 0;
  bool _isResting = false;
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSession != null) {
      _session = widget.initialSession!;
      _exercises.addAll(_session.exercises);
      if (_exercises.isNotEmpty) {
        _currentExercise = _exercises.first;
      }
    } else {
      _session = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        exercises: [],
      );
    }
    _startSessionTimer();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    _sessionNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _sessionSeconds++;
        });
      }
    });
  }

  void _startRestTimer(int restSeconds) {
    _restSeconds = restSeconds;
    _isResting = true;
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_restSeconds > 0) {
            _restSeconds--;
          } else {
            _isResting = false;
            timer.cancel();
            _showRestFinished();
          }
        });
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSeconds = 0;
    });
  }

  void _showRestFinished() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Temps de repos terminé !'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Exercices populaires suggérés
  static const List<Map<String, dynamic>> _popularExercises = [
    {'name': 'Développé couché', 'icon': Icons.fitness_center, 'muscle': 'Pectoraux'},
    {'name': 'Squat', 'icon': Icons.accessibility_new, 'muscle': 'Jambes'},
    {'name': 'Soulevé de terre', 'icon': Icons.fitness_center, 'muscle': 'Dos'},
    {'name': 'Tractions', 'icon': Icons.accessibility_new, 'muscle': 'Dos'},
    {'name': 'Curl biceps', 'icon': Icons.fitness_center, 'muscle': 'Biceps'},
    {'name': 'Crunch', 'icon': Icons.accessibility_new, 'muscle': 'Abdos'},
  ];

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Illustration principale
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFC300).withOpacity(0.2),
                  const Color(0xFFFFC300).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 56,
              color: Color(0xFFFFC300),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Prêt à t\'entraîner ? 💪',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoute ton premier exercice pour commencer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Bouton principal
          _buildAddExerciseButton(),
          
          const SizedBox(height: 32),
          
          // Section suggestions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC300).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Color(0xFFFFC300), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'SUGGESTIONS',
                      style: TextStyle(
                        color: Color(0xFFB8860B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addMultipleExercises,
                icon: const Icon(Icons.playlist_add, size: 16),
                label: const Text('Multi-ajout'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Grille d'exercices suggérés
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _popularExercises.length,
            itemBuilder: (context, index) {
              final exercise = _popularExercises[index];
              return _buildSuggestionCard(
                exercise['name'] as String,
                exercise['muscle'] as String,
                exercise['icon'] as IconData,
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Astuce
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Astuce',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Utilise "Multi-ajout" pour sélectionner plusieurs exercices d\'un coup !',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String name, String muscle, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addExerciseByName(name),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC300).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFB8860B), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      muscle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.add_circle, color: const Color(0xFFFFC300), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Ajouter un exercice par nom (suggestion)
  void _addExerciseByName(String exerciseName) {
    setState(() {
      final performance = ExercisePerformance(
        exerciseId: 'suggested_${DateTime.now().millisecondsSinceEpoch}',
        exerciseName: exerciseName,
        sets: [],
        startedAt: DateTime.now(),
      );
      _exercises.add(performance);
      _currentExercise = performance;
      _currentSet = null;
    });
    
    // Feedback visuel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$exerciseName ajouté !',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAddExerciseButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _addExercise,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF111111), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: Color(0xFFFFC300), size: 28),
                SizedBox(width: 12),
                Text(
                  'Ajouter un exercice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addExercise() async {
    // Ouvrir la bibliothèque en mode sélection
    final exercise = await Navigator.of(context).push<ExerciseLibraryItem>(
      MaterialPageRoute(
        builder: (_) => const ExerciseLibraryPage(selectionMode: true),
      ),
    );

    if (exercise != null) {
      setState(() {
        final performance = ExercisePerformance(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          sets: [],
          startedAt: DateTime.now(),
        );
        _exercises.add(performance);
        _currentExercise = performance;
        _currentSet = null;
      });
      
      // Feedback visuel
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${exercise.name} ajouté à la séance !',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Multi-sélection d'exercices
  Future<void> _addMultipleExercises() async {
    final selectedExercises = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MultiSelectExercisesSheet(
        alreadyAdded: _exercises.map((e) => e.exerciseName).toList(),
      ),
    );

    if (selectedExercises != null && selectedExercises.isNotEmpty) {
      setState(() {
        for (final exerciseName in selectedExercises) {
          final performance = ExercisePerformance(
            exerciseId: 'multi_${DateTime.now().millisecondsSinceEpoch}_${selectedExercises.indexOf(exerciseName)}',
            exerciseName: exerciseName,
            sets: [],
            startedAt: DateTime.now(),
          );
          _exercises.add(performance);
        }
        if (_exercises.isNotEmpty) {
          _currentExercise = _exercises.last;
        }
      });
      
      // Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.playlist_add_check, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${selectedExercises.length} exercice${selectedExercises.length > 1 ? 's' : ''} ajouté${selectedExercises.length > 1 ? 's' : ''} !',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _addSet() {
    if (_currentExercise == null) return;

    setState(() {
      final setNumber = _currentExercise!.sets.length + 1;
      _currentSet = ExerciseSet(
        setNumber: setNumber,
        completedAt: DateTime.now(),
      );
      _currentExercise!.sets.add(_currentSet!);
    });
  }

  void _updateSet({
    int? reps,
    double? weight,
    int? restSeconds,
    String? notes,
  }) {
    if (_currentSet == null) return;

    setState(() {
      final index = _currentExercise!.sets.indexOf(_currentSet!);
      _currentExercise!.sets[index] = _currentSet!.copyWith(
        reps: reps,
        weight: weight,
        restSeconds: restSeconds,
        notes: notes,
      );
      _currentSet = _currentExercise!.sets[index];
    });
  }

  void _deleteSet(ExerciseSet set) {
    setState(() {
      _currentExercise!.sets.remove(set);
      // Renuméroter les séries
      for (int i = 0; i < _currentExercise!.sets.length; i++) {
        _currentExercise!.sets[i] = _currentExercise!.sets[i].copyWith(setNumber: i + 1);
      }
      if (_currentExercise!.sets.isEmpty) {
        _currentSet = null;
      } else {
        _currentSet = _currentExercise!.sets.last;
      }
    });
  }

  void _startRest(int restSeconds) {
    if (restSeconds > 0) {
      _startRestTimer(restSeconds);
    }
  }

  Future<void> _finishSession() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un exercice avant de terminer')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la séance'),
        content: const Text('Voulez-vous enregistrer cette séance ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _sessionTimer?.cancel();
      _restTimer?.cancel();

      final session = _session.copyWith(
        name: _sessionNameController.text.isEmpty ? null : _sessionNameController.text,
        endTime: DateTime.now(),
        exercises: _exercises,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // Marquer tous les exercices comme terminés
      final updatedExercises = session.exercises.map((exercise) {
        if (exercise.completedAt == null) {
          return exercise.copyWith(completedAt: session.endTime);
        }
        return exercise;
      }).toList();

      final finalSession = session.copyWith(exercises: updatedExercises);

      try {
        await WorkoutSessionStorage.saveSession(finalSession);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Séance enregistrée avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'enregistrement: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final confirmed = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F0), // Fond crème/gris très clair
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quitter la séance',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Votre progression sera perdue. Continuer ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF111111),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF111111), // Noir
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Quitter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        if (confirmed == true) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          title: const Text('Enregistrement de séance'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _finishSession,
              tooltip: 'Terminer la séance',
            ),
          ],
        ),
        body: Column(
          children: [
            // Chrono de séance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF111111),
              child: Column(
                children: [
                  const Text(
                    'Temps de séance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(_sessionSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Chrono de repos (si actif)
            if (_isResting)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade700,
                child: Column(
                  children: [
                    const Text(
                      'Temps de repos',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(_restSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _stopRestTimer,
                      child: const Text('Arrêter le repos', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            // Nom de la séance (optionnel)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _sessionNameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la séance (optionnel)',
                  hintText: 'Ex: Push Day, Jambes...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            // Liste des exercices
            Expanded(
              child: _exercises.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _exercises.length + 1, // +1 pour le bouton ajouter
                      itemBuilder: (context, index) {
                        if (index == _exercises.length) {
                          // Bouton ajouter en bas de la liste
                          return _buildAddExerciseButton();
                        }
                        final exercise = _exercises[index];
                        final isCurrent = exercise == _currentExercise;
                        return _ExerciseCard(
                          exercise: exercise,
                          isCurrent: isCurrent,
                          currentSet: isCurrent ? _currentSet : null,
                          onTap: () {
                            setState(() {
                              _currentExercise = exercise;
                              _currentSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
                            });
                          },
                          onAddSet: () {
                            setState(() {
                              _currentExercise = exercise;
                            });
                            _addSet();
                          },
                          onUpdateSet: _updateSet,
                          onDeleteSet: _deleteSet,
                          onStartRest: _startRest,
                          formatTime: _formatTime,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher un exercice avec ses séries
class _ExerciseCard extends StatelessWidget {
  final ExercisePerformance exercise;
  final bool isCurrent;
  final ExerciseSet? currentSet;
  final VoidCallback onTap;
  final VoidCallback onAddSet;
  final Function({int? reps, double? weight, int? restSeconds, String? notes}) onUpdateSet;
  final Function(ExerciseSet) onDeleteSet;
  final Function(int) onStartRest;
  final String Function(int) formatTime;

  const _ExerciseCard({
    required this.exercise,
    required this.isCurrent,
    required this.currentSet,
    required this.onTap,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onDeleteSet,
    required this.onStartRest,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrent ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent ? const Color(0xFF111111) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exercise.exerciseName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? const Color(0xFF111111) : Colors.black87,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ACTIF',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Liste des séries
              if (exercise.sets.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Aucune série enregistrée',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                )
              else
                ...exercise.sets.map((set) => _SetRow(
                      set: set,
                      isCurrent: set == currentSet,
                      onUpdate: onUpdateSet,
                      onDelete: () => onDeleteSet(set),
                      onStartRest: onStartRest,
                      formatTime: formatTime,
                    )),
              const SizedBox(height: 8),
              // Bouton ajouter série
              ElevatedButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Ajouter une série'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour afficher une série avec édition
class _SetRow extends StatefulWidget {
  final ExerciseSet set;
  final bool isCurrent;
  final Function({int? reps, double? weight, int? restSeconds, String? notes}) onUpdate;
  final VoidCallback onDelete;
  final Function(int) onStartRest;
  final String Function(int) formatTime;

  const _SetRow({
    required this.set,
    required this.isCurrent,
    required this.onUpdate,
    required this.onDelete,
    required this.onStartRest,
    required this.formatTime,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _restController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: widget.set.reps?.toString() ?? '');
    _weightController = TextEditingController(text: widget.set.weight?.toString() ?? '');
    _restController = TextEditingController(text: widget.set.restSeconds?.toString() ?? '');
    _notesController = TextEditingController(text: widget.set.notes ?? '');
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateField() {
    widget.onUpdate(
      reps: _repsController.text.isEmpty ? null : int.tryParse(_repsController.text),
      weight: _weightController.text.isEmpty ? null : double.tryParse(_weightController.text.replaceAll(',', '.')),
      restSeconds: _restController.text.isEmpty ? null : int.tryParse(_restController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isCurrent ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isCurrent ? const Color(0xFF111111) : Colors.grey.shade300,
          width: widget.isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Série ${widget.set.setNumber}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red,
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repsController,
                  decoration: const InputDecoration(
                    labelText: 'Répétitions',
                    hintText: '12',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _updateField(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Charge (kg)',
                    hintText: '20',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _updateField(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _restController,
                  decoration: const InputDecoration(
                    labelText: 'Repos (sec)',
                    hintText: '60',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) {
                    _updateField();
                    setState(() {}); // Pour mettre à jour l'affichage du bouton
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (_restController.text.isNotEmpty && int.tryParse(_restController.text) != null)
                ElevatedButton(
                  onPressed: () {
                    final restSeconds = int.tryParse(_restController.text);
                    if (restSeconds != null && restSeconds > 0) {
                      widget.onStartRest(restSeconds);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Démarrer repos'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optionnel)',
              hintText: 'Ex: Forme correcte',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
            onChanged: (_) => _updateField(),
          ),
        ],
      ),
    );
  }
}

// ============ BOTTOM SHEET MULTI-SÉLECTION ============

class _MultiSelectExercisesSheet extends StatefulWidget {
  final List<String> alreadyAdded;
  
  const _MultiSelectExercisesSheet({required this.alreadyAdded});

  @override
  State<_MultiSelectExercisesSheet> createState() => _MultiSelectExercisesSheetState();
}

class _MultiSelectExercisesSheetState extends State<_MultiSelectExercisesSheet> {
  final Set<String> _selected = {};
  String _searchQuery = '';
  
  // Liste d'exercices par catégorie
  static const Map<String, List<String>> _exercisesByCategory = {
    'Pectoraux': [
      'Développé couché',
      'Développé incliné',
      'Écarté haltères',
      'Dips',
      'Push-ups',
      'Pec deck',
    ],
    'Dos': [
      'Tractions',
      'Rowing barre',
      'Tirage vertical',
      'Tirage horizontal',
      'Soulevé de terre',
      'Pull-over',
    ],
    'Épaules': [
      'Développé militaire',
      'Élévations latérales',
      'Élévations frontales',
      'Oiseau',
      'Face pull',
      'Shrugs',
    ],
    'Bras': [
      'Curl biceps',
      'Curl marteau',
      'Curl concentré',
      'Extension triceps',
      'Dips triceps',
      'Kickback',
    ],
    'Jambes': [
      'Squat',
      'Presse à cuisses',
      'Leg extension',
      'Leg curl',
      'Fentes',
      'Mollets debout',
    ],
    'Abdominaux': [
      'Crunch',
      'Relevé de jambes',
      'Planche',
      'Russian twist',
      'Ab wheel',
      'Gainage latéral',
    ],
  };

  List<MapEntry<String, String>> get _filteredExercises {
    final result = <MapEntry<String, String>>[];
    for (final category in _exercisesByCategory.entries) {
      for (final exercise in category.value) {
        if (!widget.alreadyAdded.contains(exercise)) {
          if (_searchQuery.isEmpty ||
              exercise.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              category.key.toLowerCase().contains(_searchQuery.toLowerCase())) {
            result.add(MapEntry(category.key, exercise));
          }
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // En-tête
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.playlist_add, color: Color(0xFFFFC300), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Multi-sélection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_selected.length} sélectionné${_selected.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _selected.clear()),
                    child: const Text('Tout effacer', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          
          // Liste des exercices
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Text(
                      'Aucun exercice trouvé',
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final entry = exercises[index];
                      final category = entry.key;
                      final exercise = entry.value;
                      final isSelected = _selected.contains(exercise);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selected.remove(exercise);
                                } else {
                                  _selected.add(exercise);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFC300).withOpacity(0.15)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFFC300)
                                      : Colors.white.withOpacity(0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFFC300)
                                          : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isSelected ? Icons.check : Icons.fitness_center,
                                      color: isSelected ? Colors.black : Colors.white.withOpacity(0.6),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise,
                                          style: TextStyle(
                                            color: isSelected ? const Color(0xFFFFC300) : Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          category,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Bouton de validation
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _selected.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(_selected.toList()),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      _selected.isEmpty
                          ? 'Sélectionner'
                          : 'Ajouter ${_selected.length} exercice${_selected.length > 1 ? 's' : ''}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade700,
                      disabledForegroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
}

