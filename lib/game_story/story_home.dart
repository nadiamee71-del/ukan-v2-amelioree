import 'package:flutter/material.dart';
import '../models/game_story.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';
import 'story_chapter_page.dart';
import 'daily_quests_page.dart';
import 'story_rewards.dart';
import 'story_avatar.dart';
import '../coach_vs_coach/coach_ranking_page.dart';

/// Page d'accueil du Sport Gaming Story™ - Design Immersif
class StoryHomePage extends StatefulWidget {
  const StoryHomePage({super.key});

  @override
  State<StoryHomePage> createState() => _StoryHomePageState();
}

class _StoryHomePageState extends State<StoryHomePage> with TickerProviderStateMixin {
  final _gameNotifier = GameStoryNotifier();
  
  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Couleurs du thème Gaming Immersif
  static const _primaryGold = Color(0xFFFFD700);
  static const _accentOrange = Color(0xFFFF6B35);
  static const _deepPurple = Color(0xFF1A0A2E);
  static const _darkBg = Color(0xFF0D0D1A);
  static const _cardBg = Color(0xFF1E1E3F);
  static const _successGreen = Color(0xFF00E676);

  // Images des badges
  final List<Map<String, dynamic>> _badgeImages = [
    {'image': 'assets/images/badge_starter.png', 'name': 'Starter', 'unlocked': true},
    {'image': 'assets/images/badge_boss_slayer.png', 'name': 'Boss Slayer', 'unlocked': true},
    {'image': 'assets/images/badge_en_marche.png', 'name': 'En Marche', 'unlocked': false},
    {'image': 'assets/images/badge_endurant.png', 'name': 'Endurant', 'unlocked': false},
    {'image': 'assets/images/badge_hydro_boost.png', 'name': 'Hydro', 'unlocked': false},
    {'image': 'assets/images/badge_repos_guerrier.png', 'name': 'Repos', 'unlocked': false},
    {'image': 'assets/images/badge_legende.png', 'name': 'Légende', 'unlocked': false},
  ];

  // Chapitres avec images (utilisant des images existantes)
  final List<Map<String, dynamic>> _chapterData = [
    {'id': 'story1', 'image': 'assets/images/boss_squat_0.png', 'icon': '🚪', 'completed': true},
    {'id': 'story2', 'image': 'assets/images/mon_profil_gagnant.png', 'icon': '🏃', 'completed': true},
    {'id': 'story3', 'image': 'assets/images/mon_profil_neutre.png', 'icon': '⚔️', 'completed': false},
    {'id': 'story4', 'image': 'assets/images/fitpro_logo.png', 'icon': '🌉', 'completed': false},
    {'id': 'story5', 'image': 'assets/images/badge_repos_guerrier.png', 'icon': '😴', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _gameNotifier.addListener(_onGameChanged);
    AlterEgoPageDetector.setupPageContext(UkanPage.gameStory);
    
    // Animation de pulsation pour le bouton principal
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Animation de glow
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
    _gameNotifier.removeListener(_onGameChanged);
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  int get currentLevel => _gameNotifier.currentLevel;
  int get currentXP => _gameNotifier.currentXP;
  int get xpForNextLevel => _gameNotifier.xpForNextLevel;
  StoryChapter? get currentChapter => _gameNotifier.currentChapter;

  double get progress {
    if (xpForNextLevel == 0) return 0.0;
    return (currentXP / xpForNextLevel).clamp(0.0, 1.0);
  }

  int get xpRemaining => (xpForNextLevel - currentXP).clamp(0, xpForNextLevel);

  int get completedQuests => _gameNotifier.dailyQuests.where((q) => q.isCompleted).length;
  int get totalQuests => _gameNotifier.dailyQuests.length;
  int get unlockedBadges => _gameNotifier.rewards.where((r) => r.isUnlocked).length;
  int get totalBadges => _gameNotifier.rewards.length;

  String get _rankTitle {
    if (currentLevel >= 10) return '👑 Légende';
    if (currentLevel >= 7) return '⚔️ Champion';
    if (currentLevel >= 4) return '🛡️ Guerrier';
    if (currentLevel >= 2) return '🌱 Apprenti';
    return '🎯 Débutant';
  }

  String _getQuestIcon(String? tag) {
    switch (tag) {
      case 'Story':
        return '📖';
      case 'Santé':
        return '💪';
      case 'Habitude':
        return '🔄';
      case 'Social':
        return '👥';
      default:
        return '⚡';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Fond avec gradient et effet
          _buildBackground(),
          
          // Contenu principal
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header Hero avec niveau et XP
                SliverToBoxAdapter(child: _buildHeroHeader()),
                
                // Carte d'aventure (chemin des chapitres)
                SliverToBoxAdapter(child: _buildAdventureMap()),
                
                // Mission Boss actuelle
                SliverToBoxAdapter(child: _buildCurrentBossCard()),
                
                // Quêtes du jour
                SliverToBoxAdapter(child: _buildDailyQuests()),
                
                // Collection de badges
                SliverToBoxAdapter(child: _buildBadgesCollection()),
                
                // Avatar et Classement
                SliverToBoxAdapter(child: _buildAvatarAndRanking()),
                
                // Espace en bas
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
            const Color(0xFF0A0A15),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Effet de particules/étoiles subtiles
          Positioned.fill(
            child: CustomPaint(
              painter: _StarsPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      children: [
        // Barre de retour
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: _primaryGold, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
            ],
          ),
        ),
        // Carte principale
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _cardBg,
                _cardBg.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _primaryGold.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryGold.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Titre et rang
              Row(
                children: [
                  // Badge niveau avec glow
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_primaryGold, _accentOrange],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryGold.withOpacity(_glowAnimation.value),
                          blurRadius: 20,
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
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            'NIVEAU',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SPORT GAMING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _rankTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Barre XP stylisée
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_successGreen, _primaryGold],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: _successGreen.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '⭐ $currentXP XP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _primaryGold,
                          ),
                        ),
                        Text(
                          '+$xpRemaining pour lvl ${currentLevel + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
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
      ],
    );
  }

  Widget _buildAdventureMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.map, color: _primaryGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'CARTE D\'AVENTURE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _chapterData.length,
            itemBuilder: (context, index) {
              final chapter = _chapterData[index];
              final isCompleted = chapter['completed'] as bool;
              final isCurrent = index == 2; // Chapitre 3 en cours
              final isLocked = index > 2;
              
              return _buildChapterNode(
                index: index + 1,
                imagePath: chapter['image'] as String,
                icon: chapter['icon'] as String,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLocked: isLocked,
                isLast: index == _chapterData.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChapterNode({
    required int index,
    required String imagePath,
    required String icon,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required bool isLast,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: isLocked ? null : () {
            // Navigation vers le chapitre
            if (currentChapter != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoryChapterPage(chapter: currentChapter!),
                ),
              );
            }
          },
          child: AnimatedBuilder(
            animation: isCurrent ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: isCurrent ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 100,
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? _primaryGold
                          : isCompleted
                              ? _successGreen
                              : Colors.white24,
                      width: isCurrent ? 3 : 2,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: _primaryGold.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image de fond
                        ColorFiltered(
                          colorFilter: isLocked
                              ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _cardBg,
                              child: Center(
                                child: Text(icon, style: const TextStyle(fontSize: 32)),
                              ),
                            ),
                          ),
                        ),
                        // Overlay sombre
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(isLocked ? 0.8 : 0.6),
                              ],
                            ),
                          ),
                        ),
                        // Contenu
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _successGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 16),
                              )
                            else if (isLocked)
                              const Icon(Icons.lock, color: Colors.white54, size: 24)
                            else if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _accentOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'JOUER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'Ch. $index',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isLocked ? Colors.white38 : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Ligne de connexion
        if (!isLast)
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCompleted
                    ? [_successGreen, _successGreen.withOpacity(0.5)]
                    : [Colors.white24, Colors.white12],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentBossCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D1B4E),
            _cardBg,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _accentOrange.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentOrange.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec image boss
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/boss_squat_0.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: _deepPurple,
                    child: const Center(
                      child: Text('🐉', style: TextStyle(fontSize: 64)),
                    ),
                  ),
                ),
                // Overlay gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                // Badge "BOSS"
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⚔️', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 4),
                        Text(
                          'BOSS ACTUEL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Titre du boss
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentChapter?.boss.name ?? 'Le Réveil',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${currentChapter?.boss.targetValue ?? 50} ${currentChapter?.boss.targetUnit ?? 'Squats'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _primaryGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bouton action
          Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentChapter != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StoryChapterPage(chapter: currentChapter!),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: _accentOrange.withOpacity(0.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('⚔️', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text(
                            'AFFRONTER LE BOSS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuests() {
    final quests = _gameNotifier.dailyQuests;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text(
                    'QUÊTES DU JOUR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _successGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedQuests/$totalQuests',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _successGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: quests.length,
            itemBuilder: (context, index) {
              final quest = quests[index];
              return _buildQuestCard(quest);
            },
          ),
        ),
        // Bouton voir toutes les quêtes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DailyQuestsPage()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Voir toutes les quêtes',
                  style: TextStyle(color: _primaryGold, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: _primaryGold, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestCard(DailyQuest quest) {
    final isCompleted = quest.isCompleted;
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? _successGreen.withOpacity(0.15) : _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? _successGreen : Colors.white12,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(_getQuestIcon(quest.tag), style: const TextStyle(fontSize: 20)),
              const Spacer(),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
            ],
          ),
          Text(
            quest.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCompleted ? Colors.white54 : Colors.white,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '+${quest.xpReward} XP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.white38 : _primaryGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text(
                    'MA COLLECTION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Text(
                '$unlockedBadges/${_badgeImages.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _primaryGold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              // Grille de badges
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _badgeImages.length,
                itemBuilder: (context, index) {
                  final badge = _badgeImages[index];
                  final isUnlocked = badge['unlocked'] as bool;
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StoryRewardsPage()),
                      );
                    },
                    child: AnimatedBuilder(
                      animation: isUnlocked ? _glowAnimation : const AlwaysStoppedAnimation(0.0),
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? _primaryGold.withOpacity(0.1)
                                : Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isUnlocked
                                  ? _primaryGold.withOpacity(0.5)
                                  : Colors.white12,
                              width: 2,
                            ),
                            boxShadow: isUnlocked
                                ? [
                                    BoxShadow(
                                      color: _primaryGold.withOpacity(_glowAnimation.value * 0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ColorFiltered(
                                    colorFilter: isUnlocked
                                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                        : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                    child: Opacity(
                                      opacity: isUnlocked ? 1.0 : 0.4,
                                      child: Image.asset(
                                        badge['image'] as String,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            '🏅',
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: isUnlocked ? null : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isUnlocked)
                                  const Center(
                                    child: Icon(Icons.lock, color: Colors.white38, size: 20),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Bouton voir tous
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StoryRewardsPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voir tous mes badges',
                      style: TextStyle(color: _primaryGold, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: _primaryGold, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarAndRanking() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StoryAvatarPage()),
              );
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryGold, _accentOrange],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: _primaryGold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGold.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/alter_ego_salut.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      '$currentLevel',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mon Profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _rankTitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: _primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Classement
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CoachRankingPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _deepPurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryGold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    '#5',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryGold,
                    ),
                  ),
                  const Text(
                    'Rang',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter pour les étoiles en arrière-plan
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Dessiner quelques "étoiles" (points)
    final stars = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.05),
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.7, size.height * 0.08),
      Offset(size.width * 0.9, size.height * 0.12),
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.22),
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.28),
    ];
    
    for (final star in stars) {
      canvas.drawCircle(star, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
