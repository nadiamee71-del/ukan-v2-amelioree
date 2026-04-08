import 'package:flutter/foundation.dart';
import 'user_profile.dart';
import 'nutrition.dart';

/// ─────────────────────────────────────────────
/// Modèles de base
/// ─────────────────────────────────────────────

class HydrationEntry {
  final String id;
  final DateTime date; // on ne garde que AAAA-MM-JJ
  final int milliliters;

  HydrationEntry({
    required this.id,
    required DateTime date,
    required this.milliliters,
  }) : date = DateTime(date.year, date.month, date.day);
}

class SleepEntry {
  final String id;
  final DateTime date; // date de la nuit (jour de coucher)
  final DateTime bedTime;
  final DateTime wakeTime;
  final int durationMinutes;

  SleepEntry({
    required this.id,
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.durationMinutes,
  });
}

/// Helper interne pour normaliser une date (AAAA-MM-JJ)
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// ─────────────────────────────────────────────
/// Hydratation
/// ─────────────────────────────────────────────

class HydrationNotifier extends ChangeNotifier {
  static final HydrationNotifier _instance = HydrationNotifier._internal();
  factory HydrationNotifier() => _instance;
  HydrationNotifier._internal();

  final List<HydrationEntry> _entries = [];

  void addWater({required DateTime date, required int milliliters}) {
    if (milliliters <= 0) return;
    final entry = HydrationEntry(
      id: 'water_${DateTime.now().microsecondsSinceEpoch}',
      date: date,
      milliliters: milliliters,
    );
    _entries.add(entry);
    notifyListeners();
  }

  List<HydrationEntry> entriesForDate(DateTime date) {
    final d = _dateOnly(date);
    return _entries.where((e) => _dateOnly(e.date) == d).toList();
  }

  int totalForDate(DateTime date) {
    return entriesForDate(date)
        .fold<int>(0, (sum, e) => sum + e.milliliters);
  }

  /// Total sur les 7 derniers jours (utile pour StatsPage)
  Map<DateTime, int> totalsForLast7Days() {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final Map<DateTime, int> result = {};
    for (int i = 6; i >= 0; i--) {
      final d = _dateOnly(today.subtract(Duration(days: i)));
      result[d] = totalForDate(d);
    }
    return result;
  }
}

/// ─────────────────────────────────────────────
/// Sommeil
/// ─────────────────────────────────────────────

class SleepNotifier extends ChangeNotifier {
  static final SleepNotifier _instance = SleepNotifier._internal();
  factory SleepNotifier() => _instance;
  SleepNotifier._internal();

  final List<SleepEntry> _entries = [];

  void addSleep(SleepEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  List<SleepEntry> entriesForLast7Days() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _entries
        .where((e) => e.date.isAfter(sevenDaysAgo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  SleepEntry? lastEntry() {
    if (_entries.isEmpty) return null;
    final sorted = [..._entries]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }
}

/// ─────────────────────────────────────────────
/// Objectifs quotidiens (eau / protéines / sommeil)
/// ─────────────────────────────────────────────

class DailyGoalsNotifier extends ChangeNotifier {
  static final DailyGoalsNotifier _instance =
      DailyGoalsNotifier._internal();
  factory DailyGoalsNotifier() => _instance;
  DailyGoalsNotifier._internal() {
    _initFromProfile();
  }

  final HydrationNotifier _hydrationNotifier = HydrationNotifier();
  final SleepNotifier _sleepNotifier = SleepNotifier();
  final Map<DateTime, int> _proteinByDate = {};

  double waterGoalLiters = 2.0;
  double sleepGoalHours = 7.0;
  int proteinGoalGrams = 120;

  void _initFromProfile() {
    // Si le poids est connu, objectif protéines = poids * 1.6
    final profile = UserProfileNotifier().profile;
    if (profile.currentWeight != null) {
      proteinGoalGrams = (profile.currentWeight! * 1.6).round();
    }
  }

  void updateGoals({
    double? waterGoalLiters,
    double? sleepGoalHours,
    int? proteinGoalGrams,
  }) {
    bool changed = false;

    if (waterGoalLiters != null && waterGoalLiters > 0) {
      this.waterGoalLiters = waterGoalLiters;
      changed = true;
    }
    if (sleepGoalHours != null && sleepGoalHours > 0) {
      this.sleepGoalHours = sleepGoalHours;
      changed = true;
    }
    if (proteinGoalGrams != null && proteinGoalGrams > 0) {
      this.proteinGoalGrams = proteinGoalGrams;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// À appeler depuis la NutritionTab pour enregistrer les protéines du jour.
  void setProteinForDate(DateTime date, int grams) {
    final d = _dateOnly(date);
    _proteinByDate[d] = grams;
    notifyListeners();
  }

  // ─ Hydratation ─

  int totalWaterForDate(DateTime date) {
    return _hydrationNotifier.totalForDate(date);
  }

  double waterProgressForDate(DateTime date) {
    final totalMl = totalWaterForDate(date);
    final goalMl = (waterGoalLiters * 1000).clamp(1, 100000).toDouble();
    return (totalMl / goalMl).clamp(0.0, 2.0);
  }

  // ─ Protéines ─

  int totalProteinForDate(DateTime date) {
    final d = _dateOnly(date);
    return _proteinByDate[d] ?? 0;
  }

  double proteinProgressForDate(DateTime date) {
    final total = totalProteinForDate(date);
    final goal = proteinGoalGrams.clamp(1, 10000);
    return (total / goal).clamp(0.0, 2.0);
  }

  // ─ Sommeil ─

  SleepEntry? lastSleepEntry() {
    return _sleepNotifier.lastEntry();
  }

  List<SleepEntry> sleepEntriesForLast7Days() {
    return _sleepNotifier.entriesForLast7Days();
  }

  /// Helper pour StatsPage : protéines sur 7 jours
  Map<DateTime, int> proteinTotalsForLast7Days() {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final Map<DateTime, int> result = {};
    for (int i = 6; i >= 0; i--) {
      final d = _dateOnly(today.subtract(Duration(days: i)));
      result[d] = totalProteinForDate(d);
    }
    return result;
  }

  /// Helper pour StatsPage : hydratation sur 7 jours
  Map<DateTime, int> waterTotalsForLast7Days() {
    return _hydrationNotifier.totalsForLast7Days();
  }
}

