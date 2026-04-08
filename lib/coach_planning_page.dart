import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/planning.dart';
import 'models/theme_notifier.dart';
import 'coach_clients_page.dart';
import 'coach_client_detail_page.dart';

enum CoachPlanningViewMode { day, week, month }

class CoachPlanningPage extends StatefulWidget {
  final String coachId; // ID du coach actuel

  const CoachPlanningPage({
    super.key,
    required this.coachId,
  });

  @override
  State<CoachPlanningPage> createState() => _CoachPlanningPageState();
}

class _CoachPlanningPageState extends State<CoachPlanningPage> with SingleTickerProviderStateMixin {
  final _planningNotifier = PlanningNotifier();
  late DateTime _selectedDay;
  late DateTime _selectedMonth;
  CoachPlanningViewMode _viewMode = CoachPlanningViewMode.week;
  late TabController _tabController;
  
  // Liste des clients/abonnés (demo)
  final List<CoachClient> _clients = [
    const CoachClient(
      id: 'sarah',
      name: 'Sarah',
      age: 29,
      goal: 'Perte de poids',
      sessionsPerWeek: 3,
      level: 'Intermédiaire',
      currentWeight: 72,
      targetWeight: 65,
      status: 'Actif',
    ),
    const CoachClient(
      id: 'mehdi',
      name: 'Mehdi',
      age: 26,
      goal: 'Prise de masse',
      sessionsPerWeek: 4,
      level: 'Intermédiaire',
      currentWeight: 70,
      targetWeight: 78,
      status: 'Actif',
    ),
    const CoachClient(
      id: 'lina',
      name: 'Lina',
      age: 34,
      goal: 'Remise en forme',
      sessionsPerWeek: 2,
      level: 'Débutante',
      currentWeight: 60,
      targetWeight: 58,
      status: 'Actif',
    ),
    const CoachClient(
      id: 'alex',
      name: 'Alex',
      age: 31,
      goal: 'Perte de poids',
      sessionsPerWeek: 3,
      level: 'Avancé',
      currentWeight: 85,
      targetWeight: 75,
      status: 'En pause',
    ),
    const CoachClient(
      id: 'marie',
      name: 'Marie',
      age: 28,
      goal: 'Prise de masse',
      sessionsPerWeek: 5,
      level: 'Avancé',
      currentWeight: 65,
      targetWeight: 72,
      status: 'Nouveau',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _selectedMonth = DateTime(now.year, now.month, 1);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _viewMode = CoachPlanningViewMode.values[_tabController.index];
      });
    });
    _planningNotifier.addListener(_onChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _planningNotifier.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusLabel(PlannedSessionStatus status) {
    switch (status) {
      case PlannedSessionStatus.planned:
        return 'Prévu';
      case PlannedSessionStatus.done:
        return 'Terminé';
      case PlannedSessionStatus.cancelled:
        return 'Annulé';
    }
  }

  Color _getStatusColor(PlannedSessionStatus status) {
    switch (status) {
      case PlannedSessionStatus.planned:
        return Colors.grey.shade600;
      case PlannedSessionStatus.done:
        return Colors.green.shade600;
      case PlannedSessionStatus.cancelled:
        return Colors.red.shade600;
    }
  }

  String? _getClientName(String? clientId) {
    if (clientId == null) return null;
    final client = _clients.firstWhere(
      (c) => c.id == clientId,
      orElse: () => const CoachClient(
        id: '',
        name: 'Client',
        age: 0,
        goal: '',
        sessionsPerWeek: 0,
        level: '',
        currentWeight: 0,
        targetWeight: 0,
      ),
    );
    return client.name;
  }

  CoachClient? _getClientById(String? clientId) {
    if (clientId == null) return null;
    try {
      return _clients.firstWhere((c) => c.id == clientId);
    } catch (e) {
      return null;
    }
  }

  List<PlannedSession> _getCoachSessionsForDay(DateTime day) {
    return _planningNotifier.appointmentsWithCoach(widget.coachId)
        .where((s) =>
            s.dateTime.year == day.year &&
            s.dateTime.month == day.month &&
            s.dateTime.day == day.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode 
          ? const Color(0xFF0A0E27)
          : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC300),
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mon Planning Coach'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.black87, size: 28),
            onPressed: _showAddSessionBottomSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                // Section Liste des abonnés (déroulante)
                ExpansionTile(
                  title: Row(
                    children: [
                      const Icon(Icons.people, color: Color(0xFFFFC300)),
                      const SizedBox(width: 8),
                      Text(
                        'Mes abonnés (${_clients.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.grey.shade100,
                  collapsedBackgroundColor: Colors.grey.shade100,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _clients.length,
                        itemBuilder: (context, index) {
                          final client = _clients[index];
                          return _ClientListItem(
                            client: client,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CoachClientDetailPage(client: client),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Tabs stylisés
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFFFFC300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelColor: Colors.black87,
                    unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black87,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Jour'),
                      Tab(text: 'Semaine'),
                      Tab(text: 'Mois'),
                    ],
                  ),
                ),
                // Contenu selon la vue
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayView() {
    final sessions = _getCoachSessionsForDay(_selectedDay);
    final isToday = _selectedDay.year == DateTime.now().year &&
        _selectedDay.month == DateTime.now().month &&
        _selectedDay.day == DateTime.now().day;
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF0A0E27),
                  const Color(0xFF1A1A2E).withOpacity(0.8),
                ]
              : [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
        ),
      ),
      child: Column(
        children: [
          // Header date
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFC300),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE', 'fr_FR').format(_selectedDay),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDay),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black87.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: isDarkMode ? Colors.white : Colors.black87),
                      onPressed: () {
                        setState(() {
                          _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = DateTime.now();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isToday ? const Color(0xFFFFC300) : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isToday ? "Aujourd'hui" : 'Aller à aujourd\'hui',
                          style: TextStyle(
                            color: isToday ? Colors.black87 : (isDarkMode ? Colors.white : Colors.black87),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: isDarkMode ? Colors.white : Colors.black87),
                      onPressed: () {
                        setState(() {
                          _selectedDay = _selectedDay.add(const Duration(days: 1));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Liste des séances
          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 80,
                          color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black87.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune séance prévue',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black87.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final client = _getClientById(session.clientId);
                      return _CoachSessionCard(
                        session: session,
                        client: client,
                        formatTime: _formatTime,
                        getStatusLabel: _getStatusLabel,
                        getStatusColor: _getStatusColor,
                        onTap: () {
                          if (client != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CoachClientDetailPage(client: client),
                              ),
                            );
                          }
                        },
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final monday = _getMondayOfWeek(_selectedDay);
    final weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF0A0E27),
                  const Color(0xFF1A1A2E).withOpacity(0.8),
                ]
              : [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
        ),
      ),
      child: Column(
        children: [
          // Navigation semaine
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFC300),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: isDarkMode ? Colors.white : Colors.black87),
                  onPressed: () {
                    setState(() {
                      _selectedDay = _selectedDay.subtract(const Duration(days: 7));
                    });
                  },
                ),
                Text(
                  'Semaine du ${_formatDateShort(monday)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: isDarkMode ? Colors.white : Colors.black87),
                  onPressed: () {
                    setState(() {
                      _selectedDay = _selectedDay.add(const Duration(days: 7));
                    });
                  },
                ),
              ],
            ),
          ),
          // En-têtes des jours
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black87.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Grille du calendrier semaine
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final isToday = day.year == DateTime.now().year &&
                    day.month == DateTime.now().month &&
                    day.day == DateTime.now().day;
                final isSelected = day.year == _selectedDay.year &&
                    day.month == _selectedDay.month &&
                    day.day == _selectedDay.day;
                final daySessions = _getCoachSessionsForDay(day);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFC300),
                                Color(0xFFFFD700),
                              ],
                            )
                          : isToday
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFFC300).withOpacity(0.3),
                                    const Color(0xFFFFD700).withOpacity(0.2),
                                  ],
                                )
                              : null,
                      color: isSelected || isToday ? null : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFC300)
                            : isToday
                                ? const Color(0xFFFFC300).withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.black87
                                : (isDarkMode ? Colors.white : Colors.black87),
                          ),
                        ),
                        if (daySessions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              daySessions.length > 3 ? 3 : daySessions.length,
                              (i) => Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black87
                                      : const Color(0xFFFFC300),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Séances du jour sélectionné
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_getCoachSessionsForDay(_selectedDay).isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFC300),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Séances du ${_formatDateShort(_selectedDay)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._getCoachSessionsForDay(_selectedDay).map((session) {
                            final client = _getClientById(session.clientId);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _CoachSessionCard(
                                session: session,
                                client: client,
                                formatTime: _formatTime,
                                getStatusLabel: _getStatusLabel,
                                getStatusColor: _getStatusColor,
                                onTap: () {
                                  if (client != null) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CoachClientDetailPage(client: client),
                                      ),
                                    );
                                  }
                                },
                                isDarkMode: isDarkMode,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstMonday = _getMondayOfWeek(firstDayOfMonth);
    final days = List.generate(35, (index) => firstMonday.add(Duration(days: index)));
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF0A0E27),
                  const Color(0xFF1A1A2E).withOpacity(0.8),
                ]
              : [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
        ),
      ),
      child: Column(
        children: [
          // Navigation mois
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFC300),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: isDarkMode ? Colors.white : Colors.black87),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(_selectedMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: isDarkMode ? Colors.white : Colors.black87),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
          ),
          // En-têtes des jours
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black87.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Grille du calendrier
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 35,
              itemBuilder: (context, index) {
                final day = days[index];
                final isCurrentMonth = day.month == _selectedMonth.month;
                final isToday = day.year == DateTime.now().year &&
                    day.month == DateTime.now().month &&
                    day.day == DateTime.now().day;
                final isSelected = day.year == _selectedDay.year &&
                    day.month == _selectedDay.month &&
                    day.day == _selectedDay.day;
                final daySessions = _getCoachSessionsForDay(day);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                      _selectedMonth = DateTime(day.year, day.month, 1);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFC300),
                                Color(0xFFFFD700),
                              ],
                            )
                          : isToday
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFFC300).withOpacity(0.3),
                                    const Color(0xFFFFD700).withOpacity(0.2),
                                  ],
                                )
                              : null,
                      color: isSelected || isToday ? null : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFC300)
                            : isToday
                                ? const Color(0xFFFFC300).withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.black87
                                : isCurrentMonth
                                    ? (isDarkMode ? Colors.white : Colors.black87)
                                    : (isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black87.withOpacity(0.3)),
                          ),
                        ),
                        if (daySessions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: daySessions.take(3).map((session) {
                              return Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(session.status),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Liste des séances du jour sélectionné
          if (_getCoachSessionsForDay(_selectedDay).isNotEmpty) ...[
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFC300),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Séances du ${_formatDateShort(_selectedDay)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._getCoachSessionsForDay(_selectedDay).map((session) {
                        final client = _getClientById(session.clientId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _CoachSessionCard(
                            session: session,
                            client: client,
                            formatTime: _formatTime,
                            getStatusLabel: _getStatusLabel,
                            getStatusColor: _getStatusColor,
                            onTap: () {
                              if (client != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CoachClientDetailPage(client: client),
                                  ),
                                );
                              }
                            },
                            isDarkMode: isDarkMode,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddSessionBottomSheet() {
    // TODO: Implémenter l'ajout de séance pour le coach
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir : Ajouter une séance'),
        backgroundColor: Color(0xFFFFC300),
      ),
    );
  }
}

// Widget pour afficher un client dans la liste déroulante
class _ClientListItem extends StatelessWidget {
  final CoachClient client;
  final VoidCallback onTap;

  const _ClientListItem({
    required this.client,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  client.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    client.goal,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher une carte de séance coach
class _CoachSessionCard extends StatelessWidget {
  final PlannedSession session;
  final CoachClient? client;
  final String Function(DateTime) formatTime;
  final String Function(PlannedSessionStatus) getStatusLabel;
  final Color Function(PlannedSessionStatus) getStatusColor;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _CoachSessionCard({
    required this.session,
    required this.client,
    required this.formatTime,
    required this.getStatusLabel,
    required this.getStatusColor,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFC300),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatTime(session.dateTime),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client?.name ?? session.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (client != null)
                    Text(
                      client!.goal,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor(session.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: getStatusColor(session.status),
                  width: 1,
                ),
              ),
              child: Text(
                getStatusLabel(session.status),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: getStatusColor(session.status),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

