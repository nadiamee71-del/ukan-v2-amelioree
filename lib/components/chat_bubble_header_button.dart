import 'package:flutter/material.dart';
import '../alter_ego_floating/alter_ego_service.dart';

/// Bouton de chat en style bulle de discussion pour le header
class ChatBubbleHeaderButton extends StatefulWidget {
  const ChatBubbleHeaderButton({super.key});

  @override
  State<ChatBubbleHeaderButton> createState() => _ChatBubbleHeaderButtonState();
}

class _ChatBubbleHeaderButtonState extends State<ChatBubbleHeaderButton> {
  final AlterEgoService _service = AlterEgoService();
  bool _showChatInterface = false;

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
      setState(() {});
    }
  }

  void _toggleChat() {
    if (!_service.isChatActive) {
      _service.startConversation();
    } else {
      _service.toggleChatInterface();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUnreadMessages = _service.isChatActive && !_service.showChatInterface;
    
    return GestureDetector(
      onTap: _toggleChat,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 40,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bulle de discussion avec triangle (dessiné par CustomPaint)
            CustomPaint(
              size: const Size(40, 40),
              painter: ChatBubblePainter(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC300),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC300).withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _service.isChatActive ? Icons.chat : Icons.chat_bubble_outline,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
            // Badge de notification
            if (hasUnreadMessages)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red,
                        blurRadius: 4,
                        spreadRadius: 1,
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

/// Painter pour créer l'effet de bulle de discussion avec triangle
class ChatBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC300)
      ..style = PaintingStyle.fill;

    // Cercle principal (légèrement plus petit pour laisser de la place au triangle)
    final center = Offset(size.width / 2, size.height / 2 - 2);
    final radius = size.width / 2 - 3;
    canvas.drawCircle(center, radius, paint);

    // Petit triangle en bas à droite pour l'effet bulle de discussion
    final path = Path();
    final triangleSize = 5.0;
    final triangleX = size.width - triangleSize - 3;
    final triangleY = size.height - triangleSize - 1;
    
    path.moveTo(triangleX, triangleY);
    path.lineTo(triangleX + triangleSize, triangleY);
    path.lineTo(triangleX + triangleSize / 2, triangleY + triangleSize);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

