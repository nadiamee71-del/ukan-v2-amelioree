import 'package:flutter/material.dart';
import 'dart:math';
import '../data/coach_vocal_ia_audios.dart';

/// Style de coach disponible
enum CoachStyle {
  gentle,
  hard,
  military,
  humor;

  String get displayName {
    switch (this) {
      case CoachStyle.gentle:
        return 'Gentil';
      case CoachStyle.hard:
        return 'Dur';
      case CoachStyle.military:
        return 'Militaire';
      case CoachStyle.humor:
        return 'Humour';
    }
  }

  String get description {
    switch (this) {
      case CoachStyle.gentle:
        return 'Bienveillant et encourageant';
      case CoachStyle.hard:
        return 'Exigeant et motivant';
      case CoachStyle.military:
        return 'Discipliné et structuré';
      case CoachStyle.humor:
        return 'Décontracté et drôle';
    }
  }

  IconData get icon {
    switch (this) {
      case CoachStyle.gentle:
        return Icons.favorite_rounded;
      case CoachStyle.hard:
        return Icons.whatshot_rounded;
      case CoachStyle.military:
        return Icons.military_tech_rounded;
      case CoachStyle.humor:
        return Icons.sentiment_very_satisfied_rounded;
    }
  }

  Color get color {
    switch (this) {
      case CoachStyle.gentle:
        return Colors.pink.shade400;
      case CoachStyle.hard:
        return Colors.red.shade600;
      case CoachStyle.military:
        return Colors.green.shade700;
      case CoachStyle.humor:
        return Colors.orange.shade600;
    }
  }
}

/// Phrases du coach organisées par phase
class CoachPhrases {
  final List<String> start; // 0.0 - 0.2
  final List<String> middle; // 0.2 - 0.7
  final List<String> almostDone; // 0.7 - 0.95
  final List<String> end; // 0.95 - 1.0

  const CoachPhrases({
    required this.start,
    required this.middle,
    required this.almostDone,
    required this.end,
  });

  /// Récupère une phrase aléatoire pour une phase donnée
  String getRandomPhraseForPhase(double progress) {
    final random = Random();
    if (progress < 0.2) {
      return start[random.nextInt(start.length)];
    } else if (progress < 0.7) {
      return middle[random.nextInt(middle.length)];
    } else if (progress < 0.95) {
      return almostDone[random.nextInt(almostDone.length)];
    } else {
      return end[random.nextInt(end.length)];
    }
  }
}

/// Personnalité complète d'un coach
class CoachPersonality {
  final CoachStyle style;
  final String name;
  final IconData icon;
  final Color color;
  final CoachPhrases phrases;
  final List<String> audioPaths;

  const CoachPersonality({
    required this.style,
    required this.name,
    required this.icon,
    required this.color,
    required this.phrases,
    required this.audioPaths,
  });

  /// Récupère une phrase selon le progrès (0.0 - 1.0)
  String getPhraseForProgress(double progress) {
    return phrases.getRandomPhraseForPhase(progress);
  }

  /// Exemple de phrase pour l'aperçu
  String get examplePhrase => phrases.middle.first;

  /// Récupère un chemin audio aléatoire
  String? getRandomAudioPath() {
    if (audioPaths.isEmpty) return null;
    final random = Random();
    return audioPaths[random.nextInt(audioPaths.length)];
  }
}

/// Factory pour créer les coaches disponibles
class CoachPersonalityFactory {
  static CoachPersonality createGentle() {
    return CoachPersonality(
      style: CoachStyle.gentle,
      name: 'Coach Gentil',
      icon: Icons.favorite_rounded,
      color: Colors.pink.shade400,
      audioPaths: const [
        'assets/audios/coach_vocal_ia/ElevenLabs 11111111.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs 22222222.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs 33333333.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs 44444444.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs 55555555.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs 66666666.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs 77777777.mp3',
      ],
      phrases: const CoachPhrases(
        start: [
          'Super boulot, continue comme ça !',
          'Tu progresses vraiment bien !',
          'C\'est parfait, tu es sur la bonne voie !',
        ],
        middle: [
          'Je sais que c\'était dur, mais tu l\'as fait !',
          'Encore un peu, tu y arrives !',
          'Tu as assuré aujourd\'hui !',
        ],
        almostDone: [
          'Excellent travail !',
          'Tu progresses vraiment bien !',
          'Super boulot, continue comme ça !',
        ],
        end: [
          'Excellent travail !',
          'Tu as assuré aujourd\'hui !',
          'C\'est parfait, tu es sur la bonne voie !',
        ],
      ),
    );
  }

  static CoachPersonality createHard() {
    return CoachPersonality(
      style: CoachStyle.hard,
      name: 'Coach Dur',
      icon: Icons.whatshot_rounded,
      color: Colors.red.shade600,
      audioPaths: const [
        'assets/audios/coach_vocal_ia/ElevenLabs coach dur 1.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs coach dur 2.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs coach dur 3.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs coach dur 4.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs coach dur 5.mp3',
        'assets/audios/coach_vocal_ia/ElevenLabs coach dur 6.mp3',
      ],
      phrases: const CoachPhrases(
        start: [
          'Tu n\'en es qu\'à ça ? Allez continue !',
          'Bouge-toi, ce n\'est pas encore assez !',
        ],
        middle: [
          'Ça t\'a fatigué ? Normal, continue !',
          'Pas mal, mais tu peux faire mieux !',
        ],
        almostDone: [
          'Tu as survécu… la prochaine fois on monte le niveau !',
          'Bouge-toi, ce n\'est pas encore assez !',
        ],
        end: [
          'Tu as survécu… la prochaine fois on monte le niveau !',
          'Pas mal, mais tu peux faire mieux !',
        ],
      ),
    );
  }

  static CoachPersonality createMilitary() {
    return CoachPersonality(
      style: CoachStyle.military,
      name: 'Coach Militaire',
      icon: Icons.military_tech_rounded,
      color: Colors.green.shade700,
      audioPaths: kMilitaryCoachAudios,
      phrases: const CoachPhrases(
        start: [
          'Allez soldat ! On continue !',
          'On ne s\'arrête pas !',
        ],
        middle: [
          'C\'est dur ? Normal !',
          'Aucune faiblesse !',
        ],
        almostDone: [
          'Bien joué, mais demain plus fort !',
          'On ne s\'arrête pas !',
        ],
        end: [
          'Bien joué, mais demain plus fort !',
          'Allez soldat ! On continue !',
        ],
      ),
    );
  }

  static CoachPersonality createHumor() {
    return CoachPersonality(
      style: CoachStyle.humor,
      name: 'Coach Drôle',
      icon: Icons.sentiment_very_satisfied_rounded,
      color: Colors.orange.shade600,
      audioPaths: kFunnyCoachAudios,
      phrases: const CoachPhrases(
        start: [
          'Même ton canapé serait fier !',
          'Tes chaussettes dansent de joie !',
        ],
        middle: [
          'Ça chauffe hein ? Bon signe !',
          'Tu as survécu !',
        ],
        almostDone: [
          'Si tu tombes demain, c\'est pour les muscles !',
          'Ça chauffe hein ? Bon signe !',
        ],
        end: [
          'Si tu tombes demain, c\'est pour les muscles !',
          'Même ton canapé serait fier !',
        ],
      ),
    );
  }

  /// Liste de tous les coaches disponibles
  static List<CoachPersonality> getAllCoaches() {
    return [
      createGentle(),
      createHard(),
      createMilitary(),
      createHumor(),
    ];
  }
}







