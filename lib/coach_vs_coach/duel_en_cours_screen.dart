import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/coach_vs_coach.dart';
import 'duel_video_placeholder.dart';

/// Écran de duel en cours avec timer, scores simulés et animation VS
/// Version maquette ultra-réaliste avec placeholders vidéo, boutons caméra/micro
class DuelEnCoursScreen extends StatefulWidget {
  final CoachRanking coachA;
  final DuelOpponent opponent;
  final String challengeType;
  final Duration duration;
  final DuelType duelType; // Type de duel pour l'historique

  const DuelEnCoursScreen({
    super.key,
    required this.coachA,
    required this.opponent,
    required this.challengeType,
    required this.duration,
    required this.duelType,
  });

  @override
  State<DuelEnCoursScreen> createState() => _DuelEnCoursScreenState();
}

class _DuelEnCoursScreenState extends State<DuelEnCoursScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _remainingTime = const Duration();
  int _scoreA = 0;
  int _scoreB = 0;
  bool _isFinished = false;
  bool _isPaused = false;
  final DateTime _duelStartTime = DateTime.now(); // Heure de début du duel
  
  // États caméra/micro (simulés)
  bool _cameraAOn = true;
  bool _cameraBOn = true;
  bool _microAOn = true;
  bool _microBOn = true;
  bool _isFrontCameraA = true; // true = frontale, false = arrière

  // Animation 3-2-1-GO
  bool _showCountdown = true;
  int _countdownValue = 3;
  String? _countdownText;

  late AnimationController _pulseAnimationController;
  late AnimationController _scoreAnimationController;
  late AnimationController _countdownAnimationController;
  late AnimationController _goAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countdownScaleAnimation;
  late Animation<double> _goScaleAnimation;

  final Random _random = Random();

  // Chemins vers les vidéos dans assets/videos/duel/
  // Les vidéos sont disponibles : squat.mp4, jump_rope.mp4
  // Pour activer les vidéos, remplacez null par le chemin
  static const String? videoPathA = 'assets/videos/duel/squat.mp4'; // Vidéo gauche
  static const String? videoPathB = 'assets/videos/duel/jump_rope.mp4'; // Vidéo droite

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;

    // Animation de pulsation pour le VS
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation pour les scores
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Animation pour le countdown 3-2-1
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _countdownScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _countdownAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Animation pour GO!
    _goAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _goScaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _goAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Lancer le countdown puis le duel
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseAnimationController.dispose();
    _scoreAnimationController.dispose();
    _countdownAnimationController.dispose();
    _goAnimationController.dispose();
    super.dispose();
  }

  /// Lance le countdown 3-2-1-GO avant de commencer le duel
  void _startCountdown() {
    _countdownValue = 3;
    _countdownText = '3';
    
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdownAnimationController.reset();
        _countdownAnimationController.forward();

        if (_countdownValue > 1) {
          _countdownValue--;
          _countdownText = '$_countdownValue';
          // Vibration simulée (optionnel)
          HapticFeedback.lightImpact();
        } else if (_countdownValue == 1) {
          _countdownValue = 0;
          _countdownText = 'GO!';
          _goAnimationController.forward();
          HapticFeedback.mediumImpact();
        } else {
          // Le countdown est terminé, on cache et on démarre le duel
          timer.cancel();
          _showCountdown = false;
          _pulseAnimationController.repeat(reverse: true);
          _startDuel();
        }
      });
    });
  }

  /// Démarre le duel avec timer et simulation de scores
  void _startDuel() {
    _remainingTime = widget.duration; // Réinitialiser le temps
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || _isFinished || _isPaused) return;

      setState(() {
        // Décrémenter le temps
        if (_remainingTime.inMilliseconds > 0) {
          _remainingTime = Duration(
            milliseconds: _remainingTime.inMilliseconds - 100,
          );
        } else {
          _remainingTime = Duration.zero;
        }

        // Simuler les scores toutes les 700ms environ (7 * 100ms)
        if (timer.tick % 7 == 0) {
          // Score A : légèrement favorisé si le coach A a un meilleur score
          final coachAScoreBonus = widget.coachA.score > 1000 ? 0.1 : 0.0;
          final scoreAIncrement = _random.nextInt(3) + (coachAScoreBonus > 0 ? 1 : 0);
          _scoreA += scoreAIncrement;

          // Score B : aléatoire
          final scoreBIncrement = _random.nextInt(3);
          _scoreB += scoreBIncrement;

          // Animation des scores
          _scoreAnimationController.forward(from: 0.0);
        }

        // Vérifier si le temps est écoulé
        if (_remainingTime.inMilliseconds <= 0) {
          _finishDuel();
        }
      });
    });
  }

  /// Termine le duel et calcule le résultat
  void _finishDuel() {
    if (_isFinished) return;

    _isFinished = true;
    _timer?.cancel();

    // Calculer le résultat et afficher le dialog
    final result = _computeResultFromScores();
    _showResultDialog(result);
  }

  /// Calcule le résultat du duel à partir des scores
  DuelResult _computeResultFromScores() {
    final winnerIsA = _scoreA >= _scoreB;
    final winnerScoreChange = winnerIsA ? 40 : 0; // +40 si coach gagne, 0 si élève gagne (pas de points pour élève)
    final loserScoreChange = winnerIsA ? 0 : -15; // -15 si coach perd, 0 si élève perd

    if (widget.opponent.isStudent) {
      // Coach vs Élève : seul le coach peut gagner/perdre des points
      final updatedWinner = widget.coachA.copyWith(
        score: (widget.coachA.score + winnerScoreChange).clamp(0, double.infinity).toInt(),
        wins: widget.coachA.wins + (winnerIsA ? 1 : 0),
        losses: widget.coachA.losses + (winnerIsA ? 0 : 1),
      );

      return DuelResult(
        winner: updatedWinner,
        loserCoach: null, // Élève ne peut pas être dans le classement
        loserStudentName: widget.opponent.studentName,
        loserIsStudent: true,
        challengeType: widget.challengeType,
        winnerScoreChange: winnerScoreChange,
        loserScoreChange: loserScoreChange,
      );
    } else {
      // Coach vs Coach
      final winner = winnerIsA ? widget.coachA : widget.opponent.coach!;
      final loser = winnerIsA ? widget.opponent.coach! : widget.coachA;
      
      final updatedWinner = winner.copyWith(
        score: (winner.score + winnerScoreChange).clamp(0, double.infinity).toInt(),
        wins: winner.wins + 1,
      );
      final updatedLoser = loser.copyWith(
        score: (loser.score + loserScoreChange).clamp(0, double.infinity).toInt(),
        losses: loser.losses + 1,
      );

      return DuelResult(
        winner: updatedWinner,
        loserCoach: updatedLoser,
        loserStudentName: null,
        loserIsStudent: false,
        challengeType: widget.challengeType,
        winnerScoreChange: winnerScoreChange,
        loserScoreChange: loserScoreChange,
      );
    }
  }

  /// Affiche le dialog de résultat (réutilise le style de duel_coach_page.dart)
  void _showResultDialog(DuelResult result) {
    final rankingNotifier = CoachRankingNotifier();
    final historyNotifier = DuelHistoryNotifier();

    // Mettre à jour les points dans le classement
    if (!result.loserIsStudent && result.loserCoach != null) {
      // Coach vs Coach : mettre à jour les deux coachs
      rankingNotifier.updateCoach(result.winner);
      rankingNotifier.updateCoach(result.loserCoach!);
    } else {
      // Coach vs Élève : mettre à jour seulement le coach (gagnant ou perdant)
      rankingNotifier.updateCoach(result.winner);
    }

    // Sauvegarder dans l'historique
    final duelHistory = DuelHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      coachA: widget.coachA,
      opponent: widget.opponent,
      challengeType: widget.challengeType,
      createdAt: _duelStartTime,
      completedAt: DateTime.now(),
      result: result,
      duelType: widget.duelType,
      scoreA: _scoreA,
      scoreB: _scoreB,
      duration: widget.duration,
    );
    historyNotifier.addDuel(duelHistory);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFFC300),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result.winner.name} gagne !',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Défi : ${result.challengeType}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Carte gagnant (verte)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.winner.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.winnerScoreChange > 0
                                ? '+${result.winnerScoreChange} points'
                                : '${result.winnerScoreChange} points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Carte perdant (rouge)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.shade200,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.loserName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${result.loserScoreChange} points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Fermer le dialog
                        Navigator.pop(context); // Retourner à Duel Coach
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111111),
                        side: const BorderSide(
                          color: Color(0xFF111111),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Nouveau duel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Fermer le dialog
                        Navigator.pop(context); // Retourner à Duel Coach
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
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
    );
  }

  /// Formate le temps restant en MM:SS
  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (_remainingTime.inMilliseconds / widget.duration.inMilliseconds);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Duel en cours'),
        centerTitle: true,
        elevation: 0,
        // Boutons caméra/micro pour Coach A (en haut à droite)
        actions: [
          _buildCameraMicroButton(isLeft: true),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
          children: [
            // Header avec timer et barre de progression
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF111111),
              child: Column(
                children: [
                  Text(
                    widget.challengeType,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(_remainingTime),
                    style: const TextStyle(
                      color: Color(0xFFFFC300),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC300)),
                    ),
                  ),
                ],
              ),
            ),

            // Zone centrale VS
            Expanded(
              child: Container(
                color: const Color(0xFF0B0B0B),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte Coach A (gauche)
                        Expanded(
                          child: SizedBox(
                            height: constraints.maxHeight,
                            child: _buildParticipantCard(
                              name: widget.coachA.name,
                              specialty: widget.coachA.specialty,
                              score: _scoreA,
                              isLeft: true,
                            ),
                          ),
                        ),

                        // VS au centre (plus compact)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    margin: const EdgeInsets.only(top: 80),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFC300),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFC300).withOpacity(0.5),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'VS',
                                        style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Carte Opponent (droite)
                        Expanded(
                          child: SizedBox(
                            height: constraints.maxHeight,
                            child: _buildParticipantCard(
                              name: widget.opponent.name,
                              specialty: widget.opponent.specialty ?? 'Élève',
                              score: _scoreB,
                              isLeft: false,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Boutons en bas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isFinished ? null : _finishDuel,
                      icon: const Icon(Icons.stop),
                      label: const Text('Terminer le duel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Abandonner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
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
            ),
          ],
        ),
            // Overlay countdown 3-2-1-GO
            if (_showCountdown) _buildCountdownOverlay(),
          ],
        ),
      ),
    );
  }

  /// Construit l'overlay du countdown 3-2-1-GO
  Widget _buildCountdownOverlay() {
    final isGo = _countdownText == 'GO!';
    final animation = isGo ? _goScaleAnimation : _countdownScaleAnimation;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: animation.value,
              child: Text(
                _countdownText ?? '3',
                style: TextStyle(
                  fontSize: isGo ? 80 : 100,
                  fontWeight: FontWeight.bold,
                  color: isGo ? const Color(0xFFFFC300) : Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 0),
                      blurRadius: 30,
                      color: isGo
                          ? const Color(0xFFFFC300).withOpacity(0.8)
                          : Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construit les boutons caméra/micro (pour la AppBar ou en bas de carte)
  Widget _buildCameraMicroButton({required bool isLeft}) {
    final cameraOn = isLeft ? _cameraAOn : _cameraBOn;
    final microOn = isLeft ? _microAOn : _microBOn;
    final isFrontCamera = isLeft ? _isFrontCameraA : true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton caméra (plus petit)
        IconButton(
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            cameraOn ? Icons.videocam : Icons.videocam_off,
            color: cameraOn ? Colors.white : Colors.red,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              if (isLeft) {
                _cameraAOn = !_cameraAOn;
              } else {
                _cameraBOn = !_cameraBOn;
              }
            });
            HapticFeedback.lightImpact();
          },
          tooltip: cameraOn ? 'Désactiver la caméra' : 'Activer la caméra',
        ),
        const SizedBox(width: 8),
        // Bouton micro (plus petit)
        IconButton(
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            microOn ? Icons.mic : Icons.mic_off,
            color: microOn ? Colors.white : Colors.red,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              if (isLeft) {
                _microAOn = !_microAOn;
              } else {
                _microBOn = !_microBOn;
              }
            });
            HapticFeedback.lightImpact();
          },
          tooltip: microOn ? 'Couper le micro' : 'Activer le micro',
        ),
        // Bouton swap caméra (uniquement si caméra activée)
        if (cameraOn) ...[
          const SizedBox(width: 8),
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              isFrontCamera ? Icons.camera_front : Icons.camera_rear,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                if (isLeft) {
                  _isFrontCameraA = !_isFrontCameraA;
                }
              });
              HapticFeedback.lightImpact();
            },
            tooltip: 'Changer de caméra',
          ),
        ],
      ],
    );
  }

  /// Construit une carte de participant (Coach A ou Opponent)
  Widget _buildParticipantCard({
    required String name,
    required String specialty,
    required int score,
    required bool isLeft,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(), // Empêche le scroll mais permet au contenu de s'adapter
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score avec animation (EN HAUT pour être toujours visible)
            AnimatedBuilder(
              animation: _scoreAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_scoreAnimationController.value * 0.1),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFC300),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC300).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Score',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: Color(0xFFFFC300),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Nom (au-dessus de la vidéo)
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),

            // Spécialité
            Text(
              specialty,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Placeholder vidéo avec support pour vidéos mp4 (réduit)
            DuelVideoPlaceholder(
              videoPath: isLeft ? videoPathA : videoPathB,
              isCameraOff: isLeft ? !_cameraAOn : !_cameraBOn,
              width: 140,
              height: 140,
            ),
            const SizedBox(height: 3),

            // Boutons caméra/micro pour ce participant (en dessous de la vidéo) - plus compacts
            SizedBox(
              height: 28,
              child: _buildCameraMicroButton(isLeft: isLeft),
            ),
            
            // Icône micro barré si micro off (optionnel) - masqué si pas de place
            if ((isLeft && !_microAOn) || (!isLeft && !_microBOn))
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_off,
                        size: 10,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'OFF',
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 7,
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
}

