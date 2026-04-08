import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_story.dart';

/// ─────────────────────────────────────────────
/// Sport Gaming™ - Quêtes Journalières
/// Design Gaming Immersif
/// ─────────────────────────────────────────────

// Palette Gaming Immersif
const Color _primaryGold = Color(0xFFFFD700);
const Color _accentOrange = Color(0xFFFF6B35);
const Color _deepPurple = Color(0xFF1A0A2E);
const Color _darkBg = Color(0xFF0D0D1A);
const Color _cardBg = Color(0xFF1E1E3F);
const Color _cardBgLight = Color(0xFF2A2A5A);
const Color _successGreen = Color(0xFF00E676);
const Color _textLight = Color(0xFFE0E0E0);

class DailyQuestsPage extends StatefulWidget {
  const DailyQuestsPage({super.key});

  @override
  State<DailyQuestsPage> createState() => _DailyQuestsPageState();
}

class _DailyQuestsPageState extends State<DailyQuestsPage> with SingleTickerProviderStateMixin {
  final _gameNotifier = GameStoryNotifier();
  late List<QuestItem> _quests;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _gameNotifier.addListener(_onGameChanged);
    
    // Animation de pulsation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Initialiser les quêtes
    _quests = _gameNotifier.dailyQuests.map((q) {
      String emoji;
      IconData icon;
      Color color;
      switch (q.id) {
        case 'quest1':
          emoji = '💪';
          icon = Icons.fitness_center;
          color = _accentOrange;
          break;
        case 'quest2':
          emoji = '💧';
          icon = Icons.water_drop;
          color = Colors.blue;
          break;
        case 'quest3':
          emoji = '🧘';
          icon = Icons.accessibility_new;
          color = Colors.purple;
          break;
        case 'quest4':
          emoji = '😴';
          icon = Icons.bedtime;
          color = Colors.indigo;
          break;
        case 'quest5':
          emoji = '🚶';
          icon = Icons.directions_walk;
          color = _successGreen;
          break;
        default:
          emoji = '⭐';
          icon = Icons.assignment;
          color = _primaryGold;
      }
      return QuestItem(
        id: q.id,
        title: q.title,
        description: q.description,
        xpReward: q.xpReward,
        icon: icon,
        emoji: emoji,
        color: color,
        tag: q.tag,
        isCompleted: q.isCompleted,
      );
    }).toList();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gameNotifier.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    setState(() {});
  }

  void _completeQuest(QuestItem quest) {
    if (quest.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚡ Quête déjà validée !'),
          backgroundColor: _cardBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _quests = _quests.map((q) {
        if (q.id == quest.id) {
          return q.copyWith(isCompleted: true);
        }
        return q;
      }).toList();
    });

    _gameNotifier.completeQuest(quest.id);

    // Afficher confirmation gaming
    _showQuestCompletedDialog(quest);
  }

  void _showQuestCompletedDialog(QuestItem quest) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_cardBgLight, _cardBg],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _primaryGold.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: _primaryGold.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône avec glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryGold, _accentOrange],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryGold.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'QUÊTE VALIDÉE !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _primaryGold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                quest.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: _textLight,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // XP gagné
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _successGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _successGreen),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: _primaryGold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+${quest.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _successGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGold,
                    foregroundColor: _darkBg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'CONTINUER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int get _totalAvailableXP {
    return _quests
        .where((q) => !q.isCompleted)
        .fold<int>(0, (sum, q) => sum + q.xpReward);
  }

  int get _completedCount => _quests.where((q) => q.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Background avec effet
          _buildBackground(),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Contenu
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bannière résumé
                        _buildSummaryCard(),
                        const SizedBox(height: 24),
                        
                        // Titre section
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_primaryGold, _accentOrange],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'QUÊTES DU JOUR',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _textLight,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Liste des quêtes
                        ..._quests.asMap().entries.map((entry) {
                          final index = entry.key;
                          final quest = entry.value;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: _QuestCard(
                                    quest: quest,
                                    onTap: () => _completeQuest(quest),
                                    pulseAnimation: _pulseAnimation,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _deepPurple,
            _darkBg,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _StarsPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryGold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.arrow_back, color: _textLight, size: 20),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚔️ Quêtes Journalières',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Complète-les pour gagner de l\'XP !',
                  style: TextStyle(
                    fontSize: 13,
                    color: _primaryGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final progress = _completedCount / _quests.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardBgLight, _cardBg],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _primaryGold.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progression du jour',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_completedCount / ${_quests.length}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _primaryGold,
                    ),
                  ),
                ],
              ),
              // Cercle de progression
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: _darkBg,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? _successGreen : _primaryGold,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // XP disponible
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _darkBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _successGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: _primaryGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  _totalAvailableXP > 0
                      ? '+$_totalAvailableXP XP disponible'
                      : '🎉 Toutes les quêtes complétées !',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _totalAvailableXP > 0 ? _successGreen : _primaryGold,
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

// ─────────────────────────────────────────────
// Widget carte quête
// ─────────────────────────────────────────────

class _QuestCard extends StatelessWidget {
  final QuestItem quest;
  final VoidCallback onTap;
  final Animation<double> pulseAnimation;

  const _QuestCard({
    required this.quest,
    required this.onTap,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: quest.isCompleted ? 1.0 : pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: quest.isCompleted
                    ? [_successGreen.withOpacity(0.2), _successGreen.withOpacity(0.1)]
                    : [_cardBgLight, _cardBg],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: quest.isCompleted
                    ? _successGreen
                    : quest.color.withOpacity(0.4),
                width: quest.isCompleted ? 2 : 1,
              ),
              boxShadow: quest.isCompleted
                  ? [
                      BoxShadow(
                        color: _successGreen.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: quest.isCompleted ? null : onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icône avec effet
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: quest.isCompleted
                              ? LinearGradient(colors: [_successGreen, _successGreen.withOpacity(0.7)])
                              : LinearGradient(colors: [quest.color, quest.color.withOpacity(0.7)]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: (quest.isCompleted ? _successGreen : quest.color).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: quest.isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 28)
                              : Text(quest.emoji, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Informations
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    quest.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: quest.isCompleted
                                          ? Colors.white60
                                          : Colors.white,
                                      decoration: quest.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                // Badge XP
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: quest.isCompleted
                                          ? [_successGreen, _successGreen.withOpacity(0.7)]
                                          : [_primaryGold, _accentOrange],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        quest.isCompleted ? Icons.check : Icons.star,
                                        size: 12,
                                        color: quest.isCompleted ? Colors.white : _darkBg,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        quest.isCompleted ? 'FAIT' : '+${quest.xpReward} XP',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: quest.isCompleted ? Colors.white : _darkBg,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              quest.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: quest.isCompleted
                                    ? Colors.white38
                                    : Colors.white60,
                              ),
                            ),
                            if (quest.tag != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getTagColor(quest.tag!).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _getTagColor(quest.tag!).withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  quest.tag!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getTagColor(quest.tag!),
                                  ),
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
          ),
        );
      },
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Story':
        return _primaryGold;
      case 'Santé':
        return _successGreen;
      case 'Habitude':
        return Colors.blue;
      case 'Social':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// ─────────────────────────────────────────────
// Painter pour les étoiles de fond
// ─────────────────────────────────────────────

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Dessiner des étoiles aléatoires
    final stars = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.05),
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.7, size.height * 0.08),
      Offset(size.width * 0.9, size.height * 0.12),
      Offset(size.width * 0.2, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width * 0.15, size.height * 0.4),
      Offset(size.width * 0.85, size.height * 0.45),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Modèle local pour une quête
// ─────────────────────────────────────────────

class QuestItem {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final IconData icon;
  final String emoji;
  final Color color;
  final String? tag;
  final bool isCompleted;

  QuestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.icon,
    required this.emoji,
    required this.color,
    this.tag,
    this.isCompleted = false,
  });

  QuestItem copyWith({bool? isCompleted}) {
    return QuestItem(
      id: id,
      title: title,
      description: description,
      xpReward: xpReward,
      icon: icon,
      emoji: emoji,
      color: color,
      tag: tag,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
