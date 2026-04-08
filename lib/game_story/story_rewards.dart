import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_story.dart';

/// ─────────────────────────────────────────────
/// Sport Gaming™ - Récompenses & Badges
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

class StoryRewardsPage extends StatefulWidget {
  const StoryRewardsPage({super.key});

  @override
  State<StoryRewardsPage> createState() => _StoryRewardsPageState();
}

class _StoryRewardsPageState extends State<StoryRewardsPage> with SingleTickerProviderStateMixin {
  final _gameNotifier = GameStoryNotifier();
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _gameNotifier.addListener(_onGameChanged);
    
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
    super.dispose();
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  // Liste étendue de badges
  List<GameReward> get _allBadges {
    final baseRewards = _gameNotifier.rewards;
    
    final additionalBadges = [
      const GameReward(
        id: 'starter',
        name: 'Badge Starter',
        description: '1ère séance complétée',
        icon: '🎯',
        imagePath: 'assets/images/badge_starter.png',
        isUnlocked: true,
      ),
      GameReward(
        id: 'warrior',
        name: 'Badge Warrior',
        description: '5 Boss vaincus',
        icon: '⚔️',
        imagePath: 'assets/images/badge_boss_slayer.png',
        isUnlocked: _gameNotifier.bosses.where((b) => b.isDefeated).length >= 2,
      ),
      const GameReward(
        id: 'hydra',
        name: 'Badge Hydra',
        description: '7 jours d\'hydratation consécutifs',
        icon: '💧',
        imagePath: 'assets/images/badge_hydro_boost.png',
        isUnlocked: false,
      ),
      const GameReward(
        id: 'streak',
        name: 'Badge Streak',
        description: '10 jours d\'entraînement consécutifs',
        icon: '🔥',
        imagePath: 'assets/images/badge_endurant.png',
        isUnlocked: false,
      ),
      GameReward(
        id: 'legend',
        name: 'Badge Légende',
        description: 'Niveau 10 atteint',
        icon: '👑',
        imagePath: 'assets/images/badge_legende.png',
        isUnlocked: _gameNotifier.currentLevel >= 10,
      ),
    ];

    final allBadges = <GameReward>[];
    allBadges.addAll(baseRewards);
    
    for (final badge in additionalBadges) {
      if (!allBadges.any((b) => b.id == badge.id)) {
        allBadges.add(badge);
      }
    }
    
    return allBadges;
  }

  void _showBadgeDetail(BuildContext context, GameReward badge) {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_cardBgLight, _darkBg],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: badge.isUnlocked ? _primaryGold.withOpacity(0.5) : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Badge avec effet glow
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: badge.isUnlocked
                          ? [
                              BoxShadow(
                                color: _primaryGold.withOpacity(_glowAnimation.value),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: badge.isUnlocked
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_primaryGold, _accentOrange],
                              )
                            : null,
                        color: badge.isUnlocked ? null : _cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: badge.isUnlocked ? _primaryGold : Colors.white24,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: badge.isUnlocked ? 1.0 : 0.3,
                          child: badge.imagePath != null
                              ? ClipOval(
                                  child: Image.asset(
                                    badge.imagePath!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text(
                                        badge.icon,
                                        style: const TextStyle(fontSize: 56),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  badge.icon,
                                  style: const TextStyle(fontSize: 56),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Nom du badge
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: badge.isUnlocked ? _primaryGold : Colors.white60,
                ),
              ),
              const SizedBox(height: 12),
              
              // Statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: badge.isUnlocked
                      ? LinearGradient(colors: [_successGreen, _successGreen.withOpacity(0.7)])
                      : null,
                  color: badge.isUnlocked ? null : _cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: badge.isUnlocked ? _successGreen : Colors.white24,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badge.isUnlocked ? Icons.check_circle : Icons.lock_outline,
                      size: 18,
                      color: badge.isUnlocked ? Colors.white : Colors.white60,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      badge.isUnlocked
                          ? badge.unlockedDate != null
                              ? 'Obtenu le ${badge.unlockedDate!.day}/${badge.unlockedDate!.month}'
                              : 'Débloqué !'
                          : 'À débloquer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: badge.isUnlocked ? Colors.white : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _darkBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: _primaryGold),
                        SizedBox(width: 8),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _primaryGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textLight,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Comment débloquer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: badge.isUnlocked
                        ? [_successGreen.withOpacity(0.2), _successGreen.withOpacity(0.1)]
                        : [_accentOrange.withOpacity(0.2), _accentOrange.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: badge.isUnlocked
                        ? _successGreen.withOpacity(0.5)
                        : _accentOrange.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          badge.isUnlocked ? Icons.emoji_events : Icons.lightbulb_outline,
                          size: 18,
                          color: badge.isUnlocked ? _successGreen : _accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          badge.isUnlocked ? 'Comment tu l\'as obtenu' : 'Comment le débloquer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: badge.isUnlocked ? _successGreen : _accentOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge.unlockCondition ?? badge.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: badge.isUnlocked ? _successGreen : _textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Bouton fermer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: badge.isUnlocked ? _primaryGold : _cardBg,
                    foregroundColor: badge.isUnlocked ? _darkBg : _textLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    badge.isUnlocked ? 'SUPER !' : 'FERMER',
                    style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    final allBadges = _allBadges;
    final unlockedCount = allBadges.where((r) => r.isUnlocked).length;
    final progress = unlockedCount / allBadges.length;

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
                _buildHeader(),
                
                // Contenu
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bannière collection
                        _buildCollectionCard(unlockedCount, allBadges.length, progress),
                        const SizedBox(height: 24),
                        
                        // Badges débloqués
                        if (allBadges.any((b) => b.isUnlocked)) ...[
                          _buildSectionTitle('🏆 BADGES DÉBLOQUÉS', _successGreen),
                          const SizedBox(height: 12),
                          _buildBadgesGrid(allBadges.where((b) => b.isUnlocked).toList()),
                          const SizedBox(height: 24),
                        ],
                        
                        // Badges à débloquer
                        if (allBadges.any((b) => !b.isUnlocked)) ...[
                          _buildSectionTitle('🔒 À DÉBLOQUER', Colors.white60),
                          const SizedBox(height: 12),
                          _buildBadgesGrid(allBadges.where((b) => !b.isUnlocked).toList()),
                        ],
                        
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
                  '🏅 Récompenses & Badges',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Ta collection de trophées',
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

  Widget _buildCollectionCard(int unlocked, int total, double progress) {
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
              const Text(
                '🏆 COLLECTION',
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
                  Text(
                    '$unlocked',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: _primaryGold,
                    ),
                  ),
                  Text(
                    ' / $total',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Barre de progression dorée
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
                            colors: [_primaryGold, _accentOrange],
                          ),
                          borderRadius: BorderRadius.circular(6),
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
                progress >= 1.0
                    ? '🎉 Collection complète !'
                    : '${(progress * 100).toInt()}% de la collection',
                style: TextStyle(
                  fontSize: 14,
                  color: progress >= 1.0 ? _successGreen : Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesGrid(List<GameReward> badges) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _BadgeCard(
          badge: badge,
          onTap: () => _showBadgeDetail(context, badge),
          glowAnimation: _glowAnimation,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Widget carte badge
// ─────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final GameReward badge;
  final VoidCallback onTap;
  final Animation<double> glowAnimation;

  const _BadgeCard({
    required this.badge,
    required this.onTap,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: badge.isUnlocked
                    ? [_cardBgLight, _cardBg]
                    : [_cardBg.withOpacity(0.5), _darkBg],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: badge.isUnlocked
                    ? _primaryGold.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: badge.isUnlocked ? 2 : 1,
              ),
              boxShadow: badge.isUnlocked
                  ? [
                      BoxShadow(
                        color: _primaryGold.withOpacity(glowAnimation.value * 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: badge.isUnlocked
                        ? LinearGradient(colors: [_primaryGold, _accentOrange])
                        : null,
                    color: badge.isUnlocked ? null : _cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: badge.isUnlocked ? _primaryGold : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: badge.isUnlocked ? 1.0 : 0.3,
                      child: badge.imagePath != null
                          ? ClipOval(
                              child: Image.asset(
                                badge.imagePath!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    badge.icon,
                                    style: const TextStyle(fontSize: 28),
                                  );
                                },
                              ),
                            )
                          : Text(
                              badge.icon,
                              style: const TextStyle(fontSize: 28),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Nom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    badge.name.replaceAll('Badge ', ''),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badge.isUnlocked ? Colors.white : Colors.white38,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Statut
                if (!badge.isUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.lock_outline, size: 14, color: Colors.white24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
