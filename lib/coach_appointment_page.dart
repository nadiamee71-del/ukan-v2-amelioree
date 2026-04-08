import 'package:flutter/material.dart';
import 'models/planning.dart';
import 'models/coach_directory.dart';
import 'models/user_profile.dart';

/// Page pour créer et gérer les rendez-vous avec un coach
class CoachAppointmentPage extends StatefulWidget {
  final String coachId;
  final String? clientId; // ID du client (utilisateur actuel)

  const CoachAppointmentPage({
    super.key,
    required this.coachId,
    this.clientId,
  });

  @override
  State<CoachAppointmentPage> createState() => _CoachAppointmentPageState();
}

class _CoachAppointmentPageState extends State<CoachAppointmentPage> {
  final _planningNotifier = PlanningNotifier();
  final _coachNotifier = CoachDirectoryNotifier();
  final _userProfileNotifier = UserProfileNotifier();
  
  late DateTime _selectedDay;
  AppointmentType? _selectedAppointmentType;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Pour la création de rendez-vous
  DateTime? _selectedDateTime;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _planningNotifier.addListener(_onChanged);
  }

  @override
  void dispose() {
    _planningNotifier.removeListener(_onChanged);
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _showCreateAppointmentDialog() {
    _selectedDateTime = null;
    _selectedTime = TimeOfDay.now();
    _selectedAppointmentType = null;
    _addressController.clear();
    _notesController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Nouveau rendez-vous',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDay,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        _selectedDateTime = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.black54),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDateTime != null
                              ? _formatDate(_selectedDateTime!)
                              : 'Sélectionner une date',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Heure
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() {
                        _selectedTime = time;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.black54),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime != null
                              ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                              : 'Sélectionner une heure',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Type de rendez-vous
                const Text(
                  'Type de rendez-vous',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setDialogState(() {
                            _selectedAppointmentType = AppointmentType.visio;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedAppointmentType == AppointmentType.visio
                                ? const Color(0xFFFFC300).withOpacity(0.2)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedAppointmentType == AppointmentType.visio
                                  ? const Color(0xFFFFC300)
                                  : Colors.grey.shade300,
                              width: _selectedAppointmentType == AppointmentType.visio ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.videocam,
                                color: _selectedAppointmentType == AppointmentType.visio
                                    ? const Color(0xFFFFC300)
                                    : Colors.grey.shade600,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Visio',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedAppointmentType == AppointmentType.visio
                                      ? Colors.black
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setDialogState(() {
                            _selectedAppointmentType = AppointmentType.presentiel;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedAppointmentType == AppointmentType.presentiel
                                ? const Color(0xFFFFC300).withOpacity(0.2)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedAppointmentType == AppointmentType.presentiel
                                  ? const Color(0xFFFFC300)
                                  : Colors.grey.shade300,
                              width: _selectedAppointmentType == AppointmentType.presentiel ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: _selectedAppointmentType == AppointmentType.presentiel
                                    ? const Color(0xFFFFC300)
                                    : Colors.grey.shade600,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Présentiel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedAppointmentType == AppointmentType.presentiel
                                      ? Colors.black
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Adresse (si présentiel)
                if (_selectedAppointmentType == AppointmentType.presentiel) ...[
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Adresse du rendez-vous',
                      hintText: 'Ex: 123 Rue de la Forme, Paris',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.location_on, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (optionnel)',
                    hintText: 'Ajouter des notes...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedDateTime == null || _selectedTime == null || _selectedAppointmentType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs obligatoires'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (_selectedAppointmentType == AppointmentType.presentiel && 
                    _addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez saisir une adresse pour un rendez-vous présentiel'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final dateTime = DateTime(
                  _selectedDateTime!.year,
                  _selectedDateTime!.month,
                  _selectedDateTime!.day,
                  _selectedTime!.hour,
                  _selectedTime!.minute,
                );

                final coach = _coachNotifier.getCoachById(widget.coachId);
                final clientId = widget.clientId ?? _userProfileNotifier.profile.email ?? 'client_default';

                final appointment = PlannedSession(
                  id: 'appt_${DateTime.now().microsecondsSinceEpoch}',
                  dateTime: dateTime,
                  title: 'Rendez-vous avec ${coach?.name ?? "Coach"}',
                  type: PlannedSessionType.coach,
                  status: PlannedSessionStatus.planned,
                  coachId: widget.coachId,
                  clientId: clientId,
                  appointmentType: _selectedAppointmentType,
                  address: _selectedAppointmentType == AppointmentType.presentiel
                      ? _addressController.text.trim()
                      : null,
                  videoLink: _selectedAppointmentType == AppointmentType.visio
                      ? 'https://meet.ukan.app/${widget.coachId}_${dateTime.millisecondsSinceEpoch}'
                      : null,
                  notes: _notesController.text.trim().isNotEmpty
                      ? _notesController.text.trim()
                      : null,
                );

                _planningNotifier.addSession(appointment);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Rendez-vous créé avec succès !'),
                    backgroundColor: const Color(0xFFFFC300),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Créer',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coach = _coachNotifier.getCoachById(widget.coachId);
    final clientId = widget.clientId ?? _userProfileNotifier.profile.email ?? 'client_default';
    final appointments = _planningNotifier.appointmentsForClient(clientId)
        .where((a) => a.coachId == widget.coachId)
        .toList();

    final monday = _getMondayOfWeek(_selectedDay);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          coach != null ? 'Planning avec ${coach.name}' : 'Planning',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bandeau semaine
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Semaine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final day = monday.add(Duration(days: index));
                    final dayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                    final isSelected = day.year == _selectedDay.year &&
                        day.month == _selectedDay.month &&
                        day.day == _selectedDay.day;
                    final hasAppointment = appointments.any((a) =>
                        a.dateTime.year == day.year &&
                        a.dateTime.month == day.month &&
                        a.dateTime.day == day.day);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = day;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black
                              : hasAppointment
                                  ? const Color(0xFFFFC300).withOpacity(0.1)
                                  : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : hasAppointment
                                    ? const Color(0xFFFFC300)
                                    : Colors.grey.shade300,
                            width: isSelected || hasAppointment ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayLetters[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (hasAppointment)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFC300),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Liste des rendez-vous
          Expanded(
            child: appointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun rendez-vous',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Créez votre premier rendez-vous',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Rendez-vous du ${_formatDate(_selectedDay)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...appointments
                          .where((a) =>
                              a.dateTime.year == _selectedDay.year &&
                              a.dateTime.month == _selectedDay.month &&
                              a.dateTime.day == _selectedDay.day)
                          .map((appointment) => _AppointmentCard(
                                appointment: appointment,
                                coach: coach,
                                formatTime: _formatTime,
                                onUpdate: () {
                                  setState(() {});
                                },
                              ))
                          .toList(),
                    ],
                  ),
          ),

          // Bouton créer rendez-vous
          Container(
            padding: const EdgeInsets.all(20),
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
                child: ElevatedButton.icon(
                  onPressed: _showCreateAppointmentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau rendez-vous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC300),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final PlannedSession appointment;
  final CoachProfile? coach;
  final String Function(DateTime) formatTime;
  final VoidCallback onUpdate;

  const _AppointmentCard({
    required this.appointment,
    this.coach,
    required this.formatTime,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final planningNotifier = PlanningNotifier();
    final isPast = appointment.dateTime.isBefore(DateTime.now());
    final isVisio = appointment.appointmentType == AppointmentType.visio;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVisio
              ? const Color(0xFFFFC300).withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  formatTime(appointment.dateTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isVisio
                      ? const Color(0xFFFFC300).withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVisio ? Icons.videocam : Icons.location_on,
                      size: 16,
                      color: isVisio ? const Color(0xFFFFC300) : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVisio ? 'Visio' : 'Présentiel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isVisio ? Colors.black87 : Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appointment.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          if (appointment.address != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    appointment.address!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (appointment.videoLink != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // TODO: Ouvrir le lien visio
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lien visio: ${appointment.videoLink}'),
                    backgroundColor: const Color(0xFFFFC300),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.videocam, size: 16, color: const Color(0xFFFFC300)),
                  const SizedBox(width: 4),
                  Text(
                    'Rejoindre la visio',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFC300),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                appointment.notes!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (!isPast && appointment.status == PlannedSessionStatus.planned) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      planningNotifier.updateStatus(
                        appointment.id,
                        PlannedSessionStatus.cancelled,
                      );
                      onUpdate();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

