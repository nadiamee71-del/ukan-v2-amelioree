/// Repository local pour le calendrier d'exercices Ukan
/// Mode démo : stockage en mémoire uniquement

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'calendar_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SINGLETON REPOSITORY (DEMO MODE)
// ─────────────────────────────────────────────────────────────────────────────

class ExercisesCalendarRepository extends ChangeNotifier {
  // Singleton
  static final ExercisesCalendarRepository _instance = ExercisesCalendarRepository._internal();
  factory ExercisesCalendarRepository() => _instance;
  ExercisesCalendarRepository._internal() {
    _initDemoData();
  }

  // Stockage en mémoire
  final List<ExerciseHistoryEntry> _entries = [];
  final List<CalendarGoal> _goals = [];
  final List<BodyMetricsSnapshot> _bodyMetrics = [];

  // ───────────────────────────────────────────────────────────────────────────
  // GETTERS
  // ───────────────────────────────────────────────────────────────────────────

  List<ExerciseHistoryEntry> get allEntries => List.unmodifiable(_entries);
  List<CalendarGoal> get allGoals => List.unmodifiable(_goals);
  List<BodyMetricsSnapshot> get allBodyMetrics => List.unmodifiable(_bodyMetrics);

  // ───────────────────────────────────────────────────────────────────────────
  // MÉTHODES POUR LES ENTRÉES D'EXERCICES
  // ───────────────────────────────────────────────────────────────────────────

  /// Récupérer toutes les entrées d'un jour donné
  List<ExerciseHistoryEntry> getEntriesForDay(DateTime day) {
    return _entries.where((e) =>
      e.date.year == day.year &&
      e.date.month == day.month &&
      e.date.day == day.day
    ).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Récupérer toutes les entrées d'un exercice spécifique
  List<ExerciseHistoryEntry> getEntriesForExercise(String exerciseId) {
    return _entries.where((e) => e.exerciseId == exerciseId)
      .toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Récupérer l'historique entre deux dates
  List<ExerciseHistoryEntry> getEntriesBetween(DateTime start, DateTime end) {
    return _entries.where((e) =>
      e.date.isAfter(start.subtract(const Duration(days: 1))) &&
      e.date.isBefore(end.add(const Duration(days: 1)))
    ).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Ajouter ou mettre à jour une entrée
  void addOrUpdateEntry(ExerciseHistoryEntry entry) {
    final existingIndex = _entries.indexWhere((e) => e.id == entry.id);
    if (existingIndex >= 0) {
      _entries[existingIndex] = entry;
    } else {
      _entries.add(entry);
    }
    notifyListeners();
  }

  /// Mettre à jour la difficulté d'une entrée
  void updateEntryDifficulty(String entryId, double difficulty) {
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index >= 0) {
      _entries[index] = _entries[index].copyWith(perceivedDifficulty: difficulty);
      notifyListeners();
    }
  }

  /// Supprimer une entrée
  void deleteEntry(String entryId) {
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MÉTHODES POUR LES OBJECTIFS
  // ───────────────────────────────────────────────────────────────────────────

  /// Récupérer les objectifs pour un jour donné (date cible)
  List<CalendarGoal> getGoalsForDay(DateTime day) {
    return _goals.where((g) =>
      g.targetDate.year == day.year &&
      g.targetDate.month == day.month &&
      g.targetDate.day == day.day
    ).toList();
  }

  /// Récupérer tous les objectifs actifs
  List<CalendarGoal> getActiveGoals() {
    return _goals.where((g) => !g.isCompleted).toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  /// Récupérer les objectifs en retard
  List<CalendarGoal> getOverdueGoals() {
    return _goals.where((g) => g.isOverdue).toList();
  }

  /// Récupérer les objectifs complétés
  List<CalendarGoal> getCompletedGoals() {
    return _goals.where((g) => g.isCompleted).toList();
  }

  /// Ajouter un objectif
  void addGoal(CalendarGoal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  /// Mettre à jour un objectif
  void updateGoal(CalendarGoal goal) {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _goals[index] = goal;
      notifyListeners();
    }
  }

  /// Ajouter un rappel à un objectif
  void addReminderToGoal(String goalId, GoalReminder reminder) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index >= 0) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        reminders: [...goal.reminders, reminder],
      );
      notifyListeners();
    }
  }

  /// Marquer un rappel comme envoyé
  void markReminderAsSent(String goalId, String reminderId) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex >= 0) {
      final goal = _goals[goalIndex];
      final updatedReminders = goal.reminders.map((r) {
        if (r.id == reminderId) {
          return r.copyWith(isSent: true);
        }
        return r;
      }).toList();
      _goals[goalIndex] = goal.copyWith(reminders: updatedReminders);
      notifyListeners();
    }
  }

  /// Marquer un objectif comme complété
  void completeGoal(String goalId, {double? finalValue}) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index >= 0) {
      _goals[index] = _goals[index].copyWith(
        isCompleted: true,
        currentValue: finalValue ?? _goals[index].currentValue,
      );
      notifyListeners();
    }
  }

  /// Supprimer un objectif
  void deleteGoal(String goalId) {
    _goals.removeWhere((g) => g.id == goalId);
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MÉTHODES POUR LES MENSURATIONS
  // ───────────────────────────────────────────────────────────────────────────

  /// Récupérer les mensurations pour un jour donné
  BodyMetricsSnapshot? getMetricsForDay(DateTime day) {
    try {
      return _bodyMetrics.firstWhere((m) =>
        m.measuredAt.year == day.year &&
        m.measuredAt.month == day.month &&
        m.measuredAt.day == day.day
      );
    } catch (_) {
      return null;
    }
  }

  /// Ajouter ou mettre à jour des mensurations
  void addOrUpdateMetrics(BodyMetricsSnapshot metrics) {
    final existingIndex = _bodyMetrics.indexWhere((m) => m.id == metrics.id);
    if (existingIndex >= 0) {
      _bodyMetrics[existingIndex] = metrics;
    } else {
      _bodyMetrics.add(metrics);
    }
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MÉTHODES AGRÉGÉES
  // ───────────────────────────────────────────────────────────────────────────

  /// Récupérer toutes les données d'un jour
  CalendarDayData getDayData(DateTime day) {
    return CalendarDayData(
      date: day,
      exercises: getEntriesForDay(day),
      goals: getGoalsForDay(day),
      bodyMetrics: getMetricsForDay(day),
    );
  }

  /// Vérifier si un jour a des données
  bool hasDataForDay(DateTime day) {
    final hasExercises = _entries.any((e) =>
      e.date.year == day.year &&
      e.date.month == day.month &&
      e.date.day == day.day
    );
    final hasGoals = _goals.any((g) =>
      g.targetDate.year == day.year &&
      g.targetDate.month == day.month &&
      g.targetDate.day == day.day
    );
    final hasMetrics = _bodyMetrics.any((m) =>
      m.measuredAt.year == day.year &&
      m.measuredAt.month == day.month &&
      m.measuredAt.day == day.day
    );
    return hasExercises || hasGoals || hasMetrics;
  }

  /// Récupérer les rappels dus
  List<({CalendarGoal goal, GoalReminder reminder})> checkAndGetDueReminders(DateTime now) {
    final dueReminders = <({CalendarGoal goal, GoalReminder reminder})>[];
    for (final goal in _goals) {
      for (final reminder in goal.reminders) {
        if (reminder.isDue(now)) {
          dueReminders.add((goal: goal, reminder: reminder));
        }
      }
    }
    return dueReminders;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STATISTIQUES
  // ───────────────────────────────────────────────────────────────────────────

  /// Nombre total de séances (jours uniques avec exercices)
  int get totalWorkoutDays {
    final uniqueDays = <String>{};
    for (final entry in _entries) {
      uniqueDays.add('${entry.date.year}-${entry.date.month}-${entry.date.day}');
    }
    return uniqueDays.length;
  }

  /// Volume total sur une période
  double getTotalVolume({DateTime? start, DateTime? end}) {
    var entries = _entries;
    if (start != null) {
      entries = entries.where((e) => e.date.isAfter(start.subtract(const Duration(days: 1)))).toList();
    }
    if (end != null) {
      entries = entries.where((e) => e.date.isBefore(end.add(const Duration(days: 1)))).toList();
    }
    return entries.fold(0.0, (sum, e) => sum + e.totalVolume);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DONNÉES DÉMO
  // ───────────────────────────────────────────────────────────────────────────

  void _initDemoData() {
    final now = DateTime.now();
    final random = Random(42);

    // Générer des exercices sur les 30 derniers jours
    final demoExercises = [
      ('squat_01', 'Squat barre', 'Jambes', 'Quadriceps'),
      ('deadlift_01', 'Soulevé de terre', 'Jambes', 'Dos'),
      ('bench_01', 'Développé couché', 'Haut du corps', 'Pectoraux'),
      ('pullup_01', 'Tractions', 'Haut du corps', 'Dos'),
      ('shoulder_01', 'Développé épaules', 'Haut du corps', 'Épaules'),
      ('curl_01', 'Curl biceps', 'Haut du corps', 'Biceps'),
      ('plank_01', 'Gainage', 'Abdos', 'Core'),
      ('crunch_01', 'Crunchs', 'Abdos', 'Core'),
    ];

    // Séances sur les 30 derniers jours (3-4 par semaine)
    for (int daysAgo = 0; daysAgo < 30; daysAgo++) {
      // Entraînement 3-4 fois par semaine
      if (daysAgo % 2 == 0 || daysAgo % 7 == 0) {
        final date = now.subtract(Duration(days: daysAgo));
        
        // 2-4 exercices par séance
        final numExercises = 2 + random.nextInt(3);
        final usedExercises = <int>{};
        
        for (int i = 0; i < numExercises; i++) {
          int exerciseIndex;
          do {
            exerciseIndex = random.nextInt(demoExercises.length);
          } while (usedExercises.contains(exerciseIndex));
          usedExercises.add(exerciseIndex);

          final exercise = demoExercises[exerciseIndex];
          final isStrength = exercise.$2 != 'Gainage';
          
          // Générer 3-5 séries
          final numSets = 3 + random.nextInt(3);
          final sets = <ExerciseSet>[];
          
          for (int s = 0; s < numSets; s++) {
            if (isStrength) {
              sets.add(ExerciseSet(
                setNumber: s + 1,
                reps: 6 + random.nextInt(10),
                weight: 20 + random.nextInt(80).toDouble(),
                restTime: Duration(seconds: 60 + random.nextInt(60)),
              ));
            } else {
              sets.add(ExerciseSet(
                setNumber: s + 1,
                timeUnderTension: Duration(seconds: 30 + random.nextInt(60)),
                restTime: const Duration(seconds: 30),
              ));
            }
          }

          _entries.add(ExerciseHistoryEntry(
            id: 'entry_${daysAgo}_$i',
            exerciseId: exercise.$1,
            exerciseName: exercise.$2,
            exerciseCategory: exercise.$3,
            muscleGroup: exercise.$4,
            date: date,
            sets: sets,
            perceivedDifficulty: daysAgo < 7 ? null : 5 + random.nextInt(5).toDouble(),
            totalDuration: Duration(minutes: 10 + random.nextInt(20)),
          ));
        }
      }
    }

    // Quelques objectifs démo
    _goals.addAll([
      CalendarGoal(
        id: 'goal_1',
        title: 'Perdre 5 kg',
        description: 'Objectif de perte de poids avant l\'été',
        targetDate: now.add(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 30)),
        targetValue: -5,
        unit: 'kg',
        startValue: 82,
        currentValue: 80,
        type: CalendarGoalType.weightLoss,
        reminders: [
          GoalReminder(
            id: 'rem_1_1',
            reminderDateTime: now.add(const Duration(days: 30)),
            customMessage: 'Mi-parcours : vérifie ta progression !',
          ),
          GoalReminder(
            id: 'rem_1_2',
            reminderDateTime: now.add(const Duration(days: 57)),
            customMessage: 'Plus que 3 jours !',
          ),
        ],
      ),
      CalendarGoal(
        id: 'goal_2',
        title: '100 kg au squat',
        description: 'Atteindre 100 kg au squat pour 5 reps',
        targetDate: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 15)),
        targetValue: 100,
        unit: 'kg',
        startValue: 70,
        currentValue: 85,
        type: CalendarGoalType.performance,
        linkedExerciseId: 'squat_01',
        reminders: [
          GoalReminder(
            id: 'rem_2_1',
            reminderDateTime: now.add(const Duration(days: 42)),
            customMessage: 'Dernière ligne droite pour ton objectif squat !',
          ),
        ],
      ),
      CalendarGoal(
        id: 'goal_3',
        title: 'Tour de taille -3 cm',
        targetDate: now.add(const Duration(days: 90)),
        createdAt: now.subtract(const Duration(days: 10)),
        targetValue: -3,
        unit: 'cm',
        startValue: 88,
        currentValue: 87,
        type: CalendarGoalType.measurement,
      ),
      CalendarGoal(
        id: 'goal_4',
        title: '3 séances par semaine',
        description: 'Maintenir une régularité d\'entraînement',
        targetDate: now.add(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 7)),
        type: CalendarGoalType.habit,
        isCompleted: false,
      ),
    ]);

    // Quelques mensurations démo
    for (int weeksAgo = 0; weeksAgo < 4; weeksAgo++) {
      final date = now.subtract(Duration(days: weeksAgo * 7));
      _bodyMetrics.add(BodyMetricsSnapshot(
        id: 'metrics_$weeksAgo',
        measuredAt: date,
        weightKg: 82 - weeksAgo * 0.5 + random.nextDouble(),
        waistCm: 88 - weeksAgo * 0.3 + random.nextDouble() * 0.5,
        bodyFatPercent: weeksAgo == 0 ? 18.5 : null,
      ));
    }
  }

  /// Réinitialiser les données (pour tests)
  void resetToDemo() {
    _entries.clear();
    _goals.clear();
    _bodyMetrics.clear();
    _initDemoData();
    notifyListeners();
  }
}





