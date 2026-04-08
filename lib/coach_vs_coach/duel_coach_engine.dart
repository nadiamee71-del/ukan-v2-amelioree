import 'dart:math';
import '../models/coach_vs_coach.dart';

// DuelResult est maintenant défini dans models/coach_vs_coach.dart

/// Moteur pour simuler un duel entre coachs
class DuelCoachEngine {
  /// Simule un duel entre deux coachs
  static DuelResult simulateDuel({
    required CoachRanking coachA,
    required CoachRanking coachB,
    required String challengeType,
  }) {
    final random = Random();

    // Probabilité de victoire basée sur le score actuel
    final totalScore = coachA.score + coachB.score;
    final coachAWinProbability = coachA.score / totalScore;

    // Ajouter un peu de hasard (±20%)
    final adjustedProbability = (coachAWinProbability * 0.8) +
        (random.nextDouble() * 0.4);

    CoachRanking winner;
    CoachRanking loser;
    int winnerScoreChange;
    int loserScoreChange;

    if (random.nextDouble() < adjustedProbability) {
      // Coach A gagne
      winner = coachA;
      loser = coachB;
      winnerScoreChange = 40; // +40 points pour le gagnant (démo)
      loserScoreChange = -15; // -15 points pour le perdant (démo)
    } else {
      // Coach B gagne
      winner = coachB;
      loser = coachA;
      winnerScoreChange = 40; // +40 points pour le gagnant (démo)
      loserScoreChange = -15; // -15 points pour le perdant (démo)
    }

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
      challengeType: challengeType,
      winnerScoreChange: winnerScoreChange,
      loserScoreChange: loserScoreChange,
    );
  }
}

