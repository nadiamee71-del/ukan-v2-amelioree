import 'package:flutter/foundation.dart';

/// Expéditeur du message
enum ChatSender {
  client,
  coach,
}

/// Message dans une conversation
class ChatMessage {
  final String id;
  final String clientId; // ex: "sarah", "mehdi"
  final ChatSender sender; // client ou coach
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.clientId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });
}

/// Notifier pour gérer les messages de chat (en mémoire)
class ChatNotifier extends ChangeNotifier {
  static final ChatNotifier _instance = ChatNotifier._internal();
  factory ChatNotifier() => _instance;
  ChatNotifier._internal() {
    // Messages de démo pour le client "sarah"
    _messages.addAll([
      ChatMessage(
        id: 'demo_1',
        clientId: 'sarah',
        sender: ChatSender.coach,
        content: 'Salut Sarah, prêt(e) pour la séance d\'aujourd\'hui ?',
        createdAt: DateTime(2024, 1, 15, 9, 30),
      ),
      ChatMessage(
        id: 'demo_2',
        clientId: 'sarah',
        sender: ChatSender.client,
        content: 'Oui, je suis motivée ! 💪',
        createdAt: DateTime(2024, 1, 15, 9, 45),
      ),
      ChatMessage(
        id: 'demo_3',
        clientId: 'sarah',
        sender: ChatSender.coach,
        content: 'Parfait ! On se retrouve à 18h30 pour le full body.',
        createdAt: DateTime(2024, 1, 15, 10, 0),
      ),
    ]);
  }

  final List<ChatMessage> _messages = [];

  /// Récupère les messages pour un client donné (triés par date)
  List<ChatMessage> messagesForClient(String clientId) {
    final list = _messages
        .where((m) => m.clientId == clientId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  /// Ajoute un nouveau message
  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}

