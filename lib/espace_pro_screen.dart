import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'alter_ego.dart';
import 'pages/health_injuries_page.dart';
import 'pages/faq_support_page.dart';
import 'alter_ego_floating/alter_ego_page_detector.dart';
import 'coach_personality/coach_personality_page.dart';
import 'group_classes/group_class_live.dart';
import 'group_classes/group_class_replays.dart';
import 'events/events_page.dart';
import 'models/user_profile.dart';
import 'models/subscription.dart';
import 'pages/my_purchases_page.dart';
import 'premium_page.dart';
import 'future_self_advanced_page.dart';
import 'community_chat_page.dart';
import 'coach_directory_page.dart';
import 'body_composition_page.dart';
import 'coach_personality/coach_personality_notifier.dart';
import 'models/demo_purchase.dart';
import 'pages/video_packs_page.dart';
import 'chat_match/match_home_page.dart';
import 'buddy_training/buddy_home_page.dart';
import 'chat_match/match_engine.dart';
import 'chat_match/match_profile.dart';
import 'coach_business/business_dashboard.dart';
import 'game_story/story_home.dart';
import 'coach_vs_coach/coach_ranking_page.dart';
import 'transformation_ra/ra_future_preview.dart';
import 'workout_session_page.dart';
import 'models/workout_step.dart';
import 'coach_ia_premium/coach_ia_premium_page.dart';
import 'foodscan_ia/foodscan_home_page.dart';
import 'models/theme_notifier.dart';
import 'components/messaging_icon_button.dart';
import 'rooms_page.dart';
import 'hard_challenge/hard_challenge_page.dart';
import 'evolution/pose_guide_camera_page.dart';

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
const Color _primaryCyan = Color(0xFF22D3EE);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);

// Styles uniformes pour tous les conteneurs
const double _uniformBorderRadius = 16.0;
const double _uniformBorderWidth = 1.5;
const List<BoxShadow> _uniformShadow = [
  BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

// Modèle pour représenter une fonctionnalité
enum AdvancedFeatureCategory { freemium, premium, ia }

class AdvancedFeature {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final AdvancedFeatureCategory category;
  final VoidCallback onTap;
  final Color? customColor;

  AdvancedFeature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.onTap,
    this.customColor,
  });
}

/// Écran centralisé "Mon Espace Avancé" - Hub pour toutes les fonctionnalités avancées/premium
class EspaceProScreen extends StatefulWidget {
  /// Indique si l'utilisateur courant est un coach.
  /// Le bouton « Passer en mode Coach » est masqué pour les clients afin
  /// d'empêcher tout contournement de rôle.
  final bool isCoach;

  const EspaceProScreen({super.key, this.isCoach = false});

  @override
  State<EspaceProScreen> createState() => _EspaceProScreenState();
}

class _EspaceProScreenState extends State<EspaceProScreen>
    with SingleTickerProviderStateMixin {
  late final SubscriptionNotifier _subscriptionNotifier;
  late final UserProfileNotifier _profileNotifier;
  late AnimationController _animationController;
  String _searchQuery = '';
  AdvancedFeatureCategory _selectedCategory = AdvancedFeatureCategory.freemium;

  @override
  void initState() {
    super.initState();
    _subscriptionNotifier = SubscriptionNotifier();
    _subscriptionNotifier.addListener(_onSubscriptionChanged);
    _profileNotifier = UserProfileNotifier();
    _profileNotifier.addListener(_onProfileChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    AlterEgoPageDetector.setupPageContext(UkanPage.espacePro);
  }

  @override
  void dispose() {
    _subscriptionNotifier.removeListener(_onSubscriptionChanged);
    _profileNotifier.removeListener(_onProfileChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onSubscriptionChanged() {
    setState(() {});
  }

  void _onProfileChanged() {
    setState(() {});
  }

  void _showPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PremiumPage()),
    );
  }

  // Génère la liste complète de toutes les fonctionnalités
  List<AdvancedFeature> _getAllFeatures() {
    final profile = _profileNotifier.profile;

    return [
      // ============================================
      // FREEMIUM
      // ============================================
      AdvancedFeature(
        id: 'analyse_corporelle',
        title: 'Analyse corporelle',
        subtitle: 'Suivi détaillé de ta composition',
        icon: Icons.monitor_weight_outlined,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryGreen,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BodyCompositionPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'chat_entraide',
        title: 'Chat communautaire',
        subtitle: 'Discussions entre membres',
        icon: Icons.forum_outlined,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryBlue,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CommunityChatPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'chat_match',
        title: 'Chat Match™',
        subtitle: 'Trouve des partenaires sportifs',
        icon: Icons.favorite_border,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryRed,
        onTap: () {
          final matchEngine = MatchEngine();
          matchEngine.setCurrentUserProfile(
            MatchProfile(
              id: 'current_user',
              name: profile.name,
              age: 25,
              level: 'Intermédiaire',
              goals: [profile.mainGoal],
              availability: 'Flexible',
              city: 'Paris',
              distance: 0,
              sportPreferences: {},
              sportCharacter: 'Motivé',
              compatibilityScore: 0,
              createdAt: DateTime.now(),
            ),
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MatchHomePage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'buddy_training',
        title: 'Visio Training',
        subtitle: 'Entraîne-toi en live avec tes amis',
        icon: Icons.videocam_outlined,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryCyan,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BuddyHomePage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'sante_blessures',
        title: 'Santé & Blessures',
        subtitle: 'Carnet de suivi médical',
        icon: Icons.health_and_safety_outlined,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryOrange,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HealthInjuriesPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'coach_directory',
        title: 'Annuaire',
        subtitle: 'Coachs & Utilisateurs',
        icon: Icons.people_outline,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryPurple,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CoachDirectoryPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'coach_personality',
        title: 'Personnalité Coach',
        subtitle: 'Personnalise ton assistant',
        icon: Icons.psychology_outlined,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryGold,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CoachPersonalityPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'events',
        title: 'Événements',
        subtitle: 'Combats, marathons, compétitions...',
        icon: Icons.event,
        category: AdvancedFeatureCategory.freemium,
        customColor: const Color(0xFFEC4899),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EventsPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'sport_gaming_story',
        title: 'Sport Gaming™',
        subtitle: 'Le sport comme un jeu',
        icon: Icons.videogame_asset_outlined,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryRed,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StoryHomePage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'evolution',
        title: 'Mon Évolution',
        subtitle: 'Photos avant/après avec guide de pose',
        icon: Icons.trending_up_rounded,
        category: AdvancedFeatureCategory.freemium,
        customColor: _primaryGreen,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PoseGuideEvolutionPage()),
          );
        },
      ),

      // ============================================
      // PREMIUM
      // ============================================
      AdvancedFeature(
        id: 'coach_business',
        title: 'Coach Business™',
        subtitle: 'Vends tes programmes',
        icon: Icons.store_mall_directory_outlined,
        category: AdvancedFeatureCategory.premium,
        customColor: _primaryGold,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CoachBusinessDashboard()),
          );
        },
      ),
      AdvancedFeature(
        id: 'cours_collectifs_live',
        title: 'Cours Live',
        subtitle: 'Cours en direct style TikTok',
        icon: Icons.videocam_rounded,
        category: AdvancedFeatureCategory.premium,
        customColor: _primaryRed,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GroupClassLivePage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'pack_videos',
        title: 'Pack Vidéos',
        subtitle: 'Vidéos d\'exercices détaillées',
        icon: Icons.video_library_outlined,
        category: AdvancedFeatureCategory.premium,
        customColor: _primaryBlue,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VideoPacksPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'replays',
        title: 'Replays',
        subtitle: 'Replays des cours collectifs',
        icon: Icons.replay_circle_filled_outlined,
        category: AdvancedFeatureCategory.premium,
        customColor: _primaryPurple,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GroupClassReplaysPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'coach_vs_coach',
        title: 'Coach vs Coach',
        subtitle: 'Classement des meilleurs coachs',
        icon: Icons.emoji_events_outlined,
        category: AdvancedFeatureCategory.premium,
        customColor: _primaryOrange,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CoachRankingPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'hard_challenge',
        title: 'Hard Challenge',
        subtitle: 'Défis intensifs 50/75/90 jours',
        icon: Icons.local_fire_department,
        category: AdvancedFeatureCategory.premium,
        customColor: _primaryRed,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HardChallengePage()),
          );
        },
      ),

      // ============================================
      // IA
      // ============================================
      AdvancedFeature(
        id: 'coach_ia_premium',
        title: 'Coach IA Premium',
        subtitle: 'Analyse posture en temps réel',
        icon: Icons.sensors_rounded,
        category: AdvancedFeatureCategory.ia,
        customColor: _primaryCyan,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CoachIAPremiumPage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'foodscan_ia',
        title: 'FoodScan IA',
        subtitle: 'Analyse repas par IA',
        icon: Icons.camera_alt_rounded,
        category: AdvancedFeatureCategory.ia,
        customColor: _primaryGreen,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FoodScanHomePage()),
          );
        },
      ),
      AdvancedFeature(
        id: 'alter_ego_ia',
        title: 'Mon Alter Ego',
        subtitle: 'Ton assistant personnel IA',
        icon: Icons.psychology_alt_outlined,
        category: AdvancedFeatureCategory.ia,
        customColor: _primaryPurple,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AlterEgoScreen()),
          );
        },
      ),
      AdvancedFeature(
        id: 'transformation_projection',
        title: 'Projection IA',
        subtitle: 'Génère ton futur corps par IA',
        icon: Icons.auto_awesome,
        category: AdvancedFeatureCategory.ia,
        customColor: _primaryOrange,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RAFuturePreviewPage()),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allFeatures = _getAllFeatures();
    final filteredFeatures = allFeatures.where((f) {
      if (f.category != _selectedCategory) return false;
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return f.title.toLowerCase().contains(query) ||
          f.subtitle.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Fond avec gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCategoryColor(_selectedCategory).withOpacity(0.15),
                  _darkBg,
                  _darkBg,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          // Cercles décoratifs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getCategoryColor(_selectedCategory).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar moderne
              SliverAppBar(
                expandedHeight: 210,
                pinned: true,
                backgroundColor: _darkBg,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _cardBgLight,
                        borderRadius: BorderRadius.circular(_uniformBorderRadius),
                        border: Border.all(
                          color: _cardBgLight.withOpacity(0.5),
                          width: _uniformBorderWidth,
                        ),
                        boxShadow: _uniformShadow,
                      ),
                      child: const Icon(Icons.help_outline,
                          size: 20, color: _textLight),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const FaqSupportPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _primaryGold,
                                      _primaryGold.withOpacity(0.7)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryGold.withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.rocket_launch,
                                    color: Colors.black, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Espace Avancé',
                                      style: TextStyle(
                                        color: _textLight,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Fonctionnalités exclusives',
                                      style: TextStyle(
                                        color: _textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Le bouton « Passer en mode Coach » a été supprimé :
                          // le coach arrive directement sur son Dashboard Coach
                          // après connexion, et les clients ne doivent pas y
                          // accéder (aucun contournement de rôle possible).
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Barre de recherche + Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchAndTabsDelegate(
                  searchQuery: _searchQuery,
                  selectedCategory: _selectedCategory,
                  onSearchChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  onCategoryChanged: (category) {
                    setState(() => _selectedCategory = category);
                    HapticFeedback.selectionClick();
                  },
                ),
              ),

              // Liste des fonctionnalités
              if (filteredFeatures.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: _textMuted.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat',
                          style: TextStyle(
                            color: _textMuted,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6, // Plus large que haut pour cartes compactes
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final feature = filteredFeatures[index];
                        return _FeatureCard(
                          feature: feature,
                          index: index,
                          animationController: _animationController,
                        );
                      },
                      childCount: filteredFeatures.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(AdvancedFeatureCategory category) {
    switch (category) {
      case AdvancedFeatureCategory.freemium:
        return _primaryGreen;
      case AdvancedFeatureCategory.premium:
        return _primaryGold;
      case AdvancedFeatureCategory.ia:
        return _primaryCyan;
    }
  }
}

// Delegate pour la barre de recherche et les tabs
class _SearchAndTabsDelegate extends SliverPersistentHeaderDelegate {
  final String searchQuery;
  final AdvancedFeatureCategory selectedCategory;
  final Function(String) onSearchChanged;
  final Function(AdvancedFeatureCategory) onCategoryChanged;

  _SearchAndTabsDelegate({
    required this.searchQuery,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _darkBg,
      child: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(_uniformBorderRadius),
                border: Border.all(
                  color: _cardBgLight.withOpacity(0.5),
                  width: _uniformBorderWidth,
                ),
                boxShadow: _uniformShadow,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: _textMuted, size: 22),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(color: _textLight, fontSize: 15),
                onChanged: onSearchChanged,
              ),
            ),
          ),
          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildTab(
                  category: AdvancedFeatureCategory.freemium,
                  label: 'Freemium',
                  icon: Icons.star_outline,
                  color: _primaryGreen,
                ),
                const SizedBox(width: 8),
                _buildTab(
                  category: AdvancedFeatureCategory.premium,
                  label: 'Premium',
                  icon: Icons.workspace_premium,
                  color: _primaryGold,
                ),
                const SizedBox(width: 8),
                _buildTab(
                  category: AdvancedFeatureCategory.ia,
                  label: 'IA',
                  icon: Icons.auto_awesome,
                  color: _primaryCyan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required AdvancedFeatureCategory category,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () => onCategoryChanged(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : _cardBgLight,
            borderRadius: BorderRadius.circular(_uniformBorderRadius),
            border: Border.all(
              color: isSelected ? color : _cardBgLight.withOpacity(0.5),
              width: _uniformBorderWidth,
            ),
            boxShadow: _uniformShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : _textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : _textMuted,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 130;

  @override
  double get minExtent => 130;

  @override
  bool shouldRebuild(covariant _SearchAndTabsDelegate oldDelegate) {
    return oldDelegate.searchQuery != searchQuery ||
        oldDelegate.selectedCategory != selectedCategory;
  }
}

// Carte de fonctionnalité moderne
class _FeatureCard extends StatelessWidget {
  final AdvancedFeature feature;
  final int index;
  final AnimationController animationController;

  const _FeatureCard({
    required this.feature,
    required this.index,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final color = feature.customColor ?? _primaryBlue;

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 0.5),
          ((index * 0.1) + 0.5).clamp(0.5, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              feature.onTap();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icône à gauche
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      feature.icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Texte à droite
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Titre
                        Text(
                          feature.title,
                          style: const TextStyle(
                            color: _textLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Sous-titre
                        Text(
                          feature.subtitle,
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
  }
}





