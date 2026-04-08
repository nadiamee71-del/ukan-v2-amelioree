import 'package:flutter/foundation.dart';

/// Entrée d'historique d'une séance terminée
class WorkoutSessionHistoryEntry {
  final String id;
  final DateTime date; // date/heure de la séance
  final String workoutTitle; // nom du programme
  final int durationSeconds; // durée estimée en secondes
  final int caloriesEstimate; // estimation calories (simple)

  const WorkoutSessionHistoryEntry({
    required this.id,
    required this.date,
    required this.workoutTitle,
    required this.durationSeconds,
    required this.caloriesEstimate,
  });
}

/// Résumé hebdomadaire des séances
class WeeklyWorkoutSummary {
  final int sessionsCount;
  final int totalMinutes;
  final Map<int, int> sessionsPerWeekday;
  // clé = weekday (1 = lundi ... 7 = dimanche), valeur = nombre de séances

  const WeeklyWorkoutSummary({
    required this.sessionsCount,
    required this.totalMinutes,
    required this.sessionsPerWeekday,
  });
}

/// Notifier pour gérer l'historique des séances (en mémoire)
class WorkoutHistoryNotifier extends ChangeNotifier {
  static final WorkoutHistoryNotifier _instance =
      WorkoutHistoryNotifier._internal();
  factory WorkoutHistoryNotifier() => _instance;
  WorkoutHistoryNotifier._internal() {
    // Entrées de démo pour tester
    final now = DateTime.now();
    _entries.addAll([
      WorkoutSessionHistoryEntry(
        id: 'demo_1',
        date: now.subtract(const Duration(days: 2)),
        workoutTitle: 'Full body – Niveau intermédiaire',
        durationSeconds: 2700, // 45 min
        caloriesEstimate: 270,
      ),
      WorkoutSessionHistoryEntry(
        id: 'demo_2',
        date: now.subtract(const Duration(days: 1)),
        workoutTitle: 'Programme débutant – 3 séances',
        durationSeconds: 2400, // 40 min
        caloriesEstimate: 240,
      ),
    ]);
  }

  final List<WorkoutSessionHistoryEntry> _entries = [];

  /// Récupère toutes les entrées (triées par date)
  List<WorkoutSessionHistoryEntry> allEntries() {
    final list = [..._entries];
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Ajoute une nouvelle entrée
  void addEntry(WorkoutSessionHistoryEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  /// Récupère le résumé pour une semaine donnée
  WeeklyWorkoutSummary summaryForWeek(DateTime referenceDate) {
    // semaine du lundi au dimanche contenant referenceDate
    final monday = referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final sessionsPerWeekday = <int, int>{for (var i = 1; i <= 7; i++) i: 0};
    int totalMinutes = 0;
    int sessionsCount = 0;

    for (final e in _entries) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      final mondayDate = DateTime(monday.year, monday.month, monday.day);
      final sundayDate = DateTime(sunday.year, sunday.month, sunday.day);

      if (!d.isBefore(mondayDate) && !d.isAfter(sundayDate)) {
        sessionsCount++;
        totalMinutes += (e.durationSeconds / 60).round();
        sessionsPerWeekday[e.date.weekday] =
            (sessionsPerWeekday[e.date.weekday] ?? 0) + 1;
      }
    }

    return WeeklyWorkoutSummary(
      sessionsCount: sessionsCount,
      totalMinutes: totalMinutes,
      sessionsPerWeekday: sessionsPerWeekday,
    );
  }
}









