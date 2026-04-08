import 'package:flutter/material.dart';
import 'alter_ego_service.dart';
import 'alter_ego_chat_button.dart';
import 'alter_ego_premium_chat.dart';

/// Widget flottant pour l'Alter Ego - Version Premium
/// Intègre le bouton avec bulles de pensée et la fenêtre draggable
class AlterEgoFloatingWidget extends StatefulWidget {
  final bool showFloatingButton;
  
  const AlterEgoFloatingWidget({
    super.key,
    this.showFloatingButton = true,
  });

  @override
  State<AlterEgoFloatingWidget> createState() => _AlterEgoFloatingWidgetState();
}

class _AlterEgoFloatingWidgetState extends State<AlterEgoFloatingWidget> {
  final AlterEgoService _service = AlterEgoService();
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) {
      // Utiliser addPostFrameCallback pour éviter setState pendant le build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showChat = _service.showChatInterface && _service.isChatActive;
          });
        }
      });
    }
  }

  void _openChat() {
    if (!_service.isChatActive) {
      _service.startConversation();
    } else {
      _service.toggleChatInterface();
    }
    setState(() => _showChat = true);
  }

  void _closeChat() {
    _service.hideChatInterface();
    setState(() => _showChat = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Fenêtre de chat premium draggable
        if (_showChat)
          AlterEgoPremiumChat(
            onClose: _closeChat,
            screenSize: screenSize,
          ),
        
        // Bouton flottant avec bulles de pensée (si activé)
        if (widget.showFloatingButton && !_showChat)
          Positioned(
            top: 80,
            right: 16,
            child: AlterEgoChatButton(
              onTap: _openChat,
              isActive: _service.isChatActive,
            ),
          ),
      ],
    );
  }
}

/// Widget simplifié pour l'AppBar - Bouton chatbot avec bulles
class AlterEgoAppBarButton extends StatelessWidget {
  const AlterEgoAppBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AlterEgoService();
    
    return GestureDetector(
      onTap: () {
        if (!service.isChatActive) {
          service.startConversation();
        } else {
          service.toggleChatInterface();
        }
      },
      child: AlterEgoChatButton(
        onTap: () {
          if (!service.isChatActive) {
            service.startConversation();
          } else {
            service.toggleChatInterface();
          }
        },
        isActive: service.isChatActive,
      ),
    );
  }
}
