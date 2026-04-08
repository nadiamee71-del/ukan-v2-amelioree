import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_story.dart';
import '../models/user_profile.dart';

/// ─────────────────────────────────────────────
/// Sport Gaming™ - Mon Avatar
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

class StoryAvatarPage extends StatefulWidget {
  const StoryAvatarPage({super.key});

  @override
  State<StoryAvatarPage> createState() => _StoryAvatarPageState();
}

class _StoryAvatarPageState extends State<StoryAvatarPage> with TickerProviderStateMixin {
  final _gameNotifier = GameStoryNotifier();
  final _profileNotifier = UserProfileNotifier();
  
  int _selectedStyle = 0; // 0: Guerrier, 1: Mage, 2: Légende
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateController;

  // Styles d'avatar disponibles
  final List<AvatarStyle> _avatarStyles = [
    AvatarStyle(
      id: 0,
      name: 'Guerrier',
      emoji: '⚔️',
      colors: [const Color(0xFFFF6B35), const Color(0xFFE53935)],
      description: 'Force et détermination',
    ),
    AvatarStyle(
      id: 1,
      name: 'Mage',
      emoji: '✨',
      colors: [const Color(0xFF7C4DFF), const Color(0xFF536DFE)],
      description: 'Sagesse et endurance',
    ),
    AvatarStyle(
      id: 2,
      name: 'Légende',
      emoji: '👑',
      colors: [const Color(0xFFFFD700), const Color(0xFFFF9800)],
      description: 'Maître de tous les arts',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _gameNotifier.addListener(_onGameChanged);
    _profileNotifier.addListener(_onGameChanged);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _gameNotifier.removeListener(_onGameChanged);
    _profileNotifier.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  String _getInitials() {
    final name = _profileNotifier.profile.name;
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty
        ? name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase()
        : 'AF';
  }

  AvatarStyle get _currentStyle => _avatarStyles[_selectedStyle];

  void _showStylePicker() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_cardBgLight, _darkBg],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: _primaryGold.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              '⚔️ CHOISIR UN STYLE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _primaryGold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            ..._avatarStyles.map((style) => _StyleOption(
                  style: style,
                  isSelected: _selectedStyle == style.id,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedStyle = style.id);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = _gameNotifier.currentLevel;
    final currentXP = _gameNotifier.currentXP;
    final xpForNextLevel = _gameNotifier.xpForNextLevel;
    final progress = xpForNextLevel > 0 ? currentXP / xpForNextLevel : 0.0;
    final initials = _getInitials();

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Background avec effet
          _buildBackground(),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // Avatar principal avec effet
                  _buildAvatarSection(initials, currentLevel),
                  const SizedBox(height: 24),
                  
                  // Barre XP
                  _buildXPSection(currentXP, xpForNextLevel, progress, currentLevel),
                  const SizedBox(height: 24),
                  
                  // Stats
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  
                  // Bouton changer de style
                  _buildStyleButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_deepPurple, _darkBg],
            ),
          ),
        ),
        // Cercles décoratifs animés
        AnimatedBuilder(
          animation: _rotateController,
          builder: (context, child) {
            return Positioned(
              top: -100,
              right: -100,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * 3.14159,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentStyle.colors[0].withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
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
                '🎭 Mon Avatar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                'Personnalise ton héros',
                style: TextStyle(
                  fontSize: 13,
                  color: _primaryGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(String initials, int level) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Avatar avec effet glow
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _currentStyle.colors[0].withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: _currentStyle.colors[1].withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _currentStyle.colors,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: _primaryGold, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Badge style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _currentStyle.colors),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _currentStyle.colors[0].withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_currentStyle.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    _currentStyle.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentStyle.description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white60,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildXPSection(int currentXP, int xpForNextLevel, double progress, int level) {
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
                    'NIVEAU',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_primaryGold, _accentOrange]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$level',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _darkBg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white38, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${level + 1}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // XP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'XP',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: _primaryGold, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$currentXP',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _primaryGold,
                        ),
                      ),
                      Text(
                        ' / $xpForNextLevel',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de progression
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_primaryGold, _accentOrange]),
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryGold.withOpacity(0.5),
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
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% vers le niveau ${level + 1}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final questsCompleted = _gameNotifier.dailyQuests.where((q) => q.isCompleted).length;
    final bossesDefeated = _gameNotifier.bosses.where((b) => b.isDefeated).length;
    final badgesUnlocked = _gameNotifier.rewards.where((r) => r.isUnlocked).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardBgLight, _cardBg],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_primaryGold, _accentOrange]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'STATISTIQUES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primaryGold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.assignment_turned_in,
                  emoji: '⚔️',
                  label: 'Quêtes',
                  value: '$questsCompleted',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.shield,
                  emoji: '🐉',
                  label: 'Boss',
                  value: '$bossesDefeated',
                  color: _accentOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  emoji: '🏆',
                  label: 'Badges',
                  value: '$badgesUnlocked',
                  color: _primaryGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showStylePicker,
        icon: const Icon(Icons.palette),
        label: const Text('CHANGER DE STYLE'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _cardBg,
          foregroundColor: _primaryGold,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _primaryGold.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets auxiliaires
// ─────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final AvatarStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleOption({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [style.colors[0].withOpacity(0.3), style.colors[1].withOpacity(0.2)],
                )
              : null,
          color: isSelected ? null : _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? style.colors[0] : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: style.colors[0].withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: style.colors),
                shape: BoxShape.circle,
                border: Border.all(color: _primaryGold, width: 2),
              ),
              child: Center(
                child: Text(style.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? style.colors[0] : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    style.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _successGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Modèle style avatar
// ─────────────────────────────────────────────

class AvatarStyle {
  final int id;
  final String name;
  final String emoji;
  final List<Color> colors;
  final String description;

  const AvatarStyle({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colors,
    required this.description,
  });
}
