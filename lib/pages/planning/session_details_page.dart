import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/planning.dart';
import '../../models/difficulty_entry.dart';
import '../../services/difficulty_service.dart';
import '../../components/difficulty_form.dart';
import '../../models/theme_notifier.dart';
import '../../models/rooms.dart';

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

/// Page de détails d'une séance du planning - Design immersif
class SessionDetailsPage extends StatefulWidget {
  final PlannedSession session;

  const SessionDetailsPage({
    super.key,
    required this.session,
  });

  @override
  State<SessionDetailsPage> createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends State<SessionDetailsPage>
    with SingleTickerProviderStateMixin {
  final _difficultyService = DifficultyService();
  final _roomsNotifier = RoomsNotifier();
  List<DifficultyEntry> _difficultyEntries = [];
  List<RoomExercise> _exercises = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadDifficultyEntries();
    _loadExercises();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadExercises() {
    if (widget.session.type == PlannedSessionType.room) {
      final currentRoom = _roomsNotifier.currentRoom;
      if (currentRoom != null &&
          (currentRoom.id == widget.session.id ||
              currentRoom.workoutTitle == widget.session.title)) {
        setState(() {
          _exercises = currentRoom.exercises;
        });
      } else {
        setState(() {
          _exercises = [];
        });
      }
    }
  }

  Future<void> _loadDifficultyEntries() async {
    setState(() => _isLoading = true);

    final allEntries = await _difficultyService.getAll();
    _difficultyEntries = allEntries
        .where((entry) => entry.sessionId == widget.session.id)
        .toList();

    setState(() => _isLoading = false);
  }

  bool get _isFutureSession {
    return widget.session.dateTime.isAfter(DateTime.now());
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'fr_FR').format(dateTime);
  }

  Color _getDifficultyColor(int level) {
    if (level <= 3) return _primaryGreen;
    if (level <= 6) return _primaryOrange;
    return _primaryRed;
  }

  Future<void> _showModifyDifficultyDialog(DifficultyEntry entry) async {
    await showDialog<DifficultyEntry>(
      context: context,
      builder: (context) => DifficultyForm(
        exerciseId: entry.exerciseId,
        sessionId: entry.sessionId,
        onSave: (newEntry) async {
          final updatedEntry = DifficultyEntry(
            id: entry.id,
            exerciseId: newEntry.exerciseId,
            sessionId: newEntry.sessionId,
            date: newEntry.date,
            level: newEntry.level,
            comment: newEntry.comment,
            shared: newEntry.shared,
          );
          await _difficultyService.saveDifficulty(updatedEntry);
          await _loadDifficultyEntries();
        },
      ),
    );
  }

  Future<void> _deleteDifficulty(DifficultyEntry entry) async {
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
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette évaluation ?',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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
      await _difficultyService.deleteDifficulty(entry.id);
      await _loadDifficultyEntries();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Évaluation supprimée'),
            backgroundColor: _primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _toggleShare(DifficultyEntry entry) async {
    HapticFeedback.lightImpact();
    final updatedEntry = entry.copyWith(shared: !entry.shared);
    await _difficultyService.saveDifficulty(updatedEntry);
    await _loadDifficultyEntries();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedEntry.shared
              ? '✨ Partagé avec la communauté'
              : 'Partage retiré',
        ),
        backgroundColor: updatedEntry.shared ? _primaryGreen : _textMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  _getTypeColor(widget.session.type).withOpacity(0.15),
                  _darkBg,
                ],
                stops: const [0.0, 0.4],
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: _primaryGold))
              : CustomScrollView(
                  slivers: [
                    // AppBar moderne
                    SliverAppBar(
                      expandedHeight: 200,
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
                            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                            child: _buildHeader(),
                          ),
                        ),
                      ),
                    ),

                    // Contenu
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats rapides
                            _buildQuickStats(),
                            const SizedBox(height: 24),

                            // Exercices
                            if (_exercises.isNotEmpty) ...[
                              _buildSectionTitle('Exercices', Icons.fitness_center),
                              const SizedBox(height: 12),
                              ..._exercises.asMap().entries.map(
                                (e) => _buildExerciseCard(e.value, e.key),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Section difficulté
                            if (_isFutureSession)
                              _buildFutureSessionInfo()
                            else ...[
                              _buildSectionTitle('Niveaux de difficulté', Icons.assessment),
                              const SizedBox(height: 12),
                              if (_difficultyEntries.isEmpty)
                                _buildEmptyDifficulty()
                              else
                                ..._difficultyEntries.asMap().entries.map(
                                  (e) => _buildDifficultyCard(e.value, e.key),
                                ),
                            ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTypeColor(widget.session.type),
                        _getTypeColor(widget.session.type).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _getTypeColor(widget.session.type).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(_getTypeIcon(widget.session.type), color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.title,
                        style: const TextStyle(
                          color: _textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _TypeBadge(type: widget.session.type),
                          const SizedBox(width: 8),
                          _StatusBadge(status: widget.session.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBgLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickStat(
              icon: Icons.calendar_today,
              label: 'Date',
              value: _formatDateTime(widget.session.dateTime),
              color: _primaryBlue,
            ),
          ),
          Container(width: 1, height: 50, color: _cardBgLight),
          Expanded(
            child: _QuickStat(
              icon: Icons.schedule,
              label: 'Heure',
              value: _formatTime(widget.session.dateTime),
              color: _primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _primaryGold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryGold, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: _textLight,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(RoomExercise exercise, int index) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (0.3 + index * 0.1).clamp(0.0, 0.8),
          (0.6 + index * 0.1).clamp(0.5, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - animation.value), 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryGold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryGold.withOpacity(0.2), _primaryOrange.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: _primaryGold,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (exercise.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      exercise.description,
                      style: TextStyle(color: _textMuted, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: _primaryBlue, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${exercise.durationSeconds}s',
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBlue.withOpacity(0.15), _primaryBlue.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.info_outline, color: _primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Séance à venir',
                  style: TextStyle(
                    color: _textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu pourras évaluer la difficulté après avoir terminé cette séance.',
                  style: TextStyle(color: _textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDifficulty() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assessment_outlined, size: 48, color: _textMuted),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune évaluation',
            style: TextStyle(
              color: _textLight,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoute une évaluation pour suivre ta progression',
            style: TextStyle(color: _textMuted, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddDifficultyDialog,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Ajouter une évaluation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(DifficultyEntry entry, int index) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (0.4 + index * 0.1).clamp(0.0, 0.8),
          (0.7 + index * 0.1).clamp(0.5, 1.0),
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _getDifficultyColor(entry.level).withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(entry.level).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: _getDifficultyColor(entry.level),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getExerciseName(entry.exerciseId),
                        style: const TextStyle(
                          color: _textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _DifficultyIndicator(level: entry.level),
                          if (entry.shared) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _primaryGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.share, color: _primaryGreen, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Partagé',
                                    style: TextStyle(color: _primaryGreen, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Commentaire
            if (entry.comment != null && entry.comment!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cardBgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.comment, color: _textMuted, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.comment!,
                        style: TextStyle(color: _textMuted, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Modifier',
                    color: _primaryGold,
                    onTap: () => _showModifyDifficultyDialog(entry),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Supprimer',
                    color: _primaryRed,
                    onTap: () => _deleteDifficulty(entry),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: entry.shared ? Icons.share : Icons.share_outlined,
                    label: entry.shared ? 'Partagé' : 'Partager',
                    color: entry.shared ? _primaryGreen : _primaryBlue,
                    onTap: () => _toggleShare(entry),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDifficultyDialog() async {
    await showDialog<DifficultyEntry>(
      context: context,
      builder: (context) => DifficultyForm(
        exerciseId: 'exercise_${widget.session.id}',
        sessionId: widget.session.id,
        onSave: (entry) async {
          await _difficultyService.saveDifficulty(entry);
          await _loadDifficultyEntries();
        },
      ),
    );
  }

  IconData _getTypeIcon(PlannedSessionType type) {
    switch (type) {
      case PlannedSessionType.solo:
        return Icons.person;
      case PlannedSessionType.coach:
        return Icons.school;
      case PlannedSessionType.room:
        return Icons.groups;
    }
  }

  Color _getTypeColor(PlannedSessionType type) {
    switch (type) {
      case PlannedSessionType.solo:
        return _primaryBlue;
      case PlannedSessionType.coach:
        return _primaryGold;
      case PlannedSessionType.room:
        return _primaryPurple;
    }
  }

  String _getExerciseName(String exerciseId) {
    try {
      final exercise = _exercises.firstWhere((e) => e.id == exerciseId);
      return exercise.name;
    } catch (e) {
      switch (exerciseId.toLowerCase()) {
        case 'squat':
        case 'squats':
          return 'Squats';
        case 'pushup':
        case 'pompes':
          return 'Pompes';
        case 'plank':
        case 'gainage':
          return 'Gainage';
        case 'lunges':
        case 'fentes':
          return 'Fentes';
        default:
          return 'Exercice: $exerciseId';
      }
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final PlannedSessionType type;

  const _TypeBadge({required this.type});

  String get _label {
    switch (type) {
      case PlannedSessionType.solo:
        return 'Solo';
      case PlannedSessionType.coach:
        return 'Coach';
      case PlannedSessionType.room:
        return 'Room';
    }
  }

  Color get _color {
    switch (type) {
      case PlannedSessionType.solo:
        return _primaryBlue;
      case PlannedSessionType.coach:
        return _primaryGold;
      case PlannedSessionType.room:
        return _primaryPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PlannedSessionStatus status;

  const _StatusBadge({required this.status});

  String get _label {
    switch (status) {
      case PlannedSessionStatus.planned:
        return 'Prévu';
      case PlannedSessionStatus.done:
        return 'Terminé';
      case PlannedSessionStatus.cancelled:
        return 'Annulé';
    }
  }

  Color get _color {
    switch (status) {
      case PlannedSessionStatus.planned:
        return _textMuted;
      case PlannedSessionStatus.done:
        return _primaryGreen;
      case PlannedSessionStatus.cancelled:
        return _primaryRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == PlannedSessionStatus.done)
            Icon(Icons.check, color: _color, size: 14),
          if (status == PlannedSessionStatus.done) const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: _textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: _textLight, fontSize: 13, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DifficultyIndicator extends StatelessWidget {
  final int level;

  const _DifficultyIndicator({required this.level});

  Color get _color {
    if (level <= 3) return _primaryGreen;
    if (level <= 6) return _primaryOrange;
    return _primaryRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(10, (index) {
            return Container(
              width: 6,
              height: 14,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: index < level ? _color : _cardBgLight,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
          const SizedBox(width: 6),
          Text(
            '$level/10',
            style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
