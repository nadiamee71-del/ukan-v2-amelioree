import 'package:flutter/foundation.dart';

/// Modèle pour le classement d'un coach
class CoachRanking {
  final String id;
  final String name;
  final String specialty;
  final int score;
  final int wins;
  final int losses;

  const CoachRanking({
    required this.id,
    required this.name,
    required this.specialty,
    required this.score,
    required this.wins,
    required this.losses,
  });

  CoachRanking copyWith({
    String? id,
    String? name,
    String? specialty,
    int? score,
    int? wins,
    int? losses,
  }) {
    return CoachRanking(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      score: score ?? this.score,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
    );
  }
}

/// Notifier pour gérer le classement des coachs
class CoachRankingNotifier extends ChangeNotifier {
  static final CoachRankingNotifier _instance = CoachRankingNotifier._internal();
  factory CoachRankingNotifier() => _instance;
  CoachRankingNotifier._internal();

  final List<CoachRanking> _coaches = [
    // Perte de poids (3 coachs)
    const CoachRanking(
      id: 'coach1',
      name: 'Alex Martin',
      specialty: 'Perte de poids',
      score: 1250,
      wins: 12,
      losses: 3,
    ),
    const CoachRanking(
      id: 'coach6',
      name: 'Marie Lefebvre',
      specialty: 'Perte de poids',
      score: 1100,
      wins: 9,
      losses: 4,
    ),
    const CoachRanking(
      id: 'coach7',
      name: 'David Moreau',
      specialty: 'Perte de poids',
      score: 1020,
      wins: 7,
      losses: 5,
    ),
    // Prise de masse (3 coachs)
    const CoachRanking(
      id: 'coach2',
      name: 'Sarah Lopez',
      specialty: 'Prise de masse',
      score: 1180,
      wins: 10,
      losses: 5,
    ),
    const CoachRanking(
      id: 'coach8',
      name: 'Julien Petit',
      specialty: 'Prise de masse',
      score: 1150,
      wins: 11,
      losses: 3,
    ),
    const CoachRanking(
      id: 'coach9',
      name: 'Laura Bernard',
      specialty: 'Prise de masse',
      score: 1080,
      wins: 8,
      losses: 6,
    ),
    // CrossFit (3 coachs)
    const CoachRanking(
      id: 'coach3',
      name: 'Karim Ben',
      specialty: 'CrossFit',
      score: 1120,
      wins: 9,
      losses: 6,
    ),
    const CoachRanking(
      id: 'coach10',
      name: 'Sophie Nguyen',
      specialty: 'CrossFit',
      score: 1090,
      wins: 10,
      losses: 4,
    ),
    const CoachRanking(
      id: 'coach11',
      name: 'Maxime Rousseau',
      specialty: 'CrossFit',
      score: 1040,
      wins: 7,
      losses: 7,
    ),
    // Post-partum (2 coachs)
    const CoachRanking(
      id: 'coach4',
      name: 'Emma Dubois',
      specialty: 'Post-partum',
      score: 1050,
      wins: 8,
      losses: 7,
    ),
    const CoachRanking(
      id: 'coach12',
      name: 'Clara Martin',
      specialty: 'Post-partum',
      score: 990,
      wins: 6,
      losses: 8,
    ),
    // Endurance (2 coachs)
    const CoachRanking(
      id: 'coach5',
      name: 'Thomas Chen',
      specialty: 'Endurance',
      score: 980,
      wins: 6,
      losses: 9,
    ),
    const CoachRanking(
      id: 'coach13',
      name: 'Pierre Durand',
      specialty: 'Endurance',
      score: 950,
      wins: 5,
      losses: 10,
    ),
    // Yoga & Mobilité (2 coachs)
    const CoachRanking(
      id: 'coach14',
      name: 'Anaïs Girard',
      specialty: 'Yoga & Mobilité',
      score: 1000,
      wins: 7,
      losses: 6,
    ),
    const CoachRanking(
      id: 'coach15',
      name: 'Lucas Mercier',
      specialty: 'Yoga & Mobilité',
      score: 970,
      wins: 6,
      losses: 7,
    ),
    // Cardio & Endurance (2 coachs)
    const CoachRanking(
      id: 'coach16',
      name: 'Nina Torres',
      specialty: 'Cardio & Endurance',
      score: 1030,
      wins: 8,
      losses: 5,
    ),
    const CoachRanking(
      id: 'coach17',
      name: 'Antoine Lemoine',
      specialty: 'Cardio & Endurance',
      score: 960,
      wins: 5,
      losses: 8,
    ),
    // Remise en forme (2 coachs)
    const CoachRanking(
      id: 'coach18',
      name: 'Julie Roux',
      specialty: 'Remise en forme',
      score: 1010,
      wins: 7,
      losses: 6,
    ),
    const CoachRanking(
      id: 'coach19',
      name: 'Marc Lambert',
      specialty: 'Remise en forme',
      score: 940,
      wins: 5,
      losses: 9,
    ),
  ];

  List<CoachRanking> get coaches {
    final sorted = [..._coaches];
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return List.unmodifiable(sorted);
  }

  CoachRanking? getCoachById(String id) {
    try {
      return _coaches.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateCoach(CoachRanking updatedCoach) {
    final index = _coaches.indexWhere((c) => c.id == updatedCoach.id);
    if (index != -1) {
      _coaches[index] = updatedCoach;
      notifyListeners();
    }
  }
}

/// Modèle pour représenter un duel entre deux coachs
class CoachDuel {
  final String id;
  final CoachRanking coachA;
  final CoachRanking coachB;
  final String challengeType;
  final DateTime createdAt;
  final DuelResult? result; // null tant que non joué

  const CoachDuel({
    required this.id,
    required this.coachA,
    required this.coachB,
    required this.challengeType,
    required this.createdAt,
    this.result,
  });

  CoachDuel copyWith({
    String? id,
    CoachRanking? coachA,
    CoachRanking? coachB,
    String? challengeType,
    DateTime? createdAt,
    DuelResult? result,
  }) {
    return CoachDuel(
      id: id ?? this.id,
      coachA: coachA ?? this.coachA,
      coachB: coachB ?? this.coachB,
      challengeType: challengeType ?? this.challengeType,
      createdAt: createdAt ?? this.createdAt,
      result: result ?? this.result,
    );
  }
}

/// Type de duel
enum DuelType {
  coachVsCoach,
  coachVsStudent,
  studentVsStudent,
}

/// Opposant dans un duel (peut être un coach ou un élève)
class DuelOpponent {
  final CoachRanking? coach; // si Coach vs Coach
  final String? studentName; // si Coach vs Élève
  final bool isStudent;

  const DuelOpponent({
    this.coach,
    this.studentName,
    required this.isStudent,
  });

  /// Créer un DuelOpponent pour un coach
  factory DuelOpponent.coach(CoachRanking coach) {
    return DuelOpponent(
      coach: coach,
      studentName: null,
      isStudent: false,
    );
  }

  /// Créer un DuelOpponent pour un élève
  factory DuelOpponent.student(String studentName) {
    return DuelOpponent(
      coach: null,
      studentName: studentName,
      isStudent: true,
    );
  }

  /// Obtenir le nom de l'opposant
  String get name {
    if (isStudent) {
      return studentName ?? 'Élève';
    }
    return coach?.name ?? 'Coach';
  }

  /// Obtenir la spécialité (pour les coachs uniquement)
  String? get specialty {
    if (isStudent) return null;
    return coach?.specialty;
  }
}

/// Résultat d'un duel (réutilisé depuis duel_coach_engine.dart)
/// Défini ici pour éviter la dépendance circulaire
class DuelResult {
  final CoachRanking winner;
  final CoachRanking? loserCoach; // null si le perdant est un élève
  final String? loserStudentName; // null si le perdant est un coach
  final bool loserIsStudent;
  final String challengeType;
  final int winnerScoreChange;
  final int loserScoreChange;

  const DuelResult({
    required this.winner,
    this.loserCoach,
    this.loserStudentName,
    required this.loserIsStudent,
    required this.challengeType,
    required this.winnerScoreChange,
    required this.loserScoreChange,
  });

  /// Nom du perdant
  String get loserName {
    if (loserIsStudent) {
      return loserStudentName ?? 'Élève';
    }
    return loserCoach?.name ?? 'Coach';
  }
}

/// Historique d'un duel avec toutes les informations
class DuelHistory {
  final String id;
  final CoachRanking coachA;
  final DuelOpponent opponent;
  final String challengeType;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DuelResult? result;
  final DuelType duelType;
  final int? scoreA; // Score final du participant A
  final int? scoreB; // Score final du participant B
  final Duration? duration; // Durée du duel

  const DuelHistory({
    required this.id,
    required this.coachA,
    required this.opponent,
    required this.challengeType,
    required this.createdAt,
    this.completedAt,
    this.result,
    required this.duelType,
    this.scoreA,
    this.scoreB,
    this.duration,
  });

  /// Spécialité du duel (basée sur coachA)
  String get specialty => coachA.specialty;

  /// Nom du participant A
  String get participantAName => coachA.name;

  /// Nom du participant B
  String get participantBName => opponent.name;
}

/// Notifier pour gérer l'historique des duels
class DuelHistoryNotifier extends ChangeNotifier {
  static final DuelHistoryNotifier _instance = DuelHistoryNotifier._internal();
  factory DuelHistoryNotifier() => _instance;
  DuelHistoryNotifier._internal();

  final List<DuelHistory> _history = [];

  List<DuelHistory> get history => List.unmodifiable(_history);

  /// Ajouter un duel à l'historique
  void addDuel(DuelHistory duel) {
    _history.insert(0, duel); // Ajouter en début de liste (plus récent en premier)
    notifyListeners();
  }

  /// Obtenir les duels filtrés par type
  List<DuelHistory> getDuelsByType(DuelType type) {
    return _history.where((duel) => duel.duelType == type).toList();
  }

  /// Obtenir les duels d'un coach spécifique
  List<DuelHistory> getDuelsByCoach(String coachId) {
    return _history.where((duel) => duel.coachA.id == coachId).toList();
  }

  /// Obtenir les statistiques par type de duel
  Map<DuelType, DuelTypeStats> getStatsByType() {
    final stats = <DuelType, DuelTypeStats>{};
    
    for (final duelType in DuelType.values) {
      final duels = getDuelsByType(duelType);
      final completedDuels = duels.where((d) => d.result != null).toList();
      
      stats[duelType] = DuelTypeStats(
        totalDuels: duels.length,
        completedDuels: completedDuels.length,
        totalParticipants: duels.map((d) => d.participantAName).toSet().length +
            duels.map((d) => d.participantBName).toSet().length,
      );
    }
    
    return stats;
  }

  /// Obtenir le palmarès (top gagnants)
  List<PalmaresEntry> getPalmares({DuelType? type}) {
    final duels = type != null ? getDuelsByType(type) : _history;
    final winners = <String, int>{};
    final specialties = <String, String>{};

    for (final duel in duels.where((d) => d.result != null)) {
      final winnerName = duel.result!.winner.name;
      winners[winnerName] = (winners[winnerName] ?? 0) + 1;
      if (!specialties.containsKey(winnerName)) {
        specialties[winnerName] = duel.result!.winner.specialty;
      }
    }

    final entries = winners.entries.map((entry) {
      return PalmaresEntry(
        name: entry.key,
        wins: entry.value,
        specialty: specialties[entry.key] ?? 'Non spécifiée',
      );
    }).toList();

    entries.sort((a, b) => b.wins.compareTo(a.wins));
    return entries;
  }

  /// Obtenir le palmarès par catégorie (spécialité)
  Map<String, List<PalmaresEntry>> getPalmaresByCategory({DuelType? type}) {
    final duels = type != null ? getDuelsByType(type) : _history;
    final categoryWinners = <String, Map<String, int>>{}; // Catégorie -> Nom -> Victoires
    final specialties = <String, String>{};

    for (final duel in duels.where((d) => d.result != null)) {
      final winnerName = duel.result!.winner.name;
      final category = duel.result!.winner.specialty;
      
      if (!categoryWinners.containsKey(category)) {
        categoryWinners[category] = <String, int>{};
      }
      
      categoryWinners[category]![winnerName] = 
          (categoryWinners[category]![winnerName] ?? 0) + 1;
      
      if (!specialties.containsKey(winnerName)) {
        specialties[winnerName] = category;
      }
    }

    final result = <String, List<PalmaresEntry>>{};
    
    for (final category in categoryWinners.keys) {
      final entries = categoryWinners[category]!.entries.map((entry) {
        return PalmaresEntry(
          name: entry.key,
          wins: entry.value,
          specialty: specialties[entry.key] ?? category,
        );
      }).toList();

      entries.sort((a, b) => b.wins.compareTo(a.wins));
      result[category] = entries;
    }

    return result;
  }
}

/// Statistiques par type de duel
class DuelTypeStats {
  final int totalDuels;
  final int completedDuels;
  final int totalParticipants;

  const DuelTypeStats({
    required this.totalDuels,
    required this.completedDuels,
    required this.totalParticipants,
  });
}

/// Entrée du palmarès
class PalmaresEntry {
  final String name;
  final int wins;
  final String specialty;

  const PalmaresEntry({
    required this.name,
    required this.wins,
    required this.specialty,
  });
}






