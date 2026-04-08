import 'package:flutter/foundation.dart';

/// Modèle pour un niveau de jeu
class GameLevel {
  final int level;
  final String name;
  final String description;
  final int requiredSessions; // Nombre de séances pour débloquer

  const GameLevel({
    required this.level,
    required this.name,
    required this.description,
    required this.requiredSessions,
  });
}

/// Modèle pour un boss
class GameBoss {
  final String id;
  final String name;
  final String description;
  final String challenge; // Ex: "100 squats", "20 min HIIT"
  final int targetValue; // Objectif numérique (100 squats, 20 minutes, 3 séances)
  final String targetUnit; // Unité : "squats", "minutes", "séances"
  final bool isDefeated;

  const GameBoss({
    required this.id,
    required this.name,
    required this.description,
    required this.challenge,
    required this.targetValue,
    required this.targetUnit,
    this.isDefeated = false,
  });

  GameBoss copyWith({bool? isDefeated}) {
    return GameBoss(
      id: id,
      name: name,
      description: description,
      challenge: challenge,
      targetValue: targetValue,
      targetUnit: targetUnit,
      isDefeated: isDefeated ?? this.isDefeated,
    );
  }
}

/// Modèle pour une quête journalière
class DailyQuest {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String? tag; // "Story", "Santé", "Habitude", "Social"
  final int xpReward;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.tag,
    this.xpReward = 10,
  });

  DailyQuest copyWith({bool? isCompleted}) {
    return DailyQuest(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      tag: tag,
      xpReward: xpReward,
    );
  }
}

/// Modèle pour un chapitre de Story
class StoryChapter {
  final String id;
  final int chapterNumber;
  final String title;
  final String subtitle;
  final String description;
  final GameBoss boss;
  final List<ChapterMission> missions;
  final bool isUnlocked;
  final bool isCompleted;
  final String? imagePath; // Chemin vers l'illustration du chapitre

  const StoryChapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.boss,
    required this.missions,
    this.isUnlocked = true,
    this.isCompleted = false,
    this.imagePath,
  });

  StoryChapter copyWith({
    bool? isUnlocked,
    bool? isCompleted,
    List<ChapterMission>? missions,
    String? imagePath,
  }) {
    return StoryChapter(
      id: id,
      chapterNumber: chapterNumber,
      title: title,
      subtitle: subtitle,
      description: description,
      boss: boss,
      missions: missions ?? this.missions,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

/// Modèle pour une mission dans un chapitre
class ChapterMission {
  final String id;
  final String title;
  final String description;
  final String icon; // Emoji ou nom d'icône
  final MissionStatus status; // En cours / Terminé / Verrouillé
  final int? targetValue; // Optionnel pour les missions avec objectif numérique

  const ChapterMission({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.status = MissionStatus.locked,
    this.targetValue,
  });

  ChapterMission copyWith({MissionStatus? status, int? targetValue}) {
    return ChapterMission(
      id: id,
      title: title,
      description: description,
      icon: icon,
      status: status ?? this.status,
      targetValue: targetValue ?? this.targetValue,
    );
  }
}

enum MissionStatus {
  locked,
  inProgress,
  completed,
}

/// Modèle pour une récompense/badge
class GameReward {
  final String id;
  final String name;
  final String description;
  final String icon; // Emoji ou icône
  final String? imagePath; // Chemin vers l'image du badge (optionnel)
  final bool isUnlocked;
  final String? unlockCondition; // Condition pour débloquer (affichée si verrouillé)
  final DateTime? unlockedDate; // Date de déblocage (en démo, peut être null)

  const GameReward({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.imagePath,
    this.isUnlocked = false,
    this.unlockCondition,
    this.unlockedDate,
  });

  GameReward copyWith({
    bool? isUnlocked,
    DateTime? unlockedDate,
    String? imagePath,
  }) {
    return GameReward(
      id: id,
      name: name,
      description: description,
      icon: icon,
      imagePath: imagePath ?? this.imagePath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockCondition: unlockCondition,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }
}

/// Notifier pour gérer le jeu
class GameStoryNotifier extends ChangeNotifier {
  static final GameStoryNotifier _instance = GameStoryNotifier._internal();
  factory GameStoryNotifier() => _instance;
  GameStoryNotifier._internal();

  int _currentLevel = 1;
  int _currentXP = 0;
  int _xpForNextLevel = 100;

  final List<GameBoss> _bosses = [
    const GameBoss(
      id: 'legs',
      name: 'Boss Jambes',
      description: '10 squats pour le vaincre',
      challenge: '10 squats',
      targetValue: 10,
      targetUnit: 'squats',
    ),
    const GameBoss(
      id: 'cardio',
      name: 'Boss Cardio',
      description: '20 min de HIIT pour le vaincre',
      challenge: '20 min de HIIT',
      targetValue: 20,
      targetUnit: 'minutes',
    ),
    const GameBoss(
      id: 'core',
      name: 'Boss Core',
      description: '3 séances abdos pour le vaincre',
      challenge: '3 séances abdos',
      targetValue: 3,
      targetUnit: 'séances',
    ),
  ];

  // Chapitres de la Story - Univers complet narratif
  final List<StoryChapter> _chapters = [
    // STORY 1 : La Salle d'Entraînement Oubliée
    StoryChapter(
      id: 'story1',
      chapterNumber: 1,
      title: 'STORY 1 : La Salle d\'Entraînement Oubliée',
      subtitle: 'Le départ de ton aventure',
      description: 'Tu découvres une salle d\'entraînement abandonnée depuis des années. '
          'La poussière recouvre les appareils et l\'air est lourd, comme si personne n\'était entré ici depuis très longtemps.\n\n'
          'Devant toi se trouve une porte massive en métal. Sur ses côtés, seules quelques barres lumineuses clignotent faiblement.\n\n'
          'Une phrase apparaît sur le mur : « Pour réveiller la salle, tu dois activer ton propre corps. »\n\n'
          'Chaque squat que tu fais recharge la porte. Quand elle sera pleinement allumée… elle s\'ouvrira.',
      imagePath: 'assets/images/boss_squat_0.png',
      boss: const GameBoss(
        id: 'boss_story1',
        name: 'La Porte Verrouillée',
        description: 'Une lourde porte métallique bloque l\'accès à la salle principale.',
        challenge: 'Fais 5 squats pour l\'ouvrir.',
        targetValue: 5,
        targetUnit: 'squats',
      ),
      missions: [
        const ChapterMission(
          id: 'story1_mission1',
          title: 'Fais 5 squats pour ouvrir la porte',
          description: 'La porte s\'illumine à chaque squat.',
          icon: '🏋️',
          status: MissionStatus.inProgress,
          targetValue: 5,
        ),
      ],
    ),
    // STORY 2 : Le Couloir de l'Énergie
    StoryChapter(
      id: 'story2',
      chapterNumber: 2,
      title: 'STORY 2 : Le Couloir de l\'Énergie',
      subtitle: 'Recharge ton énergie intérieure',
      description: 'Après l\'ouverture de la porte, tu découvres un long couloir futuriste plongé dans l\'obscurité.\n\n'
          'Sur les murs, des lignes d\'énergie bleue sont éteintes, comme des veines sans circulation.\n\n'
          'Un message s\'affiche au sol : « La stabilité vient du centre. Tiens bon. »\n\n'
          'À chaque seconde de gainage, le couloir s\'éclaire et révèle son architecture. '
          'Ce n\'est qu\'en prouvant ton endurance que tu parviendras au bout.',
      imagePath: 'assets/images/mon_profil_gagnant.png',
      boss: const GameBoss(
        id: 'energy',
        name: 'Le Couloir de l\'Énergie',
        description: '10 secondes de gainage pour continuer',
        challenge: '10 secondes de gainage',
        targetValue: 10,
        targetUnit: 'secondes',
      ),
      missions: [
        const ChapterMission(
          id: 'story2_mission1',
          title: 'Tiens 10 secondes en gainage',
          description: 'Chaque seconde allume un peu plus le couloir.',
          icon: '⚡',
          status: MissionStatus.locked,
          targetValue: 10,
        ),
      ],
    ),
    // STORY 3 : L'Autel de l'Hydratation
    StoryChapter(
      id: 'story3',
      chapterNumber: 3,
      title: 'STORY 3 : L\'Autel de l\'Hydratation',
      subtitle: 'Aucune évolution sans hydratation',
      description: 'Tu arrives dans une salle circulaire. Au centre, un autel ancien soutient une goutte de lumière bleue flottante.\n\n'
          'Elle pulse lentement, comme un cœur prêt à se réveiller.\n\n'
          'Une inscription apparaît : « Celui qui néglige l\'eau éteint son potentiel. »\n\n'
          'À chaque fois que tu bois, la lumière de l\'autel s\'intensifie. '
          'Quand l\'autel est pleinement éveillé, un nouveau chemin se dévoile.',
      imagePath: 'assets/images/mon_profil_neutre.png',
      boss: const GameBoss(
        id: 'hydration',
        name: 'L\'Autel de l\'Hydratation',
        description: '200 ml d\'eau pour continuer',
        challenge: '200 ml d\'eau',
        targetValue: 200,
        targetUnit: 'ml',
      ),
      missions: [
        const ChapterMission(
          id: 'story3_mission1',
          title: 'Bois 200 ml d\'eau',
          description: 'L\'autel s\'illumine à chaque gorgée.',
          icon: '💧',
          status: MissionStatus.locked,
          targetValue: 200,
        ),
      ],
    ),
    // STORY 4 : Le Pont des 5000 Pas
    StoryChapter(
      id: 'story4',
      chapterNumber: 4,
      title: 'STORY 4 : Le Pont des 5000 Pas',
      subtitle: 'Prouve ta constance',
      description: 'L\'autel libère une onde lumineuse qui ouvre un passage vers un pont suspendu.\n\n'
          'Sous tes pieds, les planches semblent flotter dans le vide. '
          'Elles ne s\'allument que lorsque tu avances, comme si le pont se construisait avec ta détermination.\n\n'
          '« Chaque pas te rapproche de ton destin. »\n\n'
          'Plus tu marches, plus le pont devient solide et lumineux, révélant une porte dorée au loin.',
      imagePath: 'assets/images/fitpro_logo.png',
      boss: const GameBoss(
        id: 'bridge',
        name: 'Le Pont des 5000 Pas',
        description: '5000 pas pour stabiliser le pont',
        challenge: '5000 pas',
        targetValue: 5000,
        targetUnit: 'pas',
      ),
      missions: [
        const ChapterMission(
          id: 'story4_mission1',
          title: 'Marche 5000 pas',
          description: 'Le pont se construit pas après pas.',
          icon: '🚶',
          status: MissionStatus.locked,
          targetValue: 5000,
        ),
      ],
    ),
    // STORY 5 : La Porte du Sommeil Sacré
    StoryChapter(
      id: 'story5',
      chapterNumber: 5,
      title: 'STORY 5 : La Porte du Sommeil Sacré',
      subtitle: 'Le corps progresse aussi pendant la nuit',
      description: 'Le pont mène à une gigantesque porte dorée vibrant d\'une énergie douce.\n\n'
          'Au-dessus, une phrase est gravée : « Le repos est aussi un entraînement. »\n\n'
          'La porte ne s\'ouvre qu\'aux guerriers qui respectent leur sommeil. '
          'Plus tu dors, plus sa lumière s\'intensifie.\n\n'
          'Quand elle brillera totalement… l\'épreuve finale commencera.',
      imagePath: 'assets/images/badge_repos_guerrier.png',
      boss: const GameBoss(
        id: 'sleep',
        name: 'La Porte du Sommeil Sacré',
        description: '7 heures de sommeil pour débloquer',
        challenge: '7 heures de sommeil',
        targetValue: 7,
        targetUnit: 'heures',
      ),
      missions: [
        const ChapterMission(
          id: 'story5_mission1',
          title: 'Dors 7 heures',
          description: 'La porte se charge pendant ton sommeil.',
          icon: '🌙',
          status: MissionStatus.locked,
          targetValue: 7,
        ),
      ],
    ),
    // BOSS JAMBES - Chapitre final
    StoryChapter(
      id: 'boss_legs',
      chapterNumber: 6,
      title: 'BOSS JAMBES : Le Gardien du Niveau 2',
      subtitle: 'Prouve ta force',
      description: 'Le sol tremble. Une silhouette colossale se dessine dans la fumée.\n\n'
          'C\'est le Gardien des Jambes, protecteur du passage vers le deuxième monde.\n\n'
          '« Montre-moi ta force. »\n\n'
          'À chaque squat, le Boss recule, impressionné. À 10 squats, il tombe à genoux.',
      imagePath: 'assets/images/boss_squat_0.png',
      boss: const GameBoss(
        id: 'legs',
        name: 'Boss Jambes',
        description: '10 squats pour le vaincre',
        challenge: '10 squats',
        targetValue: 10,
        targetUnit: 'squats',
      ),
      missions: [
        const ChapterMission(
          id: 'boss_mission1',
          title: '0/10 → Le Boss te jauge',
          description: 'Commence à l\'impressionner',
          icon: '👁️',
          status: MissionStatus.inProgress,
          targetValue: 3,
        ),
        const ChapterMission(
          id: 'boss_mission2',
          title: '3/10 → Tu commences à l\'impressionner',
          description: 'Continue, tu le domines',
          icon: '💪',
          status: MissionStatus.locked,
          targetValue: 6,
        ),
        const ChapterMission(
          id: 'boss_mission3',
          title: '6/10 → Il recule… tu le domines',
          description: 'La victoire approche',
          icon: '⚔️',
          status: MissionStatus.locked,
          targetValue: 9,
        ),
        const ChapterMission(
          id: 'boss_mission4',
          title: '10/10 → Victoire ! Le passage s\'ouvre',
          description: 'Tu es officiellement un conquérant',
          icon: '👑',
          status: MissionStatus.locked,
          targetValue: 10,
        ),
      ],
    ),
    // STORY TEST : Story de test avec exercices qui se débloquent
    StoryChapter(
      id: 'story_test',
      chapterNumber: 7,
      title: '🧪 TEST - STORY TEST : L\'Aventure du Testeur',
      subtitle: 'TEST - Débloque les exercices un par un',
      description: '🧪 TEST - Une histoire spéciale pour tester le système de déblocage progressif. Complète chaque exercice pour débloquer le suivant et obtenir le badge final.',
      imagePath: 'assets/images/ChatGPT Image 25 nov. 2025, 18_45_34.png',
      boss: const GameBoss(
        id: 'test_final',
        name: '🧪 TEST - Le Défi Final',
        description: 'TEST - Complète les 3 exercices pour obtenir le badge',
        challenge: 'TEST - 3 exercices complétés',
        targetValue: 3,
        targetUnit: 'exercices',
      ),
      missions: [
        const ChapterMission(
          id: 'test_mission1',
          title: '🧪 TEST - Exercice 1 : Les Fondations',
          description: 'TEST - Complète le premier exercice pour débloquer le suivant',
          icon: '🎯',
          status: MissionStatus.inProgress,
          targetValue: 1,
        ),
        const ChapterMission(
          id: 'test_mission2',
          title: '🧪 TEST - Exercice 2 : L\'Ascension',
          description: 'TEST - Débloqué après l\'exercice 1. Continue ton aventure',
          icon: '⚡',
          status: MissionStatus.locked,
          targetValue: 2,
        ),
        const ChapterMission(
          id: 'test_mission3',
          title: '🧪 TEST - Exercice 3 : La Victoire',
          description: 'TEST - Débloqué après l\'exercice 2. Obtiens le badge final !',
          icon: '👑',
          status: MissionStatus.locked,
          targetValue: 3,
        ),
      ],
    ),
  ];

  final List<DailyQuest> _dailyQuests = [
    const DailyQuest(
      id: 'quest1',
      title: 'Faire une séance',
      description: 'Développe ton potentiel.',
      tag: 'Story',
      xpReward: 15,
    ),
    const DailyQuest(
      id: 'quest2',
      title: 'Boire de l\'eau',
      description: 'Recharge ton énergie.',
      tag: 'Santé',
      xpReward: 5,
    ),
    const DailyQuest(
      id: 'quest3',
      title: 'Faire 30 squats',
      description: 'Renforce tes fondations.',
      tag: 'Story',
      xpReward: 10,
    ),
    const DailyQuest(
      id: 'quest4',
      title: 'Dormir 7 heures',
      description: 'Ton corps se régénère.',
      tag: 'Santé',
      xpReward: 5,
    ),
    const DailyQuest(
      id: 'quest5',
      title: 'Marcher 5000 pas',
      description: 'Explore ton environnement.',
      tag: 'Habitude',
      xpReward: 10,
    ),
  ];

  final List<GameReward> _rewards = [
    // Badges des Stories
    const GameReward(
      id: 'starter',
      name: 'Starter',
      description: 'Tu entres dans la voie.',
      icon: '🎯',
      imagePath: 'assets/images/badge_starter.png',
      isUnlocked: true,
      unlockCondition: 'Faire 5 squats (Story 1)',
    ),
    const GameReward(
      id: 'endurant',
      name: 'Endurant',
      description: 'Ton mental est solide.',
      icon: '💪',
      imagePath: 'assets/images/badge_endurant.png',
      unlockCondition: 'Faire 10 secondes de gainage (Story 2)',
    ),
    const GameReward(
      id: 'hydro_boost',
      name: 'Hydro Boost',
      description: 'Hydraté = prêt à avancer.',
      icon: '💧',
      imagePath: 'assets/images/badge_hydro_boost.png',
      unlockCondition: 'Boire 200 ml d\'eau (Story 3)',
    ),
    const GameReward(
      id: 'en_marche',
      name: 'En Marche',
      description: 'La route t\'appartient.',
      icon: '🚶',
      imagePath: 'assets/images/badge_en_marche.png',
      unlockCondition: 'Marcher 5000 pas (Story 4)',
    ),
    const GameReward(
      id: 'repos_guerrier',
      name: 'Repos du Guerrier',
      description: 'La récupération fait partie du pouvoir.',
      icon: '🌙',
      imagePath: 'assets/images/badge_repos_guerrier.png',
      unlockCondition: 'Dormir 7 heures (Story 5)',
    ),
    // Badge Boss
    const GameReward(
      id: 'boss_slayer',
      name: 'Boss Slayer',
      description: 'Tu écrases les obstacles.',
      icon: '👑',
      imagePath: 'assets/images/badge_boss_slayer.png',
      unlockCondition: 'Vaincre le Boss Jambes (10 squats)',
    ),
    // Badge final
    const GameReward(
      id: 'legend',
      name: 'Légende',
      description: 'Ton nom s\'inscrit dans la légende.',
      icon: '⭐',
      imagePath: 'assets/images/badge_legende.png',
      unlockCondition: 'Avoir 6 badges',
    ),
    // Badge Story Test
    const GameReward(
      id: 'test_story_badge',
      name: '🧪 TEST - Maître du Test',
      description: '🧪 TEST - Tu as complété la Story Test avec succès !',
      icon: '🎯',
      imagePath: 'assets/images/badge_starter.png',
      unlockCondition: '🧪 TEST - Compléter les 3 exercices de la Story Test',
    ),
  ];

  int get currentLevel => _currentLevel;
  int get currentXP => _currentXP;
  int get xpForNextLevel => _xpForNextLevel;
  List<GameBoss> get bosses => List.unmodifiable(_bosses);
  List<DailyQuest> get dailyQuests => List.unmodifiable(_dailyQuests);
  List<GameReward> get rewards => List.unmodifiable(_rewards);
  List<StoryChapter> get chapters => List.unmodifiable(_chapters);
  
  // Obtenir le chapitre actuel (le premier non complété)
  StoryChapter? get currentChapter {
    try {
      return _chapters.firstWhere(
        (chapter) => !chapter.isCompleted,
        orElse: () => _chapters.first,
      );
    } catch (e) {
      return _chapters.isNotEmpty ? _chapters.first : null;
    }
  }
  
  // Obtenir le premier chapitre débloqué (pour redirection automatique)
  StoryChapter? get firstUnlockedChapter {
    try {
      // Chercher le premier chapitre débloqué et non complété
      final unlockedNotCompleted = _chapters.where(
        (chapter) => chapter.isUnlocked && !chapter.isCompleted,
      ).firstOrNull;
      
      if (unlockedNotCompleted != null) {
        return unlockedNotCompleted;
      }
      
      // Sinon, chercher le premier chapitre débloqué
      final unlocked = _chapters.where(
        (chapter) => chapter.isUnlocked,
      ).firstOrNull;
      
      if (unlocked != null) {
        return unlocked;
      }
      
      // En dernier recours, retourner le premier chapitre
      return _chapters.isNotEmpty ? _chapters.first : null;
    } catch (e) {
      return _chapters.isNotEmpty ? _chapters.first : null;
    }
  }
  
  // Obtenir le chapitre suivant après un chapitre donné
  StoryChapter? getNextChapter(String currentChapterId) {
    final currentIndex = _chapters.indexWhere((c) => c.id == currentChapterId);
    if (currentIndex == -1 || currentIndex >= _chapters.length - 1) {
      return null; // Pas de chapitre suivant
    }
    
    final nextChapter = _chapters[currentIndex + 1];
    // Retourner seulement si le chapitre suivant est débloqué
    if (nextChapter.isUnlocked) {
      return nextChapter;
    }
    return null;
  }
  
  // Obtenir la progression du chapitre actuel
  String get currentChapterProgress {
    final chapter = currentChapter;
    if (chapter == null) return '0 / 0 étapes complétées';
    
    final completedMissions = chapter.missions.where((m) => m.status == MissionStatus.completed).length;
    return '$completedMissions / ${chapter.missions.length} étapes complétées';
  }

  void addXP(int xp) {
    _currentXP += xp;
    while (_currentXP >= _xpForNextLevel) {
      _currentXP -= _xpForNextLevel;
      _currentLevel++;
      _xpForNextLevel = (100 * _currentLevel).toInt();
    }
    notifyListeners();
  }

  void defeatBoss(String bossId) {
    final index = _bosses.indexWhere((b) => b.id == bossId);
    if (index != -1 && !_bosses[index].isDefeated) {
      _bosses[index] = _bosses[index].copyWith(isDefeated: true);
      
      // Débloquer la récompense correspondante
      final rewardIndex = _rewards.indexWhere((r) => r.id == 'boss_$bossId');
      if (rewardIndex != -1) {
        _rewards[rewardIndex] = _rewards[rewardIndex].copyWith(isUnlocked: true);
      }
      
      addXP(50); // Bonus XP pour vaincre un boss
      notifyListeners();
    }
  }

  void completeQuest(String questId) {
    final index = _dailyQuests.indexWhere((q) => q.id == questId);
    if (index != -1 && !_dailyQuests[index].isCompleted) {
      final quest = _dailyQuests[index];
      _dailyQuests[index] = quest.copyWith(isCompleted: true);
      addXP(quest.xpReward);
      notifyListeners();
    }
  }
  
  // Mettre à jour une mission de chapitre
  void updateChapterMission(String chapterId, String missionId, MissionStatus status) {
    final chapterIndex = _chapters.indexWhere((c) => c.id == chapterId);
    if (chapterIndex == -1) return;
    
    final chapter = _chapters[chapterIndex];
    final missionIndex = chapter.missions.indexWhere((m) => m.id == missionId);
    if (missionIndex == -1) return;
    
    final updatedMissions = List<ChapterMission>.from(chapter.missions);
    updatedMissions[missionIndex] = updatedMissions[missionIndex].copyWith(status: status);
    
    // Vérifier si toutes les missions sont complétées
    final allCompleted = updatedMissions.every((m) => m.status == MissionStatus.completed);
    
    _chapters[chapterIndex] = chapter.copyWith(
      missions: updatedMissions,
      isCompleted: allCompleted,
    );
    
    notifyListeners();
  }
  
  // Débloquer un badge
  void unlockReward(String rewardId) {
    final index = _rewards.indexWhere((r) => r.id == rewardId);
    if (index != -1 && !_rewards[index].isUnlocked) {
      _rewards[index] = _rewards[index].copyWith(
        isUnlocked: true,
        unlockedDate: DateTime.now(),
      );
      notifyListeners();
    }
  }
  
  /// Retourne le badge associé à une story
  GameReward getRewardForStory(String storyId) {
    String rewardId;
    switch (storyId) {
      case 'story1':
        rewardId = 'starter';
        break;
      case 'story2':
        rewardId = 'endurant';
        break;
      case 'story3':
        rewardId = 'hydro_boost';
        break;
      case 'story4':
        rewardId = 'en_marche';
        break;
      case 'story5':
        rewardId = 'repos_guerrier';
        break;
      case 'story_test':
        rewardId = 'test_story_badge';
        break;
      case 'boss_legs':
        rewardId = 'boss_slayer';
        break;
      default:
        rewardId = 'starter';
    }
    
    return _rewards.firstWhere(
      (r) => r.id == rewardId,
      orElse: () => _rewards.first,
    );
  }
  
  /// Compléter une mission depuis un workout (appelé quand le chrono se termine)
  void completeMissionFromWorkout({
    required String storyId,
    required String missionId,
    required int targetValue,
  }) {
    // 1. Récupérer le chapitre
    final chapterIndex = _chapters.indexWhere((c) => c.id == storyId);
    if (chapterIndex == -1) return;
    
    final chapter = _chapters[chapterIndex];
    
    // 2. Récupérer la mission
    final missionIndex = chapter.missions.indexWhere((m) => m.id == missionId);
    if (missionIndex == -1) return;
    
    // 3. Mettre la mission en complétée
    final updatedMissions = List<ChapterMission>.from(chapter.missions);
    updatedMissions[missionIndex] = updatedMissions[missionIndex].copyWith(
      status: MissionStatus.completed,
    );
    
    // 4. Si toutes les missions du chapitre sont complètes → chapter complété
    final allCompleted = updatedMissions.every((m) => m.status == MissionStatus.completed);
    
    _chapters[chapterIndex] = chapter.copyWith(
      missions: updatedMissions,
      isCompleted: allCompleted,
    );
    
    if (allCompleted) {
      // 4a. Débloquer le badge lié à cette story
      final reward = getRewardForStory(storyId);
      unlockReward(reward.id);
      
      // 4b. Débloquer la story suivante (si elle existe)
      final nextIndex = chapterIndex + 1;
      if (nextIndex < _chapters.length) {
        final nextChapter = _chapters[nextIndex];
        if (!nextChapter.isUnlocked) {
          _chapters[nextIndex] = nextChapter.copyWith(isUnlocked: true);
          
          // Débloquer la première mission de la story suivante
          if (nextChapter.missions.isNotEmpty) {
            final firstMission = nextChapter.missions.first;
            final nextMissions = List<ChapterMission>.from(nextChapter.missions);
            nextMissions[0] = nextMissions[0].copyWith(status: MissionStatus.inProgress);
            _chapters[nextIndex] = _chapters[nextIndex].copyWith(missions: nextMissions);
          }
        }
      }
    }
    
    notifyListeners();
  }
}

