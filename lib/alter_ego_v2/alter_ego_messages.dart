import 'dart:math';
import '../coach_personality/coach_personality_model.dart';

enum MessagePhase {
  debut,
  milieu,
  fin,
  victoire,
  recadrage,
}

class AlterEgoMessages {
  static final _rnd = Random();

  static const Map<MessagePhase, List<String>> gentle = {
    MessagePhase.debut: [
      "On y va tranquillement, tu es exactement au bon endroit.",
      "Respire, on commence ensemble. Je suis avec toi du début à la fin.",
      "Aujourd'hui, on avance juste d'un petit pas. C'est largement suffisant.",
    ],
    MessagePhase.milieu: [
      "Regarde comme tu tiens bien, ne lâche pas maintenant.",
      "Tu fais déjà mieux que ce que tu crois, garde ce rythme.",
      "Je sais que ça pique un peu, mais tu gères vraiment très bien.",
    ],
    MessagePhase.fin: [
      "Encore quelques secondes, tu vas être fier de toi.",
      "Reste avec moi jusqu'au bip, tu peux le faire.",
      "Compte jusqu'à 5 dans ta tête… et tu l'auras fait.",
    ],
    MessagePhase.victoire: [
      "Yes ! Tu viens de prouver à ton futur que tu es sérieux.",
      "Bravo ! Garde cette version de toi en tête pour la prochaine fois.",
      "Tu peux sourire : ton futur toi vient de t'applaudir.",
    ],
    MessagePhase.recadrage: [
      "Ce n'est pas grave si tu as coupé avant, l'important c'est de revenir.",
      "On apprend de chaque essai. La prochaine fois, on fera un tout petit peu plus.",
      "Tu n'as pas échoué, tu as juste trouvé ta limite du jour. On la repoussera ensemble.",
    ],
  };

  static const Map<MessagePhase, List<String>> hard = {
    MessagePhase.debut: [
      "OK, on y va. Pas de demi-mesure aujourd'hui.",
      "Tu as appuyé sur START, maintenant tu assumes jusqu'au bout.",
      "On ne discute pas, on exécute. C'est parti.",
    ],
    MessagePhase.milieu: [
      "C'est maintenant que la différence se fait, pas quand c'est facile.",
      "Si tu peux encore réfléchir, c'est que tu peux encore pousser.",
      "Tu voulais des résultats ? Ils sont exactement dans cet inconfort.",
    ],
    MessagePhase.fin: [
      "Tu tiens, tu bloques, tu ne lâches pas avant la fin.",
      "Encore quelques secondes, montre-toi de quoi tu es vraiment capable.",
      "Pas maintenant. Tu pourras poser tout ça APRÈS le bip.",
    ],
    MessagePhase.victoire: [
      "Voilà ce que ça donne quand tu ne cherches pas d'excuses.",
      "Retient bien cette sensation : c'est le prix du progrès.",
      "Tu viens de prouver que tu es plus fort que ton cerveau fainéant.",
    ],
    MessagePhase.recadrage: [
      "Tu as coupé trop tôt, mais tu sais exactement pourquoi. On corrige au prochain round.",
      "Soit tu trouves une excuse, soit tu trouves une solution. Choisis la solution.",
      "On ne se ment pas : tu pouvais faire un peu plus. On se rattrape sur la prochaine série.",
    ],
  };

  static const Map<MessagePhase, List<String>> military = {
    MessagePhase.debut: [
      "Recrue, en position. L'entraînement commence MAINTENANT.",
      "Dos droit, regard devant. On ne lâche rien sur cette série.",
      "Tu es sur le terrain, pas au repos. C'est l'heure de travailler.",
    ],
    MessagePhase.milieu: [
      "Tu tiens la ligne, soldat. Pas de recul.",
      "Ce n'est pas la douleur, c'est la progression qui parle.",
      "Tes muscles se plaignent ? Parfait, ça veut dire qu'ils se réveillent.",
    ],
    MessagePhase.fin: [
      "Tu restes en place jusqu'à l'ordre de relâcher.",
      "Encore quelques secondes, prouve que tu fais partie de l'unité Ukan.",
      "Tu ne lâches pas la position tant que je n'ai pas donné le signal.",
    ],
    MessagePhase.victoire: [
      "Mission accomplie. Tu peux être fier, soldat.",
      "Objectif atteint. Tu viens de gagner tes galons du jour.",
      "Bon travail. Tu viens de renforcer ton armure.",
    ],
    MessagePhase.recadrage: [
      "Tu as quitté le terrain trop tôt. On réajuste et on revient plus fort.",
      "Les vrais progrès viennent de la régularité. Prochaine mission : tenir un peu plus.",
      "Pas de jugement, mais pas d'auto-mensonge non plus. On fera mieux au prochain ordre.",
    ],
  };

  static const Map<MessagePhase, List<String>> humor = {
    MessagePhase.debut: [
      "Allez, on brûle quelques cookies imaginaires ensemble.",
      "Je te promets : personne n'est mort d'un squat de 30 secondes.",
      "C'est parti, on donne au canapé une bonne raison de nous manquer.",
    ],
    MessagePhase.milieu: [
      "Si tu peux râler, tu peux encore bouger, donc on continue.",
      "Tes jambes te détestent, mais ton futur jean te dira merci.",
      "Oui ça pique, mais au moins tu n'es pas en train de plier du linge.",
    ],
    MessagePhase.fin: [
      "Encore un petit effort et tu pourras te la raconter toute la journée.",
      "Tu y es presque, fais comme si ton crush te regardait.",
      "Tiens bon, tu es à deux secondes de pouvoir dire « j'ai tout donné ».",
    ],
    MessagePhase.victoire: [
      "BOOM. Tu viens de mériter ton prochain carré de chocolat.",
      "Screen cette victoire dans ta tête, tu vas en avoir besoin les jours de flemme.",
      "Bravo, la version canapé de toi vient de perdre ce round.",
    ],
    MessagePhase.recadrage: [
      "OK, aujourd'hui c'était la version « échauffement ». Demain on fait la version sérieuse.",
      "Tu as coupé avant la fin, mais on ne va pas le dire à tout le monde.",
      "Pas grave, on appelle ça une répétition générale. La vraie scène, c'est la prochaine série.",
    ],
  };

  static String randomFor(CoachStyle style, MessagePhase phase) {
    final Map<MessagePhase, List<String>> bank;
    switch (style) {
      case CoachStyle.gentle:
        bank = gentle;
        break;
      case CoachStyle.hard:
        bank = hard;
        break;
      case CoachStyle.military:
        bank = military;
        break;
      case CoachStyle.humor:
        bank = humor;
        break;
    }
    final list = bank[phase] ?? const [];
    if (list.isEmpty) return "";
    return list[_rnd.nextInt(list.length)];
  }
}

