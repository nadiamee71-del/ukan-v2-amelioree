import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Entrée d'historique de douleur
class PainHistoryEntry {
  final DateTime date;
  final int painLevel;
  final String? note;

  const PainHistoryEntry({
    required this.date,
    required this.painLevel,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'painLevel': painLevel,
    'note': note,
  };

  factory PainHistoryEntry.fromJson(Map<String, dynamic> json) => PainHistoryEntry(
    date: DateTime.parse(json['date'] as String),
    painLevel: json['painLevel'] as int,
    note: json['note'] as String?,
  );
}

/// Rendez-vous médical
class MedicalAppointment {
  final String id;
  final DateTime date;
  final String type; // kiné, médecin, spécialiste, etc.
  final String? doctorName;
  final String? notes;
  final bool completed;

  const MedicalAppointment({
    required this.id,
    required this.date,
    required this.type,
    this.doctorName,
    this.notes,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'type': type,
    'doctorName': doctorName,
    'notes': notes,
    'completed': completed,
  };

  factory MedicalAppointment.fromJson(Map<String, dynamic> json) => MedicalAppointment(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    type: json['type'] as String,
    doctorName: json['doctorName'] as String?,
    notes: json['notes'] as String?,
    completed: json['completed'] as bool? ?? false,
  );
}

/// Exercice de rééducation
class RehabExercise {
  final String id;
  final String name;
  final String description;
  final int sets;
  final int reps;
  final String? imageUrl;
  final String? videoUrl;

  const RehabExercise({
    required this.id,
    required this.name,
    required this.description,
    this.sets = 3,
    this.reps = 10,
    this.imageUrl,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'sets': sets,
    'reps': reps,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
  };

  factory RehabExercise.fromJson(Map<String, dynamic> json) => RehabExercise(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    sets: json['sets'] as int? ?? 3,
    reps: json['reps'] as int? ?? 10,
    imageUrl: json['imageUrl'] as String?,
    videoUrl: json['videoUrl'] as String?,
  );
}

/// Modèle de données pour une blessure
class Injury {
  final String id;
  final String userId;
  final String bodyPart; // zone du corps : genou, dos, cheville, épaule, etc.
  final String type; // entorse, fracture, tendinite, déchirure, etc.
  final String severity; // "léger", "modéré", "sévère"
  final String status; // "en_cours", "en_rééducation", "guérie"
  final int painLevel; // de 1 à 10
  final DateTime startDate; // début de la blessure
  final DateTime? endDate; // date de guérison (facultative)
  final String? rehabPlan; // plan de rééducation (texte)
  final String notes; // notes libres
  final List<String> imagePaths; // chemins des images (assets)
  final List<Uint8List> imageBytes; // images en bytes (pour Web)
  final String? videoUrl; // vidéo éventuelle de la blessure
  final DateTime lastUpdated; // dernière mise à jour
  final List<PainHistoryEntry> painHistory; // historique de douleur
  final List<MedicalAppointment> appointments; // rendez-vous médicaux
  final List<RehabExercise> rehabExercises; // exercices de rééducation
  final List<String> exercisesToAvoid; // exercices à éviter

  const Injury({
    required this.id,
    required this.userId,
    required this.bodyPart,
    required this.type,
    required this.severity,
    required this.status,
    required this.painLevel,
    required this.startDate,
    this.endDate,
    this.rehabPlan,
    this.notes = '',
    this.imagePaths = const [],
    this.imageBytes = const [],
    this.videoUrl,
    required this.lastUpdated,
    this.painHistory = const [],
    this.appointments = const [],
    this.rehabExercises = const [],
    this.exercisesToAvoid = const [],
  });

  /// Crée une copie de la blessure avec des valeurs modifiées
  Injury copyWith({
    String? id,
    String? userId,
    String? bodyPart,
    String? type,
    String? severity,
    String? status,
    int? painLevel,
    DateTime? startDate,
    DateTime? endDate,
    String? rehabPlan,
    String? notes,
    List<String>? imagePaths,
    List<Uint8List>? imageBytes,
    String? videoUrl,
    DateTime? lastUpdated,
    List<PainHistoryEntry>? painHistory,
    List<MedicalAppointment>? appointments,
    List<RehabExercise>? rehabExercises,
    List<String>? exercisesToAvoid,
  }) {
    return Injury(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bodyPart: bodyPart ?? this.bodyPart,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      painLevel: painLevel ?? this.painLevel,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rehabPlan: rehabPlan ?? this.rehabPlan,
      notes: notes ?? this.notes,
      imagePaths: imagePaths ?? this.imagePaths,
      imageBytes: imageBytes ?? this.imageBytes,
      videoUrl: videoUrl ?? this.videoUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      painHistory: painHistory ?? this.painHistory,
      appointments: appointments ?? this.appointments,
      rehabExercises: rehabExercises ?? this.rehabExercises,
      exercisesToAvoid: exercisesToAvoid ?? this.exercisesToAvoid,
    );
  }

  /// Convertit en Map pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bodyPart': bodyPart,
      'type': type,
      'severity': severity,
      'status': status,
      'painLevel': painLevel,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'rehabPlan': rehabPlan,
      'notes': notes,
      'imagePaths': imagePaths,
      'videoUrl': videoUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
      'painHistory': painHistory.map((e) => e.toJson()).toList(),
      'appointments': appointments.map((e) => e.toJson()).toList(),
      'rehabExercises': rehabExercises.map((e) => e.toJson()).toList(),
      'exercisesToAvoid': exercisesToAvoid,
    };
  }

  /// Crée depuis un Map
  factory Injury.fromJson(Map<String, dynamic> json) {
    return Injury(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bodyPart: json['bodyPart'] as String,
      type: json['type'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      painLevel: json['painLevel'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      rehabPlan: json['rehabPlan'] as String?,
      notes: json['notes'] as String? ?? '',
      imagePaths: (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoUrl: json['videoUrl'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      painHistory: (json['painHistory'] as List<dynamic>?)
              ?.map((e) => PainHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      appointments: (json['appointments'] as List<dynamic>?)
              ?.map((e) => MedicalAppointment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rehabExercises: (json['rehabExercises'] as List<dynamic>?)
              ?.map((e) => RehabExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      exercisesToAvoid: (json['exercisesToAvoid'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

/// Notifier pour gérer les blessures (en mémoire)
class InjuryNotifier extends ChangeNotifier {
  static final InjuryNotifier _instance = InjuryNotifier._internal();
  factory InjuryNotifier() => _instance;
  InjuryNotifier._internal();

  final List<Injury> _injuries = [];
  static const String _currentUserId = 'user_demo_123'; // ID simulé

  /// Récupère toutes les blessures de l'utilisateur
  List<Injury> getInjuries() {
    return _injuries.where((i) => i.userId == _currentUserId).toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  /// Récupère une blessure par ID
  Injury? getInjuryById(String id) {
    try {
      return _injuries.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Ajoute une blessure
  void addInjury(Injury injury) {
    _injuries.add(injury);
    notifyListeners();
  }

  /// Met à jour une blessure
  void updateInjury(Injury injury) {
    final index = _injuries.indexWhere((i) => i.id == injury.id);
    if (index != -1) {
      _injuries[index] = injury;
      notifyListeners();
    }
  }

  /// Supprime une blessure
  void removeInjury(String id) {
    _injuries.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
















