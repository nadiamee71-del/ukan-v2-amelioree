import 'package:flutter/material.dart';
import '../../models/coach_programs.dart';
import '../../coach_personality/coach_personality_model.dart';

/// Page de création/édition d'un programme coach
class CoachProgramCreatePage extends StatefulWidget {
  final CoachProgram? programToEdit; // Si non null, mode édition
  final String? preselectedClientId; // Client présélectionné (si appelé depuis la fiche client)

  const CoachProgramCreatePage({
    super.key,
    this.programToEdit,
    this.preselectedClientId,
  });

  @override
  State<CoachProgramCreatePage> createState() => _CoachProgramCreatePageState();
}

class _CoachProgramCreatePageState extends State<CoachProgramCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGoal = 'Perte de poids';
  String _selectedLevel = 'Intermédiaire';
  int _sessionsPerWeek = 3;
  int _estimatedMinutes = 45;
  int _durationWeeks = 8;
  CoachStyle? _coachStyleOverride;

  final List<String> _goals = ['Perte de poids', 'Prise de masse', 'Remise en forme'];
  final List<String> _levels = ['Débutant', 'Intermédiaire', 'Avancé'];

  @override
  void initState() {
    super.initState();
    if (widget.programToEdit != null) {
      final program = widget.programToEdit!;
      _titleController.text = program.title;
      _notesController.text = program.notes ?? '';
      _selectedGoal = program.goal;
      _selectedLevel = program.level;
      _sessionsPerWeek = program.sessionsPerWeek;
      _estimatedMinutes = program.estimatedMinutes;
      _durationWeeks = program.durationWeeks;
      _coachStyleOverride = program.coachStyleOverride;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveProgram() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = CoachProgramsNotifier();

    if (widget.programToEdit != null) {
      // Mode édition
      final updated = CoachProgram(
        id: widget.programToEdit!.id,
        title: _titleController.text.trim(),
        goal: _selectedGoal,
        level: _selectedLevel,
        sessionsPerWeek: _sessionsPerWeek,
        estimatedMinutes: _estimatedMinutes,
        durationWeeks: _durationWeeks,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        exercises: widget.programToEdit!.exercises, // Garde les exercices existants
        assignedClientIds: widget.programToEdit!.assignedClientIds,
        coachStyleOverride: _coachStyleOverride,
      );
      notifier.updateProgram(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Programme mis à jour !')),
      );
    } else {
      // Mode création
      final newProgram = CoachProgram(
        id: 'program_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        goal: _selectedGoal,
        level: _selectedLevel,
        sessionsPerWeek: _sessionsPerWeek,
        estimatedMinutes: _estimatedMinutes,
        durationWeeks: _durationWeeks,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        exercises: const [], // Liste vide pour l'instant, sera remplie plus tard
        assignedClientIds: widget.preselectedClientId != null ? [widget.preselectedClientId!] : [],
        coachStyleOverride: _coachStyleOverride,
      );
      notifier.addProgram(newProgram);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Programme créé !')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: Text(widget.programToEdit != null ? 'Modifier le programme' : 'Nouveau programme'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre du programme *',
                    hintText: 'Ex: Perte de poids – Phase 1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Objectif
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Objectif *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _goals.map((goal) {
                          final isSelected = _selectedGoal == goal;
                          return ChoiceChip(
                            label: Text(goal),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedGoal = goal);
                            },
                            selectedColor: const Color(0xFFFFC300),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black87 : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Niveau
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Niveau *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _levels.map((level) {
                          final isSelected = _selectedLevel == level;
                          return ChoiceChip(
                            label: Text(level),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedLevel = level);
                            },
                            selectedColor: const Color(0xFFFFC300),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black87 : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Durée et séances
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Semaines *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _durationWeeks,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: List.generate(20, (i) => i + 1).map((weeks) {
                                return DropdownMenuItem(
                                  value: weeks,
                                  child: Text('$weeks semaine${weeks > 1 ? 's' : ''}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) setState(() => _durationWeeks = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Séances / semaine *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _sessionsPerWeek,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: List.generate(7, (i) => i + 1).map((sessions) {
                                return DropdownMenuItem(
                                  value: sessions,
                                  child: Text('$sessions séance${sessions > 1 ? 's' : ''}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) setState(() => _sessionsPerWeek = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Durée estimée par séance
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Durée estimée par séance (minutes) *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _estimatedMinutes,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [15, 20, 30, 45, 60, 75, 90].map((minutes) {
                          return DropdownMenuItem(
                            value: minutes,
                            child: Text('$minutes min'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _estimatedMinutes = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Style de coach override
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Style de coach vocal (optionnel)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Si défini, ce style remplacera celui du client pour ce programme',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          // Option "Utiliser le style du client"
                          ChoiceChip(
                            label: const Text('Style du client'),
                            selected: _coachStyleOverride == null,
                            onSelected: (selected) {
                              if (selected) setState(() => _coachStyleOverride = null);
                            },
                            selectedColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: _coachStyleOverride == null ? Colors.black87 : Colors.grey.shade700,
                              fontWeight: _coachStyleOverride == null ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          // Options de style
                          ...CoachPersonalityFactory.getAllCoaches().map((coach) {
                            final isSelected = _coachStyleOverride == coach.style;
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(coach.icon, size: 16, color: isSelected ? Colors.black87 : coach.color),
                                  const SizedBox(width: 6),
                                  Text(coach.name),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) setState(() => _coachStyleOverride = coach.style);
                              },
                              selectedColor: coach.color.withOpacity(0.3),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black87 : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Notes (optionnel)',
                    hintText: 'Notes générales sur le programme...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                // Bouton sauvegarder
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProgram,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      widget.programToEdit != null ? 'Enregistrer les modifications' : 'Créer le programme',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (widget.programToEdit != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Ouvrir la page d'ajout d'exercices
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ajout d\'exercices à venir')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black26),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Gérer les exercices',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}







