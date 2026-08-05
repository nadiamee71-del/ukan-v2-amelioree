import 'package:flutter/foundation.dart';
import '../coach_personality/coach_personality_model.dart';

/// Modèle d'un exercice dans un programme d'entraînement
class Exercise {
  final String id;
  final String name;
  final String zone; // "Haut du corps", "Bas du corps", "Full body", "Cardio"
  final int sets; // Nombre de séries
  final int? reps; // Nombre de répétitions (optionnel si durée)
  final int? durationSeconds; // Durée en secondes (optionnel, pour gainage/cardio)
  final double? weightKg; // Poids en kg (optionnel)
  final int restSeconds; // Temps de repos entre séries (en secondes)
  final String? notes; // Notes du coach (facultatif)
  final String? videoUrl; // URL vidéo (facultatif, pour plus tard)
  final CoachStyle? coachStyleOverride; // Style de coach spécifique pour cet exercice (optionnel)

  const Exercise({
    required this.id,
    required this.name,
    required this.zone,
    required this.sets,
    this.reps,
    this.durationSeconds,
    this.weightKg,
    required this.restSeconds,
    this.notes,
    this.videoUrl,
    this.coachStyleOverride,
  });

  /// Génère un résumé textuel de l'exercice (ex: "3 x 12 reps • 60 kg • repos 90s")
  String getSummary() {
    final parts = <String>[];
    
    // Séries
    parts.add('$sets séries');
    
    // Répétitions ou durée
    if (reps != null) {
      parts.add('$reps reps');
    } else if (durationSeconds != null) {
      final minutes = durationSeconds! ~/ 60;
      final seconds = durationSeconds! % 60;
      if (minutes > 0 && seconds > 0) {
        parts.add('${minutes}min ${seconds}s');
      } else if (minutes > 0) {
        parts.add('${minutes}min');
      } else {
        parts.add('${seconds}s');
      }
    }
    
    // Poids (si renseigné et > 0)
    if (weightKg != null && weightKg! > 0) {
      parts.add('${weightKg!.toStringAsFixed(0)} kg');
    }
    
    // Repos
    final restMinutes = restSeconds ~/ 60;
    final restSecs = restSeconds % 60;
    if (restMinutes > 0 && restSecs > 0) {
      parts.add('repos ${restMinutes}min ${restSecs}s');
    } else if (restMinutes > 0) {
      parts.add('repos ${restMinutes}min');
    } else {
      parts.add('repos ${restSecs}s');
    }
    
    return parts.join(' • ');
  }
}

/// Modèle d'un programme d'entraînement créé par un coach
class CoachProgram {
  final String id;
  final String title;
  final String goal; // "Perte de poids", "Prise de masse", "Remise en forme"
  final String level; // "Débutant", "Intermédiaire", "Avancé"
  final int sessionsPerWeek; // Nombre de séances par semaine
  final int estimatedMinutes; // Durée estimée par séance (en minutes)
  final int durationWeeks; // Durée du programme en semaines
  final String? notes; // Notes générales du coach
  final List<Exercise> exercises; // Liste des exercices du programme
  final List<String> assignedClientIds; // Liste des IDs des clients associés (nouveau système)
  final CoachStyle? coachStyleOverride; // Style de coach spécifique pour ce programme (optionnel)
  
  // Compatibilité avec l'ancien système (déprécié)
  @Deprecated('Utiliser assignedClientIds à la place')
  String? get clientId => assignedClientIds.isNotEmpty ? assignedClientIds.first : null;

  const CoachProgram({
    required this.id,
    required this.title,
    required this.goal,
    required this.level,
    required this.sessionsPerWeek,
    required this.estimatedMinutes,
    required this.durationWeeks,
    this.notes,
    required this.exercises,
    required this.assignedClientIds,
    this.coachStyleOverride,
  });

  /// Constructeur pour compatibilité avec l'ancien système (un seul client)
  factory CoachProgram.fromSingleClient({
    required String id,
    required String title,
    required String goal,
    required String level,
    required int sessionsPerWeek,
    required int estimatedMinutes,
    int durationWeeks = 8,
    String? notes,
    required List<Exercise> exercises,
    required String clientId,
    CoachStyle? coachStyleOverride,
  }) {
    return CoachProgram(
      id: id,
      title: title,
      goal: goal,
      level: level,
      sessionsPerWeek: sessionsPerWeek,
      estimatedMinutes: estimatedMinutes,
      durationWeeks: durationWeeks,
      notes: notes,
      exercises: exercises,
      assignedClientIds: [clientId],
      coachStyleOverride: coachStyleOverride,
    );
  }

  /// Nombre de clients actifs
  int get activeClientsCount => assignedClientIds.length;

  /// Vérifie si le programme est assigné à un client
  bool isAssignedToClient(String clientId) {
    return assignedClientIds.contains(clientId);
  }

  /// Ajoute un client à la liste des assignés
  CoachProgram withClient(String clientId) {
    if (assignedClientIds.contains(clientId)) return this;
    return CoachProgram(
      id: id,
      title: title,
      goal: goal,
      level: level,
      sessionsPerWeek: sessionsPerWeek,
      estimatedMinutes: estimatedMinutes,
      durationWeeks: durationWeeks,
      notes: notes,
      exercises: exercises,
      assignedClientIds: [...assignedClientIds, clientId],
      coachStyleOverride: coachStyleOverride,
    );
  }

  /// Retire un client de la liste des assignés
  CoachProgram withoutClient(String clientId) {
    return CoachProgram(
      id: id,
      title: title,
      goal: goal,
      level: level,
      sessionsPerWeek: sessionsPerWeek,
      estimatedMinutes: estimatedMinutes,
      durationWeeks: durationWeeks,
      notes: notes,
      exercises: exercises,
      assignedClientIds: assignedClientIds.where((id) => id != clientId).toList(),
      coachStyleOverride: coachStyleOverride,
    );
  }
}

/// Notifier pour gérer les programmes créés par les coaches (en mémoire)
class CoachProgramsNotifier extends ChangeNotifier {
  static final CoachProgramsNotifier _instance =
      CoachProgramsNotifier._internal();
  factory CoachProgramsNotifier() => _instance;

  List<CoachProgram> _programs = [];

  CoachProgramsNotifier._internal() {
    // Programmes de démo
    _programs.addAll([
      // Programme Perte de poids - Phase 1 (assigné à Sarah et Mehdi)
      CoachProgram(
        id: 'program_perte_poids_1',
        title: 'Perte de poids – Phase 1',
        goal: 'Perte de poids',
        level: 'Intermédiaire',
        sessionsPerWeek: 3,
        estimatedMinutes: 45,
        durationWeeks: 8,
        notes: 'Programme adapté pour débuter une perte de poids progressive. Focus sur le cardio et le renforcement musculaire.',
        assignedClientIds: ['sarah', 'mehdi'],
        coachStyleOverride: null, // Utilise le style préféré du client
        exercises: [
          const Exercise(
            id: 'ex1',
            name: 'Squats',
            zone: 'Bas du corps',
            sets: 3,
            reps: 12,
            weightKg: null,
            restSeconds: 60,
            notes: 'Garde le dos droit et descends jusqu\'à ce que tes cuisses soient parallèles au sol.',
          ),
          const Exercise(
            id: 'ex2',
            name: 'Pompes',
            zone: 'Haut du corps',
            sets: 3,
            reps: 10,
            weightKg: null,
            restSeconds: 60,
            notes: 'Si trop difficile, commence sur les genoux.',
          ),
          const Exercise(
            id: 'ex3',
            name: 'Gainage planche',
            zone: 'Full body',
            sets: 3,
            reps: null,
            durationSeconds: 30,
            weightKg: null,
            restSeconds: 45,
            notes: 'Maintiens une position droite, engage les abdos.',
          ),
          const Exercise(
            id: 'ex4',
            name: 'Fentes alternées',
            zone: 'Bas du corps',
            sets: 3,
            reps: 10,
            weightKg: null,
            restSeconds: 60,
            notes: '10 répétitions par jambe.',
          ),
          const Exercise(
            id: 'ex5',
            name: 'Cardio vélo',
            zone: 'Cardio',
            sets: 1,
            reps: null,
            durationSeconds: 600,
            weightKg: null,
            restSeconds: 0,
            notes: '10 minutes à intensité modérée.',
          ),
        ],
      ),
      // Programme Prise de masse - Débutant (assigné à 3 clients)
      CoachProgram(
        id: 'program_prise_masse_debutant',
        title: 'Prise de masse – Débutant',
        goal: 'Prise de masse',
        level: 'Débutant',
        sessionsPerWeek: 4,
        estimatedMinutes: 60,
        durationWeeks: 12,
        notes: 'Programme pour débutants souhaitant prendre de la masse musculaire. Progression progressive.',
        assignedClientIds: ['lina', 'marie', 'alex'],
        coachStyleOverride: CoachStyle.hard, // Force le style "dur" pour ce programme
        exercises: [
          const Exercise(
            id: 'ex_pm1',
            name: 'Développé couché',
            zone: 'Haut du corps',
            sets: 4,
            reps: 8,
            weightKg: 40,
            restSeconds: 90,
            notes: 'Commence léger et augmente progressivement.',
          ),
          const Exercise(
            id: 'ex_pm2',
            name: 'Squats',
            zone: 'Bas du corps',
            sets: 4,
            reps: 10,
            weightKg: 50,
            restSeconds: 90,
            notes: 'Forme avant tout.',
          ),
          const Exercise(
            id: 'ex_pm3',
            name: 'Rowing',
            zone: 'Haut du corps',
            sets: 3,
            reps: 12,
            weightKg: 30,
            restSeconds: 60,
          ),
        ],
      ),
      // Programme Remise en forme complète (assigné à l'élève de démonstration current_user)
      CoachProgram(
        id: 'program_remise_forme',
        title: 'Remise en forme complète',
        goal: 'Remise en forme',
        level: 'Intermédiaire',
        sessionsPerWeek: 3,
        estimatedMinutes: 40,
        durationWeeks: 6,
        notes: 'Programme général pour se remettre en forme, combinant cardio et renforcement.',
        assignedClientIds: ['current_user'],
        coachStyleOverride: CoachStyle.gentle, // Style bienveillant
        exercises: [
          const Exercise(
            id: 'ex_rf1',
            name: 'Échauffement cardio',
            zone: 'Cardio',
            sets: 1,
            reps: null,
            durationSeconds: 300,
            restSeconds: 0,
            notes: '5 minutes de marche rapide ou vélo.',
          ),
          const Exercise(
            id: 'ex_rf2',
            name: 'Circuit complet',
            zone: 'Full body',
            sets: 3,
            reps: 12,
            restSeconds: 45,
          ),
        ],
      ),
    ]);
  }

  /// Récupère tous les programmes
  List<CoachProgram> get programs => List.unmodifiable(_programs);

  /// Récupère les programmes associés à un client spécifique
  List<CoachProgram> programsForClient(String clientId) {
    return _programs.where((p) => p.isAssignedToClient(clientId)).toList();
  }
  
  /// Récupère les programmes qui ne sont pas encore assignés à un client
  List<CoachProgram> getUnassignedPrograms() {
    return _programs.where((p) => p.assignedClientIds.isEmpty).toList();
  }
  
  /// Récupère les programmes avec des clients actifs (bibliothèque)
  List<CoachProgram> getProgramsWithClients() {
    return _programs.where((p) => p.assignedClientIds.isNotEmpty).toList();
  }
  
  /// Récupère les programmes filtrés par objectif
  List<CoachProgram> getProgramsByGoal(String goal) {
    return _programs.where((p) => p.goal == goal).toList();
  }
  
  /// Récupère les programmes filtrés par niveau
  List<CoachProgram> getProgramsByLevel(String level) {
    return _programs.where((p) => p.level == level).toList();
  }
  
  /// Assigne un programme à un client
  void assignProgramToClient(String programId, String clientId) {
    final program = getProgramById(programId);
    if (program != null && !program.isAssignedToClient(clientId)) {
      final updated = program.withClient(clientId);
      updateProgram(updated);
    }
  }
  
  /// Retire un client d'un programme
  void unassignProgramFromClient(String programId, String clientId) {
    final program = getProgramById(programId);
    if (program != null && program.isAssignedToClient(clientId)) {
      final updated = program.withoutClient(clientId);
      updateProgram(updated);
    }
  }

  /// Récupère un programme par son ID
  CoachProgram? getProgramById(String id) {
    try {
      return _programs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Ajoute un nouveau programme
  void addProgram(CoachProgram program) {
    _programs.add(program);
    notifyListeners();
  }

  /// Supprime un programme (pour plus tard si nécessaire)
  void removeProgram(String id) {
    _programs.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Met à jour un programme existant (pour plus tard si nécessaire)
  void updateProgram(CoachProgram updatedProgram) {
    final index = _programs.indexWhere((p) => p.id == updatedProgram.id);
    if (index != -1) {
      _programs[index] = updatedProgram;
      notifyListeners();
    }
  }
}

