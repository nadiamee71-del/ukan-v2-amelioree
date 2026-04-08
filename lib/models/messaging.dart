import 'package:flutter/foundation.dart';

/// Type d'expéditeur
enum SenderType {
  user,
  coach,
}

/// Type de conversation
enum ThreadType {
  userToUser,
  userToCoach,
  coachToCoach,
}

/// Message individuel
class Message {
  final String id;
  final String threadId;
  final SenderType senderType;
  final String senderId;
  final String senderName; // Nom de l'expéditeur pour affichage
  final String content;
  final DateTime sentAt;
  final bool isRead;

  Message({
    required this.id,
    required this.threadId,
    required this.senderType,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });

  Message copyWith({
    String? id,
    String? threadId,
    SenderType? senderType,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Thread de conversation
class MessageThread {
  final String id;
  final ThreadType type;
  final List<String> participantIds; // 2 personnes uniquement
  final Map<String, String> participantNames; // id -> name
  final Map<String, String> participantAvatars; // id -> avatar (optionnel)
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadForUser; // compteur pour utilisateur
  final int unreadForCoach; // compteur pour coach
  final Map<String, int> unreadCountByParticipant; // pour user<->user ou coach<->coach

  MessageThread({
    required this.id,
    required this.type,
    required this.participantIds,
    required this.participantNames,
    this.participantAvatars = const {},
    required this.lastMessagePreview,
    required this.lastMessageAt,
    this.unreadForUser = 0,
    this.unreadForCoach = 0,
    this.unreadCountByParticipant = const {},
  });

  /// Récupère le nom de l'autre participant (celui qui n'est pas l'utilisateur courant)
  String getOtherParticipantName(String currentUserId) {
    final otherId = participantIds.firstWhere((id) => id != currentUserId);
    return participantNames[otherId] ?? 'Inconnu';
  }

  /// Récupère l'ID de l'autre participant
  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere((id) => id != currentUserId);
  }

  /// Récupère le type de l'autre participant
  SenderType getOtherParticipantType(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    // Déterminer selon le type de thread
    switch (type) {
      case ThreadType.userToUser:
        return SenderType.user;
      case ThreadType.userToCoach:
        return currentUserId == participantIds[0] ? SenderType.coach : SenderType.user;
      case ThreadType.coachToCoach:
        return SenderType.coach;
    }
  }

  /// Récupère le nombre de messages non lus pour un participant donné
  int getUnreadCountFor(String userId) {
    if (unreadCountByParticipant.containsKey(userId)) {
      return unreadCountByParticipant[userId] ?? 0;
    }
    // Fallback selon le type
    if (type == ThreadType.userToCoach) {
      // Déterminer si userId est user ou coach
      final isUser = participantIds[0] == userId && type == ThreadType.userToCoach;
      return isUser ? unreadForUser : unreadForCoach;
    }
    return 0;
  }

  MessageThread copyWith({
    String? id,
    ThreadType? type,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantAvatars,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadForUser,
    int? unreadForCoach,
    Map<String, int>? unreadCountByParticipant,
  }) {
    return MessageThread(
      id: id ?? this.id,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadForUser: unreadForUser ?? this.unreadForUser,
      unreadForCoach: unreadForCoach ?? this.unreadForCoach,
      unreadCountByParticipant: unreadCountByParticipant ?? this.unreadCountByParticipant,
    );
  }
}

/// Notifier pour gérer les threads et messages (mode démo)
class MessagingNotifier extends ChangeNotifier {
  static final MessagingNotifier _instance = MessagingNotifier._internal();
  factory MessagingNotifier() => _instance;
  MessagingNotifier._internal() {
    _initDemoData();
  }

  final List<MessageThread> _threads = [];
  final Map<String, List<Message>> _messagesByThread = {};
  String? _currentUserId; // ID de l'utilisateur/coach actuel

  List<MessageThread> get threads => List.unmodifiable(_threads);
  Map<String, List<Message>> get messagesByThread => Map.unmodifiable(_messagesByThread);

  /// Définit l'utilisateur courant
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  /// Récupère les threads pour un utilisateur
  List<MessageThread> getThreadsForUser(String userId) {
    return _threads.where((thread) {
      return thread.participantIds.contains(userId) &&
          (thread.type == ThreadType.userToUser || thread.type == ThreadType.userToCoach);
    }).toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  /// Récupère les threads pour un coach
  List<MessageThread> getThreadsForCoach(String coachId) {
    return _threads.where((thread) {
      return thread.participantIds.contains(coachId) &&
          (thread.type == ThreadType.coachToCoach || thread.type == ThreadType.userToCoach);
    }).toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  /// Récupère tous les threads pour un utilisateur/coach (selon son rôle)
  List<MessageThread> getAllThreadsFor(String userId) {
    return _threads.where((thread) => thread.participantIds.contains(userId)).toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  /// Récupère les messages d'un thread
  List<Message> getMessagesForThread(String threadId) {
    return _messagesByThread[threadId] ?? []
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  /// Envoie un message
  void sendMessage({
    required String threadId,
    required SenderType senderType,
    required String senderId,
    required String senderName,
    required String content,
  }) {
    final message = Message(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      threadId: threadId,
      senderType: senderType,
      senderId: senderId,
      senderName: senderName,
      content: content,
      sentAt: DateTime.now(),
      isRead: false,
    );

    // Ajouter le message au thread
    if (!_messagesByThread.containsKey(threadId)) {
      _messagesByThread[threadId] = [];
    }
    _messagesByThread[threadId]!.add(message);

    // Mettre à jour le thread
    final threadIndex = _threads.indexWhere((t) => t.id == threadId);
    if (threadIndex >= 0) {
      final thread = _threads[threadIndex];
      final otherParticipantId = thread.getOtherParticipantId(senderId);
      
      // Mettre à jour le compteur non lu pour l'autre participant
      final newUnreadCount = Map<String, int>.from(thread.unreadCountByParticipant);
      newUnreadCount[otherParticipantId] = (newUnreadCount[otherParticipantId] ?? 0) + 1;

      _threads[threadIndex] = thread.copyWith(
        lastMessagePreview: content.length > 50 ? '${content.substring(0, 50)}...' : content,
        lastMessageAt: DateTime.now(),
        unreadCountByParticipant: newUnreadCount,
      );
    }

    notifyListeners();
  }

  /// Marque un thread comme lu
  void markThreadAsRead(String threadId, String userId) {
    final threadIndex = _threads.indexWhere((t) => t.id == threadId);
    if (threadIndex >= 0) {
      final thread = _threads[threadIndex];
      final newUnreadCount = Map<String, int>.from(thread.unreadCountByParticipant);
      newUnreadCount[userId] = 0;

      _threads[threadIndex] = thread.copyWith(
        unreadCountByParticipant: newUnreadCount,
      );
    }

    // Marquer tous les messages comme lus
    if (_messagesByThread.containsKey(threadId)) {
      _messagesByThread[threadId] = _messagesByThread[threadId]!.map((msg) {
        if (msg.senderId != userId) {
          return msg.copyWith(isRead: true);
        }
        return msg;
      }).toList();
    }

    notifyListeners();
  }

  /// Récupère le nombre total de messages non lus pour un utilisateur
  int getTotalUnreadCountFor(String userId) {
    int total = 0;
    for (final thread in _threads) {
      if (thread.participantIds.contains(userId)) {
        total += thread.getUnreadCountFor(userId);
      }
    }
    return total;
  }

  /// Initialise les données de démo
  void _initDemoData() {
    // Thread User -> Coach
    final thread1 = MessageThread(
      id: 'thread_1',
      type: ThreadType.userToCoach,
      participantIds: ['user_1', 'coach_1'],
      participantNames: {
        'user_1': 'Alice Dupont',
        'coach_1': 'Sophie Martin',
      },
      participantAvatars: {
        'user_1': 'assets/images/avatars/avatar_f1.png',
        'coach_1': 'assets/images/avatars/avatar_f2.png',
      },
      lastMessagePreview: 'Merci pour les conseils !',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadForUser: 0,
      unreadForCoach: 2,
      unreadCountByParticipant: {
        'coach_1': 2,
      },
    );

    // Thread User -> User
    final thread2 = MessageThread(
      id: 'thread_2',
      type: ThreadType.userToUser,
      participantIds: ['user_1', 'user_2'],
      participantNames: {
        'user_1': 'Alice Dupont',
        'user_2': 'Bob Martin',
      },
      participantAvatars: {
        'user_1': 'assets/images/avatars/avatar_f1.png',
        'user_2': 'assets/images/avatars/avatar_m1.png',
      },
      lastMessagePreview: 'On se retrouve demain ?',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCountByParticipant: {
        'user_2': 1,
      },
    );

    // Thread Coach -> Coach
    final thread3 = MessageThread(
      id: 'thread_3',
      type: ThreadType.coachToCoach,
      participantIds: ['coach_1', 'coach_2'],
      participantNames: {
        'coach_1': 'Sophie Martin',
        'coach_2': 'Pierre Dubois',
      },
      participantAvatars: {
        'coach_1': 'assets/images/avatars/avatar_f2.png',
        'coach_2': 'assets/images/avatars/avatar_m2.png',
      },
      lastMessagePreview: 'Super séance hier !',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCountByParticipant: {
        'coach_2': 3,
      },
    );

    _threads.addAll([thread1, thread2, thread3]);

    // Messages de démo pour thread_1
    _messagesByThread['thread_1'] = [
      Message(
        id: 'msg_1',
        threadId: 'thread_1',
        senderType: SenderType.user,
        senderId: 'user_1',
        senderName: 'Alice Dupont',
        content: 'Bonjour, j\'aimerais avoir des conseils pour ma progression.',
        sentAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      Message(
        id: 'msg_2',
        threadId: 'thread_1',
        senderType: SenderType.coach,
        senderId: 'coach_1',
        senderName: 'Sophie Martin',
        content: 'Bonjour Alice ! Bien sûr, je peux t\'aider. Quels sont tes objectifs ?',
        sentAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        isRead: true,
      ),
      Message(
        id: 'msg_3',
        threadId: 'thread_1',
        senderType: SenderType.user,
        senderId: 'user_1',
        senderName: 'Alice Dupont',
        content: 'Je veux perdre 5 kg et gagner en masse musculaire.',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      Message(
        id: 'msg_4',
        threadId: 'thread_1',
        senderType: SenderType.coach,
        senderId: 'coach_1',
        senderName: 'Sophie Martin',
        content: 'Parfait ! Je vais te préparer un programme personnalisé.',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      Message(
        id: 'msg_5',
        threadId: 'thread_1',
        senderType: SenderType.coach,
        senderId: 'coach_1',
        senderName: 'Sophie Martin',
        content: 'Merci pour les conseils !',
        sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
    ];

    // Messages de démo pour thread_2
    _messagesByThread['thread_2'] = [
      Message(
        id: 'msg_6',
        threadId: 'thread_2',
        senderType: SenderType.user,
        senderId: 'user_1',
        senderName: 'Alice Dupont',
        content: 'Salut Bob ! Tu veux faire une séance ensemble ?',
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      Message(
        id: 'msg_7',
        threadId: 'thread_2',
        senderType: SenderType.user,
        senderId: 'user_2',
        senderName: 'Bob Martin',
        content: 'Oui, bonne idée ! On se retrouve demain ?',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];

    // Messages de démo pour thread_3
    _messagesByThread['thread_3'] = [
      Message(
        id: 'msg_8',
        threadId: 'thread_3',
        senderType: SenderType.coach,
        senderId: 'coach_1',
        senderName: 'Sophie Martin',
        content: 'Salut Pierre, super séance hier !',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      Message(
        id: 'msg_9',
        threadId: 'thread_3',
        senderType: SenderType.coach,
        senderId: 'coach_2',
        senderName: 'Pierre Dubois',
        content: 'Merci ! On refait ça bientôt ?',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
      ),
    ];
  }
}















