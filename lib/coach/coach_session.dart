import 'package:shared_preferences/shared_preferences.dart';

/// Identité du coach connecté (démo locale).
///
/// Toutes les pages de l'espace coach (dashboard, disponibilités, profil
/// public, contenus, réservations) référencent `CoachSession().coachId`
/// au lieu d'un identifiant codé en dur. La valeur est persistée dans
/// SharedPreferences (clé `fitpro_coach_id`).
///
/// Pour la démo, l'identifiant stable par défaut est `coach_1` : à
/// l'inscription d'un coach, son identité écrase ce profil dans la source
/// unique (`CoachDirectoryNotifier`), il n'y a donc plus de « Sophie Martin »
/// codée en dur si ce n'est pas le coach connecté.
class CoachSession {
  CoachSession._();
  static final CoachSession _instance = CoachSession._();
  factory CoachSession() => _instance;

  static const String _prefsKey = 'fitpro_coach_id';
  static const String defaultCoachId = 'coach_1';

  String _coachId = defaultCoachId;
  String get coachId => _coachId;

  /// Relit l'identifiant du coach connecté. À appeler au démarrage.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _coachId = prefs.getString(_prefsKey) ?? defaultCoachId;
    } catch (_) {
      _coachId = defaultCoachId;
    }
  }

  /// Définit le coach connecté (ex. après inscription) et le persiste.
  Future<void> setCoachId(String id) async {
    _coachId = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, id);
    } catch (_) {
      // Démo : reste en mémoire en cas d'erreur.
    }
  }
}
