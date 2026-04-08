import 'package:flutter/material.dart';
import 'match_profile.dart';
import 'match_engine.dart';
import 'match_chat_page.dart';

/// ─────────────────────────────────────────────
/// Page Mes Buddies - Buddy Workout
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

class MatchResultsPage extends StatefulWidget {
  const MatchResultsPage({super.key});

  @override
  State<MatchResultsPage> createState() => _MatchResultsPageState();
}

class _MatchResultsPageState extends State<MatchResultsPage> {
  final _matchEngine = MatchEngine();

  @override
  void initState() {
    super.initState();
    _matchEngine.addListener(_onMatchesChanged);
  }

  @override
  void dispose() {
    _matchEngine.removeListener(_onMatchesChanged);
    super.dispose();
  }

  void _onMatchesChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matchEngine.getMatches();

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
                color: _vertSauge.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.handshake, size: 18, color: _vertSauge),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mes Buddies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: matches.isEmpty
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
                      child: const Icon(Icons.people_outline, size: 50, color: _texteSecondaire),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Aucun buddy pour l\'instant',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _texteClair,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Continue à découvrir des profils pour trouver ton partenaire d\'entraînement idéal !',
                      style: TextStyle(
                        fontSize: 14,
                        color: _texteSecondaire,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.search),
                      label: const Text('Découvrir des profils'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _vertSauge,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BuddyCard(
                    profile: match,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MatchChatPage(matchId: match.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _BuddyCard extends StatelessWidget {
  final MatchProfile profile;
  final VoidCallback onTap;

  const _BuddyCard({
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_vertSauge, _vertOlive],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _vertSauge.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
                  Row(
                    children: [
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _texteClair,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge Buddy
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _vertSauge.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.handshake, size: 12, color: _vertSauge),
                            SizedBox(width: 4),
                            Text(
                              'BUDDY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _vertSauge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: _texteSecondaire,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Compatibilité
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: profile.compatibilityScore >= 80
                              ? _vertOlive.withOpacity(0.2)
                              : _bleuArdoise.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 12,
                              color: profile.compatibilityScore >= 80 ? _vertSauge : _bleuArdoiseClair,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.compatibilityScore}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: profile.compatibilityScore >= 80 ? _vertSauge : _bleuArdoiseClair,
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

            // Flèche et bouton chat
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _vertSauge.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: _vertSauge, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
