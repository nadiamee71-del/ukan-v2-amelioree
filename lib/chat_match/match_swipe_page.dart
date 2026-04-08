import 'package:flutter/material.dart';
import 'match_profile.dart';
import 'match_engine.dart';
import 'match_chat_page.dart';
import 'match_compatibility.dart';
import 'match_home_page.dart' show showMatchAnimation;

/// ─────────────────────────────────────────────
/// Page de découverte des profils - Buddy Workout
/// ─────────────────────────────────────────────

// Palette sobre
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

class MatchSwipePage extends StatefulWidget {
  const MatchSwipePage({super.key});

  @override
  State<MatchSwipePage> createState() => _MatchSwipePageState();
}

class _MatchSwipePageState extends State<MatchSwipePage> {
  final _matchEngine = MatchEngine();
  List<MatchProfile> _availableProfiles = [];
  int _currentIndex = 0;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _matchEngine.addListener(_onMatchesChanged);
    _loadProfiles();
  }

  @override
  void dispose() {
    _matchEngine.removeListener(_onMatchesChanged);
    super.dispose();
  }

  void _onMatchesChanged() {
    setState(() => _loadProfiles());
  }

  void _loadProfiles() {
    setState(() {
      _availableProfiles = _matchEngine.getAvailableProfiles();
      if (_currentIndex >= _availableProfiles.length) {
        _currentIndex = 0;
      }
    });
  }

  void _onSwipeLeft() {
    if (_currentIndex < _availableProfiles.length) {
      final profile = _availableProfiles[_currentIndex];
      _matchEngine.dislikeProfile(profile.id);
      _currentIndex++;
      _loadProfiles();
    }
  }

  void _onSwipeRight() {
    if (_currentIndex >= _availableProfiles.length) return;
    
    final profile = _availableProfiles[_currentIndex];
    final isMatch = profile.compatibilityScore >= 60;
    
    _matchEngine.likeProfile(profile.id);
    _currentIndex++;
    _loadProfiles();
    
    if (isMatch && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Animation cercles concentriques rose/vert
          showMatchAnimation(context, profile.compatibilityScore, onComplete: () {
            if (mounted) _showMatchDialog(profile);
          });
        }
      });
    }
  }

  MatchProfile? _getCurrentUserProfile() {
    return _matchEngine.currentUserProfile ?? MatchProfile(
      id: 'user',
      name: 'Moi',
      age: 28,
      level: 'Intermédiaire',
      goals: ['Prise de masse', 'Force'],
      availability: 'Soir',
      city: 'Paris',
      distance: 0,
      sportPreferences: {'musculation': true, 'hiit': true},
      sportCharacter: 'Motivé',
      compatibilityScore: 0,
      createdAt: DateTime.now(),
      equipment: ['Haltères', 'Banc'],
      motivation: 'Très motivé',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_availableProfiles.isEmpty) {
      return Scaffold(
        backgroundColor: _grisCharbon,
        appBar: AppBar(
          backgroundColor: _grisCharbon,
          foregroundColor: _texteClair,
          title: const Text('Buddy Workout'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _grisCarte,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.search_off, size: 50, color: _texteSecondaire),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Aucun profil disponible',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _texteClair),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tu as déjà vu tous les profils disponibles !\nReviens plus tard pour découvrir de nouveaux sportifs.',
                  style: TextStyle(fontSize: 14, color: _texteSecondaire, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _texteClair,
                    side: const BorderSide(color: _bleuArdoiseClair),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentProfile = _availableProfiles[_currentIndex];
    final userProfile = _getCurrentUserProfile();
    final compatResult = userProfile != null 
        ? calculateCompatibility(userProfile, currentProfile)
        : null;

    return Scaffold(
      backgroundColor: _grisCharbon,
      appBar: AppBar(
        backgroundColor: _grisCharbon,
        foregroundColor: _texteClair,
        elevation: 0,
        title: Column(
          children: [
            const Text('Découvrir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              '${_currentIndex + 1} / ${_availableProfiles.length}',
              style: const TextStyle(fontSize: 12, color: _texteSecondaire),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _availableProfiles.length,
                  backgroundColor: _grisCarte,
                  valueColor: const AlwaysStoppedAnimation<Color>(_vertSauge),
                  minHeight: 4,
                ),
              ),
            ),

            // Carte du profil
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: _grisCarte,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _grisCarteClair.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      // Header avec avatar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_bleuArdoise, _bleuArdoiseClair],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _bleuArdoise.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  currentProfile.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Nom et âge
                            Text(
                              '${currentProfile.name}, ${currentProfile.age} ans',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _texteClair,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currentProfile.city} • ${currentProfile.distance.toStringAsFixed(1)} km',
                              style: const TextStyle(fontSize: 14, color: _texteSecondaire),
                            ),
                            const SizedBox(height: 12),
                            
                            // Badge compatibilité
                            _buildCompatibilityBadge(currentProfile.compatibilityScore),
                          ],
                        ),
                      ),

                      // Onglets
                      _buildTabs(currentProfile, compatResult),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityBadge(int score) {
    final label = getCompatibilityLabel(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: label.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: label.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.handshake, size: 18, color: label.color),
          const SizedBox(width: 8),
          Text(
            '$score% • ${label.text}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: label.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(MatchProfile profile, CompatibilityResult? compatResult) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _grisCarteClair,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _TabButton(label: 'Résumé', isSelected: _selectedTabIndex == 0, onTap: () => setState(() => _selectedTabIndex = 0)),
              _TabButton(label: 'Sports', isSelected: _selectedTabIndex == 1, onTap: () => setState(() => _selectedTabIndex = 1)),
              _TabButton(label: 'Matériel', isSelected: _selectedTabIndex == 2, onTap: () => setState(() => _selectedTabIndex = 2)),
              _TabButton(label: 'Match', isSelected: _selectedTabIndex == 3, onTap: () => setState(() => _selectedTabIndex = 3)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Tab content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTabContent(profile, compatResult),
        ),
      ],
    );
  }

  Widget _buildTabContent(MatchProfile profile, CompatibilityResult? compatResult) {
    switch (_selectedTabIndex) {
      case 0: // Résumé
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _grisCarteClair.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _InfoRow(icon: Icons.trending_up, label: 'Niveau', value: profile.level),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.flag, label: 'Objectifs', value: profile.goals.take(2).join(', ')),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.schedule, label: 'Disponibilité', value: profile.availability),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.local_fire_department, label: 'Motivation', value: profile.motivation),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.repeat, label: 'Fréquence', value: profile.trainingFrequency),
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bleuArdoise.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bio', style: TextStyle(fontSize: 12, color: _texteSecondaire)),
                      const SizedBox(height: 4),
                      Text(
                        profile.bio!,
                        style: const TextStyle(fontSize: 13, color: _texteClair, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
        
      case 1: // Sports
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _grisCarteClair.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.sportPreferences.keys.map((sport) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  sport,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              );
            }).toList(),
          ),
        );
        
      case 2: // Matériel
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _grisCarteClair.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: profile.equipment.isEmpty
              ? const Center(
                  child: Text('Pas de matériel renseigné', style: TextStyle(color: _texteSecondaire)),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.equipment.map((equip) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _bleuArdoise,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fitness_center, size: 14, color: _texteClair),
                          const SizedBox(width: 6),
                          Text(
                            equip,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _texteClair),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        );
        
      case 3: // Match détaillé
        if (compatResult == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _grisCarteClair.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compatibilité détaillée',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _texteClair),
              ),
              const SizedBox(height: 16),
              ...compatResult.detailedScores.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 13, color: _texteSecondaire)),
                          Text('${entry.value}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _texteClair)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: _grisCharbon,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            entry.value >= 70 ? _vertSauge : _bleuArdoise,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              // Points forts
              const Text('Points forts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _texteClair)),
              const SizedBox(height: 8),
              ...compatResult.reasons.where((r) => r.isPositive).take(3).map((reason) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: _vertSauge),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason.text,
                          style: const TextStyle(fontSize: 13, color: _texteClair),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _grisCarte,
        border: Border(top: BorderSide(color: _grisCarteClair.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Passer
          _ActionButton(
            icon: Icons.close,
            label: 'Passer',
            color: Colors.red.shade400,
            onTap: _onSwipeLeft,
          ),
          
          // Liker
          _ActionButton(
            icon: Icons.favorite,
            label: 'Liker',
            color: _vertSauge,
            isPrimary: true,
            onTap: _onSwipeRight,
          ),
          
          // Infos
          _ActionButton(
            icon: Icons.info_outline,
            label: 'Détails',
            color: _bleuArdoiseClair,
            onTap: () => _showProfileDetails(context, _availableProfiles[_currentIndex]),
          ),
        ],
      ),
    );
  }

  void _showMatchDialog(MatchProfile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_bleuArdoiseFonce, _grisCharbon],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _vertSauge.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _vertSauge.withOpacity(0.5),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(Icons.handshake, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 20),
              const Text(
                '🎉 C\'est un MATCH !',
                style: TextStyle(
                  color: _vertSauge,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu as matché avec ${profile.name} !',
                style: const TextStyle(color: _texteClair, fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '${profile.compatibilityScore}% de compatibilité',
                style: const TextStyle(color: _texteSecondaire, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MatchChatPage(matchId: profile.id)),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble),
                  label: const Text('Discuter maintenant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _vertSauge,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuer à découvrir', style: TextStyle(color: _texteSecondaire)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _grisCarte,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: _vertSauge),
            SizedBox(width: 10),
            Text('Comment ça marche ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _texteClair)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(icon: Icons.favorite, text: 'Appuie sur ❤️ pour liker un profil'),
            const SizedBox(height: 12),
            _HelpItem(icon: Icons.close, text: 'Appuie sur ✕ pour passer'),
            const SizedBox(height: 12),
            _HelpItem(icon: Icons.handshake, text: 'Si vous vous plaisez → MATCH !'),
            const SizedBox(height: 12),
            _HelpItem(icon: Icons.chat_bubble, text: 'Discute et organise tes séances'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris !', style: TextStyle(color: _vertSauge)),
          ),
        ],
      ),
    );
  }

  void _showProfileDetails(BuildContext context, MatchProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: _grisCharbon,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_bleuArdoiseFonce, _bleuArdoise]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_bleuArdoise, _bleuArdoiseClair]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        profile.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile.name}, ${profile.age} ans',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _texteClair),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _vertSauge.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${profile.compatibilityScore}% compatible',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _vertSauge),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _texteClair),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailSection(title: 'Niveau', value: profile.level, icon: Icons.trending_up),
                    const SizedBox(height: 14),
                    _DetailSection(title: 'Objectifs', value: profile.goals.join(', '), icon: Icons.flag),
                    const SizedBox(height: 14),
                    _DetailSection(title: 'Disponibilité', value: profile.availability, icon: Icons.schedule),
                    const SizedBox(height: 14),
                    _DetailSection(title: 'Distance', value: '${profile.distance.toStringAsFixed(1)} km', icon: Icons.location_on),
                    const SizedBox(height: 14),
                    _DetailSection(title: 'Motivation', value: profile.motivation, icon: Icons.local_fire_department),
                    const SizedBox(height: 14),
                    _DetailSection(title: 'Fréquence', value: profile.trainingFrequency, icon: Icons.repeat),
                    const SizedBox(height: 20),
                    
                    // Sports
                    const Text('Sports pratiqués', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _texteClair)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.sportPreferences.keys.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _vertSauge,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Matériel
                    if (profile.equipment.isNotEmpty) ...[
                      const Text('Matériel disponible', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _texteClair)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.equipment.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _bleuArdoise,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _texteClair)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Bio
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      const Text('À propos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _texteClair)),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _grisCarte,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          profile.bio!,
                          style: const TextStyle(fontSize: 14, color: _texteClair, height: 1.5),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _onSwipeRight();
                        },
                        icon: const Icon(Icons.favorite),
                        label: const Text('Liker ce profil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _vertSauge,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// WIDGETS
// ═══════════════════════════════════════════════

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _vertSauge : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : _texteSecondaire,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _texteSecondaire),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: _texteSecondaire))),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _texteClair),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 70 : 56,
            height: isPrimary ? 70 : 56,
            decoration: BoxDecoration(
              color: isPrimary ? color : _grisCarteClair,
              shape: BoxShape.circle,
              border: isPrimary ? null : Border.all(color: color.withOpacity(0.5), width: 2),
              boxShadow: isPrimary ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Icon(icon, color: isPrimary ? Colors.white : color, size: isPrimary ? 32 : 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _vertSauge),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: _texteClair))),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DetailSection({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _grisCarte,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _texteSecondaire),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: _texteSecondaire)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _texteClair)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
