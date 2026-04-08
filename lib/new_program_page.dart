import 'package:flutter/material.dart';
import 'models/coach_programs.dart';

class NewProgramPage extends StatefulWidget {
  final String clientId;
  final String? clientName; // Optionnel pour affichage uniquement

  const NewProgramPage({
    super.key,
    required this.clientId,
    this.clientName,
  });

  @override
  State<NewProgramPage> createState() => _NewProgramPageState();
}

class _NewProgramPageState extends State<NewProgramPage> {
  final _titleController = TextEditingController();
  final _estimatedMinutesController = TextEditingController(text: '45');
  final _notesController = TextEditingController();
  
  String _goal = 'Perte de poids';
  String _level = 'Intermédiaire';
  int _sessionsPerWeek = 3;
  List<Exercise> _exercises = [];

  @override
  void dispose() {
    _titleController.dispose();
    _estimatedMinutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExerciseBottomSheet(
        onExerciseAdded: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _saveProgram() {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le titre du programme')),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins un exercice')),
      );
      return;
    }

    // Créer le programme
    final programId = 'prog_${DateTime.now().millisecondsSinceEpoch}';
    final estimatedMinutes =
        int.tryParse(_estimatedMinutesController.text) ?? 45;

    final program = CoachProgram(
      id: programId,
      title: _titleController.text.trim(),
      goal: _goal,
      level: _level,
      sessionsPerWeek: _sessionsPerWeek,
      estimatedMinutes: estimatedMinutes,
      durationWeeks: 8, // Valeur par défaut, peut être modifiée plus tard
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      exercises: _exercises.toList(), // Conversion en List pour éviter les problèmes de const
      assignedClientIds: [widget.clientId],
      coachStyleOverride: null, // Pas d'override par défaut
    );

    // Ajouter via le notifier
    CoachProgramsNotifier().addProgram(program);

    // Afficher confirmation et retourner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Programme enregistré (démo) pour ${widget.clientName ?? 'le client'}',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Nouveau programme'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info client (si disponible)
                    if (widget.clientName != null) ...[
                      Text(
                        'Client : ${widget.clientName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Section "Infos du programme"
                    const Text(
                      'Infos du programme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Titre
                    _LabeledField(
                      label: 'Titre du programme',
                      controller: _titleController,
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 16),
                    
                    // Objectif
                    _LabeledField(
                      label: 'Objectif principal',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _goal,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Perte de poids',
                                child: Text('Perte de poids'),
                              ),
                              DropdownMenuItem(
                                value: 'Prise de masse',
                                child: Text('Prise de masse'),
                              ),
                              DropdownMenuItem(
                                value: 'Remise en forme',
                                child: Text('Remise en forme'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _goal = value);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Niveau
                    _LabeledField(
                      label: 'Niveau',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _level,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Débutant',
                                child: Text('Débutant'),
                              ),
                              DropdownMenuItem(
                                value: 'Intermédiaire',
                                child: Text('Intermédiaire'),
                              ),
                              DropdownMenuItem(
                                value: 'Avancé',
                                child: Text('Avancé'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _level = value);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Séances par semaine
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Séances par semaine',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_sessionsPerWeek > 1)
                                          _sessionsPerWeek--;
                                      });
                                    },
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(
                                    '$_sessionsPerWeek',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_sessionsPerWeek < 7)
                                          _sessionsPerWeek++;
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Durée estimée (min)',
                            controller: _estimatedMinutesController,
                            icon: Icons.timer_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    _LabeledField(
                      label: 'Notes du coach',
                      controller: _notesController,
                      icon: Icons.note_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // Section "Exercices"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Exercices',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '(${_exercises.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Liste des exercices
                    if (_exercises.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'Aucun exercice ajouté. Cliquez sur "Ajouter un exercice" pour commencer.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          return _ExerciseCard(
                            exercise: exercise,
                            onDelete: () {
                              setState(() {
                                _exercises.removeAt(index);
                              });
                            },
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: _exercises.length,
                      ),
                    const SizedBox(height: 12),
                    
                    // Bouton ajouter exercice
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showAddExerciseSheet,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Ajouter un exercice'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black26),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Bouton enregistrer (fixé en bas)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProgram,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer le programme (démo)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget? child;
  final TextEditingController? controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _LabeledField({
    required this.label,
    this.child,
    this.controller,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        child ??
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                decoration: InputDecoration(
                  prefixIcon:
                      icon != null ? Icon(icon, color: Colors.grey.shade700) : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required this.exercise,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFFFFC300),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.getSummary(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(exercise.zone),
                  labelStyle: const TextStyle(fontSize: 11),
                  backgroundColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

// BottomSheet pour ajouter un exercice
class _AddExerciseBottomSheet extends StatefulWidget {
  final void Function(Exercise) onExerciseAdded;

  const _AddExerciseBottomSheet({required this.onExerciseAdded});

  @override
  State<_AddExerciseBottomSheet> createState() =>
      _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<_AddExerciseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController();
  final _durationSecondsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restSecondsController = TextEditingController(text: '90');
  final _notesController = TextEditingController();

  String _zone = 'Full body';
  bool _useDuration = false; // false = reps, true = duration

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _durationSecondsController.dispose();
    _weightController.dispose();
    _restSecondsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addExercise() {
    if (!_formKey.currentState!.validate()) return;

    final exerciseId = 'ex_${DateTime.now().microsecondsSinceEpoch}';
    final sets = int.parse(_setsController.text);
    final restSeconds = int.parse(_restSecondsController.text);

    final exercise = Exercise(
      id: exerciseId,
      name: _nameController.text.trim(),
      zone: _zone,
      sets: sets,
      reps: _useDuration
          ? null
          : (_repsController.text.isNotEmpty
              ? int.tryParse(_repsController.text)
              : null),
      durationSeconds: _useDuration
          ? (_durationSecondsController.text.isNotEmpty
              ? int.tryParse(_durationSecondsController.text)
              : null)
          : null,
      weightKg: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      restSeconds: restSeconds,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    widget.onExerciseAdded(exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Titre
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  'Ajouter un exercice',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom (obligatoire)
                      _BottomSheetField(
                        label: 'Nom de l\'exercice *',
                        controller: _nameController,
                        icon: Icons.fitness_center,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Zone
                      _BottomSheetField(
                        label: 'Zone',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _zone,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Haut du corps',
                                  child: Text('Haut du corps'),
                                ),
                                DropdownMenuItem(
                                  value: 'Bas du corps',
                                  child: Text('Bas du corps'),
                                ),
                                DropdownMenuItem(
                                  value: 'Full body',
                                  child: Text('Full body'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cardio',
                                  child: Text('Cardio'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _zone = value);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Séries
                      _BottomSheetField(
                        label: 'Nombre de séries *',
                        controller: _setsController,
                        icon: Icons.repeat,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Obligatoire';
                          }
                          final sets = int.tryParse(value);
                          if (sets == null || sets <= 0) {
                            return 'Nombre valide requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Répétitions ou Durée (toggle)
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Répétitions'),
                              selected: !_useDuration,
                              onSelected: (selected) {
                                setState(() => _useDuration = false);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Durée'),
                              selected: _useDuration,
                              onSelected: (selected) {
                                setState(() => _useDuration = true);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (!_useDuration)
                        _BottomSheetField(
                          label: 'Répétitions (optionnel)',
                          controller: _repsController,
                          icon: Icons.repeat_one,
                          keyboardType: TextInputType.number,
                        )
                      else
                        _BottomSheetField(
                          label: 'Durée en secondes (optionnel)',
                          controller: _durationSecondsController,
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      const SizedBox(height: 16),
                      
                      // Poids (optionnel)
                      _BottomSheetField(
                        label: 'Poids (kg) - optionnel',
                        controller: _weightController,
                        icon: Icons.scale_outlined,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      
                      // Repos
                      _BottomSheetField(
                        label: 'Temps de repos (secondes) *',
                        controller: _restSecondsController,
                        icon: Icons.timer_off_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Obligatoire';
                          }
                          final rest = int.tryParse(value);
                          if (rest == null || rest < 0) {
                            return 'Nombre valide requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Notes
                      _BottomSheetField(
                        label: 'Notes (optionnel)',
                        controller: _notesController,
                        icon: Icons.note_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // Boutons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black26),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _addExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Ajouter'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetField extends StatelessWidget {
  final String label;
  final Widget? child;
  final TextEditingController? controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;

  const _BottomSheetField({
    required this.label,
    this.child,
    this.controller,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        child ??
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              decoration: InputDecoration(
                prefixIcon: icon != null
                    ? Icon(icon, color: Colors.grey.shade700)
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
      ],
    );
  }
}
