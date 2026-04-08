import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_session.dart';
import '../models/game_story.dart';
import '../main.dart' show WorkoutDetailPage, Workout;

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

/// Page listant les séances de la semaine (passées / à venir)
class WeeklySessionsPage extends StatefulWidget {
  const WeeklySessionsPage({super.key});

  @override
  State<WeeklySessionsPage> createState() => _WeeklySessionsPageState();
}

class _WeeklySessionsPageState extends State<WeeklySessionsPage>
    with TickerProviderStateMixin {
  late List<_WeeklySession> _sessions;
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _sessions = _generateWeeklySessions();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<_WeeklySession> _generateWeeklySessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      _WeeklySession(
        id: '1',
        title: 'Full body – Intermédiaire',
        date: today.subtract(const Duration(days: 2)),
        time: '18:30',
        duration: 45,
        muscles: ['Jambes', 'Dos', 'Pectoraux'],
        intensity: 'Moyenne',
        isCompleted: true,
        calories: 420,
        xpGained: 15,
      ),
      _WeeklySession(
        id: '2',
        title: 'Cardio HIIT',
        date: today.subtract(const Duration(days: 1)),
        time: '19:00',
        duration: 30,
        muscles: ['Cardio'],
        intensity: 'Élevée',
        isCompleted: true,
        calories: 380,
        xpGained: 12,
      ),
      _WeeklySession(
        id: '3',
        title: 'Renforcement jambes',
        date: today,
        time: '18:00',
        duration: 40,
        muscles: ['Jambes', 'Fessiers'],
        intensity: 'Moyenne',
        isCompleted: false,
      ),
      _WeeklySession(
        id: '4',
        title: 'Haut du corps',
        date: today.add(const Duration(days: 2)),
        time: '18:30',
        duration: 45,
        muscles: ['Pectoraux', 'Dos', 'Épaules'],
        intensity: 'Moyenne',
        isCompleted: false,
      ),
      _WeeklySession(
        id: '5',
        title: 'Stretching & Mobilité',
        date: today.add(const Duration(days: 4)),
        time: '19:30',
        duration: 35,
        muscles: ['Tout le corps'],
        intensity: 'Douce',
        isCompleted: false,
      ),
    ];
  }

  void _markSessionAsDone(_WeeklySession session) {
    if (session.isCompleted) return;

    HapticFeedback.mediumImpact();

    setState(() {
      final index = _sessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        _sessions[index] = _WeeklySession(
          id: session.id,
          title: session.title,
          date: session.date,
          time: session.time,
          duration: session.duration,
          muscles: session.muscles,
          intensity: session.intensity,
          isCompleted: true,
          calories: session.calories ?? (300 + (session.duration * 5)),
          xpGained: session.xpGained ?? (10 + (session.duration ~/ 5)),
        );
      }
    });

    final xpToAdd = session.xpGained ?? (10 + (session.duration ~/ 5));
    final gameNotifier = GameStoryNotifier();
    gameNotifier.addXP(xpToAdd);

    _showSessionRecap(context, session, xpToAdd);
  }

  void _showSessionRecap(BuildContext context, _WeeklySession session, int xpGained) {
    final calories = session.calories ?? (300 + (session.duration * 5));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation de succès
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: _primaryGreen, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bravo ! 🎉',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu as terminé "${session.title}"',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 15),
            ),
            const SizedBox(height: 24),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RecapStat(
                  icon: Icons.star,
                  value: '+$xpGained',
                  label: 'XP',
                  color: _primaryGold,
                ),
                _RecapStat(
                  icon: Icons.local_fire_department,
                  value: '$calories',
                  label: 'kcal',
                  color: _primaryOrange,
                ),
                _RecapStat(
                  icon: Icons.fitness_center,
                  value: '+1',
                  label: 'séance',
                  color: _primaryBlue,
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Super !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pastSessions = _sessions.where((s) => s.isCompleted).toList();
    final upcomingSessions = _sessions.where((s) => !s.isCompleted).toList();

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
                  _primaryOrange.withOpacity(0.1),
                  _darkBg,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar moderne
              SliverAppBar(
                expandedHeight: 160,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_primaryOrange, _primaryOrange.withOpacity(0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryOrange.withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Séances de la semaine',
                                      style: TextStyle(
                                        color: _textLight,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${upcomingSessions.length} à venir • ${pastSessions.length} terminées',
                                      style: TextStyle(color: _textMuted, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // TabBar
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: _primaryOrange,
                    indicatorWeight: 3,
                    labelColor: _primaryOrange,
                    unselectedLabelColor: _textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.upcoming, size: 20),
                            const SizedBox(width: 8),
                            Text('À venir (${upcomingSessions.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text('Passées (${pastSessions.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // À venir
                    _buildSessionsList(upcomingSessions, false),
                    // Passées
                    _buildSessionsList(pastSessions, true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<_WeeklySession> sessions, bool isPast) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardBgLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPast ? Icons.history : Icons.event_available,
                size: 48,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPast ? 'Aucune séance passée' : 'Aucune séance à venir',
              style: const TextStyle(
                color: _textLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPast ? 'Tes séances terminées apparaîtront ici' : 'Planifie ta prochaine séance !',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _ModernSessionCard(
          session: session,
          index: index,
          isPast: isPast,
          animationController: _animationController,
          onTap: () => _openSessionDetail(session),
          onMarkDone: isPast ? null : () => _markSessionAsDone(session),
        );
      },
    );
  }

  void _openSessionDetail(_WeeklySession session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailPage(
          workout: Workout(
            title: session.title,
            durationMinutes: session.duration,
            difficulty: session.intensity == 'Élevée'
                ? 'Avancé'
                : session.intensity == 'Moyenne'
                    ? 'Intermédiaire'
                    : 'Débutant',
            sessionsPerWeek: 3,
            objective: 'Remise en forme',
            equipment: 'Poids du corps',
            calories: session.calories ?? 350,
            steps: 5000,
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: _darkBg, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _WeeklySession {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final int duration;
  final List<String> muscles;
  final String intensity;
  final bool isCompleted;
  final int? calories;
  final int? xpGained;

  _WeeklySession({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.muscles,
    required this.intensity,
    required this.isCompleted,
    this.calories,
    this.xpGained,
  });
}

class _ModernSessionCard extends StatelessWidget {
  final _WeeklySession session;
  final int index;
  final bool isPast;
  final AnimationController animationController;
  final VoidCallback onTap;
  final VoidCallback? onMarkDone;

  const _ModernSessionCard({
    required this.session,
    required this.index,
    required this.isPast,
    required this.animationController,
    required this.onTap,
    this.onMarkDone,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 0.5),
          ((index * 0.1) + 0.5).clamp(0.5, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: session.isCompleted ? _primaryGreen.withOpacity(0.5) : _cardBgLight,
            width: session.isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (session.isCompleted ? _primaryGreen : _primaryOrange).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      // Date badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getDateColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _formatDateShort(session.date),
                              style: TextStyle(
                                color: _getDateColor(),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              session.time,
                              style: TextStyle(
                                color: _getDateColor().withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Titre et durée
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              style: TextStyle(
                                color: session.isCompleted ? _textMuted : _textLight,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                decoration: session.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 14, color: _textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  '${session.duration} min',
                                  style: TextStyle(color: _textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Badge complété
                      if (session.isCompleted)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Muscles et intensité
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...session.muscles.take(3).map((muscle) => _MuscleChip(muscle: muscle)),
                      _IntensityChip(intensity: session.intensity),
                    ],
                  ),
                  // Stats si complété
                  if (session.isCompleted && session.calories != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _cardBgLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SmallStat(
                            icon: Icons.star,
                            value: '+${session.xpGained}',
                            label: 'XP',
                            color: _primaryGold,
                          ),
                          _SmallStat(
                            icon: Icons.local_fire_department,
                            value: '${session.calories}',
                            label: 'kcal',
                            color: _primaryOrange,
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Bouton marquer comme fait
                  if (!session.isCompleted && onMarkDone != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onMarkDone,
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text('Marquer comme faite'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen.withOpacity(0.15),
                          foregroundColor: _primaryGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: _primaryGreen.withOpacity(0.3)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDateColor() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = session.date.difference(today).inDays;

    if (session.isCompleted) return _primaryGreen;
    if (diff == 0) return _primaryOrange;
    if (diff < 0) return _textMuted;
    return _primaryBlue;
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = date.difference(today).inDays;

    if (diff == 0) return 'Auj.';
    if (diff == -1) return 'Hier';
    if (diff == 1) return 'Dem.';

    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }
}

class _MuscleChip extends StatelessWidget {
  final String muscle;

  const _MuscleChip({required this.muscle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        muscle,
        style: const TextStyle(color: _textLight, fontSize: 12),
      ),
    );
  }
}

class _IntensityChip extends StatelessWidget {
  final String intensity;

  const _IntensityChip({required this.intensity});

  Color get _color {
    switch (intensity) {
      case 'Élevée':
        return _primaryRed;
      case 'Moyenne':
        return _primaryOrange;
      case 'Douce':
        return _primaryGreen;
      default:
        return _textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        intensity,
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SmallStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: _textMuted, fontSize: 12)),
      ],
    );
  }
}

class _RecapStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _RecapStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Text(label, style: TextStyle(color: _textMuted, fontSize: 12)),
      ],
    );
  }
}
