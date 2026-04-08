/// Vue détaillée d'un rendez-vous
/// Ukan - Permet de modifier/annuler/confirmer

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_models.dart';
import 'appointments_repository.dart';
import 'appointment_type_badge.dart';

class AppointmentDetailsView extends StatefulWidget {
  final Appointment appointment;
  final bool isCoachView;

  const AppointmentDetailsView({
    super.key,
    required this.appointment,
    this.isCoachView = false,
  });

  @override
  State<AppointmentDetailsView> createState() => _AppointmentDetailsViewState();
}

class _AppointmentDetailsViewState extends State<AppointmentDetailsView> {
  final _repository = AppointmentsRepository();
  late Appointment _appointment;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _noteController.text = _appointment.note ?? '';
    _repository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    _noteController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    // Retrouver le RDV mis à jour
    final updated = _repository.allAppointments
        .where((a) => a.id == _appointment.id)
        .firstOrNull;
    if (updated != null && mounted) {
      setState(() => _appointment = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = _appointment.status == AppointmentStatus.cancelled;
    final isPast = _appointment.isPast;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Détails du RDV',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principale
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _appointment.color.withOpacity(0.2),
                    _appointment.color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _appointment.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  // Type/Catégorie et statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_appointment.type != null)
                        AppointmentTypeBadge(type: _appointment.type!)
                      else
                        _buildCategoryChip(),
                      AppointmentStatusBadge(status: _appointment.status),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Date et heure
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: DateFormat('EEEE d MMMM', 'fr_FR').format(_appointment.start),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.access_time,
                          label: 'Heure',
                          value: '${_formatTime(_appointment.start)} - ${_formatTime(_appointment.end)}',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Durée
                  _buildInfoCard(
                    icon: Icons.timelapse,
                    label: 'Durée',
                    value: '${_appointment.duration.inMinutes} minutes',
                    fullWidth: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Personne
            _buildSection(
              title: widget.isCoachView ? 'Client' : 'Coach',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _appointment.color.withOpacity(0.2),
                      child: Text(
                        _getDisplayName().isNotEmpty 
                            ? _getDisplayName().substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: _appointment.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getDisplayName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSubtitle(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Ouvrir le profil
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voir profil - DEMO')),
                        );
                      },
                      icon: const Icon(Icons.open_in_new, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Note
            _buildSection(
              title: 'Note',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ajouter une note...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _repository.updateAppointmentNote(_appointment.id, value);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            if (!isCancelled && !isPast) ...[
              // Modifier le RDV
              _buildActionButton(
                label: 'Modifier le RDV',
                icon: Icons.edit,
                color: const Color(0xFFFFC300),
                onTap: _showRescheduleDialog,
              ),
              
              const SizedBox(height: 12),
              
              // Confirmer (si en attente et vue coach)
              if (_appointment.status == AppointmentStatus.pending && widget.isCoachView) ...[
                _buildActionButton(
                  label: 'Confirmer le RDV',
                  icon: Icons.check_circle,
                  color: const Color(0xFF2ECC71),
                  onTap: () {
                    _repository.confirmAppointment(_appointment.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ RDV confirmé'),
                        backgroundColor: Color(0xFF2ECC71),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              
              // Annuler le RDV
              _buildActionButton(
                label: 'Annuler le RDV',
                icon: Icons.cancel,
                color: Colors.red,
                onTap: _showCancelDialog,
              ),
            ],
            
            // Marquer comme terminé (si passé et non annulé)
            if (isPast && !isCancelled && _appointment.status != AppointmentStatus.completed) ...[
              _buildActionButton(
                label: 'Marquer comme terminé',
                icon: Icons.done_all,
                color: const Color(0xFF2ECC71),
                onTap: () {
                  _repository.completeAppointment(_appointment.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ RDV marqué comme terminé'),
                      backgroundColor: Color(0xFF2ECC71),
                    ),
                  );
                },
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.6), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName() {
    if (widget.isCoachView) {
      return _appointment.clientName;
    }
    // Pour le client: afficher le nom du coach ou le titre de la séance
    return _appointment.coachName ?? _appointment.title ?? _appointment.displayName;
  }

  String _getSubtitle() {
    if (widget.isCoachView) {
      return 'Client';
    }
    switch (_appointment.category) {
      case SessionCategory.coach:
        return 'Coach fitness';
      case SessionCategory.solo:
        return 'Séance personnelle';
      case SessionCategory.group:
        return _appointment.location ?? 'Séance en groupe';
    }
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _appointment.category.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _appointment.category.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_appointment.category.icon, size: 16, color: _appointment.category.color),
          const SizedBox(width: 6),
          Text(
            _appointment.category.displayName,
            style: TextStyle(
              color: _appointment.category.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showRescheduleDialog() {
    DateTime newDate = _appointment.start;
    TimeOfDay newStartTime = TimeOfDay.fromDateTime(_appointment.start);
    
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
                'Reprogrammer le RDV',
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
                    initialDate: newDate,
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
                    setSheetState(() => newDate = date);
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
                          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(newDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.edit, color: Color(0xFFFFC300), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Sélection heure
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: newStartTime,
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
                  if (time != null) {
                    setSheetState(() => newStartTime = time);
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
                      const Icon(Icons.access_time, color: Colors.white54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.edit, color: Color(0xFFFFC300), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Bouton confirmer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newStart = DateTime(
                      newDate.year, newDate.month, newDate.day,
                      newStartTime.hour, newStartTime.minute,
                    );
                    final newEnd = newStart.add(_appointment.duration);
                    
                    _repository.rescheduleAppointment(
                      _appointment.id, newStart, newEnd,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ RDV reprogrammé'),
                        backgroundColor: Color(0xFF2ECC71),
                      ),
                    );
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
                    'Confirmer',
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Annuler le RDV ?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Voulez-vous vraiment annuler ce rendez-vous avec ${widget.isCoachView ? _appointment.clientName : _appointment.coachName} ?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              _repository.cancelAppointment(_appointment.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ RDV annulé'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

