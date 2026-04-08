import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_story.dart';
import '../models/workout_history.dart';

/// ─────────────────────────────────────────────
/// Sport Gaming™ - Mes Niveaux
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

class StoryLevelsPage extends StatefulWidget {
  const StoryLevelsPage({super.key});

  @override
  State<StoryLevelsPage> createState() => _StoryLevelsPageState();
}

class _StoryLevelsPageState extends State<StoryLevelsPage> with SingleTickerProviderStateMixin {
  final _gameNotifier = GameStoryNotifier();
  final _workoutHistory = WorkoutHistoryNotifier();
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<GameLevel> _levels = const [
    GameLevel(
      level: 1,
      name: 'Apprenti',
      description: 'Complète 3 séances pour débloquer le niveau suivant',
      requiredSessions: 3,
    ),
    GameLevel(
      level: 2,
      name: 'Guerrier',
      description: 'Complète 5 séances pour débloquer le niveau suivant',
      requiredSessions: 5,
    ),
    GameLevel(
      level: 3,
      name: 'Champion',
      description: 'Complète 7 séances pour débloquer le niveau suivant',
      requiredSessions: 7,
    ),
    GameLevel(
      level: 4,
      name: 'Maître',
      description: 'Complète 10 séances pour débloquer le niveau suivant',
      requiredSessions: 10,
    ),
    GameLevel(
      level: 5,
      name: 'Légende',
      description: 'Tu as atteint le sommet !',
      requiredSessions: 15,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _gameNotifier.addListener(_onGameChanged);
    _workoutHistory.addListener(_onGameChanged);
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _gameNotifier.removeListener(_onGameChanged);
    _workoutHistory.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  int _getCompletedSessions() {
    return _workoutHistory.allEntries().length;
  }

  bool _isLevelUnlocked(int levelIndex) {
    final completed = _getCompletedSessions();
    if (levelIndex == 0) return true;
    
    int requiredTotal = 0;
    for (int i = 0; i < levelIndex; i++) {
      requiredTotal += _levels[i].requiredSessions;
    }
    return completed >= requiredTotal;
  }

  bool _isLevelCompleted(int levelIndex) {
    final completed = _getCompletedSessions();
    int requiredTotal = 0;
    for (int i = 0; i <= levelIndex; i++) {
      requiredTotal += _levels[i].requiredSessions;
    }
    return completed >= requiredTotal;
  }

  String _getLevelEmoji(int level) {
    switch (level) {
      case 1:
        return '🌱';
      case 2:
        return '⚔️';
      case 3:
        return '🏆';
      case 4:
        return '🔥';
      case 5:
        return '👑';
      default:
        return '⭐';
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return _accentOrange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.purple;
      case 5:
        return _primaryGold;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedSessions = _getCompletedSessions();
    final currentLevel = _gameNotifier.currentLevel;

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Background
          _buildBackground(),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(currentLevel),
                
                // Contenu
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte progression
                        _buildProgressionCard(completedSessions, currentLevel),
                        const SizedBox(height: 24),
                        
                        // Titre section
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [_primaryGold, _accentOrange]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '📊 PARCOURS DE NIVEAUX',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _textLight,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Liste des niveaux
                        ..._levels.asMap().entries.map((entry) {
                          final index = entry.key;
                          final level = entry.value;
                          final isUnlocked = _isLevelUnlocked(index);
                          final isCompleted = _isLevelCompleted(index);
                          final isCurrentLevel = currentLevel == level.level;
                          
                          int progress = 0;
                          if (isUnlocked && !isCompleted) {
                            int previousRequired = 0;
                            for (int i = 0; i < index; i++) {
                              previousRequired += _levels[i].requiredSessions;
                            }
                            final remaining = completedSessions - previousRequired;
                            progress = ((remaining / level.requiredSessions) * 100).clamp(0, 100).toInt();
                          } else if (isCompleted) {
                            progress = 100;
                          }
                          
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: _LevelCard(
                                    level: level,
                                    emoji: _getLevelEmoji(level.level),
                                    color: _getLevelColor(level.level),
                                    isUnlocked: isUnlocked,
                                    isCompleted: isCompleted,
                                    isCurrentLevel: isCurrentLevel,
                                    progress: progress,
                                    glowAnimation: _glowAnimation,
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
          colors: [_deepPurple, _darkBg],
        ),
      ),
    );
  }

  Widget _buildHeader(int currentLevel) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📈 Mes Niveaux',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Niveau actuel : $currentLevel',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _primaryGold,
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

  Widget _buildProgressionCard(int completedSessions, int currentLevel) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_cardBgLight, _cardBg],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _primaryGold.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: _primaryGold.withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Niveau actuel avec effet
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_primaryGold, _accentOrange]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryGold.withOpacity(0.5),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currentLevel',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: _darkBg,
                        ),
                      ),
                      const Text(
                        'NIVEAU',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _darkBg,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'PROGRESSION GLOBALE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _primaryGold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem(Icons.fitness_center, '$completedSessions', 'Séances'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.star, '${_gameNotifier.currentXP}', 'XP Total'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.emoji_events, '${_gameNotifier.rewards.where((r) => r.isUnlocked).length}', 'Badges'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: _primaryGold, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Widget carte niveau
// ─────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final GameLevel level;
  final String emoji;
  final Color color;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isCurrentLevel;
  final int progress;
  final Animation<double> glowAnimation;

  const _LevelCard({
    required this.level,
    required this.emoji,
    required this.color,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrentLevel,
    required this.progress,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCurrentLevel
                  ? [color.withOpacity(0.3), color.withOpacity(0.15)]
                  : isCompleted
                      ? [_successGreen.withOpacity(0.2), _successGreen.withOpacity(0.1)]
                      : isUnlocked
                          ? [_cardBgLight, _cardBg]
                          : [_cardBg.withOpacity(0.5), _darkBg],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrentLevel
                  ? color
                  : isCompleted
                      ? _successGreen
                      : isUnlocked
                          ? color.withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
              width: isCurrentLevel ? 2 : 1,
            ),
            boxShadow: isCurrentLevel
                ? [
                    BoxShadow(
                      color: color.withOpacity(glowAnimation.value * 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône niveau
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? LinearGradient(colors: [color, color.withOpacity(0.7)])
                        : null,
                    color: isUnlocked ? null : _cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isUnlocked ? color : Colors.white24,
                      width: 2,
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 28)
                        : isUnlocked
                            ? Text(emoji, style: const TextStyle(fontSize: 28))
                            : Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.3), size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Infos niveau
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Niveau ${level.level}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isUnlocked ? color : Colors.white38,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isCurrentLevel)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ACTUEL',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          if (isCompleted && !isCurrentLevel)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _successGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 10, color: Colors.white),
                                  SizedBox(width: 2),
                                  Text(
                                    'COMPLÉTÉ',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isUnlocked ? Colors.white : Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnlocked ? Colors.white60 : Colors.white24,
                        ),
                      ),
                      
                      // Barre de progression si niveau en cours
                      if (isCurrentLevel && !isCompleted) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _darkBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Stack(
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: progress / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.5),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$progress%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Info verrouillé
                      if (!isUnlocked) ...[
                        const SizedBox(height: 8),
                        Text(
                          '🔒 Débloquer avec ${level.requiredSessions} séances',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
