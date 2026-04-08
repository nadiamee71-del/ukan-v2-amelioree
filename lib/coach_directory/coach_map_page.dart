import 'package:flutter/material.dart';
import 'mock_coaches_data.dart';

// Palette de couleurs Ukan
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

/// Page de carte globale des coachs (simulation sans flutter_map pour éviter les dépendances)
class CoachMapPage extends StatefulWidget {
  final CoachData? initialCoach; // Si fourni, centre sur ce coach
  final double? userLat;
  final double? userLng;

  const CoachMapPage({
    super.key,
    this.initialCoach,
    this.userLat,
    this.userLng,
  });

  @override
  State<CoachMapPage> createState() => _CoachMapPageState();
}

class _CoachMapPageState extends State<CoachMapPage> {
  List<CoachData> _coaches = [];
  CoachData? _selectedCoach;
  bool _isLoading = true;
  String _selectedCity = 'Toutes les villes';
  bool _isDemoMode = true; // Switch DEMO/PROD

  // Liste des villes disponibles
  final List<String> _cities = [
    'Toutes les villes',
    'Paris',
    'Lyon',
    'Marseille',
    'Bordeaux',
    'Toulouse',
    'Nice',
    'Nantes',
    'Strasbourg',
    'Lille',
    'Montpellier',
  ];

  @override
  void initState() {
    super.initState();
    _loadCoaches();
    if (widget.initialCoach != null) {
      _selectedCoach = widget.initialCoach;
    }
  }

  void _loadCoaches() {
    setState(() {
      _isLoading = true;
    });

    // Simule un délai de chargement API
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _coaches = MockCoachesData.getCoachesWithLocation();
        _isLoading = false;
      });
    });
  }

  List<CoachData> get _filteredCoaches {
    if (_selectedCity == 'Toutes les villes') {
      return _coaches;
    }
    return _coaches.where((c) => c.city.toLowerCase().contains(_selectedCity.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Carte des coachs',
          style: TextStyle(
            color: _textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Filtre par ville
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: _primaryGold),
            color: _cardBg,
            onSelected: (city) {
              setState(() {
                _selectedCity = city;
                _selectedCoach = null;
              });
            },
            itemBuilder: (context) => _cities.map((city) {
              return PopupMenuItem<String>(
                value: city,
                child: Row(
                  children: [
                    Icon(
                      city == _selectedCity ? Icons.check_circle : Icons.circle_outlined,
                      color: city == _selectedCity ? _primaryGold : _textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      city,
                      style: TextStyle(
                        color: city == _selectedCity ? _primaryGold : _textLight,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _primaryGold),
            )
          : Column(
              children: [
                // Info bar avec switch DEMO/PROD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: _cardBg,
                  child: Row(
                    children: [
                      // Switch DEMO/PROD
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDemoMode = !_isDemoMode;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isDemoMode 
                                    ? 'Mode DEMO activé (données locales)'
                                    : 'Mode PROD activé (connecter /api/coaches)',
                              ),
                              backgroundColor: _isDemoMode ? _primaryGold : _primaryGreen,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isDemoMode ? _primaryGold : _primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isDemoMode ? Icons.science : Icons.cloud,
                                color: _darkBg,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isDemoMode ? 'DEMO' : 'PROD',
                                style: const TextStyle(
                                  color: _darkBg,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, color: _primaryGold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${_filteredCoaches.length} coachs',
                        style: const TextStyle(color: _textLight, fontSize: 13),
                      ),
                      const Spacer(),
                      if (_selectedCity != 'Toutes les villes')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primaryGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCity,
                                style: const TextStyle(color: _primaryGold, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCity = 'Toutes les villes';
                                  });
                                },
                                child: const Icon(Icons.close, color: _primaryGold, size: 14),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Carte simulée (grille de markers)
                Expanded(
                  flex: 2,
                  child: _buildSimulatedMap(),
                ),

                // Liste des coachs en bas
                Expanded(
                  flex: 1,
                  child: _buildCoachList(),
                ),
              ],
            ),
    );
  }

  /// Carte simulée avec une grille de markers
  Widget _buildSimulatedMap() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Stack(
        children: [
          // Fond de carte simulé
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _cardBg,
                    _cardBgLight,
                    _cardBg.withOpacity(0.8),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _MapGridPainter(),
                child: Container(),
              ),
            ),
          ),

          // Markers des coachs
          ..._buildMarkers(),

          // Légende
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cardBg.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARTE DEMO',
                    style: TextStyle(
                      color: _primaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _primaryGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Coach',
                        style: TextStyle(color: _textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Message si coach sélectionné
          if (_selectedCoach != null)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: _buildCoachPopup(_selectedCoach!),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMarkers() {
    final coaches = _filteredCoaches;
    if (coaches.isEmpty) return [];

    // Grouper par ville pour positionner les markers
    final Map<String, List<CoachData>> coachesByCity = {};
    for (final coach in coaches) {
      final cityKey = coach.city.split(' ').first; // Prend le premier mot de la ville
      coachesByCity.putIfAbsent(cityKey, () => []).add(coach);
    }

    // Positions approximatives des villes sur la carte simulée (en pourcentage)
    final Map<String, Offset> cityPositions = {
      'Paris': const Offset(0.55, 0.25),
      'Boulogne-Billancourt': const Offset(0.52, 0.27),
      'Neuilly-sur-Seine': const Offset(0.53, 0.23),
      'Lyon': const Offset(0.60, 0.55),
      'Marseille': const Offset(0.58, 0.80),
      'Bordeaux': const Offset(0.25, 0.60),
      'Toulouse': const Offset(0.35, 0.75),
      'Nice': const Offset(0.75, 0.75),
      'Nantes': const Offset(0.20, 0.40),
      'Strasbourg': const Offset(0.80, 0.25),
      'Lille': const Offset(0.55, 0.08),
      'Montpellier': const Offset(0.50, 0.78),
    };

    return coaches.map((coach) {
      final cityKey = coach.city.split(' ').first;
      final basePos = cityPositions[cityKey] ?? const Offset(0.5, 0.5);
      
      // Ajoute un petit décalage aléatoire pour éviter la superposition
      final index = coaches.indexOf(coach);
      final offsetX = (index % 3 - 1) * 0.03;
      final offsetY = (index ~/ 3 % 3 - 1) * 0.03;

      return Positioned(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final x = (basePos.dx + offsetX) * constraints.maxWidth;
            final y = (basePos.dy + offsetY) * constraints.maxHeight;

            return Stack(
              children: [
                Positioned(
                  left: x - 15,
                  top: y - 15,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCoach = coach;
                      });
                    },
                    child: _buildMarker(coach),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildMarker(CoachData coach) {
    final isSelected = _selectedCoach?.id == coach.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? 40 : 30,
      height: isSelected ? 40 : 30,
      decoration: BoxDecoration(
        color: isSelected ? _primaryGold : _cardBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? _primaryGold : _primaryGold.withOpacity(0.5),
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryGold.withOpacity(isSelected ? 0.5 : 0.3),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          coach.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            color: isSelected ? _darkBg : _primaryGold,
            size: isSelected ? 24 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCoachPopup(CoachData coach) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _primaryGold, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                coach.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _cardBgLight,
                  child: const Icon(Icons.person, color: _primaryGold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        coach.name,
                        style: const TextStyle(
                          color: _textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (coach.isVerified)
                      const Icon(Icons.verified, color: _primaryGold, size: 16),
                  ],
                ),
                Text(
                  coach.speciality,
                  style: const TextStyle(color: _primaryGold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: _textMuted, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      coach.city,
                      style: const TextStyle(color: _textMuted, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: _primaryGold, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      coach.rating.toString(),
                      style: const TextStyle(color: _textLight, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Boutons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPopupButton(
                icon: Icons.person,
                label: 'Profil',
                onTap: () {
                  Navigator.pop(context, coach);
                },
              ),
              const SizedBox(height: 4),
              _buildPopupButton(
                icon: Icons.close,
                label: 'Fermer',
                isSecondary: true,
                onTap: () {
                  setState(() {
                    _selectedCoach = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopupButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSecondary ? _cardBgLight : _primaryGold,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSecondary ? _textMuted : _darkBg,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSecondary ? _textMuted : _darkBg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachList() {
    final coaches = _filteredCoaches;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Titre
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Liste des coachs',
                  style: TextStyle(
                    color: _textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${coaches.length} résultats',
                  style: const TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          // Liste horizontale
          Expanded(
            child: coaches.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun coach trouvé',
                      style: TextStyle(color: _textMuted),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: coaches.length,
                    itemBuilder: (context, index) {
                      final coach = coaches[index];
                      return _buildMiniCoachCard(coach);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCoachCard(CoachData coach) {
    final isSelected = _selectedCoach?.id == coach.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCoach = coach;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGold.withOpacity(0.2) : _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryGold : _borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? _primaryGold : _borderColor,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  coach.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    color: _primaryGold,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Nom
            Text(
              coach.name.split(' ').first,
              style: TextStyle(
                color: isSelected ? _primaryGold : _textLight,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: _primaryGold, size: 10),
                const SizedBox(width: 2),
                Text(
                  coach.rating.toString(),
                  style: const TextStyle(color: _textMuted, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter pour dessiner une grille de carte simulée
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _borderColor.withOpacity(0.3)
      ..strokeWidth = 1;

    // Lignes horizontales
    for (int i = 1; i < 10; i++) {
      final y = size.height * i / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Lignes verticales
    for (int i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Texte "France" au centre
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'FRANCE',
        style: TextStyle(
          color: _textMuted,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

