import 'dart:async';
import 'package:flutter/material.dart';
import 'alter_ego.dart';

/// Liste des duels/exercices disponibles
class DuelExercises {
  static final List<AlterEgoDuelConfig> allDuels = const [
    AlterEgoDuelConfig(
      label: '🔥 Sprint 30 sec',
      targetSeconds: 30,
    ),
    AlterEgoDuelConfig(
      label: '🧱 Gainage 45 sec',
      targetSeconds: 45,
    ),
    AlterEgoDuelConfig(
      label: '🪑 Chaise 60 sec',
      targetSeconds: 60,
    ),
    AlterEgoDuelConfig(
      label: '💪 Pompes 30 sec',
      targetSeconds: 30,
    ),
    AlterEgoDuelConfig(
      label: '🏃 Burpees 45 sec',
      targetSeconds: 45,
    ),
    AlterEgoDuelConfig(
      label: '🤸 Squats 60 sec',
      targetSeconds: 60,
    ),
    AlterEgoDuelConfig(
      label: '⏱️ Sprint 20 sec',
      targetSeconds: 20,
    ),
    AlterEgoDuelConfig(
      label: '🧘 Gainage 90 sec',
      targetSeconds: 90,
    ),
  ];
}

class AlterEgoDuelScreen extends StatefulWidget {
  final AlterEgoDuelConfig? duelConfig; // Optionnel maintenant

  const AlterEgoDuelScreen({
    super.key,
    this.duelConfig,
  });

  @override
  State<AlterEgoDuelScreen> createState() => _AlterEgoDuelScreenState();
}

class _AlterEgoDuelScreenState extends State<AlterEgoDuelScreen>
    with TickerProviderStateMixin {
  AlterEgoDuelConfig? _selectedDuel;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  bool _voiceEnabled = false;
  String? _coachMessage;
  bool _hasShownMid = false;
  bool _hasShownFinal = false;
  late AnimationController _alterEgoAnimationController;
  late AnimationController _resultAnimationController;
  String _userAvatarImage = 'assets/images/mon_profil_neutre.png';
  String _alterEgoAvatarImage = 'assets/images/alter_ego_neutre.png';
  String? _resultMessage;
  bool? _hasWon; // null = pas encore de résultat, true = victoire, false = défaite

  @override
  void initState() {
    super.initState();
    // Si un duel est fourni, l'utiliser, sinon sélectionner le premier par défaut
    _selectedDuel = widget.duelConfig ?? DuelExercises.allDuels[1]; // Gainage 45 sec par défaut
    
    // Animation pour l'Alter Ego lors du résultat
    _alterEgoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Animation pour le résultat (scale et glow)
    _resultAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _alterEgoAnimationController.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  void _selectDuel(AlterEgoDuelConfig config) {
    if (_isRunning) {
      // Ne pas changer de duel pendant que le chrono tourne
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Arrête le chrono avant de changer de duel"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _selectedDuel = config;
      _elapsedSeconds = 0;
      _hasShownMid = false;
      _hasShownFinal = false;
      _coachMessage = null;
      // Réinitialiser les avatars à l'état neutre
      _userAvatarImage = 'assets/images/mon_profil_neutre.png';
      _alterEgoAvatarImage = 'assets/images/alter_ego_neutre.png';
      _resultMessage = null;
      _hasWon = null;
      _alterEgoAnimationController.reset();
      _resultAnimationController.reset();
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      // Arrêt prématuré (Pause) - ne pas évaluer, juste mettre en pause
      _timer?.cancel();
      final bool wasPremature = _elapsedSeconds > 0 && _elapsedSeconds < _selectedDuel!.targetSeconds;
      
      setState(() {
        _isRunning = false;
        
        // Si arrêt prématuré : Alter Ego montre frustration, Moi reste neutre
        if (wasPremature) {
          _alterEgoAvatarImage = 'assets/images/alter_ego_alerte.png';
          _userAvatarImage = 'assets/images/mon_profil_neutre.png';
          _resultMessage = null;
          _hasWon = null;
          _resultAnimationController.reset();
        } else if (_elapsedSeconds >= _selectedDuel!.targetSeconds) {
          // Si l'objectif était atteint, réinitialiser pour permettre le rejeu
          _userAvatarImage = 'assets/images/mon_profil_neutre.png';
          _alterEgoAvatarImage = 'assets/images/alter_ego_neutre.png';
          _resultMessage = null;
          _hasWon = null;
        }
      });
      
      // Animation de frustration pour l'arrêt prématuré
      if (wasPremature) {
        _alterEgoAnimationController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              _alterEgoAnimationController.reverse();
            }
          });
        });
      }
      return;
    }

    // Démarrage : Réinitialiser les avatars à l'état neutre
    setState(() {
      _isRunning = true;
      _elapsedSeconds = 0;
      _hasShownMid = false;
      _hasShownFinal = false;
      _coachMessage = null;
      _userAvatarImage = 'assets/images/mon_profil_neutre.png';
      _alterEgoAvatarImage = 'assets/images/alter_ego_neutre.png';
      _resultMessage = null;
      _hasWon = null;
      _alterEgoAnimationController.reset();
      _resultAnimationController.reset();
    });

    // Message de départ si voix activée
    if (_voiceEnabled) {
      setState(() {
        _coachMessage = "Allez, on commence fort 💥";
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _coachMessage == "Allez, on commence fort 💥") {
          setState(() {
            _coachMessage = null;
          });
        }
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _elapsedSeconds++;
      });

      // Arrêt automatique du chronomètre quand la durée cible est atteinte
      if (_elapsedSeconds >= _selectedDuel!.targetSeconds) {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
        // Évaluer automatiquement le résultat
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _stopAndEvaluate();
          }
        });
        return;
      }

      // Messages du coach selon le temps
      if (_voiceEnabled) {
        final midPoint = _selectedDuel!.targetSeconds ~/ 2;
        final finalPoint = _selectedDuel!.targetSeconds - 5;

        // Milieu
        if (_elapsedSeconds == midPoint && !_hasShownMid) {
          _hasShownMid = true;
          setState(() {
            _coachMessage = "Tu es à mi-chemin, lâche rien !";
          });
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              setState(() {
                _coachMessage = null;
              });
            }
          });
        }

        // 5 secondes avant la fin
        if (_elapsedSeconds == finalPoint && !_hasShownFinal) {
          _hasShownFinal = true;
          setState(() {
            _coachMessage = "Encore 5 secondes, accroche-toi !";
          });
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              setState(() {
                _coachMessage = null;
              });
            }
          });
        }
      }
    });
  }

  void _handleStop() {
    if (_voiceEnabled && _isRunning) {
      setState(() {
        _coachMessage = "Fin de la série, ton Alter Ego prend des notes… 📓";
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _coachMessage = null;
          });
          _stopAndEvaluate();
        }
      });
    } else {
      _stopAndEvaluate();
    }
  }

  void _toggleVoice() {
    setState(() {
      _voiceEnabled = !_voiceEnabled;
      if (!_voiceEnabled) {
        _coachMessage = null;
      }
    });
  }

  void _stopAndEvaluate() {
    // Ne pas évaluer si le chrono n'a pas été lancé ou s'il est à zéro
    if (_elapsedSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lance le chrono avant d'évaluer le résultat"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    final int targetSeconds = _selectedDuel!.targetSeconds;
    final int diff = _elapsedSeconds - targetSeconds;
    final bool win = _elapsedSeconds >= targetSeconds;

    // Déclencher l'animation et changer les poses selon le résultat
    _hasWon = win;
    
    if (win) {
      // VICTOIRE : Utilisateur bat l'Alter Ego
      setState(() {
        _userAvatarImage = 'assets/images/mon_profil_gagnant.png'; // Pose victoire pour "Moi"
        _alterEgoAvatarImage = 'assets/images/alter_ego_reflechit.png'; // Pose surprise/réflexion quand l'utilisateur gagne
        _resultMessage = "Bravo ! Tu as gagné ! Tu es plus fort que ton moi futur aujourd'hui ! 🎉💪";
      });
    } else {
      // DÉFAITE : Alter Ego bat l'utilisateur
      setState(() {
        _userAvatarImage = 'assets/images/mon_profil_perdant.png'; // Pose défaite pour "Moi"
        _alterEgoAvatarImage = 'assets/images/alter_ego_encourage.png'; // Pose victoire/encouragement (non modifié)
        _resultMessage = "Pas grave ! Ton moi futur t'a battu cette fois, mais continue et tu vas y arriver ! 💪🔥";
      });
    }

    // Lancer les animations
    _alterEgoAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _alterEgoAnimationController.reverse();
        }
      });
    });
    
    _resultAnimationController.forward();

    // Afficher le dialogue après un court délai pour voir les animations
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      String title;
      String message;
      if (win) {
        title = "Victoire sur ton moi futur 🎉";
        if (diff == 0) {
          message =
              "Score parfait : tu égales exactement ton moi futur.\nC'est ton clone !";
        } else {
          message =
              "Tu bats ton moi futur de ${diff} seconde${diff > 1 ? 's' : ''}.\nExcellent travail !";
        }
      } else {
        title = "Ton futur t'a battu aujourd'hui 😅";
        message =
            "Il te manque encore ${diff.abs()} seconde${diff.abs() > 1 ? 's' : ''} pour battre ton moi futur.\nContinue comme ça, tu vas y arriver !";
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF050814),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Réinitialiser pour rejouer
                  setState(() {
                    _elapsedSeconds = 0;
                    _userAvatarImage = 'assets/images/mon_profil_neutre.png';
                    _alterEgoAvatarImage = 'assets/images/alter_ego_neutre.png';
                    _resultMessage = null;
                    _hasWon = null;
                    _resultAnimationController.reset();
                  });
                },
                child: const Text(
                  "Rejouer",
                  style: TextStyle(color: Colors.cyanAccent),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Retour à AlterEgoScreen
                },
                child: const Text(
                  "Nouveau duel",
                  style: TextStyle(color: Colors.cyanAccent),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Fermer",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  String _formatSeconds(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDuel == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF050814),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050814),
        elevation: 0,
        title: const Text("Mode Duel"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Section : Liste des duels/exercices disponibles
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1020),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Choisis ton défi",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sélectionne un exercice pour affronter ton moi futur",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // Grille de duels
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: DuelExercises.allDuels.map((duel) {
                      final isSelected = _selectedDuel?.label == duel.label;
                      return GestureDetector(
                        onTap: () => _selectDuel(duel),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.cyanAccent.withOpacity(0.2)
                                : const Color(0xFF1A1F2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.cyanAccent
                                  : Colors.white.withOpacity(0.2),
                              width: isSelected ? 2 : 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                duel.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.cyanAccent
                                      : Colors.white70,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${duel.targetSeconds}s",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.cyanAccent.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Description avec le label du duel sélectionné
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1020),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Affronte ton moi futur sur : ${_selectedDuel!.label}",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tiens l'effort jusqu'à ${_selectedDuel!.targetSeconds} secondes, essaye de battre ton moi futur.",
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Message du coach (si activé)
            if (_coachMessage != null) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_coachMessage),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFC300).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: const Color(0xFFFFC300),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _coachMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Layout responsive : Row sur desktop, Column sur mobile
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildAvatarCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildChronoCard()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildAvatarCard(),
                      const SizedBox(height: 16),
                      _buildChronoCard(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 30),

            // Bouton activation voix
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _voiceEnabled
                    ? const Color(0xFFFFC300).withOpacity(0.2)
                    : const Color(0xFF0B1020),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _voiceEnabled
                      ? const Color(0xFFFFC300)
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: _toggleVoice,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _voiceEnabled
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      color: _voiceEnabled
                          ? const Color(0xFFFFC300)
                          : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _voiceEnabled
                          ? "🎙️ Voix du coach activée (démo)"
                          : "🔇 Activer la voix du coach",
                      style: TextStyle(
                        color: _voiceEnabled
                            ? const Color(0xFFFFC300)
                            : Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard() {
    // Données de comparaison (exemple)
    final stats = {
      'poids': {'moi': 77, 'alterEgo': 73},
      'sport': {'moi': 85, 'alterEgo': 105},
      'endurance': {'moi': 65, 'alterEgo': 77},
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titre amélioré
          const Text(
            "Face à Ton Futur Moi !",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Deux avatars côte à côte avec élément VS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Avatar "Moi aujourd'hui"
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                CurvedAnimation(parent: animation, curve: Curves.easeOut),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: ClipOval(
                          key: ValueKey(_userAvatarImage),
                          child: Image.asset(
                            _userAvatarImage,
                            fit: BoxFit.contain,
                            width: 150,
                            height: 150,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback selon le type d'image demandée pour l'avatar "Moi"
                              if (_userAvatarImage.contains('gagnant')) {
                                // Image de victoire : fallback vers neutre avec effet vert
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/mon_profil_neutre.png',
                                    fit: BoxFit.contain,
                                    width: 150,
                                    height: 150,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFF1A1F2E),
                                        child: const Icon(
                                          Icons.celebration,
                                          color: Colors.green,
                                          size: 70,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else if (_userAvatarImage.contains('perdant')) {
                                // Image de défaite : fallback vers neutre avec effet orange
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/mon_profil_neutre.png',
                                    fit: BoxFit.contain,
                                    width: 150,
                                    height: 150,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFF1A1F2E),
                                        child: const Icon(
                                          Icons.sentiment_dissatisfied,
                                          color: Colors.orange,
                                          size: 70,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                // Image neutre : fallback standard
                                return Image.asset(
                                  'assets/images/mon_profil_neutre.png',
                                  fit: BoxFit.contain,
                                  width: 150,
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF1A1F2E),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white70,
                                        size: 70,
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Moi aujourd'hui",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Élément VS graphique
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFC300),
                          Color(0xFFFF9800),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC300).withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "VS",
                        style: TextStyle(
                          color: Color(0xFF050814),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Avatar "Mon Alter Ego" avec animation
              Expanded(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _alterEgoAnimationController,
                        _resultAnimationController,
                      ]),
                      builder: (context, child) {
                        final resultGlow = _resultAnimationController.value;
                        final alterEgoScale = 1.0 +
                            (_alterEgoAnimationController.value * 0.15);
                        final resultScale = 1.0 + (resultGlow * 0.1);
                        
                        return Transform.scale(
                          scale: alterEgoScale * resultScale,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hasWon == true 
                                    ? Colors.red.withOpacity(0.6) // Rouge si défaite Alter Ego
                                    : _hasWon == false
                                        ? Colors.green.withOpacity(0.6) // Vert si victoire Alter Ego
                                        : Colors.cyanAccent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _hasWon == true
                                      ? Colors.red.withOpacity(0.4 + (resultGlow * 0.2))
                                      : _hasWon == false
                                          ? Colors.green.withOpacity(0.4 + (resultGlow * 0.2))
                                          : Colors.cyanAccent
                                              .withOpacity(0.5 + (_alterEgoAnimationController.value * 0.3)),
                                  blurRadius: 18 + (resultGlow * 15),
                                  spreadRadius: 3 + (resultGlow * 4),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child: ClipOval(
                                key: ValueKey(_alterEgoAvatarImage),
                                child: Image.asset(
                                  _alterEgoAvatarImage,
                                  fit: BoxFit.contain,
                                  width: 150,
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback vers neutre si l'image n'existe pas
                                    return Image.asset(
                                      'assets/images/alter_ego_neutre.png',
                                      fit: BoxFit.contain,
                                      width: 150,
                                      height: 150,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: const Color(0xFF0B1020),
                                          child: const Icon(
                                            Icons.face,
                                            color: Colors.cyanAccent,
                                            size: 70,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Mon Alter Ego",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

            const SizedBox(height: 28),

          // Message du résultat (bulle de dialogue)
          if (_resultMessage != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(_resultMessage),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _hasWon == true
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hasWon == true
                        ? Colors.green.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasWon == true ? Icons.celebration : Icons.thumb_up,
                      color: _hasWon == true ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _resultMessage!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Statistiques comparatives avec barres de progression
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poids
              _buildStatRow(
                icon: Icons.monitor_weight_rounded,
                label: 'Poids',
                moiValue: stats['poids']!['moi']!,
                alterEgoValue: stats['poids']!['alterEgo']!,
                unit: 'kg',
                isLowerBetter: true,
              ),
              const SizedBox(height: 16),
              // Sport (Force)
              _buildStatRow(
                icon: Icons.fitness_center_rounded,
                label: 'Force',
                moiValue: stats['sport']!['moi']!,
                alterEgoValue: stats['sport']!['alterEgo']!,
                unit: 'kg',
                isLowerBetter: false,
              ),
              const SizedBox(height: 16),
              // Endurance
              _buildStatRow(
                icon: Icons.directions_run_rounded,
                label: 'Endurance',
                moiValue: stats['endurance']!['moi']!,
                alterEgoValue: stats['endurance']!['alterEgo']!,
                unit: '%',
                isLowerBetter: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required int moiValue,
    required int alterEgoValue,
    required String unit,
    required bool isLowerBetter,
  }) {
    final maxValue = [moiValue, alterEgoValue].reduce((a, b) => a > b ? a : b);
    final moiProgress = moiValue / (maxValue * 1.2); // Pour avoir de la marge
    final alterEgoProgress = alterEgoValue / (maxValue * 1.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Barre "Moi"
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$moiValue$unit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Moi',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: moiProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$alterEgoValue$unit',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Alter Ego',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: alterEgoProgress,
                      minHeight: 8,
                      backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.cyanAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChronoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Objectif de ton moi futur",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_selectedDuel!.targetSeconds}s",
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Boutons Start/Stop au-dessus du chrono
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRunning ? Colors.redAccent : Colors.cyanAccent,
                    foregroundColor:
                        _isRunning ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(_isRunning ? "Pause" : "Start"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleStop,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyanAccent,
                    side: const BorderSide(color: Colors.cyanAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Stop / Résultat"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Ton chrono",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.cyanAccent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _formatSeconds(_elapsedSeconds),
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRunning
                ? "Appuie sur STOP quand tu as fini 🔥"
                : "Appuie sur START et lance ton effort",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
