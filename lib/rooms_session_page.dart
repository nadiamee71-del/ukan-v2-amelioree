import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/rooms.dart';
import 'models/exercise_difficulty_notifier.dart';
import 'models/difficulty_entry.dart';
import 'services/difficulty_service.dart';
import 'components/difficulty_form.dart';
import 'alter_ego_floating/alter_ego_page_detector.dart';
import 'alter_ego_floating/alter_ego_context_service.dart';

class RoomsSessionPage extends StatefulWidget {
  final String roomId;
  final bool enableDifficultyEvaluation;

  const RoomsSessionPage({
    super.key,
    required this.roomId,
    this.enableDifficultyEvaluation = true,
  });

  @override
  State<RoomsSessionPage> createState() => _RoomsSessionPageState();
}

class _RoomsSessionPageState extends State<RoomsSessionPage> {
  final _roomsNotifier = RoomsNotifier();
  final _difficultyNotifier = ExerciseDifficultyNotifier();
  Timer? _sessionTimer;
  Timer? _exerciseTimer;
  Timer? _progressTimer;
  int _totalElapsedSeconds = 0;
  bool _isMicrophoneOn = true;
  bool _isCameraOn = true;
  bool _isExercisePaused = false;
  String? _pinnedParticipantId;

  // Contrôleur vidéo pour l'exercice actuel
  VideoPlayerController? _exerciseVideoController;
  bool _exerciseVideoInitialized = false;
  bool _exerciseVideoError = false;

  // États pour les nouvelles fonctionnalités
  bool _isReadyScreen = true; // Écran "En attente / prêt"
  bool _isUserReady = false; // L'utilisateur a cliqué sur "Je suis prêt"
  Map<String, bool> _participantsReady = {}; // État de préparation des participants
  bool _isSessionCompleted = false; // Séance terminée
  static const bool isGroupTrainingPremium = true; // Flag Premium (mode démo activé)
  
  // Compte à rebours 3, 2, 1, GO!
  bool _isCountdownActive = false;
  int _countdownValue = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _roomsNotifier.addListener(_onRoomChanged);
    // Initialiser l'état de préparation des participants
    final room = _roomsNotifier.currentRoom;
    if (room != null) {
      for (final participant in room.participants) {
        _participantsReady[participant.id] = false;
      }
    }
    // En mode démo, simuler que les autres participants deviennent prêts après 2-3 secondes
    if (room != null && room.participants.length > 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            for (final participant in room.participants) {
              if (participant.id != 'you') {
                _participantsReady[participant.id] = true;
              }
            }
          });
        }
      });
    }
    // Détecter la page pour l'Alter Ego
    AlterEgoPageDetector.setupPageContext(UkanPage.rooms);
    // Ne pas démarrer les timers tant que l'écran "prêt" est affiché
    // _startTimers() sera appelé quand la séance démarre réellement
    // _initializeExerciseVideo() sera appelé quand la séance démarre
  }

  @override
  void dispose() {
    _roomsNotifier.removeListener(_onRoomChanged);
    _sessionTimer?.cancel();
    _exerciseTimer?.cancel();
    _progressTimer?.cancel();
    _countdownTimer?.cancel();
    _exerciseVideoController?.dispose();
    super.dispose();
  }

  void _onRoomChanged() {
    setState(() {
      _initializeExerciseVideo(); // Réinitialiser la vidéo si l'exercice change
    });
  }

  Future<void> _initializeExerciseVideo() async {
    final room = _roomsNotifier.currentRoom;
    final currentExercise = room?.currentExercise;
    
    if (currentExercise == null) {
      _exerciseVideoController?.dispose();
      _exerciseVideoController = null;
      setState(() {
        _exerciseVideoInitialized = false;
        _exerciseVideoError = false;
      });
      return;
    }

    // Si l'exercice a changé, disposer l'ancien contrôleur
    if (_exerciseVideoController != null) {
      await _exerciseVideoController!.dispose();
      _exerciseVideoController = null;
    }

    // Essayer de charger la vidéo locale d'abord
    if (currentExercise.videoAsset != null) {
      try {
        _exerciseVideoController = VideoPlayerController.asset(currentExercise.videoAsset!);
        await _exerciseVideoController!.initialize();
        if (mounted) {
          setState(() {
            _exerciseVideoInitialized = true;
            _exerciseVideoError = false;
          });
          _exerciseVideoController!.setLooping(true);
          if (!_isExercisePaused) {
            _exerciseVideoController!.play();
          }
        }
      } catch (e) {
        // Échec de chargement de la vidéo locale
        if (mounted) {
          setState(() {
            _exerciseVideoError = true;
            _exerciseVideoInitialized = false;
          });
        }
        if (_exerciseVideoController != null) {
          await _exerciseVideoController!.dispose();
          _exerciseVideoController = null;
        }
      }
    } else {
      setState(() {
        _exerciseVideoError = true;
        _exerciseVideoInitialized = false;
      });
    }
  }

  void _toggleExercisePause() {
    setState(() {
      _isExercisePaused = !_isExercisePaused;
    });
    
    if (_exerciseVideoController != null) {
      if (_isExercisePaused) {
        _exerciseVideoController!.pause();
      } else {
        _exerciseVideoController!.play();
      }
    }
  }

  void _startTimers() {
    // Timer principal de la séance
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _totalElapsedSeconds++;
      });
    });

    // Timer pour l'exercice actuel
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isExercisePaused) {
        return;
      }
      final room = _roomsNotifier.currentRoom;
      if (room == null || room.currentExercise == null) return;

      final newElapsed = room.currentExerciseElapsedSeconds + 1;
      final exerciseDuration = room.currentExercise!.durationSeconds;

      if (newElapsed >= exerciseDuration) {
        // L'exercice est terminé
        _roomsNotifier.updateCurrentRoom(
          room.copyWith(currentExerciseElapsedSeconds: exerciseDuration),
        );
        
        // Proposer de noter la difficulté de l'exercice avec le nouveau formulaire
        if (mounted && room.currentExercise != null && widget.enableDifficultyEvaluation) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => DifficultyForm(
              exerciseId: room.currentExercise!.id,
              sessionId: room.id,
              onSave: (entry) async {
                await DifficultyService().saveDifficulty(entry);
              },
              onCancel: () {
                // L'utilisateur peut annuler
              },
            ),
          );
        }
        
        // Vérifier si la séance est complète
        if (!room.hasNextExercise) {
          // Tous les exercices sont terminés
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _finishSession();
            }
          });
        } else {
          // Auto-passer à l'exercice suivant après 2 secondes avec compte à rebours
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && room.hasNextExercise) {
              _roomsNotifier.nextExercise();
              _startCountdownForNextExercise();
            }
          });
        }
      } else {
        _roomsNotifier.updateCurrentRoom(
          room.copyWith(currentExerciseElapsedSeconds: newElapsed),
        );
      }
    });

    // Timer pour simuler la progression des autres participants
    _progressTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || _isExercisePaused) {
        return;
      }
      _simulateOtherParticipantsProgress();
    });
  }

  void _simulateOtherParticipantsProgress() {
    final room = _roomsNotifier.currentRoom;
    if (room == null || room.currentExercise == null) return;

    final exerciseId = room.currentExercise!.id;
    final exerciseDuration = room.currentExercise!.durationSeconds;
    final elapsed = room.currentExerciseElapsedSeconds;
    final exerciseProgress = ((elapsed / exerciseDuration) * 100).clamp(0, 100).toInt();

    final updatedParticipants = room.participants.map((p) {
      if (!p.isOwner) {
        // Simuler une progression pour l'exercice actuel
        final currentExProgress = p.exerciseProgress[exerciseId] ?? 0;
        final increment = 2 + (DateTime.now().millisecond % 4);
        final newExProgress = (currentExProgress + increment).clamp(0, exerciseProgress);
        
        final newExerciseProgress = Map<String, int>.from(p.exerciseProgress);
        newExerciseProgress[exerciseId] = newExProgress;

        // Calculer la progression globale de la séance
        final totalExercises = room.exercises.length;
        final completedExercises = room.currentExerciseIndex;
        final currentExPercent = newExProgress / 100.0;
        final globalProgress = ((completedExercises + currentExPercent) / totalExercises * 100).clamp(0, 100).toInt();

        return p.copyWith(
          progressPercent: globalProgress,
          exerciseProgress: newExerciseProgress,
        );
      }
      return p;
    }).toList();

    _roomsNotifier.updateCurrentRoom(
      room.copyWith(
        participants: updatedParticipants,
        isActive: true,
      ),
    );
  }

  void _updateMyExerciseProgress(int progress) {
    final room = _roomsNotifier.currentRoom;
    if (room == null || room.currentExercise == null) return;

    final exerciseId = room.currentExercise!.id;
    final updated = room.participants.map((p) {
      if (p.id == 'you') {
        final newExerciseProgress = Map<String, int>.from(p.exerciseProgress);
        newExerciseProgress[exerciseId] = progress.clamp(0, 100);

        // Calculer la progression globale
        final totalExercises = room.exercises.length;
        final completedExercises = room.currentExerciseIndex;
        final currentExPercent = progress / 100.0;
        final globalProgress = ((completedExercises + currentExPercent) / totalExercises * 100).clamp(0, 100).toInt();

        return p.copyWith(
          progressPercent: globalProgress,
          exerciseProgress: newExerciseProgress,
        );
      }
      return p;
    }).toList();

    _roomsNotifier.updateCurrentRoom(
      room.copyWith(participants: updated),
    );
  }

  void _incrementMyExerciseProgress() {
    final room = _roomsNotifier.currentRoom;
    if (room == null || room.currentExercise == null) return;

    final exerciseId = room.currentExercise!.id;
    final currentProgress = room.participants
        .firstWhere((p) => p.id == 'you', orElse: () => room.participants.first)
        .exerciseProgress[exerciseId] ?? 0;

    final newProgress = (currentProgress + 10).clamp(0, 100);
    _updateMyExerciseProgress(newProgress);
  }

  void _toggleMicrophone() {
    setState(() {
      _isMicrophoneOn = !_isMicrophoneOn;
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
  }

  void _pinParticipant(String? participantId) {
    setState(() {
      _pinnedParticipantId = _pinnedParticipantId == participantId ? null : participantId;
    });
  }

  void _showAddParticipantDialog() {
    final room = _roomsNotifier.currentRoom;
    if (room == null) return;

    final currentParticipantIds = room.participants.map((p) => p.id).toSet();
    final availableMembers = RoomsNotifier.availableMembers
        .where((member) => !currentParticipantIds.contains(member.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ajouter des participants',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Liste des membres disponibles
            Expanded(
              child: availableMembers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tous les membres sont déjà dans la séance',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: availableMembers.length,
                      itemBuilder: (context, index) {
                        final member = availableMembers[index];
                        final memberColor = _getColorForParticipant(member.id);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: memberColor,
                              child: Text(
                                member.avatarInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'En ligne • Disponible',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () {
                                _roomsNotifier.addParticipant(member);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${member.name} a rejoint la séance'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text('Ajouter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC300),
                                foregroundColor: const Color(0xFF111111),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishSession() {
    _sessionTimer?.cancel();
    _exerciseTimer?.cancel();
    _progressTimer?.cancel();
    _exerciseVideoController?.pause();

    final room = _roomsNotifier.currentRoom;
    if (room != null) {
      // Si l'évaluation de difficulté est activée, afficher le formulaire pour chaque exercice
      if (widget.enableDifficultyEvaluation && room.exercises.isNotEmpty) {
        _showDifficultyFormsForAllExercises(room);
      } else {
        // Sinon, afficher directement l'écran récapitulatif
        _showSessionSummary(room);
      }
    }
  }

  /// Affiche le formulaire de difficulté pour tous les exercices de la séance
  void _showDifficultyFormsForAllExercises(TrainingRoom room) async {
    final exercises = room.exercises;
    int currentExerciseIndex = 0;

    // Fonction récursive pour afficher les formulaires un par un
    void showNextForm() {
      if (currentExerciseIndex >= exercises.length) {
        // Tous les formulaires ont été remplis, afficher le résumé
        if (mounted) {
          _showSessionSummary(room);
        }
        return;
      }

      final exercise = exercises[currentExerciseIndex];
      
      showDialog(
        context: context,
        barrierDismissible: false, // Empêcher de fermer en cliquant en dehors
        builder: (context) => DifficultyForm(
          exerciseId: exercise.id,
          sessionId: room.id,
          onSave: (entry) async {
            // Enregistrer l'évaluation via le service
            await DifficultyService().saveDifficulty(entry);
          },
          onCancel: () {
            // Si l'utilisateur annule, passer à l'exercice suivant quand même
          },
        ),
      ).then((_) {
        // Quand le dialog se ferme (après enregistrement ou annulation)
        currentExerciseIndex++;
        // Afficher le formulaire suivant
        if (mounted) {
          showNextForm();
        }
      });
    }

    // Démarrer avec le premier exercice
    showNextForm();
  }

  void _startSession() {
    setState(() {
      _isReadyScreen = false;
    });
    // Lancer le compte à rebours 3, 2, 1, GO! avant de démarrer
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdownValue = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdownValue > 0) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountdownActive = false;
        });
        // Démarrer la séance après le compte à rebours
        _startTimers();
        _initializeExerciseVideo();
      }
    });
  }

  void _startCountdownForNextExercise() {
    // Pause l'exercice actuel
    _exerciseVideoController?.pause();
    
    setState(() {
      _isCountdownActive = true;
      _countdownValue = 3;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdownValue > 0) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountdownActive = false;
        });
        // Reprendre la vidéo
        if (!_isExercisePaused && _exerciseVideoController != null) {
          _exerciseVideoController!.play();
        }
      }
    });
  }

  void _markUserReady() {
    setState(() {
      _isUserReady = true;
      _participantsReady['you'] = true;
    });
    
    final room = _roomsNotifier.currentRoom;
    if (room != null) {
      final isOwner = room.participants.any((p) => p.id == 'you' && p.isOwner);
      final allReady = _participantsReady.values.every((ready) => ready);
      
      // Si l'utilisateur est owner et que tous sont prêts, ou si owner clique sur "Lancer"
      if (isOwner && allReady) {
        _startSession();
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final room = _roomsNotifier.currentRoom;

    if (room == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          title: const Text('Séance en groupe'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Aucune room active.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Afficher l'écran "En attente / prêt" si la séance n'a pas encore démarré
    if (_isReadyScreen && !_isSessionCompleted) {
      return _buildReadyScreen(room);
    }

    // Afficher l'écran récapitulatif si la séance est terminée
    if (_isSessionCompleted) {
      return _buildSessionSummaryScreen(room);
    }

    final currentExercise = room.currentExercise;
    final exerciseElapsed = room.currentExerciseElapsedSeconds;
    final exerciseDuration = currentExercise?.durationSeconds ?? 60;
    final exerciseProgress = currentExercise != null
        ? (exerciseElapsed / exerciseDuration).clamp(0.0, 1.0)
        : 0.0;

    // Organiser les participants
    final participants = List<RoomParticipant>.from(room.participants);
    if (_pinnedParticipantId != null) {
      final pinnedIndex = participants.indexWhere((p) => p.id == _pinnedParticipantId);
      if (pinnedIndex != -1) {
        final pinned = participants.removeAt(pinnedIndex);
        participants.insert(0, pinned);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Column(
              children: [
                // Header avec timer, participants, badge Premium et bouton ajouter
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge Premium
                      if (isGroupTrainingPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Premium (démo)',
                            style: TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const Spacer(),
                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(_totalElapsedSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Participants + Bouton ajouter
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  '${room.participants.length} participants',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Bouton ajouter participant
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showAddParticipantDialog,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC300),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_add, size: 16, color: Color(0xFF111111)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ajouter',
                                      style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Vidéo de l'exercice (30% hauteur) + Onglets avec contrôles
                if (room.exercises.isNotEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Row(
                      children: [
                        // Vidéo de l'exercice (30% largeur)
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: currentExercise != null
                                  ? _buildExerciseVideoPlayer(currentExercise)
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.fitness_center,
                                            size: 60,
                                            color: Color(0xFFFFC300),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Sélectionnez un exercice',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Onglets avec contrôles (70% largeur)
                        Expanded(
                          flex: 7,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                // Onglets des exercices
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: room.exercises.length,
                                    itemBuilder: (context, index) {
                                      final exercise = room.exercises[index];
                                      final isActive = index == room.currentExerciseIndex;
                                      final isCompleted = index < room.currentExerciseIndex;
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _exerciseVideoController?.pause();
                                              _exerciseVideoController?.dispose();
                                              _exerciseVideoController = null;
                                              
                                              setState(() {
                                                _exerciseVideoInitialized = false;
                                                _exerciseVideoError = false;
                                                _isExercisePaused = false;
                                              });
                                              
                                              _roomsNotifier.updateCurrentRoom(
                                                room.copyWith(
                                                  currentExerciseIndex: index,
                                                  currentExerciseElapsedSeconds: 0,
                                                ),
                                              );
                                              
                                              Future.delayed(const Duration(milliseconds: 100), () {
                                                _initializeExerciseVideo();
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? const Color(0xFFFFC300)
                                                    : (isCompleted ? Colors.green.shade700 : Colors.grey.shade800),
                                                borderRadius: BorderRadius.circular(20),
                                                border: isActive
                                                    ? Border.all(color: Colors.white, width: 2)
                                                    : null,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: isActive
                                                          ? const Color(0xFF111111)
                                                          : Colors.white.withValues(alpha: 0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: isCompleted
                                                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                                                          : Text(
                                                              '${index + 1}',
                                                              style: TextStyle(
                                                                color: isActive ? const Color(0xFFFFC300) : Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    exercise.name,
                                                    style: TextStyle(
                                                      color: isActive ? const Color(0xFF111111) : Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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

                                // Contrôles : Chronomètre, barre de progression, play/pause
                                if (currentExercise != null)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Chronomètre de l'exercice avec bouton info
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFC300),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFFC300).withValues(alpha: 0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.fitness_center, color: Color(0xFF111111), size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${_formatTime(exerciseElapsed)} / ${_formatTime(exerciseDuration)}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF111111),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                // Bouton info pour détail exercice
                                                Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () => _showExerciseDetail(currentExercise!),
                                                    borderRadius: BorderRadius.circular(16),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF111111).withValues(alpha: 0.2),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.info_outline,
                                                        color: Color(0xFF111111),
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                // Bouton Play/Pause
                                                Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: _toggleExercisePause,
                                                    borderRadius: BorderRadius.circular(16),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: const BoxDecoration(
                                                        color: Color(0xFF111111),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        _isExercisePaused ? Icons.play_arrow : Icons.pause,
                                                        color: const Color(0xFFFFC300),
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Barre de progression
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: exerciseProgress,
                                                minHeight: 8,
                                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC300)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Exercice ${room.currentExerciseIndex + 1}/${room.exercises.length}',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Grille des participants (tout l'espace restant)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _buildParticipantsGrid(participants, currentExercise),
                    ),
                  ),
                ),

                // Contrôles en bas
                _buildControls(room),
              ],
            ),
          ),
          // Overlay compte à rebours 3, 2, 1, GO!
          if (_isCountdownActive) _buildCountdownOverlay(),
        ],
      ),
    );
  }

  /// Overlay du compte à rebours 3, 2, 1, GO!
  Widget _buildCountdownOverlay() {
    final displayText = _countdownValue > 0 ? '$_countdownValue' : 'GO!';
    final displayColor = _countdownValue > 0 ? const Color(0xFFFFC300) : Colors.green;
    
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_countdownValue),
          tween: Tween(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cercle avec le chiffre
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          displayColor,
                          displayColor.withValues(alpha: 0.3),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: displayColor.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: _countdownValue > 0 ? 100 : 60,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111111),
                          letterSpacing: _countdownValue > 0 ? 0 : 4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Message
                  Text(
                    _countdownValue > 0 ? 'Préparez-vous...' : 'C\'est parti ! 💪',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nom de l'exercice
                  if (_roomsNotifier.currentRoom?.currentExercise != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: displayColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        _roomsNotifier.currentRoom!.currentExercise!.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: displayColor,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExerciseVideoPlayer(RoomExercise exercise) {
    if (_exerciseVideoInitialized && _exerciseVideoController != null) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: _exerciseVideoController!.value.aspectRatio,
            child: VideoPlayer(_exerciseVideoController!),
          ),
          // Overlay avec nom de l'exercice et bouton info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showExerciseDetail(exercise),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (exercise.youtubeUrl != null && _exerciseVideoError) {
      // Fallback YouTube
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_fill,
              size: 50,
              color: Color(0xFFFFC300),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(exercise.youtubeUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('YouTube', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: const Color(0xFF111111),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Placeholder
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 50,
              color: Color(0xFFFFC300),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                exercise.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildParticipantsGrid(List<RoomParticipant> participants, RoomExercise? currentExercise) {
    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucun participant',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Calculer le nombre de colonnes selon le nombre de participants
    int crossAxisCount = 2;
    if (participants.length == 1) {
      crossAxisCount = 1;
    } else if (participants.length <= 4) {
      crossAxisCount = 2;
    } else if (participants.length <= 6) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return _buildParticipantTile(participant, currentExercise);
      },
    );
  }

  Widget _buildParticipantTile(RoomParticipant participant, RoomExercise? currentExercise) {
    final isPinned = participant.id == _pinnedParticipantId;
    final isYou = participant.id == 'you';
    
    // Progression de l'exercice actuel
    final exerciseProgress = currentExercise != null
        ? (participant.exerciseProgress[currentExercise.id] ?? 0)
        : 0;

    return GestureDetector(
      onTap: () => _pinParticipant(participant.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: isPinned
              ? Border.all(color: const Color(0xFFFFC300), width: 3)
              : Border.all(color: Colors.grey.shade800, width: 1),
        ),
        child: Column(
          children: [
            // Vidéo/Avatar
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getColorForParticipant(participant.id).withValues(alpha: 0.8),
                      _getColorForParticipant(participant.id).withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: Text(
                              participant.avatarInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isYou) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fiber_manual_record,
                                    color: Colors.red,
                                    size: 8,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Progression globale en haut à droite
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${participant.progressPercent}%',
                          style: const TextStyle(
                            color: Color(0xFFFFC300),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Badge "Créateur"
                    if (participant.isOwner && !isYou)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Créateur',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Infos en bas
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (isYou)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Toi',
                            style: TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (isYou) const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          participant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (currentExercise != null) ...[
                    const SizedBox(height: 6),
                    // Barre de progression de l'exercice
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: exerciseProgress / 100.0,
                        minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          exerciseProgress >= 100
                              ? Colors.green
                              : const Color(0xFFFFC300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$exerciseProgress%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForParticipant(String participantId) {
    switch (participantId) {
      case 'you':
        return const Color(0xFF111111);
      case 'sarah':
        return Colors.purple.shade700;
      case 'bilel':
        return Colors.blue.shade700;
      case 'marie':
        return Colors.pink.shade700;
      case 'lucas':
        return Colors.green.shade700;
      case 'sophie':
        return Colors.orange.shade700;
      case 'thomas':
        return Colors.indigo.shade700;
      case 'julie':
        return Colors.red.shade700;
      case 'pierre':
        return Colors.cyan.shade700;
      default:
        return Colors.teal.shade700;
    }
  }

  Widget _buildControls(TrainingRoom room) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre de la séance
            Text(
              room.workoutTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            
            // Contrôles principaux
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Microphone
                _ControlButton(
                  icon: _isMicrophoneOn ? Icons.mic : Icons.mic_off,
                  label: _isMicrophoneOn ? 'Micro' : 'Off',
                  isActive: _isMicrophoneOn,
                  onPressed: _toggleMicrophone,
                ),
                
                // Caméra
                _ControlButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  label: _isCameraOn ? 'Caméra' : 'Off',
                  isActive: _isCameraOn,
                  onPressed: _toggleCamera,
                ),
                
                // Progression exercice
                _ControlButton(
                  icon: Icons.add_circle_outline,
                  label: '+10%',
                  isActive: true,
                  onPressed: _incrementMyExerciseProgress,
                  color: const Color(0xFFFFC300),
                ),

                // Passer à l'exercice suivant (si owner)
                if (room.participants.any((p) => p.id == 'you' && p.isOwner) && room.hasNextExercise)
                  _ControlButton(
                    icon: Icons.skip_next,
                    label: 'Suivant',
                    isActive: true,
                    onPressed: () {
                      _roomsNotifier.nextExercise();
                    },
                    color: Colors.blue.shade700,
                  ),
                
                // Quitter
                _ControlButton(
                  icon: Icons.call_end,
                  label: 'Quitter',
                  isActive: false,
                  onPressed: _finishSession,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // Écran "En attente / prêt à démarrer"
  Widget _buildReadyScreen(TrainingRoom room) {
    final isOwner = room.participants.any((p) => p.id == 'you' && p.isOwner);
    final allReady = _participantsReady.values.every((ready) => ready);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Prêt à démarrer'),
        centerTitle: true,
        actions: [
          // Badge Premium
          if (isGroupTrainingPremium)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Premium (démo)',
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Titre de la séance
              Text(
                room.workoutTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${room.participants.length} participant${room.participants.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              // Liste des participants avec leur statut
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Participants',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...room.participants.map((participant) {
                      final isReady = _participantsReady[participant.id] ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: _getColorForParticipant(participant.id),
                              child: Text(
                                participant.avatarInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                participant.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isReady)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              )
                            else
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC300)),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Message Premium
              if (isGroupTrainingPremium)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4CC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFC300),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFF111111),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fonctionnalité Premium – actuellement en mode démo, aucun paiement réel.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Bouton "Je suis prêt" ou "Lancer la séance"
              if (!_isUserReady)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _markUserReady,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: const Color(0xFF111111),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Je suis prêt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (isOwner && allReady)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Lancer la séance (démo)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'En attente des autres participants...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Écran récapitulatif de la séance
  void _showSessionSummary(TrainingRoom room) {
    setState(() {
      _isSessionCompleted = true;
    });
  }

  Widget _buildSessionSummaryScreen(TrainingRoom room) {
    // Calculer les statistiques
    final completedExercises = room.currentExerciseIndex + 1;
    final totalExercises = room.exercises.length;
    
    // Calculer la difficulté moyenne ressentie
    final difficultyEntries = _difficultyNotifier.allEntries
        .where((e) => room.exercises.any((ex) => ex.id == e.exerciseId))
        .toList();
    
    double averageDifficultyValue = 0;
    if (difficultyEntries.isNotEmpty) {
      final sum = difficultyEntries.fold<int>(0, (sum, entry) {
        switch (entry.difficulty) {
          case PerceivedDifficulty.veryEasy:
            return sum + 1;
          case PerceivedDifficulty.easy:
            return sum + 2;
          case PerceivedDifficulty.medium:
            return sum + 3;
          case PerceivedDifficulty.hard:
            return sum + 4;
          case PerceivedDifficulty.veryHard:
            return sum + 5;
        }
      });
      averageDifficultyValue = sum / difficultyEntries.length;
    }
    
    String averageDifficultyText = 'Non noté';
    if (averageDifficultyValue > 0) {
      if (averageDifficultyValue <= 1.5) {
        averageDifficultyText = 'Très facile';
      } else if (averageDifficultyValue <= 2.5) {
        averageDifficultyText = 'Facile';
      } else if (averageDifficultyValue <= 3.5) {
        averageDifficultyText = 'Moyen';
      } else if (averageDifficultyValue <= 4.5) {
        averageDifficultyText = 'Difficile';
      } else {
        averageDifficultyText = 'Très difficile';
      }
    }
    
    // Estimation de calories brûlées (démo)
    final estimatedCalories = (_totalElapsedSeconds / 60 * 8).round(); // ~8 kcal/min en moyenne

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Séance terminée'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Icône de succès
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Séance terminée !',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                room.workoutTitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              // Statistiques
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _SummaryStatRow(
                      icon: Icons.timer,
                      label: 'Durée totale',
                      value: _formatTime(_totalElapsedSeconds),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _SummaryStatRow(
                      icon: Icons.fitness_center,
                      label: 'Exercices complétés',
                      value: '$completedExercises / $totalExercises',
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _SummaryStatRow(
                      icon: Icons.sentiment_satisfied,
                      label: 'Difficulté moyenne',
                      value: averageDifficultyText,
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _SummaryStatRow(
                      icon: Icons.local_fire_department,
                      label: 'Calories brûlées (estimation)',
                      value: '$estimatedCalories kcal',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Boutons d'action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Rejouer la séance
                    setState(() {
                      _isSessionCompleted = false;
                      _isReadyScreen = true;
                      _isUserReady = false;
                      _totalElapsedSeconds = 0;
                      _participantsReady.clear();
                      final room = _roomsNotifier.currentRoom;
                      if (room != null) {
                        for (final participant in room.participants) {
                          _participantsReady[participant.id] = false;
                        }
                      }
                      _roomsNotifier.updateCurrentRoom(
                        room!.copyWith(
                          isActive: false,
                          currentExerciseIndex: 0,
                          currentExerciseElapsedSeconds: 0,
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC300),
                    foregroundColor: const Color(0xFF111111),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Rejouer la séance (démo)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Panneau de détail d'exercice
  void _showExerciseDetail(RoomExercise exercise) {
    // Données statiques pour les exercices (démo)
    final exerciseData = _getExerciseDetailData(exercise.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Détail de l\'exercice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom de l'exercice
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Zone du corps
                    if (exerciseData['bodyZone'] != null)
                      _DetailSection(
                        title: 'Zone du corps',
                        content: Text(
                          exerciseData['bodyZone'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Muscles principaux / secondaires
                    if (exerciseData['mainMuscles'] != null || exerciseData['secondaryMuscles'] != null)
                      _DetailSection(
                        title: 'Muscles sollicités',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (exerciseData['mainMuscles'] != null) ...[
                              const Text(
                                'Principaux :',
                                style: TextStyle(
                                  color: Color(0xFFFFC300),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (exerciseData['mainMuscles'] as List<String>)
                                    .map((muscle) => Chip(
                                          label: Text(muscle),
                                          backgroundColor: const Color(0xFFFFC300).withValues(alpha: 0.2),
                                          labelStyle: const TextStyle(color: Color(0xFFFFC300)),
                                        ))
                                    .toList(),
                              ),
                            ],
                            if (exerciseData['secondaryMuscles'] != null && (exerciseData['secondaryMuscles'] as List).isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Secondaires :',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (exerciseData['secondaryMuscles'] as List<String>)
                                    .map((muscle) => Chip(
                                          label: Text(muscle),
                                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                                          labelStyle: const TextStyle(color: Colors.white70),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Description
                    if (exercise.description.isNotEmpty)
                      _DetailSection(
                        title: 'Description',
                        content: Text(
                          exercise.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Étapes d'exécution
                    if (exerciseData['steps'] != null)
                      _DetailSection(
                        title: 'Étapes d\'exécution',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (exerciseData['steps'] as List<String>)
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${entry.key + 1}.',
                                          style: const TextStyle(
                                            color: Color(0xFFFFC300),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Erreurs fréquentes
                    if (exerciseData['commonMistakes'] != null && (exerciseData['commonMistakes'] as List).isNotEmpty)
                      _DetailSection(
                        title: 'Erreurs fréquentes',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (exerciseData['commonMistakes'] as List<String>)
                              .map((mistake) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            mistake,
                                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Image placeholder
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: exercise.imageAsset != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                exercise.imageAsset!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 60,
                                    color: Color(0xFFFFC300),
                                  ),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: Color(0xFFFFC300),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getExerciseDetailData(String exerciseId) {
    // Données statiques pour les exercices (démo)
    switch (exerciseId) {
      case 'squat':
        return {
          'bodyZone': 'Bas du corps',
          'mainMuscles': ['Quadriceps', 'Fessiers', 'Mollets'],
          'secondaryMuscles': ['Ischio-jambiers', 'Abdominaux'],
          'steps': [
            'Écarte les pieds à largeur des épaules',
            'Descends en pliant les genoux jusqu\'à ce que tes cuisses soient parallèles au sol',
            'Garde le dos droit et le regard vers l\'avant',
            'Remonte en poussant sur les talons',
            'Contracte les fessiers en fin de mouvement',
          ],
          'commonMistakes': [
            'Genoux qui rentrent vers l\'intérieur',
            'Dos arrondi',
            'Talons qui se décollent du sol',
            'Ne pas descendre assez bas',
          ],
        };
      case 'pushup':
        return {
          'bodyZone': 'Haut du corps',
          'mainMuscles': ['Pectoraux', 'Triceps', 'Épaules'],
          'secondaryMuscles': ['Abdominaux', 'Dos'],
          'steps': [
            'Place-toi en position de planche, mains à largeur des épaules',
            'Descends lentement jusqu\'à frôler le sol avec la poitrine',
            'Garde le corps aligné de la tête aux pieds',
            'Remonte en poussant sur les bras',
            'Expire en montant, inspire en descendant',
          ],
          'commonMistakes': [
            'Fesses trop hautes ou trop basses',
            'Tête qui tombe vers le sol',
            'Mouvement incomplet (ne pas descendre assez)',
            'Respiration bloquée',
          ],
        };
      case 'plank':
        return {
          'bodyZone': 'Abdominaux',
          'mainMuscles': ['Abdominaux', 'Fessiers', 'Épaules'],
          'secondaryMuscles': ['Épaules', 'Dos'],
          'steps': [
            'Place-toi en position de planche sur les avant-bras',
            'Garde le corps droit comme une planche',
            'Contracte les abdos et les fessiers',
            'Respire normalement',
            'Maintiens la position',
          ],
          'commonMistakes': [
            'Fesses trop hautes',
            'Creux du dos trop prononcé',
            'Tête qui tombe',
            'Respiration bloquée',
          ],
        };
      case 'lunges':
        return {
          'bodyZone': 'Bas du corps',
          'mainMuscles': ['Quadriceps', 'Fessiers', 'Mollets'],
          'secondaryMuscles': ['Ischio-jambiers', 'Abdominaux'],
          'steps': [
            'Fais un pas en avant assez grand',
            'Plie le genou avant jusqu\'à 90°',
            'Garde le torse droit',
            'Pousse sur le talon avant pour remonter',
            'Alterne les jambes',
          ],
          'commonMistakes': [
            'Genou avant qui dépasse les orteils',
            'Corps qui penche vers l\'avant',
            'Pas trop petit',
            'Déséquilibre',
          ],
        };
      default:
        return {
          'bodyZone': 'Full body',
          'mainMuscles': [],
          'secondaryMuscles': [],
          'steps': [],
          'commonMistakes': [],
        };
    }
  }
}

// Widget pour une ligne de statistique dans le récapitulatif
class _SummaryStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryStatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC300), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Widget pour une section de détail d'exercice
class _DetailSection extends StatelessWidget {
  final String title;
  final Widget content;

  const _DetailSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFC300),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? (isActive ? const Color(0xFFFFC300) : Colors.grey.shade700);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: buttonColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
