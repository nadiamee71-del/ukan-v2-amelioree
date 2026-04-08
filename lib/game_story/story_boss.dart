import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_story.dart';
import 'boss_squat_game.dart';
import 'boss_hiit_game.dart';
import 'boss_plank_game.dart';

/// ─────────────────────────────────────────────
/// Sport Gaming™ - Boss Arena
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
const Color _dangerRed = Color(0xFFFF1744);
const Color _textLight = Color(0xFFE0E0E0);

class StoryBossPage extends StatefulWidget {
  const StoryBossPage({super.key});

  @override
  State<StoryBossPage> createState() => _StoryBossPageState();
}

class _StoryBossPageState extends State<StoryBossPage> with TickerProviderStateMixin {
  final _gameNotifier = GameStoryNotifier();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _gameNotifier.addListener(_onGameChanged);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _gameNotifier.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  void _startBossGame(GameBoss boss) {
    HapticFeedback.heavyImpact();
    
    Widget gamePage;
    switch (boss.id) {
      case 'legs':
        gamePage = BossSquatGamePage(boss: boss);
        break;
      case 'cardio':
        gamePage = BossHiitGamePage(boss: boss);
        break;
      case 'core':
        gamePage = BossPlankGamePage(boss: boss);
        break;
      default:
        return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => gamePage),
    );
  }

  String _getBossEmoji(String bossId) {
    switch (bossId) {
      case 'legs':
        return '🦵';
      case 'cardio':
        return '❤️‍🔥';
      case 'core':
        return '💪';
      default:
        return '👹';
    }
  }

  Color _getBossColor(String bossId) {
    switch (bossId) {
      case 'legs':
        return _accentOrange;
      case 'cardio':
        return _dangerRed;
      case 'core':
        return Colors.purple;
      default:
        return _primaryGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bosses = _gameNotifier.bosses;
    final defeatedCount = bosses.where((b) => b.isDefeated).length;

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
                _buildHeader(defeatedCount, bosses.length),
                
                // Contenu
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bannière Arena
                        _buildArenaCard(defeatedCount, bosses.length),
                        const SizedBox(height: 24),
                        
                        // Titre section
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [_dangerRed, _accentOrange]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '🐉 BOSS À VAINCRE',
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
                        
                        // Liste des boss
                        ...bosses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final boss = entry.value;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300 + (index * 150)),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(30 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: _BossCard(
                                    boss: boss,
                                    emoji: _getBossEmoji(boss.id),
                                    color: _getBossColor(boss.id),
                                    pulseAnimation: _pulseAnimation,
                                    onFight: () => _startBossGame(boss),
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
            const Color(0xFF150505), // Teinte rouge sombre
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int defeated, int total) {
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
                border: Border.all(color: _dangerRed.withOpacity(0.3)),
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
                  '⚔️ Boss Arena',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$defeated / $total vaincus',
                  style: TextStyle(
                    fontSize: 13,
                    color: defeated == total ? _successGreen : _dangerRed,
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

  Widget _buildArenaCard(int defeated, int total) {
    final progress = defeated / total;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardBgLight,
            _cardBg,
            const Color(0xFF1A0A1A), // Teinte sombre
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _dangerRed.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _dangerRed.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône centrale
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_dangerRed, _accentOrange]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _dangerRed.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🐉', style: TextStyle(fontSize: 40)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'ARÈNE DES BOSS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _dangerRed,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            defeated == total
                ? '🏆 Tous les boss vaincus !'
                : 'Affronte les gardiens pour progresser',
            style: TextStyle(
              fontSize: 14,
              color: defeated == total ? _successGreen : Colors.white60,
            ),
          ),
          const SizedBox(height: 20),
          // Barre de progression
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: defeated == total
                            ? [_successGreen, _successGreen.withOpacity(0.7)]
                            : [_dangerRed, _accentOrange],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: (defeated == total ? _successGreen : _dangerRed).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
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
}

// ─────────────────────────────────────────────
// Widget carte boss
// ─────────────────────────────────────────────

class _BossCard extends StatelessWidget {
  final GameBoss boss;
  final String emoji;
  final Color color;
  final Animation<double> pulseAnimation;
  final VoidCallback onFight;

  const _BossCard({
    required this.boss,
    required this.emoji,
    required this.color,
    required this.pulseAnimation,
    required this.onFight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: boss.isDefeated
              ? [_successGreen.withOpacity(0.2), _successGreen.withOpacity(0.1)]
              : [_cardBgLight, _cardBg],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: boss.isDefeated ? _successGreen : color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: boss.isDefeated
            ? [
                BoxShadow(
                  color: _successGreen.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Icône boss avec effet
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: boss.isDefeated ? 1.0 : pulseAnimation.value,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: boss.isDefeated
                              ? LinearGradient(colors: [_successGreen, _successGreen.withOpacity(0.7)])
                              : LinearGradient(colors: [color, color.withOpacity(0.7)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (boss.isDefeated ? _successGreen : color).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: boss.isDefeated
                              ? const Icon(Icons.check, color: Colors.white, size: 36)
                              : Text(emoji, style: const TextStyle(fontSize: 36)),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                
                // Infos boss
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              boss.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: boss.isDefeated ? Colors.white60 : Colors.white,
                                decoration: boss.isDefeated ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (boss.isDefeated)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [_successGreen, _successGreen.withOpacity(0.7)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'VAINCU',
                                    style: TextStyle(
                                      fontSize: 10,
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
                      const SizedBox(height: 6),
                      Text(
                        boss.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: boss.isDefeated ? Colors.white38 : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Défi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _darkBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, size: 20, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Défi : ${boss.challenge}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: boss.isDefeated ? Colors.white38 : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bouton combat
            if (!boss.isDefeated) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onFight,
                  icon: const Icon(Icons.flash_on),
                  label: const Text(
                    'COMBATTRE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: color.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
