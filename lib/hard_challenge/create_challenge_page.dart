import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Palette
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

/// Types d'exercices disponibles
enum ExerciseType {
  pushups,
  squats,
  plank,
  burpees,
  running,
  walking,
  jumpRope,
  abs,
  pullups,
  custom,
}

extension ExerciseTypeExtension on ExerciseType {
  String get label {
    switch (this) {
      case ExerciseType.pushups: return 'Pompes';
      case ExerciseType.squats: return 'Squats';
      case ExerciseType.plank: return 'Planche';
      case ExerciseType.burpees: return 'Burpees';
      case ExerciseType.running: return 'Course';
      case ExerciseType.walking: return 'Marche';
      case ExerciseType.jumpRope: return 'Corde à sauter';
      case ExerciseType.abs: return 'Abdos';
      case ExerciseType.pullups: return 'Tractions';
      case ExerciseType.custom: return 'Personnalisé';
    }
  }

  IconData get icon {
    switch (this) {
      case ExerciseType.pushups: return Icons.fitness_center;
      case ExerciseType.squats: return Icons.accessibility_new;
      case ExerciseType.plank: return Icons.timer;
      case ExerciseType.burpees: return Icons.sports_gymnastics;
      case ExerciseType.running: return Icons.directions_run;
      case ExerciseType.walking: return Icons.directions_walk;
      case ExerciseType.jumpRope: return Icons.sports;
      case ExerciseType.abs: return Icons.sports_martial_arts;
      case ExerciseType.pullups: return Icons.fitness_center;
      case ExerciseType.custom: return Icons.edit;
    }
  }

  String get defaultUnit {
    switch (this) {
      case ExerciseType.pushups:
      case ExerciseType.squats:
      case ExerciseType.burpees:
      case ExerciseType.abs:
      case ExerciseType.pullups:
      case ExerciseType.jumpRope:
        return 'répétitions';
      case ExerciseType.plank:
        return 'secondes';
      case ExerciseType.running:
        return 'km';
      case ExerciseType.walking:
        return 'pas';
      case ExerciseType.custom:
        return 'répétitions';
    }
  }

  int get defaultTarget {
    switch (this) {
      case ExerciseType.pushups: return 30;
      case ExerciseType.squats: return 50;
      case ExerciseType.plank: return 60;
      case ExerciseType.burpees: return 20;
      case ExerciseType.running: return 5;
      case ExerciseType.walking: return 10000;
      case ExerciseType.jumpRope: return 100;
      case ExerciseType.abs: return 50;
      case ExerciseType.pullups: return 10;
      case ExerciseType.custom: return 30;
    }
  }
}

/// Objectif quotidien
class DailyObjective {
  ExerciseType type;
  String customName;
  int targetValue;
  String unit;
  bool hasProgression;
  int progressionPerWeek;

  DailyObjective({
    required this.type,
    this.customName = '',
    required this.targetValue,
    required this.unit,
    this.hasProgression = false,
    this.progressionPerWeek = 0,
  });
}

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final _nameController = TextEditingController();
  final _customExerciseController = TextEditingController();
  final _motivationController = TextEditingController();
  
  int _currentStep = 0;
  int _selectedDays = 30;
  bool _requireDailyPhoto = false;
  bool _enableReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  
  final List<DailyObjective> _objectives = [];

  @override
  void dispose() {
    _nameController.dispose();
    _customExerciseController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer mon Hard Challenge',
          style: TextStyle(color: _textLight, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Retour', style: TextStyle(color: _textMuted)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(),
            ),
          ),
          
          // Bottom button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? _primaryGold : _cardBgLight,
                borderRadius: BorderRadius.circular(2),
              ),
              child: isCompleted
                  ? Container(color: _primaryGold)
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1_BasicInfo();
      case 1:
        return _buildStep2_Objectives();
      case 2:
        return _buildStep3_Options();
      case 3:
        return _buildStep4_Summary();
      default:
        return const SizedBox();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ÉTAPE 1 : Informations de base
  // ═══════════════════════════════════════════════════════════
  Widget _buildStep1_BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Étape 1/4',
          style: TextStyle(color: _primaryGold, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Informations de base',
          style: TextStyle(color: _textLight, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Donne un nom à ton challenge et choisis sa durée',
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
        const SizedBox(height: 32),

        // Nom du challenge
        const Text(
          'Nom du challenge *',
          style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: _textLight, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Ex: 30 Pompes Challenge, 75 Hard Sport...',
            hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
            filled: true,
            fillColor: _cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryGold),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Durée
        const Text(
          'Durée du challenge *',
          style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [30, 50, 75, 90].map((days) {
            final isSelected = days == _selectedDays;
            return GestureDetector(
              onTap: () => setState(() => _selectedDays = days),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryGold : _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _primaryGold : _borderColor,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$days',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : _textLight,
                      ),
                    ),
                    Text(
                      'jours',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.black87 : _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Citation motivation
        const Text(
          'Citation de motivation (optionnel)',
          style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _motivationController,
          style: const TextStyle(color: _textLight, fontSize: 14),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Ex: Chaque jour compte, chaque effort te rapproche du but !',
            hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
            filled: true,
            fillColor: _cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryGold),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ÉTAPE 2 : Objectifs quotidiens
  // ═══════════════════════════════════════════════════════════
  Widget _buildStep2_Objectives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Étape 2/4',
          style: TextStyle(color: _primaryGold, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Objectifs quotidiens',
          style: TextStyle(color: _textLight, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ajoute les exercices que tu devras faire chaque jour',
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Liste des objectifs ajoutés
        if (_objectives.isNotEmpty) ...[
          ..._objectives.asMap().entries.map((entry) {
            final index = entry.key;
            final obj = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(obj.type.icon, color: _primaryGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          obj.type == ExerciseType.custom ? obj.customName : obj.type.label,
                          style: const TextStyle(color: _textLight, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${obj.targetValue} ${obj.unit}${obj.hasProgression ? ' (+${obj.progressionPerWeek}/sem)' : ''}',
                          style: const TextStyle(color: _textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: _textMuted, size: 20),
                    onPressed: () => _editObjective(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: _primaryRed, size: 20),
                    onPressed: () => setState(() => _objectives.removeAt(index)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Bouton ajouter objectif
        GestureDetector(
          onTap: _showAddObjectiveSheet,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryGold.withOpacity(0.5), style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: _primaryGold, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Ajouter un objectif',
                  style: TextStyle(color: _primaryGold, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        if (_objectives.isEmpty) ...[
          const SizedBox(height: 32),
          // Suggestions rapides
          const Text(
            'Suggestions populaires',
            style: TextStyle(color: _textMuted, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSuggestion(ExerciseType.pushups, 30),
              _buildQuickSuggestion(ExerciseType.squats, 50),
              _buildQuickSuggestion(ExerciseType.plank, 60),
              _buildQuickSuggestion(ExerciseType.walking, 10000),
              _buildQuickSuggestion(ExerciseType.running, 3),
              _buildQuickSuggestion(ExerciseType.abs, 50),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQuickSuggestion(ExerciseType type, int target) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _objectives.add(DailyObjective(
            type: type,
            targetValue: target,
            unit: type.defaultUnit,
          ));
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, color: _primaryGold, size: 16),
            const SizedBox(width: 6),
            Text(
              '$target ${type.defaultUnit == 'répétitions' ? type.label.toLowerCase() : type.defaultUnit}',
              style: const TextStyle(color: _textLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddObjectiveSheet() {
    ExerciseType selectedType = ExerciseType.pushups;
    final targetController = TextEditingController(text: selectedType.defaultTarget.toString());
    final customNameController = TextEditingController();
    String selectedUnit = selectedType.defaultUnit;
    bool hasProgression = false;
    final progressionController = TextEditingController(text: '5');

    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Ajouter un objectif',
                      style: TextStyle(color: _textLight, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: _textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Type d'exercice
                const Text('Type d\'exercice', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExerciseType.values.map((type) {
                    final isSelected = type == selectedType;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          selectedType = type;
                          selectedUnit = type.defaultUnit;
                          targetController.text = type.defaultTarget.toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? _primaryGold : _cardBgLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(type.icon, size: 16, color: isSelected ? Colors.black : _textMuted),
                            const SizedBox(width: 6),
                            Text(
                              type.label,
                              style: TextStyle(
                                color: isSelected ? Colors.black : _textLight,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Nom personnalisé si custom
                if (selectedType == ExerciseType.custom) ...[
                  const Text('Nom de l\'exercice', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: customNameController,
                    style: const TextStyle(color: _textLight),
                    decoration: InputDecoration(
                      hintText: 'Ex: Dips, Mountain climbers...',
                      hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
                      filled: true,
                      fillColor: _cardBgLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Objectif et unité
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Objectif', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: targetController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: _textLight, fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _cardBgLight,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unité', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: _cardBgLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedUnit,
                                isExpanded: true,
                                dropdownColor: _cardBg,
                                style: const TextStyle(color: _textLight),
                                items: ['répétitions', 'secondes', 'minutes', 'km', 'pas', 'litres']
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) => setModalState(() => selectedUnit = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Progression hebdomadaire
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardBgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_up, color: _primaryGreen, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Progression hebdomadaire',
                              style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Switch(
                            value: hasProgression,
                            activeColor: _primaryGold,
                            onChanged: (v) => setModalState(() => hasProgression = v),
                          ),
                        ],
                      ),
                      if (hasProgression) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Augmenter de', style: TextStyle(color: _textMuted, fontSize: 13)),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: progressionController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: _textLight),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: _cardBg,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text('par semaine', style: TextStyle(color: _textMuted, fontSize: 13)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton ajouter
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final target = int.tryParse(targetController.text) ?? selectedType.defaultTarget;
                      final progression = int.tryParse(progressionController.text) ?? 0;
                      
                      setState(() {
                        _objectives.add(DailyObjective(
                          type: selectedType,
                          customName: customNameController.text,
                          targetValue: target,
                          unit: selectedUnit,
                          hasProgression: hasProgression,
                          progressionPerWeek: progression,
                        ));
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ajouter cet objectif', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editObjective(int index) {
    // TODO: Implémenter l'édition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Édition bientôt disponible'), backgroundColor: _primaryBlue),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ÉTAPE 3 : Options
  // ═══════════════════════════════════════════════════════════
  Widget _buildStep3_Options() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Étape 3/4',
          style: TextStyle(color: _primaryGold, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Options du challenge',
          style: TextStyle(color: _textLight, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Personnalise ton challenge avec des options supplémentaires',
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
        const SizedBox(height: 32),

        // Photo quotidienne
        _buildOptionTile(
          icon: Icons.camera_alt,
          iconColor: _primaryOrange,
          title: 'Photo quotidienne obligatoire',
          subtitle: 'Prends une photo chaque jour pour valider',
          value: _requireDailyPhoto,
          onChanged: (v) => setState(() => _requireDailyPhoto = v),
        ),
        const SizedBox(height: 16),

        // Rappel
        _buildOptionTile(
          icon: Icons.notifications_active,
          iconColor: _primaryBlue,
          title: 'Rappel quotidien',
          subtitle: 'Reçois une notification pour ne pas oublier',
          value: _enableReminder,
          onChanged: (v) => setState(() => _enableReminder = v),
        ),

        if (_enableReminder) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(primary: _primaryGold),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() => _reminderTime = time);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 52),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, color: _primaryGold, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, color: _textMuted, size: 16),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? iconColor.withOpacity(0.5) : _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _textLight, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: _textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: iconColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ÉTAPE 4 : Résumé
  // ═══════════════════════════════════════════════════════════
  Widget _buildStep4_Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Étape 4/4',
          style: TextStyle(color: _primaryGold, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Résumé du challenge',
          style: TextStyle(color: _textLight, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Vérifie les détails avant de lancer ton challenge',
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
        const SizedBox(height: 32),

        // Card résumé
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryGold.withOpacity(0.2), _cardBg],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primaryGold.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_fire_department, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isEmpty ? 'Mon Challenge' : _nameController.text,
                          style: const TextStyle(color: _textLight, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$_selectedDays jours',
                          style: const TextStyle(color: _primaryGold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: _borderColor),
              const SizedBox(height: 16),

              // Objectifs
              const Text(
                'Objectifs quotidiens',
                style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._objectives.map((obj) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(obj.type.icon, color: _primaryGold, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${obj.targetValue} ${obj.unit} de ${obj.type == ExerciseType.custom ? obj.customName : obj.type.label.toLowerCase()}',
                        style: const TextStyle(color: _textLight, fontSize: 14),
                      ),
                    ),
                    if (obj.hasProgression)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+${obj.progressionPerWeek}/sem',
                          style: const TextStyle(color: _primaryGreen, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              )),

              const SizedBox(height: 16),
              const Divider(color: _borderColor),
              const SizedBox(height: 16),

              // Options
              const Text(
                'Options',
                style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _requireDailyPhoto ? Icons.check_circle : Icons.cancel,
                    color: _requireDailyPhoto ? _primaryGreen : _textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Text('Photo quotidienne', style: TextStyle(color: _textLight, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _enableReminder ? Icons.check_circle : Icons.cancel,
                    color: _enableReminder ? _primaryGreen : _textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _enableReminder 
                        ? 'Rappel à ${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'
                        : 'Pas de rappel',
                    style: const TextStyle(color: _textLight, fontSize: 14),
                  ),
                ],
              ),

              if (_motivationController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: _borderColor),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardBgLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.format_quote, color: _primaryGold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _motivationController.text,
                          style: const TextStyle(color: _textMuted, fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTTOM BUTTON
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomButton() {
    final isLastStep = _currentStep == 3;
    final canContinue = _canContinue();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canContinue ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canContinue ? _primaryGold : _cardBgLight,
              foregroundColor: canContinue ? Colors.black : _textMuted,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isLastStep ? '🚀 Lancer le challenge !' : 'Continuer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _objectives.isNotEmpty;
      case 2:
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _createChallenge();
    }
  }

  void _createChallenge() {
    HapticFeedback.heavyImpact();
    
    // TODO: Sauvegarder le challenge
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Challenge "${_nameController.text}" créé pour $_selectedDays jours !'),
            ),
          ],
        ),
        backgroundColor: _primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}









