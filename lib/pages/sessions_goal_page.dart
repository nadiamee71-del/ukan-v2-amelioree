import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_history.dart';
import 'package:intl/intl.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

// Palette moderne et immersive
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryPurple = Color(0xFFA855F7);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);

class SessionsGoalPage extends StatefulWidget {
  const SessionsGoalPage({super.key});

  @override
  State<SessionsGoalPage> createState() => _SessionsGoalPageState();
}

class _SessionsGoalPageState extends State<SessionsGoalPage>
    with SingleTickerProviderStateMixin {
  final _historyNotifier = WorkoutHistoryNotifier();
  static const int _targetSessionsPerWeek = 4;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _historyNotifier.addListener(_onDataChanged);
    AlterEgoPageDetector.setupPageContext(UkanPage.objectifSeances);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _historyNotifier.removeListener(_onDataChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (dateOnly == today) {
      dateStr = 'Aujourd\'hui';
    } else if (dateOnly == yesterday) {
      dateStr = 'Hier';
    } else {
      dateStr = DateFormat('dd/MM').format(date);
    }

    final timeStr = DateFormat('HH:mm').format(date);
    return '$dateStr à $timeStr';
  }

  String _extractWorkoutType(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('cardio') || lowerTitle.contains('course') || lowerTitle.contains('running')) {
      return 'Cardio';
    } else if (lowerTitle.contains('danse') || lowerTitle.contains('dance')) {
      return 'Danse';
    } else if (lowerTitle.contains('yoga') || lowerTitle.contains('pilates')) {
      return 'Yoga';
    } else if (lowerTitle.contains('muscu') || lowerTitle.contains('musculation') || lowerTitle.contains('full body')) {
      return 'Musculation';
    } else {
      return 'Sport';
    }
  }

  Color _getWorkoutTypeColor(String type) {
    switch (type) {
      case 'Cardio':
        return _primaryRed;
      case 'Danse':
        return _primaryPurple;
      case 'Yoga':
        return _primaryGreen;
      case 'Musculation':
        return _primaryOrange;
      default:
        return _primaryBlue;
    }
  }

  List<bool?> _getWeeklyStatus() {
    final now = DateTime.now();
    final entries = _historyNotifier.allEntries();

    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 - i));
      if (date.isAfter(now)) return null;

      final hasWorkout = entries.any((e) =>
          e.date.year == date.year && e.date.month == date.month && e.date.day == date.day);

      return hasWorkout ? true : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekSummary = _historyNotifier.summaryForWeek(now);
    final sessionsCount = weekSummary.sessionsCount;
    final progress = (sessionsCount / _targetSessionsPerWeek).clamp(0.0, 1.0);
    final weeklyStatus = _getWeeklyStatus();

    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sundayDate = DateTime(monday.year, monday.month, monday.day).add(const Duration(days: 6));
    final mondayDate = DateTime(monday.year, monday.month, monday.day);

    final weekSessions = _historyNotifier.allEntries().where((entry) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      return !entryDate.isBefore(mondayDate) && !entryDate.isAfter(sundayDate);
    }).toList();

    weekSessions.sort((a, b) => b.date.compareTo(a.date));

    String status;
    Color statusColor;
    IconData statusIcon;
    if (sessionsCount == 0) {
      status = 'Commence ta semaine !';
      statusColor = _textMuted;
      statusIcon = Icons.play_arrow;
    } else if (sessionsCount >= _targetSessionsPerWeek) {
      status = 'Objectif atteint ! 🎉';
      statusColor = _primaryGreen;
      statusIcon = Icons.check_circle;
    } else {
      status = 'Bien joué, continue !';
      statusColor = _primaryPurple;
      statusIcon = Icons.trending_up;
    }

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Fond avec gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _primaryPurple.withOpacity(0.15),
                  _darkBg,
                ],
                stops: const [0.0, 0.4],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar moderne
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: _darkBg,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _textLight),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                      child: _buildHeader(),
                    ),
                  ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainCard(
                        sessionsCount: sessionsCount,
                        progress: progress,
                        status: status,
                        statusColor: statusColor,
                        statusIcon: statusIcon,
                      ),
                      const SizedBox(height: 20),
                      _buildWeeklyTable(weeklyStatus),
                      const SizedBox(height: 20),
                      _buildSessionsList(weekSessions),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryPurple, _primaryPurple.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.track_changes, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Objectif Séances',
                  style: TextStyle(
                    color: _textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Cette semaine',
                  style: TextStyle(color: _textMuted, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard({
    required int sessionsCount,
    required double progress,
    required String status,
    required Color statusColor,
    required IconData statusIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0, end: sessionsCount.toDouble()),
                builder: (context, value, child) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: _textLight,
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '/ $_targetSessionsPerWeek séances',
                  style: TextStyle(color: _textMuted, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress bar stylée
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0, end: progress),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: progress >= 1.0
                                ? [_primaryGreen, _primaryGreen.withOpacity(0.7)]
                                : [_primaryPurple, _primaryPurple.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: (progress >= 1.0 ? _primaryGreen : _primaryPurple)
                                  .withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTable(List<bool?> statuses) {
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_view_week, color: _primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Séances de la semaine',
                style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(7, (i) {
              final date = now.subtract(Duration(days: now.weekday - 1 - i));
              final isToday = date.day == now.day && date.month == now.month;
              final status = i < statuses.length ? statuses[i] : null;
              final isFuture = date.isAfter(now);

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dayNames[i],
                      style: TextStyle(
                        color: isToday ? _primaryPurple : _textMuted,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? _primaryPurple : _textMuted.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: status == true
                            ? LinearGradient(
                                colors: [_primaryPurple, _primaryPurple.withOpacity(0.7)],
                              )
                            : null,
                        color: status != true ? _cardBgLight : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday
                            ? Border.all(color: _primaryPurple, width: 2)
                            : Border.all(color: _cardBgLight),
                        boxShadow: status == true
                            ? [
                                BoxShadow(
                                  color: _primaryPurple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: status == true
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : isFuture
                                ? Icon(Icons.remove, size: 14, color: _textMuted.withOpacity(0.3))
                                : Icon(Icons.close, size: 14, color: _textMuted.withOpacity(0.3)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<WorkoutSessionHistoryEntry> sessions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.list_alt, color: _primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Séances réalisées',
                style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${sessions.length}',
                  style: TextStyle(color: _primaryGreen, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.fitness_center_outlined, size: 40, color: _textMuted),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune séance cette semaine',
                    style: TextStyle(color: _textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'C\'est le moment de commencer ! 💪',
                    style: TextStyle(color: _primaryPurple, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ...sessions.asMap().entries.map((entry) => _buildSessionCard(entry.value, entry.key)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(WorkoutSessionHistoryEntry entry, int index) {
    final type = _extractWorkoutType(entry.workoutTitle);
    final typeColor = _getWorkoutTypeColor(type);

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (0.3 + index * 0.1).clamp(0.0, 0.7),
          (0.6 + index * 0.1).clamp(0.5, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - animation.value), 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: typeColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [typeColor.withOpacity(0.2), typeColor.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.fitness_center, color: typeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.workoutTitle,
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.timer, size: 14, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${(entry.durationSeconds / 60).round()} min',
                        style: TextStyle(color: _textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDateTime(entry.date).split(' à ')[0],
                  style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatDateTime(entry.date).split(' à ')[1],
                  style: TextStyle(color: _textMuted.withOpacity(0.6), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
