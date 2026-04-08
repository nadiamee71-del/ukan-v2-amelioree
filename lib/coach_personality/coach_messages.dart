import 'coach_personality_model.dart';

/// Messages de motivation du coach vocal (mode DÉMO - texte uniquement)
/// 
/// Cette classe fournit des phrases de motivation selon le style du coach
/// et la phase de l'exercice (début / milieu / fin).
class CoachMessages {
  /// Récupère un message d'introduction selon le style (0-10% du temps)
  static String getIntroMessage(CoachStyle style) {
    switch (style) {
      case CoachStyle.gentle:
        return 'On y va tranquillement, tu fais déjà le plus dur : commencer 💛';
      case CoachStyle.hard:
        return 'OK, pas d\'excuse, on attaque maintenant.';
      case CoachStyle.military:
        return 'Soldat, en position. On va au bout, compris ?';
      case CoachStyle.humor:
        return 'Allez, on brûle les croissants de ce matin 😄';
    }
  }

  /// Récupère un message de milieu selon le style (40-60% du temps)
  static String getMidMessage(CoachStyle style) {
    switch (style) {
      case CoachStyle.gentle:
        return 'Respire, tu gères, reste avec moi, tu es sur la bonne voie.';
      case CoachStyle.hard:
        return 'Tu peux faire mieux que ça, pousse un peu plus.';
      case CoachStyle.military:
        return 'Garde le rythme, pas de relâchement.';
      case CoachStyle.humor:
        return 'Si tu lâches maintenant, je raconte cette séance à tout Instagram.';
    }
  }

  /// Récupère un message de fin selon le style (80-100% du temps)
  static String getFinalPushMessage(CoachStyle style) {
    switch (style) {
      case CoachStyle.gentle:
        return 'Dernières secondes, ne lâche pas, tu peux être fier de toi !';
      case CoachStyle.hard:
        return 'C\'est maintenant que ça compte. Tu termines propre ou tu recommences.';
      case CoachStyle.military:
        return '10 secondes ! Tu donnes tout, aucun abandon.';
      case CoachStyle.humor:
        return 'Encore un petit effort et tu as officiellement mérité Netflix.';
    }
  }

  /// Récupère un message selon le style et le progrès (0.0 - 1.0)
  /// 
  /// - progress < 0.1 : Intro
  /// - 0.4 <= progress < 0.6 : Milieu
  /// - progress >= 0.8 : Fin
  /// - Sinon : retourne null (pas de message)
  static String? getMessageForProgress(CoachStyle style, double progress) {
    if (progress < 0.1) {
      return getIntroMessage(style);
    } else if (progress >= 0.4 && progress < 0.6) {
      return getMidMessage(style);
    } else if (progress >= 0.8) {
      return getFinalPushMessage(style);
    }
    return null;
  }

  /// Méthode de compatibilité : convertit un tone (String) en CoachStyle et retourne un message
  /// Pour l'ancien système qui utilise "gentil", "dur", "militaire", "humour"
  static String getMotivationMessage(String tone) {
    CoachStyle style;
    switch (tone) {
      case 'gentil':
        style = CoachStyle.gentle;
        break;
      case 'dur':
        style = CoachStyle.hard;
        break;
      case 'militaire':
        style = CoachStyle.military;
        break;
      case 'humour':
        style = CoachStyle.humor;
        break;
      default:
        style = CoachStyle.gentle;
    }
    // Retourne un message de milieu par défaut (message général)
    return getMidMessage(style);
  }
}
