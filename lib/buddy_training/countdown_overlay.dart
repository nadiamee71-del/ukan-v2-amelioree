import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// COUNTDOWN OVERLAY - Animation 3, 2, 1, GO! avec sablier
/// ═══════════════════════════════════════════════════════════════════════════

const Color _primaryBlue = Color(0xFF00D4FF);
const Color _secondaryPurple = Color(0xFF7B2FFF);
const Color _accentPink = Color(0xFFFF2D92);
const Color _successGreen = Color(0xFF00E676);
const Color _warningOrange = Color(0xFFFF9100);
const Color _darkBg = Color(0xFF0A0A1A);

class CountdownOverlay extends StatefulWidget {
  final int value;
  final String exerciseName;
  
  const CountdownOverlay({
    super.key,
    required this.value,
    required this.exerciseName,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _hourglassController;
  late Animation<double> _hourglassAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation (bounce effect)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOut),
    );
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Hourglass animation
    _hourglassController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _hourglassAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hourglassController, curve: Curves.linear),
    );
    
    _startAnimation();
  }

  @override
  void didUpdateWidget(CountdownOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _scaleController.reset();
    _rotateController.reset();
    _scaleController.forward();
    _rotateController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    _hourglassController.dispose();
    super.dispose();
  }

  Color _getColorForValue(int value) {
    switch (value) {
      case 3:
        return _accentPink;
      case 2:
        return _warningOrange;
      case 1:
        return _primaryBlue;
      case 0:
        return _successGreen;
      default:
        return _primaryBlue;
    }
  }

  String _getTextForValue(int value) {
    if (value > 0) return value.toString();
    return 'GO!';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForValue(widget.value);
    final text = _getTextForValue(widget.value);
    final isGo = widget.value == 0;
    
    return Container(
      color: _darkBg.withOpacity(0.95),
      child: Stack(
        children: [
          // Background particles
          ...List.generate(50, (index) {
            final random = math.Random(index);
            return AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Positioned(
                  left: random.nextDouble() * MediaQuery.of(context).size.width,
                  top: random.nextDouble() * MediaQuery.of(context).size.height,
                  child: Container(
                    width: 3 + random.nextDouble() * 6,
                    height: 3 + random.nextDouble() * 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(_glowAnimation.value * 0.3 * random.nextDouble()),
                    ),
                  ),
                );
              },
            );
          }),
          
          // Radial glow
          Center(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(_glowAnimation.value * 0.4),
                        color.withOpacity(_glowAnimation.value * 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hourglass
                AnimatedBuilder(
                  animation: _hourglassAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _hourglassAnimation.value * math.pi * 2,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: color.withOpacity(0.5), width: 3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomPaint(
                          painter: _HourglassPainter(
                            color: color,
                            progress: _hourglassAnimation.value,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Countdown number/GO
                AnimatedBuilder(
                  animation: Listenable.merge([_scaleAnimation, _rotateAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color, color.withOpacity(0.6)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: 50,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: isGo ? 48 : 80,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Exercise name
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [color, _secondaryPurple],
                  ).createShader(bounds),
                  child: Text(
                    widget.exerciseName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  isGo ? 'C\'est parti ! 🔥' : 'Prépare-toi...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Progress dots at bottom
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final dotValue = 3 - index;
                final isActive = widget.value <= dotValue;
                final isPast = widget.value < dotValue;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: isActive ? 16 : 12,
                  height: isActive ? 16 : 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPast 
                        ? _successGreen 
                        : (isActive ? color : Colors.white.withOpacity(0.3)),
                    boxShadow: isActive
                        ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]
                        : null,
                  ),
                  child: isPast
                      ? const Icon(Icons.check, color: Colors.white, size: 10)
                      : null,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for animated hourglass
class _HourglassPainter extends CustomPainter {
  final Color color;
  final double progress;
  
  _HourglassPainter({required this.color, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Top triangle (sand remaining)
    final topPath = Path();
    topPath.moveTo(centerX, centerY - 5);
    topPath.lineTo(centerX - 20 * (1 - progress), 10);
    topPath.lineTo(centerX + 20 * (1 - progress), 10);
    topPath.close();
    canvas.drawPath(topPath, paint);
    
    // Bottom triangle (sand accumulated)
    final bottomPath = Path();
    bottomPath.moveTo(centerX, centerY + 5);
    bottomPath.lineTo(centerX - 20 * progress, size.height - 10);
    bottomPath.lineTo(centerX + 20 * progress, size.height - 10);
    bottomPath.close();
    canvas.drawPath(bottomPath, paint);
    
    // Center stream
    if (progress > 0 && progress < 1) {
      final streamPaint = Paint()
        ..color = color.withOpacity(0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(centerX, centerY - 5),
        Offset(centerX, centerY + 5),
        streamPaint,
      );
    }
    
    // Hourglass outline
    final outlinePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final outlinePath = Path();
    outlinePath.moveTo(centerX - 25, 5);
    outlinePath.lineTo(centerX + 25, 5);
    outlinePath.lineTo(centerX, centerY);
    outlinePath.lineTo(centerX + 25, size.height - 5);
    outlinePath.lineTo(centerX - 25, size.height - 5);
    outlinePath.lineTo(centerX, centerY);
    outlinePath.close();
    canvas.drawPath(outlinePath, outlinePaint);
  }
  
  @override
  bool shouldRepaint(covariant _HourglassPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}







