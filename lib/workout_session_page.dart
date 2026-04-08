import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'models/workout_session.dart';
import 'models/workout_step.dart';
import 'workout_finished_page.dart';
import 'coach_personality/coach_personality_notifier.dart';
import 'coach_personality/coach_personality_model.dart';
import 'coach_personality/coach_messages.dart';
import 'coach_personality/coach_audio_service.dart';
import 'widgets/coach_voice_bubble.dart';
import 'coach_personality/coach_personality_page.dart';
import 'models/demo_purchase.dart';
import 'data/exercise_name_matcher.dart';
import 'exercises/exercise_detail_page.dart';
import 'data/exercise_data_helper.dart';
import 'models/exercise_library_item.dart';
import 'models/exercise_difficulty_notifier.dart';
import 'components/difficulty_form.dart';
import 'services/difficulty_service.dart';
import 'models/difficulty_entry.dart';

class WorkoutSessionPage extends StatefulWidget {
  final String workoutTitle;
  final List<WorkoutStep> steps;
  final CoachStyle? programCoachStyleOverride; // Style de coach au niveau du programme (optionnel)

  const WorkoutSessionPage({
    super.key,
    required this.workoutTitle,
    required this.steps,
    this.programCoachStyleOverride,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  int _currentStepIndex = 0;
  int? _remainingSeconds;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;
  bool _isRestPhase = false;
  int? _restRemainingSeconds;
  Timer? _restTimer;

  int _completedSteps = 0;
  int _totalDurationSeconds = 0;

  // Coach vocal IA
  late CoachPersonalityNotifier _coachNotifier;
  final CoachAudioService _audioService = CoachAudioService();
  final DemoPurchaseNotifier _purchaseNotifier = DemoPurchaseNotifier();
  final ExerciseDifficultyNotifier _difficultyNotifier = ExerciseDifficultyNotifier();
  Timer? _coachPhraseTimer;
  String? _currentCoachPhrase;
  int _stepStartTime = 0;
  int _stepInitialDuration = 0;

  // Capteur de position
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  bool _isPositionSensorActive = false;
  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;
  String _positionAdvice = '';
  double _postureScore = 0.0;

  @override
  void initState() {
    super.initState();
    _coachNotifier = CoachPersonalityNotifier();
    _coachNotifier.addListener(_onCoachChanged);
    
    // Pour l'exercice de test, activer automatiquement le Coach Drôle si aucun coach n'est sélectionné
    final isTestExercise = widget.workoutTitle.contains('Test') || widget.workoutTitle.contains('🧪');
    if (isTestExercise && _coachNotifier.currentCoach == null) {
      _coachNotifier.selectCoach(CoachStyle.humor);
      _coachNotifier.setEnabled(true);
    }
    
    _initializeStep();
    _calculateTotalDuration();
  }


  void _calculateTotalDuration() {
    int total = 0;
    for (final step in widget.steps) {
      if (step.durationSeconds != null) {
        total += step.durationSeconds!;
      }
      if (step.restSeconds != null) {
        total += step.restSeconds!;
      }
    }
    _totalDurationSeconds = total;
  }

  void _initializeStep() {
    final step = widget.steps[_currentStepIndex];
    setState(() {
      _remainingSeconds = step.durationSeconds;
      _stepInitialDuration = step.durationSeconds ?? 0;
      _stepStartTime = DateTime.now().millisecondsSinceEpoch;
      _isRunning = false;
      _isPaused = false;
      _isRestPhase = false;
      _restRemainingSeconds = null;
      _currentCoachPhrase = null;
    });
    _stopTimers();
    _stopCoachPhraseTimer();
  }

  void _stopTimers() {
    _timer?.cancel();
    _timer = null;
    _restTimer?.cancel();
    _restTimer = null;
    // Arrêter le capteur de position quand on arrête le timer
    if (_isPositionSensorActive) {
      _stopPositionSensor();
    }
  }

  void _startTimer() {
    if (_remainingSeconds == null) return;

    // Marquer l'interaction utilisateur pour permettre l'audio sur le web
    _audioService.markUserInteraction();

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _startCoachPhraseTimer();
    
    // Démarrer le capteur de position si activé
    if (_isPositionSensorActive && _accelerometerSubscription == null) {
      _startPositionSensor();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds! > 0) {
          _remainingSeconds = _remainingSeconds! - 1;
          // La phrase du coach change automatiquement toutes les 15 secondes via _coachPhraseTimer
          // Le système de phases (début/milieu/presque fini/fin) est géré automatiquement 
          // par getPhraseForProgress() selon le progrès actuel
        } else {
          timer.cancel();
          _isRunning = false;
          _stopCoachPhraseTimer();
          _onStepCompleted();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _stopCoachPhraseTimer();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    // Arrêter temporairement le capteur pendant la pause
    if (_isPositionSensorActive) {
      _stopPositionSensor();
    }
  }

  void _resumeTimer() {
    _startTimer();
    
    // Redémarrer le capteur de position si activé
    if (_isPositionSensorActive && _accelerometerSubscription == null) {
      _startPositionSensor();
    }
  }

  void _onStepCompleted() {
    final step = widget.steps[_currentStepIndex];

    // Proposer de noter la difficulté de l'exercice
    _showDifficultyRatingDialog(step);

    // Si l'étape a un temps de repos, lancer la phase de repos
    if (step.restSeconds != null && step.restSeconds! > 0) {
      setState(() {
        _isRestPhase = true;
        _restRemainingSeconds = step.restSeconds;
      });
      _startRestTimer();
    } else {
      _moveToNextStep();
    }
  }

  /// Retourne la couleur selon le niveau de difficulté (0-10)
  Color _getDifficultyColorFromLevel(int level) {
    // 0-3 : Vert (facile)
    // 4-6 : Jaune/Orange (moyen)
    // 7-10 : Rouge (difficile)
    if (level <= 3) {
      return Colors.green;
    } else if (level <= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _showDifficultyRatingDialog(WorkoutStep step) {
    // Essayer de trouver l'exercice correspondant dans la bibliothèque
    final detectedExercises = ExerciseNameMatcher.findExercisesInDescription(step.description);
    ExerciseLibraryItem? exercise;
    String exerciseId = step.id;
    String exerciseName = step.title;

    if (detectedExercises.isNotEmpty) {
      exercise = detectedExercises.first;
      exerciseId = exercise.id;
      exerciseName = exercise.name;
    }

    // Utiliser le nouveau DifficultyForm avec slider
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DifficultyForm(
        exerciseId: exerciseId,
        sessionId: 'workout_${widget.workoutTitle}_${DateTime.now().millisecondsSinceEpoch}',
        onSave: (entry) async {
          // Enregistrer l'évaluation via le service
          await DifficultyService().saveDifficulty(entry);
          // Fermer le dialog immédiatement
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        onCancel: () {
          // Si l'utilisateur annule, fermer le dialog
          Navigator.of(context).pop();
        },
      ),
    );
  }


  void _startRestTimer() {
    if (_restRemainingSeconds == null) return;

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_restRemainingSeconds! > 0) {
          _restRemainingSeconds = _restRemainingSeconds! - 1;
        } else {
          timer.cancel();
          _isRestPhase = false;
          _moveToNextStep();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isRestPhase = false;
      _restRemainingSeconds = null;
    });
    _moveToNextStep();
  }

  void _moveToNextStep() {
    setState(() {
      _completedSteps++;
      _currentStepIndex++;
    });

    if (_currentStepIndex >= widget.steps.length) {
      _finishWorkout();
    } else {
      _initializeStep();
    }
  }

  void _skipCurrentStep() {
    if (_isRestPhase) {
      _skipRest();
    } else {
      _stopTimers();
      _moveToNextStep();
    }
  }

  void _finishWorkout() {
    _stopTimers();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutFinishedPage(
          workoutTitle: widget.workoutTitle,
          totalSteps: widget.steps.length,
          completedSteps: _completedSteps,
          estimatedDurationSeconds: _totalDurationSeconds,
        ),
      ),
    );
  }

  void _confirmStopWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arrêter la séance ?'),
        content: const Text(
          'Tu veux vraiment arrêter cette séance ? Ta progression ne sera pas sauvegardée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _stopTimers();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Arrêter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _onCoachChanged() {
    if (mounted) setState(() {});
  }

  /// Démarre le capteur de position
  void _startPositionSensor() {
    if (_isPositionSensorActive && _accelerometerSubscription != null) return;
    
    // Écouter l'accéléromètre
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (!_isPositionSensorActive || !_isRunning) return;
        
        if (mounted) {
          setState(() {
            _x = event.x;
            _y = event.y;
            _z = event.z;
            _analyzePosture();
          });
        }
      },
      onError: (error) {
        debugPrint('Erreur accéléromètre: $error');
      },
    );

    // Écouter le gyroscope
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        if (!_isPositionSensorActive || !_isRunning) return;
        // Utiliser les données du gyroscope pour une analyse plus précise
      },
      onError: (error) {
        debugPrint('Erreur gyroscope: $error');
      },
    );
  }

  /// Arrête le capteur de position
  void _stopPositionSensor() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    
    if (mounted) {
      setState(() {
        _isPositionSensorActive = false;
        _positionAdvice = '';
        _postureScore = 0.0;
      });
    }
  }

  /// Analyse la posture basée sur les données du capteur
  void _analyzePosture() {
    final magnitude = math.sqrt(_x * _x + _y * _y + _z * _z);
    final step = widget.steps[_currentStepIndex];
    
    // Analyse basée sur la magnitude de l'accélération
    if (magnitude < 9.5) {
      _postureScore = 95.0;
      _positionAdvice = 'Posture excellente ! Continue comme ça.';
    } else if (magnitude < 10.5) {
      _postureScore = 80.0;
      _positionAdvice = 'Posture correcte. Quelques ajustements mineurs possibles.';
    } else if (magnitude < 11.5) {
      _postureScore = 60.0;
      _positionAdvice = 'Redresse légèrement ton dos et garde les épaules alignées.';
    } else {
      _postureScore = 40.0;
      _positionAdvice = 'Attention ! Corrige ta posture. Redresse-toi et contracte les abdos.';
    }

    // Conseils spécifiques selon l'exercice
    final stepTitle = step.title.toLowerCase();
    if (stepTitle.contains('squat') || stepTitle.contains('fente')) {
      if (magnitude > 11.0) {
        _positionAdvice = 'Garde le dos droit et les genoux alignés avec les orteils.';
      }
    } else if (stepTitle.contains('pompe') || stepTitle.contains('planche')) {
      if (magnitude > 11.0) {
        _positionAdvice = 'Garde le corps aligné de la tête aux pieds. Évite de creuser le dos.';
      }
    }

    // Si le coach IA est activé, mettre à jour la phrase avec le conseil de posture
    if (_coachNotifier.isEnabled && _positionAdvice.isNotEmpty && _postureScore < 70) {
      _currentCoachPhrase = _positionAdvice;
      if (mounted) setState(() {});
    }
  }

  /// Toggle le capteur de position
  void _togglePositionSensor() {
    setState(() {
      if (_isPositionSensorActive) {
        _stopPositionSensor();
      } else {
        _isPositionSensorActive = true;
        if (_isRunning) {
          _startPositionSensor();
        }
      }
    });
  }

  void _startCoachPhraseTimer() {
    if (!_coachNotifier.isEnabled || _stepInitialDuration == 0) return;

    _coachPhraseTimer?.cancel();
    
    // Première phrase immédiatement au démarrage
    _updateCoachPhrase();

    // Calculer l'intervalle selon la durée de l'exercice
    // Pour des exercices courts (20-30s), jouer toutes les 5-7 secondes
    // Pour des exercices moyens (30-60s), jouer toutes les 8-10 secondes
    // Pour des exercices longs (60s+), jouer toutes les 12-15 secondes
    int intervalSeconds;
    if (_stepInitialDuration <= 30) {
      intervalSeconds = 5; // Exercices courts : audio toutes les 5 secondes
    } else if (_stepInitialDuration <= 60) {
      intervalSeconds = 8; // Exercices moyens : audio toutes les 8 secondes
    } else {
      intervalSeconds = 12; // Exercices longs : audio toutes les 12 secondes
    }
    
    debugPrint('🎵 Intervalle audio configuré: $intervalSeconds secondes (durée exercice: $_stepInitialDuration s)');

    // Timer périodique avec intervalle adaptatif
    _coachPhraseTimer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      if (!mounted || !_isRunning || !_coachNotifier.isEnabled) {
        timer.cancel();
        return;
      }
      // Forcer la mise à jour de la phrase et jouer un nouvel audio à chaque fois
      _updateCoachPhrase();
    });
  }

  void _stopCoachPhraseTimer() {
    _coachPhraseTimer?.cancel();
    _coachPhraseTimer = null;
    // Arrêter l'audio si en cours
    _audioService.stop();
    setState(() {
      _currentCoachPhrase = null;
    });
  }

  /// Calcule le style de coach effectif selon la hiérarchie :
  /// 1. Style de l'exercice (step.coachStyleOverride)
  /// 2. Style du programme (widget.programCoachStyleOverride)
  /// 3. Style préféré du client (coachNotifier.currentCoach?.style)
  CoachStyle? _getEffectiveCoachStyle() {
    final step = widget.steps[_currentStepIndex];
    
    // 1. Priorité à l'exercice (si défini)
    if (step.coachStyleOverride != null) {
      return step.coachStyleOverride;
    }
    
    // 2. Priorité au programme (si défini)
    if (widget.programCoachStyleOverride != null) {
      return widget.programCoachStyleOverride;
    }
    
    // 3. Sinon, utilise le style préféré du client
    return _coachNotifier.currentCoach?.style;
  }

  void _updateCoachPhrase() {
    final isTestExercise = widget.workoutTitle.contains('Test') || widget.workoutTitle.contains('🧪');
    
    // Pour l'exercice de test, forcer l'activation du coach si nécessaire
    if (isTestExercise && !_coachNotifier.isEnabled) {
      if (_coachNotifier.currentCoach == null) {
        _coachNotifier.selectCoach(CoachStyle.humor);
      }
      _coachNotifier.setEnabled(true);
    }
    
    if (!_coachNotifier.isEnabled || _stepInitialDuration == 0) return;

    final effectiveStyle = _getEffectiveCoachStyle();
    
    // Pour l'exercice de test, utiliser le Coach Drôle par défaut si aucun coach n'est sélectionné
    CoachStyle? styleToUse = effectiveStyle;
    if (effectiveStyle == null && isTestExercise) {
      styleToUse = CoachStyle.humor; // Coach Drôle par défaut pour l'exercice de test
    }
    
    if (styleToUse == null) {
      // Pas de style disponible, utilise le système par défaut
      final elapsed = _stepInitialDuration - (_remainingSeconds ?? _stepInitialDuration);
      final progress = (elapsed / _stepInitialDuration).clamp(0.0, 1.0);
      final phrase = _coachNotifier.getPhraseForProgress(progress);
      if (phrase != null && phrase != _currentCoachPhrase) {
        setState(() {
          _currentCoachPhrase = phrase;
        });
      }
      return;
    }

    // Utilise le style calculé avec la hiérarchie
    final elapsed = _stepInitialDuration - (_remainingSeconds ?? _stepInitialDuration);
    final progress = (elapsed / _stepInitialDuration).clamp(0.0, 1.0);
    
    // Récupérer le coach correspondant au style
    final allCoaches = CoachPersonalityFactory.getAllCoaches();
    final coach = allCoaches.firstWhere(
      (c) => c.style == styleToUse,
      orElse: () => allCoaches.first,
    );
    
    // Utilise directement la méthode du coach pour obtenir une phrase selon le progrès
    // Cette méthode retourne toujours une phrase (4 phases : start, middle, almostDone, end)
    final phrase = coach.getPhraseForProgress(progress);
    if (phrase != null) {
      // Toujours mettre à jour la phrase (même si identique, pour forcer le refresh)
      setState(() {
        _currentCoachPhrase = phrase;
      });
    }

    // Jouer l'audio si la fonctionnalité a été achetée (ou en mode démo pour l'exercice de test)
    // IMPORTANT : Jouer l'audio à chaque appel pour avoir de la variété et un accompagnement continu
    if (_purchaseNotifier.hasCoachVocalIA || isTestExercise) {
      // Jouer un fichier audio aléatoire si disponible
      if (coach.audioPaths.isNotEmpty) {
        // Arrêter l'audio précédent et jouer le nouveau immédiatement
        // Ne pas attendre pour éviter les délais qui réduisent le nombre d'audio sur exercices courts
        _audioService.stop().then((_) {
          // Petit délai pour s'assurer que l'arrêt est bien effectué
          Future.delayed(const Duration(milliseconds: 200), () {
            _audioService.playRandomAudio(coach).catchError((error) {
              debugPrint('Erreur lecture audio coach: $error');
            });
          });
        }).catchError((error) {
          // Si erreur lors de l'arrêt, jouer quand même le nouvel audio
          _audioService.playRandomAudio(coach).catchError((err) {
            debugPrint('Erreur lecture audio coach: $err');
          });
        });
      }
    }
  }

  void _dismissCoachPhrase() {
    setState(() {
      _currentCoachPhrase = null;
    });
    // Réafficher après 3 secondes si le coach est toujours actif
    if (_coachNotifier.isEnabled && _isRunning) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _coachNotifier.isEnabled && _isRunning) {
          _updateCoachPhrase();
        }
      });
    }
  }

  void _toggleCoach() {
    // Toujours ouvrir la page de sélection pour permettre de changer de coach
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CoachPersonalityPage(),
      ),
    ).then((_) {
      // Après sélection, activer automatiquement si un coach a été choisi
      if (_coachNotifier.currentCoach != null) {
        _coachNotifier.setEnabled(true);
        if (_isRunning && _stepInitialDuration > 0) {
          _startCoachPhraseTimer();
        }
      }
    });
  }
  
  void _toggleCoachEnabled() {
    // Activer/désactiver le coach sans changer de coach
    final wasEnabled = _coachNotifier.isEnabled;
    _coachNotifier.setEnabled(!wasEnabled);
    
    if (!wasEnabled) {
      // On active → démarrer le timer si l'exercice est en cours
      if (_isRunning && _stepInitialDuration > 0) {
        _startCoachPhraseTimer();
      }
    } else {
      // On désactive → arrêter le timer et masquer la phrase
      _stopCoachPhraseTimer();
    }
  }

  @override
  void dispose() {
    _stopPositionSensor();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _stopTimers();
    _stopCoachPhraseTimer();
    _coachNotifier.removeListener(_onCoachChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStepIndex >= widget.steps.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final step = widget.steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: Text(widget.workoutTitle),
        centerTitle: true,
        actions: [
          // Icône de difficulté (affiche la difficulté moyenne de l'exercice en cours)
          Builder(
            builder: (context) {
              final step = widget.steps[_currentStepIndex];
              final detectedExercises = ExerciseNameMatcher.findExercisesInDescription(step.description);
              String exerciseId = step.id;
              
              if (detectedExercises.isNotEmpty) {
                exerciseId = detectedExercises.first.id;
              }
              
              return FutureBuilder<List<DifficultyEntry>>(
                future: DifficultyService().getByExercise(exerciseId),
                builder: (context, snapshot) {
                  final difficulties = snapshot.data ?? [];
                  final averageDifficulty = difficulties.isNotEmpty
                      ? (difficulties.map((e) => e.level).reduce((a, b) => a + b) / difficulties.length).round()
                      : null;
                  
                  return IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          color: averageDifficulty != null
                              ? _getDifficultyColorFromLevel(averageDifficulty)
                              : Colors.white70,
                          size: 24,
                        ),
                        if (averageDifficulty != null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: _getDifficultyColorFromLevel(averageDifficulty),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF111111), width: 1),
                              ),
                              child: Text(
                                '$averageDifficulty',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      // Ouvrir le formulaire de difficulté
                      _showDifficultyRatingDialog(step);
                    },
                    tooltip: averageDifficulty != null
                        ? 'Difficulté moyenne: $averageDifficulty/10 - Clique pour modifier'
                        : 'Noter la difficulté',
                  );
                },
              );
            },
          ),
          // Bouton Capteur de position
          IconButton(
            icon: Icon(
              _isPositionSensorActive ? Icons.sensors : Icons.sensors_off,
              color: _isPositionSensorActive ? Colors.green : Colors.white70,
              size: 24,
            ),
            onPressed: _togglePositionSensor,
            tooltip: _isPositionSensorActive
                ? 'Capteur de position activé - Clique pour désactiver'
                : 'Activer le capteur de position',
          ),
          // Bouton Coach IA avec menu contextuel
          Stack(
            children: [
              PopupMenuButton<String>(
                icon: Icon(
                  _coachNotifier.isEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                  color: _coachNotifier.isEnabled ? const Color(0xFFFFC300) : Colors.white70,
                  size: 28,
                ),
                tooltip: _coachNotifier.isEnabled 
                    ? 'Coach IA activé - Menu' 
                    : _coachNotifier.currentCoach == null
                        ? 'Sélectionner un coach IA'
                        : 'Menu Coach IA',
                onSelected: (value) {
                  if (value == 'select') {
                    _toggleCoach(); // Ouvrir la page de sélection
                  } else if (value == 'toggle') {
                    _toggleCoachEnabled(); // Activer/désactiver
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'select',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: _coachNotifier.currentCoach?.color ?? Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        const Text('Choisir un coach'),
                      ],
                    ),
                  ),
                  if (_coachNotifier.currentCoach != null)
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            _coachNotifier.isEnabled 
                                ? Icons.volume_off_rounded 
                                : Icons.volume_up_rounded,
                            size: 20,
                            color: _coachNotifier.currentCoach!.color,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _coachNotifier.isEnabled 
                                ? 'Désactiver le coach' 
                                : 'Activer le coach',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (_coachNotifier.isEnabled && _isRunning)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF111111), width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _confirmStopWorkout,
            tooltip: 'Arrêter la séance',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Indicateur d'étape
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Étape ${_currentStepIndex + 1} / ${widget.steps.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Carte Coach IA (si activé et coach sélectionné)
              if (_coachNotifier.isEnabled && _getEffectiveCoachStyle() != null && !_isRestPhase)
                Builder(
                  builder: (context) {
                    final effectiveStyle = _getEffectiveCoachStyle()!;
                    final coachPersonality = CoachPersonalityFactory.getAllCoaches()
                        .firstWhere((c) => c.style == effectiveStyle);
                    
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            coachPersonality.color.withOpacity(0.15),
                            coachPersonality.color.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: coachPersonality.color.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: coachPersonality.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              coachPersonality.icon,
                              color: coachPersonality.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      coachPersonality.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: coachPersonality.color,
                                      ),
                                    ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'En direct',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentCoachPhrase ?? 'Prêt à t\'accompagner...',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _coachNotifier.isEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: coachPersonality.color,
                          size: 20,
                        ),
                        onPressed: _toggleCoachEnabled,
                        tooltip: _coachNotifier.isEnabled 
                            ? 'Désactiver le coach' 
                            : 'Activer le coach',
                      ),
                    ],
                  ),
                );
                  },
                ),

              // Carte Capteur de position (si activé)
              if (_isPositionSensorActive && !_isRestPhase && _isRunning)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _postureScore >= 80 
                          ? Colors.green.withOpacity(0.5)
                          : _postureScore >= 60
                              ? Colors.orange.withOpacity(0.5)
                              : Colors.red.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _postureScore >= 80 
                              ? Colors.green.withOpacity(0.2)
                              : _postureScore >= 60
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.sensors,
                          color: _postureScore >= 80 
                              ? Colors.green
                              : _postureScore >= 60
                                  ? Colors.orange
                                  : Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Posture: ${_postureScore.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _postureScore >= 80 
                                        ? Colors.green
                                        : _postureScore >= 60
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _postureScore >= 80 
                                        ? Colors.green
                                        : _postureScore >= 60
                                            ? Colors.orange
                                            : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (_positionAdvice.isNotEmpty)
                              Text(
                                _positionAdvice,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Phase de repos ou étape normale
              if (_isRestPhase) ...[
                // Carte repos
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.timer_off,
                        size: 48,
                        color: Color(0xFFFFC300),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Repos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                  ),
                      const SizedBox(height: 8),
                      Text(
                        _restRemainingSeconds != null
                            ? _formatTime(_restRemainingSeconds!)
                            : '0:00',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Reprends ton souffle avant la prochaine étape.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Carte étape normale avec exercices
                Builder(
                  builder: (context) {
                    // Détecter les exercices dans la description
                    final detectedExercises = ExerciseNameMatcher.findExercisesInDescription(step.description);
                    
                    return Column(
                      children: [
                        // Carte titre et description
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      step.title,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (step.durationSeconds != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF4CC),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Chrono',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Sans chrono',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                step.description,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              // Image ou vidéo de l'étape si disponible
                              if (step.imageAsset != null || step.videoUrl != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                    image: step.imageAsset != null
                                        ? DecorationImage(
                                            image: AssetImage(step.imageAsset!),
                                            fit: BoxFit.cover,
                                            onError: (_, __) {},
                                          )
                                        : null,
                                  ),
                                  child: step.imageAsset == null
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                step.videoUrl != null
                                                    ? Icons.play_circle_filled_rounded
                                                    : Icons.fitness_center_rounded,
                                                color: const Color(0xFFFFC300),
                                                size: 48,
                                              ),
                                              if (step.videoUrl != null) ...[
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Vidéo disponible',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        )
                                      : step.videoUrl != null
                                          ? Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                const Center(
                                                  child: Icon(
                                                    Icons.play_circle_filled_rounded,
                                                    color: Colors.white,
                                                    size: 64,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : null,
                                ),
                                if (step.videoUrl != null) ...[
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      // Ouvrir la vidéo YouTube ou locale
                                      // TODO: Implémenter l'ouverture de la vidéo
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Voir la vidéo',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        // Affichage des exercices détectés avec images/vidéos
                        if (detectedExercises.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.fitness_center_rounded, 
                                      size: 20, 
                                      color: Colors.grey.shade700),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Exercices de cette étape',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...detectedExercises.map((exercise) {
                                  return _ExercisePreviewCard(
                                    exercise: exercise,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ExerciseDetailPage(
                                            exerciseLibraryItem: exercise,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Zone timer (si applicable)
                if (step.durationSeconds != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Temps restant',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _remainingSeconds != null
                              ? _formatTime(_remainingSeconds!)
                              : _formatTime(step.durationSeconds!),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFC300),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Pas de durée, fais l\'exercice à ton rythme',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skipCurrentStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black26),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(_isRestPhase ? 'Passer le repos' : 'Passer l\'étape'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (step.durationSeconds == null) {
                          _moveToNextStep();
                        } else if (_isRestPhase) {
                          _skipRest();
                        } else if (!_isRunning && !_isPaused) {
                          _startTimer();
                        } else if (_isRunning) {
                          _pauseTimer();
                        } else if (_isPaused) {
                          _resumeTimer();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (step.durationSeconds != null && _coachNotifier.isEnabled && _getEffectiveCoachStyle() != null && _isRunning)
                            Builder(
                              builder: (context) {
                                final effectiveStyle = _getEffectiveCoachStyle()!;
                                final coachPersonality = CoachPersonalityFactory.getAllCoaches()
                                    .firstWhere((c) => c.style == effectiveStyle);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.mic_rounded,
                                    size: 16,
                                    color: coachPersonality.color,
                                  ),
                                );
                              },
                            ),
                          Text(
                            step.durationSeconds == null
                                ? 'Étape suivante'
                                : _isRestPhase
                                    ? 'Passer le repos'
                                    : !_isRunning && !_isPaused
                                        ? 'Démarrer'
                                        : _isRunning
                                            ? 'Pause'
                                            : 'Reprendre',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
            // Bulle vocale du coach (grande notification en haut)
            if (_currentCoachPhrase != null && 
                _getEffectiveCoachStyle() != null && 
                _coachNotifier.isEnabled &&
                _isRunning &&
                !_isRestPhase)
              Builder(
                builder: (context) {
                  final effectiveStyle = _getEffectiveCoachStyle()!;
                  final coachPersonality = CoachPersonalityFactory.getAllCoaches()
                      .firstWhere((c) => c.style == effectiveStyle);
                  return Positioned(
                    top: 70,
                    left: 16,
                    right: 16,
                    child: CoachVoiceBubble(
                      phrase: _currentCoachPhrase!,
                      coach: coachPersonality,
                      onDismiss: _dismissCoachPhrase,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Carte de prévisualisation d'un exercice avec image/vidéo
class _ExercisePreviewCard extends StatelessWidget {
  final ExerciseLibraryItem exercise;
  final VoidCallback onTap;

  const _ExercisePreviewCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedia = exercise.imageAsset != null || exercise.youtubeUrl != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image ou placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(10),
                    image: exercise.imageAsset != null
                        ? DecorationImage(
                            image: AssetImage(exercise.imageAsset!),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : null,
                  ),
                  child: exercise.imageAsset == null
                      ? Center(
                          child: Icon(
                            exercise.youtubeUrl != null 
                                ? Icons.play_circle_filled_rounded
                                : Icons.fitness_center_rounded,
                            color: const Color(0xFFFFC300),
                            size: 32,
                          ),
                        )
                      : exercise.youtubeUrl != null
                          ? Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const Center(
                                  child: Icon(
                                    Icons.play_circle_filled_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            )
                          : null,
                ),
                const SizedBox(width: 12),
                // Infos exercice
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (exercise.youtubeUrl != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.video_library_rounded, 
                                  size: 14, 
                                  color: Colors.red.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  'Vidéo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          if (exercise.imageAsset != null && exercise.youtubeUrl != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          if (exercise.imageAsset != null || exercise.youtubeUrl == null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image_rounded, 
                                  size: 14, 
                                  color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  'Guide visuel',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bouton voir
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.visibility_rounded, 
                        size: 16, 
                        color: Color(0xFF111111)),
                      SizedBox(width: 6),
                      Text(
                        'Voir',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
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
  }
}



