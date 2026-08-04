import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _imageTransitionAnimation;
  
  int _currentImageIndex = 0;
  // Animation de boxe : 2 positions (replié, poing droit)
  final List<String> _logoPaths = [
    'assets/images/fitpro_logo_boxeur_replie.png',    // Position repliée (garde)
    'assets/images/fitpro_logo_boxeur_droit.png',      // Coup de poing droit
  ];

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation (durée totale : 3 secondes)
    // Séquence : Replié (0-1.5s) → Bras droit (1.5-3s) → Fin
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Animation de fade in pour la première image (position repliée)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    // Animation de scale (zoom) pour l'apparition
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.elasticOut),
      ),
    );

    // Animation de transition entre les 2 images (replié → droit)
    _imageTransitionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.95, curve: Curves.easeInOut),
      ),
    );

    // Démarrer l'animation
    _controller.forward();
    
    // Mettre à jour l'index de l'image de manière fluide selon la progression
    _controller.addListener(() {
      if (mounted) {
        final progress = _imageTransitionAnimation.value;
        int newIndex;
        
        if (progress < 0.5) {
          newIndex = 0; // Replié
        } else {
          newIndex = 1; // Bras droit
        }
        
        if (newIndex != _currentImageIndex) {
          setState(() {
            _currentImageIndex = newIndex;
          });
        }
      }
    });

    // Rediriger vers la page de connexion après l'animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo avec animation de transition entre deux images
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildAnimatedLogo(),
                  ),
                ),
                const SizedBox(height: 24),
                // Texte Ukan avec animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'UKAN',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    // Calculer les effets visuels selon la progression de l'animation
    final progress = _imageTransitionAnimation.value;
    double scale = 1.0;
    double translateX = 0.0;
    
    // Calculer l'index et les effets de manière fluide
    if (progress < 0.5) {
      // Position repliée (0.0 - 0.5)
      scale = 1.0;
      translateX = 0.0;
    } else {
      // Bras droit (0.5 - 1.0) - Effet de "punch" fluide
      final localProgress = (progress - 0.5) / 0.5;
      // Animation de punch : expansion puis retour
      final punchCurve = localProgress < 0.5 
          ? localProgress * 2.0  // Expansion (0.0 -> 1.0)
          : 2.0 - (localProgress * 2.0); // Retour (1.0 -> 0.0)
      scale = 1.0 + (punchCurve * 0.2);
      translateX = punchCurve * 30.0; // Translation vers la droite
    }
    
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: child,
            ),
          );
        },
        child: Transform.translate(
          key: ValueKey<int>(_currentImageIndex),
          offset: Offset(translateX, 0),
          child: Transform.scale(
            scale: scale,
            child: _buildLogoImage(_logoPaths[_currentImageIndex]),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoImage(String imagePath) {
    return Image.asset(
      imagePath,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      cacheWidth: 400,
      cacheHeight: 400,
      errorBuilder: (context, error, stackTrace) {
        // Debug: afficher l'erreur en mode debug
        debugPrint('❌ Erreur chargement logo: $imagePath - $error');
        // Si le logo n'existe pas, afficher un logo par défaut avec l'icône
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC300),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 100,
            color: Colors.black,
          ),
        );
      },
    );
  }
}

