import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Catégorie de message communautaire
enum ChatCategory {
  all,
  nutrition,
  training,
  motivation,
  questions,
  tips,
  achievements,
}

extension ChatCategoryX on ChatCategory {
  String get displayName {
    switch (this) {
      case ChatCategory.all:
        return 'Tous';
      case ChatCategory.nutrition:
        return 'Nutrition';
      case ChatCategory.training:
        return 'Entraînement';
      case ChatCategory.motivation:
        return 'Motivation';
      case ChatCategory.questions:
        return 'Questions';
      case ChatCategory.tips:
        return 'Conseils';
      case ChatCategory.achievements:
        return 'Succès';
    }
  }

  IconData get icon {
    switch (this) {
      case ChatCategory.all:
        return Icons.chat_bubble_outline;
      case ChatCategory.nutrition:
        return Icons.restaurant_outlined;
      case ChatCategory.training:
        return Icons.fitness_center;
      case ChatCategory.motivation:
        return Icons.favorite_outline;
      case ChatCategory.questions:
        return Icons.help_outline;
      case ChatCategory.tips:
        return Icons.lightbulb_outline;
      case ChatCategory.achievements:
        return Icons.emoji_events_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ChatCategory.all:
        return const Color(0xFF5D4037); // Marron foncé
      case ChatCategory.nutrition:
        return const Color(0xFF4CAF50); // Vert principal
      case ChatCategory.training:
        return const Color(0xFF8D6E63); // Marron principal
      case ChatCategory.motivation:
        return const Color(0xFF66BB6A); // Vert clair
      case ChatCategory.questions:
        return const Color(0xFFA1887F); // Marron clair
      case ChatCategory.tips:
        return const Color(0xFF388E3C); // Vert foncé
      case ChatCategory.achievements:
        return const Color(0xFF5D4037); // Marron foncé
    }
  }
}

/// Type de message
enum MessageType {
  normal,
  system, // Messages système (X a rejoint, etc.)
  announcement, // Annonces importantes
}

/// Réaction à un message
class MessageReaction {
  final String emoji;
  final List<String> userIds; // Utilisateurs qui ont réagi

  MessageReaction({
    required this.emoji,
    List<String>? userIds,
  }) : userIds = userIds ?? [];

  MessageReaction copyWith({
    String? emoji,
    List<String>? userIds,
  }) {
    return MessageReaction(
      emoji: emoji ?? this.emoji,
      userIds: userIds ?? this.userIds,
    );
  }
}

/// Message communautaire amélioré
class CommunityMessage {
  final String id;
  final DateTime date;
  final String username;
  final String userId;
  final String text;
  final ChatCategory category;
  final MessageType type;
  final List<MessageReaction> reactions;
  final List<CommunityMessage> replies; // Réponses à ce message
  final String? replyToId; // ID du message auquel on répond
  final bool isPinned;
  final int viewCount;
  final String? avatarColor; // Couleur de l'avatar

  CommunityMessage({
    required this.id,
    required this.date,
    required this.username,
    required this.userId,
    required this.text,
    this.category = ChatCategory.all,
    this.type = MessageType.normal,
    List<MessageReaction>? reactions,
    List<CommunityMessage>? replies,
    this.replyToId,
    this.isPinned = false,
    this.viewCount = 0,
    this.avatarColor,
  })  : reactions = reactions ?? [],
        replies = replies ?? [];

  int get totalLikes {
    final likeReaction = reactions.firstWhere(
      (r) => r.emoji == '👍',
      orElse: () => MessageReaction(emoji: '👍', userIds: []),
    );
    return likeReaction.userIds.length;
  }

  CommunityMessage copyWith({
    String? id,
    DateTime? date,
    String? username,
    String? userId,
    String? text,
    ChatCategory? category,
    MessageType? type,
    List<MessageReaction>? reactions,
    List<CommunityMessage>? replies,
    String? replyToId,
    bool? isPinned,
    int? viewCount,
    String? avatarColor,
  }) {
    return CommunityMessage(
      id: id ?? this.id,
      date: date ?? this.date,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      category: category ?? this.category,
      type: type ?? this.type,
      reactions: reactions ?? this.reactions,
      replies: replies ?? this.replies,
      replyToId: replyToId ?? this.replyToId,
      isPinned: isPinned ?? this.isPinned,
      viewCount: viewCount ?? this.viewCount,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}

/// ─────────────────────────────────────────────
/// Notifier pour le chat communautaire amélioré
/// ─────────────────────────────────────────────

class CommunityChatNotifier extends ChangeNotifier {
  static final CommunityChatNotifier _instance = CommunityChatNotifier._internal();
  factory CommunityChatNotifier() => _instance;
  CommunityChatNotifier._internal() {
    _initDemo();
  }

  final List<CommunityMessage> _messages = [];
  ChatCategory _selectedCategory = ChatCategory.all;
  String _searchQuery = '';

  ChatCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void _initDemo() {
    final now = DateTime.now();
    _messages.addAll([
      CommunityMessage(
        id: 'msg_1',
        date: now.subtract(const Duration(hours: 2)),
        username: 'Sarah M.',
        userId: 'sarah',
        category: ChatCategory.nutrition,
        text: 'Quels sont vos repas préférés après une séance intense ? Je cherche des idées saines et rapides ! 🥗',
        reactions: [
          MessageReaction(emoji: '👍', userIds: ['bilel', 'alex', 'marine']),
          MessageReaction(emoji: '💪', userIds: ['tom']),
        ],
        replies: [
          CommunityMessage(
            id: 'msg_1_reply_1',
            date: now.subtract(const Duration(hours: 1, minutes: 45)),
            username: 'Bilel',
            userId: 'bilel',
            category: ChatCategory.nutrition,
            text: 'Je prends toujours un shake protéiné avec banane et flocons d\'avoine. Rapide et efficace !',
            replyToId: 'msg_1',
            avatarColor: '#2196F3',
          ),
          CommunityMessage(
            id: 'msg_1_reply_2',
            date: now.subtract(const Duration(hours: 1, minutes: 30)),
            username: 'Marine',
            userId: 'marine',
            category: ChatCategory.nutrition,
            text: 'Salade de quinoa avec poulet grillé et légumes 🥙 Parfait pour la récup !',
            replyToId: 'msg_1',
            avatarColor: '#E91E63',
          ),
        ],
        isPinned: true,
        avatarColor: '#9C27B0',
      ),
      CommunityMessage(
        id: 'msg_2',
        date: now.subtract(const Duration(minutes: 45)),
        username: 'Alex',
        userId: 'alex',
        category: ChatCategory.training,
        text: 'Quelqu\'un a déjà testé le programme "Full body 30 min" ? J\'hésite à commencer...',
        reactions: [
          MessageReaction(emoji: '👍', userIds: ['sarah', 'tom']),
        ],
        replies: [
          CommunityMessage(
            id: 'msg_2_reply_1',
            date: now.subtract(const Duration(minutes: 30)),
            username: 'Tom',
            userId: 'tom',
            category: ChatCategory.training,
            text: 'Je l\'ai fait la semaine dernière, super intense mais efficace ! Tu vas adorer 💪',
            replyToId: 'msg_2',
            avatarColor: '#FF9800',
          ),
        ],
        avatarColor: '#4CAF50',
      ),
      CommunityMessage(
        id: 'msg_3',
        date: now.subtract(const Duration(minutes: 20)),
        username: 'Marine',
        userId: 'marine',
        category: ChatCategory.achievements,
        type: MessageType.announcement,
        text: '🎉 J\'ai enfin atteint mon objectif de 10 000 pas/jour pendant 7 jours d\'affilée ! Merci à tous pour le soutien !',
        reactions: [
          MessageReaction(emoji: '🎉', userIds: ['sarah', 'bilel', 'alex', 'tom']),
          MessageReaction(emoji: '🔥', userIds: ['sarah', 'bilel']),
          MessageReaction(emoji: '💪', userIds: ['alex']),
        ],
        isPinned: true,
        avatarColor: '#E91E63',
      ),
      CommunityMessage(
        id: 'msg_4',
        date: now.subtract(const Duration(minutes: 15)),
        username: 'Bilel',
        userId: 'bilel',
        category: ChatCategory.tips,
        text: '💡 Astuce : Si vous manquez de motivation le matin, préparez vos affaires de sport la veille au soir. Ça change tout !',
        reactions: [
          MessageReaction(emoji: '👍', userIds: ['sarah', 'alex', 'marine', 'tom']),
          MessageReaction(emoji: '💡', userIds: ['sarah']),
        ],
        avatarColor: '#2196F3',
      ),
      CommunityMessage(
        id: 'msg_5',
        date: now.subtract(const Duration(minutes: 10)),
        username: 'Tom',
        userId: 'tom',
        category: ChatCategory.questions,
        text: 'Question : Est-ce qu\'il faut vraiment faire des étirements avant une séance ? J\'ai entendu des avis contradictoires...',
        reactions: [
          MessageReaction(emoji: '🤔', userIds: ['alex']),
        ],
        avatarColor: '#FF9800',
      ),
      CommunityMessage(
        id: 'msg_6',
        date: now.subtract(const Duration(minutes: 5)),
        username: 'Sarah M.',
        userId: 'sarah',
        category: ChatCategory.motivation,
        text: 'On est tous là pour progresser ensemble ! 💪 N\'oubliez pas : chaque petit pas compte. Continuons !',
        reactions: [
          MessageReaction(emoji: '💪', userIds: ['bilel', 'alex', 'marine', 'tom']),
          MessageReaction(emoji: '❤️', userIds: ['bilel', 'marine']),
        ],
        avatarColor: '#9C27B0',
      ),
    ]);
  }

  List<CommunityMessage> get messages {
    var filtered = List<CommunityMessage>.from(_messages);
    
    // Filtrer par catégorie
    if (_selectedCategory != ChatCategory.all) {
      filtered = filtered.where((m) => m.category == _selectedCategory).toList();
    }
    
    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((m) => 
        m.text.toLowerCase().contains(query) ||
        m.username.toLowerCase().contains(query)
      ).toList();
    }
    
    // Trier : épinglés en premier, puis par date décroissante
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.date.compareTo(a.date);
    });
    
    return filtered;
  }

  List<CommunityMessage> get pinnedMessages {
    return _messages.where((m) => m.isPinned).toList();
  }

  int get totalMessages => _messages.length;
  
  int get activeUsers {
    final userIds = _messages.map((m) => m.userId).toSet();
    return userIds.length;
  }

  void setCategory(ChatCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addMessage(String text, ChatCategory category) {
    if (text.trim().isEmpty) return;

    final message = CommunityMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      date: DateTime.now(),
      username: 'Moi',
      userId: 'you',
      text: text.trim(),
      category: category,
      avatarColor: '#111111',
    );

    _messages.add(message);
    notifyListeners();
  }

  void addReply(String messageId, String text) {
    if (text.trim().isEmpty) return;

    final parentIndex = _messages.indexWhere((m) => m.id == messageId);
    if (parentIndex == -1) return;

    final reply = CommunityMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      date: DateTime.now(),
      username: 'Moi',
      userId: 'you',
      text: text.trim(),
      category: _messages[parentIndex].category,
      replyToId: messageId,
      avatarColor: '#111111',
    );

    final parent = _messages[parentIndex];
    final updatedReplies = List<CommunityMessage>.from(parent.replies)..add(reply);
    _messages[parentIndex] = parent.copyWith(replies: updatedReplies);
    notifyListeners();
  }

  void toggleReaction(String messageId, String emoji) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = _messages[messageIndex];
    final reactionIndex = message.reactions.indexWhere((r) => r.emoji == emoji);
    
    List<MessageReaction> updatedReactions;
    
    if (reactionIndex == -1) {
      // Ajouter la réaction
      updatedReactions = List<MessageReaction>.from(message.reactions)
        ..add(MessageReaction(emoji: emoji, userIds: ['you']));
    } else {
      // Retirer ou ajouter selon si l'utilisateur a déjà réagi
      final reaction = message.reactions[reactionIndex];
      if (reaction.userIds.contains('you')) {
        // Retirer la réaction
        final updatedUserIds = List<String>.from(reaction.userIds)..remove('you');
        if (updatedUserIds.isEmpty) {
          updatedReactions = List<MessageReaction>.from(message.reactions)..removeAt(reactionIndex);
        } else {
          updatedReactions = List<MessageReaction>.from(message.reactions);
          updatedReactions[reactionIndex] = reaction.copyWith(userIds: updatedUserIds);
        }
      } else {
        // Ajouter la réaction
        final updatedUserIds = List<String>.from(reaction.userIds)..add('you');
        updatedReactions = List<MessageReaction>.from(message.reactions);
        updatedReactions[reactionIndex] = reaction.copyWith(userIds: updatedUserIds);
      }
    }

    _messages[messageIndex] = message.copyWith(reactions: updatedReactions);
    notifyListeners();
  }

  void togglePin(String messageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = _messages[messageIndex];
    _messages[messageIndex] = message.copyWith(isPinned: !message.isPinned);
    notifyListeners();
  }
}
