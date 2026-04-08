/// Modèle de données pour une entrée d'évaluation de difficulté
class DifficultyEntry {
  final String id;
  final String exerciseId;      // id de l'exercice
  final String sessionId;       // id de la séance (room)
  final DateTime date;          // date et heure
  final int level;              // difficulté ressentie 0 à 10
  final String? comment;        // commentaire optionnel
  final bool shared;            // partagé dans communauté ou non

  DifficultyEntry({
    required this.id,
    required this.exerciseId,
    required this.sessionId,
    required this.date,
    required this.level,
    this.comment,
    this.shared = false,
  });

  /// Crée une copie de l'entrée avec des valeurs modifiées
  DifficultyEntry copyWith({
    String? id,
    String? exerciseId,
    String? sessionId,
    DateTime? date,
    int? level,
    String? comment,
    bool? shared,
  }) {
    return DifficultyEntry(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      sessionId: sessionId ?? this.sessionId,
      date: date ?? this.date,
      level: level ?? this.level,
      comment: comment ?? this.comment,
      shared: shared ?? this.shared,
    );
  }
}
