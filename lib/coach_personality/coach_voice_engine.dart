import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/coach_personality.dart';
import 'coach_messages.dart';

/// Service pour la voix du coach avec synthèse vocale
class CoachVoiceEngine {
  static final CoachVoiceEngine _instance = CoachVoiceEngine._internal();
  factory CoachVoiceEngine() => _instance;
  CoachVoiceEngine._internal() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isCurrentlySpeaking = false;

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.5); // Vitesse par défaut
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  /// Configure la voix selon le style de coach
  Future<void> _configureVoiceForStyle(String tone) async {
    if (!_isInitialized) await _initTts();

    switch (tone) {
      case 'gentil':
        // Voix douce et bienveillante
        await _flutterTts.setSpeechRate(0.45); // Plus lent
        await _flutterTts.setPitch(1.2); // Plus aigu (voix plus douce)
        await _flutterTts.setVolume(0.9);
        break;
      case 'dur':
        // Voix forte et exigeante
        await _flutterTts.setSpeechRate(0.6); // Plus rapide
        await _flutterTts.setPitch(0.8); // Plus grave (voix plus autoritaire)
        await _flutterTts.setVolume(1.0);
        break;
      case 'militaire':
        // Voix autoritaire et disciplinée
        await _flutterTts.setSpeechRate(0.55); // Rapide et net
        await _flutterTts.setPitch(0.9); // Grave et ferme
        await _flutterTts.setVolume(1.0);
        break;
      case 'humour':
        // Voix décontractée et fun
        await _flutterTts.setSpeechRate(0.5); // Normal
        await _flutterTts.setPitch(1.1); // Légèrement aigu (voix joyeuse)
        await _flutterTts.setVolume(1.0);
        break;
      default:
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setVolume(1.0);
    }
  }

  /// Lit un message de motivation avec la voix adaptée au style
  Future<void> speakMotivationMessage(String tone, {String? customMessage}) async {
    if (!_isInitialized) await _initTts();

    // Configurer la voix selon le style
    await _configureVoiceForStyle(tone);

    // Obtenir le message
    final message = customMessage ?? CoachMessages.getMotivationMessage(tone);
    
    // Nettoyer le message (enlever les emojis pour la synthèse vocale)
    final cleanMessage = _removeEmojis(message);

    // Marquer comme en train de parler
    _isCurrentlySpeaking = true;

    // Parler
    await _flutterTts.speak(cleanMessage);
  }

  /// Lit le message du jour du coach actuel
  Future<void> speakDailyMessage(CoachPersonality personality, {VoidCallback? onComplete}) async {
    // Configurer le callback de fin
    if (onComplete != null) {
      _flutterTts.setCompletionHandler(() {
        _isCurrentlySpeaking = false;
        onComplete();
      });
    } else {
      _flutterTts.setCompletionHandler(() {
        _isCurrentlySpeaking = false;
      });
    }
    
    await speakMotivationMessage(personality.tone);
  }

  /// Arrête la lecture en cours
  Future<void> stop() async {
    await _flutterTts.stop();
    _isCurrentlySpeaking = false;
  }

  /// Vérifie si la voix est en train de parler
  bool isSpeaking() {
    return _isCurrentlySpeaking;
  }

  /// Enlève les emojis du texte pour la synthèse vocale
  String _removeEmojis(String text) {
    // Pattern simple pour enlever les emojis courants
    return text
        .replaceAll(RegExp(r'[💪✨🌟🔥💀🪖😂😄🍕]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

