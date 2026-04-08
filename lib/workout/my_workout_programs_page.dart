import 'package:flutter/material.dart';
import '../models/workout_program.dart';
import '../models/workout_session_storage.dart';
import '../services/default_program_seeder.dart';
import 'workout_program_edit_page.dart';
import 'workout_program_detail_page.dart';
import 'workout_execution_page.dart';

class MyWorkoutProgramsPage extends StatefulWidget {
  final bool embedInTab;
  const MyWorkoutProgramsPage({super.key, this.embedInTab = false});

  @override
  State<MyWorkoutProgramsPage> createState() => _MyWorkoutProgramsPageState();
}

class _MyWorkoutProgramsPageState extends State<MyWorkoutProgramsPage> {
  List<WorkoutProgram> _programs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    setState(() {
      _isLoading = true;
    });
    
    // Initialiser les programmes prédéfinis si nécessaire
    await DefaultProgramSeeder.seedIfNeeded();
    
    final programs = await WorkoutSessionStorage.getAllPrograms();
    setState(() {
      _programs = programs;
      _isLoading = false;
    });
  }

  Future<void> _deleteProgram(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Supprimer le programme', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce programme ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await WorkoutSessionStorage.deleteProgram(id);
      _loadPrograms();
    }
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

  void _showQuickStartDialog(WorkoutProgram program) {
    if (program.days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ce programme n\'a pas de jours configurés')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final maxHeight = MediaQuery.of(context).size.height * 0.6;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.play_circle_fill, color: Color(0xFFFFC300), size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Démarrer une séance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez le jour :',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: program.days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WorkoutExecutionPage(
                                program: program,
                                day: day,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getColorForType(program.colorType),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'J${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${day.exercises.length} exercices',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFFFFC300),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
      },
    );
  }

  Widget _buildBody() {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFC300)),
              )
            : _programs.isEmpty
                ? _buildEmptyState()
                : _buildProgramsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 48,
                color: Color(0xFFFFC300),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun programme',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier programme\nd\'entraînement personnalisé',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WorkoutProgramEditPage(),
                  ),
                );
                _loadPrograms();
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer un programme'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.list_alt, color: Color(0xFFFFC300), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Mes programmes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC300).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_programs.length}',
                  style: const TextStyle(
                    color: Color(0xFFFFC300),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Liste des programmes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _programs.length,
            itemBuilder: (context, index) {
              final program = _programs[index];
              return _ProgramCard(
                program: program,
                color: _getColorForType(program.colorType),
                difficulty: _getDifficultyLabel(program),
                difficultyColor: _getDifficultyColor(_getDifficultyLabel(program)),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutProgramDetailPage(program: program),
                    ),
                  );
                  _loadPrograms();
                },
                onQuickStart: () => _showQuickStartDialog(program),
                onEdit: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutProgramEditPage(program: program),
                    ),
                  );
                  _loadPrograms();
                },
                onDelete: () => _deleteProgram(program.id),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();
    final fab = FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const WorkoutProgramEditPage(),
          ),
        );
        _loadPrograms();
      },
      label: const Text(
        'Nouveau',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      icon: const Icon(Icons.add),
      backgroundColor: const Color(0xFFFFC300),
      foregroundColor: Colors.black,
    );

    if (widget.embedInTab) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: body,
        floatingActionButton: fab,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mes Programmes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: body,
      floatingActionButton: fab,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET CARTE PROGRAMME
// ─────────────────────────────────────────────────────────────────────────────

class _ProgramCard extends StatelessWidget {
  final WorkoutProgram program;
  final Color color;
  final String difficulty;
  final Color difficultyColor;
  final VoidCallback onTap;
  final VoidCallback onQuickStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProgramCard({
    required this.program,
    required this.color,
    required this.difficulty,
    required this.difficultyColor,
    required this.onTap,
    required this.onQuickStart,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalExercises = program.days.fold(0, (sum, day) => sum + day.exercises.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    // Icône
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
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
                          program.colorCode ?? program.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Titre et objectif
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (program.objective != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              program.objective!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      color: const Color(0xFF2A2A2A),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Badges info
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Difficulté avec icône de notification
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: difficultyColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            difficulty == 'Débutant'
                                ? Icons.star_outline
                                : difficulty == 'Intermédiaire'
                                    ? Icons.star_half
                                    : Icons.star,
                            color: difficultyColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            difficulty,
                            style: TextStyle(
                              color: difficultyColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.notifications_active,
                            color: difficultyColor.withOpacity(0.7),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                    // Jours
                    _InfoBadge(
                      icon: Icons.calendar_today,
                      text: '${program.days.length} jours',
                    ),
                    // Exercices
                    _InfoBadge(
                      icon: Icons.fitness_center,
                      text: '$totalExercises exos',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bouton GO
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onQuickStart,
                    icon: const Icon(Icons.play_arrow, size: 24),
                    label: const Text(
                      'COMMENCER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
