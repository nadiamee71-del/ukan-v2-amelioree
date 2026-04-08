import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_session.dart';
import '../models/workout_session_storage.dart';
import 'workout_session_detail_page.dart';
import 'workout_session_recording_page.dart';
import 'package:intl/intl.dart';

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

/// Page principale "Mes Séances" - Design immersif PRO
class MyWorkoutSessionsPage extends StatefulWidget {
  final bool embedInTab;
  const MyWorkoutSessionsPage({super.key, this.embedInTab = false});

  @override
  State<MyWorkoutSessionsPage> createState() => _MyWorkoutSessionsPageState();
}

class _MyWorkoutSessionsPageState extends State<MyWorkoutSessionsPage>
    with SingleTickerProviderStateMixin {
  List<WorkoutSession> _sessions = [];
  bool _isLoading = true;
  String? _searchQuery;
  String _selectedFilter = 'all';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadSessions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await WorkoutSessionStorage.getAllSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
    _animationController.forward(from: 0);
  }

  Future<void> _deleteSession(WorkoutSession session) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: _primaryRed),
            const SizedBox(width: 12),
            const Text('Supprimer', style: TextStyle(color: _textLight)),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la séance du ${_formatDate(session.startTime)} ?',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await WorkoutSessionStorage.deleteSession(session.id);
      _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Séance supprimée'),
            backgroundColor: _primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date);
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return 'En cours...';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h${mins > 0 ? ' $mins min' : ''}';
  }

  int get _totalSessions => _sessions.length;
  int get _totalMinutes => _sessions.fold(0, (sum, s) => sum + (s.durationMinutes ?? 0));
  double get _totalVolume => _sessions.fold(0.0, (sum, s) => sum + s.totalVolume);

  Map<String, List<WorkoutSession>> get _sessionsByWeek {
    final map = <String, List<WorkoutSession>>{};
    for (final session in _filteredSessions) {
      final weekStart = _getWeekStart(session.startTime);
      final key = DateFormat('dd/MM/yyyy').format(weekStart);
      map.putIfAbsent(key, () => []).add(session);
    }
    return map;
  }

  DateTime _getWeekStart(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  String _getWeekLabel(String weekStartKey) {
    final now = DateTime.now();
    final thisWeekStart = _getWeekStart(now);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final weekStart = DateFormat('dd/MM/yyyy').parse(weekStartKey);

    if (weekStart.year == thisWeekStart.year &&
        weekStart.month == thisWeekStart.month &&
        weekStart.day == thisWeekStart.day) {
      return 'Cette semaine';
    } else if (weekStart.year == lastWeekStart.year &&
        weekStart.month == lastWeekStart.month &&
        weekStart.day == lastWeekStart.day) {
      return 'Semaine dernière';
    } else {
      return 'Semaine du ${DateFormat('dd MMM', 'fr_FR').format(weekStart)}';
    }
  }

  List<WorkoutSession> get _filteredSessions {
    var sessions = _sessions;
    final now = DateTime.now();

    if (_selectedFilter == 'week') {
      final weekStart = _getWeekStart(now);
      sessions = sessions.where((s) => s.startTime.isAfter(weekStart)).toList();
    } else if (_selectedFilter == 'month') {
      final monthStart = DateTime(now.year, now.month, 1);
      sessions = sessions.where((s) => s.startTime.isAfter(monthStart)).toList();
    }

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      sessions = sessions.where((session) {
        return (session.name?.toLowerCase().contains(query) ?? false) ||
            session.exercises.any((ex) => ex.exerciseName.toLowerCase().contains(query));
      }).toList();
    }

    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  String _formatTotalTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    return '${hours}h';
  }

  void _startNewSession() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const WorkoutSessionRecordingPage()))
        .then((_) => _loadSessions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewSession,
        backgroundColor: _primaryGold,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Nouvelle séance', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          // Fond avec gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _primaryGold.withOpacity(0.1),
                  _darkBg,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator(color: _primaryGold))
              : CustomScrollView(
                  slivers: [
                    // AppBar moderne
                    SliverAppBar(
                      expandedHeight: 120,
                      pinned: true,
                      backgroundColor: _darkBg,
                      leading: widget.embedInTab
                          ? null
                          : IconButton(
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
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_primaryGold, _primaryOrange],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primaryGold.withOpacity(0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Mes Séances',
                                      style: TextStyle(
                                        color: _textLight,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '$_totalSessions séances enregistrées',
                                      style: TextStyle(color: _textMuted, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Stats globales
                    SliverToBoxAdapter(child: _buildGlobalStats()),

                    // Filtres
                    SliverToBoxAdapter(child: _buildFilters()),

                    // Barre de recherche
                    SliverToBoxAdapter(child: _buildSearchBar()),

                    // Liste des séances
                    if (_filteredSessions.isEmpty)
                      SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: _buildSessionsSliver(),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildGlobalStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _primaryGold.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.bar_chart, color: _primaryGold, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mes statistiques',
                style: TextStyle(color: _textLight, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.fitness_center,
                  value: '$_totalSessions',
                  label: 'Séances',
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer,
                  value: _formatTotalTime(_totalMinutes),
                  label: 'Temps total',
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  value: '${(_totalVolume / 1000).toStringAsFixed(1)}t',
                  label: 'Volume',
                  color: _primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tout',
            isSelected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Cette semaine',
            isSelected: _selectedFilter == 'week',
            onTap: () => setState(() => _selectedFilter = 'week'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Ce mois',
            isSelected: _selectedFilter == 'month',
            onTap: () => setState(() => _selectedFilter = 'month'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBgLight),
        ),
        child: TextField(
          style: const TextStyle(color: _textLight),
          decoration: InputDecoration(
            hintText: 'Rechercher une séance...',
            hintStyle: TextStyle(color: _textMuted),
            prefixIcon: Icon(Icons.search, color: _textMuted),
            suffixIcon: _searchQuery != null && _searchQuery!.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: _textMuted),
                    onPressed: () => setState(() => _searchQuery = null),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (value) => setState(() => _searchQuery = value.isEmpty ? null : value),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            child: Icon(Icons.fitness_center, size: 48, color: _primaryGold),
          ),
          const SizedBox(height: 24),
          Text(
            _sessions.isEmpty ? 'Aucune séance enregistrée' : 'Aucune séance trouvée',
            style: const TextStyle(color: _textLight, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          if (_sessions.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Commencez par créer votre première séance',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startNewSession,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle séance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsSliver() {
    final weeklyGroups = _sessionsByWeek;
    final sortedKeys = weeklyGroups.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd/MM/yyyy').parse(a);
        final dateB = DateFormat('dd/MM/yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    final List<Widget> items = [];

    for (int weekIndex = 0; weekIndex < sortedKeys.length; weekIndex++) {
      final weekKey = sortedKeys[weekIndex];
      final sessions = weeklyGroups[weekKey]!;

      // En-tête de semaine
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryGold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: _primaryGold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _getWeekLabel(weekKey),
                      style: TextStyle(color: _primaryGold, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${sessions.length} séance${sessions.length > 1 ? 's' : ''}',
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );

      // Séances de la semaine
      for (int i = 0; i < sessions.length; i++) {
        final session = sessions[i];
        items.add(
          _SessionCard(
            session: session,
            index: i,
            animationController: _animationController,
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => WorkoutSessionDetailPage(session: session)))
                  .then((_) => _loadSessions());
            },
            onDelete: () => _deleteSession(session),
            formatDuration: _formatDuration,
          ),
        );
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => items[index],
        childCount: items.length,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(color: _textLight, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: _textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGold : _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _primaryGold : _cardBgLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : _textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final WorkoutSession session;
  final int index;
  final AnimationController animationController;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(int?) formatDuration;

  const _SessionCard({
    required this.session,
    required this.index,
    required this.animationController,
    required this.onTap,
    required this.onDelete,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE', 'fr_FR').format(session.startTime);
    final capitalizedDay = dayName[0].toUpperCase() + dayName.substring(1);

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
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _cardBgLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Date badge
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryGold.withOpacity(0.2), _primaryOrange.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              capitalizedDay.substring(0, 3),
                              style: TextStyle(
                                color: _primaryGold,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${session.startTime.day}',
                              style: const TextStyle(
                                color: _textLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.name ?? 'Séance d\'entraînement',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(session.startTime),
                              style: TextStyle(fontSize: 13, color: _textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 20, color: _primaryRed.withOpacity(0.7)),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _InfoChip(icon: Icons.fitness_center, label: '${session.exercises.length} exos'),
                      const SizedBox(width: 8),
                      _InfoChip(icon: Icons.timer_outlined, label: formatDuration(session.durationMinutes)),
                      if (session.totalVolume > 0) ...[
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.trending_up, label: '${session.totalVolume.toStringAsFixed(0)} kg'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _textMuted),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: _textMuted)),
        ],
      ),
    );
  }
}
