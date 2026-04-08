import '../models/exercise_library_item.dart';

/// Bibliothèque complète d'exercices par défaut (111 exercices)
/// Utilisée partout dans l'application pour la sélection d'exercices
class DefaultExercisesLibrary {
  static List<ExerciseLibraryItem> get allExercises => [
    // ========== ABDOMINAUX ==========
    _createExercise(
      id: 'abdo_1',
      name: 'Crunch au sol',
      muscleGroup: 'Abdominaux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'abdo_2',
      name: 'Crunch au banc incliné',
      muscleGroup: 'Abdominaux',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'abdo_3',
      name: 'Crunch à la poulie haute',
      muscleGroup: 'Abdominaux',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'abdo_4',
      name: 'Crunch avec rotation (obliques)',
      muscleGroup: 'Abdominaux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'abdo_5',
      name: 'Crunch jambes levées',
      muscleGroup: 'Abdominaux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'abdo_6',
      name: 'Relevé de jambes suspendu',
      muscleGroup: 'Abdominaux',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'abdo_7',
      name: 'Relevé de bassin sur banc',
      muscleGroup: 'Abdominaux',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'abdo_8',
      name: 'Gainage (planche ventrale)',
      muscleGroup: 'Abdominaux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'abdo_9',
      name: 'Gainage latéral (planche côté)',
      muscleGroup: 'Abdominaux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'abdo_10',
      name: 'Gainage dynamique (montées de genoux)',
      muscleGroup: 'Abdominaux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'abdo_11',
      name: 'Roue abdominale (ab wheel)',
      muscleGroup: 'Abdominaux',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'abdo_12',
      name: 'Sit-up complet',
      muscleGroup: 'Abdominaux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'abdo_13',
      name: 'Relevé de buste sur banc romain',
      muscleGroup: 'Abdominaux',
      equipment: 'machine',
    ),

    // ========== PECTORAUX ==========
    _createExercise(
      id: 'pec_1',
      name: 'Développé couché barre',
      muscleGroup: 'Pectoraux',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'pec_2',
      name: 'Développé couché haltères',
      muscleGroup: 'Pectoraux',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'pec_3',
      name: 'Développé incliné barre',
      muscleGroup: 'Pectoraux',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'pec_4',
      name: 'Développé incliné haltères',
      muscleGroup: 'Pectoraux',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'pec_5',
      name: 'Développé décliné barre',
      muscleGroup: 'Pectoraux',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'pec_6',
      name: 'Écarté couché haltères',
      muscleGroup: 'Pectoraux',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'pec_7',
      name: 'Écarté incliné haltères',
      muscleGroup: 'Pectoraux',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'pec_8',
      name: 'Écarté à la poulie vis-à-vis',
      muscleGroup: 'Pectoraux',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'pec_9',
      name: 'Pompes au sol',
      muscleGroup: 'Pectoraux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'pec_10',
      name: 'Pompes surélevées',
      muscleGroup: 'Pectoraux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'pec_11',
      name: 'Pompes sur poignées',
      muscleGroup: 'Pectoraux',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'pec_12',
      name: 'Dips entre deux barres (pectoraux)',
      muscleGroup: 'Pectoraux',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'pec_13',
      name: 'Machine presse pectorale',
      muscleGroup: 'Pectoraux',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'pec_14',
      name: 'Peck-deck (butterfly)',
      muscleGroup: 'Pectoraux',
      equipment: 'machine',
    ),

    // ========== DOS ==========
    _createExercise(
      id: 'dos_1',
      name: 'Tractions pronation',
      muscleGroup: 'Dos',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'dos_2',
      name: 'Tractions supination',
      muscleGroup: 'Dos',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'dos_3',
      name: 'Tractions prise neutre',
      muscleGroup: 'Dos',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'dos_4',
      name: 'Tirage vertical poulie devant',
      muscleGroup: 'Dos',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'dos_5',
      name: 'Tirage vertical poulie nuque',
      muscleGroup: 'Dos',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'dos_6',
      name: 'Tirage horizontal poulie (rowing assis)',
      muscleGroup: 'Dos',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'dos_7',
      name: 'Rowing barre buste penché',
      muscleGroup: 'Dos',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'dos_8',
      name: 'Rowing haltère unilatéral',
      muscleGroup: 'Dos',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'dos_9',
      name: 'Rowing T-bar',
      muscleGroup: 'Dos',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'dos_10',
      name: 'Pull-over haltère',
      muscleGroup: 'Dos',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'dos_11',
      name: 'Pull-over poulie',
      muscleGroup: 'Dos',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'dos_12',
      name: 'Soulevé de terre classique',
      muscleGroup: 'Dos',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'dos_13',
      name: 'Soulevé de terre jambes tendues (ischios / bas du dos)',
      muscleGroup: 'Dos',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'dos_14',
      name: 'Extensions lombaires banc à lombaires',
      muscleGroup: 'Dos',
      equipment: 'machine',
    ),

    // ========== ÉPAULES ==========
    _createExercise(
      id: 'epaule_1',
      name: 'Développé militaire barre',
      muscleGroup: 'Épaules',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'epaule_2',
      name: 'Développé haltères assis',
      muscleGroup: 'Épaules',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'epaule_3',
      name: 'Développé Arnold',
      muscleGroup: 'Épaules',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'epaule_4',
      name: 'Élévations latérales haltères',
      muscleGroup: 'Épaules',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'epaule_5',
      name: 'Élévations frontales haltères',
      muscleGroup: 'Épaules',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'epaule_6',
      name: 'Oiseau haltères (arrière d\'épaule)',
      muscleGroup: 'Épaules',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'epaule_7',
      name: 'Élévations latérales à la machine',
      muscleGroup: 'Épaules',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'epaule_8',
      name: 'Tirage menton barre',
      muscleGroup: 'Épaules',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'epaule_9',
      name: 'Shrugs barre',
      muscleGroup: 'Épaules',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'epaule_10',
      name: 'Shrugs haltères',
      muscleGroup: 'Épaules',
      equipment: 'haltères',
    ),

    // ========== BICEPS ==========
    _createExercise(
      id: 'biceps_1',
      name: 'Curl barre droite',
      muscleGroup: 'Biceps',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'biceps_2',
      name: 'Curl barre EZ',
      muscleGroup: 'Biceps',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'biceps_3',
      name: 'Curl haltères debout',
      muscleGroup: 'Biceps',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'biceps_4',
      name: 'Curl incliné haltères',
      muscleGroup: 'Biceps',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'biceps_5',
      name: 'Curl pupitre (Larry Scott)',
      muscleGroup: 'Biceps',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'biceps_6',
      name: 'Curl concentration',
      muscleGroup: 'Biceps',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'biceps_7',
      name: 'Curl marteau haltères',
      muscleGroup: 'Biceps',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'biceps_8',
      name: 'Curl à la poulie basse corde',
      muscleGroup: 'Biceps',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'biceps_9',
      name: 'Curl à la machine biceps',
      muscleGroup: 'Biceps',
      equipment: 'machine',
    ),

    // ========== TRICEPS ==========
    _createExercise(
      id: 'triceps_1',
      name: 'Barre au front (skull crusher)',
      muscleGroup: 'Triceps',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'triceps_2',
      name: 'Extension triceps haltères au-dessus de la tête',
      muscleGroup: 'Triceps',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'triceps_3',
      name: 'Extension triceps poulie haute corde',
      muscleGroup: 'Triceps',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'triceps_4',
      name: 'Extension triceps poulie barre',
      muscleGroup: 'Triceps',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'triceps_5',
      name: 'Dips banc (triceps)',
      muscleGroup: 'Triceps',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'triceps_6',
      name: 'Dips parallèles (triceps)',
      muscleGroup: 'Triceps',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'triceps_7',
      name: 'Kickback haltère',
      muscleGroup: 'Triceps',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'triceps_8',
      name: 'Extension triceps à la machine',
      muscleGroup: 'Triceps',
      equipment: 'machine',
    ),

    // ========== JAMBES ==========
    _createExercise(
      id: 'jambes_1',
      name: 'Squat barre arrière',
      muscleGroup: 'Jambes',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'jambes_2',
      name: 'Squat barre avant',
      muscleGroup: 'Jambes',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'jambes_3',
      name: 'Squat goblet (haltère)',
      muscleGroup: 'Jambes',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'jambes_4',
      name: 'Presse à cuisses',
      muscleGroup: 'Jambes',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'jambes_5',
      name: 'Fentes avant haltères',
      muscleGroup: 'Jambes',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'jambes_6',
      name: 'Fentes arrière (reverse lunges)',
      muscleGroup: 'Jambes',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'jambes_7',
      name: 'Fentes marchées',
      muscleGroup: 'Jambes',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'jambes_8',
      name: 'Bulgarian split squat (fente bulgare)',
      muscleGroup: 'Jambes',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'jambes_9',
      name: 'Leg extension (machine quadriceps)',
      muscleGroup: 'Jambes',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'jambes_10',
      name: 'Leg curl allongé (ischios)',
      muscleGroup: 'Jambes',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'jambes_11',
      name: 'Leg curl assis',
      muscleGroup: 'Jambes',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'jambes_12',
      name: 'Soulevé de terre jambes tendues',
      muscleGroup: 'Jambes',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'jambes_13',
      name: 'Hip thrust barre',
      muscleGroup: 'Jambes',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'jambes_14',
      name: 'Pont fessier au sol',
      muscleGroup: 'Jambes',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'jambes_15',
      name: 'Abduction machine (extérieur cuisses)',
      muscleGroup: 'Jambes',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'jambes_16',
      name: 'Adduction machine (intérieur cuisses)',
      muscleGroup: 'Jambes',
      equipment: 'machine',
    ),

    // ========== MOLETS ==========
    _createExercise(
      id: 'mollets_1',
      name: 'Mollets debout barre / machine',
      muscleGroup: 'Mollets',
      equipment: 'barre',
    ),
    _createExercise(
      id: 'mollets_2',
      name: 'Mollets assis',
      muscleGroup: 'Mollets',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'mollets_3',
      name: 'Mollets à la presse à cuisses',
      muscleGroup: 'Mollets',
      equipment: 'machine',
    ),

    // ========== CARDIO / HIIT ==========
    _createExercise(
      id: 'cardio_1',
      name: 'Tapis de course – footing',
      muscleGroup: 'Cardio',
      equipment: 'cardio',
    ),
    _createExercise(
      id: 'cardio_2',
      name: 'Tapis de course – sprints',
      muscleGroup: 'Cardio',
      equipment: 'cardio',
    ),
    _createExercise(
      id: 'cardio_3',
      name: 'Vélo stationnaire',
      muscleGroup: 'Cardio',
      equipment: 'cardio',
    ),
    _createExercise(
      id: 'cardio_4',
      name: 'Vélo elliptique',
      muscleGroup: 'Cardio',
      equipment: 'cardio',
    ),
    _createExercise(
      id: 'cardio_5',
      name: 'Rameur',
      muscleGroup: 'Cardio',
      equipment: 'cardio',
    ),
    _createExercise(
      id: 'cardio_6',
      name: 'Stepper / escalier',
      muscleGroup: 'Cardio',
      equipment: 'cardio',
    ),
    _createExercise(
      id: 'cardio_7',
      name: 'Corde à sauter',
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'cardio_8',
      name: 'Burpees',
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'cardio_9',
      name: 'Jumping jacks',
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'cardio_10',
      name: 'Mountain climbers',
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'cardio_11',
      name: 'High knees (montées de genoux)',
      muscleGroup: 'Cardio',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),

    // ========== FULL-BODY / GAINAGE ==========
    _createExercise(
      id: 'fullbody_1',
      name: 'Kettlebell swing',
      muscleGroup: 'Autres',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'fullbody_2',
      name: 'Clean & press haltère',
      muscleGroup: 'Autres',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'fullbody_3',
      name: 'Snatch haltère',
      muscleGroup: 'Autres',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'fullbody_4',
      name: 'Farmer walk (marche du fermier)',
      muscleGroup: 'Autres',
      equipment: 'haltères',
    ),
    _createExercise(
      id: 'fullbody_5',
      name: 'Battle rope',
      muscleGroup: 'Autres',
      equipment: 'machine',
    ),
    _createExercise(
      id: 'fullbody_6',
      name: 'Planche avec shoulder tap',
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'fullbody_7',
      name: 'Planche avec rotation',
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'fullbody_8',
      name: 'Gainage dynamique avec déplacement latéral',
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),

    // ========== MOBILITÉ / ÉTIREMENTS ==========
    _createExercise(
      id: 'mobilite_1',
      name: 'Étirement ischios (debout ou assis)',
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'mobilite_2',
      name: 'Étirement quadriceps debout',
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'mobilite_3',
      name: 'Étirement pectoraux contre mur',
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'mobilite_4',
      name: 'Étirement dos rond / creux (cat-cow)',
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
    _createExercise(
      id: 'mobilite_5',
      name: 'Étirement fessiers allongé (figure 4)',
      muscleGroup: 'Autres',
      equipment: 'poids du corps',
      isBodyweight: true,
    ),
  ];

  static ExerciseLibraryItem _createExercise({
    required String id,
    required String name,
    required String muscleGroup,
    required String equipment,
    bool isBodyweight = false,
  }) {
    // Déterminer la catégorie à partir du groupe musculaire
    String category;
    if (muscleGroup == 'Cardio') {
      category = 'Cardio';
    } else if (muscleGroup == 'Autres') {
      category = 'Full body';
    } else {
      category = muscleGroup;
    }

    // Déterminer les muscles travaillés
    List<String> muscles = [muscleGroup];

    // Description par défaut
    final description = 'Exercice de $muscleGroup. ${isBodyweight ? 'Exercice au poids du corps.' : 'Utilise $equipment.'}';

    // Instructions par défaut
    final steps = [
      '1. Préparez-vous à effectuer $name',
      '2. Respectez la technique correcte',
      '3. Effectuez le nombre de répétitions ou la durée prévue',
      '4. Reposez-vous entre les séries',
    ];

    return ExerciseLibraryItem(
      id: id,
      name: name,
      category: category,
      difficulty: ExerciseDifficulty.intermediate,
      description: description,
      steps: steps,
      muscles: muscles,
      muscleGroup: muscleGroup,
      equipment: equipment,
      isBodyweight: isBodyweight,
      isPremium: false,
      isOfficial: true,
      isUserCreated: false,
    );
  }
}











