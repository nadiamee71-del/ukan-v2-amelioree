import 'package:flutter/material.dart';
import '../../models/coach_programs.dart';
import '../../models/coach_directory.dart' as directory_models;
import '../../coach_personality/coach_personality_model.dart';
import 'coach_program_create_page.dart';
import '../../coach_program_detail_page.dart';

/// Page principale de la bibliothèque de programmes coach
class CoachProgramsPage extends StatefulWidget {
  const CoachProgramsPage({super.key});

  @override
  State<CoachProgramsPage> createState() => _CoachProgramsPageState();
}

class _CoachProgramsPageState extends State<CoachProgramsPage> {
  late final CoachProgramsNotifier _notifier;
  String _searchQuery = '';
  String? _selectedGoal;
  String? _selectedLevel;

  final List<String> _goals = ['Tous', 'Perte de poids', 'Prise de masse', 'Remise en forme'];
  final List<String> _levels = ['Tous', 'Débutant', 'Intermédiaire', 'Avancé'];

  @override
  void initState() {
    super.initState();
    _notifier = CoachProgramsNotifier();
    _notifier.addListener(_onProgramsChanged);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onProgramsChanged);
    super.dispose();
  }

  void _onProgramsChanged() {
    setState(() {});
  }

  List<CoachProgram> get _filteredPrograms {
    var programs = _notifier.programs;

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      programs = programs.where((p) {
        return p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.goal.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtre par objectif
    if (_selectedGoal != null && _selectedGoal != 'Tous') {
      programs = programs.where((p) => p.goal == _selectedGoal).toList();
    }

    // Filtre par niveau
    if (_selectedLevel != null && _selectedLevel != 'Tous') {
      programs = programs.where((p) => p.level == _selectedLevel).toList();
    }

    return programs;
  }

  void _showDeleteConfirm(CoachProgram program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le programme ?'),
        content: Text(
          'Tu veux vraiment supprimer "${program.title}" ?\n\n'
          '${program.activeClientsCount} client(s) actif(s) seront affecté(s).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _notifier.removeProgram(program.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Programme "${program.title}" supprimé')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _duplicateProgram(CoachProgram program) {
    final duplicated = CoachProgram(
      id: '${program.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
      title: '${program.title} (Copie)',
      goal: program.goal,
      level: program.level,
      sessionsPerWeek: program.sessionsPerWeek,
      estimatedMinutes: program.estimatedMinutes,
      durationWeeks: program.durationWeeks,
      notes: program.notes,
      exercises: program.exercises,
      assignedClientIds: [], // Copie sans clients assignés
      coachStyleOverride: program.coachStyleOverride,
    );
    _notifier.addProgram(duplicated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Programme dupliqué !')),
    );
  }

  void _assignToClient(CoachProgram program) {
    // TODO: Ouvrir une page de sélection de client
    // Pour l'instant, on affiche juste un message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigner à un client'),
        content: Text(
          'Fonctionnalité à venir : sélectionner un client pour "${program.title}".\n\n'
          'Clients actuellement assignés : ${program.activeClientsCount}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrograms = _filteredPrograms;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Mes programmes coach'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Barre de recherche et filtres
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Recherche
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un programme…',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filtres
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGoal ?? 'Tous',
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                              items: _goals.map((goal) {
                                return DropdownMenuItem(
                                  value: goal,
                                  child: Text(goal, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedGoal = value == 'Tous' ? null : value);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLevel ?? 'Tous',
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                              items: _levels.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(level, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedLevel = value == 'Tous' ? null : value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Liste des programmes
            Expanded(
              child: filteredPrograms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || _selectedGoal != null || _selectedLevel != null
                                ? 'Aucun programme trouvé'
                                : 'Aucun programme créé',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crée ton premier programme',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPrograms.length,
                      itemBuilder: (context, index) {
                        final program = filteredPrograms[index];
                        return _ProgramCard(
                          program: program,
                          onTap: () {
                            // Convertir le programme de coach_programs.dart vers coach_directory.dart
                            final directoryProgram = directory_models.CoachProgram(
                              id: program.id,
                              title: program.title,
                              description: program.notes ?? program.goal,
                              price: 0.0, // Programmes du coach pour ses clients sont gratuits
                              durationWeeks: program.durationWeeks,
                              level: program.level,
                              coachId: 'coach_current', // ID du coach actuel
                            );
                            
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CoachProgramDetailPage(
                                  program: directoryProgram,
                                  coachId: 'coach_current',
                                  coachName: 'Votre Coach',
                                ),
                              ),
                            );
                          },
                          onAssign: () => _assignToClient(program),
                          onEdit: () {
                            // TODO: Ouvrir page d'édition
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Édition à venir')),
                            );
                          },
                          onDuplicate: () => _duplicateProgram(program),
                          onDelete: () => _showDeleteConfirm(program),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CoachProgramCreatePage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouveau programme'),
      ),
    );
  }
}

/// Carte d'un programme dans la liste
class _ProgramCard extends StatelessWidget {
  final CoachProgram program;
  final VoidCallback onTap;
  final VoidCallback onAssign;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _ProgramCard({
    required this.program,
    required this.onTap,
    required this.onAssign,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icône
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC300).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFFFFC300),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Titre et infos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${program.durationWeeks} semaines • ${program.sessionsPerWeek} séances / semaine',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge niveau
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getLevelColor(program.level).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        program.level,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getLevelColor(program.level),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Objectif et clients actifs
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        program.goal,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people_outline, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Clients actifs : ${program.activeClientsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    // Style de coach override (si présent)
                    if (program.coachStyleOverride != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: program.coachStyleOverride!.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              program.coachStyleOverride!.icon,
                              size: 14,
                              color: program.coachStyleOverride!.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              program.coachStyleOverride!.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                color: program.coachStyleOverride!.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Actions
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.person_add_rounded,
                      label: 'Assigner',
                      onPressed: onAssign,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.edit_rounded,
                      label: 'Modifier',
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Dupliquer',
                      onPressed: onDuplicate,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: Colors.red.shade400,
                      onPressed: onDelete,
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}



