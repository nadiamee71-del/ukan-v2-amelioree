/// Éditeur de disponibilités pour les coachs
/// Ukan - Permet de définir les créneaux disponibles

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_models.dart';
import 'appointments_repository.dart';

class CoachAvailabilityEditor extends StatefulWidget {
  final String coachId;

  const CoachAvailabilityEditor({
    super.key,
    required this.coachId,
  });

  @override
  State<CoachAvailabilityEditor> createState() => _CoachAvailabilityEditorState();
}

class _CoachAvailabilityEditorState extends State<CoachAvailabilityEditor> {
  final _repository = AppointmentsRepository();
  late CoachAvailability _availability;
  
  final List<String> _weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  void initState() {
    super.initState();
    _availability = _repository.getCoachAvailability(widget.coachId) ??
        CoachAvailability(coachId: widget.coachId);
    _repository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    final updated = _repository.getCoachAvailability(widget.coachId);
    if (updated != null && mounted) {
      setState(() => _availability = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mes Disponibilités',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section jours travaillés
            _buildSection(
              title: '📅 Jours travaillés',
              subtitle: 'Sélectionnez vos jours de travail',
              child: _buildWorkingDaysSelector(),
            ),
            
            const SizedBox(height: 24),
            
            // Section horaires par défaut
            _buildSection(
              title: '⏰ Horaires par défaut',
              subtitle: 'Définissez vos heures de travail',
              child: _buildDefaultHoursSelector(),
            ),
            
            const SizedBox(height: 24),
            
            // Section créneaux personnalisés
            _buildSection(
              title: '📋 Créneaux personnalisés',
              subtitle: 'Ajoutez des créneaux spécifiques',
              child: _buildCustomSlots(),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSlotSheet,
        backgroundColor: const Color(0xFFFFC300),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un créneau'),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildWorkingDaysSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final dayNumber = index + 1;
          final isSelected = _availability.workingDays.contains(dayNumber);
          return GestureDetector(
            onTap: () {
              final newDays = List<int>.from(_availability.workingDays);
              if (isSelected) {
                newDays.remove(dayNumber);
              } else {
                newDays.add(dayNumber);
              }
              newDays.sort();
              _repository.updateWorkingDays(widget.coachId, newDays);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFFFFC300) 
                    : const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFFFFC300) 
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Text(
                  _weekDays[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDefaultHoursSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeSelector(
              label: 'Début',
              time: _availability.defaultStartTime,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _availability.defaultStartTime,
                  builder: _timePickerBuilder,
                );
                if (time != null) {
                  _repository.setCoachAvailability(
                    _availability.copyWith(defaultStartTime: time),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.3)),
          ),
          Expanded(
            child: _buildTimeSelector(
              label: 'Fin',
              time: _availability.defaultEndTime,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _availability.defaultEndTime,
                  builder: _timePickerBuilder,
                );
                if (time != null) {
                  _repository.setCoachAvailability(
                    _availability.copyWith(defaultEndTime: time),
                  );
                }
              },
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 4),
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

  Widget _buildCustomSlots() {
    // Grouper les créneaux par date
    final slotsByDate = <DateTime, List<AvailableSlot>>{};
    for (final slot in _availability.slots) {
      if (slot.start.isAfter(DateTime.now())) {
        final dateKey = DateTime(slot.start.year, slot.start.month, slot.start.day);
        slotsByDate[dateKey] ??= [];
        slotsByDate[dateKey]!.add(slot);
      }
    }

    // Trier par date
    final sortedDates = slotsByDate.keys.toList()..sort();

    if (sortedDates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun créneau personnalisé',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Utilisez le bouton + pour ajouter',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: sortedDates.take(5).map((date) {
        final slots = slotsByDate[date]!;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFFFC300),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE d MMMM', 'fr_FR').format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Créneaux
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: slots.map((slot) => _buildSlotChip(slot)).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlotChip(AvailableSlot slot) {
    final startStr = '${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')}';
    final endStr = '${slot.end.hour.toString().padLeft(2, '0')}:${slot.end.minute.toString().padLeft(2, '0')}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$startStr - $endStr',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              _repository.removeAvailabilitySlot(widget.coachId, slot.id);
            },
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.red,
            ),
          ),
        ],
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

  void _showAddSlotSheet() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay startTime = _availability.defaultStartTime;
    TimeOfDay endTime = _availability.defaultEndTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Ajouter un créneau',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Sélection date
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
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
                    setSheetState(() => selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE d MMMM', 'fr_FR').format(selectedDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.edit, color: Color(0xFFFFC300), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Sélection heures
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                          builder: _timePickerBuilder,
                        );
                        if (time != null) {
                          setSheetState(() => startTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Début',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Color(0xFFFFC300),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward, color: Colors.white24),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                          builder: _timePickerBuilder,
                        );
                        if (time != null) {
                          setSheetState(() => endTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Fin',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Color(0xFFFFC300),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Bouton ajouter
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final start = DateTime(
                      selectedDate.year, selectedDate.month, selectedDate.day,
                      startTime.hour, startTime.minute,
                    );
                    final end = DateTime(
                      selectedDate.year, selectedDate.month, selectedDate.day,
                      endTime.hour, endTime.minute,
                    );
                    
                    if (end.isAfter(start)) {
                      _repository.addAvailabilitySlot(
                        widget.coachId,
                        AvailableSlot(start: start, end: end),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Créneau ajouté'),
                          backgroundColor: Color(0xFF2ECC71),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ L\'heure de fin doit être après l\'heure de début'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC300),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ajouter',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





