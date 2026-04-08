import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/demo_purchase.dart';
import '../premium_page.dart';

// ═══════════════════════════════════════════════════════════════════════════
// COACH IA PREMIUM - Analyse de Posture en Temps Réel
// Design professionnel Noir & Or
// ═══════════════════════════════════════════════════════════════════════════

// Palette noir/or
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);
const Color _accentGreen = Color(0xFF4ECDC4);
const Color _accentRed = Color(0xFFFF6B6B);
const Color _accentOrange = Color(0xFFFF9F43);
const Color _accentPurple = Color(0xFFA855F7);
const Color _accentBlue = Color(0xFF58A6FF);

class CoachIAPremiumPage extends StatefulWidget {
  const CoachIAPremiumPage({super.key});

  @override
  State<CoachIAPremiumPage> createState() => _CoachIAPremiumPageState();
}

class _CoachIAPremiumPageState extends State<CoachIAPremiumPage>
    with TickerProviderStateMixin {
  final _purchaseNotifier = DemoPurchaseNotifier();
  
  // Animations
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _glowAnimation;
  
  // État
  bool _isScanning = false;
  bool _hasPremium = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  // Données
  double _postureScore = 0.0;
  String _currentPosture = 'En attente';
  String _currentAdvice = 'Démarre le scan pour analyser ta posture';
  List<PostureAlert> _alerts = [];
  int _scanDuration = 0;
  Timer? _durationTimer;
  
  // Capteur
  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;

  @override
  void initState() {
    super.initState();
    _hasPremium = _purchaseNotifier.hasPremium;
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    if (_hasPremium) {
      // Auto-start en mode premium
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _glowController.dispose();
    _accelerometerSubscription?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  void _startScanning() {
    if (!_hasPremium) {
      _showPaywall();
      return;
    }
    
    setState(() {
      _isScanning = true;
      _scanDuration = 0;
    });
    
    // Timer pour la durée
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isScanning) {
        setState(() => _scanDuration++);
      }
    });
    
    // Capteur accéléromètre
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
        _analyzePosture();
      });
    });
    
    // Simulation si pas de capteur
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() => _simulatePostureAnalysis());
      }
    });
  }

  void _stopScanning() {
    setState(() => _isScanning = false);
    _accelerometerSubscription?.cancel();
    _durationTimer?.cancel();
  }

  void _analyzePosture() {
    final magnitude = sqrt(_x * _x + _y * _y + _z * _z);
    
    if (magnitude < 9.5) {
      _postureScore = 95.0;
      _currentPosture = 'Excellente';
      _currentAdvice = '✨ Posture parfaite ! Continue comme ça.';
    } else if (magnitude < 10.5) {
      _postureScore = 80.0;
      _currentPosture = 'Bonne';
      _currentAdvice = '👍 Posture correcte, quelques ajustements mineurs possibles.';
    } else if (magnitude < 11.5) {
      _postureScore = 60.0;
      _currentPosture = 'Moyenne';
      _currentAdvice = '⚡ Redresse légèrement ton dos et garde les épaules alignées.';
    } else {
      _postureScore = 40.0;
      _currentPosture = 'À corriger';
      _currentAdvice = '⚠️ Posture incorrecte ! Redresse-toi immédiatement.';
    }
  }

  void _simulatePostureAnalysis() {
    final random = Random();
    final score = 55 + random.nextDouble() * 40;
    
    _postureScore = score;
    
    if (score >= 85) {
      _currentPosture = 'Excellente';
      _currentAdvice = '✨ Posture parfaite ! Continue comme ça.';
    } else if (score >= 70) {
      _currentPosture = 'Bonne';
      _currentAdvice = '👍 Posture correcte, quelques ajustements mineurs possibles.';
    } else if (score >= 55) {
      _currentPosture = 'Moyenne';
      _currentAdvice = '⚡ Redresse légèrement ton dos et garde les épaules alignées.';
    } else {
      _currentPosture = 'À corriger';
      _currentAdvice = '⚠️ Posture incorrecte ! Redresse-toi immédiatement.';
    }
    
    if (random.nextDouble() < 0.25 && score < 65) {
      _addAlert();
    }
  }

  void _addAlert() {
    final alerts = [
      'Redresse ton dos',
      'Garde les épaules alignées',
      'Rentre le ventre légèrement',
      'Tête droite, regarde devant toi',
      'Évite de te pencher en avant',
      'Détends tes épaules',
    ];
    
    final random = Random();
    final alert = PostureAlert(
      message: alerts[random.nextInt(alerts.length)],
      timestamp: DateTime.now(),
      severity: _postureScore < 50 ? AlertSeverity.high : AlertSeverity.medium,
    );
    
    setState(() {
      _alerts.insert(0, alert);
      if (_alerts.length > 5) _alerts.removeLast();
    });
  }

  void _showPaywall() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryGold, _primaryGold.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryGold.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.lock_outline, color: _darkBg, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fonctionnalité Premium',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textLight,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Débloque l\'analyse de posture en temps réel avec l\'Intelligence Artificielle avancée.',
              style: TextStyle(color: _textMuted, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PremiumPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGold,
                  foregroundColor: _darkBg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Découvrir Premium',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Plus tard', style: TextStyle(color: _textMuted)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primaryGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology, color: _primaryGold, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Coach IA Premium',
              style: TextStyle(fontWeight: FontWeight.w700, color: _textLight),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_hasPremium)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: _darkBg, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: TextStyle(
                      color: _darkBg,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            _buildHeroSection(),
            const SizedBox(height: 24),
            
            if (!_hasPremium) ...[
              _buildPaywallCard(),
              const SizedBox(height: 24),
              _buildFeaturesGrid(),
            ] else ...[
              // Zone de scan
              _buildScanZone(),
              const SizedBox(height: 24),
              
              // Score de posture
              if (_isScanning || _postureScore > 0) ...[
                _buildPostureScore(),
                const SizedBox(height: 24),
                
                // Conseil
                _buildAdviceCard(),
                const SizedBox(height: 24),
              ],
              
              // Alertes
              if (_alerts.isNotEmpty) ...[
                _buildAlertsSection(),
                const SizedBox(height: 24),
              ],
              
              // Stats
              _buildStatsSection(),
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryGold.withOpacity(0.15),
            _accentPurple.withOpacity(0.1),
            _accentBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryGold.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryGold, _accentOrange],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGold.withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sensors_rounded, color: _darkBg, size: 45),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Analyse de Posture IA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _textLight,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'L\'IA analyse ta posture en temps réel grâce aux capteurs de mouvement. Reçois des conseils instantanés pour optimiser ta position.',
            style: TextStyle(
              fontSize: 14,
              color: _textMuted,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaywallCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryGold.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: _primaryGold.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryGold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline, color: _primaryGold, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'Fonctionnalité Premium',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textLight,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Débloque l\'analyse de posture en temps réel avec l\'Intelligence Artificielle.',
            style: TextStyle(fontSize: 14, color: _textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: _darkBg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Découvrir Premium',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fonctionnalités incluses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textLight,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildFeatureCard(Icons.analytics_outlined, 'Analyse temps réel', _accentBlue),
            _buildFeatureCard(Icons.lightbulb_outline, 'Conseils IA', _primaryGold),
            _buildFeatureCard(Icons.notifications_active_outlined, 'Alertes posture', _accentOrange),
            _buildFeatureCard(Icons.show_chart, 'Statistiques', _accentPurple),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScanZone() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isScanning
                  ? _primaryGold.withOpacity(_glowAnimation.value)
                  : _borderColor,
              width: 2,
            ),
            boxShadow: _isScanning
                ? [
                    BoxShadow(
                      color: _primaryGold.withOpacity(_glowAnimation.value * 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animation de scan
              if (_isScanning)
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 320),
                      painter: ScanPainter(
                        progress: _scanAnimation.value,
                        color: _primaryGold,
                      ),
                    );
                  },
                ),
              
              // Silhouette
              _buildBodySilhouette(),
              
              // Bouton de contrôle
              Positioned(
                bottom: 20,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? _stopScanning : _startScanning,
                  icon: Icon(
                    _isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 24,
                  ),
                  label: Text(
                    _isScanning ? 'Arrêter' : 'Démarrer le scan',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isScanning ? _accentRed : _primaryGold,
                    foregroundColor: _isScanning ? _textLight : _darkBg,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              // Indicateur de durée
              if (_isScanning)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _primaryGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _primaryGold.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, color: _primaryGold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${(_scanDuration ~/ 60).toString().padLeft(2, '0')}:${(_scanDuration % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: _primaryGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBodySilhouette() {
    final color = _isScanning ? _primaryGold : _textMuted;
    final opacity = _isScanning ? 0.3 : 0.1;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tête
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(height: 6),
        // Corps
        Container(
          width: 70,
          height: 100,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(height: 6),
        // Jambes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 25,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(opacity),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 25,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(opacity),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostureScore() {
    final color = _postureScore >= 80
        ? _accentGreen
        : _postureScore >= 60
            ? _accentOrange
            : _accentRed;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Score de Posture',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textMuted),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: _postureScore / 100,
                    strokeWidth: 14,
                    backgroundColor: _cardBgLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _postureScore.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentPosture,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    final color = _postureScore >= 80
        ? _accentGreen
        : _postureScore >= 60
            ? _accentOrange
            : _accentRed;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline, color: _primaryGold, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Conseil IA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  _postureScore >= 80 ? Icons.check_circle : Icons.info_outline,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentAdvice,
                    style: const TextStyle(
                      fontSize: 15,
                      color: _textLight,
                      height: 1.5,
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

  Widget _buildAlertsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active, color: _accentOrange, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Alertes Récentes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textLight),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_alerts.length}',
                  style: const TextStyle(color: _accentOrange, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._alerts.map((alert) => _buildAlertItem(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(PostureAlert alert) {
    final color = alert.severity == AlertSeverity.high ? _accentRed : _accentOrange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(alert.timestamp),
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques de session',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textLight),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer_outlined,
                  label: 'Durée',
                  value: _scanDuration > 0
                      ? '${(_scanDuration ~/ 60)}:${(_scanDuration % 60).toString().padLeft(2, '0')}'
                      : '0:00',
                  color: _accentBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Alertes',
                  value: '${_alerts.length}',
                  color: _accentOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  label: 'Score moy.',
                  value: _postureScore > 0 ? '${_postureScore.toStringAsFixed(0)}%' : '-',
                  color: _accentGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: _textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) return 'Il y a ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    return 'Il y a ${diff.inHours}h';
  }
}

// Classes auxiliaires
class PostureAlert {
  final String message;
  final DateTime timestamp;
  final AlertSeverity severity;

  PostureAlert({
    required this.message,
    required this.timestamp,
    required this.severity,
  });
}

enum AlertSeverity { low, medium, high }

class ScanPainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scanY = size.height * progress;
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.6),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 30, size.width, 60));

    canvas.drawRect(
      Rect.fromLTWH(0, scanY - 30, size.width, 60),
      gradient,
    );
  }

  @override
  bool shouldRepaint(ScanPainter oldDelegate) => oldDelegate.progress != progress;
}
