import '../models/workout_program.dart';

/// Bibliothèque de programmes d'entraînement prédéfinis
/// Utilise les exercices de DefaultExercisesLibrary
class DefaultWorkoutPrograms {
  /// Construit tous les programmes prédéfinis
  static List<WorkoutProgram> buildAll() {
    return [
      buildPoidsDeCorps2Jours(),
      buildFullbody3Jours(),
      buildSplit3Jours(),
      buildSplit4Jours(),
      buildCardioSalle3Jours(),
    ];
  }

  /// Programme 1 : Poids de corps – 2 jours
  static WorkoutProgram buildPoidsDeCorps2Jours() {
    final now = DateTime.now();
    return WorkoutProgram(
      id: 'default_program_1',
      name: 'Poids de corps – 2 jours',
      objective: 'Entretien au poids du corps sur 2 séances par semaine',
      sessionsPerWeek: 2,
      colorCode: 'PC',
      colorType: ColorType.green,
      createdAt: now,
      days: [
        // Jour 1 – Haut du corps
        ProgramDay(
          id: 'day_1_1',
          name: 'Jour 1 – Haut du corps',
          dayNumber: 1,
          exercises: [
            // Tractions pronation - 4 × max reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_1',
              exerciseName: 'Tractions pronation',
              targetSets: 4,
              targetReps: null,
              isMaxReps: true,
            ),
            // Pompes classiques - 4 × max reps, repos 1'30
            ProgramExercise(
              exerciseId: 'pec_9',
              exerciseName: 'Pompes au sol',
              targetSets: 4,
              targetReps: null,
              isMaxReps: true,
            ),
            // Dips sur banc - 4 × max reps, repos 1'30
            ProgramExercise(
              exerciseId: 'triceps_6',
              exerciseName: 'Dips banc (triceps)',
              targetSets: 4,
              targetReps: null,
              isMaxReps: true,
            ),
            // Rowing inversé - 4 × max reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_6',
              exerciseName: 'Tirage horizontal poulie (rowing assis)',
              targetSets: 4,
              targetReps: null,
              isMaxReps: true,
              notes: 'Rowing inversé au poids du corps ou tirage horizontal TRX',
            ),
            // Gainage planche - 3 × 30 secondes, repos 1 min
            ProgramExercise(
              exerciseId: 'abdo_8',
              exerciseName: 'Gainage (planche ventrale)',
              targetSets: 3,
              targetReps: 30, // 30 secondes
              isMaxReps: false,
            ),
          ],
        ),
        // Jour 2 – Bas du corps & tronc
        ProgramDay(
          id: 'day_1_2',
          name: 'Jour 2 – Bas du corps / tronc',
          dayNumber: 2,
          exercises: [
            // Squats au poids du corps - 4 × 20 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'jambes_3',
              exerciseName: 'Squat goblet (haltère)',
              targetSets: 4,
              targetReps: 20,
              isMaxReps: false,
              notes: 'Squats au poids du corps (sans haltère)',
            ),
            // Fentes avant alternées - 4 × 12 reps par jambe, repos 1'30
            ProgramExercise(
              exerciseId: 'jambes_5',
              exerciseName: 'Fentes avant haltères',
              targetSets: 4,
              targetReps: 12,
              isMaxReps: false,
              notes: 'Fentes avant alternées (sans haltères)',
            ),
            // Fentes bulgares - 3 × 10 reps par jambe, repos 1'30
            ProgramExercise(
              exerciseId: 'jambes_8',
              exerciseName: 'Bulgarian split squat (fente bulgare)',
              targetSets: 3,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Hip thrust au sol (pont fessier) - 4 × 20 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'jambes_14',
              exerciseName: 'Pont fessier au sol',
              targetSets: 4,
              targetReps: 20,
              isMaxReps: false,
            ),
            // Crunch au sol - 4 × 20 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'abdo_1',
              exerciseName: 'Crunch au sol',
              targetSets: 4,
              targetReps: 20,
              isMaxReps: false,
            ),
            // Gainage latéral - 3 × 30 secondes chaque côté, repos 45s
            ProgramExercise(
              exerciseId: 'abdo_9',
              exerciseName: 'Gainage latéral (planche côté)',
              targetSets: 3,
              targetReps: 30, // 30 secondes chaque côté
              isMaxReps: false,
            ),
          ],
        ),
      ],
    );
  }

  /// Programme 2 : Fullbody – 3 jours
  static WorkoutProgram buildFullbody3Jours() {
    final now = DateTime.now();
    return WorkoutProgram(
      id: 'default_program_2',
      name: 'Fullbody – 3 jours',
      objective: 'Fullbody pour progresser sur 3 séances par semaine',
      sessionsPerWeek: 3,
      colorCode: 'FB',
      colorType: ColorType.blue,
      createdAt: now,
      days: [
        // Jour 1 – Fullbody "Force de base"
        ProgramDay(
          id: 'day_2_1',
          name: 'Jour 1 – Fullbody "Force de base"',
          dayNumber: 1,
          exercises: [
            // Squat barre - 4 × 8 reps, repos 2 min
            ProgramExercise(
              exerciseId: 'jambes_1',
              exerciseName: 'Squat barre arrière',
              targetSets: 4,
              targetReps: 8,
              isMaxReps: false,
            ),
            // Développé couché barre - 4 × 8 reps, repos 2 min
            ProgramExercise(
              exerciseId: 'pec_1',
              exerciseName: 'Développé couché barre',
              targetSets: 4,
              targetReps: 8,
              isMaxReps: false,
            ),
            // Rowing barre ou tirage horizontal - 4 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_7',
              exerciseName: 'Rowing barre buste penché',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Élévations latérales haltères - 3 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'epaule_4',
              exerciseName: 'Élévations latérales haltères',
              targetSets: 3,
              targetReps: 15,
              isMaxReps: false,
            ),
            // Crunch au sol - 4 × 20 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'abdo_1',
              exerciseName: 'Crunch au sol',
              targetSets: 4,
              targetReps: 20,
              isMaxReps: false,
            ),
          ],
        ),
        // Jour 2 – Fullbody "Tirage et ischios"
        ProgramDay(
          id: 'day_2_2',
          name: 'Jour 2 – Fullbody "Tirage et ischios"',
          dayNumber: 2,
          exercises: [
            // Soulevé de terre jambes tendues - 4 × 10 reps, repos 2 min
            ProgramExercise(
              exerciseId: 'dos_13',
              exerciseName: 'Soulevé de terre jambes tendues (ischios / bas du dos)',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Tractions pronation - 4 × max reps, repos 2 min
            ProgramExercise(
              exerciseId: 'dos_1',
              exerciseName: 'Tractions pronation',
              targetSets: 4,
              targetReps: null,
              isMaxReps: true,
            ),
            // Développé militaire - 4 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'epaule_1',
              exerciseName: 'Développé militaire barre',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Curl biceps haltères - 3 × 12 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'biceps_3',
              exerciseName: 'Curl haltères debout',
              targetSets: 3,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Gainage planche - 3 × 45 secondes, repos 1 min
            ProgramExercise(
              exerciseId: 'abdo_8',
              exerciseName: 'Gainage (planche ventrale)',
              targetSets: 3,
              targetReps: 45,
              isMaxReps: false,
            ),
          ],
        ),
        // Jour 3 – Fullbody "Volume / pump"
        ProgramDay(
          id: 'day_2_3',
          name: 'Jour 3 – Fullbody "Volume / pump"',
          dayNumber: 3,
          exercises: [
            // Presse à cuisses - 4 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'jambes_4',
              exerciseName: 'Presse à cuisses',
              targetSets: 4,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Développé incliné haltères - 4 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'pec_4',
              exerciseName: 'Développé incliné haltères',
              targetSets: 4,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Tirage horizontal poulie basse - 4 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_6',
              exerciseName: 'Tirage horizontal poulie (rowing assis)',
              targetSets: 4,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Écartés à la poulie ou aux haltères - 3 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'pec_8',
              exerciseName: 'Écarté à la poulie vis-à-vis',
              targetSets: 3,
              targetReps: 15,
              isMaxReps: false,
            ),
            // Crunch jambes levées - 4 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'abdo_5',
              exerciseName: 'Crunch jambes levées',
              targetSets: 4,
              targetReps: 15,
              isMaxReps: false,
            ),
          ],
        ),
      ],
    );
  }

  /// Programme 3 : Prise de masse – Split – 3 jours
  static WorkoutProgram buildSplit3Jours() {
    final now = DateTime.now();
    return WorkoutProgram(
      id: 'default_program_3',
      name: 'Prise de masse – Split – 3 jours',
      objective: 'Prise de volume sur 3 séances par semaine',
      sessionsPerWeek: 3,
      colorCode: 'PM',
      colorType: ColorType.orange,
      createdAt: now,
      days: [
        // Jour 1 – Pectoraux / Triceps
        ProgramDay(
          id: 'day_3_1',
          name: 'Jour 1 – Pectoraux / Triceps',
          dayNumber: 1,
          exercises: [
            // Développé couché barre - 4 × 8 reps, repos 2 min
            ProgramExercise(
              exerciseId: 'pec_1',
              exerciseName: 'Développé couché barre',
              targetSets: 4,
              targetReps: 8,
              isMaxReps: false,
            ),
            // Développé incliné haltères - 4 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'pec_4',
              exerciseName: 'Développé incliné haltères',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Écartés aux haltères ou poulie - 3 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'pec_6',
              exerciseName: 'Écarté couché haltères',
              targetSets: 3,
              targetReps: 15,
              isMaxReps: false,
            ),
            // Dips entre deux bancs (triceps) - 3 × max reps, repos 1'30
            ProgramExercise(
              exerciseId: 'pec_12',
              exerciseName: 'Dips entre deux barres (pectoraux)',
              targetSets: 3,
              targetReps: null,
              isMaxReps: true,
              notes: 'Dips entre deux bancs (triceps)',
            ),
            // Extension triceps à la poulie - 3 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'triceps_2',
              exerciseName: 'Extension triceps poulie haute corde',
              targetSets: 3,
              targetReps: 15,
              isMaxReps: false,
            ),
          ],
        ),
        // Jour 2 – Dos / Biceps
        ProgramDay(
          id: 'day_3_2',
          name: 'Jour 2 – Dos / Biceps',
          dayNumber: 2,
          exercises: [
            // Tractions pronation - 4 × max reps, repos 2 min
            ProgramExercise(
              exerciseId: 'dos_1',
              exerciseName: 'Tractions pronation',
              targetSets: 4,
              targetReps: null,
              isMaxReps: true,
            ),
            // Rowing barre ou machine - 4 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_7',
              exerciseName: 'Rowing barre buste penché',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Tirage horizontal poulie basse - 3 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_6',
              exerciseName: 'Tirage horizontal poulie (rowing assis)',
              targetSets: 3,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Curl barre - 3 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'biceps_1',
              exerciseName: 'Curl barre droite',
              targetSets: 3,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Curl incliné haltères - 3 × 12 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'biceps_4',
              exerciseName: 'Curl incliné haltères',
              targetSets: 3,
              targetReps: 12,
              isMaxReps: false,
            ),
          ],
        ),
        // Jour 3 – Jambes / Épaules / Abdos
        ProgramDay(
          id: 'day_3_3',
          name: 'Jour 3 – Jambes / Épaules / Abdos',
          dayNumber: 3,
          exercises: [
            // Squat barre - 4 × 8 reps, repos 2 min
            ProgramExercise(
              exerciseId: 'jambes_1',
              exerciseName: 'Squat barre arrière',
              targetSets: 4,
              targetReps: 8,
              isMaxReps: false,
            ),
            // Presse à cuisses - 4 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'jambes_4',
              exerciseName: 'Presse à cuisses',
              targetSets: 4,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Soulevé de terre jambes tendues - 3 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_13',
              exerciseName: 'Soulevé de terre jambes tendues (ischios / bas du dos)',
              targetSets: 3,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Développé militaire - 4 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'epaule_1',
              exerciseName: 'Développé militaire barre',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Élévations latérales - 3 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'epaule_4',
              exerciseName: 'Élévations latérales haltères',
              targetSets: 3,
              targetReps: 15,
              isMaxReps: false,
            ),
            // Crunch - 3 × 20 reps, repos 45s
            ProgramExercise(
              exerciseId: 'abdo_1',
              exerciseName: 'Crunch au sol',
              targetSets: 3,
              targetReps: 20,
              isMaxReps: false,
            ),
            // Gainage - 3 × 30 secondes, repos 45s
            ProgramExercise(
              exerciseId: 'abdo_8',
              exerciseName: 'Gainage (planche ventrale)',
              targetSets: 3,
              targetReps: 30,
              isMaxReps: false,
            ),
          ],
        ),
      ],
    );
  }

  /// Programme 4 : Prise de masse – Split – 4 jours
  static WorkoutProgram buildSplit4Jours() {
    final now = DateTime.now();
    return WorkoutProgram(
      id: 'default_program_4',
      name: 'Prise de masse – Split – 4 jours',
      objective: 'Prise de volume sur 4 séances par semaine',
      sessionsPerWeek: 4,
      colorCode: 'PM4',
      colorType: ColorType.purple,
      createdAt: now,
      days: [
        // Jour 1 – Pectoraux / Triceps
        ProgramDay(
          id: 'day_4_1',
          name: 'Jour 1 – Pectoraux / Triceps',
          dayNumber: 1,
          exercises: [
            // Développé couché barre - 4 × 8 reps, repos 2 min
            ProgramExercise(
              exerciseId: 'pec_1',
              exerciseName: 'Développé couché barre',
              targetSets: 4,
              targetReps: 8,
              isMaxReps: false,
            ),
            // Développé incliné haltères - 4 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'pec_4',
              exerciseName: 'Développé incliné haltères',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Écartés à la poulie - 3 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'pec_8',
              exerciseName: 'Écarté à la poulie vis-à-vis',
              targetSets: 3,
              targetReps: 15,
              isMaxReps: false,
            ),
            // Dips - 3 × max reps, repos 1'30
            ProgramExercise(
              exerciseId: 'triceps_5',
              exerciseName: 'Dips parallèles (triceps)',
              targetSets: 3,
              targetReps: null,
              isMaxReps: true,
            ),
            // Extension triceps poulie - 3 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'triceps_2',
              exerciseName: 'Extension triceps poulie haute corde',
              targetSets: 3,
              targetReps: 15,
              isMaxReps: false,
            ),
          ],
        ),
        // Jour 2 – Dos / Biceps
        ProgramDay(
          id: 'day_4_2',
          name: 'Jour 2 – Dos / Biceps',
          dayNumber: 2,
          exercises: [
            // Tractions pronation - 4 × max reps, repos 2 min
            ProgramExercise(
              exerciseId: 'dos_1',
              exerciseName: 'Tractions pronation',
              targetSets: 4,
              targetReps: null,
              isMaxReps: true,
            ),
            // Rowing barre - 4 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_7',
              exerciseName: 'Rowing barre buste penché',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Tirage horizontal - 3 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_6',
              exerciseName: 'Tirage horizontal poulie (rowing assis)',
              targetSets: 3,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Curl barre - 3 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'biceps_1',
              exerciseName: 'Curl barre droite',
              targetSets: 3,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Curl marteau haltères - 3 × 12 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'biceps_7',
              exerciseName: 'Curl marteau haltères',
              targetSets: 3,
              targetReps: 12,
              isMaxReps: false,
            ),
          ],
        ),
        // Jour 3 – Jambes
        ProgramDay(
          id: 'day_4_3',
          name: 'Jour 3 – Jambes',
          dayNumber: 3,
          exercises: [
            // Squat barre - 4 × 8 reps, repos 2 min
            ProgramExercise(
              exerciseId: 'jambes_1',
              exerciseName: 'Squat barre arrière',
              targetSets: 4,
              targetReps: 8,
              isMaxReps: false,
            ),
            // Presse à cuisses - 4 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'jambes_4',
              exerciseName: 'Presse à cuisses',
              targetSets: 4,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Soulevé de terre jambes tendues - 3 × 12 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'dos_13',
              exerciseName: 'Soulevé de terre jambes tendues (ischios / bas du dos)',
              targetSets: 3,
              targetReps: 12,
              isMaxReps: false,
            ),
            // Fentes bulgares - 3 × 10 reps par jambe, repos 1'30
            ProgramExercise(
              exerciseId: 'jambes_8',
              exerciseName: 'Bulgarian split squat (fente bulgare)',
              targetSets: 3,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Mollets debout - 4 × 20 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'mollets_1',
              exerciseName: 'Mollets debout barre / machine',
              targetSets: 4,
              targetReps: 20,
              isMaxReps: false,
            ),
          ],
        ),
        // Jour 4 – Épaules / Abdos
        ProgramDay(
          id: 'day_4_4',
          name: 'Jour 4 – Épaules / Abdos',
          dayNumber: 4,
          exercises: [
            // Développé militaire - 4 × 10 reps, repos 1'30
            ProgramExercise(
              exerciseId: 'epaule_1',
              exerciseName: 'Développé militaire barre',
              targetSets: 4,
              targetReps: 10,
              isMaxReps: false,
            ),
            // Élévations latérales - 4 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'epaule_4',
              exerciseName: 'Élévations latérales haltères',
              targetSets: 4,
              targetReps: 15,
              isMaxReps: false,
            ),
            // Oiseau (arrière d'épaule) - 3 × 15 reps, repos 1 min
            ProgramExercise(
              exerciseId: 'epaule_6',
              exerciseName: 'Oiseau haltères (arrière d\'épaule)',
              targetSets: 3,
              targetReps: 15,
              isMaxReps: false,
            ),
            // Crunch au sol - 4 × 20 reps, repos 45s
            ProgramExercise(
              exerciseId: 'abdo_1',
              exerciseName: 'Crunch au sol',
              targetSets: 4,
              targetReps: 20,
              isMaxReps: false,
            ),
            // Gainage planche - 3 × 45 secondes, repos 45s
            ProgramExercise(
              exerciseId: 'abdo_8',
              exerciseName: 'Gainage (planche ventrale)',
              targetSets: 3,
              targetReps: 45,
              isMaxReps: false,
            ),
            // Gainage latéral - 3 × 30 secondes par côté, repos 30-45s
            ProgramExercise(
              exerciseId: 'abdo_9',
              exerciseName: 'Gainage latéral (planche côté)',
              targetSets: 3,
              targetReps: 30,
              isMaxReps: false,
            ),
          ],
        ),
      ],
    );
  }

  /// Programme 5 : Cardio en salle – 3 jours
  static WorkoutProgram buildCardioSalle3Jours() {
    final now = DateTime.now();
    return WorkoutProgram(
      id: 'default_program_5',
      name: 'Cardio en salle – 3 jours',
      objective: 'Perte de poids et amélioration du cardio',
      sessionsPerWeek: 3,
      colorCode: 'C',
      colorType: ColorType.red,
      createdAt: now,
      days: [
        // Jour 1 – Cardio continu
        ProgramDay(
          id: 'day_5_1',
          name: 'Jour 1 – Cardio continu',
          dayNumber: 1,
          exercises: [
            // Vélo d'appartement - 1 bloc de 20 min
            ProgramExercise(
              exerciseId: 'cardio_3',
              exerciseName: 'Vélo stationnaire',
              targetSets: 1,
              targetReps: 1200, // 20 min = 1200 secondes (pour cohérence avec la structure)
              isMaxReps: false,
              notes: '20 minutes en continu',
            ),
            // Tapis de course – marche rapide - 1 bloc de 15 min
            ProgramExercise(
              exerciseId: 'cardio_1',
              exerciseName: 'Tapis de course – footing',
              targetSets: 1,
              targetReps: 900, // 15 min = 900 secondes
              isMaxReps: false,
              notes: '15 minutes marche rapide',
            ),
            // Rameur - 1 bloc de 10 min
            ProgramExercise(
              exerciseId: 'cardio_5',
              exerciseName: 'Rameur',
              targetSets: 1,
              targetReps: 600, // 10 min = 600 secondes
              isMaxReps: false,
              notes: '10 minutes en continu',
            ),
          ],
        ),
        // Jour 2 – Cardio fractionné léger
        ProgramDay(
          id: 'day_5_2',
          name: 'Jour 2 – Cardio fractionné léger',
          dayNumber: 2,
          exercises: [
            // Tapis de course – alternance course/marche - 10 × (1 min course / 1 min marche)
            ProgramExercise(
              exerciseId: 'cardio_1',
              exerciseName: 'Tapis de course – footing',
              targetSets: 10,
              targetReps: 60, // 1 min = 60 secondes
              isMaxReps: false,
              notes: '10 × (1 min course / 1 min marche)',
            ),
            // Vélo – intervalles - 8 × (30 s rapide / 1 min lent)
            ProgramExercise(
              exerciseId: 'cardio_3',
              exerciseName: 'Vélo stationnaire',
              targetSets: 8,
              targetReps: 30, // 30 secondes rapide
              isMaxReps: false,
              notes: '8 × (30 s rapide / 1 min lent)',
            ),
            // Elliptique – cool down - 1 bloc 10-15 min
            ProgramExercise(
              exerciseId: 'cardio_4',
              exerciseName: 'Vélo elliptique',
              targetSets: 1,
              targetReps: 900, // 15 min = 900 secondes
              isMaxReps: false,
              notes: '10-15 minutes cool down',
            ),
          ],
        ),
        // Jour 3 – Cardio mix + renforcement léger
        ProgramDay(
          id: 'day_5_3',
          name: 'Jour 3 – Cardio mix + renforcement léger',
          dayNumber: 3,
          exercises: [
            // Rameur - 5 × 2 min modéré, repos 1 min
            ProgramExercise(
              exerciseId: 'cardio_5',
              exerciseName: 'Rameur',
              targetSets: 5,
              targetReps: 120, // 2 min = 120 secondes
              isMaxReps: false,
              notes: '5 × 2 min modéré, repos 1 min',
            ),
            // Vélo - 15 min continu
            ProgramExercise(
              exerciseId: 'cardio_3',
              exerciseName: 'Vélo stationnaire',
              targetSets: 1,
              targetReps: 900, // 15 min = 900 secondes
              isMaxReps: false,
              notes: '15 minutes en continu',
            ),
            // Montée de genoux / stepper - 4 × 1 min, repos 1 min
            ProgramExercise(
              exerciseId: 'cardio_11',
              exerciseName: 'High knees (montées de genoux)',
              targetSets: 4,
              targetReps: 60, // 1 min = 60 secondes
              isMaxReps: false,
              notes: '4 × 1 min, repos 1 min',
            ),
            // Gainage planche - 3 × 30-45 secondes, repos 45s
            ProgramExercise(
              exerciseId: 'abdo_8',
              exerciseName: 'Gainage (planche ventrale)',
              targetSets: 3,
              targetReps: 45, // 45 secondes
              isMaxReps: false,
            ),
          ],
        ),
      ],
    );
  }
}











