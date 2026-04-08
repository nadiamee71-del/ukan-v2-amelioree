import 'package:flutter/foundation.dart';
import 'coach_personality_model.dart';

/// Notifier singleton pour gérer le coach vocal IA sélectionné
class CoachPersonalityNotifier extends ChangeNotifier {
  static final CoachPersonalityNotifier _instance =
      CoachPersonalityNotifier._internal();
  factory CoachPersonalityNotifier() => _instance;
  CoachPersonalityNotifier._internal();

  CoachPersonality? _currentCoach;
  bool _isEnabled = false;

  /// Coach actuellement sélectionné
  CoachPersonality? get currentCoach => _currentCoach;

  /// Est-ce que le coach est activé
  bool get isEnabled => _isEnabled && _currentCoach != null;

  /// Sélectionne un coach par son style
  void selectCoach(CoachStyle style) {
    CoachPersonality? newCoach;
    switch (style) {
      case CoachStyle.gentle:
        newCoach = CoachPersonalityFactory.createGentle();
        break;
      case CoachStyle.hard:
        newCoach = CoachPersonalityFactory.createHard();
        break;
      case CoachStyle.military:
        newCoach = CoachPersonalityFactory.createMilitary();
        break;
      case CoachStyle.humor:
        newCoach = CoachPersonalityFactory.createHumor();
        break;
    }
    _currentCoach = newCoach;
    notifyListeners();
  }

  /// Active ou désactive le coach
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
  }

  /// Récupère une phrase selon le progrès de l'exercice (0.0 - 1.0)
  /// 
  /// - progress < 0.2 : phaseStart (début)
  /// - 0.2 <= progress < 0.7 : phaseMiddle (milieu)
  /// - 0.7 <= progress < 0.95 : phaseAlmostDone (presque fini)
  /// - progress >= 0.95 : phaseEnd (fin)
  String? getPhraseForProgress(double progress) {
    if (!isEnabled || _currentCoach == null) return null;
    
    // Clamp progress entre 0.0 et 1.0
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    return _currentCoach!.getPhraseForProgress(clampedProgress);
  }

  /// Réinitialise le coach (désélectionne)
  void reset() {
    _currentCoach = null;
    _isEnabled = false;
    notifyListeners();
  }
}







