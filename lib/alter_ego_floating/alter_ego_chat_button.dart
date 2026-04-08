import 'package:flutter/material.dart';
import 'alter_ego_service.dart';

/// Icône bulle de PENSÉE pour ouvrir le chatbot Alter Ego
/// Utilise l'image de bulle personnalisée
class AlterEgoChatButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isActive;
  
  const AlterEgoChatButton({
    super.key,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<AlterEgoChatButton> createState() => _AlterEgoChatButtonState();
}

class _AlterEgoChatButtonState extends State<AlterEgoChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Détermine si le bouton est "actif" (cliqué ou chat ouvert)
    final isActiveState = _isPressed || widget.isActive;
    
    return Tooltip(
      message: 'Chatbot IA - Discuter avec ton coach virtuel',
      preferBelow: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isActive ? _pulseAnimation.value : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Bordure dorée quand actif/cliqué
                    border: Border.all(
                      color: isActiveState 
                          ? const Color(0xFFFFC300) 
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      // Ombre externe pour effet relief
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: _isPressed ? 3 : 6,
                        offset: Offset(0, _isPressed ? 1 : 3),
                      ),
                      // Lueur jaune - plus intense quand actif
                      BoxShadow(
                        color: const Color(0xFFFFC300).withOpacity(isActiveState ? 0.6 : 0.3),
                        blurRadius: isActiveState ? 12 : 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/bulle_chatbot.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback si l'image n'est pas trouvée
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            // Fond doré quand cliqué, gradient normal sinon
                            color: isActiveState ? const Color(0xFFFFC300) : null,
                            gradient: isActiveState ? null : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF21262D),
                                Color(0xFF161B22),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFC300), 
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: isActiveState ? Colors.black : const Color(0xFFFFC300),
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget pour l'icône de profil utilisateur (différent de la mascotte chatbot)
class AlterEgoProfileIcon extends StatefulWidget {
  final VoidCallback? onTap;
  final double size;
  
  const AlterEgoProfileIcon({
    super.key,
    this.onTap,
    this.size = 44,
  });

  @override
  State<AlterEgoProfileIcon> createState() => _AlterEgoProfileIconState();
}

class _AlterEgoProfileIconState extends State<AlterEgoProfileIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Mon Profil - Voir et modifier mes informations',
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Bordure dorée quand cliqué
              border: Border.all(
                color: _isPressed 
                    ? const Color(0xFFFFC300) 
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                // Ombre externe pour effet relief
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: _isPressed ? 3 : 6,
                  offset: Offset(0, _isPressed ? 1 : 3),
                ),
                // Lueur dorée - plus intense quand cliqué
                BoxShadow(
                  color: const Color(0xFFFFC300).withOpacity(_isPressed ? 0.6 : 0.25),
                  blurRadius: _isPressed ? 12 : 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                // Image différente pour le profil utilisateur (pas la mascotte)
                'assets/images/alter_ego_clindoeil.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      // Fond doré quand cliqué, gradient sombre sinon
                      color: _isPressed ? const Color(0xFFFFC300) : null,
                      gradient: _isPressed ? null : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF21262D),
                          Color(0xFF161B22),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFC300), 
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: _isPressed ? Colors.black : const Color(0xFFFFC300),
                      size: widget.size * 0.6,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
