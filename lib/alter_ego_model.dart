/// Modèle de données pour l'Alter Ego Premium (démo)
class AlterEgoSnapshot {
  final int steps; // pas du jour
  final int stepsGoal; // objectif de pas (ex : 8000)
  final int calories; // calories estimées consommées
  final int caloriesGoal; // objectif (ex : 1800)
  final double waterLiters; // eau bue en L
  final double waterGoal; // objectif eau (ex : 2.0 L)
  final int workoutsDone; // séances faites
  final int workoutsPlanned; // séances prévues
  final int score; // score global sur 100
  final String coachMessage; // message style coach
  final String accountantMessage; // message style comptable

  const AlterEgoSnapshot({
    required this.steps,
    required this.stepsGoal,
    required this.calories,
    required this.caloriesGoal,
    required this.waterLiters,
    required this.waterGoal,
    required this.workoutsDone,
    required this.workoutsPlanned,
    required this.score,
    required this.coachMessage,
    required this.accountantMessage,
  });
}

/// Fonction qui renvoie une instance mockée de l'état du jour
AlterEgoSnapshot getDemoSnapshot() {
  return AlterEgoSnapshot(
    steps: 6245,
    stepsGoal: 8000,
    calories: 1850,
    caloriesGoal: 1800,
    waterLiters: 1.4,
    waterGoal: 2.0,
    workoutsDone: 2,
    workoutsPlanned: 3,
    score: 72,
    coachMessage:
        "On a bien avancé aujourd'hui 💪 Mais il manque encore une petite marche pour exploser les compteurs de pas.",
    accountantMessage:
        "6245 pas / 8000, 1850 kcal / 1800, 1.4 L / 2 L. Journée correcte, mais tu peux faire un peu mieux sur les pas et l'eau.",
  );
}

/// Constante pour le mode Premium (démo)
const bool isAlterEgoPremiumUnlocked = false;






