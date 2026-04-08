import 'package:flutter/material.dart';
import '../models/group_class.dart';
import '../models/group_class_notifier.dart';

/// Page Coach - Créer un cours collectif
class CoachCreateGroupClassPage extends StatefulWidget {
  const CoachCreateGroupClassPage({super.key});

  @override
  State<CoachCreateGroupClassPage> createState() =>
      _CoachCreateGroupClassPageState();
}

class _CoachCreateGroupClassPageState extends State<CoachCreateGroupClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _accessoriesController = TextEditingController();

  GroupClassLevel _selectedLevel = GroupClassLevel.beginner;
  String _selectedCategory = 'hiit';
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _caloriesController.dispose();
    _accessoriesController.dispose();
    super.dispose();
  }

  void _publishClass() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne une date et heure pour le cours'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final accessories = _accessoriesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final groupClass = GroupClass(
      id: 'coach_class_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      coachName: 'Toi', // En vrai: récupérer depuis le profil coach
      coachId: 'coach_self',
      coachRating: 5.0,
      level: _selectedLevel,
      durationMinutes: int.parse(_durationController.text),
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      startDateTime: _selectedDateTime,
      isLive: false,
      isReplay: false,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      estimatedCalories: _caloriesController.text.isNotEmpty
          ? int.parse(_caloriesController.text)
          : 0,
      accessories: accessories,
    );

    GroupClassNotifier().addClass(groupClass);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cours publié avec succès ! ✅'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Informations du cours'),
                      const SizedBox(height: 20),

                      // Titre
                      _buildTextField(
                        controller: _titleController,
                        label: 'Titre du cours *',
                        icon: Icons.title_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le titre est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),

                      // Catégorie
                      _buildDropdown<String>(
                        label: 'Catégorie *',
                        icon: Icons.category_rounded,
                        value: _selectedCategory,
                        items: GroupClassCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat.name,
                            child: Text('${cat.emoji} ${cat.displayName}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Niveau
                      _buildDropdown<GroupClassLevel>(
                        label: 'Niveau *',
                        icon: Icons.signal_cellular_alt_rounded,
                        value: _selectedLevel,
                        items: GroupClassLevel.values.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text('${level.emoji} ${level.displayName}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedLevel = value);
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Paramètres'),
                      const SizedBox(height: 20),

                      // Durée
                      _buildTextField(
                        controller: _durationController,
                        label: 'Durée (minutes) *',
                        icon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La durée est obligatoire';
                          }
                          final duration = int.tryParse(value);
                          if (duration == null || duration <= 0) {
                            return 'Durée invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Prix
                      _buildTextField(
                        controller: _priceController,
                        label: 'Prix (€) *',
                        icon: Icons.euro_rounded,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le prix est obligatoire';
                          }
                          final price = double.tryParse(value.replaceAll(',', '.'));
                          if (price == null || price <= 0) {
                            return 'Prix invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Calories estimées
                      _buildTextField(
                        controller: _caloriesController,
                        label: 'Calories estimées (optionnel)',
                        icon: Icons.local_fire_department_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Accessoires
                      _buildTextField(
                        controller: _accessoriesController,
                        label: 'Accessoires requis (séparés par des virgules)',
                        icon: Icons.fitness_center_outlined,
                        hint: 'Ex: Tapis, Haltères, Bouteille d\'eau',
                      ),
                      const SizedBox(height: 16),

                      // Date et heure
                      _buildDateTimePicker(),
                      const SizedBox(height: 32),

                      // Bouton Publier
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _publishClass,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC300),
                            foregroundColor: const Color(0xFF050814),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.publish_rounded, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Publier le cours',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D111C),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          const Text(
            'Créer un cours',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFFFC300)),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: const Color(0xFF0D111C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFFFC300),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D111C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFFFC300)),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF0D111C),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date et heure *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D111C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Color(0xFFFFC300)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'Sélectionner date et heure'
                        : _formatDateTime(_selectedDateTime!),
                    style: TextStyle(
                      color: _selectedDateTime == null
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: const Color(0xFFFFC300),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC300),
              surface: Color(0xFF0D111C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: const Color(0xFFFFC300),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC300),
              surface: Color(0xFF0D111C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year} à $hour:$minute';
  }
}







