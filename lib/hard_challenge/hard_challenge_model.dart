import 'package:flutter/material.dart';

/// Modèle pour le Hard Challenge
class HardChallenge {
  final String id;
  final String name;
  final String? description;
  final int totalDays;
  final int currentDay;
  final double completion; // 0.0 – 1.0
  final String motivationalQuote;
  final DateTime startDate;
  final List<DailyHabit> habits;
  final Map<int, bool> calendarData; // jour du mois -> réussi ou non
  final bool isCustom; // Challenge personnalisé ou prédéfini
  final List<String> participants; // IDs des participants
  final String? creatorId;
  final bool isShared; // Partagé avec la communauté

  HardChallenge({
    required this.id,
    required this.name,
    this.description,
    required this.totalDays,
    required this.currentDay,
    required this.completion,
    required this.motivationalQuote,
    required this.startDate,
    required this.habits,
    required this.calendarData,
    this.isCustom = false,
    this.participants = const [],
    this.creatorId,
    this.isShared = false,
  });

  int get successfulDays => calendarData.values.where((v) => v).length;
  int get failedDays => calendarData.values.where((v) => !v).length;
  double get successRate => calendarData.isEmpty ? 0 : successfulDays / calendarData.length;

  HardChallenge copyWith({
    String? id,
    String? name,
    String? description,
    int? totalDays,
    int? currentDay,
    double? completion,
    String? motivationalQuote,
    DateTime? startDate,
    List<DailyHabit>? habits,
    Map<int, bool>? calendarData,
    bool? isCustom,
    List<String>? participants,
    String? creatorId,
    bool? isShared,
  }) {
    return HardChallenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalDays: totalDays ?? this.totalDays,
      currentDay: currentDay ?? this.currentDay,
      completion: completion ?? this.completion,
      motivationalQuote: motivationalQuote ?? this.motivationalQuote,
      startDate: startDate ?? this.startDate,
      habits: habits ?? this.habits,
      calendarData: calendarData ?? this.calendarData,
      isCustom: isCustom ?? this.isCustom,
      participants: participants ?? this.participants,
      creatorId: creatorId ?? this.creatorId,
      isShared: isShared ?? this.isShared,
    );
  }
}

/// Catégories d'habitudes - SPORT uniquement
enum HabitCategory {
  workout,    // Entraînement
  activity,   // Activité quotidienne
  nutrition,  // Nutrition sportive
  recovery,   // Récupération
}

/// Modèle pour une habitude quotidienne
class DailyHabit {
  final String id;
  final HabitCategory category;
  final String label;
  final String? value;
  final String? target;
  final IconType iconType;
  bool isDone;

  DailyHabit({
    required this.id,
    required this.category,
    required this.label,
    this.value,
    this.target,
    this.iconType = IconType.checkCircle,
    this.isDone = false,
  });

  String get categoryName {
    switch (category) {
      case HabitCategory.workout:
        return 'Entraînement';
      case HabitCategory.activity:
        return 'Activité quotidienne';
      case HabitCategory.nutrition:
        return 'Nutrition sportive';
      case HabitCategory.recovery:
        return 'Récupération';
    }
  }

  DailyHabit copyWith({
    String? id,
    HabitCategory? category,
    String? label,
    String? value,
    String? target,
    IconType? iconType,
    bool? isDone,
  }) {
    return DailyHabit(
      id: id ?? this.id,
      category: category ?? this.category,
      label: label ?? this.label,
      value: value ?? this.value,
      target: target ?? this.target,
      iconType: iconType ?? this.iconType,
      isDone: isDone ?? this.isDone,
    );
  }
}

enum IconType {
  checkCircle,
  fitness,
  walk,
  run,
  water,
  food,
  sleep,
  stretch,
  pushup,
  squat,
  plank,
  abs,
  rope,
  burpee,
  dumbbell,
  timer,
  fire,
  target,
  group,
  share,
}

/// Challenge prédéfini (template)
class ChallengeTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int defaultDays;
  final List<int> availableDurations;
  final List<DailyHabit> defaultHabits;

  const ChallengeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.defaultDays,
    required this.availableDurations,
    required this.defaultHabits,
  });
}

/// Données et templates pour le Hard Challenge
class HardChallengeData {
  // Templates de challenges prédéfinis
  static List<ChallengeTemplate> getTemplates() {
    return [
      ChallengeTemplate(
        id: 'pushups_30',
        name: '30 Pompes/jour',
        description: 'Fais 30 pompes chaque jour pendant la durée du challenge',
        icon: Icons.fitness_center,
        color: const Color(0xFFFF6B6B),
        defaultDays: 30,
        availableDurations: [30, 50, 75],
        defaultHabits: [
          DailyHabit(id: 'pushups', category: HabitCategory.workout, label: 'Pompes', target: '30 pompes', iconType: IconType.pushup),
        ],
      ),
      ChallengeTemplate(
        id: 'squats_50',
        name: '50 Squats/jour',
        description: 'Fais 50 squats chaque jour pour renforcer tes jambes',
        icon: Icons.accessibility_new,
        color: const Color(0xFF4ECDC4),
        defaultDays: 30,
        availableDurations: [30, 50, 75],
        defaultHabits: [
          DailyHabit(id: 'squats', category: HabitCategory.workout, label: 'Squats', target: '50 squats', iconType: IconType.squat),
        ],
      ),
      ChallengeTemplate(
        id: 'plank_challenge',
        name: 'Planche Challenge',
        description: 'Tiens la planche chaque jour (30s → 2min progressif)',
        icon: Icons.timer,
        color: const Color(0xFFA855F7),
        defaultDays: 30,
        availableDurations: [30, 50],
        defaultHabits: [
          DailyHabit(id: 'plank', category: HabitCategory.workout, label: 'Planche', value: '30s', target: '2 min', iconType: IconType.plank),
        ],
      ),
      ChallengeTemplate(
        id: 'steps_10k',
        name: '10K Pas/jour',
        description: 'Marche au moins 10 000 pas chaque jour',
        icon: Icons.directions_walk,
        color: const Color(0xFF58A6FF),
        defaultDays: 30,
        availableDurations: [30, 50, 75, 90],
        defaultHabits: [
          DailyHabit(id: 'steps', category: HabitCategory.activity, label: 'Pas du jour', target: '10 000 pas', iconType: IconType.walk),
        ],
      ),
      ChallengeTemplate(
        id: 'abs_challenge',
        name: 'Abdos Challenge',
        description: 'Travaille tes abdos chaque jour (20-30 répétitions)',
        icon: Icons.sports_gymnastics,
        color: const Color(0xFFFF9F43),
        defaultDays: 30,
        availableDurations: [30, 50],
        defaultHabits: [
          DailyHabit(id: 'abs', category: HabitCategory.workout, label: 'Abdos', target: '30 abdos', iconType: IconType.abs),
        ],
      ),
      ChallengeTemplate(
        id: 'run_3k',
        name: 'Course 3K/jour',
        description: 'Cours 3 km chaque jour',
        icon: Icons.directions_run,
        color: const Color(0xFF22D3EE),
        defaultDays: 30,
        availableDurations: [30, 50, 75],
        defaultHabits: [
          DailyHabit(id: 'run', category: HabitCategory.activity, label: 'Course', target: '3 km', iconType: IconType.run),
        ],
      ),
      ChallengeTemplate(
        id: 'rope_challenge',
        name: 'Corde à sauter',
        description: 'Fais 200 sauts à la corde chaque jour',
        icon: Icons.sports,
        color: const Color(0xFFFFC300),
        defaultDays: 30,
        availableDurations: [30, 50],
        defaultHabits: [
          DailyHabit(id: 'rope', category: HabitCategory.workout, label: 'Corde à sauter', target: '200 sauts', iconType: IconType.rope),
        ],
      ),
      ChallengeTemplate(
        id: 'burpees_challenge',
        name: 'Burpees Challenge',
        description: 'Fais 15 burpees chaque jour',
        icon: Icons.local_fire_department,
        color: const Color(0xFFEF4444),
        defaultDays: 30,
        availableDurations: [30, 50, 75],
        defaultHabits: [
          DailyHabit(id: 'burpees', category: HabitCategory.workout, label: 'Burpees', target: '15 burpees', iconType: IconType.burpee),
        ],
      ),
      ChallengeTemplate(
        id: '75_hard_sport',
        name: '75 Hard Sport',
        description: 'Le challenge ultime : séance sport + hydratation + pas quotidiens',
        icon: Icons.emoji_events,
        color: const Color(0xFFFFC300),
        defaultDays: 75,
        availableDurations: [50, 75, 90],
        defaultHabits: [
          DailyHabit(id: 'workout', category: HabitCategory.workout, label: 'Séance sport', target: '45 min minimum', iconType: IconType.fitness),
          DailyHabit(id: 'hydration', category: HabitCategory.nutrition, label: 'Hydratation', target: '2 L', iconType: IconType.water),
          DailyHabit(id: 'steps', category: HabitCategory.activity, label: 'Pas du jour', target: '10 000 pas', iconType: IconType.walk),
          DailyHabit(id: 'stretch', category: HabitCategory.recovery, label: 'Étirements', target: '10 min', iconType: IconType.stretch),
        ],
      ),
    ];
  }

  static HardChallenge getMockChallenge() {
    return HardChallenge(
      id: 'mock_challenge_1',
      name: '30 Pompes/jour',
      description: 'Fais 30 pompes chaque jour pendant 30 jours',
      totalDays: 30,
      currentDay: 12,
      completion: 12 / 30,
      motivationalQuote: 'Chaque pompe te rapproche de ton objectif. Continue !',
      startDate: DateTime.now().subtract(const Duration(days: 11)),
      habits: getMockHabits(),
      calendarData: getMockCalendar(),
      isCustom: false,
      participants: ['user_1', 'user_2'],
      creatorId: 'user_1',
      isShared: true,
    );
  }

  static List<DailyHabit> getMockHabits() {
    return [
      // Entraînement
      DailyHabit(
        id: 'pushups',
        category: HabitCategory.workout,
        label: 'Pompes',
        value: '25',
        target: '30 pompes',
        iconType: IconType.pushup,
        isDone: false,
      ),
      
      // Activité quotidienne
      DailyHabit(
        id: 'steps',
        category: HabitCategory.activity,
        label: 'Pas du jour',
        value: '7 500',
        target: '10 000 pas',
        iconType: IconType.walk,
        isDone: false,
      ),
      
      // Nutrition sportive
      DailyHabit(
        id: 'hydration',
        category: HabitCategory.nutrition,
        label: 'Hydratation',
        value: '1.5 L',
        target: '2 L',
        iconType: IconType.water,
        isDone: true,
      ),
      
      // Récupération
      DailyHabit(
        id: 'stretch',
        category: HabitCategory.recovery,
        label: 'Étirements',
        value: '5 min',
        target: '10 min',
        iconType: IconType.stretch,
        isDone: false,
      ),
    ];
  }

  static Map<int, bool> getMockCalendar() {
    return {
      1: true,
      2: true,
      3: true,
      4: false,
      5: true,
      6: true,
      7: true,
      8: false,
      9: true,
      10: true,
      11: true,
      12: true, // aujourd'hui
    };
  }
}

/// Notifier pour gérer les Hard Challenges
class HardChallengeNotifier extends ChangeNotifier {
  static final HardChallengeNotifier _instance = HardChallengeNotifier._internal();
  factory HardChallengeNotifier() => _instance;
  HardChallengeNotifier._internal();

  HardChallenge? _currentChallenge;
  final List<HardChallenge> _myCreatedChallenges = [];
  final List<HardChallenge> _sharedChallenges = [];

  HardChallenge? get currentChallenge => _currentChallenge;
  List<HardChallenge> get myCreatedChallenges => _myCreatedChallenges;
  List<HardChallenge> get sharedChallenges => _sharedChallenges;

  void setCurrentChallenge(HardChallenge challenge) {
    _currentChallenge = challenge;
    notifyListeners();
  }

  void createChallenge(HardChallenge challenge) {
    _myCreatedChallenges.add(challenge);
    _currentChallenge = challenge;
    notifyListeners();
  }

  void shareChallenge(String challengeId) {
    final index = _myCreatedChallenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      _myCreatedChallenges[index] = _myCreatedChallenges[index].copyWith(isShared: true);
      _sharedChallenges.add(_myCreatedChallenges[index]);
      notifyListeners();
    }
  }

  void inviteToChallenge(String challengeId, String participantId) {
    if (_currentChallenge != null && _currentChallenge!.id == challengeId) {
      final newParticipants = List<String>.from(_currentChallenge!.participants)..add(participantId);
      _currentChallenge = _currentChallenge!.copyWith(participants: newParticipants);
      notifyListeners();
    }
  }

  void toggleHabit(String habitId) {
    if (_currentChallenge != null) {
      final habits = _currentChallenge!.habits.map((h) {
        if (h.id == habitId) {
          return h.copyWith(isDone: !h.isDone);
        }
        return h;
      }).toList();
      _currentChallenge = _currentChallenge!.copyWith(habits: habits);
      notifyListeners();
    }
  }

  void updateDayStatus(int day, bool success) {
    if (_currentChallenge != null) {
      final newCalendar = Map<int, bool>.from(_currentChallenge!.calendarData);
      newCalendar[day] = success;
      _currentChallenge = _currentChallenge!.copyWith(calendarData: newCalendar);
      notifyListeners();
    }
  }
}

