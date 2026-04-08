import '../models/exercise_library_item.dart';
import '../models/video_pack.dart';
import 'default_exercises_library.dart';

/// Base de données d'exercices de démo (en local)
class DemoExercises {
  /// Liste de tous les exercices de démo
  /// Inclut la bibliothèque par défaut (111 exercices) + exercices de test/démo
  static List<ExerciseLibraryItem> get allExercises => [
    // Bibliothèque complète par défaut (111 exercices)
    ...DefaultExercisesLibrary.allExercises,
    
    // Exercices de test/démo (pour développeurs)
    // Exercice de TEST/DÉMO pour développeurs
    const ExerciseLibraryItem(
      id: 'test_developer',
      name: '🧪 Exercice Test Développeur',
      category: 'Full body',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Exercice de test pour les développeurs. Permet de tester le chronomètre, les boutons d\'action, la barre de difficulté, le coach vocal IA, les capteurs, la caméra et la voix. Cet exercice est destiné uniquement aux tests de fonctionnalités.',
      steps: [
        '1. Lance l\'exercice depuis la bibliothèque',
        '2. Teste le chronomètre (démarrage/pause/arrêt)',
        '3. Teste les boutons d\'action (capteurs, caméra, voix)',
        '4. Teste la barre de difficulté à la fin',
        '5. Teste le coach vocal IA (sélection dans AppBar)',
        '6. Vérifie que tous les éléments fonctionnent correctement',
      ],
      muscles: ['Test', 'Développement'],
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/coach_1_header.png',
      videoAsset: null,
      youtubeUrl: null,
      isOfficial: true,
      isUserCreated: false,
      perceivedDifficulty: 'Facile',
    ),
    
    // Exercices de test pour la Story Test
    const ExerciseLibraryItem(
      id: 'test_story_exercise_1',
      name: '🎯 Exercice Test Story - Niveau 1',
      category: 'Full body',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Premier exercice de la Story Test. Complète cet exercice pour débloquer le niveau suivant. Teste toutes les fonctionnalités : chronomètre, coach vocal IA, capteurs et difficulté.',
      steps: [
        '1. Démarre l\'exercice depuis la Story Test',
        '2. Effectue 20 secondes d\'exercice',
        '3. Le coach vocal IA t\'accompagne',
        '4. Complète pour débloquer l\'exercice 2',
      ],
      muscles: ['Test', 'Story'],
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/ChatGPT Image 25 nov. 2025, 18_27_24.png',
      videoAsset: null,
      youtubeUrl: null,
      isOfficial: true,
      isUserCreated: false,
      perceivedDifficulty: 'Facile',
    ),
    const ExerciseLibraryItem(
      id: 'test_story_exercise_2',
      name: '⚡ Exercice Test Story - Niveau 2',
      category: 'Full body',
      difficulty: ExerciseDifficulty.intermediate,
      description: 'Deuxième exercice de la Story Test. Débloqué après avoir complété l\'exercice 1. Continue ton aventure et débloque le niveau final.',
      steps: [
        '1. Cet exercice est débloqué après l\'exercice 1',
        '2. Effectue 30 secondes d\'exercice',
        '3. Le coach vocal IA continue de t\'encourager',
        '4. Complète pour débloquer l\'exercice 3',
      ],
      muscles: ['Test', 'Story'],
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/ChatGPT Image 25 nov. 2025, 18_32_27.png',
      videoAsset: null,
      youtubeUrl: null,
      isOfficial: true,
      isUserCreated: false,
      perceivedDifficulty: 'Moyen',
    ),
    const ExerciseLibraryItem(
      id: 'test_story_exercise_3',
      name: '👑 Exercice Test Story - Niveau 3',
      category: 'Full body',
      difficulty: ExerciseDifficulty.advanced,
      description: 'Exercice final de la Story Test. Débloqué après avoir complété l\'exercice 2. Complète cet exercice pour obtenir le badge de récompense.',
      steps: [
        '1. Cet exercice est débloqué après l\'exercice 2',
        '2. Effectue 40 secondes d\'exercice',
        '3. Le coach vocal IA te guide jusqu\'à la fin',
        '4. Complète pour obtenir le badge de récompense !',
      ],
      muscles: ['Test', 'Story'],
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/ChatGPT Image 25 nov. 2025, 18_35_02.png',
      videoAsset: null,
      youtubeUrl: null,
      isOfficial: true,
      isUserCreated: false,
      perceivedDifficulty: 'Difficile',
    ),
    
    // Exercices GRATUITS
    const ExerciseLibraryItem(
      id: 'squat_bodyweight',
      name: 'Squat au poids du corps',
      category: 'Jambes',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Exercice de base pour renforcer les jambes et les fessiers. Excellent pour débuter.',
      steps: [
        'Tiens-toi debout, pieds écartés de la largeur des épaules.',
        'Garde le dos droit et regarde devant toi.',
        'Descends en pliant les genoux comme si tu t\'asseyais sur une chaise.',
        'Va jusqu\'à ce que tes cuisses soient parallèles au sol.',
        'Remonte en contractant les fessiers.',
        'Répète le mouvement de manière contrôlée.',
      ],
      muscles: ['Quadriceps', 'Fessiers', 'Mollets'],
      muscleGroup: 'Jambes',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/exercises/squat.png',
      videoAsset: 'assets/videos/exercises/squat.mp4',
      youtubeUrl: 'https://www.youtube.com/watch?v=Dy28eq2PjcM', // Squat tutorial
    ),
    const ExerciseLibraryItem(
      id: 'pushup',
      name: 'Pompes',
      category: 'Haut du corps',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Exercice classique pour développer la force du haut du corps.',
      steps: [
        'Mets-toi en position de planche, bras tendus.',
        'Garde le corps droit, de la tête aux pieds.',
        'Descends en pliant les coudes jusqu\'à frôler le sol.',
        'Pousse vers le haut pour revenir à la position de départ.',
        'Répète en gardant un rythme régulier.',
      ],
      muscles: ['Pectoraux', 'Triceps', 'Épaules'],
      muscleGroup: 'Pectoraux',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/exercises/pushup.png',
      videoAsset: 'assets/videos/exercises/pushup.mp4',
      youtubeUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4', // Push-up tutorial
    ),
    const ExerciseLibraryItem(
      id: 'plank',
      name: 'Gainage (Planche)',
      category: 'Abdos',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Excellent exercice isométrique pour renforcer le core.',
      steps: [
        'Mets-toi en position de pompe, mais sur les avant-bras.',
        'Garde le corps droit et aligné.',
        'Contracte les abdos et les fessiers.',
        'Maintiens la position sans bouger.',
        'Respire normalement pendant l\'exercice.',
      ],
      muscles: ['Abdominaux', 'Fessiers', 'Épaules'],
      muscleGroup: 'Abdominaux',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/exercises/plank.png',
      videoAsset: 'assets/videos/exercises/plank.mp4',
      youtubeUrl: 'https://www.youtube.com/watch?v=pSHjTRCQxIw', // Plank tutorial
    ),
    const ExerciseLibraryItem(
      id: 'lunges',
      name: 'Fentes',
      category: 'Jambes',
      difficulty: ExerciseDifficulty.intermediate,
      description: 'Excellent pour travailler les jambes unilatéralement.',
      steps: [
        'Tiens-toi debout, pieds joints.',
        'Fais un grand pas en avant avec une jambe.',
        'Descends jusqu\'à ce que les deux genoux soient à 90 degrés.',
        'Pousse sur la jambe avant pour revenir debout.',
        'Répète avec l\'autre jambe.',
      ],
      muscles: ['Quadriceps', 'Fessiers', 'Mollets'],
      muscleGroup: 'Jambes',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/exercises/lunges.png',
      videoAsset: 'assets/videos/exercises/lunges.mp4',
      youtubeUrl: 'https://www.youtube.com/watch?v=QOVaHwm-Q6U', // Lunges tutorial
    ),
    const ExerciseLibraryItem(
      id: 'row_bodyweight',
      name: 'Rowing au poids du corps',
      category: 'Haut du corps',
      difficulty: ExerciseDifficulty.intermediate,
      description: 'Excellent exercice pour renforcer le dos et les bras. Peut être fait avec une table ou une barre.',
      steps: [
        'Installe-toi sous une table solide ou utilise une barre.',
        'Tiens-toi suspendu, bras tendus, corps droit.',
        'Tire ton corps vers le haut jusqu\'à toucher la table avec la poitrine.',
        'Descends lentement jusqu\'à extension complète des bras.',
        'Répète en gardant le contrôle.',
      ],
      muscles: ['Dorsaux', 'Biceps', 'Épaules'],
      muscleGroup: 'Dos',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/exercises/row_bodyweight.png',
      videoAsset: 'assets/videos/exercises/row_bodyweight.mp4',
      youtubeUrl: 'https://www.youtube.com/watch?v=eGo4IYlbE5g', // Bodyweight row tutorial
    ),
    const ExerciseLibraryItem(
      id: 'burpee',
      name: 'Burpees',
      category: 'Full body',
      difficulty: ExerciseDifficulty.advanced,
      description: 'Exercice cardio très efficace qui fait travailler tout le corps.',
      steps: [
        'Commence debout, puis accroupis-toi et mets les mains au sol.',
        'Saute tes pieds en arrière pour te retrouver en planche.',
        'Fais une pompe (optionnel pour débutant).',
        'Saute tes pieds vers tes mains.',
        'Saute en l\'air les bras tendus.',
        'Répète rapidement.',
      ],
      muscles: ['Full body', 'Cardio'],
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: false,
      imageAsset: 'assets/images/exercises/burpee.png',
      videoAsset: 'assets/videos/exercises/burpee.mp4',
      youtubeUrl: 'https://www.youtube.com/watch?v=TU8QYVW0gDU', // Burpee tutorial
    ),

    // Exercices PREMIUM - Pack HIIT
    const ExerciseLibraryItem(
      id: 'mountain_climber',
      name: 'Mountain Climbers',
      category: 'Cardio',
      difficulty: ExerciseDifficulty.intermediate,
      description: 'Exercice cardio intense qui renforce aussi le core.',
      steps: [
        'Mets-toi en position de planche.',
        'Alterne rapidement en ramenant un genou vers la poitrine.',
        'Change de jambe rapidement.',
        'Garde le dos droit et les abdos contractés.',
        'Main tiens un rythme élevé.',
      ],
      muscles: ['Cardio', 'Abdominaux', 'Épaules'],
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: true,
      packId: 'hiit_pack',
      imageAsset: 'assets/images/exercises/mountain_climber.png',
      videoAsset: 'assets/videos/exercises/mountain_climber.mp4',
      youtubeUrl: 'https://www.youtube.com/watch?v=nmwgirgXLYM', // Mountain climber tutorial
    ),
    const ExerciseLibraryItem(
      id: 'jumping_jacks',
      name: 'Sauts écartés (Jumping Jacks)',
      category: 'Cardio',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Échauffement cardio classique.',
      steps: [
        'Debout, saute en écartant les jambes et levant les bras.',
        'Reviens à la position initiale en sautant.',
        'Répète rapidement.',
      ],
      muscles: ['Cardio', 'Jambes'],
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: true,
      packId: 'hiit_pack',
      imageAsset: 'assets/images/exercises/jumping_jacks.png',
      videoAsset: 'assets/videos/exercises/jumping_jacks.mp4',
    ),
    const ExerciseLibraryItem(
      id: 'high_knees',
      name: 'Montées de genoux',
      category: 'Cardio',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Échauffement cardio efficace.',
      steps: [
        'Debout, cours sur place en montant les genoux haut.',
        'Balance les bras naturellement.',
        'Garde un rythme rapide.',
      ],
      muscles: ['Cardio', 'Quadriceps'],
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: true,
      packId: 'hiit_pack',
      imageAsset: 'assets/images/exercises/high_knees.png',
      videoAsset: 'assets/videos/exercises/high_knees.mp4',
    ),

    // Exercices PREMIUM - Pack Renforcement
    const ExerciseLibraryItem(
      id: 'deadlift_bodyweight',
      name: 'Soulevé de terre au poids du corps',
      category: 'Full body',
      difficulty: ExerciseDifficulty.intermediate,
      description: 'Excellent pour renforcer toute la chaîne postérieure.',
      steps: [
        'Debout, pieds largeur des hanches.',
        'Descends en gardant le dos droit et en pliant les hanches.',
        'Touche le sol (ou presque) avec les doigts.',
        'Remonte en contractant les fessiers et les ischio-jambiers.',
        'Répète de manière contrôlée.',
      ],
      muscles: ['Ischio-jambiers', 'Fessiers', 'Lombaires'],
      muscleGroup: 'Dos',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: true,
      packId: 'strength_pack',
      imageAsset: 'assets/images/exercises/deadlift.png',
      videoAsset: 'assets/videos/exercises/deadlift.mp4',
    ),
    const ExerciseLibraryItem(
      id: 'pullup',
      name: 'Tractions',
      category: 'Haut du corps',
      difficulty: ExerciseDifficulty.advanced,
      description: 'L\'un des meilleurs exercices pour le dos et les bras.',
      steps: [
        'Suspend-toi à une barre, mains en pronation.',
        'Tire ton corps vers le haut jusqu\'à ce que le menton passe la barre.',
        'Descends lentement jusqu\'à extension complète.',
        'Répète en gardant le contrôle.',
      ],
      muscles: ['Dorsaux', 'Biceps', 'Épaules'],
      muscleGroup: 'Dos',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: true,
      packId: 'strength_pack',
      imageAsset: 'assets/images/exercises/pullup.png',
      videoAsset: 'assets/videos/exercises/pullup.mp4',
    ),
    const ExerciseLibraryItem(
      id: 'dips',
      name: 'Dips sur banc',
      category: 'Haut du corps',
      difficulty: ExerciseDifficulty.intermediate,
      description: 'Excellent pour les triceps et les épaules.',
      steps: [
        'Assieds-toi sur un banc, mains sur le bord.',
        'Glisse vers l\'avant et descends en pliant les coudes.',
        'Remonte en contractant les triceps.',
        'Répète.',
      ],
      muscles: ['Triceps', 'Épaules', 'Pectoraux'],
      muscleGroup: 'Triceps',
      equipment: 'machine',
      isBodyweight: false,
      isPremium: true,
      packId: 'strength_pack',
      imageAsset: 'assets/images/exercises/dips.png',
      videoAsset: 'assets/videos/exercises/dips.mp4',
    ),

    // Exercices PREMIUM - Pack Yoga
    const ExerciseLibraryItem(
      id: 'downward_dog',
      name: 'Chien tête en bas',
      category: 'Mobilité',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Posture de yoga classique pour étirer tout le corps.',
      steps: [
        'Commence à quatre pattes.',
        'Lève les hanches pour former un V inversé.',
        'Garde les mains au sol, doigts écartés.',
        'Étire les jambes autant que possible.',
        'Respire profondément et maintiens.',
      ],
      muscles: ['Ischio-jambiers', 'Épaules', 'Mollets'],
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: true,
      packId: 'yoga_pack',
      imageAsset: 'assets/images/exercises/downward_dog.png',
      videoAsset: 'assets/videos/exercises/downward_dog.mp4',
    ),
    const ExerciseLibraryItem(
      id: 'warrior_pose',
      name: 'Posture du Guerrier',
      category: 'Mobilité',
      difficulty: ExerciseDifficulty.beginner,
      description: 'Posture de yoga pour renforcer les jambes et améliorer l\'équilibre.',
      steps: [
        'Debout, fais un grand pas en avant.',
        'Tourne le pied arrière à 45 degrés.',
        'Plie la jambe avant jusqu\'à ce que le genou soit au-dessus de la cheville.',
        'Lève les bras parallèlement au sol.',
        'Garde la position et respire.',
      ],
      muscles: ['Quadriceps', 'Fessiers', 'Équilibre'],
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
      isPremium: true,
      packId: 'yoga_pack',
      imageAsset: 'assets/images/exercises/warrior_pose.png',
      videoAsset: 'assets/videos/exercises/warrior_pose.mp4',
    ),
  ];

  /// Liste des packs vidéos disponibles
  static List<VideoPack> get videoPacks => [
    const VideoPack(
      id: 'hiit_pack',
      title: 'Pack HIIT Complet',
      description: '20+ exercices HIIT pour brûler des calories rapidement. Parfait pour les entraînements courts et intenses.',
      price: 14.99,
      exerciseIds: ['mountain_climber', 'jumping_jacks', 'high_knees'],
    ),
    const VideoPack(
      id: 'strength_pack',
      title: 'Pack Renforcement',
      description: '30+ exercices pour renforcer tout le corps. Idéal pour développer la force musculaire.',
      price: 19.99,
      exerciseIds: ['deadlift_bodyweight', 'pullup', 'dips'],
    ),
    const VideoPack(
      id: 'yoga_pack',
      title: 'Pack Yoga & Mobilité',
      description: '25+ postures de yoga et étirements pour améliorer la flexibilité et la mobilité.',
      price: 12.99,
      exerciseIds: ['downward_dog', 'warrior_pose'],
    ),
  ];

  /// Obtenir un exercice par son ID
  static ExerciseLibraryItem? getExerciseById(String id) {
    try {
      return allExercises.firstWhere((ex) => ex.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir un pack par son ID
  static VideoPack? getPackById(String id) {
    try {
      return videoPacks.firstWhere((pack) => pack.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les exercices d'une catégorie
  static List<ExerciseLibraryItem> getExercisesByCategory(String category) {
    return allExercises.where((ex) => ex.category == category).toList();
  }

  /// Obtenir les exercices d'un niveau de difficulté
  static List<ExerciseLibraryItem> getExercisesByDifficulty(ExerciseDifficulty difficulty) {
    return allExercises.where((ex) => ex.difficulty == difficulty).toList();
  }

  /// Obtenir les exercices d'un pack
  static List<ExerciseLibraryItem> getExercisesByPackId(String packId) {
    return allExercises.where((ex) => ex.packId == packId).toList();
  }
}

