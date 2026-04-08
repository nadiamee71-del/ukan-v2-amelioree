import 'package:flutter/material.dart';
import 'coach_personality_model.dart';
import 'coach_personality_notifier.dart';
import 'coach_audio_service.dart';

/// Page de sélection du coach vocal IA
class CoachPersonalityPage extends StatefulWidget {
  const CoachPersonalityPage({super.key});

  @override
  State<CoachPersonalityPage> createState() => _CoachPersonalityPageState();
}

class _CoachPersonalityPageState extends State<CoachPersonalityPage> {
  late CoachPersonalityNotifier _notifier;
  CoachPersonality? _previewCoach;

  @override
  void initState() {
    super.initState();
    _notifier = CoachPersonalityNotifier();
    _notifier.addListener(_onNotifierChanged);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    super.dispose();
  }

  void _onNotifierChanged() {
    setState(() {});
  }

  void _previewCoachPhrase(CoachPersonality coach) async {
    setState(() {
      _previewCoach = coach;
    });

    // Jouer un audio aléatoire si disponible
    final audioService = CoachAudioService();
    if (coach.audioPaths.isNotEmpty) {
      await audioService.playRandomAudio(coach);
    }

    // Afficher une bulle de prévisualisation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(coach.icon, color: coach.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                coach.examplePhrase,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D111C),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _selectCoach(CoachPersonality coach) async {
    _notifier.selectCoach(coach.style);
    _notifier.setEnabled(true);

    // Jouer un audio aléatoire si disponible
    final audioService = CoachAudioService();
    if (coach.audioPaths.isNotEmpty) {
      await audioService.playRandomAudio(coach);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: const Color(0xFFFFC300)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${coach.name} est maintenant ton coach !',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Retour après un court délai
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allCoaches = CoachPersonalityFactory.getAllCoaches();
    final currentCoach = _notifier.currentCoach;

    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D111C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Coach Vocal IA',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFC300).withOpacity(0.15),
                      const Color(0xFF0D111C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFC300).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFC300), Color(0xFFFFD633)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC300).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Color(0xFF050814),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choisis ton coach vocal IA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Il t\'accompagnera pendant tes exercices avec des phrases motivantes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Liste des coaches
              ...allCoaches.map((coach) {
                final isSelected = currentCoach?.style == coach.style;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _CoachCard(
                    coach: coach,
                    isSelected: isSelected,
                    onPreview: () => _previewCoachPhrase(coach),
                    onSelect: () => _selectCoach(coach),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte d'un coach
class _CoachCard extends StatefulWidget {
  final CoachPersonality coach;
  final bool isSelected;
  final VoidCallback onPreview;
  final VoidCallback onSelect;

  const _CoachCard({
    required this.coach,
    required this.isSelected,
    required this.onPreview,
    required this.onSelect,
  });

  @override
  State<_CoachCard> createState() => _CoachCardState();
}

class _CoachCardState extends State<_CoachCard> {
  final CoachAudioService _audioService = CoachAudioService();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    // Écouter les changements d'état de lecture audio
    // Note: audioplayers ne fournit pas de stream direct, on gère manuellement
  }

  Future<void> _playAudio() async {
    if (widget.coach.audioPaths.isEmpty) {
      // Si pas d'audio, utiliser la prévisualisation normale
      widget.onPreview();
      return;
    }

    if (_isPlayingAudio) {
      // Arrêter la lecture si déjà en cours
      await _audioService.stop();
      setState(() {
        _isPlayingAudio = false;
      });
      return;
    }

    // CRITIQUE : Marquer l'interaction utilisateur AVANT de jouer l'audio
    // C'est nécessaire pour que l'audio fonctionne sur mobile web
    _audioService.markUserInteraction();

    setState(() {
      _isPlayingAudio = true;
    });

    try {
      await _audioService.playRandomAudio(widget.coach);
      // Vérifier après un délai si l'audio joue vraiment
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_audioService.isPlaying) {
        // Si l'audio ne joue pas, réessayer
        debugPrint('⚠️ Audio ne joue pas, nouvelle tentative...');
        await _audioService.playRandomAudio(widget.coach);
      }
    } catch (e) {
      debugPrint('❌ Erreur lecture audio: $e');
      setState(() {
        _isPlayingAudio = false;
      });
    }

    // Simuler la fin de lecture après un délai (approximatif)
    // En production, on pourrait utiliser un stream pour détecter la fin
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D111C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isSelected
              ? widget.coach.color
              : Colors.white.withOpacity(0.1),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? widget.coach.color.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec icône et nom
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.coach.color,
                        widget.coach.color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.coach.color.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.coach.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.coach.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (widget.isSelected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ACTIF',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF050814),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.coach.style.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Exemple de phrase
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: widget.coach.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"${widget.coach.examplePhrase}"',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Boutons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.coach.audioPaths.isNotEmpty
                        ? _playAudio
                        : widget.onPreview,
                    icon: Icon(
                      _isPlayingAudio ? Icons.stop_rounded : Icons.volume_up_rounded,
                      size: 18,
                    ),
                    label: Text(
                      widget.coach.audioPaths.isNotEmpty
                          ? (_isPlayingAudio ? 'Arrêter' : 'Écouter la voix')
                          : 'Prévisualiser',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: widget.onSelect,
                    icon: Icon(
                      widget.isSelected ? Icons.check_circle : Icons.person_add_rounded,
                      size: 18,
                    ),
                    label: Text(widget.isSelected ? 'Sélectionné' : 'Sélectionner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isSelected
                          ? widget.coach.color.withOpacity(0.3)
                          : widget.coach.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
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







