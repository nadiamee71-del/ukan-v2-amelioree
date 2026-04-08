import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'match_swipe_page.dart';
import 'match_results_page.dart';
import 'match_profiles_list_page.dart';
import 'match_engine.dart';
import 'match_profile.dart';
import 'match_filters.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

class MatchHomePage extends StatefulWidget {
  const MatchHomePage({super.key});
  @override
  State<MatchHomePage> createState() => _MatchHomePageState();
}

const Color _bleuArdoise = Color(0xFF475569);
const Color _bleuArdoiseFonce = Color(0xFF334155);
const Color _bleuArdoiseClair = Color(0xFF64748B);
const Color _vertSauge = Color(0xFF6B8E7E);
const Color _vertOlive = Color(0xFF4A7C59);
const Color _grisCharbon = Color(0xFF1E293B);
const Color _grisCarte = Color(0xFF2D3A4F);
const Color _grisCarteClair = Color(0xFF3D4A5F);
const Color _texteClair = Color(0xFFF1F5F9);
const Color _texteSecondaire = Color(0xFF94A3B8);
const Color _roseMatch = Color(0xFFE91E63);
const Color _vertMatch = Color(0xFF4CAF50);

class _MatchHomePageState extends State<MatchHomePage> with SingleTickerProviderStateMixin {
  final _matchEngine = MatchEngine();
  String? _selectedDistance;
  String? _selectedLevel;
  final List<String> _selectedSports = [];
  final List<String> _selectedEquipment = [];
  String? _selectedMotivation;
  int? _minAge;
  int? _maxAge;
  bool _isFilterMenuOpen = false;
  late AnimationController _menuController;

  @override
  void initState() {
    super.initState();
    _matchEngine.addListener(_onMatchesChanged);
    _initializeUserProfile();
    AlterEgoPageDetector.setupPageContext(UkanPage.chatMatch);
    _menuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  }
  
  @override
  void dispose() {
    _menuController.dispose();
    _matchEngine.removeListener(_onMatchesChanged);
    super.dispose();
  }

  void _onMatchesChanged() => setState(() {});

  void _initializeUserProfile() {
    final userProfile = MatchProfile(
      id: 'user', name: 'Moi', age: 28, level: 'Intermédiaire',
      goals: ['Prise de masse', 'Force'], availability: 'Soir', city: 'Paris',
      distance: 0, sportPreferences: {'musculation': true, 'hiit': true},
      sportCharacter: 'Motivé', compatibilityScore: 0, createdAt: DateTime.now(),
      equipment: ['Haltères', 'Banc', 'Élastiques'], motivation: 'Très motivé',
      trainingFrequency: '4-5x/semaine',
    );
    _matchEngine.setCurrentUserProfile(userProfile);
  }

  void _toggleFilterMenu() {
    setState(() {
      _isFilterMenuOpen = !_isFilterMenuOpen;
      _isFilterMenuOpen ? _menuController.forward() : _menuController.reverse();
    });
  }

  void _applyFilters() {
    final filters = MatchFilters();
    if (_selectedDistance != null) {
      final distanceMap = {'1 km': 1.0, '3 km': 3.0, '5 km': 5.0, '10 km': 10.0, '20 km': 20.0};
      filters.maxDistance = distanceMap[_selectedDistance];
    }
    filters.level = _selectedLevel;
    filters.sportInterests = _selectedSports;
    filters.accessories = _selectedEquipment;
    filters.minAge = _minAge;
    filters.maxAge = _maxAge;
    _matchEngine.setFilters(filters);
    setState(() {});
  }

  void _resetFilters() {
    setState(() {
      _selectedDistance = null;
      _selectedLevel = null;
      _selectedSports.clear();
      _selectedEquipment.clear();
      _selectedMotivation = null;
      _minAge = null;
      _maxAge = null;
    });
    _matchEngine.setFilters(MatchFilters());
  }

  bool _hasActiveFilters() => _selectedDistance != null || _selectedLevel != null || 
      _selectedSports.isNotEmpty || _selectedEquipment.isNotEmpty || 
      _selectedMotivation != null || _minAge != null || _maxAge != null;

  @override
  Widget build(BuildContext context) {
    final matches = _matchEngine.getMatches();
    final availableProfiles = _matchEngine.getAvailableProfiles();

    return Scaffold(
      backgroundColor: _grisCharbon,
      appBar: AppBar(
        backgroundColor: _grisCharbon,
        foregroundColor: _texteClair,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('Buddy Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _grisCarte, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.tune_rounded, size: 18),
                ),
                if (_hasActiveFilters())
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: _vertSauge, shape: BoxShape.circle,
                        border: Border.all(color: _grisCharbon, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _toggleFilterMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompactHeader(),
                  const SizedBox(height: 14),
                  _buildCompactStats(availableProfiles.length, matches.length),
                  const SizedBox(height: 14),
                  _buildQuickFilters(),
                  const SizedBox(height: 16),
                  _buildCompactHowItWorks(),
                  const SizedBox(height: 18),
                  if (availableProfiles.isNotEmpty) _buildCompatibleProfiles(availableProfiles),
                  const SizedBox(height: 18),
                  if (matches.isNotEmpty) _buildMyBuddies(matches),
                  const SizedBox(height: 18),
                  _buildMainButton(availableProfiles.length),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isFilterMenuOpen) ...[
            GestureDetector(onTap: _toggleFilterMenu, child: Container(color: Colors.black54)),
            _buildFilterMenu(),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_bleuArdoiseFonce.withOpacity(0.8), _grisCarte]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _bleuArdoiseClair.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trouve ton partenaire', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _texteClair)),
                const SizedBox(height: 2),
                Text('Filtre par âge, distance, niveau...', style: TextStyle(fontSize: 11, color: _texteSecondaire.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStats(int profileCount, int matchCount) {
    return Row(
      children: [
        Expanded(child: _CompactStatChip(icon: Icons.people_outline, value: '$profileCount', label: 'Profils', color: _bleuArdoise, onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchProfilesListPage(profiles: _matchEngine.getAvailableProfiles())));
        })),
        const SizedBox(width: 10),
        Expanded(child: _CompactStatChip(icon: Icons.handshake, value: '$matchCount', label: 'Buddies', color: _vertSauge, onTap: matchCount > 0 ? () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchResultsPage()));
        } : null)),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickFilterChip(label: 'Distance', value: _selectedDistance, icon: Icons.location_on, onTap: _showDistancePicker),
          const SizedBox(width: 8),
          _QuickFilterChip(label: 'Niveau', value: _selectedLevel, icon: Icons.trending_up, onTap: _showLevelPicker),
          const SizedBox(width: 8),
          _QuickFilterChip(label: 'Sports', value: _selectedSports.isNotEmpty ? '${_selectedSports.length}' : null, icon: Icons.sports, onTap: _showSportsPicker),
          const SizedBox(width: 8),
          _QuickFilterChip(label: 'Matériel', value: _selectedEquipment.isNotEmpty ? '${_selectedEquipment.length}' : null, icon: Icons.fitness_center, onTap: _showEquipmentPicker),
        ],
      ),
    );
  }

  Widget _buildCompactHowItWorks() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: _grisCarte.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniStep(number: '1', label: 'Filtre'),
          Icon(Icons.chevron_right, size: 14, color: _texteSecondaire.withOpacity(0.4)),
          _MiniStep(number: '2', label: 'Découvre'),
          Icon(Icons.chevron_right, size: 14, color: _texteSecondaire.withOpacity(0.4)),
          _MiniStep(number: '3', label: 'Match'),
          Icon(Icons.chevron_right, size: 14, color: _texteSecondaire.withOpacity(0.4)),
          _MiniStep(number: '4', label: 'Train'),
        ],
      ),
    );
  }

  Widget _buildCompatibleProfiles(List<MatchProfile> profiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Profils compatibles', onViewAll: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchProfilesListPage(profiles: profiles)));
        }),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: profiles.take(5).length,
            itemBuilder: (context, index) => _ProfilePreviewCard(profile: profiles[index], onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchSwipePage()));
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMyBuddies(List<MatchProfile> buddies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Mes Buddies', color: _vertOlive, onViewAll: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchResultsPage()));
        }),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: buddies.length,
            itemBuilder: (context, index) => _BuddyAvatar(name: buddies[index].name, compatibility: buddies[index].compatibilityScore, onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchResultsPage()));
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton(int profileCount) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: profileCount == 0 ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchSwipePage())),
        icon: const Icon(Icons.search, size: 20),
        label: Text(profileCount == 0 ? 'Aucun profil' : 'Découvrir ($profileCount)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _vertSauge, foregroundColor: Colors.white,
          disabledBackgroundColor: _grisCarte, disabledForegroundColor: _texteSecondaire,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFilterMenu() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: double.infinity,
        color: _grisCharbon,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                color: _bleuArdoiseFonce,
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: _texteClair, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Filtres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _texteClair))),
                    IconButton(icon: const Icon(Icons.close, color: _texteClair, size: 20), onPressed: _toggleFilterMenu),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _FilterSection(title: 'Distance', icon: Icons.location_on, child: Wrap(spacing: 6, runSpacing: 6, children: BuddyProfileOptions.distances.map((d) => _FilterChip(label: d, isSelected: _selectedDistance == d, onTap: () => setState(() => _selectedDistance = _selectedDistance == d ? null : d))).toList())),
                      const SizedBox(height: 14),
                      _FilterSection(title: 'Âge', icon: Icons.cake, child: Row(children: [
                        Expanded(child: _AgeField(label: 'Min', value: _minAge, onChanged: (v) => setState(() => _minAge = v))),
                        const SizedBox(width: 10),
                        Expanded(child: _AgeField(label: 'Max', value: _maxAge, onChanged: (v) => setState(() => _maxAge = v))),
                      ])),
                      const SizedBox(height: 14),
                      _FilterSection(title: 'Niveau', icon: Icons.trending_up, child: Wrap(spacing: 6, runSpacing: 6, children: BuddyProfileOptions.levels.map((l) => _FilterChip(label: l, isSelected: _selectedLevel == l, onTap: () => setState(() => _selectedLevel = _selectedLevel == l ? null : l))).toList())),
                      const SizedBox(height: 14),
                      _FilterSection(title: 'Sports', icon: Icons.sports, child: Wrap(spacing: 6, runSpacing: 6, children: BuddyProfileOptions.sports.map((s) => _FilterChip(label: s, isSelected: _selectedSports.contains(s), onTap: () => setState(() { if (_selectedSports.contains(s)) _selectedSports.remove(s); else _selectedSports.add(s); }))).toList())),
                      const SizedBox(height: 14),
                      _FilterSection(title: 'Matériel', icon: Icons.fitness_center, child: Wrap(spacing: 6, runSpacing: 6, children: BuddyProfileOptions.equipment.map((e) => _FilterChip(label: e, isSelected: _selectedEquipment.contains(e), onTap: () => setState(() { if (_selectedEquipment.contains(e)) _selectedEquipment.remove(e); else _selectedEquipment.add(e); }))).toList())),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: _grisCarte,
                child: Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: _resetFilters, style: OutlinedButton.styleFrom(foregroundColor: _texteClair, side: const BorderSide(color: _bleuArdoiseClair), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Reset'))),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: ElevatedButton(onPressed: () { _applyFilters(); _toggleFilterMenu(); }, style: ElevatedButton.styleFrom(backgroundColor: _vertSauge, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Appliquer'))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDistancePicker() => _showPicker('Distance', BuddyProfileOptions.distances, _selectedDistance, (v) => setState(() { _selectedDistance = v; _applyFilters(); }));
  void _showLevelPicker() => _showPicker('Niveau', BuddyProfileOptions.levels, _selectedLevel, (v) => setState(() { _selectedLevel = v; _applyFilters(); }));
  void _showSportsPicker() => _showMultiPicker('Sports', BuddyProfileOptions.sports, _selectedSports, (list) => setState(() { _selectedSports.clear(); _selectedSports.addAll(list); _applyFilters(); }));
  void _showEquipmentPicker() => _showMultiPicker('Matériel', BuddyProfileOptions.equipment, _selectedEquipment, (list) => setState(() { _selectedEquipment.clear(); _selectedEquipment.addAll(list); _applyFilters(); }));

  void _showPicker(String title, List<String> options, String? selected, Function(String?) onSelected) {
    showModalBottomSheet(context: context, backgroundColor: _grisCarte, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (context) => Padding(padding: const EdgeInsets.all(14), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _texteClair)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: options.map((o) => GestureDetector(onTap: () { onSelected(selected == o ? null : o); Navigator.pop(context); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: selected == o ? _vertSauge : _grisCarteClair, borderRadius: BorderRadius.circular(8)), child: Text(o, style: TextStyle(color: selected == o ? Colors.white : _texteClair, fontWeight: selected == o ? FontWeight.w700 : FontWeight.w500))))).toList()),
        const SizedBox(height: 14),
      ])));
  }

  void _showMultiPicker(String title, List<String> options, List<String> selected, Function(List<String>) onChanged) {
    final temp = List<String>.from(selected);
    showModalBottomSheet(context: context, backgroundColor: _grisCarte, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) => Padding(padding: EdgeInsets.only(left: 14, right: 14, top: 14, bottom: MediaQuery.of(context).viewInsets.bottom + 14), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _texteClair)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: options.map((o) => GestureDetector(onTap: () => setModalState(() { if (temp.contains(o)) temp.remove(o); else temp.add(o); }), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: temp.contains(o) ? _vertSauge : _grisCarteClair, borderRadius: BorderRadius.circular(8)), child: Text(o, style: TextStyle(color: temp.contains(o) ? Colors.white : _texteClair, fontWeight: temp.contains(o) ? FontWeight.w700 : FontWeight.w500))))).toList()),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { onChanged(temp); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: _vertSauge, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('OK'))),
      ]))));
  }
}

class _CompactStatChip extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color; final VoidCallback? onTap;
  const _CompactStatChip({required this.icon, required this.value, required this.label, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: _grisCarte, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: _texteSecondaire))),
        if (onTap != null) Icon(Icons.chevron_right, size: 16, color: color.withOpacity(0.5)),
      ]),
    ));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title; final Color color; final VoidCallback onViewAll;
  const _SectionHeader({required this.title, this.color = _vertSauge, required this.onViewAll});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _texteClair)),
      ]),
      GestureDetector(onTap: onViewAll, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Tout', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 2),
          Icon(Icons.arrow_forward_ios, size: 9, color: color),
        ]),
      )),
    ]);
  }
}

class _MiniStep extends StatelessWidget {
  final String number; final String label;
  const _MiniStep({required this.number, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 20, height: 20, decoration: BoxDecoration(color: _vertSauge, borderRadius: BorderRadius.circular(5)), child: Center(child: Text(number, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)))),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 9, color: _texteSecondaire)),
    ]);
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label; final String? value; final IconData icon; final VoidCallback onTap;
  const _QuickFilterChip({required this.label, required this.value, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: hasValue ? _vertSauge : _grisCarte, borderRadius: BorderRadius.circular(8), border: Border.all(color: hasValue ? _vertSauge : _grisCarteClair)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: hasValue ? Colors.white : _texteSecondaire),
        const SizedBox(width: 4),
        Text(hasValue ? value! : label, style: TextStyle(fontSize: 11, fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500, color: hasValue ? Colors.white : _texteClair)),
      ]),
    ));
  }
}

class _ProfilePreviewCard extends StatelessWidget {
  final MatchProfile profile; final VoidCallback onTap;
  const _ProfilePreviewCard({required this.profile, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      width: 100, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _grisCarte, borderRadius: BorderRadius.circular(10), border: Border.all(color: _grisCarteClair.withOpacity(0.4))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_bleuArdoise, _bleuArdoiseClair]), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(profile.name[0].toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))),
        const SizedBox(height: 6),
        Text(profile.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _texteClair), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${profile.age}ans', style: const TextStyle(fontSize: 9, color: _texteSecondaire)),
        const SizedBox(height: 4),
        Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: profile.compatibilityScore >= 70 ? _vertOlive.withOpacity(0.3) : _bleuArdoise.withOpacity(0.3), borderRadius: BorderRadius.circular(4)), child: Text('${profile.compatibilityScore}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: profile.compatibilityScore >= 70 ? _vertSauge : _bleuArdoiseClair))),
      ]),
    ));
  }
}

class _BuddyAvatar extends StatelessWidget {
  final String name; final int compatibility; final VoidCallback onTap;
  const _BuddyAvatar({required this.name, required this.compatibility, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(width: 55, margin: const EdgeInsets.only(right: 10), child: Column(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
      const SizedBox(height: 3),
      Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _texteClair), maxLines: 1, overflow: TextOverflow.ellipsis),
      Text('$compatibility%', style: const TextStyle(fontSize: 8, color: _vertSauge, fontWeight: FontWeight.w600)),
    ])));
  }
}

class _FilterSection extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _FilterSection({required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _grisCarte, borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: _vertSauge, size: 16), const SizedBox(width: 6), Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _texteClair))]),
      const SizedBox(height: 10),
      child,
    ]));
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool isSelected; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: isSelected ? _vertSauge : _grisCarteClair, borderRadius: BorderRadius.circular(6)), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : _texteClair))));
  }
}

class _AgeField extends StatelessWidget {
  final String label; final int? value; final Function(int?) onChanged;
  const _AgeField({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: _texteSecondaire, fontSize: 11), filled: true, fillColor: _grisCarteClair, border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)), style: const TextStyle(color: _texteClair, fontSize: 13), controller: TextEditingController(text: value?.toString() ?? ''), onChanged: (v) => onChanged(v.isNotEmpty ? int.tryParse(v) : null));
  }
}

// Animation cercles concentriques pour match
class MatchCirclesAnimation extends StatefulWidget {
  final int score;
  final VoidCallback? onComplete;
  const MatchCirclesAnimation({super.key, required this.score, this.onComplete});
  @override
  State<MatchCirclesAnimation> createState() => _MatchCirclesAnimationState();
}

class _MatchCirclesAnimationState extends State<MatchCirclesAnimation> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _ctrl.addStatusListener((s) { if (s == AnimationStatus.completed) Future.delayed(const Duration(seconds: 2), () => widget.onComplete?.call()); });
  }

  @override
  void dispose() { _ctrl.dispose(); _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black, child: Center(child: AnimatedBuilder(animation: Listenable.merge([_ctrl, _pulse]), builder: (context, _) {
      final scale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)).value;
      final pulse = Tween<double>(begin: 1.0, end: 1.05).animate(_pulse).value;
      final rot = _ctrl.value * 2 * math.pi;
      return Transform.scale(scale: scale * pulse, child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 220, height: 220, child: Stack(alignment: Alignment.center, children: [
          Transform.rotate(angle: rot, child: _Ring(radius: 100, color: _roseMatch, progress: 0.75, stroke: 6)),
          Transform.rotate(angle: -rot * 0.7, child: _Ring(radius: 75, color: _vertMatch, progress: 0.85, stroke: 6)),
          Transform.rotate(angle: rot * 0.5, child: _Ring(radius: 50, color: _roseMatch.withOpacity(0.7), progress: 0.9, stroke: 5)),
          Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [_roseMatch.withOpacity(0.9), _vertMatch.withOpacity(0.9)]), boxShadow: [BoxShadow(color: _roseMatch.withOpacity(0.5), blurRadius: 15)]), child: Center(child: Text('${widget.score}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)))),
        ])),
        const SizedBox(height: 24),
        ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [_roseMatch, _vertMatch]).createShader(b), child: const Text('COMPATIBLE À', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2))),
        const SizedBox(height: 6),
        Text('${widget.score}%', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: _roseMatch, shadows: [Shadow(color: _roseMatch.withOpacity(0.5), blurRadius: 15)])),
      ]));
    })));
  }
}

class _Ring extends StatelessWidget {
  final double radius, stroke, progress; final Color color;
  const _Ring({required this.radius, required this.color, required this.progress, required this.stroke});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(radius * 2, radius * 2), painter: _RingPainter(radius: radius, color: color, progress: progress, stroke: stroke));
}

class _RingPainter extends CustomPainter {
  final double radius, stroke, progress; final Color color;
  _RingPainter({required this.radius, required this.color, required this.progress, required this.stroke});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, radius, Paint()..color = color.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = stroke);
    canvas.drawArc(Rect.fromCircle(center: c, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: c, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = stroke + 3..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }
  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

void showMatchAnimation(BuildContext context, int score, {VoidCallback? onComplete}) {
  showDialog(context: context, barrierDismissible: false, barrierColor: Colors.black, builder: (_) => MatchCirclesAnimation(score: score, onComplete: () { Navigator.of(context).pop(); onComplete?.call(); }));
}
