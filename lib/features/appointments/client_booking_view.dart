/// Vue de réservation pour les clients
/// Ukan - Permet de prendre RDV avec un coach

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_models.dart';
import 'appointments_repository.dart';

class ClientBookingView extends StatefulWidget {
  final String coachId;
  final String coachName;
  final String? coachPhotoUrl;

  const ClientBookingView({
    super.key,
    required this.coachId,
    required this.coachName,
    this.coachPhotoUrl,
  });

  @override
  State<ClientBookingView> createState() => _ClientBookingViewState();
}

class _ClientBookingViewState extends State<ClientBookingView> {
  final _repository = AppointmentsRepository();
  
  DateTime _selectedDate = DateTime.now();
  AvailableSlot? _selectedSlot;
  AppointmentType _selectedType = AppointmentType.presentiel;
  final _noteController = TextEditingController();
  
  int _currentStep = 0;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
          'Prendre RDV',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Contenu
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Info coach
                  _buildCoachInfo(),
                  const SizedBox(height: 24),
                  
                  // Étape actuelle
                  if (_currentStep == 0) _buildDateSelection(),
                  if (_currentStep == 1) _buildSlotSelection(),
                  if (_currentStep == 2) _buildTypeSelection(),
                  if (_currentStep == 3) _buildConfirmation(),
                ],
              ),
            ),
          ),
          
          // Boutons navigation
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Date', 'Heure', 'Type', 'Confirmer'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive 
                          ? const Color(0xFFFFC300) 
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? const Color(0xFFFFC300) 
                        : Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: isCurrent 
                        ? Border.all(color: const Color(0xFFFFC300), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isActive && index < _currentStep
                        ? const Icon(Icons.check, size: 16, color: Colors.black)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.black : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCoachInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC300).withOpacity(0.15),
            const Color(0xFFFFC300).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFFC300).withOpacity(0.2),
            backgroundImage: widget.coachPhotoUrl != null 
                ? AssetImage(widget.coachPhotoUrl!)
                : null,
            child: widget.coachPhotoUrl == null
                ? Text(
                    widget.coachName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFC300),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.coachName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Coach fitness',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified,
            color: Color(0xFFFFC300),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    final now = DateTime.now();
    final dates = List.generate(14, (i) => now.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisir une date',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _isSameDay(_selectedDate, date);
              final dayName = DateFormat('EEE', 'fr_FR').format(date);
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFFFC300) 
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFFFFC300) 
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM', 'fr_FR').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.black54 : Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Calendrier complet (optionnel)
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
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
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white54),
                const SizedBox(width: 12),
                const Text(
                  'Voir le calendrier complet',
                  style: TextStyle(color: Colors.white),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotSelection() {
    final slots = _repository.getAvailableSlotsForDay(widget.coachId, _selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Créneaux disponibles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              DateFormat('d MMMM', 'fr_FR').format(_selectedDate),
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (slots.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun créneau disponible',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Essayez une autre date',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) {
              final isSelected = _selectedSlot?.id == slot.id;
              final timeStr = '${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')}';
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSlot = slot);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFFFC300) 
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFFFFC300) 
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de séance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...AppointmentType.values.map((type) {
          final isSelected = _selectedType == type;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedType = type);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? type.color.withOpacity(0.15) 
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected 
                      ? type.color 
                      : Colors.white.withOpacity(0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: type.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(type.icon, color: type.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getTypeDescription(type),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: type.color),
                ],
              ),
            ),
          );
        }),
        
        const SizedBox(height: 16),
        
        // Note optionnelle
        TextField(
          controller: _noteController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ajouter une note (optionnel)...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    if (_selectedSlot == null) return const SizedBox.shrink();
    
    final dateStr = DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDate);
    final timeStr = '${_selectedSlot!.start.hour.toString().padLeft(2, '0')}:${_selectedSlot!.start.minute.toString().padLeft(2, '0')}';
    final endStr = '${_selectedSlot!.end.hour.toString().padLeft(2, '0')}:${_selectedSlot!.end.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récapitulatif',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _selectedType.color.withOpacity(0.15),
                _selectedType.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _selectedType.color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildSummaryRow(Icons.person, 'Coach', widget.coachName),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(Icons.calendar_today, 'Date', dateStr),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(Icons.access_time, 'Horaire', '$timeStr - $endStr'),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(_selectedType.icon, 'Type', _selectedType.displayName),
              if (_noteController.text.isNotEmpty) ...[
                const Divider(color: Colors.white12, height: 24),
                _buildSummaryRow(Icons.note, 'Note', _noteController.text),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF2ECC71)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Le coach recevra votre demande et pourra la confirmer.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
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
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Retour'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: _canContinue() ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white.withOpacity(0.1),
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _currentStep == 3 ? 'Confirmer le RDV' : 'Continuer',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _selectedSlot != null;
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
      _confirmBooking();
    }
  }

  void _confirmBooking() {
    if (_selectedSlot == null) return;

    final appointment = Appointment(
      id: _repository.generateId(),
      coachId: widget.coachId,
      coachName: widget.coachName,
      coachPhotoUrl: widget.coachPhotoUrl ?? '',
      clientId: _repository.currentUserId,
      clientName: 'Thomas Martin', // DEMO
      start: _selectedSlot!.start,
      end: _selectedSlot!.end,
      type: _selectedType,
      status: AppointmentStatus.pending,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    _repository.addAppointment(appointment);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ RDV réservé avec succès !'),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
  }

  String _getTypeDescription(AppointmentType type) {
    switch (type) {
      case AppointmentType.visio:
        return 'Séance en visioconférence';
      case AppointmentType.presentiel:
        return 'Séance en face à face';
      case AppointmentType.salle:
        return 'Séance dans une salle de sport';
      case AppointmentType.domicile:
        return 'Séance à votre domicile';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}





