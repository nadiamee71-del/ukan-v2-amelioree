/// Vue calendrier pour les rendez-vous
/// Ukan - Planning Coach/Client

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_models.dart';
import 'appointments_repository.dart';
import 'appointment_type_badge.dart';
import 'appointment_details_view.dart';
import 'add_session_page.dart';

class AppointmentsCalendarView extends StatefulWidget {
  final bool isCoachView;
  final String? specificUserId;

  const AppointmentsCalendarView({
    super.key,
    this.isCoachView = false,
    this.specificUserId,
  });

  @override
  State<AppointmentsCalendarView> createState() => _AppointmentsCalendarViewState();
}

class _AppointmentsCalendarViewState extends State<AppointmentsCalendarView> {
  final _repository = AppointmentsRepository();
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDay = DateTime.now();
    _repository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Calendrier
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Calendrier mensuel
                  _buildCalendar(),
                  
                  const SizedBox(height: 20),
                  
                  // RDV du jour sélectionné
                  _buildDayAppointments(),
                  
                  const SizedBox(height: 80), // Espace pour le FAB
                ],
              ),
            ),
          ),
        ],
      ),
      // Bouton + pour ajouter une séance (client uniquement)
      floatingActionButton: !widget.isCoachView
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddSessionPage(initialDate: _selectedDay),
                  ),
                ).then((_) => setState(() {})); // Rafraîchir après ajout
              },
              backgroundColor: const Color(0xFFFFC300),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text(
                'Nouvelle séance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Color(0xFFFFC300),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isCoachView ? 'Mon Planning Coach' : 'Mes Rendez-vous',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getSubtitle(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Bouton aujourd'hui
            GestureDetector(
              onTap: () {
                setState(() {
                  _focusedMonth = DateTime.now();
                  _selectedDay = DateTime.now();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC300).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Aujourd'hui",
                  style: TextStyle(
                    color: Color(0xFFFFC300),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle() {
    final appointments = _getAppointmentsForUser();
    final upcoming = appointments.where((a) => 
        a.start.isAfter(DateTime.now()) && 
        a.status != AppointmentStatus.cancelled
    ).length;
    return '$upcoming RDV à venir';
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    final now = DateTime.now();
    
    final totalCells = firstDayWeekday - 1 + daysInMonth;
    final weeksNeeded = (totalCells / 7).ceil();

    final weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    
    // Obtenir les RDV du mois
    final monthAppointments = _repository.getAppointmentsForMonth(
      _focusedMonth.year,
      _focusedMonth.month,
      userId: widget.specificUserId ?? _repository.currentUserId,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E2E),
            const Color(0xFF161622),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header navigation mois
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFC300).withOpacity(0.15),
                  const Color(0xFFFF8C00).withOpacity(0.08),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: () {
                    setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMMM', 'fr_FR').format(_focusedMonth).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFC300),
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '${_focusedMonth.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: () {
                    setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Jours de la semaine
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Row(
              children: List.generate(7, (index) {
                final isWeekend = index >= 5;
                return Expanded(
                  child: Center(
                    child: Text(
                      weekDays[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isWeekend 
                            ? const Color(0xFFFFC300).withOpacity(0.8)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Grille des jours
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Column(
              children: List.generate(weeksNeeded, (weekIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: List.generate(7, (dayIndex) {
                      final dayNumber = weekIndex * 7 + dayIndex - firstDayWeekday + 2;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return Expanded(child: Container(height: 50));
                      }
                      
                      final day = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                      final isSelected = _isSameDay(_selectedDay, day);
                      final isToday = _isSameDay(now, day);
                      final dayKey = DateTime(day.year, day.month, day.day);
                      final dayAppointments = monthAppointments[dayKey] ?? [];
                      final hasAppointments = dayAppointments.isNotEmpty;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedDay = day);
                          },
                          child: Container(
                            height: 50,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFFC300), Color(0xFFFF9500)],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isToday && !isSelected
                                    ? const Color(0xFFFFC300)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected || isToday 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                    color: isSelected 
                                        ? Colors.black 
                                        : Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                if (hasAppointments)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: dayAppointments.take(3).map((appt) {
                                        return Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? Colors.black.withOpacity(0.5)
                                                : appt.color,
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
          
          // Légende
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AppointmentType.values.map((type) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: type.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
      ),
    );
  }

  Widget _buildDayAppointments() {
    final appointments = _getAppointmentsForSelectedDay();
    final dateStr = DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header du jour
        Row(
          children: [
            Text(
              dateStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${appointments.length} RDV',
                style: const TextStyle(
                  color: Color(0xFFFFC300),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Liste des RDV
        if (appointments.isEmpty)
          _buildEmptyState()
        else
          ...appointments.map((appt) => AppointmentCard(
            appointment: appt,
            isCoachView: widget.isCoachView,
            onTap: () => _showAppointmentDetails(appt),
            onConfirm: widget.isCoachView && appt.status == AppointmentStatus.pending
                ? () => _repository.confirmAppointment(appt.id)
                : null,
            onCancel: widget.isCoachView && appt.status == AppointmentStatus.pending
                ? () => _repository.cancelAppointment(appt.id)
                : null,
          )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
            'Aucun rendez-vous',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pas de RDV prévu ce jour',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  List<Appointment> _getAppointmentsForUser() {
    final userId = widget.specificUserId ?? _repository.currentUserId;
    if (widget.isCoachView) {
      return _repository.getAppointmentsForCoach(userId);
    } else {
      return _repository.getAppointmentsForClient(userId);
    }
  }

  List<Appointment> _getAppointmentsForSelectedDay() {
    final userId = widget.specificUserId ?? _repository.currentUserId;
    if (widget.isCoachView) {
      return _repository.getAppointmentsForDay(_selectedDay, coachId: userId);
    } else {
      return _repository.getAppointmentsForDay(_selectedDay, clientId: userId);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAppointmentDetails(Appointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailsView(
          appointment: appointment,
          isCoachView: widget.isCoachView,
        ),
      ),
    );
  }
}

