/// Onglet Calendrier de la bibliothèque d'exercices Ukan
/// Affiche l'historique des entraînements, objectifs et rappels

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_models.dart';
import '../models/calendar_repository.dart';

class ExercisesCalendarTab extends StatefulWidget {
  const ExercisesCalendarTab({super.key});

  @override
  State<ExercisesCalendarTab> createState() => _ExercisesCalendarTabState();
}

class _ExercisesCalendarTabState extends State<ExercisesCalendarTab> {
  final _repository = ExercisesCalendarRepository();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
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
    return Container(
      color: const Color(0xFF121212),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // En-tête avec titre et bouton ajouter objectif
              _buildHeader(),
              
              // Calendrier mensuel
              _buildCalendarCompact(),
              
              // Panneau du jour sélectionné
              _buildDayPanelCompact(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCalendarCompact() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    final now = DateTime.now();
    
    // Calculer le nombre de semaines nécessaires
    final totalCells = firstDayWeekday - 1 + daysInMonth;
    final weeksNeeded = (totalCells / 7).ceil();

    // Noms des jours
    final weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HEADER DU CALENDRIER
          // ═══════════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
                // Bouton précédent
                _buildNavButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                    });
                  },
                ),
                
                // Mois et année
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _focusedDay = DateTime.now();
                        _selectedDay = DateTime.now();
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMMM', 'fr_FR').format(_focusedDay).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFC300),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_focusedDay.year}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bouton suivant
                _buildNavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
          ),
          
          // ═══════════════════════════════════════════════════════════════
          // JOURS DE LA SEMAINE
          // ═══════════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Row(
              children: List.generate(7, (index) {
                final isWeekend = index >= 5;
                return Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: isWeekend 
                            ? const Color(0xFFFFC300).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        weekDays[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isWeekend 
                              ? const Color(0xFFFFC300).withOpacity(0.8)
                              : Colors.white.withOpacity(0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Séparateur
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // ═══════════════════════════════════════════════════════════════
          // GRILLE DES JOURS
          // ═══════════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              children: List.generate(weeksNeeded, (weekIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: List.generate(7, (dayIndex) {
                      final dayNumber = weekIndex * 7 + dayIndex - firstDayWeekday + 2;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return Expanded(child: Container(height: 44));
                      }
                      
                      final day = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
                      final isSelected = _isSameDay(_selectedDay, day);
                      final isToday = _isSameDay(now, day);
                      final dayData = _repository.getDayData(day);
                      final hasExercises = dayData.hasExercises;
                      final hasGoals = dayData.hasGoals;
                      final isWeekend = dayIndex >= 5;
                      final isPast = day.isBefore(DateTime(now.year, now.month, now.day));

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedDay = day);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 44,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFC300),
                                        Color(0xFFFF9500),
                                      ],
                                    )
                                  : null,
                              color: isSelected 
                                  ? null
                                  : isToday
                                      ? const Color(0xFFFFC300).withOpacity(0.15)
                                      : hasExercises
                                          ? const Color(0xFF2ECC71).withOpacity(0.1)
                                          : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : isToday
                                        ? const Color(0xFFFFC300)
                                        : hasExercises
                                            ? const Color(0xFF2ECC71).withOpacity(0.3)
                                            : Colors.white.withOpacity(0.05),
                                width: isToday ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFFC300).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Numéro du jour
                                Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected || isToday || hasExercises
                                        ? FontWeight.w700 
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.black
                                        : isPast && !isToday
                                            ? Colors.white.withOpacity(0.4)
                                            : isWeekend
                                                ? Colors.white.withOpacity(0.7)
                                                : Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                
                                // Indicateurs en bas
                                if (hasExercises || hasGoals)
                                  Positioned(
                                    bottom: 4,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (hasExercises)
                                          Container(
                                            width: 16,
                                            height: 3,
                                            margin: const EdgeInsets.only(right: 2),
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? Colors.black.withOpacity(0.5)
                                                  : const Color(0xFF2ECC71),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        if (hasGoals)
                                          Container(
                                            width: 16,
                                            height: 3,
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? Colors.black.withOpacity(0.5)
                                                  : const Color(0xFFE74C3C),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  
                                // Badge "Aujourd'hui"
                                if (isToday && !isSelected)
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFC300),
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
                  ),
                );
              }),
            ),
          ),
          
          // ═══════════════════════════════════════════════════════════════
          // LÉGENDE
          // ═══════════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF2ECC71), 'Séance'),
                const SizedBox(width: 24),
                _buildLegendItem(const Color(0xFFE74C3C), 'Objectif'),
                const SizedBox(width: 24),
                _buildLegendItem(const Color(0xFFFFC300), "Aujourd'hui"),
              ],
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
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDayPanelCompact() {
    final dayData = _repository.getDayData(_selectedDay);
    final formattedDate = DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDay);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du panneau
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (dayData.hasData)
                        Text(
                          '${dayData.exercises.length} exercices • ${dayData.totalSets} séries',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Bouton ajouter mensurations
                GestureDetector(
                  onTap: () => _showAddMetricsDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.straighten,
                      color: Color(0xFF9C27B0),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (dayData.hasExercises && dayData.averageDifficulty != null)
                  _DifficultyBadge(difficulty: dayData.averageDifficulty!),
              ],
            ),
          ),
          
          const Divider(color: Colors.white12, height: 1),
          
          // Contenu
          if (dayData.hasData)
            _buildDayContentCompact(dayData)
          else
            _buildEmptyDayCompact(),
        ],
      ),
    );
  }
  
  Widget _buildDayContentCompact(CalendarDayData dayData) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Objectifs du jour
          if (dayData.hasGoals) ...[
            const _SectionTitle(title: '🎯 Objectifs', icon: Icons.flag),
            ...dayData.goals.map((goal) => _GoalCard(
              goal: goal,
              onTap: () => _showGoalDetail(context, goal),
            )),
            const SizedBox(height: 12),
          ],
          
          // Exercices du jour
          if (dayData.hasExercises) ...[
            const _SectionTitle(title: '💪 Exercices', icon: Icons.fitness_center),
            ...dayData.exercises.map((entry) => _ExerciseEntryCard(
              entry: entry,
              onEvaluateDifficulty: () => _showDifficultyDialog(context, entry),
              onNewChallenge: () => _showNewChallengeDialog(context, entry),
              onTap: () => _showExerciseDetail(context, entry, dayData.bodyMetrics),
            )),
          ],
          
          // Mensurations du jour
          if (dayData.hasMetrics) ...[
            const SizedBox(height: 12),
            const _SectionTitle(title: '📏 Mensurations', icon: Icons.straighten),
            _MetricsCard(metrics: dayData.bodyMetrics!),
          ],
        ],
      ),
    );
  }
  
  Widget _buildEmptyDayCompact() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune activité ce jour',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(context, prefilledDate: _selectedDay),
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: const Text('Ajouter un objectif'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC300),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final activeGoals = _repository.getActiveGoals();
    final overdueGoals = _repository.getOverdueGoals();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📅 Calendrier',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  // Bouton objectifs
                  _HeaderButton(
                    icon: Icons.flag_outlined,
                    label: '${activeGoals.length}',
                    badgeColor: overdueGoals.isNotEmpty 
                        ? Colors.red 
                        : (activeGoals.isNotEmpty ? const Color(0xFFFFC300) : null),
                    onTap: () => _showGoalsList(context),
                  ),
                  const SizedBox(width: 8),
                  // Bouton ajouter objectif
                  _HeaderButton(
                    icon: Icons.add,
                    onTap: () => _showAddGoalDialog(context),
                  ),
                ],
              ),
            ],
          ),
          // Stats rapides (compact)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                _QuickStatCompact(
                  label: 'Ce mois',
                  value: '${_getMonthWorkoutCount()} séances',
                  icon: Icons.fitness_center,
                ),
                const SizedBox(width: 12),
                _QuickStatCompact(
                  label: 'Volume',
                  value: '${(_repository.getTotalVolume() / 1000).toStringAsFixed(1)}t',
                  icon: Icons.bar_chart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getMonthWorkoutCount() {
    final now = DateTime.now();
    int count = 0;
    final entries = _repository.allEntries;
    final uniqueDays = <String>{};
    for (final entry in entries) {
      if (entry.date.year == now.year && entry.date.month == now.month) {
        uniqueDays.add('${entry.date.day}');
      }
    }
    return uniqueDays.length;
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Navigation mois
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white70),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                },
                child: Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(_focusedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white70),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          
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
                      color: Colors.white.withOpacity(0.5),
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
                final dayNumber = weekIndex * 7 + dayIndex - firstDayWeekday + 2;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 36));
                }
                
                final day = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
                final isSelected = _isSameDay(_selectedDay, day);
                final isToday = _isSameDay(now, day);
                final dayData = _repository.getDayData(day);
                final hasExercises = dayData.hasExercises;
                final hasGoals = dayData.hasGoals;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedDay = day);
                    },
                    child: Container(
                      height: 36,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFC300)
                            : isToday
                                ? const Color(0xFFFFC300).withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(color: const Color(0xFFFFC300), width: 1)
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isToday 
                                  ? FontWeight.w700 
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.white.withOpacity(0.9),
                            ),
                          ),
                          // Indicateurs
                          if (hasExercises || hasGoals)
                            Positioned(
                              bottom: 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasExercises)
                                    Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.only(right: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? Colors.black54 
                                            : Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if (hasGoals)
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? Colors.black54 
                                            : Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
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

  Widget _buildDayPanel() {
    final dayData = _repository.getDayData(_selectedDay);
    final formattedDate = DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDay);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du panneau
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (dayData.hasData)
                        Text(
                          '${dayData.exercises.length} exercices • ${dayData.totalSets} séries',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                // Bouton ajouter mensurations
                GestureDetector(
                  onTap: () => _showAddMetricsDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.straighten,
                      color: Color(0xFF9C27B0),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (dayData.hasExercises && dayData.averageDifficulty != null)
                  _DifficultyBadge(difficulty: dayData.averageDifficulty!),
              ],
            ),
          ),
          
          const Divider(color: Colors.white12, height: 1),
          
          // Contenu
          Expanded(
            child: dayData.hasData
                ? _buildDayContent(dayData)
                : _buildEmptyDay(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContent(CalendarDayData dayData) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Objectifs du jour
        if (dayData.hasGoals) ...[
          const _SectionTitle(title: '🎯 Objectifs', icon: Icons.flag),
          ...dayData.goals.map((goal) => _GoalCard(
            goal: goal,
            onTap: () => _showGoalDetail(context, goal),
          )),
          const SizedBox(height: 16),
        ],
        
        // Exercices du jour
        if (dayData.hasExercises) ...[
          const _SectionTitle(title: '💪 Exercices', icon: Icons.fitness_center),
          ...dayData.exercises.map((entry) => _ExerciseEntryCard(
            entry: entry,
            onEvaluateDifficulty: () => _showDifficultyDialog(context, entry),
            onNewChallenge: () => _showNewChallengeDialog(context, entry),
            onTap: () => _showExerciseDetail(context, entry, dayData.bodyMetrics),
          )),
        ],
        
        // Mensurations du jour
        if (dayData.hasMetrics) ...[
          const SizedBox(height: 16),
          const _SectionTitle(title: '📏 Mensurations', icon: Icons.straighten),
          _MetricsCard(metrics: dayData.bodyMetrics!),
        ],
      ],
    );
  }

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune activité ce jour',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(context, prefilledDate: _selectedDay),
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Ajouter un objectif'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC300),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DIALOGS & MODALS
  // ─────────────────────────────────────────────────────────────────────────────

  void _showGoalsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalsListSheet(repository: _repository),
    );
  }

  void _showAddGoalDialog(BuildContext context, {DateTime? prefilledDate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddGoalSheet(
        repository: _repository,
        initialDate: prefilledDate ?? _selectedDay,
      ),
    );
  }

  void _showGoalDetail(BuildContext context, CalendarGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalDetailSheet(
        goal: goal,
        repository: _repository,
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, ExerciseHistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DifficultySheet(
        entry: entry,
        repository: _repository,
      ),
    );
  }

  void _showNewChallengeDialog(BuildContext context, ExerciseHistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewChallengeSheet(
        entry: entry,
        repository: _repository,
      ),
    );
  }

  void _showExerciseDetail(BuildContext context, ExerciseHistoryEntry entry, BodyMetricsSnapshot? metrics) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseDetailSheet(
        entry: entry,
        bodyMetrics: metrics,
        repository: _repository,
        selectedDay: _selectedDay,
        onEvaluateDifficulty: () {
          Navigator.of(context).pop();
          _showDifficultyDialog(context, entry);
        },
        onNewChallenge: () {
          Navigator.of(context).pop();
          _showNewChallengeDialog(context, entry);
        },
      ),
    );
  }

  void _showAddMetricsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMetricsSheet(
        repository: _repository,
        selectedDay: _selectedDay,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS AUXILIAIRES
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    this.label,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (badgeColor != null) ...[
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC300).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFFC300), size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickStatCompact extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _QuickStatCompact({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFFC300), size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final double difficulty;

  const _DifficultyBadge({required this.difficulty});

  Color get _color {
    if (difficulty <= 3) return Colors.green;
    if (difficulty <= 5) return Colors.lightGreen;
    if (difficulty <= 7) return Colors.orange;
    if (difficulty <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, color: _color, size: 14),
          const SizedBox(width: 4),
          Text(
            'RPE ${difficulty.toStringAsFixed(1)}',
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final CalendarGoal goal;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: goal.type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: goal.type.color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: goal.type.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(goal.type.icon, color: goal.type.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    goal.statusLabel,
                    style: TextStyle(
                      color: goal.statusColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (goal.targetValue != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${goal.currentValue?.toStringAsFixed(1) ?? '?'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '/ ${goal.targetValue} ${goal.unit ?? ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

class _ExerciseEntryCard extends StatelessWidget {
  final ExerciseHistoryEntry entry;
  final VoidCallback onEvaluateDifficulty;
  final VoidCallback onNewChallenge;
  final VoidCallback onTap;

  const _ExerciseEntryCard({
    required this.entry,
    required this.onEvaluateDifficulty,
    required this.onNewChallenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec indication cliquable
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFFFFC300),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (entry.muscleGroup != null)
                        Text(
                          entry.muscleGroup!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (entry.perceivedDifficulty != null)
                  _DifficultyBadge(difficulty: entry.perceivedDifficulty!),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Résumé des séries
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.setsSummary,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (entry.totalVolume > 0)
                          Text(
                            'Volume: ${entry.totalVolume.toStringAsFixed(0)} kg',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (entry.photoPaths.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo, color: Colors.blue, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.photoPaths.length}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Hint cliquable
            Center(
              child: Text(
                'Appuyer pour voir le détail, ajouter photos, mensurations...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final BodyMetricsSnapshot metrics;

  const _MetricsCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (metrics.weightKg != null)
            _MetricRow(
              icon: Icons.monitor_weight,
              label: 'Poids',
              value: '${metrics.weightKg!.toStringAsFixed(1)} kg',
            ),
          if (metrics.waistCm != null)
            _MetricRow(
              icon: Icons.straighten,
              label: 'Tour de taille',
              value: '${metrics.waistCm!.toStringAsFixed(1)} cm',
            ),
          if (metrics.bodyFatPercent != null)
            _MetricRow(
              icon: Icons.percent,
              label: 'Masse grasse',
              value: '${metrics.bodyFatPercent!.toStringAsFixed(1)} %',
            ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEETS (BOTTOM SHEETS)
// ─────────────────────────────────────────────────────────────────────────────

class _GoalsListSheet extends StatelessWidget {
  final ExercisesCalendarRepository repository;

  const _GoalsListSheet({required this.repository});

  @override
  Widget build(BuildContext context) {
    final activeGoals = repository.getActiveGoals();
    final completedGoals = repository.getCompletedGoals();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Titre
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🎯 Mes Objectifs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${activeGoals.length} actifs',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Liste
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (activeGoals.isNotEmpty) ...[
                      const Text(
                        'En cours',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...activeGoals.map((goal) => _GoalListItem(goal: goal)),
                      const SizedBox(height: 24),
                    ],
                    if (completedGoals.isNotEmpty) ...[
                      const Text(
                        'Terminés',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...completedGoals.map((goal) => _GoalListItem(goal: goal)),
                    ],
                    if (activeGoals.isEmpty && completedGoals.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Aucun objectif pour le moment',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoalListItem extends StatelessWidget {
  final CalendarGoal goal;

  const _GoalListItem({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(goal.type.icon, color: goal.type.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: goal.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.statusLabel,
                  style: TextStyle(
                    color: goal.statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (goal.targetValue != null) ...[
            const SizedBox(height: 12),
            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(goal.type.color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(goal.progress * 100).toStringAsFixed(0)}% - ${goal.currentValue?.toStringAsFixed(1) ?? '?'} / ${goal.targetValue} ${goal.unit ?? ''}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Échéance: ${DateFormat('dd/MM/yyyy', 'fr_FR').format(goal.targetDate)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          if (goal.reminders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '🔔 ${goal.reminders.length} rappel${goal.reminders.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddGoalSheet extends StatefulWidget {
  final ExercisesCalendarRepository repository;
  final DateTime initialDate;

  const _AddGoalSheet({
    required this.repository,
    required this.initialDate,
  });

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  CalendarGoalType _selectedType = CalendarGoalType.custom;
  late DateTime _targetDate;
  final List<DateTime> _reminders = [];

  @override
  void initState() {
    super.initState();
    _targetDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Titre
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nouvel Objectif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: _saveGoal,
                      child: const Text(
                        'Créer',
                        style: TextStyle(
                          color: Color(0xFFFFC300),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Formulaire
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Type d'objectif
                    const Text(
                      'Type d\'objectif',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CalendarGoalType.values.map((type) {
                        final isSelected = type == _selectedType;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? type.color.withOpacity(0.3)
                                  : const Color(0xFF252525),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? type.color : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(type.icon, color: type.color, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  type.displayName,
                                  style: TextStyle(
                                    color: isSelected ? type.color : Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Titre
                    const Text(
                      'Titre de l\'objectif',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ex: Perdre 5 kg',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Valeur cible (optionnel)
                    const Text(
                      'Valeur cible (optionnel)',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _valueController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ex: -5',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              filled: true,
                              fillColor: const Color(0xFF252525),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _unitController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'kg',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              filled: true,
                              fillColor: const Color(0xFF252525),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date cible
                    const Text(
                      'Date cible',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFFFFC300)),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_targetDate),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rappels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rappels',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        TextButton.icon(
                          onPressed: _addReminder,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Ajouter'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFFC300),
                          ),
                        ),
                      ],
                    ),
                    if (_reminders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Aucun rappel configuré',
                          style: TextStyle(color: Colors.white.withOpacity(0.4)),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...List.generate(_reminders.length, (index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252525),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications, color: Colors.orange, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(_reminders[index]),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                onPressed: () {
                                  setState(() => _reminders.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _addReminder() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate.subtract(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: _targetDate,
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      if (pickedTime != null) {
        setState(() {
          _reminders.add(DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          ));
        });
      }
    }
  }

  void _saveGoal() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un titre')),
      );
      return;
    }

    final goal = CalendarGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      targetDate: _targetDate,
      createdAt: DateTime.now(),
      targetValue: double.tryParse(_valueController.text),
      unit: _unitController.text.isNotEmpty ? _unitController.text : null,
      type: _selectedType,
      reminders: _reminders.map((dt) => GoalReminder(
        id: 'rem_${dt.millisecondsSinceEpoch}',
        reminderDateTime: dt,
      )).toList(),
    );

    widget.repository.addGoal(goal);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Objectif "${goal.title}" créé !'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _GoalDetailSheet extends StatelessWidget {
  final CalendarGoal goal;
  final ExercisesCalendarRepository repository;

  const _GoalDetailSheet({
    required this.goal,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(goal.type.icon, color: goal.type.color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (goal.description != null)
            Text(
              goal.description!,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Échéance',
            value: DateFormat('dd MMMM yyyy', 'fr_FR').format(goal.targetDate),
          ),
          _InfoRow(
            icon: Icons.flag,
            label: 'Statut',
            value: goal.statusLabel,
            valueColor: goal.statusColor,
          ),
          if (goal.targetValue != null) ...[
            _InfoRow(
              icon: Icons.track_changes,
              label: 'Objectif',
              value: '${goal.targetValue} ${goal.unit ?? ''}',
            ),
            _InfoRow(
              icon: Icons.show_chart,
              label: 'Progression',
              value: '${(goal.progress * 100).toStringAsFixed(0)}%',
            ),
          ],
          const SizedBox(height: 24),
          if (!goal.isCompleted)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      repository.completeGoal(goal.id);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Marquer comme atteint'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    repository.deleteGoal(goal.id);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultySheet extends StatefulWidget {
  final ExerciseHistoryEntry entry;
  final ExercisesCalendarRepository repository;

  const _DifficultySheet({
    required this.entry,
    required this.repository,
  });

  @override
  State<_DifficultySheet> createState() => _DifficultySheetState();
}

class _DifficultySheetState extends State<_DifficultySheet> {
  late double _difficulty;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.entry.perceivedDifficulty ?? 5.0;
  }

  Color get _color {
    if (_difficulty <= 3) return Colors.green;
    if (_difficulty <= 5) return Colors.lightGreen;
    if (_difficulty <= 7) return Colors.orange;
    if (_difficulty <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  String get _label {
    if (_difficulty <= 2) return 'Très facile';
    if (_difficulty <= 4) return 'Facile';
    if (_difficulty <= 6) return 'Modéré';
    if (_difficulty <= 8) return 'Difficile';
    return 'Très difficile';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Difficulté ressentie (RPE)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.entry.exerciseName,
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 32),
          Text(
            _difficulty.toStringAsFixed(1),
            style: TextStyle(
              color: _color,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _difficulty,
            min: 1,
            max: 10,
            divisions: 18,
            activeColor: _color,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() => _difficulty = value);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 - Facile', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              Text('10 - Max', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.repository.updateEntryDifficulty(widget.entry.id, _difficulty);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Difficulté enregistrée: $_label'),
                    backgroundColor: _color,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Enregistrer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewChallengeSheet extends StatefulWidget {
  final ExerciseHistoryEntry entry;
  final ExercisesCalendarRepository repository;

  const _NewChallengeSheet({
    required this.entry,
    required this.repository,
  });

  @override
  State<_NewChallengeSheet> createState() => _NewChallengeSheetState();
}

class _NewChallengeSheetState extends State<_NewChallengeSheet> {
  late DateTime _targetDate;
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _targetDate = DateTime.now().add(const Duration(days: 30));
    _titleController.text = 'Améliorer ${widget.entry.exerciseName}';
    
    // Proposer une valeur cible basée sur les perfs actuelles
    final maxWeight = widget.entry.sets
        .where((s) => s.weight != null)
        .map((s) => s.weight!)
        .fold<double>(0, (a, b) => a > b ? a : b);
    if (maxWeight > 0) {
      _targetController.text = (maxWeight + 5).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFFFFC300)),
                  const SizedBox(width: 12),
                  const Text(
                    'Nouveau défi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Basé sur: ${widget.entry.exerciseName}',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),
              
              // Performance actuelle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance actuelle',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.entry.setsSummary,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Titre du défi
              const Text(
                'Titre du défi',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF252525),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Objectif (kg)
              const Text(
                'Objectif (kg)',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ex: 100',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF252525),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Date cible
              const Text(
                'Date limite',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _targetDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFFFFC300)),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy', 'fr_FR').format(_targetDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _createChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Créer le défi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createChallenge() {
    final targetValue = double.tryParse(_targetController.text);
    
    // Récupérer la valeur actuelle
    final currentMax = widget.entry.sets
        .where((s) => s.weight != null)
        .map((s) => s.weight!)
        .fold<double>(0, (a, b) => a > b ? a : b);

    final goal = CalendarGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      targetDate: _targetDate,
      createdAt: DateTime.now(),
      targetValue: targetValue,
      startValue: currentMax,
      currentValue: currentMax,
      unit: 'kg',
      type: CalendarGoalType.performance,
      linkedExerciseId: widget.entry.exerciseId,
    );

    widget.repository.addGoal(goal);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Défi "${goal.title}" créé !'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DÉTAIL COMPLET D'UN EXERCICE (PHOTOS, MENSURATIONS, REFAIRE)
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseDetailSheet extends StatefulWidget {
  final ExerciseHistoryEntry entry;
  final BodyMetricsSnapshot? bodyMetrics;
  final ExercisesCalendarRepository repository;
  final DateTime selectedDay;
  final VoidCallback onEvaluateDifficulty;
  final VoidCallback onNewChallenge;

  const _ExerciseDetailSheet({
    required this.entry,
    this.bodyMetrics,
    required this.repository,
    required this.selectedDay,
    required this.onEvaluateDifficulty,
    required this.onNewChallenge,
  });

  @override
  State<_ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<_ExerciseDetailSheet> {
  late List<String> _photoPaths;
  final List<String> _demoPhotos = [
    'assets/images/before_after_1.png',
    'assets/images/gym_workout_1.png',
  ];

  @override
  void initState() {
    super.initState();
    _photoPaths = List.from(widget.entry.photoPaths);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC300).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFFFFC300),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.entry.exerciseName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${widget.entry.muscleGroup ?? 'Exercice'} • ${DateFormat('dd/MM/yyyy', 'fr_FR').format(widget.entry.date)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.entry.perceivedDifficulty != null)
                      _DifficultyBadge(difficulty: widget.entry.perceivedDifficulty!),
                  ],
                ),
              ),
              
              // Contenu scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // ─────────────────────────────────────────────────────────
                    // SECTION: SÉRIES DÉTAILLÉES
                    // ─────────────────────────────────────────────────────────
                    _buildSectionTitle('📊 Séries réalisées'),
                    _buildSetsDetail(),
                    const SizedBox(height: 24),
                    
                    // ─────────────────────────────────────────────────────────
                    // SECTION: PHOTOS
                    // ─────────────────────────────────────────────────────────
                    _buildSectionTitle('📸 Photos / Vidéos'),
                    _buildPhotosSection(),
                    const SizedBox(height: 24),
                    
                    // ─────────────────────────────────────────────────────────
                    // SECTION: MENSURATIONS DU JOUR
                    // ─────────────────────────────────────────────────────────
                    _buildSectionTitle('📏 Mensurations du jour'),
                    _buildMetricsSection(),
                    const SizedBox(height: 24),
                    
                    // ─────────────────────────────────────────────────────────
                    // SECTION: ACTIONS
                    // ─────────────────────────────────────────────────────────
                    _buildSectionTitle('⚡ Actions'),
                    _buildActionsSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSetsDetail() {
    if (widget.entry.sets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Aucune série enregistrée',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header tableau
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text('#', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600))),
                Expanded(child: Text('Reps', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600))),
                Expanded(child: Text('Charge', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600))),
                Expanded(child: Text('Repos', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          // Lignes
          ...widget.entry.sets.map((set) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${set.setNumber}',
                        style: const TextStyle(
                          color: Color(0xFFFFC300),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    set.reps != null ? '${set.reps}' : (set.timeUnderTension != null ? '${set.timeUnderTension!.inSeconds}s' : '-'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    set.weight != null ? '${set.weight!.toStringAsFixed(1)} kg' : '-',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Text(
                    set.restTime != null ? '${set.restTime!.inSeconds}s' : '-',
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          )),
          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Volume total',
                  style: TextStyle(color: Color(0xFFFFC300), fontWeight: FontWeight.w600),
                ),
                Text(
                  '${widget.entry.totalVolume.toStringAsFixed(0)} kg',
                  style: const TextStyle(
                    color: Color(0xFFFFC300),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galerie de photos
          if (_photoPaths.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photoPaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.asset(
                          _photoPaths[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.image_not_supported, color: Colors.white38),
                          ),
                        ),
                        // Bouton supprimer
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _photoPaths.removeAt(index));
                              // TODO: Mettre à jour le repository
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Photo supprimée (démo)')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Text(
              'Aucune photo pour cet exercice',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          
          const SizedBox(height: 16),
          
          // Boutons d'ajout
          Row(
            children: [
              Expanded(
                child: _SmallActionButton(
                  icon: Icons.photo_library,
                  label: 'Galerie',
                  color: Colors.blue,
                  onTap: () => _addPhotoFromGallery(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallActionButton(
                  icon: Icons.camera_alt,
                  label: 'Caméra',
                  color: Colors.green,
                  onTap: () => _addPhotoFromCamera(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallActionButton(
                  icon: Icons.videocam,
                  label: 'Vidéo',
                  color: Colors.purple,
                  onTap: () => _addVideo(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addPhotoFromGallery() {
    // En mode démo, on ajoute une photo d'exemple
    setState(() {
      if (_demoPhotos.isNotEmpty) {
        _photoPaths.add(_demoPhotos[_photoPaths.length % _demoPhotos.length]);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Photo ajoutée depuis la galerie (démo)'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _addPhotoFromCamera() {
    setState(() {
      if (_demoPhotos.isNotEmpty) {
        _photoPaths.add(_demoPhotos[(_photoPaths.length + 1) % _demoPhotos.length]);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📷 Photo prise avec la caméra (démo)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎬 Vidéo ajoutée (démo)'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildMetricsSection() {
    final metrics = widget.bodyMetrics;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (metrics != null && metrics.hasAnyMeasurement) ...[
            // Afficher les mensurations existantes
            if (metrics.weightKg != null)
              _MetricDisplayRow(icon: Icons.monitor_weight, label: 'Poids', value: '${metrics.weightKg!.toStringAsFixed(1)} kg'),
            if (metrics.waistCm != null)
              _MetricDisplayRow(icon: Icons.straighten, label: 'Tour de taille', value: '${metrics.waistCm!.toStringAsFixed(1)} cm'),
            if (metrics.bodyFatPercent != null)
              _MetricDisplayRow(icon: Icons.percent, label: 'Masse grasse', value: '${metrics.bodyFatPercent!.toStringAsFixed(1)} %'),
            if (metrics.chestCm != null)
              _MetricDisplayRow(icon: Icons.accessibility_new, label: 'Tour de poitrine', value: '${metrics.chestCm!.toStringAsFixed(1)} cm'),
            if (metrics.armsCm != null)
              _MetricDisplayRow(icon: Icons.fitness_center, label: 'Tour de bras', value: '${metrics.armsCm!.toStringAsFixed(1)} cm'),
            const SizedBox(height: 12),
          ] else
            Text(
              'Aucune mensuration ce jour-là',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          
          const SizedBox(height: 8),
          
          // Bouton ajouter/modifier mensurations
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Ouvrir le sheet d'ajout de mensurations
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => _AddMetricsSheet(
                    repository: widget.repository,
                    selectedDay: widget.selectedDay,
                    existingMetrics: metrics,
                  ),
                );
              },
              icon: Icon(metrics?.hasAnyMeasurement == true ? Icons.edit : Icons.add),
              label: Text(metrics?.hasAnyMeasurement == true ? 'Modifier mensurations' : 'Ajouter mensurations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0).withOpacity(0.3),
                foregroundColor: const Color(0xFF9C27B0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: const Color(0xFF9C27B0).withOpacity(0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        // Ligne 1: Difficulté + Nouveau défi
        Row(
          children: [
            Expanded(
              child: _BigActionButton(
                icon: Icons.speed,
                label: widget.entry.perceivedDifficulty == null 
                    ? 'Évaluer\ndifficulté' 
                    : 'Modifier\ndifficulté',
                color: Colors.orange,
                onTap: widget.onEvaluateDifficulty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigActionButton(
                icon: Icons.flag,
                label: 'Nouveau\ndéfi',
                color: Colors.green,
                onTap: widget.onNewChallenge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Ligne 2: Refaire l'exercice
        SizedBox(
          width: double.infinity,
          child: _BigActionButton(
            icon: Icons.replay,
            label: 'Refaire cet exercice (nouvelle séance)',
            color: const Color(0xFFFFC300),
            isWide: true,
            onTap: () => _startNewSession(),
          ),
        ),
      ],
    );
  }

  void _startNewSession() {
    Navigator.of(context).pop();
    
    // Créer une nouvelle entrée pour aujourd'hui basée sur l'exercice
    final newEntry = ExerciseHistoryEntry(
      id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: widget.entry.exerciseId,
      exerciseName: widget.entry.exerciseName,
      exerciseCategory: widget.entry.exerciseCategory,
      muscleGroup: widget.entry.muscleGroup,
      date: DateTime.now(),
      sets: [], // Séries vides, à remplir
    );

    widget.repository.addOrUpdateEntry(newEntry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🏋️ Nouvelle séance "${widget.entry.exerciseName}" créée pour aujourd\'hui !'),
        backgroundColor: const Color(0xFFFFC300),
        action: SnackBarAction(
          label: 'VOIR',
          textColor: Colors.black,
          onPressed: () {
            // TODO: Naviguer vers la page de séance
          },
        ),
      ),
    );
  }
}

class _MetricDisplayRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricDisplayRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9C27B0), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isWide;

  const _BigActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isWide ? 16 : 20,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AJOUT DE MENSURATIONS
// ─────────────────────────────────────────────────────────────────────────────

class _AddMetricsSheet extends StatefulWidget {
  final ExercisesCalendarRepository repository;
  final DateTime selectedDay;
  final BodyMetricsSnapshot? existingMetrics;

  const _AddMetricsSheet({
    required this.repository,
    required this.selectedDay,
    this.existingMetrics,
  });

  @override
  State<_AddMetricsSheet> createState() => _AddMetricsSheetState();
}

class _AddMetricsSheetState extends State<_AddMetricsSheet> {
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _chestController = TextEditingController();
  final _armsController = TextEditingController();
  final _thighsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les valeurs existantes
    final m = widget.existingMetrics;
    if (m != null) {
      if (m.weightKg != null) _weightController.text = m.weightKg!.toStringAsFixed(1);
      if (m.waistCm != null) _waistController.text = m.waistCm!.toStringAsFixed(1);
      if (m.bodyFatPercent != null) _bodyFatController.text = m.bodyFatPercent!.toStringAsFixed(1);
      if (m.chestCm != null) _chestController.text = m.chestCm!.toStringAsFixed(1);
      if (m.armsCm != null) _armsController.text = m.armsCm!.toStringAsFixed(1);
      if (m.thighsCm != null) _thighsController.text = m.thighsCm!.toStringAsFixed(1);
      if (m.notes != null) _notesController.text = m.notes!;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _bodyFatController.dispose();
    _chestController.dispose();
    _armsController.dispose();
    _thighsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.straighten, color: Color(0xFF9C27B0)),
                        const SizedBox(width: 12),
                        Text(
                          'Mensurations du ${DateFormat('dd/MM', 'fr_FR').format(widget.selectedDay)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _saveMetrics,
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: Color(0xFFFFC300),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Formulaire
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Poids
                    _MetricField(
                      controller: _weightController,
                      label: 'Poids',
                      icon: Icons.monitor_weight,
                      unit: 'kg',
                      color: Colors.blue,
                    ),
                    // Tour de taille
                    _MetricField(
                      controller: _waistController,
                      label: 'Tour de taille',
                      icon: Icons.straighten,
                      unit: 'cm',
                      color: const Color(0xFF9C27B0),
                    ),
                    // Masse grasse
                    _MetricField(
                      controller: _bodyFatController,
                      label: 'Masse grasse',
                      icon: Icons.percent,
                      unit: '%',
                      color: Colors.orange,
                    ),
                    // Tour de poitrine
                    _MetricField(
                      controller: _chestController,
                      label: 'Tour de poitrine',
                      icon: Icons.accessibility_new,
                      unit: 'cm',
                      color: Colors.teal,
                    ),
                    // Tour de bras
                    _MetricField(
                      controller: _armsController,
                      label: 'Tour de bras',
                      icon: Icons.fitness_center,
                      unit: 'cm',
                      color: Colors.green,
                    ),
                    // Tour de cuisses
                    _MetricField(
                      controller: _thighsController,
                      label: 'Tour de cuisses',
                      icon: Icons.directions_walk,
                      unit: 'cm',
                      color: Colors.indigo,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Notes
                    const Text(
                      'Notes (optionnel)',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Remarques, ressenti...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Bouton enregistrer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMetrics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Enregistrer les mensurations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveMetrics() {
    final metrics = BodyMetricsSnapshot(
      id: widget.existingMetrics?.id ?? 'metrics_${DateTime.now().millisecondsSinceEpoch}',
      measuredAt: widget.selectedDay,
      weightKg: double.tryParse(_weightController.text),
      waistCm: double.tryParse(_waistController.text),
      bodyFatPercent: double.tryParse(_bodyFatController.text),
      chestCm: double.tryParse(_chestController.text),
      armsCm: double.tryParse(_armsController.text),
      thighsCm: double.tryParse(_thighsController.text),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    widget.repository.addOrUpdateMetrics(metrics);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📏 Mensurations enregistrées !'),
        backgroundColor: Color(0xFF9C27B0),
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String unit;
  final Color color;

  const _MetricField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    suffixText: unit,
                    suffixStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFF252525),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

