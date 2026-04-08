import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_session.dart';
import '../models/workout_session_storage.dart';
import 'workout_session_detail_page.dart';

class WorkoutHistoryCalendarPage extends StatefulWidget {
  final bool embedInTab;
  const WorkoutHistoryCalendarPage({super.key, this.embedInTab = false});

  @override
  State<WorkoutHistoryCalendarPage> createState() => _WorkoutHistoryCalendarPageState();
}

class _WorkoutHistoryCalendarPageState extends State<WorkoutHistoryCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _filterMode = 'Toutes'; // 'Toutes', 'Mois', 'Années'
  List<WorkoutSession> _allSessions = [];
  Map<DateTime, List<WorkoutSession>> _sessionsByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });
    final sessions = await WorkoutSessionStorage.getAllSessions();
    setState(() {
      _allSessions = sessions;
      _sessionsByDate = _groupSessionsByDate(sessions);
      _isLoading = false;
    });
  }

  Map<DateTime, List<WorkoutSession>> _groupSessionsByDate(List<WorkoutSession> sessions) {
    final Map<DateTime, List<WorkoutSession>> grouped = {};
    for (final session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      grouped.putIfAbsent(date, () => []).add(session);
    }
    return grouped;
  }

  List<WorkoutSession> _getSessionsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _sessionsByDate[date] ?? [];
  }

  List<WorkoutSession> _getFilteredSessions() {
    switch (_filterMode) {
      case 'Mois':
        final now = DateTime.now();
        return _allSessions.where((s) {
          return s.startTime.year == now.year && s.startTime.month == now.month;
        }).toList();
      case 'Années':
        final now = DateTime.now();
        return _allSessions.where((s) => s.startTime.year == now.year).toList();
      default:
        return _allSessions;
    }
  }

  Widget _buildBody() {
    return Container(
      color: const Color(0xFF121212), // Fond sombre
      child: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Titre
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: const Text(
                      'Photothèque',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Filtres temporels
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFF1A1A1A),
                    child: Row(
                      children: [
                        Icon(Icons.swap_vert, size: 20, color: Colors.white.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        _FilterButton(
                          label: 'Années',
                          isSelected: _filterMode == 'Années',
                          onTap: () {
                            setState(() {
                              _filterMode = 'Années';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterButton(
                          label: 'Mois',
                          isSelected: _filterMode == 'Mois',
                          onTap: () {
                            setState(() {
                              _filterMode = 'Mois';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterButton(
                          label: 'Toutes',
                          isSelected: _filterMode == 'Toutes',
                          onTap: () {
                            setState(() {
                              _filterMode = 'Toutes';
                            });
                          },
                        ),
                        const Spacer(),
                        if (!widget.embedInTab)
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                      ],
                    ),
                  ),
                  // Calendrier simplifié
                  Flexible(
                    child: SingleChildScrollView(
                      child: _buildSimpleCalendar(),
                    ),
                  ),
                  // Liste des séances du jour sélectionné
                  Expanded(
                    child: _buildDaySessionsList(),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    if (widget.embedInTab) {
      return body;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Photothèque',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildSimpleCalendar() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-tête avec navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.white.withOpacity(0.7)),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy', 'fr_FR').format(_focusedDay),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Jours de la semaine
          Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Grille du calendrier
          ...List.generate(6, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstDayWeekday + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                final day = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
                final isSelected = _selectedDay.year == day.year &&
                    _selectedDay.month == day.month &&
                    _selectedDay.day == day.day;
                final isToday = now.year == day.year &&
                    now.month == day.month &&
                    now.day == day.day;
                final hasSessions = _getSessionsForDay(day).isNotEmpty;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF007AFF)
                            : isToday
                                ? const Color(0xFF007AFF).withOpacity(0.3)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? const Color(0xFF007AFF)
                                      : Colors.white.withOpacity(0.9),
                            ),
                          ),
                          if (hasSessions && !isSelected)
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDaySessionsList() {
    final sessions = _getSessionsForDay(_selectedDay);
    final filteredSessions = _getFilteredSessions();

    return Container(
      color: const Color(0xFF121212),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carnet du ${DateFormat('dd/MM/yyyy', 'fr_FR').format(_selectedDay)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Aucune séance enregistrée ce jour',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${sessions.length} séance${sessions.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune séance ce jour',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color(0xFF1A1A1A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WorkoutSessionDetailPage(session: session),
                              ),
                            );
                            _loadSessions();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.name ?? 'Séance du ${DateFormat('dd/MM/yyyy').format(session.startTime)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateFormat('HH:mm').format(session.startTime)} - ${session.endTime != null ? DateFormat('HH:mm').format(session.endTime!) : 'En cours'}',
                                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${session.exercises.length} exercices • ${session.totalVolume.toStringAsFixed(0)} kg de volume total',
                                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007AFF).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF007AFF)
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

