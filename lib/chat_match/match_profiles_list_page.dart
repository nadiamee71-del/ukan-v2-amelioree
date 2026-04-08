import 'package:flutter/material.dart';
import 'match_profile.dart';
import 'match_engine.dart';
import 'match_compatibility.dart';
import 'match_swipe_page.dart';

/// ─────────────────────────────────────────────
/// Liste des profils compatibles - Buddy Workout
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

class MatchProfilesListPage extends StatefulWidget {
  final List<MatchProfile> profiles;

  const MatchProfilesListPage({
    super.key,
    required this.profiles,
  });

  @override
  State<MatchProfilesListPage> createState() => _MatchProfilesListPageState();
}

class _MatchProfilesListPageState extends State<MatchProfilesListPage> {
  final _matchEngine = MatchEngine();

  @override
  Widget build(BuildContext context) {
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
                color: _bleuArdoise.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.people, size: 18, color: _bleuArdoiseClair),
            ),
            const SizedBox(width: 10),
            const Text(
              'Profils compatibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: widget.profiles.isEmpty
          ? Center(
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _texteClair,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Reviens plus tard pour découvrir de nouveaux sportifs près de chez toi.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _texteSecondaire,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.profiles.length,
              itemBuilder: (context, index) {
                final profile = widget.profiles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProfileCard(
                    profile: profile,
                    onTap: () => _showProfileDetails(profile),
                  ),
                );
              },
            ),
    );
  }

  void _showProfileDetails(MatchProfile profile) {
    final userProfile = _matchEngine.currentUserProfile;
    final compatResult = userProfile != null 
        ? calculateCompatibility(userProfile, profile)
        : null;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: _grisCharbon,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bleuArdoiseFonce, _bleuArdoise],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _texteClair,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: _texteClair),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_bleuArdoise, _bleuArdoiseClair],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          profile.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${profile.name}, ${profile.age} ans',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _texteClair,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${profile.city} • ${profile.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 14, color: _texteSecondaire),
                    ),
                    const SizedBox(height: 12),
                    _buildCompatibilityBadge(profile.compatibilityScore),
                  ],
                ),
              ),
              
              // Contenu
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Infos principales
                    _InfoSection(
                      title: 'Informations',
                      children: [
                        _InfoRow(icon: Icons.trending_up, label: 'Niveau', value: profile.level),
                        _InfoRow(icon: Icons.flag, label: 'Objectifs', value: profile.goals.take(2).join(', ')),
                        _InfoRow(icon: Icons.schedule, label: 'Disponibilité', value: profile.availability),
                        _InfoRow(icon: Icons.local_fire_department, label: 'Motivation', value: profile.motivation),
                        _InfoRow(icon: Icons.repeat, label: 'Fréquence', value: profile.trainingFrequency),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Sports
                    _InfoSection(
                      title: 'Sports pratiqués',
                      children: [
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
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Matériel
                    if (profile.equipment.isNotEmpty) ...[
                      _InfoSection(
                        title: 'Matériel disponible',
                        children: [
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.fitness_center, size: 12, color: _texteClair),
                                    const SizedBox(width: 6),
                                    Text(
                                      e,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _texteClair,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Compatibilité détaillée
                    if (compatResult != null) ...[
                      _InfoSection(
                        title: 'Compatibilité détaillée',
                        children: [
                          ...compatResult.detailedScores.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(fontSize: 13, color: _texteSecondaire),
                                      ),
                                      Text(
                                        '${entry.value}%',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _texteClair,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: entry.value / 100,
                                      backgroundColor: _grisCarteClair,
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
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Bio
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      _InfoSection(
                        title: 'À propos',
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _grisCarteClair.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              profile.bio!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _texteClair,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Bouton
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MatchSwipePage()),
                          );
                        },
                        icon: const Icon(Icons.search, size: 20),
                        label: const Text(
                          'Découvrir ce profil',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _vertSauge,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
          Icon(Icons.handshake, size: 16, color: label.color),
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
}

class _ProfileCard extends StatelessWidget {
  final MatchProfile profile;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = getCompatibilityLabel(profile.compatibilityScore);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _grisCarte,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _grisCarteClair.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_bleuArdoise, _bleuArdoiseClair],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.name}, ${profile.age} ans',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _texteClair,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.level,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _texteSecondaire,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: _texteSecondaire),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.distance.toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 12, color: _texteSecondaire),
                      ),
                      const SizedBox(width: 12),
                      // Badge compatibilité
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: label.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, size: 12, color: label.color),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.compatibilityScore}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: label.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Icon(Icons.chevron_right, color: _texteSecondaire),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _grisCarte,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _grisCarteClair.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _texteClair,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _texteSecondaire),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: _texteSecondaire),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _texteClair,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
