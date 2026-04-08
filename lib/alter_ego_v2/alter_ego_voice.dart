import 'package:flutter_tts/flutter_tts.dart';
import 'alter_ego_messages.dart';
import '../coach_personality/coach_personality_notifier.dart';
import '../coach_personality/coach_personality_model.dart';

class AlterEgoVoiceService {
  AlterEgoVoiceService._internal();
  static final AlterEgoVoiceService instance = AlterEgoVoiceService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  CoachStyle currentStyle = CoachStyle.gentle;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _tts.setLanguage("fr-FR");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.52);
  }

  Future<void> setStyle(CoachStyle style) async {
    currentStyle = style;
  }

  /// Charge le style depuis CoachPersonalityNotifier
  Future<void> loadStyleFromNotifier() async {
    final notifier = CoachPersonalityNotifier();
    if (notifier.currentCoach != null) {
      currentStyle = notifier.currentCoach!.style;
    }
  }

  Future<String> speakForPhase(MessagePhase phase) async {
    await init();
    await loadStyleFromNotifier();
    
    final text = AlterEgoMessages.randomFor(currentStyle, phase);
    if (text.isEmpty) return "";
    
    await _tts.stop();
    await _tts.speak(text);
    
    return text;
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}

