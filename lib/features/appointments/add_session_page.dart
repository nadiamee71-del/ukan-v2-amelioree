/// Page pour ajouter une séance (Solo, Groupe, ou RDV Coach)
/// Ukan - Mode DEMO

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_models.dart';
import 'appointments_repository.dart';
import 'client_booking_view.dart';

class AddSessionPage extends StatefulWidget {
  final DateTime? initialDate;

  const AddSessionPage({
    super.key,
    this.initialDate,
  });

  @override
  State<AddSessionPage> createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  final _repository = AppointmentsRepository();
  
  SessionCategory _selectedCategory = SessionCategory.solo;
  late DateTime _selectedDate;
  TimeOfDay _startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 9, minute: 0);
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nouvelle séance',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection du type de séance
            _buildSectionTitle('Type de séance'),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            
            const SizedBox(height: 24),
            
            // Si Coach, rediriger vers la page de réservation
            if (_selectedCategory == SessionCategory.coach)
              _buildCoachInfo()
            else ...[
              // Date
              _buildSectionTitle('Date'),
              const SizedBox(height: 12),
              _buildDateSelector(),
              
              const SizedBox(height: 24),
              
              // Heures
              _buildSectionTitle('Horaires'),
              const SizedBox(height: 12),
              _buildTimeSelectors(),
              
              const SizedBox(height: 24),
              
              // Titre
              _buildSectionTitle('Titre de la séance'),
              const SizedBox(height: 12),
              _buildTitleField(),
              
              // Lieu (pour groupe uniquement)
              if (_selectedCategory == SessionCategory.group) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Lieu'),
                const SizedBox(height: 12),
                _buildLocationField(),
              ],
              
              const SizedBox(height: 24),
              
              // Note (optionnelle)
              _buildSectionTitle('Note (optionnel)'),
              const SizedBox(height: 12),
              _buildNoteField(),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _selectedCategory != SessionCategory.coach
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: SessionCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              
              // Si Coach, naviguer vers la page de réservation
              if (category == SessionCategory.coach) {
                _showCoachSelectionSheet();
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                right: category != SessionCategory.values.last ? 10 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? category.color.withOpacity(0.2) 
                    : const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected 
                      ? category.color 
                      : Colors.white.withOpacity(0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    category.icon,
                    color: isSelected ? category.color : Colors.white54,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      color: isSelected ? category.color : Colors.white54,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildCoachInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFC300).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports,
            color: const Color(0xFFFFC300),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Réserver avec un coach',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez un coach et réservez un créneau disponible',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showCoachSelectionSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Voir les coachs disponibles',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFFFC300),
                  surface: Color(0xFF1A1A1A),
                ),
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
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFFFC300)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.edit, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeSelector(
            label: 'Début',
            time: _startTime,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
                builder: _timePickerBuilder,
              );
              if (time != null) {
                setState(() {
                  _startTime = time;
                  // Ajuster l'heure de fin si nécessaire
                  if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
                    _endTime = TimeOfDay(
                      hour: (_startTime.hour + 1) % 24,
                      minute: _startTime.minute,
                    );
                  }
                });
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.3)),
        ),
        Expanded(
          child: _buildTimeSelector(
            label: 'Fin',
            time: _endTime,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
                builder: _timePickerBuilder,
              );
              if (time != null) {
                setState(() => _endTime = time);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Color(0xFFFFC300),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: _selectedCategory == SessionCategory.solo 
            ? 'Ex: Full body, Cardio 30 min, Push day...'
            : 'Ex: CrossFit avec amis, Running club...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          _selectedCategory.icon,
          color: _selectedCategory.color,
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _locationController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Ex: Salle Ukan, Parc, Domicile...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.location_on, color: Colors.white54),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      style: const TextStyle(color: Colors.white),
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Ajouter des détails...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveSession,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedCategory.color,
            foregroundColor: _selectedCategory == SessionCategory.solo 
                ? Colors.white 
                : Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Enregistrer la séance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _timePickerBuilder(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFC300),
          surface: Color(0xFF1A1A1A),
        ),
      ),
      child: child!,
    );
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  void _showCoachSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choisir un coach',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Liste des coachs démo
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCoachCard(
                      id: 'coach_1',
                      name: 'Coach Ali',
                      specialty: 'Musculation & Nutrition',
                      photoUrl: 'assets/images/coach1_header.png',
                    ),
                    _buildCoachCard(
                      id: 'coach_2',
                      name: 'Coach Sarah',
                      specialty: 'Cardio & HIIT',
                      photoUrl: 'assets/images/coach2_header.png',
                    ),
                    _buildCoachCard(
                      id: 'coach_3',
                      name: 'Coach Marc',
                      specialty: 'CrossFit & Fonctionnel',
                      photoUrl: null,
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

  Widget _buildCoachCard({
    required String id,
    required String name,
    required String specialty,
    String? photoUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Fermer le bottom sheet
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClientBookingView(
              coachId: id,
              coachName: name,
              coachPhotoUrl: photoUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFFFC300).withOpacity(0.2),
              backgroundImage: photoUrl != null ? AssetImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      name.substring(0, 1),
                      style: const TextStyle(
                        color: Color(0xFFFFC300),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    specialty,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFFFC300),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSession() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre est obligatoire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier que l'heure de fin est après l'heure de début
    if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'heure de fin doit être après l\'heure de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final session = Appointment(
      id: _repository.generateId(),
      category: _selectedCategory,
      clientId: _repository.currentUserId,
      clientName: 'Thomas Martin', // DEMO
      start: start,
      end: end,
      title: title,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      location: _selectedCategory == SessionCategory.group 
          ? (_locationController.text.isEmpty ? null : _locationController.text)
          : null,
      status: AppointmentStatus.confirmed,
    );

    _repository.addAppointment(session);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${_selectedCategory.displayName} ajoutée'),
        backgroundColor: const Color(0xFF2ECC71),
      ),
    );
  }
}





