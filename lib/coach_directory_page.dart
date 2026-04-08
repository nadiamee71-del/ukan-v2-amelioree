import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/coach_directory.dart';
import 'models/user_directory.dart';
import 'coach_detail_page.dart';
import 'pages/user_profile_page.dart';
import 'data/fake_images.dart';
import 'coach_directory/coach_map_page.dart';
import 'coach_directory/mock_coaches_data.dart';

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

// Type de résultat de recherche
enum SearchResultType { coach, user }

class SearchResult {
  final SearchResultType type;
  final dynamic data;

  SearchResult({required this.type, required this.data});
}

class CoachDirectoryPage extends StatefulWidget {
  const CoachDirectoryPage({super.key});

  @override
  State<CoachDirectoryPage> createState() => _CoachDirectoryPageState();
}

class _CoachDirectoryPageState extends State<CoachDirectoryPage>
    with SingleTickerProviderStateMixin {
  final _directoryNotifier = CoachDirectoryNotifier();
  final _userDirectoryNotifier = UserDirectoryNotifier();
  final _searchController = TextEditingController();
  late AnimationController _animationController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _directoryNotifier.addListener(_onDataChanged);
    _userDirectoryNotifier.addListener(_onDataChanged);
    _searchController.addListener(_onSearchChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _directoryNotifier.removeListener(_onDataChanged);
    _userDirectoryNotifier.removeListener(_onDataChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    _directoryNotifier.setSearchQuery(query);
    _userDirectoryNotifier.setSearchQuery(query);
  }

  List<SearchResult> _buildMixedResults() {
    final results = <SearchResult>[];
    final searchQuery = _searchController.text.trim().toLowerCase();

    if (searchQuery.isEmpty) {
      for (final coach in _directoryNotifier.coaches) {
        results.add(SearchResult(type: SearchResultType.coach, data: coach));
      }
    } else {
      for (final coach in _directoryNotifier.coaches) {
        results.add(SearchResult(type: SearchResultType.coach, data: coach));
      }
      for (final user in _userDirectoryNotifier.searchUsers(searchQuery)) {
        results.add(SearchResult(type: SearchResultType.user, data: user));
      }
    }

    return results;
  }

  /// Groupe les coachs par spécialité
  Map<String, List<CoachProfile>> _groupCoachesBySpecialty() {
    final grouped = <String, List<CoachProfile>>{};
    
    for (final coach in _directoryNotifier.coaches) {
      final specialty = coach.specialty;
      if (!grouped.containsKey(specialty)) {
        grouped[specialty] = [];
      }
      grouped[specialty]!.add(coach);
    }
    
    // Trier chaque groupe par note décroissante
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.rating.compareTo(a.rating));
    }
    
    return grouped;
  }

  /// Emoji pour chaque spécialité
  String _getSpecialtyEmoji(String specialty) {
    final lowerSpec = specialty.toLowerCase();
    if (lowerSpec.contains('perte') || lowerSpec.contains('minceur')) return '🔥';
    if (lowerSpec.contains('masse') || lowerSpec.contains('musculation')) return '💪';
    if (lowerSpec.contains('fitness') || lowerSpec.contains('forme')) return '✨';
    if (lowerSpec.contains('boxe') || lowerSpec.contains('boxing')) return '🥊';
    if (lowerSpec.contains('yoga')) return '🧘';
    if (lowerSpec.contains('cardio')) return '❤️';
    if (lowerSpec.contains('crossfit')) return '🏋️';
    if (lowerSpec.contains('nutrition')) return '🥗';
    if (lowerSpec.contains('bien-être') || lowerSpec.contains('wellness')) return '🌿';
    if (lowerSpec.contains('course') || lowerSpec.contains('running')) return '🏃';
    if (lowerSpec.contains('natation') || lowerSpec.contains('aqua')) return '🏊';
    if (lowerSpec.contains('danse')) return '💃';
    if (lowerSpec.contains('pilates')) return '🤸';
    if (lowerSpec.contains('stretching')) return '🧘‍♀️';
    if (lowerSpec.contains('mma') || lowerSpec.contains('combat')) return '🤼';
    if (lowerSpec.contains('judo')) return '🥋';
    if (lowerSpec.contains('karate') || lowerSpec.contains('karaté')) return '🥷';
    return '🎯';
  }

  /// Couleur pour chaque spécialité
  Color _getSpecialtyColor(String specialty) {
    final lowerSpec = specialty.toLowerCase();
    if (lowerSpec.contains('perte') || lowerSpec.contains('minceur')) return _primaryOrange;
    if (lowerSpec.contains('masse') || lowerSpec.contains('musculation')) return _primaryGold;
    if (lowerSpec.contains('fitness') || lowerSpec.contains('forme')) return _primaryGreen;
    if (lowerSpec.contains('boxe') || lowerSpec.contains('boxing')) return _primaryRed;
    if (lowerSpec.contains('yoga')) return const Color(0xFF4ECDC4);
    if (lowerSpec.contains('cardio')) return const Color(0xFFFF6B6B);
    if (lowerSpec.contains('crossfit')) return const Color(0xFFEF4444);
    if (lowerSpec.contains('nutrition')) return const Color(0xFF10B981);
    if (lowerSpec.contains('bien-être') || lowerSpec.contains('wellness')) return const Color(0xFF8B5CF6);
    if (lowerSpec.contains('course') || lowerSpec.contains('running')) return _primaryBlue;
    return _primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    final cities = _directoryNotifier.availableCities;
    final specialties = _directoryNotifier.availableSpecialties;
    final mixedResults = _buildMixedResults();

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
                  _primaryBlue.withOpacity(0.1),
                  _darkBg,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar moderne avec flèche retour
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: _darkBg,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _cardBgLight, width: 1),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: _textLight, size: 18),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      // Revenir à l'accueil si on ne peut pas pop
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(56, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_primaryGold, _primaryGold.withOpacity(0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryGold.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.search, color: _darkBg, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rechercher',
                                    style: TextStyle(
                                      color: _textLight,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Coachs & Utilisateurs',
                                    style: TextStyle(color: _textMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Barre de recherche
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(
                  searchController: _searchController,
                  showFilters: _showFilters,
                  onToggleFilters: () {
                    HapticFeedback.selectionClick();
                    setState(() => _showFilters = !_showFilters);
                  },
                  onMapTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CoachMapPage()),
                    );
                  },
                  cities: cities,
                  specialties: specialties,
                  selectedCity: _directoryNotifier.filterCity,
                  selectedSpecialty: _directoryNotifier.filterSpecialty,
                  onCityChanged: (city) => _directoryNotifier.setFilterCity(city),
                  onSpecialtyChanged: (spec) => _directoryNotifier.setFilterSpecialty(spec),
                  onClearFilters: () {
                    _directoryNotifier.clearFilters();
                    _userDirectoryNotifier.setSearchQuery('');
                    _searchController.clear();
                  },
                ),
              ),

              // Résultats groupés par catégorie
              if (_searchController.text.isEmpty && _directoryNotifier.filterSpecialty == null)
                // Vue groupée par catégorie
                ..._buildGroupedCoachesSliver()
              else if (mixedResults.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                // Vue liste simple (recherche ou filtre actif)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final result = mixedResults[index];
                        if (result.type == SearchResultType.coach) {
                          return _ModernCoachCard(
                            coach: result.data as CoachProfile,
                            index: index,
                            animationController: _animationController,
                          );
                        } else {
                          return _ModernUserCard(
                            user: result.data as PublicUserProfile,
                            index: index,
                            animationController: _animationController,
                          );
                        }
                      },
                      childCount: mixedResults.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit les slivers pour les coachs groupés par catégorie
  List<Widget> _buildGroupedCoachesSliver() {
    final groupedCoaches = _groupCoachesBySpecialty();
    final slivers = <Widget>[];
    
    int globalIndex = 0;
    
    for (final entry in groupedCoaches.entries) {
      final specialty = entry.key;
      final coaches = entry.value;
      final emoji = _getSpecialtyEmoji(specialty);
      final color = _getSpecialtyColor(specialty);
      
      // Header de la catégorie
      slivers.add(
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        specialty,
                        style: const TextStyle(
                          color: _textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${coaches.length} coach${coaches.length > 1 ? 's' : ''}',
                        style: TextStyle(color: color, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        coaches.isNotEmpty 
                            ? (coaches.map((c) => c.rating).reduce((a, b) => a + b) / coaches.length).toStringAsFixed(1)
                            : '0.0',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      // Liste des coachs de cette catégorie
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _ModernCoachCard(
                  coach: coaches[index],
                  index: globalIndex + index,
                  animationController: _animationController,
                );
              },
              childCount: coaches.length,
            ),
          ),
        ),
      );
      
      globalIndex += coaches.length;
    }
    
    // Padding en bas
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 100)));
    
    return slivers;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 48, color: _textMuted),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun résultat',
            style: TextStyle(
              color: _textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essaie avec d\'autres critères',
            style: TextStyle(color: _textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              _directoryNotifier.clearFilters();
              _searchController.clear();
            },
            icon: Icon(Icons.refresh, color: _primaryBlue),
            label: Text(
              'Réinitialiser',
              style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton pour ouvrir la carte globale des coachs
  Widget _buildMapButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CoachMapPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryGold.withOpacity(0.2), _primaryGold.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryGold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primaryGold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.map, color: _darkBg, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voir la carte',
                    style: TextStyle(
                      color: _textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Trouve les coachs près de toi',
                    style: TextStyle(color: _textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: _primaryGold, size: 18),
          ],
        ),
      ),
    );
  }

  /// Ouvre la carte centrée sur un coach spécifique
  void _openCoachOnMap(CoachProfile coach) {
    // Convertir CoachProfile en CoachData pour la carte
    final coachData = CoachData(
      id: coach.id,
      name: coach.name,
      avatarUrl: coach.photoUrl ?? 'assets/images/ChatGPT Image 1 déc. 2025, 15_43_23.png',
      speciality: coach.specialty,
      city: coach.city,
      rating: coach.rating,
      gender: 'autre',
      lat: _getCityLat(coach.city),
      lng: _getCityLng(coach.city),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachMapPage(initialCoach: coachData),
      ),
    );
  }

  // Coordonnées approximatives des villes
  double? _getCityLat(String city) {
    final cityLower = city.toLowerCase();
    if (cityLower.contains('paris')) return 48.8566;
    if (cityLower.contains('lyon')) return 45.7578;
    if (cityLower.contains('marseille')) return 43.2965;
    if (cityLower.contains('bordeaux')) return 44.8378;
    if (cityLower.contains('toulouse')) return 43.6047;
    if (cityLower.contains('nice')) return 43.7102;
    if (cityLower.contains('nantes')) return 47.2184;
    if (cityLower.contains('strasbourg')) return 48.5734;
    if (cityLower.contains('lille')) return 50.6292;
    if (cityLower.contains('montpellier')) return 43.6108;
    return null;
  }

  double? _getCityLng(String city) {
    final cityLower = city.toLowerCase();
    if (cityLower.contains('paris')) return 2.3522;
    if (cityLower.contains('lyon')) return 4.8320;
    if (cityLower.contains('marseille')) return 5.3698;
    if (cityLower.contains('bordeaux')) return -0.5792;
    if (cityLower.contains('toulouse')) return 1.4442;
    if (cityLower.contains('nice')) return 7.2620;
    if (cityLower.contains('nantes')) return -1.5536;
    if (cityLower.contains('strasbourg')) return 7.7521;
    if (cityLower.contains('lille')) return 3.0573;
    if (cityLower.contains('montpellier')) return 3.8767;
    return null;
  }
}

// Delegate pour la barre de recherche
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final bool showFilters;
  final VoidCallback onToggleFilters;
  final VoidCallback onMapTap;
  final List<String> cities;
  final List<String> specialties;
  final String? selectedCity;
  final String? selectedSpecialty;
  final Function(String?) onCityChanged;
  final Function(String?) onSpecialtyChanged;
  final VoidCallback onClearFilters;

  _SearchBarDelegate({
    required this.searchController,
    required this.showFilters,
    required this.onToggleFilters,
    required this.onMapTap,
    required this.cities,
    required this.specialties,
    required this.selectedCity,
    required this.selectedSpecialty,
    required this.onCityChanged,
    required this.onSpecialtyChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _darkBg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Barre de recherche
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _cardBgLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: _textLight, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search, color: _textMuted, size: 22),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: _textMuted, size: 20),
                              onPressed: () {
                                searchController.clear();
                                onClearFilters();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: showFilters ? _primaryBlue.withOpacity(0.2) : _cardBgLight,
                  borderRadius: BorderRadius.circular(14),
                  border: showFilters ? Border.all(color: _primaryBlue) : null,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: showFilters ? _primaryBlue : _textMuted,
                  ),
                  onPressed: onToggleFilters,
                ),
              ),
              const SizedBox(width: 8),
              // Bouton Carte
              Container(
                decoration: BoxDecoration(
                  color: _primaryGold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.map_outlined,
                    color: _darkBg,
                  ),
                  onPressed: onMapTap,
                  tooltip: 'Voir la carte',
                ),
              ),
            ],
          ),
          // Filtres (si affichés)
          if (showFilters) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    label: 'Ville',
                    value: selectedCity,
                    items: cities,
                    onChanged: onCityChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterDropdown(
                    label: 'Spécialité',
                    value: selectedSpecialty,
                    items: specialties,
                    onChanged: onSpecialtyChanged,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  double get maxExtent => showFilters ? 140 : 80;

  @override
  double get minExtent => showFilters ? 140 : 80;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return oldDelegate.showFilters != showFilters ||
        oldDelegate.selectedCity != selectedCity ||
        oldDelegate.selectedSpecialty != selectedSpecialty;
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label, style: TextStyle(color: _textMuted, fontSize: 14)),
          dropdownColor: _cardBg,
          style: const TextStyle(color: _textLight, fontSize: 14),
          icon: Icon(Icons.keyboard_arrow_down, color: _textMuted),
          items: [
            DropdownMenuItem(value: null, child: Text('Tous', style: TextStyle(color: _textMuted))),
            ...items.map((item) => DropdownMenuItem(value: item, child: Text(item))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Carte Coach moderne
class _ModernCoachCard extends StatelessWidget {
  final CoachProfile coach;
  final int index;
  final AnimationController animationController;

  const _ModernCoachCard({
    required this.coach,
    required this.index,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBgLight),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CoachDetailPage(coachId: coach.id)),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [_primaryGreen, _primaryGreen.withOpacity(0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryGreen.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: coach.photoUrl != null && coach.photoUrl!.isNotEmpty
                              ? Image.asset(
                                  coach.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildAvatarFallback(coach.name),
                                )
                              : Image.asset(
                                  getRandomImage(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildAvatarFallback(coach.name),
                                ),
                        ),
                      ),
                      if (coach.isCertified)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _primaryGold,
                              shape: BoxShape.circle,
                              border: Border.all(color: _cardBg, width: 2),
                            ),
                            child: const Icon(Icons.verified, color: Colors.black, size: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                coach.name,
                                style: const TextStyle(
                                  color: _textLight,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Note
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _primaryGold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, color: _primaryGold, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        coach.rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: _primaryGold,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primaryGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            coach.specialty,
                            style: TextStyle(
                              color: _primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: _textMuted),
                            const SizedBox(width: 4),
                            Text(
                              coach.city,
                              style: TextStyle(color: _textMuted, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.people, size: 14, color: _textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${12 + (coach.rating * 3).toInt()} clients',
                              style: TextStyle(color: _textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: _textMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase() : 'C',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// Carte Utilisateur moderne
class _ModernUserCard extends StatelessWidget {
  final PublicUserProfile user;
  final int index;
  final AnimationController animationController;

  const _ModernUserCard({
    required this.user,
    required this.index,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBgLight),
          boxShadow: [
            BoxShadow(
              color: _primaryGold.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => UserProfilePage(user: user)),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [_primaryGold, _primaryGold.withOpacity(0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryGold.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                              ? Image.asset(
                                  user.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildAvatarFallback(user.name),
                                )
                              : _buildAvatarFallback(user.name),
                        ),
                      ),
                      if (user.isCoach)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: _cardBg, width: 2),
                            ),
                            child: const Icon(Icons.sports, color: Colors.white, size: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  color: _textLight,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (user.isCoach)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Coach',
                                  style: TextStyle(
                                    color: _primaryGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primaryOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.mainGoal,
                            style: TextStyle(
                              color: _primaryOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (user.city != null) ...[
                              Icon(Icons.location_on, size: 14, color: _textMuted),
                              const SizedBox(width: 4),
                              Text(
                                user.city!,
                                style: TextStyle(color: _textMuted, fontSize: 12),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Icon(Icons.trending_up, size: 14, color: _textMuted),
                            const SizedBox(width: 4),
                            Text(
                              user.level,
                              style: TextStyle(color: _textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: _textMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
