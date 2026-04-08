import 'package:flutter/material.dart';
import '../models/workout_program.dart';
import '../models/workout_session_storage.dart';
import '../exercises/exercise_library_page.dart';
import '../models/exercise_library_item.dart';

class WorkoutProgramEditPage extends StatefulWidget {
  final WorkoutProgram? program;

  const WorkoutProgramEditPage({super.key, this.program});

  @override
  State<WorkoutProgramEditPage> createState() => _WorkoutProgramEditPageState();
}

class _WorkoutProgramEditPageState extends State<WorkoutProgramEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _objectiveController;
  late TextEditingController _sessionsPerWeekController;
  late List<ProgramDay> _days;
  ColorType _selectedColorType = ColorType.blue;
  String? _colorCode;

  @override
  void initState() {
    super.initState();
    if (widget.program != null) {
      _nameController = TextEditingController(text: widget.program!.name);
      _objectiveController = TextEditingController(text: widget.program!.objective ?? '');
      _sessionsPerWeekController = TextEditingController(text: widget.program!.sessionsPerWeek.toString());
      _days = List.from(widget.program!.days);
      _selectedColorType = widget.program!.colorType;
      _colorCode = widget.program!.colorCode;
    } else {
      _nameController = TextEditingController();
      _objectiveController = TextEditingController();
      _sessionsPerWeekController = TextEditingController(text: '3');
      _days = [];
      _colorCode = 'P';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _objectiveController.dispose();
    _sessionsPerWeekController.dispose();
    super.dispose();
  }

  Future<void> _addDay() async {
    final dayNumber = _days.length + 1;
    final nameController = TextEditingController(text: 'Jour $dayNumber');
    String selectedType = 'Push';
    
    final dayTypes = [
      {'name': 'Push', 'icon': Icons.arrow_upward, 'color': Colors.blue},
      {'name': 'Pull', 'icon': Icons.arrow_downward, 'color': Colors.green},
      {'name': 'Legs', 'icon': Icons.directions_run, 'color': Colors.orange},
      {'name': 'Upper', 'icon': Icons.fitness_center, 'color': Colors.purple},
      {'name': 'Lower', 'icon': Icons.downhill_skiing, 'color': Colors.red},
      {'name': 'Full Body', 'icon': Icons.accessibility_new, 'color': Colors.teal},
      {'name': 'Cardio', 'icon': Icons.favorite, 'color': Colors.pink},
      {'name': 'Repos', 'icon': Icons.hotel, 'color': Colors.grey},
    ];
    
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // En-tête
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC300).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFFFC300),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ajouter un jour',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Jour $dayNumber du programme',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.1), height: 1),
              // Contenu scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du jour
                      const Text(
                        'Nom du jour',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ex: Pectoraux / Triceps',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          prefixIcon: Icon(Icons.edit, color: Colors.white.withOpacity(0.5), size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Type de jour
                      const Text(
                        'Type de jour',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dayTypes.map((type) {
                          final isSelected = selectedType == type['name'];
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                selectedType = type['name'] as String;
                                if (nameController.text.startsWith('Jour ')) {
                                  nameController.text = 'Jour $dayNumber - ${type['name']}';
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? (type['color'] as Color).withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected 
                                      ? type['color'] as Color
                                      : Colors.white.withOpacity(0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    type['icon'] as IconData,
                                    color: isSelected 
                                        ? type['color'] as Color
                                        : Colors.white.withOpacity(0.6),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    type['name'] as String,
                                    style: TextStyle(
                                      color: isSelected 
                                          ? type['color'] as Color
                                          : Colors.white.withOpacity(0.8),
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      // Aperçu
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _getColorForType(_selectedColorType),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '$dayNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                                    nameController.text.isEmpty ? 'Jour $dayNumber' : nameController.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '0 exercice • Prêt à configurer',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: const Color(0xFFFFC300),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Boutons
              Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop({
                          'name': nameController.text.isEmpty ? 'Jour $dayNumber' : nameController.text,
                          'type': selectedType,
                        }),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Créer le jour'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC300),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

    if (result != null) {
      setState(() {
        _days.add(ProgramDay(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result['name'] as String,
          dayNumber: dayNumber,
          exercises: [],
        ));
      });
    }
  }

  Future<void> _editDay(ProgramDay day) async {
    final index = _days.indexOf(day);
    final nameController = TextEditingController(text: day.name);
    
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // En-tête
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getColorForType(_selectedColorType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${day.dayNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                        const Text(
                          'Modifier le jour',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${day.exercises.length} exercice${day.exercises.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nom du jour',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ex: Pectoraux / Triceps',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      prefixIcon: Icon(Icons.edit, color: Colors.white.withOpacity(0.5), size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            // Boutons
            Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  // Bouton Supprimer
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop({'delete': true}),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Suppr.'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop({
                        'name': nameController.text,
                      }),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Enregistrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC300),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      if (result['delete'] == true) {
        setState(() {
          _days.removeAt(index);
          // Réorganiser les numéros de jours
          for (int i = 0; i < _days.length; i++) {
            _days[i] = _days[i].copyWith(dayNumber: i + 1);
          }
        });
      } else {
        setState(() {
          _days[index] = day.copyWith(name: result['name'] as String);
        });
      }
    }
  }

  Future<void> _addExerciseToDay(ProgramDay day) async {
    final selectedExercise = await Navigator.of(context).push<ExerciseLibraryItem>(
      MaterialPageRoute(
        builder: (_) => const ExerciseLibraryPage(selectionMode: true),
      ),
    );

    if (selectedExercise != null) {
      final index = _days.indexOf(day);
      final exercises = List<ProgramExercise>.from(day.exercises);
      
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) {
          final setsController = TextEditingController();
          final repsController = TextEditingController();
          bool isMaxReps = false;
          
          return StatefulBuilder(
            builder: (context, setState) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // En-tête
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Objectif de l\'exercice',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    // Contenu
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre de séries
                          TextField(
                            controller: setsController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Nombre de séries',
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              hintText: '4',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF007AFF),
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          // Max reps checkbox
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isMaxReps,
                                  onChanged: (value) {
                                    setState(() {
                                      isMaxReps = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF007AFF),
                                  checkColor: Colors.white,
                                ),
                                const Expanded(
                                  child: Text(
                                    'Max reps',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isMaxReps) ...[
                            const SizedBox(height: 20),
                            TextField(
                              controller: repsController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Nombre de répétitions',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                hintText: '20',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF007AFF),
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Actions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop({
                                'sets': int.tryParse(setsController.text),
                                'reps': isMaxReps ? null : int.tryParse(repsController.text),
                                'isMaxReps': isMaxReps,
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007AFF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
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
        },
      );

      if (result != null) {
        exercises.add(ProgramExercise(
          exerciseId: selectedExercise.id,
          exerciseName: selectedExercise.name,
          targetSets: result['sets'] as int?,
          targetReps: result['reps'] as int?,
          isMaxReps: result['isMaxReps'] as bool? ?? false,
        ));

        setState(() {
          _days[index] = day.copyWith(exercises: exercises);
        });
      }
    }
  }

  Future<void> _saveProgram() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom du programme est requis')),
      );
      return;
    }

    final sessionsPerWeek = int.tryParse(_sessionsPerWeekController.text) ?? 3;

    final program = WorkoutProgram(
      id: widget.program?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      objective: _objectiveController.text.isEmpty ? null : _objectiveController.text,
      sessionsPerWeek: sessionsPerWeek,
      days: _days,
      colorCode: _colorCode,
      colorType: _selectedColorType,
      createdAt: widget.program?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await WorkoutSessionStorage.saveProgram(program);
    if (mounted) {
      Navigator.of(context).pop();
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
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.program != null;
    final totalExercises = _days.fold<int>(0, (sum, day) => sum + day.exercises.length);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Modifier le programme' : 'Nouveau programme',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _saveProgram,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Enregistrer'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFC300),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Barre de progression
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF111111),
              child: Row(
                children: [
                  _ProgressIndicator(
                    label: 'Infos',
                    isComplete: _nameController.text.isNotEmpty,
                    step: 1,
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                  _ProgressIndicator(
                    label: 'Jours',
                    isComplete: _days.isNotEmpty,
                    step: 2,
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                  _ProgressIndicator(
                    label: 'Exercices',
                    isComplete: totalExercises > 0,
                    step: 3,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Informations
                    _SectionCard(
                      title: 'Informations',
                      icon: Icons.info_outline,
                      child: Column(
                        children: [
                          _ModernTextField(
                            controller: _nameController,
                            label: 'Nom du programme',
                            hint: 'Ex: Push Pull Legs - 6 jours',
                            icon: Icons.fitness_center,
                          ),
                          const SizedBox(height: 12),
                          _ModernTextField(
                            controller: _objectiveController,
                            label: 'Objectif (optionnel)',
                            hint: 'Ex: Prise de masse sur 8 semaines',
                            icon: Icons.flag_outlined,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ModernTextField(
                                  controller: _sessionsPerWeekController,
                                  label: 'Séances/semaine',
                                  hint: '3',
                                  icon: Icons.calendar_today,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Couleur
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Couleur',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: ColorType.values.take(4).map((type) {
                                        final color = _getColorForType(type);
                                        final isSelected = _selectedColorType == type;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedColorType = type;
                                              _colorCode = type.toString().split('.').last[0].toUpperCase();
                                            });
                                          },
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            margin: const EdgeInsets.symmetric(horizontal: 3),
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected ? Colors.white : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check, color: Colors.white, size: 14)
                                                : null,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Section Jours
                    _SectionCard(
                      title: 'Jours d\'entraînement',
                      icon: Icons.calendar_month,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_days.length} jour${_days.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_days.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.white.withOpacity(0.3),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Aucun jour ajouté',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Commence par créer tes jours d\'entraînement',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._days.map((day) => _ImprovedDayCard(
                              day: day,
                              color: _getColorForType(_selectedColorType),
                              onEdit: () => _editDay(day),
                              onAddExercise: () => _addExerciseToDay(day),
                              onDeleteExercise: (exercise) {
                                final index = _days.indexOf(day);
                                final exercises = List<ProgramExercise>.from(day.exercises);
                                exercises.remove(exercise);
                                setState(() {
                                  _days[index] = day.copyWith(exercises: exercises);
                                });
                              },
                            )),
                          const SizedBox(height: 12),
                          // Bouton ajouter jour
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _addDay,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Ajouter un jour'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFFC300),
                                side: const BorderSide(color: Color(0xFFFFC300)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Espace pour le bouton flottant
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveProgram,
        backgroundColor: const Color(0xFFFFC300),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.rocket_launch),
        label: Text(
          isEditing ? 'Enregistrer' : 'Créer le programme',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ============ NOUVEAUX WIDGETS ============

class _ProgressIndicator extends StatelessWidget {
  final String label;
  final bool isComplete;
  final int step;

  const _ProgressIndicator({
    required this.label,
    required this.isComplete,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isComplete ? const Color(0xFFFFC300) : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isComplete ? const Color(0xFFFFC300) : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check, color: Colors.black, size: 16)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isComplete ? const Color(0xFFFFC300) : Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFFC300), size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4), size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFFC300)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _ImprovedDayCard extends StatelessWidget {
  final ProgramDay day;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onAddExercise;
  final Function(ProgramExercise) onDeleteExercise;

  const _ImprovedDayCard({
    required this.day,
    required this.color,
    required this.onEdit,
    required this.onAddExercise,
    required this.onDeleteExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // En-tête du jour
          InkWell(
            onTap: onEdit,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${day.dayNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.exercises.length} exercice${day.exercises.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    color: Colors.white.withOpacity(0.4),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          
          // Liste des exercices
          if (day.exercises.isNotEmpty) ...[
            Divider(color: Colors.white.withOpacity(0.08), height: 1),
            ...day.exercises.map((exercise) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          exercise.targetDescription,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red.withOpacity(0.7),
                      size: 18,
                    ),
                    onPressed: () => onDeleteExercise(exercise),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            )),
          ],
          
          // Bouton ajouter exercice
          InkWell(
            onTap: onAddExercise,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Ajouter un exercice',
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Old _DayCard kept for compatibility
class _DayCard extends StatelessWidget {
  final ProgramDay day;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onAddExercise;
  final Function(ProgramExercise) onDeleteExercise;

  const _DayCard({
    required this.day,
    required this.color,
    required this.onEdit,
    required this.onAddExercise,
    required this.onDeleteExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.dayNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    day.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (day.exercises.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Aucun exercice',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              )
            else
              ...day.exercises.map((exercise) => ListTile(
                    dense: true,
                    title: Text(exercise.exerciseName),
                    subtitle: Text(exercise.targetDescription),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => onDeleteExercise(exercise),
                    ),
                  )),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onAddExercise,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter un exercice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

