import 'package:flutter/foundation.dart';

/// Exercice dans une séance de groupe
class RoomExercise {
  final String id;
  final String name;
  final int durationSeconds; // Durée de l'exercice en secondes
  final String? videoAsset; // Asset vidéo de l'exercice
  final String? youtubeUrl; // URL YouTube en fallback
  final String? imageAsset; // Image de l'exercice
  final String description;

  const RoomExercise({
    required this.id,
    required this.name,
    required this.durationSeconds,
    this.videoAsset,
    this.youtubeUrl,
    this.imageAsset,
    this.description = '',
  });

  RoomExercise copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    String? videoAsset,
    String? youtubeUrl,
    String? imageAsset,
    String? description,
  }) {
    return RoomExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      videoAsset: videoAsset ?? this.videoAsset,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      imageAsset: imageAsset ?? this.imageAsset,
      description: description ?? this.description,
    );
  }
}

/// Participant dans une room d'entraînement
class RoomParticipant {
  final String id;
  final String name;
  final String avatarInitials; // ex: "SA", "NA", "BI"
  final int progressPercent; // 0 à 100 (progression globale de la séance)
  final Map<String, int> exerciseProgress; // Progression par exercice (exerciseId -> 0-100)
  final bool isOwner;

  const RoomParticipant({
    required this.id,
    required this.name,
    required this.avatarInitials,
    required this.progressPercent,
    this.exerciseProgress = const {},
    required this.isOwner,
  });

  RoomParticipant copyWith({
    int? progressPercent,
    Map<String, int>? exerciseProgress,
  }) {
    return RoomParticipant(
      id: id,
      name: name,
      avatarInitials: avatarInitials,
      progressPercent: progressPercent ?? this.progressPercent,
      exerciseProgress: exerciseProgress ?? this.exerciseProgress,
      isOwner: isOwner,
    );
  }
}

/// Room d'entraînement
class TrainingRoom {
  final String id;
  final String code; // ex: "ROOM-3482"
  final String workoutTitle; // nom de la séance choisie
  final bool isActive; // séance en cours ou pas
  final List<RoomParticipant> participants;
  final List<RoomExercise> exercises; // Liste des exercices de la séance
  final int currentExerciseIndex; // Index de l'exercice actuel (0-based)
  final int currentExerciseElapsedSeconds; // Temps écoulé pour l'exercice actuel

  const TrainingRoom({
    required this.id,
    required this.code,
    required this.workoutTitle,
    required this.isActive,
    required this.participants,
    this.exercises = const [],
    this.currentExerciseIndex = 0,
    this.currentExerciseElapsedSeconds = 0,
  });

  RoomExercise? get currentExercise {
    if (exercises.isEmpty || currentExerciseIndex < 0 || currentExerciseIndex >= exercises.length) {
      return null;
    }
    return exercises[currentExerciseIndex];
  }

  bool get hasNextExercise => currentExerciseIndex < exercises.length - 1;
  bool get isCompleted => currentExerciseIndex >= exercises.length - 1 && currentExerciseElapsedSeconds >= (currentExercise?.durationSeconds ?? 0);

  TrainingRoom copyWith({
    String? workoutTitle,
    bool? isActive,
    List<RoomParticipant>? participants,
    List<RoomExercise>? exercises,
    int? currentExerciseIndex,
    int? currentExerciseElapsedSeconds,
  }) {
    return TrainingRoom(
      id: id,
      code: code,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      isActive: isActive ?? this.isActive,
      participants: participants ?? this.participants,
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentExerciseElapsedSeconds: currentExerciseElapsedSeconds ?? this.currentExerciseElapsedSeconds,
    );
  }
}

/// Notifier pour gérer les rooms d'entraînement (en mémoire)
class RoomsNotifier extends ChangeNotifier {
  static final RoomsNotifier _instance = RoomsNotifier._internal();
  factory RoomsNotifier() => _instance;
  RoomsNotifier._internal() {
    // Exercices de démo pour la séance
    final demoExercises = [
      const RoomExercise(
        id: 'squat',
        name: 'Squats',
        durationSeconds: 60, // 1 minute
        videoAsset: 'assets/videos/exercises/squat.mp4',
        youtubeUrl: 'https://www.youtube.com/watch?v=Dy28eq2PjcM',
        imageAsset: 'assets/images/exercises/squat.png',
        description: 'Renforce les jambes et les fessiers',
      ),
      const RoomExercise(
        id: 'pushup',
        name: 'Pompes',
        durationSeconds: 45, // 45 secondes
        videoAsset: 'assets/videos/exercises/pushup.mp4',
        youtubeUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        imageAsset: 'assets/images/exercises/pushup.png',
        description: 'Développe la force du haut du corps',
      ),
      const RoomExercise(
        id: 'plank',
        name: 'Gainage',
        durationSeconds: 60, // 1 minute
        videoAsset: 'assets/videos/exercises/plank.mp4',
        youtubeUrl: 'https://www.youtube.com/watch?v=pSHjTRCQxIw',
        imageAsset: 'assets/images/exercises/plank.png',
        description: 'Renforce les abdominaux et le dos',
      ),
      const RoomExercise(
        id: 'lunges',
        name: 'Fentes',
        durationSeconds: 60, // 1 minute
        videoAsset: 'assets/videos/exercises/lunges.mp4',
        youtubeUrl: 'https://www.youtube.com/watch?v=QOVaHwm-Q6U',
        imageAsset: 'assets/images/exercises/lunges.png',
        description: 'Travaille les jambes et l\'équilibre',
      ),
    ];

    // Room de démo
    final demoRoom = TrainingRoom(
      id: 'room_demo',
      code: 'ROOM-1234',
      workoutTitle: 'Full body 30 min',
      isActive: false,
      participants: const [
        RoomParticipant(
          id: 'you',
          name: 'Toi',
          avatarInitials: 'TU',
          progressPercent: 0,
          exerciseProgress: {},
          isOwner: true,
        ),
        RoomParticipant(
          id: 'sarah',
          name: 'Sarah',
          avatarInitials: 'SA',
          progressPercent: 0,
          exerciseProgress: {},
          isOwner: false,
        ),
        RoomParticipant(
          id: 'bilel',
          name: 'Bilel',
          avatarInitials: 'BI',
          progressPercent: 0,
          exerciseProgress: {},
          isOwner: false,
        ),
      ],
      exercises: demoExercises,
    );
    _rooms.add(demoRoom);
    _currentRoom = demoRoom;
  }

  final List<TrainingRoom> _rooms = [];
  TrainingRoom? _currentRoom;

  TrainingRoom? get currentRoom => _currentRoom;

  /// Crée une nouvelle room
  void createRoom(String workoutTitle, {List<RoomExercise>? exercises}) {
    final code = 'ROOM-${DateTime.now().millisecondsSinceEpoch % 10000}'
        .padLeft(4, '0');
    
    // Exercices par défaut si non fournis
    final defaultExercises = exercises ?? [
      const RoomExercise(
        id: 'squat',
        name: 'Squats',
        durationSeconds: 60,
        videoAsset: 'assets/videos/exercises/squat.mp4',
        youtubeUrl: 'https://www.youtube.com/watch?v=Dy28eq2PjcM',
        imageAsset: 'assets/images/exercises/squat.png',
        description: 'Renforce les jambes et les fessiers',
      ),
      const RoomExercise(
        id: 'pushup',
        name: 'Pompes',
        durationSeconds: 45,
        videoAsset: 'assets/videos/exercises/pushup.mp4',
        youtubeUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        imageAsset: 'assets/images/exercises/pushup.png',
        description: 'Développe la force du haut du corps',
      ),
      const RoomExercise(
        id: 'plank',
        name: 'Gainage',
        durationSeconds: 60,
        videoAsset: 'assets/videos/exercises/plank.mp4',
        youtubeUrl: 'https://www.youtube.com/watch?v=pSHjTRCQxIw',
        imageAsset: 'assets/images/exercises/plank.png',
        description: 'Renforce les abdominaux et le dos',
      ),
    ];
    
    final room = TrainingRoom(
      id: 'room_${DateTime.now().microsecondsSinceEpoch}',
      code: code,
      workoutTitle: workoutTitle,
      isActive: false,
      participants: const [
        RoomParticipant(
          id: 'you',
          name: 'Toi',
          avatarInitials: 'TU',
          progressPercent: 0,
          exerciseProgress: {},
          isOwner: true,
        ),
      ],
      exercises: defaultExercises,
    );
    _rooms.add(room);
    _currentRoom = room;
    notifyListeners();
  }

  /// Passe à l'exercice suivant
  void nextExercise() {
    if (_currentRoom == null) return;
    if (!_currentRoom!.hasNextExercise) return;

    final newIndex = _currentRoom!.currentExerciseIndex + 1;
    updateCurrentRoom(
      _currentRoom!.copyWith(
        currentExerciseIndex: newIndex,
        currentExerciseElapsedSeconds: 0,
      ),
    );
  }

  /// Réinitialise l'exercice actuel
  void resetCurrentExercise() {
    if (_currentRoom == null) return;
    updateCurrentRoom(
      _currentRoom!.copyWith(
        currentExerciseElapsedSeconds: 0,
      ),
    );
  }

  /// Rejoint la room de démo
  void joinDemoRoom() {
    _currentRoom = _rooms.firstWhere(
      (r) => r.id == 'room_demo',
      orElse: () => _currentRoom ?? (_rooms.isNotEmpty ? _rooms.first : null)!,
    );
    notifyListeners();
  }

  /// Met à jour la room actuelle
  void updateCurrentRoom(TrainingRoom room) {
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      _rooms[index] = room;
    }
    _currentRoom = room;
    notifyListeners();
  }

  /// Ajoute un participant à la room actuelle
  void addParticipant(RoomParticipant participant) {
    if (_currentRoom == null) return;
    
    // Vérifier que le participant n'est pas déjà dans la room
    if (_currentRoom!.participants.any((p) => p.id == participant.id)) {
      return;
    }

    final updatedParticipants = List<RoomParticipant>.from(_currentRoom!.participants)
      ..add(participant);

    updateCurrentRoom(
      _currentRoom!.copyWith(participants: updatedParticipants),
    );
  }

  /// Retire un participant de la room actuelle
  void removeParticipant(String participantId) {
    if (_currentRoom == null) return;
    
    final updatedParticipants = _currentRoom!.participants
        .where((p) => p.id != participantId)
        .toList();

    updateCurrentRoom(
      _currentRoom!.copyWith(participants: updatedParticipants),
    );
  }

  /// Liste des membres disponibles pour invitation (démo)
  static final List<RoomParticipant> availableMembers = [
    const RoomParticipant(
      id: 'marie',
      name: 'Marie',
      avatarInitials: 'MA',
      progressPercent: 0,
      isOwner: false,
    ),
    const RoomParticipant(
      id: 'lucas',
      name: 'Lucas',
      avatarInitials: 'LU',
      progressPercent: 0,
      isOwner: false,
    ),
    const RoomParticipant(
      id: 'sophie',
      name: 'Sophie',
      avatarInitials: 'SO',
      progressPercent: 0,
      isOwner: false,
    ),
    const RoomParticipant(
      id: 'thomas',
      name: 'Thomas',
      avatarInitials: 'TH',
      progressPercent: 0,
      isOwner: false,
    ),
    const RoomParticipant(
      id: 'julie',
      name: 'Julie',
      avatarInitials: 'JU',
      progressPercent: 0,
      isOwner: false,
    ),
    const RoomParticipant(
      id: 'pierre',
      name: 'Pierre',
      avatarInitials: 'PI',
      progressPercent: 0,
      isOwner: false,
    ),
  ];
}


