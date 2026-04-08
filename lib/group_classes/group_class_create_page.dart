import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/group_class.dart';

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

class GroupClassCreatePage extends StatefulWidget {
  const GroupClassCreatePage({super.key});

  @override
  State<GroupClassCreatePage> createState() => _GroupClassCreatePageState();
}

class _GroupClassCreatePageState extends State<GroupClassCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '4.99');
  final _maxParticipantsController = TextEditingController(text: '30');
  
  GroupClassCategory _selectedCategory = GroupClassCategory.hiit;
  GroupClassLevel _selectedLevel = GroupClassLevel.intermediate;
  int _durationMinutes = 45;
  int _demoDurationMinutes = 5;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  final List<String> _selectedAccessories = [];
  bool _isRecurring = false;
  
  final List<String> _availableAccessories = [
    'Tapis',
    'Haltères',
    'Bouteille d\'eau',
    'Serviette',
    'Gants',
    'Corde à sauter',
    'Bande élastique',
    'Ballon',
    'Kimono',
    'Coussin',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
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
        title: Row(
          children: [
            const Text('📹', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            const Text(
              'Créer un cours',
              style: TextStyle(color: _textLight, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Infos de base
              _buildSectionTitle('📝', 'Informations du cours'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _titleController,
                label: 'Nom du cours *',
                hint: 'Ex: HIIT Intense - Brûle tout !',
                icon: Icons.title,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Décris ton cours pour donner envie...',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Section 2: Catégorie et niveau
              _buildSectionTitle('🏷️', 'Catégorie et niveau'),
              const SizedBox(height: 16),
              
              const Text('Catégorie *', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _buildCategorySelector(),
              const SizedBox(height: 20),
              
              const Text('Niveau *', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _buildLevelSelector(),
              const SizedBox(height: 24),
              
              // Section 3: Date et durée
              _buildSectionTitle('⏰', 'Date et durée'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker()),
                ],
              ),
              const SizedBox(height: 16),
              
              const Text('Durée du cours *', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _buildDurationSelector(),
              const SizedBox(height: 16),
              
              // Récurrence
              _buildOptionSwitch(
                icon: '🔄',
                title: 'Cours récurrent',
                subtitle: 'Répéter chaque semaine à la même heure',
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
              ),
              const SizedBox(height: 24),
              
              // Section 4: Prix et démo
              _buildSectionTitle('💰', 'Tarification'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Prix du cours (€) *',
                      hint: '4.99',
                      icon: Icons.euro,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _maxParticipantsController,
                      label: 'Places max *',
                      hint: '30',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              const Text('Durée de la démo gratuite *', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text(
                '🎬 Offre un aperçu gratuit pour donner envie aux participants !',
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              _buildDemoSelector(),
              const SizedBox(height: 24),
              
              // Section 5: Matériel
              _buildSectionTitle('🎒', 'Matériel nécessaire'),
              const SizedBox(height: 16),
              _buildAccessoriesSelector(),
              const SizedBox(height: 32),
              
              // Résumé
              _buildSummaryCard(),
              const SizedBox(height: 24),
              
              // Bouton créer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createClass,
                  icon: const Text('🚀', style: TextStyle(fontSize: 20)),
                  label: const Text(
                    'Publier le cours',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _textLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: _textLight),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: _textMuted, size: 20),
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

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: GroupClassCategory.values.map((cat) {
        final isSelected = cat == _selectedCategory;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? cat.color : _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? cat.color : _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  cat.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _textMuted,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLevelSelector() {
    return Row(
      children: GroupClassLevel.values.map((level) {
        final isSelected = level == _selectedLevel;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedLevel = level),
            child: Container(
              margin: EdgeInsets.only(right: level != GroupClassLevel.advanced ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? _primaryGold : _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? _primaryGold : _borderColor),
              ),
              child: Column(
                children: [
                  Text(level.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    level.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.black : _textMuted,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: _primaryGold),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: _primaryGold, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date', style: TextStyle(color: _textMuted, fontSize: 11)),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(color: _textLight, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
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
          setState(() => _selectedTime = time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: _primaryGold, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Heure', style: TextStyle(color: _textMuted, fontSize: 11)),
                Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: _textLight, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [15, 30, 45, 60, 90];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: durations.map((d) {
        final isSelected = d == _durationMinutes;
        return GestureDetector(
          onTap: () => setState(() => _durationMinutes = d),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _primaryGold : _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? _primaryGold : _borderColor),
            ),
            child: Text(
              '$d min',
              style: TextStyle(
                color: isSelected ? Colors.black : _textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDemoSelector() {
    final demos = [1, 3, 5, 7, 10];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: demos.map((d) {
        final isSelected = d == _demoDurationMinutes;
        return GestureDetector(
          onTap: () => setState(() => _demoDurationMinutes = d),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _primaryBlue : _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? _primaryBlue : _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎬', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  '$d min',
                  style: TextStyle(
                    color: isSelected ? Colors.white : _textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessoriesSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableAccessories.map((acc) {
        final isSelected = _selectedAccessories.contains(acc);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAccessories.remove(acc);
              } else {
                _selectedAccessories.add(acc);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _primaryGreen.withOpacity(0.2) : _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _primaryGreen : _borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  size: 16,
                  color: isSelected ? _primaryGreen : _textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  acc,
                  style: TextStyle(
                    color: isSelected ? _primaryGreen : _textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionSwitch({
    required String icon,
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
        border: Border.all(color: value ? _primaryGold.withOpacity(0.5) : _borderColor),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _textLight, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: _textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: _primaryGold,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final price = double.tryParse(_priceController.text) ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_selectedCategory.color.withOpacity(0.2), _cardBg],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _selectedCategory.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Aperçu du cours',
                style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedCategory.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_selectedCategory.emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleController.text.isEmpty ? 'Nom du cours' : _titleController.text,
                      style: TextStyle(
                        color: _titleController.text.isEmpty ? _textMuted : _textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: _titleController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedCategory.displayName} • ${_selectedLevel.displayName}',
                      style: TextStyle(color: _selectedCategory.color, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: _borderColor),
          const SizedBox(height: 12),
          
          _buildSummaryRow('📅', '${_selectedDate.day}/${_selectedDate.month} à ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
          _buildSummaryRow('⏱️', '$_durationMinutes min'),
          _buildSummaryRow('🎬', 'Démo de $_demoDurationMinutes min gratuite'),
          _buildSummaryRow('💰', '${price.toStringAsFixed(2)} €'),
          if (_selectedAccessories.isNotEmpty)
            _buildSummaryRow('🎒', _selectedAccessories.join(', ')),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: _textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  void _createClass() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donne un nom à ton cours !'),
          backgroundColor: _primaryRed,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Cours "${_titleController.text}" publié !'),
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









