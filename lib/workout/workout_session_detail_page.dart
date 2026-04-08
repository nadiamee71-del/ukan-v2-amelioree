import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_session.dart';
import '../components/exercise_icon_helper.dart';
import '../models/exercise_library_item.dart';
import '../data/demo_exercises.dart';
import '../models/user_exercises_notifier.dart';
import '../exercises/exercise_detail_pro_page.dart';
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

/// Page de détail d'une séance enregistrée - Design immersif PRO
class WorkoutSessionDetailPage extends StatefulWidget {
  final WorkoutSession session;

  const WorkoutSessionDetailPage({super.key, required this.session});

  @override
  State<WorkoutSessionDetailPage> createState() => _WorkoutSessionDetailPageState();
}

class _WorkoutSessionDetailPageState extends State<WorkoutSessionDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return 'Non terminée';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h${mins > 0 ? ' $mins min' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

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
                  _primaryGold.withOpacity(0.15),
                  _darkBg,
                ],
                stops: const [0.0, 0.35],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar moderne
              SliverAppBar(
                expandedHeight: 220,
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
                      child: _buildHeader(session),
                    ),
                  ),
                ),
              ),

              // Stats rapides
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildQuickStats(session),
                ),
              ),

              // Liste des exercices
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildSectionTitle('Exercices', Icons.fitness_center),
                        );
                      }
                      final exerciseIndex = index - 1;
                      if (exerciseIndex < session.exercises.length) {
                        return _ExerciseCard(
                          exercise: session.exercises[exerciseIndex],
                          index: exerciseIndex,
                          animationController: _animationController,
                        );
                      }
                      return const SizedBox(height: 40);
                    },
                    childCount: session.exercises.length + 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WorkoutSession session) {
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
                      colors: [_primaryGold, _primaryOrange],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGold.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name ?? 'Séance d\'entraînement',
                        style: const TextStyle(
                          color: _textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(session.startTime),
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
    );
  }

  Widget _buildQuickStats(WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBgLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickStat(
              icon: Icons.schedule,
              label: 'Heure',
              value: _formatTime(session.startTime),
              color: _primaryBlue,
            ),
          ),
          Container(width: 1, height: 50, color: _cardBgLight),
          Expanded(
            child: _QuickStat(
              icon: Icons.timer,
              label: 'Durée',
              value: _formatDuration(session.durationMinutes),
              color: _primaryGreen,
            ),
          ),
          Container(width: 1, height: 50, color: _cardBgLight),
          Expanded(
            child: _QuickStat(
              icon: Icons.fitness_center,
              label: 'Exercices',
              value: '${session.exercises.length}',
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
          style: TextStyle(color: _textLight, fontSize: 15, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Carte d'exercice moderne et immersive
class _ExerciseCard extends StatelessWidget {
  final ExercisePerformance exercise;
  final int index;
  final AnimationController animationController;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
    required this.animationController,
  });

  Color _getMuscleGroupColor() {
    final name = exercise.exerciseName.toLowerCase();
    if (name.contains('pecto') || name.contains('développé')) return _primaryRed;
    if (name.contains('dos') || name.contains('rowing') || name.contains('tirage')) return _primaryOrange;
    if (name.contains('jambe') || name.contains('squat') || name.contains('fente')) return _primaryPurple;
    if (name.contains('abdo') || name.contains('gainage')) return _primaryGreen;
    if (name.contains('biceps')) return const Color(0xFFFF2D55);
    if (name.contains('triceps')) return _primaryBlue;
    if (name.contains('épaule') || name.contains('delto')) return _primaryGold;
    return _textMuted;
  }

  String _getMuscleGroupName() {
    final name = exercise.exerciseName.toLowerCase();
    if (name.contains('pecto') || name.contains('développé')) return 'Pectoraux';
    if (name.contains('dos') || name.contains('rowing') || name.contains('tirage')) return 'Dos';
    if (name.contains('jambe') || name.contains('squat') || name.contains('fente')) return 'Jambes';
    if (name.contains('abdo') || name.contains('gainage')) return 'Abdominaux';
    if (name.contains('biceps')) return 'Biceps';
    if (name.contains('triceps')) return 'Triceps';
    if (name.contains('épaule') || name.contains('delto')) return 'Épaules';
    return 'Autres';
  }

  String _getDifficultyLevel() {
    final avgWeight = exercise.sets
            .where((s) => s.weight != null)
            .map((s) => s.weight!)
            .fold<double>(0, (a, b) => a + b) /
        (exercise.sets.where((s) => s.weight != null).length > 0
            ? exercise.sets.where((s) => s.weight != null).length
            : 1);

    if (avgWeight < 20) return 'Débutant';
    if (avgWeight < 40) return 'Intermédiaire';
    if (avgWeight < 60) return 'Avancé';
    return 'Athlète';
  }

  ExerciseLibraryItem? _findExerciseInLibrary() {
    try {
      return DemoExercises.allExercises.firstWhere((e) => e.id == exercise.exerciseId);
    } catch (e) {
      final userExercisesNotifier = UserExercisesNotifier();
      return userExercisesNotifier.getUserExerciseById(exercise.exerciseId);
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final muscleColor = _getMuscleGroupColor();
    final muscleGroup = _getMuscleGroupName();
    final difficulty = _getDifficultyLevel();
    final exerciseItem = _findExerciseInLibrary();

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          (0.2 + index * 0.1).clamp(0.0, 0.7),
          (0.5 + index * 0.1).clamp(0.4, 1.0),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: muscleColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: muscleColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: exerciseItem != null
                ? () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailProPage(exercise: exerciseItem),
                      ),
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header coloré
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [muscleColor.withOpacity(0.2), muscleColor.withOpacity(0.05)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [muscleColor, muscleColor.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
                              exercise.exerciseName,
                              style: const TextStyle(
                                color: _textLight,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _MiniChip(label: muscleGroup, color: muscleColor),
                                const SizedBox(width: 8),
                                _MiniChip(label: difficulty, color: _textMuted),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (exerciseItem != null)
                        Icon(Icons.chevron_right, color: _textMuted, size: 24),
                    ],
                  ),
                ),

                // Contenu - séries
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: exercise.sets.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Aucune série enregistrée',
                              style: TextStyle(color: _textMuted, fontSize: 14),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // En-tête du tableau
                            Row(
                              children: [
                                _TableHeader('Série', flex: 1),
                                _TableHeader('Rép.', flex: 1),
                                _TableHeader('Charge', flex: 1),
                                _TableHeader('Repos', flex: 1, isLast: true),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Séries
                            ...exercise.sets.map((set) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: muscleColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${set.setNumber}',
                                            style: TextStyle(
                                              color: muscleColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        set.reps?.toString() ?? '-',
                                        style: const TextStyle(color: _textLight, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        set.weight != null
                                            ? '${set.weight!.toStringAsFixed(1)} kg'
                                            : (set.type == SetType.time && set.durationSeconds != null
                                                ? _formatDuration(set.durationSeconds!)
                                                : '-'),
                                        style: const TextStyle(color: _textLight, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        set.restSeconds != null ? '${set.restSeconds}s' : '-',
                                        style: TextStyle(color: _textMuted, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            // Stats en bas
                            if (exercise.maxWeight != null || exercise.totalVolume > 0) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _cardBgLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    if (exercise.maxWeight != null)
                                      _StatBadge(
                                        icon: Icons.arrow_upward,
                                        label: 'Max',
                                        value: '${exercise.maxWeight!.toStringAsFixed(1)} kg',
                                        color: muscleColor,
                                      ),
                                    if (exercise.totalVolume > 0)
                                      _StatBadge(
                                        icon: Icons.trending_up,
                                        label: 'Volume',
                                        value: '${exercise.totalVolume.toStringAsFixed(0)} kg',
                                        color: _primaryGreen,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  final int flex;
  final bool isLast;

  const _TableHeader(this.label, {this.flex = 1, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600),
        textAlign: isLast ? TextAlign.center : TextAlign.center,
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: _textMuted, fontSize: 11)),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}
