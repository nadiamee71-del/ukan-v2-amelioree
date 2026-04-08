import 'package:flutter/foundation.dart';
import 'group_class.dart';

/// Notifier pour gérer les cours collectifs (live, replay, planning)
class GroupClassNotifier extends ChangeNotifier {
  static final GroupClassNotifier _instance = GroupClassNotifier._internal();
  factory GroupClassNotifier() => _instance;
  GroupClassNotifier._internal();

  // Mock data - Liste de tous les cours
  final List<GroupClass> _allClasses = [];

  List<GroupClass> get allClasses => List.unmodifiable(_allClasses);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  /// Initialise avec des données mock
  void initializeMockData() {
    if (_allClasses.isNotEmpty) return; // Déjà initialisé

    final now = DateTime.now();
    
    // Cours live en ce moment
    _allClasses.addAll([
      GroupClass(
        id: 'live_001',
        title: 'HIIT Intense - Brûle tout !',
        coachName: 'Sarah Martin',
        coachId: 'coach_001',
        coachRating: 4.9,
        level: GroupClassLevel.intermediate,
        durationMinutes: 30,
        price: 3.99,
        startDateTime: now.subtract(const Duration(minutes: 5)),
        isLive: true,
        category: GroupClassCategory.hiit.name,
        description: 'Séance HIIT intensive pour brûler un maximum de calories en 30 minutes. Enchaînements explosifs, récupérations courtes, challenge maximal !',
        estimatedCalories: 350,
        accessories: ['Tapis', 'Bouteille d\'eau'],
        currentParticipants: 127,
        maxParticipants: 200,
      ),
    ]);

    // Cours qui commencent bientôt
    _allClasses.addAll([
      GroupClass(
        id: 'upcoming_001',
        title: 'Yoga Flow Détente',
        coachName: 'Emma Dubois',
        coachId: 'coach_002',
        coachRating: 4.8,
        level: GroupClassLevel.beginner,
        durationMinutes: 45,
        price: 3.99,
        startDateTime: now.add(const Duration(minutes: 15)),
        isLive: false,
        category: GroupClassCategory.yoga.name,
        description: 'Yoga flow doux pour se détendre après une longue journée. Postures fluides, respiration profonde, relaxation totale.',
        estimatedCalories: 120,
        accessories: ['Tapis de yoga', 'Bloc (optionnel)'],
        currentParticipants: 45,
        maxParticipants: 100,
      ),
      GroupClass(
        id: 'upcoming_002',
        title: 'Pilates Core Strengthening',
        coachName: 'Lucas Bernard',
        coachId: 'coach_003',
        coachRating: 4.7,
        level: GroupClassLevel.intermediate,
        durationMinutes: 40,
        price: 4.99,
        startDateTime: now.add(const Duration(minutes: 30)),
        isLive: false,
        category: GroupClassCategory.pilates.name,
        description: 'Renforcement profond du core avec les principes Pilates. Abdos solides, dos protégé, posture améliorée.',
        estimatedCalories: 200,
        accessories: ['Tapis'],
        currentParticipants: 78,
        maxParticipants: 150,
      ),
      GroupClass(
        id: 'upcoming_003',
        title: 'Cardio Dance Party',
        coachName: 'Marie Laurent',
        coachId: 'coach_004',
        coachRating: 4.9,
        level: GroupClassLevel.beginner,
        durationMinutes: 35,
        price: 3.99,
        startDateTime: now.add(const Duration(hours: 1)),
        isLive: false,
        category: GroupClassCategory.dance.name,
        description: 'Danse sur tes musiques préférées ! Cardio fun et énergique, pas besoin de savoir danser, on s\'amuse !',
        estimatedCalories: 300,
        accessories: ['Espace libre', 'Bonnes chaussures'],
        currentParticipants: 92,
        maxParticipants: 200,
      ),
    ]);

    // Replays (cours passés)
    _allClasses.addAll([
      GroupClass(
        id: 'replay_001',
        title: 'HIIT Avancé - Beast Mode',
        coachName: 'Sarah Martin',
        coachId: 'coach_001',
        coachRating: 4.9,
        level: GroupClassLevel.advanced,
        durationMinutes: 45,
        price: 5.99,
        startDateTime: now.subtract(const Duration(days: 2)),
        isLive: false,
        isReplay: true,
        category: GroupClassCategory.hiit.name,
        description: 'HIIT niveau expert pour les athlètes confirmés. Intensité maximale, pas de repos, challenge ultime !',
        estimatedCalories: 500,
        accessories: ['Haltères', 'Kettlebell (optionnel)'],
      ),
      GroupClass(
        id: 'replay_002',
        title: 'Yoga Vinyasa Power',
        coachName: 'Emma Dubois',
        coachId: 'coach_002',
        coachRating: 4.8,
        level: GroupClassLevel.intermediate,
        durationMinutes: 50,
        price: 4.99,
        startDateTime: now.subtract(const Duration(days: 1)),
        isLive: false,
        isReplay: true,
        category: GroupClassCategory.yoga.name,
        description: 'Vinyasa flow dynamique pour développer force et souplesse. Enchaînements fluides et défis équilibre.',
        estimatedCalories: 180,
        accessories: ['Tapis de yoga'],
      ),
      GroupClass(
        id: 'replay_003',
        title: 'Boxe Cardio - Complet',
        coachName: 'Thomas Roux',
        coachId: 'coach_005',
        coachRating: 4.9,
        level: GroupClassLevel.intermediate,
        durationMinutes: 40,
        price: 4.99,
        startDateTime: now.subtract(const Duration(days: 3)),
        isLive: false,
        isReplay: true,
        category: GroupClassCategory.boxing.name,
        description: 'Séance de boxe cardio complète. Techniques de base, enchaînements, sacs virtuels. Défoule-toi !',
        estimatedCalories: 400,
        accessories: ['Gants (optionnel)', 'Espace libre'],
      ),
      GroupClass(
        id: 'replay_004',
        title: 'Stretching Recovery',
        coachName: 'Sophie Garnier',
        coachId: 'coach_006',
        coachRating: 4.7,
        level: GroupClassLevel.beginner,
        durationMinutes: 30,
        price: 3.99,
        startDateTime: now.subtract(const Duration(days: 1)),
        isLive: false,
        isReplay: true,
        category: GroupClassCategory.stretching.name,
        description: 'Stretching profond pour récupération active. Détente musculaire, mobilité améliorée, bien-être total.',
        estimatedCalories: 80,
        accessories: ['Tapis', 'Sangle (optionnel)'],
      ),
      GroupClass(
        id: 'replay_005',
        title: 'Meditation & Mindfulness',
        coachName: 'Lucas Bernard',
        coachId: 'coach_003',
        coachRating: 4.7,
        level: GroupClassLevel.beginner,
        durationMinutes: 25,
        price: 2.99,
        startDateTime: now.subtract(const Duration(days: 2)),
        isLive: false,
        isReplay: true,
        category: GroupClassCategory.meditation.name,
        description: 'Méditation guidée pour calmer l\'esprit et réduire le stress. Respiration, présence, paix intérieure.',
        estimatedCalories: 20,
        accessories: ['Coussin (optionnel)'],
      ),
      GroupClass(
        id: 'replay_006',
        title: 'Renforcement Full Body',
        coachName: 'Marie Laurent',
        coachId: 'coach_004',
        coachRating: 4.9,
        level: GroupClassLevel.intermediate,
        durationMinutes: 45,
        price: 4.99,
        startDateTime: now.subtract(const Duration(days: 4)),
        isLive: false,
        isReplay: true,
        category: GroupClassCategory.strength.name,
        description: 'Renforcement complet du corps avec poids du corps. Tous les muscles sollicités, progression garantie !',
        estimatedCalories: 250,
        accessories: ['Tapis', 'Haltères légers (optionnel)'],
      ),
    ]);

    // Planning futur (prochains jours)
    for (int day = 0; day < 7; day++) {
      final futureDate = now.add(Duration(days: day));
      
      // Cours du matin
      _allClasses.add(
        GroupClass(
          id: 'future_morning_$day',
          title: 'Yoga Matin Energisant',
          coachName: 'Emma Dubois',
          coachId: 'coach_002',
          coachRating: 4.8,
          level: GroupClassLevel.beginner,
          durationMinutes: 30,
          price: 3.99,
          startDateTime: DateTime(futureDate.year, futureDate.month, futureDate.day, 8, 0),
          isLive: false,
          category: GroupClassCategory.yoga.name,
          description: 'Réveille ton corps en douceur avec ce flow matinal énergisant.',
          estimatedCalories: 100,
          accessories: ['Tapis de yoga'],
        ),
      );

      // Cours midi
      if (day < 3) {
        _allClasses.add(
          GroupClass(
            id: 'future_lunch_$day',
            title: 'HIIT Lunch Break',
            coachName: 'Sarah Martin',
            coachId: 'coach_001',
            coachRating: 4.9,
            level: GroupClassLevel.intermediate,
            durationMinutes: 20,
            price: 2.99,
            startDateTime: DateTime(futureDate.year, futureDate.month, futureDate.day, 12, 30),
            isLive: false,
            category: GroupClassCategory.hiit.name,
            description: 'Pause déj\' intense pour se dégourdir et brûler des calories rapidement.',
            estimatedCalories: 200,
            accessories: ['Tapis'],
          ),
        );
      }

      // Cours soir
      _allClasses.add(
        GroupClass(
          id: 'future_evening_$day',
          title: 'Cardio Dance Party',
          coachName: 'Marie Laurent',
          coachId: 'coach_004',
          coachRating: 4.9,
          level: GroupClassLevel.beginner,
          durationMinutes: 35,
          price: 3.99,
          startDateTime: DateTime(futureDate.year, futureDate.month, futureDate.day, 19, 0),
          isLive: false,
          category: GroupClassCategory.dance.name,
          description: 'Finis ta journée en dansant ! Énergie positive, bonne humeur garantie.',
          estimatedCalories: 300,
          accessories: ['Espace libre', 'Bonnes chaussures'],
        ),
      );
    }

    notifyListeners();
  }

  /// Récupère les cours en direct maintenant
  List<GroupClass> getLiveNow() {
    final now = DateTime.now();
    return _allClasses.where((c) {
      if (!c.isLive || c.startDateTime == null) return false;
      final diff = now.difference(c.startDateTime!);
      return diff.inMinutes >= 0 && diff.inMinutes <= c.durationMinutes;
    }).toList();
  }

  /// Récupère les cours qui commencent bientôt (dans les 2 prochaines heures)
  List<GroupClass> getUpcoming({int maxMinutes = 120}) {
    final now = DateTime.now();
    return _allClasses.where((c) {
      if (c.isLive || c.isReplay || c.startDateTime == null) return false;
      final diff = c.startDateTime!.difference(now);
      return diff.inMinutes > 0 && diff.inMinutes <= maxMinutes;
    }).toList()
      ..sort((a, b) => a.startDateTime!.compareTo(b.startDateTime!));
  }

  /// Récupère tous les replays
  List<GroupClass> getReplays() {
    return _allClasses.where((c) => c.isReplay).toList()
      ..sort((a, b) => (b.startDateTime ?? DateTime.now()).compareTo(a.startDateTime ?? DateTime.now()));
  }

  /// Récupère les replays par niveau
  List<GroupClass> getReplaysByLevel(GroupClassLevel level) {
    return getReplays().where((c) => c.level == level).toList();
  }

  /// Récupère les replays populaires (mock: les plus récents)
  List<GroupClass> getPopularReplays({int limit = 10}) {
    return getReplays().take(limit).toList();
  }

  /// Récupère le planning pour une date spécifique
  List<GroupClass> getScheduleForDay(DateTime date) {
    return _allClasses.where((c) {
      if (c.startDateTime == null) return false;
      return c.startDateTime!.year == date.year &&
          c.startDateTime!.month == date.month &&
          c.startDateTime!.day == date.day;
    }).toList()
      ..sort((a, b) => (a.startDateTime ?? DateTime.now()).compareTo(b.startDateTime ?? DateTime.now()));
  }

  /// Récupère un cours par ID
  GroupClass? getClassById(String id) {
    try {
      return _allClasses.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Ajoute un nouveau cours (côté coach)
  void addClass(GroupClass groupClass) {
    _allClasses.add(groupClass);
    notifyListeners();
  }

  /// Réserve un cours (mock: incrémente les participants)
  void reserveClass(String classId) {
    final index = _allClasses.indexWhere((c) => c.id == classId);
    if (index != -1) {
      // En vrai, on créerait une nouvelle instance avec currentParticipants + 1
      // Pour la démo, on simule juste avec notifyListeners
      notifyListeners();
    }
  }
}







