import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'hard_challenge_model.dart';
import 'create_challenge_page.dart';

// Palette de couleurs (cohérente avec le reste de l'app)
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryPurple = Color(0xFFA855F7);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryCyan = Color(0xFF22D3EE);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

/// Page principale du Hard Challenge
class HardChallengePage extends StatefulWidget {
  const HardChallengePage({super.key});

  @override
  State<HardChallengePage> createState() => _HardChallengePageState();
}

class _HardChallengePageState extends State<HardChallengePage> {
  final _notifier = HardChallengeNotifier();
  late HardChallenge _challenge;
  late List<DailyHabit> _habits;

  @override
  void initState() {
    super.initState();
    // Charger le challenge actuel ou le mock
    _challenge = _notifier.currentChallenge ?? HardChallengeData.getMockChallenge();
    _habits = List.from(_challenge.habits);
  }

  void _toggleHabit(String habitId) {
    setState(() {
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index].isDone = !_habits[index].isDone;
      }
    });
  }

  void _showUpdateDayDialog() {
    final completedCount = _habits.where((h) => h.isDone).length;
    final allDone = completedCount == _habits.length;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              allDone ? Icons.emoji_events : Icons.check_circle,
              color: allDone ? _primaryGold : _primaryGreen,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              allDone ? 'Journée parfaite ! 🔥' : 'Journée mise à jour !',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount/${_habits.length} objectifs complétés',
              style: const TextStyle(
                fontSize: 14,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hard Challenge',
          style: TextStyle(
            color: _textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Bouton partager
          IconButton(
            icon: const Icon(Icons.share_outlined, color: _textMuted),
            onPressed: () => _showShareDialog(),
          ),
          // Bouton créer
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: _primaryGold),
            onPressed: () => _openCreateChallengePage(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1 - Résumé du Challenge
            _buildChallengeSummary(),
            const SizedBox(height: 24),
            
            // Section 2 - Objectifs du jour
            _buildHabitsSection(),
            const SizedBox(height: 24),
            
            // Section 3 - Statistiques & Calendrier
            _buildStatsSection(),
            const SizedBox(height: 24),
            
            // Section 4 - Participants
            _buildParticipantsSection(),
            const SizedBox(height: 24),
            
            // Section 5 - Challenges prédéfinis
            _buildTemplatesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Section 1 - Résumé du Challenge
  Widget _buildChallengeSummary() {
    final progress = _challenge.currentDay / _challenge.totalDays;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryOrange.withOpacity(0.2),
            _primaryGold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec icône
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department, color: _primaryGold, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _challenge.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textLight,
                      ),
                    ),
                    Text(
                      '${_challenge.totalDays} jours',
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge participants
              if (_challenge.participants.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group, size: 14, color: _primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        '${_challenge.participants.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Jour actuel
          Row(
            children: [
              Text(
                'Jour ${_challenge.currentDay}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _primaryGold,
                ),
              ),
              Text(
                ' / ${_challenge.totalDays}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _cardBgLight,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryGold),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% complété',
            style: const TextStyle(
              fontSize: 12,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 16),
          
          // Citation motivante
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote, color: _primaryGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _challenge.motivationalQuote,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: _textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Bouton principal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUpdateDayDialog,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Valider ma journée'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 2 - Objectifs du jour
  Widget _buildHabitsSection() {
    final categories = HabitCategory.values;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Objectifs du jour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textLight,
              ),
            ),
            Text(
              '${_habits.where((h) => h.isDone).length}/${_habits.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _primaryGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ...categories.map((category) {
          final categoryHabits = _habits.where((h) => h.category == category).toList();
          if (categoryHabits.isEmpty) return const SizedBox.shrink();
          
          return _buildHabitCategory(category, categoryHabits);
        }),
      ],
    );
  }

  Widget _buildHabitCategory(HabitCategory category, List<DailyHabit> habits) {
    Color categoryColor;
    IconData categoryIcon;
    
    switch (category) {
      case HabitCategory.workout:
        categoryColor = _primaryRed;
        categoryIcon = Icons.fitness_center;
        break;
      case HabitCategory.activity:
        categoryColor = _primaryBlue;
        categoryIcon = Icons.directions_walk;
        break;
      case HabitCategory.nutrition:
        categoryColor = _primaryGreen;
        categoryIcon = Icons.restaurant;
        break;
      case HabitCategory.recovery:
        categoryColor = _primaryPurple;
        categoryIcon = Icons.self_improvement;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de catégorie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(categoryIcon, color: categoryColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  habits.first.categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${habits.where((h) => h.isDone).length}/${habits.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des habitudes
          ...habits.map((habit) => _buildHabitTile(habit, categoryColor)),
        ],
      ),
    );
  }

  Widget _buildHabitTile(DailyHabit habit, Color color) {
    return InkWell(
      onTap: () => _toggleHabit(habit.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _borderColor.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            // Icône
            Icon(
              _getHabitIcon(habit.iconType),
              color: habit.isDone ? color : _textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            
            // Label et valeur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: habit.isDone ? _textLight : _textMuted,
                      decoration: habit.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (habit.target != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      habit.value != null 
                          ? '${habit.value} / ${habit.target}'
                          : habit.target!,
                      style: TextStyle(
                        fontSize: 12,
                        color: habit.isDone ? color.withOpacity(0.7) : _textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Checkbox
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: habit.isDone ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: habit.isDone ? color : _textMuted,
                  width: 2,
                ),
              ),
              child: habit.isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getHabitIcon(IconType type) {
    switch (type) {
      case IconType.checkCircle:
        return Icons.check_circle_outline;
      case IconType.fitness:
        return Icons.fitness_center;
      case IconType.walk:
        return Icons.directions_walk;
      case IconType.run:
        return Icons.directions_run;
      case IconType.water:
        return Icons.water_drop_outlined;
      case IconType.food:
        return Icons.restaurant;
      case IconType.sleep:
        return Icons.bedtime_outlined;
      case IconType.stretch:
        return Icons.self_improvement;
      case IconType.pushup:
        return Icons.fitness_center;
      case IconType.squat:
        return Icons.accessibility_new;
      case IconType.plank:
        return Icons.timer;
      case IconType.abs:
        return Icons.sports_gymnastics;
      case IconType.rope:
        return Icons.sports;
      case IconType.burpee:
        return Icons.local_fire_department;
      case IconType.dumbbell:
        return Icons.fitness_center;
      case IconType.timer:
        return Icons.timer;
      case IconType.fire:
        return Icons.local_fire_department;
      case IconType.target:
        return Icons.gps_fixed;
      case IconType.group:
        return Icons.group_outlined;
      case IconType.share:
        return Icons.share;
    }
  }

  /// Section 3 - Statistiques & Calendrier
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques & Calendrier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textLight,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mini calendrier
          _buildMiniCalendar(),
          const SizedBox(height: 20),
          
          // Stats ligne
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Jours réussis',
                '${_challenge.calendarData.values.where((v) => v).length}',
                _primaryGreen,
              ),
              Container(width: 1, height: 40, color: _borderColor),
              _buildStatItem(
                'Jours ratés',
                '${_challenge.calendarData.values.where((v) => !v).length}',
                _primaryRed,
              ),
              Container(width: 1, height: 40, color: _borderColor),
              _buildStatItem(
                'Taux de réussite',
                '${(_challenge.successRate * 100).toStringAsFixed(0)}%',
                _primaryGold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCalendar() {
    final daysInMonth = 31;
    final calendarData = _challenge.calendarData;
    
    return Column(
      children: [
        // Jours de la semaine
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
              .map((d) => SizedBox(
                    width: 36,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _textMuted,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        
        // Grille des jours
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(daysInMonth, (index) {
            final day = index + 1;
            final hasData = calendarData.containsKey(day);
            final isSuccess = calendarData[day] ?? false;
            final isToday = day == _challenge.currentDay;
            
            Color bgColor;
            Color textColor;
            
            if (!hasData) {
              bgColor = _cardBgLight;
              textColor = _textMuted;
            } else if (isSuccess) {
              bgColor = _primaryGreen;
              textColor = Colors.white;
            } else {
              bgColor = _primaryRed;
              textColor = Colors.white;
            }
            
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: _primaryGold, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _textMuted,
          ),
        ),
      ],
    );
  }

  /// Section 4 - Participants
  Widget _buildParticipantsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textLight,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showInviteDialog(),
                icon: const Icon(Icons.person_add, size: 18, color: _primaryGold),
                label: const Text('Inviter', style: TextStyle(color: _primaryGold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_challenge.participants.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.group_outlined, color: _textMuted.withOpacity(0.5), size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Invite des amis ou ton coach pour relever ce défi ensemble !',
                      style: TextStyle(color: _textMuted, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            // Liste des participants
            ...List.generate(_challenge.participants.length, (index) {
              final isMe = index == 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? _primaryGold.withOpacity(0.1) : _cardBgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: isMe ? Border.all(color: _primaryGold.withOpacity(0.3)) : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isMe ? _primaryGold : _primaryBlue,
                      child: Text(
                        isMe ? 'M' : 'U${index}',
                        style: TextStyle(
                          color: isMe ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMe ? 'Moi' : 'Utilisateur ${index}',
                            style: const TextStyle(
                              color: _textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            isMe ? 'Jour ${_challenge.currentDay}' : 'Jour ${_challenge.currentDay - index}',
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isMe)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primaryGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '1er',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Section 5 - Challenges prédéfinis
  Widget _buildTemplatesSection() {
    final templates = HardChallengeData.getTemplates();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Challenges populaires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textLight,
              ),
            ),
            TextButton.icon(
              onPressed: () => _openCreateChallengePage(),
              icon: const Icon(Icons.add, size: 18, color: _primaryGold),
              label: const Text('Créer', style: TextStyle(color: _primaryGold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateCard(template);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(ChallengeTemplate template) {
    return GestureDetector(
      onTap: () => _showStartChallengeDialog(template),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: template.color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: template.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(template.icon, color: template.color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              template.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _textLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              '${template.defaultDays} jours',
              style: TextStyle(
                fontSize: 12,
                color: template.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogs
  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Partager le challenge',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textLight,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add, color: _primaryBlue),
              ),
              title: const Text('Inviter à participer', style: TextStyle(color: _textLight)),
              subtitle: const Text('Les invités feront le challenge avec toi', style: TextStyle(color: _textMuted, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _showInviteDialog();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports, color: _primaryGold),
              ),
              title: const Text('Partager avec mon coach', style: TextStyle(color: _textLight)),
              subtitle: const Text('Ton coach pourra suivre ta progression', style: TextStyle(color: _textMuted, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _showShareWithCoachDialog();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.share, color: _primaryGreen),
              ),
              title: const Text('Partager avec la communauté', style: TextStyle(color: _textLight)),
              subtitle: const Text('Montre ton challenge aux autres', style: TextStyle(color: _textMuted, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challenge partagé avec la communauté !'),
                    backgroundColor: _primaryGreen,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showShareWithCoachDialog() {
    // Liste de coachs mock pour la démo
    final mockCoaches = [
      {'id': 'coach_1', 'name': 'Sophie Martin', 'specialty': 'Perte de poids'},
      {'id': 'coach_2', 'name': 'Marc Dubois', 'specialty': 'Prise de masse'},
      {'id': 'coach_3', 'name': 'Julie Leroy', 'specialty': 'Fitness'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Partager avec mon coach',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ton coach pourra voir ta progression et t\'encourager',
              style: TextStyle(color: _textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...mockCoaches.map((coach) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _primaryGold.withOpacity(0.2),
                  child: Text(
                    coach['name']!.substring(0, 1),
                    style: const TextStyle(color: _primaryGold, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(coach['name']!, style: const TextStyle(color: _textLight)),
                subtitle: Text(coach['specialty']!, style: const TextStyle(color: _textMuted, fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Partager',
                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Challenge partagé avec ${coach['name']} !'),
                      backgroundColor: _primaryGold,
                    ),
                  );
                },
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Inviter des participants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textLight,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports, color: _primaryGold),
              ),
              title: const Text('Inviter mon coach', style: TextStyle(color: _textLight)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invitation envoyée à ton coach !'),
                    backgroundColor: _primaryGold,
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.group, color: _primaryBlue),
              ),
              title: const Text('Inviter des amis', style: TextStyle(color: _textLight)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lien d\'invitation copié !'),
                    backgroundColor: _primaryBlue,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showStartChallengeDialog(ChallengeTemplate template) {
    int selectedDays = template.defaultDays;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: template.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(template.icon, color: template.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textLight,
                          ),
                        ),
                        Text(
                          template.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Durée du challenge',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _textLight,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: template.availableDurations.map((days) {
                  final isSelected = days == selectedDays;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedDays = days),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? template.color : _cardBgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? template.color : _borderColor,
                        ),
                      ),
                      child: Text(
                        '$days jours',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : _textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Challenge "${template.name}" démarré pour $selectedDays jours !'),
                        backgroundColor: template.color,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: template.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Démarrer le challenge',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreateChallengePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateChallengePage(),
      ),
    );
  }
}
