import 'package:flutter/material.dart';
import '../models/messaging.dart';
import '../pages/message_inbox_page.dart';

/// Widget réutilisable pour l'icône de messagerie avec badge
class MessagingIconButton extends StatelessWidget {
  final String currentUserId;
  final bool isCoach;

  const MessagingIconButton({
    super.key,
    required this.currentUserId,
    this.isCoach = false,
  });

  @override
  Widget build(BuildContext context) {
    final messagingNotifier = MessagingNotifier();
    final unreadCount = messagingNotifier.getTotalUnreadCountFor(currentUserId);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.message_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MessageInboxPage(
                  currentUserId: currentUserId,
                  isCoach: isCoach,
                ),
              ),
            );
          },
          tooltip: 'Messages',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}















