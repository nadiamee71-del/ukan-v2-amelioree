/// Planning Client Unifié - Ukan
/// Fusionne le système de RDV et les séances personnelles
/// Distinction claire : PERSO (bleu) / COACH (jaune) / GROUPE (violet)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'appointment_models.dart';
import 'appointments_repository.dart';
import 'add_session_page.dart';
import 'appointment_details_view.dart';

class UnifiedPlanningPage extends StatefulWidget {
  final bool isCoachView;
  final String? clientId; // Pour vue coach sur un client spécifique
  
  const UnifiedPlanningPage({
    super.key,
    this.isCoachView = false,
    this.clientId,
  });

  @override
  State<UnifiedPlanningPage> createState() => _UnifiedPlanningPageState();
}

class _UnifiedPlanningPageState extends State<UnifiedPlanningPage> 
    with SingleTickerProviderStateMixin {
  final _repository = AppointmentsRepository();
  late TabController _tabController;
  late DateTime _selectedDay;
  late DateTime _selectedMonth;
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _selectedMonth = DateTime(now.year, now.month, 1);
    _tabController = TabController(length: 3, vsync: this);
    _repository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<Appointment> get _appointments {
    final userId = widget.clientId ?? _repository.currentUserId;
    if (widget.isCoachView && widget.clientId == null) {
      return _repository.getAppointmentsForCoach(userId);
    }
    return _repository.getAppointmentsForClient(userId);
  }

  List<Appointment> _appointmentsForDay(DateTime day) {
    return _appointments.where((a) =>
      a.start.year == day.year &&
      a.start.month == day.month &&
      a.start.day == day.day
    ).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Onglets Jour / Semaine / Mois
          _buildTabBar(),
          
          // Contenu selon l'onglet
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDayView(),
                _buildWeekView(),
                _buildMonthView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !widget.isCoachView ? _buildFAB() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final upcoming = _appointments.where((a) => 
      a.start.isAfter(DateTime.now()) && 
      a.status != AppointmentStatus.cancelled
    ).length;
    
    return AppBar(
      backgroundColor: const Color(0xFF1A1A2E),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isCoachView ? 'Planning Coach' : 'Mon Planning',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$upcoming séances à venir',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
      actions: [
        // Bouton aujourd'hui
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              final now = DateTime.now();
              _selectedDay = DateTime(now.year, now.month, now.day);
              _selectedMonth = DateTime(now.year, now.month, 1);
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
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
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC300), Color(0xFFFF9500)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Jour'),
          Tab(text: 'Semaine'),
          Tab(text: 'Mois'),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddSessionPage(initialDate: _selectedDay),
          ),
        ).then((_) => setState(() {}));
      },
      backgroundColor: const Color(0xFFFFC300),
      foregroundColor: Colors.black,
      icon: const Icon(Icons.add),
      label: const Text(
        'Nouvelle séance',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VUE JOUR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDayView() {
    final dayAppointments = _appointmentsForDay(_selectedDay);
    final isToday = _isSameDay(_selectedDay, DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header date avec navigation
          _buildDayHeader(isToday),
          
          const SizedBox(height: 20),
          
          // Légende des types
          _buildLegend(),
          
          const SizedBox(height: 20),
          
          // Liste des séances
          if (dayAppointments.isEmpty)
            _buildEmptyState()
          else
            ...dayAppointments.map((appt) => _AppointmentCard(
              appointment: appt,
              isCoachView: widget.isCoachView,
              onTap: () => _showDetails(appt),
              onConfirm: widget.isCoachView && appt.status == AppointmentStatus.pending
                  ? () => _repository.confirmAppointment(appt.id)
                  : null,
              onCancel: widget.isCoachView && appt.status == AppointmentStatus.pending
                  ? () => _repository.cancelAppointment(appt.id)
                  : null,
              onComplete: appt.status == AppointmentStatus.confirmed
                  ? () => _repository.completeAppointment(appt.id)
                  : null,
            )),
        ],
      ),
    );
  }

  Widget _buildDayHeader(bool isToday) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC300).withOpacity(0.15),
            const Color(0xFFFF9500).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC300).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Infos date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE', 'fr_FR').format(_selectedDay).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFC300),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "AUJOURD'HUI",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Navigation
          Row(
            children: [
              _buildDayNavButton(
                icon: Icons.chevron_left,
                onTap: () {
                  setState(() {
                    _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildDayNavButton(
                icon: Icons.chevron_right,
                onTap: () {
                  setState(() {
                    _selectedDay = _selectedDay.add(const Duration(days: 1));
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VUE SEMAINE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWeekView() {
    final monday = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        children: [
          // Navigation semaine
          _buildWeekHeader(monday),
          
          const SizedBox(height: 16),
          
          // Grille des 7 jours
          Row(
            children: weekDays.map((day) => Expanded(
              child: _buildWeekDayCell(day),
            )).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Légende
          _buildLegend(),
          
          const SizedBox(height: 20),
          
          // Liste des séances du jour sélectionné
          _buildDaySessionsList(),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(DateTime monday) {
    final sunday = monday.add(const Duration(days: 6));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.subtract(const Duration(days: 7));
              });
            },
          ),
          Column(
            children: [
              const Text(
                'Semaine du',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
              Text(
                '${DateFormat('d MMM', 'fr_FR').format(monday)} - ${DateFormat('d MMM', 'fr_FR').format(sunday)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.add(const Duration(days: 7));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDayCell(DateTime day) {
    final isSelected = _isSameDay(_selectedDay, day);
    final isToday = _isSameDay(DateTime.now(), day);
    final dayAppts = _appointmentsForDay(day);
    final dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedDay = day);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFFC300), Color(0xFFFF9500)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday && !isSelected
                ? const Color(0xFFFFC300)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayNames[day.weekday - 1],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.white54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
            if (dayAppts.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dayAppts.take(3).map((a) => Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : a.category.color,
                    shape: BoxShape.circle,
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDaySessionsList() {
    final dayAppts = _appointmentsForDay(_selectedDay);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDay),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${dayAppts.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC300),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (dayAppts.isEmpty)
          _buildEmptyState()
        else
          ...dayAppts.map((appt) => _AppointmentCard(
            appointment: appt,
            isCoachView: widget.isCoachView,
            onTap: () => _showDetails(appt),
            compact: true,
          )),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VUE MOIS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMonthView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        children: [
          // Calendrier mensuel
          _buildMonthCalendar(),
          
          const SizedBox(height: 20),
          
          // Légende
          _buildLegend(),
          
          const SizedBox(height: 20),
          
          // Séances du jour
          _buildDaySessionsList(),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;
    
    final totalCells = firstWeekday - 1 + daysInMonth;
    final weeksNeeded = (totalCells / 7).ceil();
    
    final weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
          // Header mois
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFC300).withOpacity(0.15),
                  const Color(0xFFFF8C00).withOpacity(0.08),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                _buildMonthNavButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMMM', 'fr_FR').format(_selectedMonth).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFC300),
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '${_selectedMonth.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMonthNavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
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
                      final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 2;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return Expanded(child: Container(height: 50));
                      }
                      
                      final day = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                      return Expanded(
                        child: _buildMonthDayCell(day),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
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

  Widget _buildMonthDayCell(DateTime day) {
    final isSelected = _isSameDay(_selectedDay, day);
    final isToday = _isSameDay(DateTime.now(), day);
    final dayAppts = _appointmentsForDay(day);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
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
              '${day.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.white.withOpacity(0.9),
              ),
            ),
            if (dayAppts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dayAppts.take(3).map((appt) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black.withOpacity(0.5) : appt.category.color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGETS COMMUNS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: SessionCategory.values.map((cat) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: cat.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                cat == SessionCategory.solo 
                    ? 'PERSO' 
                    : cat == SessionCategory.coach 
                        ? 'COACH' 
                        : 'GROUPE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
            'Aucune séance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (!widget.isCoachView)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddSessionPage(initialDate: _selectedDay),
                  ),
                ).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.add, color: Color(0xFFFFC300)),
              label: const Text(
                'Planifier une séance',
                style: TextStyle(color: Color(0xFFFFC300)),
              ),
            ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showDetails(Appointment appointment) {
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

// ═══════════════════════════════════════════════════════════════════════════════
// CARTE DE RDV/SÉANCE
// ═══════════════════════════════════════════════════════════════════════════════

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isCoachView;
  final VoidCallback? onTap;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;
  final bool compact;

  const _AppointmentCard({
    required this.appointment,
    this.isCoachView = false,
    this.onTap,
    this.onConfirm,
    this.onCancel,
    this.onComplete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = '${appointment.start.hour.toString().padLeft(2, '0')}:${appointment.start.minute.toString().padLeft(2, '0')}';
    final category = appointment.category;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category.color.withOpacity(0.15),
              category.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: category.color.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Indicateur de catégorie
                Container(
                  width: 4,
                  height: compact ? 30 : 40,
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Icône catégorie
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: compact ? 18 : 22,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.displayName,
                        style: TextStyle(
                          fontSize: compact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          if (appointment.type != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              appointment.type!.icon,
                              size: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appointment.type!.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Badge catégorie
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category == SessionCategory.solo 
                        ? 'PERSO' 
                        : category == SessionCategory.coach 
                            ? 'COACH' 
                            : 'GROUPE',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            
            // Badge statut
            if (!compact && appointment.status != AppointmentStatus.confirmed)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: appointment.status.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: appointment.status.color.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            appointment.status.icon,
                            size: 12,
                            color: appointment.status.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.status.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: appointment.status.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Boutons d'action pour coach
            if (!compact && isCoachView && appointment.status == AppointmentStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onConfirm,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirmer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Refuser'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Bouton terminer pour client
            if (!compact && !isCoachView && appointment.status == AppointmentStatus.confirmed && onComplete != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Marquer comme terminé'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}





