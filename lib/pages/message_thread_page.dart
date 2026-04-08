import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/messaging.dart';
import '../models/theme_notifier.dart';

/// Page de conversation individuelle
class MessageThreadPage extends StatefulWidget {
  final MessageThread thread;
  final String currentUserId;
  final String currentUserName;
  final bool isCoach;

  const MessageThreadPage({
    super.key,
    required this.thread,
    required this.currentUserId,
    required this.currentUserName,
    required this.isCoach,
  });

  @override
  State<MessageThreadPage> createState() => _MessageThreadPageState();
}

class _MessageThreadPageState extends State<MessageThreadPage> {
  final _messagingNotifier = MessagingNotifier();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messagingNotifier.addListener(_onDataChanged);
    // Marquer comme lu à l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messagingNotifier.markThreadAsRead(widget.thread.id, widget.currentUserId);
    });
  }

  @override
  void dispose() {
    _messagingNotifier.removeListener(_onDataChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
    // Scroller vers le bas quand un nouveau message arrive
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

    final senderType = widget.isCoach ? SenderType.coach : SenderType.user;

    _messagingNotifier.sendMessage(
      threadId: widget.thread.id,
      senderType: senderType,
      senderId: widget.currentUserId,
      senderName: widget.currentUserName,
      content: text,
    );

    _textController.clear();
  }

  Color _getBubbleColor(SenderType senderType, bool isCurrentUser) {
    switch (widget.thread.type) {
      case ThreadType.userToUser:
        return isCurrentUser
            ? const Color(0xFF3A7AFE) // Bleu clair pour l'utilisateur courant
            : const Color(0xFF1B4EC9); // Bleu foncé pour l'autre utilisateur

      case ThreadType.userToCoach:
        if (senderType == SenderType.user) {
          return const Color(0xFFA45BFF); // Violet pour l'utilisateur
        } else {
          return const Color(0xFFFFD34E); // Jaune pour le coach
        }

      case ThreadType.coachToCoach:
        return isCurrentUser
            ? const Color(0xFFF4A845) // Orange clair pour le coach courant
            : const Color(0xFFC97A21); // Orange foncé pour l'autre coach
    }
  }

  Color _getTextColor(SenderType senderType, bool isCurrentUser) {
    switch (widget.thread.type) {
      case ThreadType.userToUser:
        return Colors.white; // Texte blanc sur fond bleu

      case ThreadType.userToCoach:
        if (senderType == SenderType.user) {
          return Colors.white; // Texte blanc sur fond violet
        } else {
          return Colors.black87; // Texte noir sur fond jaune
        }

      case ThreadType.coachToCoach:
        return Colors.white; // Texte blanc sur fond orange
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Hier ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;
    final messages = _messagingNotifier.getMessagesForThread(widget.thread.id);
    final otherName = widget.thread.getOtherParticipantName(widget.currentUserId);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: _getBubbleColor(
          widget.thread.getOtherParticipantType(widget.currentUserId),
          false,
        ),
        foregroundColor: _getTextColor(
          widget.thread.getOtherParticipantType(widget.currentUserId),
          false,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.thread.getOtherParticipantType(widget.currentUserId) == SenderType.coach
                  ? 'Coach'
                  : 'Utilisateur',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'Aucun message',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message.senderId == widget.currentUserId;
                      final bubbleColor = _getBubbleColor(message.senderType, isCurrentUser);
                      final textColor = _getTextColor(message.senderType, isCurrentUser);

                      return _MessageBubble(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        bubbleColor: bubbleColor,
                        textColor: textColor,
                        formatTime: _formatTime,
                      );
                    },
                  ),
          ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Tapez un message...',
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
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
                      color: const Color(0xFFFFC300),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour une bulle de message
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final Color bubbleColor;
  final Color textColor;
  final String Function(DateTime) formatTime;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.bubbleColor,
    required this.textColor,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isCurrentUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isCurrentUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            if (!isCurrentUser) const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.sentAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                if (isCurrentUser && message.isRead) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}















