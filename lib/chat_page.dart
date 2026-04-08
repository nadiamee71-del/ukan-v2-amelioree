import 'dart:async';
import 'package:flutter/material.dart';
import 'models/chat.dart';

class ChatPage extends StatefulWidget {
  final String clientId;
  final String clientName;

  const ChatPage({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatNotifier = ChatNotifier();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _chatNotifier.addListener(_onMessagesChanged);
    _messages = _chatNotifier.messagesForClient(widget.clientId);
    
    // Scroller en bas au chargement initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _chatNotifier.removeListener(_onMessagesChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessagesChanged() {
    setState(() {
      _messages = _chatNotifier.messagesForClient(widget.clientId);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Créer le message du client
    final messageId = 'msg_${DateTime.now().microsecondsSinceEpoch}';
    final message = ChatMessage(
      id: messageId,
      clientId: widget.clientId,
      sender: ChatSender.client,
      content: text,
      createdAt: DateTime.now(),
    );

    // Ajouter le message
    _chatNotifier.addMessage(message);
    _textController.clear();

    // Simuler une réponse du coach après 1-2 secondes
    _simulateCoachReply();
  }

  void _simulateCoachReply() {
    // Réponses automatiques du coach (démo)
    final responses = [
      'Bien reçu, on en reparle à la prochaine séance 👍',
      'Parfait ! Continue comme ça 💪',
      'Super ! Garde la motivation 😊',
      'D\'accord, je prends note. Bon courage !',
      'Merci pour ton retour. On continue !',
    ];

    final randomResponse =
        responses[DateTime.now().millisecond % responses.length];

    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;

      final replyId = 'msg_${DateTime.now().microsecondsSinceEpoch}';
      final reply = ChatMessage(
        id: replyId,
        clientId: widget.clientId,
        sender: ChatSender.coach,
        content: randomResponse,
        createdAt: DateTime.now(),
      );

      _chatNotifier.addMessage(reply);
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: Text('Chat avec ${widget.clientName}'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Bandeau Premium
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Color(0xFFFFC300),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'En Premium, tu bénéficies de réponses prioritaires et de modèles de messages.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Liste des messages
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun message pour le moment.\nCommencez la conversation !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _ChatBubble(
                          message: message,
                          formatTime: _formatTime,
                        );
                      },
                    ),
            ),

            // Menu Réponses rapides (pour coach)
            _QuickRepliesMenu(
              onReplySelected: (reply) {
                _textController.text = reply;
                _textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: reply.length),
                );
              },
            ),

            // Zone de saisie
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Tapez votre message...',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send),
                        color: const Color(0xFFFFC300),
                        tooltip: 'Envoyer',
                      ),
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String Function(DateTime) formatTime;

  const _ChatBubble({
    required this.message,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final isClient = message.sender == ChatSender.client;

    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isClient ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isClient
              ? null
              : Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                color: isClient ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: isClient ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menu des réponses rapides pour coach (templates de messages)
class _QuickRepliesMenu extends StatelessWidget {
  final void Function(String) onReplySelected;

  const _QuickRepliesMenu({required this.onReplySelected});

  static final List<String> _quickReplies = [
    'Bien reçu, on en reparle à la prochaine séance 👍',
    'Parfait ! Continue comme ça 💪',
    'Super ! Garde la motivation 😊',
    'Merci pour ton retour. On continue !',
    'D\'accord, je prends note. Bon courage !',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.smart_toy_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                'Réponses rapides (démo)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickReplies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onReplySelected(reply),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        reply.length > 40 ? '${reply.substring(0, 40)}...' : reply,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
