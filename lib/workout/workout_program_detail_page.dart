import 'package:flutter/material.dart';
import '../models/workout_program.dart';
import '../models/workout_session_storage.dart';
import 'workout_program_edit_page.dart';
import 'workout_session_recording_page.dart';
import 'workout_execution_page.dart';
import '../models/workout_session.dart';
import '../models/exercise_library_item.dart';
import 'package:intl/intl.dart';

class WorkoutProgramDetailPage extends StatefulWidget {
  final WorkoutProgram program;

  const WorkoutProgramDetailPage({super.key, required this.program});

  @override
  State<WorkoutProgramDetailPage> createState() => _WorkoutProgramDetailPageState();
}

class _WorkoutProgramDetailPageState extends State<WorkoutProgramDetailPage> {
  WorkoutProgram? _program;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    final program = await WorkoutSessionStorage.getProgramById(widget.program.id);
    setState(() {
      _program = program ?? widget.program;
    });
  }

  Color _getColorForType(ColorType type) {
    switch (type) {
      case ColorType.blue:
        return Colors.blue;
      case ColorType.red:
        return Colors.red;
      case ColorType.green:
        return Colors.green;
      case ColorType.orange:
        return Colors.orange;
      case ColorType.brown:
        return Colors.brown;
      case ColorType.purple:
        return Colors.purple;
      case ColorType.yellow:
        return const Color(0xFFFFC300);
    }
  }

  String _getDifficultyLabel(WorkoutProgram program) {
    // Déterminer la difficulté basée sur le nombre d'exercices et de séances
    final totalExercises = program.days.fold(0, (sum, day) => sum + day.exercises.length);
    final avgExercisesPerDay = totalExercises / (program.days.isEmpty ? 1 : program.days.length);
    
    if (avgExercisesPerDay <= 4 && program.sessionsPerWeek <= 2) {
      return 'Débutant';
    } else if (avgExercisesPerDay <= 6 && program.sessionsPerWeek <= 4) {
      return 'Intermédiaire';
    } else {
      return 'Avancé';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Débutant':
        return Colors.green;
      case 'Intermédiaire':
        return Colors.orange;
      case 'Avancé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Débutant':
        return Icons.star_outline;
      case 'Intermédiaire':
        return Icons.star_half;
      case 'Avancé':
        return Icons.star;
      default:
        return Icons.star_outline;
    }
  }

  Future<void> _startSessionFromDay(ProgramDay day) async {
    // Ouvrir la nouvelle page d'exécution
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutExecutionPage(
          program: _program ?? widget.program,
          day: day,
        ),
      ),
    );
    _loadProgram();
  }

  Future<void> _startRecordingFromDay(ProgramDay day) async {
    // Convertir les exercices du programme en exercices pour la séance
    final exercises = day.exercises.map((programExercise) {
      return ExercisePerformance(
        exerciseId: programExercise.exerciseId,
        exerciseName: programExercise.exerciseName,
        sets: [],
        notes: programExercise.notes,
      );
    }).toList();

    // Créer une séance temporaire pour l'enregistrement
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: day.name,
      startTime: DateTime.now(),
      exercises: exercises,
      programId: _program!.id,
    );

    // Naviguer vers la page d'enregistrement
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutSessionRecordingPage(initialSession: session),
      ),
    );
    _loadProgram();
  }

  @override
  Widget build(BuildContext context) {
    final program = _program ?? widget.program;
    final color = _getColorForType(program.colorType);
    final difficulty = _getDifficultyLabel(program);
    final difficultyColor = _getDifficultyColor(difficulty);
    final totalExercises = program.days.fold(0, (sum, day) => sum + day.exercises.length);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        title: Text(program.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WorkoutProgramEditPage(program: program),
                ),
              );
              _loadProgram();
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────────────────────────────────────────────
              // EN-TÊTE DU PROGRAMME
              // ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    // Icône et nom
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              program.colorCode ?? program.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              if (program.objective != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  program.objective!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Badge de difficulté avec notification
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: difficultyColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDifficultyIcon(difficulty),
                            color: difficultyColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            difficulty,
                            style: TextStyle(
                              color: difficultyColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildDifficultyStars(difficulty),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Indication notification de difficulté
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: const Color(0xFFFFC300),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Évaluation de difficulté après chaque exercice',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistiques
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatBadge(
                          icon: Icons.calendar_today,
                          value: '${program.sessionsPerWeek}',
                          label: 'séances/sem',
                        ),
                        _StatBadge(
                          icon: Icons.today,
                          value: '${program.days.length}',
                          label: 'jours',
                        ),
                        _StatBadge(
                          icon: Icons.fitness_center,
                          value: '$totalExercises',
                          label: 'exercices',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ────────────────────────────────────────────
              // TITRE SECTION JOURS
              // ────────────────────────────────────────────
              const Row(
                children: [
                  Icon(Icons.list_alt, color: Color(0xFFFFC300), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Jours d\'entraînement',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ────────────────────────────────────────────
              // LISTE DES JOURS
              // ────────────────────────────────────────────
              ...program.days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
                return _DayDetailCard(
                  index: index + 1,
                  day: day,
                  color: color,
                  onStartGuided: () => _startSessionFromDay(day),
                  onStartFree: () => _startRecordingFromDay(day),
                );
              }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyStars(String difficulty) {
    int stars = difficulty == 'Débutant' ? 1 : difficulty == 'Intermédiaire' ? 2 : 3;
    return Row(
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: _getDifficultyColor(difficulty),
          size: 18,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS AUXILIAIRES
// ─────────────────────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDetailCard extends StatelessWidget {
  final int index;
  final ProgramDay day;
  final Color color;
  final VoidCallback onStartGuided;
  final VoidCallback onStartFree;

  const _DayDetailCard({
    required this.index,
    required this.day,
    required this.color,
    required this.onStartGuided,
    required this.onStartFree,
  });

  @override
  Widget build(BuildContext context) {
    final totalSets = day.exercises.fold(0, (sum, e) => sum + (e.targetSets ?? 1));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du jour
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Numéro du jour
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'J$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.exercises.length} exercices • $totalSets séries',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des exercices
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                if (day.exercises.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Aucun exercice configuré',
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  )
                else
                  ...day.exercises.asMap().entries.map((entry) {
                    final exIndex = entry.key;
                    final exercise = entry.value;
                    return _ExerciseRow(
                      index: exIndex + 1,
                      exercise: exercise,
                    );
                  }),
              ],
            ),
          ),

          // Boutons d'action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Bouton principal GO
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onStartGuided,
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      'COMMENCER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Bouton secondaire (mode libre)
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onStartFree,
                    icon: const Icon(Icons.edit_note, size: 20),
                    label: const Text('Mode enregistrement libre'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final int index;
  final ProgramExercise exercise;

  const _ExerciseRow({
    required this.index,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Numéro
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Color(0xFFFFC300),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Infos exercice
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (exercise.targetDescription.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    exercise.targetDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Icône séries
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${exercise.targetSets ?? 1}×',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
