import 'package:flutter/material.dart';

class ParrainageButton extends StatefulWidget {
  final VoidCallback? onTap;

  const ParrainageButton({
    super.key,
    this.onTap,
  });

  @override
  State<ParrainageButton> createState() => _ParrainageButtonState();
}

class _ParrainageButtonState extends State<ParrainageButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final buttonSize = isSmallScreen ? 56.0 : 64.0;
    final fontSize = isSmallScreen ? 10.0 : 11.0;
    
    return Tooltip(
      message: 'Parrainage - Invite tes amis et gagne des récompenses !',
      preferBelow: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bouton rond - NOIR quand non cliqué, JAUNE/OR quand cliqué
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  // Intérieur : noir normal, jaune/or quand cliqué
                  color: _isPressed ? const Color(0xFFFFC300) : Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFC300),
                    width: 3,
                  ),
                  boxShadow: [
                    // Ombre principale pour effet relief 3D
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: _isPressed ? 4 : 8,
                      offset: Offset(0, _isPressed ? 2 : 4),
                      spreadRadius: 1,
                    ),
                    // Lueur jaune pour effet "glowing" - plus intense quand cliqué
                    BoxShadow(
                      color: const Color(0xFFFFC300).withOpacity(_isPressed ? 0.8 : 0.5),
                      blurRadius: _isPressed ? 16 : 12,
                      offset: const Offset(0, 2),
                      spreadRadius: _isPressed ? 4 : 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/fitpro_logo.png',
                    width: buttonSize,
                    height: buttonSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si le logo n'existe pas - icône kangourou
                      return Container(
                        decoration: BoxDecoration(
                          color: _isPressed ? const Color(0xFFFFC300) : Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          size: 32,
                          color: _isPressed ? Colors.black : const Color(0xFFFFC300),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Texte en dessous - adaptatif, change de couleur au clic
              SizedBox(
                width: isSmallScreen ? 70 : 80,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: _isPressed ? const Color(0xFFFFC300) : const Color(0xFF8B949E),
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                  child: const Text(
                    'Parrainer & Gagner',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

