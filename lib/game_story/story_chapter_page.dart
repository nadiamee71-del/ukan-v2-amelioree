import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/game_story.dart';
import '../workout_session_page.dart';
import '../models/workout_step.dart';
import '../data/demo_exercises.dart';
import '../coach_personality/coach_personality_notifier.dart';
import '../coach_personality/coach_personality_model.dart';
import '../coach_personality/coach_audio_service.dart';
import 'story_home.dart';

/// ─────────────────────────────────────────────────────────────
/// STORY CHAPTER PAGE - Design Immersif Gaming
/// Page détaillée d'un chapitre avec missions et progression
/// ─────────────────────────────────────────────────────────────

// Palette de couleurs Gaming Immersif
const Color _primaryGold = Color(0xFFFFD700);
const Color _accentOrange = Color(0xFFFF6B35);
const Color _deepPurple = Color(0xFF1A0A2E);
const Color _darkBg = Color(0xFF0D0D1A);
const Color _cardBg = Color(0xFF1E1E3F);
const Color _cardBgLight = Color(0xFF2A2A4F);
const Color _successGreen = Color(0xFF00E676);
const Color _warningRed = Color(0xFFFF4757);
const Color _cyanAccent = Color(0xFF00D9FF);

class StoryChapterPage extends StatefulWidget {
  final StoryChapter chapter;

  const StoryChapterPage({
    super.key,
    required this.chapter,
  });

  @override
  State<StoryChapterPage> createState() => _StoryChapterPageState();
}

class _StoryChapterPageState extends State<StoryChapterPage>
    with TickerProviderStateMixin {
  final _gameNotifier = GameStoryNotifier();
  int _currentProgress = 0;
  bool _isActive = false;
  Timer? _timer;
  Timer? _simulationTimer;
  Timer? _autoRepTimer;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  int _pauseCount = 0;
  
  int _remainingSeconds = 30;
  bool _isCountdown = false;
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _lastAcceleration = 0.0;
  DateTime? _lastSquatTime;
  bool _autoDetectionEnabled = false;
  
  late CoachPersonalityNotifier _coachNotifier;
  final CoachAudioService _audioService = CoachAudioService();
  Timer? _coachPhraseTimer;
  String? _currentCoachPhrase;
  
  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _imageAnimationController;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _imageFadeAnimation;
  late AnimationController _unlockAnimationController;
  late Animation<double> _unlockScaleAnimation;
  
  String? _lastImagePath;
  bool _bossDefeatedShown = false;
  bool _nextStoryUnlocked = false;

  @override
  void initState() {
    super.initState();
    _gameNotifier.addListener(_onGameChanged);
    
    _coachNotifier = CoachPersonalityNotifier();
    _coachNotifier.addListener(_onCoachChanged);
    _coachNotifier.setEnabled(false);
    
    // Configuration selon le chapitre
    if (widget.chapter.id == 'story1') {
      _currentProgress = 0;
      _remainingSeconds = 30;
      _isCountdown = true;
    } else if (widget.chapter.id == 'boss_legs') {
      _currentProgress = 0;
      _isCountdown = false;
    } else {
      _currentProgress = 0;
      _isCountdown = false;
    }
    
    // Initialiser les animations
    _initAnimations();
    
    // Démarrer automatiquement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isActive) {
        _startTimer();
      }
    });
    
    _lastImagePath = _getChapterImage(widget.chapter, _currentProgress / widget.chapter.boss.targetValue);
    _imageAnimationController.forward();
  }

  void _initAnimations() {
    // Pulsation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Glow
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    
    // Image animation
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _imageScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _imageAnimationController, curve: Curves.easeOutCubic),
    );
    _imageFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _imageAnimationController, curve: Curves.easeIn),
    );
    
    // Unlock animation
    _unlockAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _unlockScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _unlockAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _simulationTimer?.cancel();
    _autoRepTimer?.cancel();
    _coachPhraseTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _audioService.stop();
    _gameNotifier.removeListener(_onGameChanged);
    _coachNotifier.removeListener(_onCoachChanged);
    _pulseController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _imageAnimationController.dispose();
    _unlockAnimationController.dispose();
    super.dispose();
  }
  
  void _onCoachChanged() {
    if (mounted) setState(() {});
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  // ═══════════════════════════════════════════════════════════
  // TIMER & PROGRESS LOGIC
  // ═══════════════════════════════════════════════════════════

  void _startTimer() {
    final chapter = widget.chapter;
    final targetValue = chapter.boss.targetValue;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isActive = true;
      _startTime = DateTime.now();
      _elapsedTime = Duration.zero;
    });

    if (chapter.id == 'story1' && _isCountdown) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
            _onTimerFinished(chapter);
          }
        });
      });
      _startAutoRepTimer(targetValue);
      if (_coachNotifier.isEnabled) {
        _startCoachPhraseTimer();
      }
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _startTime != null) {
          setState(() {
            _elapsedTime = DateTime.now().difference(_startTime!);
          });
        }
      });
      _startAutoRepTimer(targetValue);
      if (chapter.id == 'boss_legs' && !_autoDetectionEnabled) {
        _startAutoSquatDetection();
      }
      if (_coachNotifier.isEnabled) {
        _startCoachPhraseTimer();
      }
    }
  }
  
  void _startAutoRepTimer(int targetValue) {
    _autoRepTimer?.cancel();
    final chapter = widget.chapter;
    
    int intervalSeconds;
    int increment;
    
    switch (chapter.id) {
      case 'story1':
        intervalSeconds = 6;
        increment = 1;
        break;
      case 'story2':
        intervalSeconds = 2;
        increment = 1;
        break;
      case 'story3':
        intervalSeconds = 3;
        increment = 50;
        break;
      case 'story4':
        intervalSeconds = 2;
        increment = 100;
        break;
      case 'story5':
        intervalSeconds = 1;
        increment = targetValue;
        break;
      case 'boss_legs':
        intervalSeconds = 2;
        increment = 1;
        break;
      default:
        intervalSeconds = 2;
        increment = 1;
    }
    
    _autoRepTimer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      if (!mounted || !_isActive) {
        timer.cancel();
        return;
      }
      
      if (_currentProgress < targetValue) {
        setState(() {
          _currentProgress = (_currentProgress + increment).clamp(0, targetValue);
        });
        
        // Animation de progression
        _progressController.forward(from: 0.0);
        
        final newImagePath = _getChapterImage(chapter, _currentProgress / targetValue);
        if (newImagePath != _lastImagePath) {
          _lastImagePath = newImagePath;
          _imageAnimationController.forward(from: 0.0);
        }
        
        if (_currentProgress >= targetValue) {
          timer.cancel();
          _autoRepTimer = null;
          _timer?.cancel();
          _onMissionCompleted();
        } else {
          _checkMissionProgress();
        }
      } else {
        timer.cancel();
        _autoRepTimer = null;
        _onMissionCompleted();
      }
    });
  }
  
  void _onMissionCompleted() {
    final chapter = widget.chapter;
    final boss = chapter.boss;
    
    HapticFeedback.heavyImpact();
    
    _timer?.cancel();
    _autoRepTimer?.cancel();
    _coachPhraseTimer?.cancel();
    
    setState(() {
      _isActive = false;
      _currentProgress = boss.targetValue;
    });
    
    _checkBossDefeat();
  }
  
  void _unlockNextChapter(StoryChapter currentChapter) {
    for (final mission in currentChapter.missions) {
      if (mission.status != MissionStatus.completed) {
        _gameNotifier.updateChapterMission(currentChapter.id, mission.id, MissionStatus.completed);
      }
    }
    
    Future.delayed(const Duration(milliseconds: 50), () {
      final updatedChapter = _gameNotifier.chapters.firstWhere(
        (c) => c.id == currentChapter.id,
        orElse: () => currentChapter,
      );
      
      if (updatedChapter.missions.isNotEmpty) {
        final lastMission = updatedChapter.missions.last;
        _gameNotifier.completeMissionFromWorkout(
          storyId: updatedChapter.id,
          missionId: lastMission.id,
          targetValue: updatedChapter.boss.targetValue,
        );
      }
    });
  }
  
  void _startCoachPhraseTimer() {
    if (!_coachNotifier.isEnabled) return;
    
    _coachPhraseTimer?.cancel();
    final progress = _currentProgress / widget.chapter.boss.targetValue;
    _updateCoachPhrase(progress);
    
    _coachPhraseTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_isActive || !_coachNotifier.isEnabled) {
        timer.cancel();
        return;
      }
      final currentProgress = _currentProgress / widget.chapter.boss.targetValue;
      _updateCoachPhrase(currentProgress);
    });
  }
  
  void _updateCoachPhrase(double progress) {
    if (!_coachNotifier.isEnabled) return;
    
    final phrase = _coachNotifier.getPhraseForProgress(progress);
    if (phrase != null && phrase != _currentCoachPhrase) {
      setState(() {
        _currentCoachPhrase = phrase;
      });
      
      final coach = _coachNotifier.currentCoach;
      if (coach != null && coach.audioPaths.isNotEmpty) {
        _audioService.stop().then((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _audioService.playRandomAudio(coach).catchError((error) {
              debugPrint('Erreur lecture audio coach: $error');
            });
          });
        });
      }
    }
  }
  
  void _onTimerFinished(StoryChapter chapter) {
    if (chapter.id != 'story1') return;
    if (_currentProgress < chapter.boss.targetValue) {
      setState(() {
        _currentProgress = chapter.boss.targetValue;
      });
      _onMissionCompleted();
    }
  }
  
  void _startAutoSquatDetection() {
    if (_autoDetectionEnabled) return;
    
    _autoDetectionEnabled = true;
    _lastAcceleration = 0.0;
    _lastSquatTime = null;
    
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          if (!_isActive || !mounted) return;
          
          final acceleration = math.sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z
          );
          
          final now = DateTime.now();
          const double squatThreshold = 2.5;
          const int minSquatInterval = 1500;
          
          final accelerationDelta = (acceleration - _lastAcceleration).abs();
          
          if (accelerationDelta > squatThreshold) {
            if (_lastSquatTime == null || 
                now.difference(_lastSquatTime!).inMilliseconds > minSquatInterval) {
              _lastSquatTime = now;
              _addRep();
            }
          }
          _lastAcceleration = acceleration;
        },
        onError: (error) {
          debugPrint('Erreur accéléromètre: $error');
          _startSimulatedSquats();
        },
      );
    } catch (e) {
      debugPrint('Impossible de démarrer la détection automatique: $e');
      _startSimulatedSquats();
    }
  }
  
  void _startSimulatedSquats() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isActive || !mounted) {
        timer.cancel();
        return;
      }
      _addRep();
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    setState(() {
      _isActive = false;
      _pauseCount++;
    });
    _timer?.cancel();
    _simulationTimer?.cancel();
    _autoRepTimer?.cancel();
    _coachPhraseTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _autoDetectionEnabled = false;
    _checkMissionProgress();
  }

  void _resetTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isActive = false;
      _startTime = null;
      _elapsedTime = Duration.zero;
      _currentProgress = 0;
      if (_isCountdown) {
        _remainingSeconds = 30;
      }
    });
    _timer?.cancel();
    _simulationTimer?.cancel();
    _autoRepTimer?.cancel();
    _coachPhraseTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _autoDetectionEnabled = false;
    _bossDefeatedShown = false;
    _nextStoryUnlocked = false;
  }

  void _launchExercise(String exerciseId, String exerciseName, int durationSeconds) {
    final exercise = DemoExercises.getExerciseById(exerciseId);
    if (exercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercice $exerciseId non trouvé'),
          backgroundColor: _warningRed,
        ),
      );
      return;
    }

    final steps = [
      WorkoutStep(
        id: exerciseId,
        title: exerciseName,
        description: exercise.description,
        durationSeconds: durationSeconds,
        restSeconds: 0,
        imageAsset: exercise.imageAsset,
      ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutSessionPage(
          workoutTitle: exerciseName,
          steps: steps,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _currentProgress = (_currentProgress + 1).clamp(0, widget.chapter.boss.targetValue);
        });
        _checkMissionProgress();
        _checkBossDefeat();
      }
    });
  }

  void _addRep() {
    final chapter = widget.chapter;
    final boss = chapter.boss;
    
    final needsTimer = chapter.id == 'story1' || chapter.id == 'boss_legs';
    
    if (needsTimer && !_isActive && !_autoDetectionEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Démarre le chrono d\'abord !'),
          backgroundColor: _accentOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    int increment = 1;
    if (chapter.id == 'story3') {
      increment = 50;
    } else if (chapter.id == 'story4') {
      increment = 100;
    } else if (chapter.id == 'story5') {
      increment = boss.targetValue;
    }

    HapticFeedback.selectionClick();
    
    setState(() {
      _currentProgress = (_currentProgress + increment).clamp(0, boss.targetValue);
    });

    _progressController.forward(from: 0.0);

    final newImagePath = _getChapterImage(widget.chapter, _currentProgress / boss.targetValue);
    if (newImagePath != _lastImagePath) {
      _lastImagePath = newImagePath;
      _imageAnimationController.forward(from: 0.0);
    }

    _checkMissionProgress();
    _checkBossDefeat();
    
    if (_currentProgress >= boss.targetValue && _autoDetectionEnabled) {
      _simulationTimer?.cancel();
      _accelerometerSubscription?.cancel();
      _autoDetectionEnabled = false;
    }
  }

  void _checkMissionProgress() {
    final chapter = widget.chapter;
    final missions = chapter.missions;
    final boss = chapter.boss;

    if (chapter.id == 'boss_legs') {
      if (_currentProgress >= 3 && missions.isNotEmpty && missions[0].status != MissionStatus.completed) {
        _gameNotifier.updateChapterMission(chapter.id, missions[0].id, MissionStatus.completed);
        _showMissionComplete('Tu commences à l\'impressionner !');
        if (missions.length > 1 && missions[1].status == MissionStatus.locked) {
          _gameNotifier.updateChapterMission(chapter.id, missions[1].id, MissionStatus.inProgress);
        }
      }
      if (_currentProgress >= 6 && missions.length > 1 && missions[1].status != MissionStatus.completed) {
        _gameNotifier.updateChapterMission(chapter.id, missions[1].id, MissionStatus.completed);
        _showMissionComplete('Il recule… tu le domines !');
        if (missions.length > 2 && missions[2].status == MissionStatus.locked) {
          _gameNotifier.updateChapterMission(chapter.id, missions[2].id, MissionStatus.inProgress);
        }
      }
    } else if (chapter.id == 'story_test') {
      if (_currentProgress >= 1 && missions.isNotEmpty && missions[0].status != MissionStatus.completed) {
        _gameNotifier.updateChapterMission(chapter.id, missions[0].id, MissionStatus.completed);
        _showMissionComplete('Exercice 1 complété ! Exercice 2 débloqué 🎯');
        if (missions.length > 1 && missions[1].status == MissionStatus.locked) {
          _gameNotifier.updateChapterMission(chapter.id, missions[1].id, MissionStatus.inProgress);
        }
      }
      if (_currentProgress >= 2 && missions.length > 1 && missions[1].status != MissionStatus.completed) {
        _gameNotifier.updateChapterMission(chapter.id, missions[1].id, MissionStatus.completed);
        _showMissionComplete('Exercice 2 complété ! Exercice 3 débloqué ⚡');
        if (missions.length > 2 && missions[2].status == MissionStatus.locked) {
          _gameNotifier.updateChapterMission(chapter.id, missions[2].id, MissionStatus.inProgress);
        }
      }
      if (_currentProgress >= 3 && missions.length > 2 && missions[2].status != MissionStatus.completed) {
        _gameNotifier.updateChapterMission(chapter.id, missions[2].id, MissionStatus.completed);
        _showMissionComplete('Exercice 3 complété ! Badge obtenu 👑');
      }
    } else {
      if (missions.isNotEmpty && _currentProgress >= (missions[0].targetValue ?? boss.targetValue)) {
        if (missions[0].status != MissionStatus.completed) {
          _gameNotifier.updateChapterMission(chapter.id, missions[0].id, MissionStatus.completed);
          _showMissionComplete(_getStoryCompleteMessage(chapter.id));
        }
      }
    }
  }

  String _getStoryCompleteMessage(String chapterId) {
    switch (chapterId) {
      case 'story1':
        return 'La porte s\'illumine ! Lumière bleue diffuse.';
      case 'story2':
        return 'L\'énergie circule ! Le corridor devient plus lumineux.';
      case 'story3':
        return 'Hydratation validée. Tu continues ton ascension.';
      case 'story4':
        return 'Rien ne t\'arrête. Tu avances, quoi qu\'il arrive.';
      case 'story5':
        return 'Tu sais quand te recharger. C\'est une vraie force.';
      case 'story_test':
        return 'Tous les exercices complétés ! Badge obtenu !';
      default:
        return 'Mission complétée !';
    }
  }

  void _checkBossDefeat() {
    final chapter = widget.chapter;
    final boss = chapter.boss;
    
    if (_currentProgress >= boss.targetValue && !_bossDefeatedShown) {
      _bossDefeatedShown = true;
      
      for (final mission in chapter.missions) {
        if (mission.status != MissionStatus.completed) {
          _gameNotifier.updateChapterMission(chapter.id, mission.id, MissionStatus.completed);
        }
      }
      
      String rewardId;
      if (chapter.id == 'boss_legs') {
        rewardId = 'boss_slayer';
      } else if (chapter.id == 'story_test') {
        rewardId = 'test_story_badge';
      } else {
        switch (chapter.id) {
          case 'story1':
            rewardId = 'starter';
            break;
          case 'story2':
            rewardId = 'endurant';
            break;
          case 'story3':
            rewardId = 'hydro_boost';
            break;
          case 'story4':
            rewardId = 'en_marche';
            break;
          case 'story5':
            rewardId = 'repos_guerrier';
            break;
          default:
            rewardId = 'starter';
        }
      }
      
      _gameNotifier.unlockReward(rewardId);
      if (chapter.id == 'boss_legs') {
        _gameNotifier.defeatBoss(boss.id);
      }
      
      _unlockNextChapter(chapter);
      _showBossDefeated();
    }
  }

  void _navigateToNextChapter(StoryChapter currentChapter) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      final nextChapter = _gameNotifier.getNextChapter(currentChapter.id);
      
      if (nextChapter != null && nextChapter.isUnlocked && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => StoryChapterPage(chapter: nextChapter),
          ),
        );
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const StoryHomePage(),
            ),
          );
        }
      }
    });
  }

  void _showMissionComplete(String message) {
    _unlockAnimationController.forward(from: 0.0);
    HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryGold, _accentOrange],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.celebration, color: _darkBg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _cardBg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _primaryGold.withOpacity(0.5)),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showBossDefeated() {
    _pauseTimer();
    final chapter = widget.chapter;
    final isBoss = chapter.id == 'boss_legs';
    
    final rewardId = isBoss ? 'boss_slayer' : 
                     chapter.id == 'story1' ? 'starter' :
                     chapter.id == 'story2' ? 'endurant' :
                     chapter.id == 'story3' ? 'hydro_boost' :
                     chapter.id == 'story4' ? 'en_marche' :
                     chapter.id == 'story5' ? 'repos_guerrier' : 'starter';
    
    final reward = _gameNotifier.rewards.firstWhere(
      (r) => r.id == rewardId,
      orElse: () => _gameNotifier.rewards.first,
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_cardBg, _deepPurple],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _primaryGold.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryGold.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_primaryGold, _accentOrange],
                ).createShader(bounds),
                child: Text(
                  isBoss ? '⚔️ BOSS VAINCU !' : '✨ STORY COMPLÉTÉE !',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Badge avec glow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryGold.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryGold.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  reward.icon,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                reward.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primaryGold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reward.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retour'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _navigateToNextChapter(chapter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGold,
                        foregroundColor: _darkBg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continuer →',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _getProgressLabel(StoryChapter chapter) {
    switch (chapter.id) {
      case 'story1':
      case 'boss_legs':
        return 'Squats';
      case 'story2':
        return 'Secondes';
      case 'story3':
        return 'ml d\'eau';
      case 'story4':
        return 'Pas';
      case 'story5':
        return 'Heures';
      case 'story_test':
        return 'Exercices';
      default:
        return 'Progression';
    }
  }

  String _getBossProgressMessage(int progress, int target) {
    if (progress == 0) return 'Le Boss te jauge...';
    final ratio = progress / target;
    if (ratio < 0.3) return 'Le Boss te jauge...';
    if (ratio < 0.6) return 'Tu commences à l\'impressionner !';
    if (ratio < 1.0) return 'Il recule… tu le domines !';
    return '⚔️ VICTOIRE !';
  }

  String _getChapterImage(StoryChapter chapter, double progressRatio) {
    // Utilise des images existantes comme fallback
    switch (chapter.id) {
      case 'story2':
        return 'assets/images/mon_profil_gagnant.png';
      case 'story3':
        return 'assets/images/mon_profil_neutre.png';
      case 'story4':
        return 'assets/images/fitpro_logo.png';
      case 'story5':
        return 'assets/images/badge_repos_guerrier.png';
      case 'boss_legs':
        return 'assets/images/boss_squat_0.png';
      default:
        return chapter.imagePath ?? 'assets/images/boss_squat_0.png';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD UI
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final boss = chapter.boss;
    final progress = _currentProgress / boss.targetValue;
    final missions = chapter.missions;
    final isBoss = chapter.id == 'boss_legs';

    return Scaffold(
      backgroundColor: _darkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardBg.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryGold.withOpacity(0.3)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryGold.withOpacity(0.3), _accentOrange.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primaryGold.withOpacity(0.5)),
              ),
              child: Text(
                chapter.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _primaryGold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Coach toggle
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _coachNotifier.isEnabled 
                    ? _successGreen.withOpacity(0.3) 
                    : _cardBg.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _coachNotifier.isEnabled ? _successGreen : Colors.white.withOpacity(0.3),
                ),
              ),
              child: Icon(
                _coachNotifier.isEnabled ? Icons.mic : Icons.mic_off,
                color: _coachNotifier.isEnabled ? _successGreen : Colors.white70,
                size: 20,
              ),
            ),
            onPressed: () {
              if (_coachNotifier.isEnabled) {
                _coachNotifier.setEnabled(false);
                _coachPhraseTimer?.cancel();
                _audioService.stop();
                setState(() => _currentCoachPhrase = null);
              } else {
                if (_coachNotifier.currentCoach == null) {
                  _coachNotifier.selectCoach(CoachStyle.humor);
                }
                _coachNotifier.setEnabled(true);
                if (_isActive) _startCoachPhraseTimer();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _deepPurple,
                  _darkBg,
                  _darkBg,
                ],
              ),
            ),
          ),
          
          // Particles effect (subtle)
          ...List.generate(20, (index) {
            final random = math.Random(index);
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: random.nextDouble() * MediaQuery.of(context).size.height,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 4 + random.nextDouble() * 4,
                    height: 4 + random.nextDouble() * 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primaryGold.withOpacity(_glowAnimation.value * 0.3 * random.nextDouble()),
                    ),
                  );
                },
              ),
            );
          }),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // Hero Image with animation
                  _buildHeroImage(chapter, progress),
                  const SizedBox(height: 24),
                  
                  // Title & Subtitle
                  _buildTitleSection(chapter),
                  const SizedBox(height: 20),
                  
                  // Segmented Battery Progress
                  _buildSegmentedBatteryProgress(progress, boss.targetValue),
                  const SizedBox(height: 24),
                  
                  // Boss message (if applicable)
                  if (isBoss) _buildBossMessage(),
                  if (isBoss) const SizedBox(height: 20),
                  
                  // Timer & Counter section
                  _buildTimerSection(chapter, boss),
                  const SizedBox(height: 24),
                  
                  // Missions
                  _buildMissionsSection(missions),
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  _buildActionButtons(chapter, boss),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(StoryChapter chapter, double progress) {
    return AnimatedBuilder(
      animation: _imageAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _imageScaleAnimation.value,
          child: Opacity(
            opacity: _imageFadeAnimation.value.clamp(0.0, 1.0),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGold.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _getChapterImage(chapter, progress),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_cardBg, _deepPurple],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              chapter.missions.isNotEmpty ? chapter.missions[0].icon : '🎮',
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _darkBg.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection(StoryChapter chapter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_primaryGold, _accentOrange],
          ).createShader(bounds),
          child: Text(
            chapter.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          chapter.subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            chapter.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════
  /// SEGMENTED BATTERY-STYLE PROGRESS INDICATOR
  /// ═══════════════════════════════════════════════════════════
  Widget _buildSegmentedBatteryProgress(double progress, int targetValue) {
    const int segments = 10;
    final int filledSegments = (progress * segments).ceil().clamp(0, segments);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_cardBg, _cardBgLight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _primaryGold.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_primaryGold, _accentOrange]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt, color: _darkBg, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getProgressLabel(widget.chapter),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progress >= 1.0 ? _successGreen.withOpacity(0.2) : _primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: progress >= 1.0 ? _successGreen : _primaryGold,
                  ),
                ),
                child: Text(
                  '$_currentProgress / $targetValue',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: progress >= 1.0 ? _successGreen : _primaryGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Segmented Battery Bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryGold.withOpacity(0.5), width: 2),
            ),
            child: Row(
              children: List.generate(segments, (index) {
                final isFilled = index < filledSegments;
                final isLast = index == segments - 1;
                final isFirst = index == 0;
                
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.only(
                      left: isFirst ? 4 : 2,
                      right: isLast ? 4 : 2,
                      top: 4,
                      bottom: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: isFilled
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                progress >= 1.0 ? _successGreen : _primaryGold,
                                progress >= 1.0 ? _successGreen.withOpacity(0.7) : _accentOrange,
                              ],
                            )
                          : null,
                      color: isFilled ? null : _cardBg.withOpacity(0.3),
                      borderRadius: BorderRadius.horizontal(
                        left: isFirst ? const Radius.circular(8) : Radius.zero,
                        right: isLast ? const Radius.circular(8) : Radius.zero,
                      ),
                      boxShadow: isFilled
                          ? [
                              BoxShadow(
                                color: (progress >= 1.0 ? _successGreen : _primaryGold).withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          
          // Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: progress >= 1.0 ? _successGreen : _primaryGold,
                    ),
                  );
                },
              ),
              if (progress >= 1.0) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_successGreen, _cyanAccent]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: _darkBg, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'COMPLÉTÉ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _darkBg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBossMessage() {
    final chapter = widget.chapter;
    final message = _getBossProgressMessage(_currentProgress, chapter.boss.targetValue);
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _currentProgress >= chapter.boss.targetValue ? 1.0 : _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _accentOrange.withOpacity(0.2),
                  _warningRed.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accentOrange.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accentOrange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sports_mma, color: _accentOrange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerSection(StoryChapter chapter, GameBoss boss) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_cardBg, _cardBgLight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Timer display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _darkBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isActive ? _successGreen.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isActive ? Icons.timer : Icons.timer_outlined,
                        color: _isActive ? _successGreen : Colors.white54,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        chapter.id == 'story1' && _isCountdown
                            ? '$_remainingSeconds'
                            : _formatDuration(_elapsedTime),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: chapter.id == 'story1' && _isCountdown && _remainingSeconds <= 5
                              ? _warningRed
                              : _primaryGold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        chapter.id == 'story1' && _isCountdown ? 'secondes' : 'temps',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Counter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _darkBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primaryGold.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center, color: _primaryGold, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        '$_currentProgress',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: _primaryGold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        _getProgressLabel(chapter),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Control buttons
          Row(
            children: [
              Expanded(
                child: _isActive
                    ? ElevatedButton.icon(
                        onPressed: _pauseTimer,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _startTimer,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Démarrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _successGreen,
                          foregroundColor: _darkBg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsSection(List<ChapterMission> missions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_primaryGold, _accentOrange]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flag, color: _darkBg, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Missions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...missions.map((mission) => _buildMissionCard(mission)),
      ],
    );
  }

  Widget _buildMissionCard(ChapterMission mission) {
    Color statusColor;
    IconData statusIcon;
    
    switch (mission.status) {
      case MissionStatus.completed:
        statusColor = _successGreen;
        statusIcon = Icons.check_circle;
        break;
      case MissionStatus.inProgress:
        statusColor = _primaryGold;
        statusIcon = Icons.play_circle;
        break;
      case MissionStatus.locked:
        statusColor = Colors.grey;
        statusIcon = Icons.lock;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: mission.status == MissionStatus.completed
              ? [_successGreen.withOpacity(0.15), _successGreen.withOpacity(0.05)]
              : [_cardBg, _cardBgLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mission.status == MissionStatus.completed
              ? _successGreen.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                mission.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: mission.status == MissionStatus.locked
                        ? Colors.grey
                        : Colors.white,
                    decoration: mission.status == MissionStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mission.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: mission.status == MissionStatus.locked
                        ? Colors.grey.withOpacity(0.6)
                        : Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(statusIcon, color: statusColor, size: 24),
        ],
      ),
    );
  }

  Widget _buildActionButtons(StoryChapter chapter, GameBoss boss) {
    // Info message pour Story 1
    if (chapter.id == 'story1') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_successGreen.withOpacity(0.15), _successGreen.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _successGreen.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _successGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: _successGreen, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Squats comptés automatiquement pendant le chrono',
                style: TextStyle(
                  fontSize: 14,
                  color: _successGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Story Test - Exercices
    if (chapter.id == 'story_test') {
      return Column(
        children: [
          if (_currentProgress < 1)
            _buildExerciseButton(
              '🎯 Exercice 1 - Niveau Débutant',
              () => _launchExercise('test_story_exercise_1', '🎯 Exercice Test Story - Niveau 1', 20),
            ),
          if (_currentProgress >= 1 && _currentProgress < 2)
            _buildExerciseButton(
              '⚡ Exercice 2 - Niveau Intermédiaire',
              () => _launchExercise('test_story_exercise_2', '⚡ Exercice Test Story - Niveau 2', 30),
            ),
          if (_currentProgress >= 2 && _currentProgress < 3)
            _buildExerciseButton(
              '👑 Exercice 3 - Niveau Expert',
              () => _launchExercise('test_story_exercise_3', '👑 Exercice Test Story - Niveau 3', 40),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addRep,
            icon: const Icon(Icons.add),
            label: const Text('Simuler +1 (démo)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    }
    
    // Autres stories
    return SizedBox(
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: ElevatedButton.icon(
              onPressed: _addRep,
              icon: Icon(_getActionIcon(chapter.id)),
              label: Text(_getActionLabel(chapter.id)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: _darkBg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: _primaryGold.withOpacity(0.5),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.play_arrow),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: _successGreen,
          foregroundColor: _darkBg,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  IconData _getActionIcon(String chapterId) {
    switch (chapterId) {
      case 'boss_legs':
        return Icons.fitness_center;
      case 'story2':
        return Icons.timer;
      case 'story3':
        return Icons.water_drop;
      case 'story4':
        return Icons.directions_walk;
      case 'story5':
        return Icons.bedtime;
      default:
        return Icons.add;
    }
  }

  String _getActionLabel(String chapterId) {
    switch (chapterId) {
      case 'boss_legs':
        return '+1 Squat';
      case 'story2':
        return '+1 Seconde';
      case 'story3':
        return '+50 ml';
      case 'story4':
        return '+100 pas';
      case 'story5':
        return 'Valider sommeil';
      default:
        return 'Valider';
    }
  }
}
