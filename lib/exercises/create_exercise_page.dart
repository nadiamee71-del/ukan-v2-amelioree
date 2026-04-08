import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// =======================
/// Données de référence
/// =======================

const List<String> kExerciseCategories = [
  'Pectoraux',
  'Dos',
  'Épaules',
  'Biceps',
  'Triceps',
  'Jambes',
  'Fessiers',
  'Mollets',
  'Abdominaux',
  'Cardio',
  'Full body',
  'Autre',
];

const Map<String, IconData> kCategoryIcons = {
  'Pectoraux': Icons.fitness_center,
  'Dos': Icons.airline_seat_flat,
  'Épaules': Icons.accessibility_new,
  'Biceps': Icons.sports_martial_arts,
  'Triceps': Icons.sports_martial_arts,
  'Jambes': Icons.directions_walk,
  'Fessiers': Icons.directions_run,
  'Mollets': Icons.directions_walk,
  'Abdominaux': Icons.sports_gymnastics,
  'Cardio': Icons.favorite,
  'Full body': Icons.accessibility,
  'Autre': Icons.more_horiz,
};

const List<String> kExerciseLevels = [
  'Débutant',
  'Intermédiaire',
  'Avancé',
];

const Map<String, Color> kLevelColors = {
  'Débutant': Colors.green,
  'Intermédiaire': Colors.orange,
  'Avancé': Colors.red,
};

const Map<String, IconData> kLevelIcons = {
  'Débutant': Icons.star_border,
  'Intermédiaire': Icons.star_half,
  'Avancé': Icons.star,
};

const List<String> kAllMuscles = [
  'Pectoraux',
  'Grand dorsal',
  'Trapèzes',
  'Deltoïdes antérieurs',
  'Deltoïdes latéraux',
  'Deltoïdes postérieurs',
  'Biceps',
  'Triceps',
  'Avant-bras',
  'Abdominaux',
  'Obliques',
  'Lombaires',
  'Quadriceps',
  'Ischios',
  'Fessiers',
  'Mollets',
  'Adducteurs',
  'Abducteurs',
  'Cou',
  'Cardio / Système cardio-respiratoire',
];

const List<String> kEquipmentSuggestions = [
  'Poids du corps',
  'Barre',
  'Haltères',
  'Kettlebell',
  'Machine guidée',
  'Câbles / Poulies',
  'Élastiques',
  'Banc',
  'TRX / Sangles',
  'Medecine ball',
  'Swiss ball',
  'Barre de traction',
  'Dips',
  'Step',
  'Vélo',
  'Tapis de course',
  'Rameur',
];

/// =======================
/// Page principale
/// =======================

class CreateExercisePage extends StatefulWidget {
  const CreateExercisePage({super.key});

  @override
  State<CreateExercisePage> createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shortDescriptionController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _tipsController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLevel;
  List<String> _primaryMuscles = [];
  List<String> _secondaryMuscles = [];
  bool _isUnilateral = false;
  List<String> _selectedEquipment = [];

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _stepsController.dispose();
    _tipsController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  int _calculateProgress() {
    int filled = 0;
    if (_nameController.text.trim().isNotEmpty) filled++;
    if (_selectedCategory != null) filled++;
    if (_selectedLevel != null) filled++;
    if (_primaryMuscles.isNotEmpty) filled++;
    if (_shortDescriptionController.text.trim().isNotEmpty) filled++;
    return filled;
  }

  void _saveExercise() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 8),
              Text('Veuillez remplir les champs obligatoires'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_primaryMuscles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 8),
              Text('Choisissez au moins un muscle principal'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final exerciseData = {
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'level': _selectedLevel,
      'primaryMuscles': _primaryMuscles,
      'secondaryMuscles': _secondaryMuscles,
      'shortDescription': _shortDescriptionController.text.trim(),
      'steps': _stepsController.text.trim(),
      'tips': _tipsController.text.trim(),
      'equipment': _selectedEquipment.isNotEmpty 
          ? _selectedEquipment.join(', ') 
          : _equipmentController.text.trim(),
      'isUnilateral': _isUnilateral,
    };

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Exercice créé avec succès ! 💪'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.of(context).pop(exerciseData);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final progressPercent = progress / 5;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header personnalisé
              _buildHeader(progressPercent),
              
              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Column(
                    children: [
                      // Aperçu en temps réel
                      _buildPreviewCard(),
                      const SizedBox(height: 20),
                      
                      // Section 1: Informations de base
                      _buildAnimatedSection(
                        index: 0,
                        icon: Icons.edit_note,
                        iconColor: const Color(0xFFFFC300),
                        title: 'Informations de base',
                        subtitle: 'Nom, catégorie et niveau',
                        child: _buildBasicInfoSection(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Section 2: Muscles sollicités
                      _buildAnimatedSection(
                        index: 1,
                        icon: Icons.accessibility_new,
                        iconColor: Colors.redAccent,
                        title: 'Muscles sollicités',
                        subtitle: 'Principaux et secondaires',
                        child: _buildMusclesSection(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Section 3: Description & Exécution
                      _buildAnimatedSection(
                        index: 2,
                        icon: Icons.description,
                        iconColor: Colors.blueAccent,
                        title: 'Description & Exécution',
                        subtitle: 'Comment réaliser l\'exercice',
                        child: _buildDescriptionSection(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Section 4: Équipement & Options
                      _buildAnimatedSection(
                        index: 3,
                        icon: Icons.fitness_center,
                        iconColor: Colors.greenAccent,
                        title: 'Équipement & Options',
                        subtitle: 'Matériel nécessaire et conseils',
                        child: _buildEquipmentSection(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bouton flottant pour enregistrer
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: _saveExercise,
          backgroundColor: const Color(0xFFFFC300),
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.check_circle, size: 24),
          label: const Text(
            'Créer l\'exercice',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(double progressPercent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de titre
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouvel exercice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Créez votre exercice personnalisé',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de progression
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progressPercent == 1
                      ? Colors.green.withOpacity(0.2)
                      : const Color(0xFFFFC300).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: progressPercent == 1
                        ? Colors.green.withOpacity(0.5)
                        : const Color(0xFFFFC300).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      progressPercent == 1 ? Icons.check_circle : Icons.edit,
                      size: 14,
                      color: progressPercent == 1 ? Colors.green : const Color(0xFFFFC300),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(progressPercent * 100).toInt()}%',
                      style: TextStyle(
                        color: progressPercent == 1 ? Colors.green : const Color(0xFFFFC300),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercent == 1 ? Colors.green : const Color(0xFFFFC300),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final hasName = _nameController.text.trim().isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF0D0D0D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC300).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar de l'exercice
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _selectedCategory != null
                  ? const Color(0xFFFFC300).withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedCategory != null
                    ? const Color(0xFFFFC300).withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: _selectedCategory != null
                  ? Icon(
                      kCategoryIcons[_selectedCategory] ?? Icons.fitness_center,
                      color: const Color(0xFFFFC300),
                      size: 32,
                    )
                  : Text(
                      hasName ? _nameController.text[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: hasName ? Colors.white : Colors.white30,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasName ? _nameController.text : 'Nom de l\'exercice',
                  style: TextStyle(
                    color: hasName ? Colors.white : Colors.white30,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (_selectedCategory != null) ...[
                      _buildMiniChip(_selectedCategory!, const Color(0xFFFFC300)),
                      const SizedBox(width: 8),
                    ],
                    if (_selectedLevel != null)
                      _buildMiniChip(
                        _selectedLevel!,
                        kLevelColors[_selectedLevel] ?? Colors.grey,
                      ),
                  ],
                ),
                if (_primaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _primaryMuscles.join(', '),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isExpanded = _currentStep == index;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded 
              ? iconColor.withOpacity(0.5) 
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          // Header de section cliquable
          InkWell(
            onTap: () => setState(() => _currentStep = isExpanded ? -1 : index),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenu animé
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState: isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        // Nom de l'exercice
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: _inputDecoration(
            label: 'Nom de l\'exercice',
            hint: 'Ex: Squat barre, Pompes, Gainage...',
            icon: Icons.sports_martial_arts,
            required: true,
          ),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty || value.trim().length < 3) {
              return 'Minimum 3 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Sélection de catégorie avec chips visuels
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Catégorie *',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kExerciseCategories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFC300).withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFC300)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      kCategoryIcons[category] ?? Icons.fitness_center,
                      size: 16,
                      color: isSelected ? const Color(0xFFFFC300) : Colors.white54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFFFC300) : Colors.white70,
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
        const SizedBox(height: 20),
        
        // Sélection de niveau avec badges colorés
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Niveau de difficulté *',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: kExerciseLevels.map((level) {
            final isSelected = _selectedLevel == level;
            final color = kLevelColors[level] ?? Colors.grey;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedLevel = level),
                child: Container(
                  margin: EdgeInsets.only(
                    right: level != kExerciseLevels.last ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.white.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        kLevelIcons[level] ?? Icons.star,
                        color: isSelected ? color : Colors.white54,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        level,
                        style: TextStyle(
                          color: isSelected ? color : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMusclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Muscles principaux
        _buildMuscleSelector(
          label: 'Muscles principaux',
          required: true,
          selected: _primaryMuscles,
          onChanged: (list) => setState(() => _primaryMuscles = list),
          color: Colors.redAccent,
        ),
        const SizedBox(height: 16),
        
        // Muscles secondaires
        _buildMuscleSelector(
          label: 'Muscles secondaires',
          required: false,
          selected: _secondaryMuscles,
          onChanged: (list) => setState(() => _secondaryMuscles = list),
          color: Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _buildMuscleSelector({
    required String label,
    required bool required,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 8),
            Text(
              '$label${required ? ' *' : ''}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (selected.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${selected.length} sélectionné${selected.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _openMusclePicker(label, selected, onChanged),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected.isNotEmpty 
                    ? color.withOpacity(0.5) 
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: selected.isEmpty ? Colors.white54 : color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selected.isEmpty
                        ? 'Appuyez pour sélectionner'
                        : selected.join(', '),
                    style: TextStyle(
                      color: selected.isEmpty ? Colors.white54 : Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white30,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selected.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    m,
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      final newList = List<String>.from(selected)..remove(m);
                      onChanged(newList);
                    },
                    child: Icon(Icons.close, size: 14, color: color),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      children: [
        TextFormField(
          controller: _shortDescriptionController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Description courte',
            hint: 'Décrivez brièvement l\'exercice...',
            icon: Icons.short_text,
            required: true,
          ),
          minLines: 2,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ajoutez une description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _stepsController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Étapes d\'exécution',
            hint: '1. Position de départ\n2. Mouvement\n3. Retour...',
            icon: Icons.format_list_numbered,
            required: false,
          ),
          minLines: 3,
          maxLines: 8,
        ),
      ],
    );
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Équipement avec suggestions
        const Text(
          'Équipement utilisé',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kEquipmentSuggestions.take(12).map((eq) {
            final isSelected = _selectedEquipment.contains(eq);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedEquipment.remove(eq);
                  } else {
                    _selectedEquipment.add(eq);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.greenAccent.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.greenAccent
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  eq,
                  style: TextStyle(
                    color: isSelected ? Colors.greenAccent : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Switch unilatéral
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isUnilateral 
                      ? const Color(0xFFFFC300).withOpacity(0.2) 
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.compare_arrows,
                  color: _isUnilateral ? const Color(0xFFFFC300) : Colors.white54,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exercice unilatéral',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Un côté à la fois',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isUnilateral,
                activeColor: const Color(0xFFFFC300),
                onChanged: (value) => setState(() => _isUnilateral = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Conseils de sécurité
        TextFormField(
          controller: _tipsController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Conseils de sécurité',
            hint: 'Garder le dos droit, ne pas verrouiller les genoux...',
            icon: Icons.health_and_safety,
            required: false,
          ),
          minLines: 2,
          maxLines: 4,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required bool required,
  }) {
    return InputDecoration(
      labelText: '$label${required ? ' *' : ''}',
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFC300), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  void _openMusclePicker(String label, List<String> selected, ValueChanged<List<String>> onChanged) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MusclePickerSheet(
        label: label,
        selected: selected,
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }
}

/// =======================
/// Bottom sheet de sélection des muscles
/// =======================

class _MusclePickerSheet extends StatefulWidget {
  final String label;
  final List<String> selected;

  const _MusclePickerSheet({
    required this.label,
    required this.selected,
  });

  @override
  State<_MusclePickerSheet> createState() => _MusclePickerSheetState();
}

class _MusclePickerSheetState extends State<_MusclePickerSheet> {
  late Set<String> _tempSelection;

  @override
  void initState() {
    super.initState();
    _tempSelection = Set<String>.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_tempSelection.length} sélectionné${_tempSelection.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Color(0xFFFFC300),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          // Liste des muscles
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kAllMuscles.length,
              itemBuilder: (context, index) {
                final muscle = kAllMuscles[index];
                final isSelected = _tempSelection.contains(muscle);
                return ListTile(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _tempSelection.remove(muscle);
                      } else {
                        _tempSelection.add(muscle);
                      }
                    });
                  },
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFC300)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.black, size: 16)
                        : null,
                  ),
                  title: Text(
                    muscle,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          // Boutons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
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
                    onPressed: () => Navigator.pop(context, _tempSelection.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Valider',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
