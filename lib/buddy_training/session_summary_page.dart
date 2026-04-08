import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/rooms.dart';
import 'buddy_home_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SESSION SUMMARY PAGE - Récapitulatif de fin de séance
/// ═══════════════════════════════════════════════════════════════════════════

const Color _primaryBlue = Color(0xFF00D4FF);
const Color _secondaryPurple = Color(0xFF7B2FFF);
const Color _accentPink = Color(0xFFFF2D92);
const Color _successGreen = Color(0xFF00E676);
const Color _warningOrange = Color(0xFFFF9100);
const Color _goldColor = Color(0xFFFFD700);
const Color _silverColor = Color(0xFFC0C0C0);
const Color _bronzeColor = Color(0xFFCD7F32);
const Color _darkBg = Color(0xFF0A0A1A);
const Color _cardBg = Color(0xFF1A1A2E);

class SessionSummaryPage extends StatefulWidget {
  final int totalSeconds;
  final int exercisesCompleted;
  final List<RoomParticipant> participants;
  
  const SessionSummaryPage({
    super.key,
    required this.totalSeconds,
    required this.exercisesCompleted,
    required this.participants,
  });

  @override
  State<SessionSummaryPage> createState() => _SessionSummaryPageState();
}

class _SessionSummaryPageState extends State<SessionSummaryPage> with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  List<_ConfettiParticle> _confetti = [];
  late List<RoomParticipant> _sortedParticipants;

  @override
  void initState() {
    super.initState();
    
    // Sort participants by progress
    _sortedParticipants = List.from(widget.participants)
      ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
    
    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    
    // Generate confetti
    _confetti = List.generate(100, (index) => _ConfettiParticle());
    
    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _scaleController.forward();
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Haptic feedback on load
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _calculateCalories() {
    // Rough estimate: 5-8 calories per minute for moderate exercise
    return (widget.totalSeconds / 60 * 6.5).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _secondaryPurple.withOpacity(0.2),
                  _darkBg,
                  _darkBg,
                ],
              ),
            ),
          ),
          
          // Confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  confetti: _confetti,
                  progress: _confettiController.value,
                ),
              );
            },
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Trophy/Success animation
                  _buildTrophySection(),
                  const SizedBox(height: 32),
                  
                  // Stats cards
                  _buildStatsSection(),
                  const SizedBox(height: 32),
                  
                  // Leaderboard
                  _buildLeaderboard(),
                  const SizedBox(height: 32),
                  
                  // Badges earned
                  _buildBadgesSection(),
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophySection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              // Trophy icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_goldColor, _warningOrange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _goldColor.withOpacity(_glowAnimation.value),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🏆',
                    style: TextStyle(fontSize: 70),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_goldColor, _warningOrange],
                ).createShader(bounds),
                child: const Text(
                  'SÉANCE TERMINÉE !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bravo à tous les participants ! 💪',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: '⏱️',
            value: _formatTime(widget.totalSeconds),
            label: 'Durée totale',
            color: _primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: '🏋️',
            value: '${widget.exercisesCompleted}',
            label: 'Exercices',
            color: _secondaryPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: '🔥',
            value: '~${_calculateCalories()}',
            label: 'Calories',
            color: _accentPink,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_cardBg, _cardBg.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _goldColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Text(
                'Classement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _goldColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Mode Compétition',
                  style: TextStyle(
                    color: _goldColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Podium
          ...List.generate(_sortedParticipants.length, (index) {
            final participant = _sortedParticipants[index];
            return _buildLeaderboardItem(participant, index);
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(RoomParticipant participant, int rank) {
    final isYou = participant.id == 'you';
    Color medalColor;
    String medalEmoji;
    
    switch (rank) {
      case 0:
        medalColor = _goldColor;
        medalEmoji = '🥇';
        break;
      case 1:
        medalColor = _silverColor;
        medalEmoji = '🥈';
        break;
      case 2:
        medalColor = _bronzeColor;
        medalEmoji = '🥉';
        break;
      default:
        medalColor = Colors.grey;
        medalEmoji = '${rank + 1}';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isYou
            ? LinearGradient(colors: [_primaryBlue.withOpacity(0.3), _secondaryPurple.withOpacity(0.2)])
            : null,
        color: isYou ? null : _darkBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isYou ? _primaryBlue.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: rank < 3 ? Border.all(color: medalColor, width: 2) : null,
            ),
            child: Center(
              child: Text(
                medalEmoji,
                style: TextStyle(
                  fontSize: rank < 3 ? 20 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isYou 
                    ? [_primaryBlue, _secondaryPurple]
                    : [Colors.grey.shade700, Colors.grey.shade800],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participant.avatarInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isYou ? 'Toi' : participant.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'TOI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (rank == 0)
                  Text(
                    '👑 Champion de la séance !',
                    style: TextStyle(
                      color: _goldColor.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          
          // Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _successGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${participant.progressPercent}%',
              style: const TextStyle(
                color: _successGreen,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {'emoji': '🔥', 'name': 'Première séance', 'unlocked': true},
      {'emoji': '💪', 'name': 'Persévérant', 'unlocked': true},
      {'emoji': '⚡', 'name': 'Rapide', 'unlocked': widget.totalSeconds < 300},
      {'emoji': '🏆', 'name': 'Champion', 'unlocked': _sortedParticipants.first.id == 'you'},
    ];
    
    final unlockedBadges = badges.where((b) => b['unlocked'] == true).toList();
    
    if (unlockedBadges.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_secondaryPurple.withOpacity(0.2), _accentPink.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _secondaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🎖️', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                'Badges débloqués',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: unlockedBadges.map((badge) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_secondaryPurple, _accentPink]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _secondaryPurple.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(badge['emoji'] as String, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      badge['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action - Replay
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Go back to create room
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const BuddyHomePage()),
              );
            },
            icon: const Icon(Icons.replay, size: 24),
            label: const Text(
              'Nouvelle séance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _successGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: _successGreen.withOpacity(0.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Secondary actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Résultats partagés ! 🎉'),
                      backgroundColor: _primaryBlue,
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Partager'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  side: const BorderSide(color: _primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const BuddyHomePage()),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Accueil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Confetti particle data
class _ConfettiParticle {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  
  _ConfettiParticle()
      : x = math.Random().nextDouble(),
        speed = 0.3 + math.Random().nextDouble() * 0.7,
        size = 8 + math.Random().nextDouble() * 8,
        color = [
          _goldColor,
          _primaryBlue,
          _accentPink,
          _successGreen,
          _warningOrange,
          _secondaryPurple,
        ][math.Random().nextInt(6)],
        rotation = math.Random().nextDouble() * math.pi * 2;
}

/// Confetti painter
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> confetti;
  final double progress;
  
  _ConfettiPainter({required this.confetti, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in confetti) {
      final y = (progress * particle.speed * size.height * 2) % (size.height + 50) - 50;
      final paint = Paint()..color = particle.color.withOpacity(0.8);
      
      canvas.save();
      canvas.translate(particle.x * size.width, y);
      canvas.rotate(particle.rotation + progress * math.pi * 2);
      
      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size / 2),
        paint,
      );
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}







