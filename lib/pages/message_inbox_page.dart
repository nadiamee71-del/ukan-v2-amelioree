import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/messaging.dart';
import '../models/theme_notifier.dart';
import 'message_thread_page.dart';

/// Page de boîte de réception des messages
class MessageInboxPage extends StatefulWidget {
  final String currentUserId;
  final bool isCoach; // Indique si l'utilisateur actuel est un coach

  const MessageInboxPage({
    super.key,
    required this.currentUserId,
    this.isCoach = false,
  });

  @override
  State<MessageInboxPage> createState() => _MessageInboxPageState();
}

class _MessageInboxPageState extends State<MessageInboxPage> {
  final _messagingNotifier = MessagingNotifier();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ThreadType? _selectedFilter; // null = tous

  @override
  void initState() {
    super.initState();
    _messagingNotifier.setCurrentUser(widget.currentUserId);
    _messagingNotifier.addListener(_onDataChanged);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _messagingNotifier.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<MessageThread> get _filteredThreads {
    List<MessageThread> threads = widget.isCoach
        ? _messagingNotifier.getThreadsForCoach(widget.currentUserId)
        : _messagingNotifier.getThreadsForUser(widget.currentUserId);

    // Filtre par type
    if (_selectedFilter != null) {
      threads = threads.where((t) => t.type == _selectedFilter).toList();
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      threads = threads.where((thread) {
        final otherName = thread.getOtherParticipantName(widget.currentUserId);
        return otherName.toLowerCase().contains(_searchQuery) ||
            thread.lastMessagePreview.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return threads;
  }

  Color _getThreadColor(ThreadType type) {
    switch (type) {
      case ThreadType.userToUser:
        return const Color(0xFF3A7AFE); // Bleu
      case ThreadType.userToCoach:
        return const Color(0xFFA45BFF); // Violet
      case ThreadType.coachToCoach:
        return const Color(0xFFF4A845); // Orange
    }
  }

  String _getThreadTypeLabel(ThreadType type) {
    switch (type) {
      case ThreadType.userToUser:
        return 'Utilisateur';
      case ThreadType.userToCoach:
        return widget.isCoach ? 'Client' : 'Coach';
      case ThreadType.coachToCoach:
        return 'Coach';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;
    final threads = _filteredThreads;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF733F24),
        foregroundColor: Colors.white,
        title: const Text('Messages'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une conversation...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtres par type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Tous',
                    isSelected: _selectedFilter == null,
                    onTap: () {
                      setState(() {
                        _selectedFilter = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: widget.isCoach ? 'Avec clients' : 'Avec coachs',
                    isSelected: _selectedFilter == ThreadType.userToCoach,
                    onTap: () {
                      setState(() {
                        _selectedFilter = ThreadType.userToCoach;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: widget.isCoach ? 'Avec coachs' : 'Avec utilisateurs',
                    isSelected: _selectedFilter == (widget.isCoach ? ThreadType.coachToCoach : ThreadType.userToUser),
                    onTap: () {
                      setState(() {
                        _selectedFilter = widget.isCoach ? ThreadType.coachToCoach : ThreadType.userToUser;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Liste des conversations
          Expanded(
            child: threads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Aucune conversation trouvée'
                              : 'Aucune conversation',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: threads.length,
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      final otherName = thread.getOtherParticipantName(widget.currentUserId);
                      final otherId = thread.getOtherParticipantId(widget.currentUserId);
                      final unreadCount = thread.getUnreadCountFor(widget.currentUserId);
                      final threadColor = _getThreadColor(thread.type);
                      final otherType = thread.getOtherParticipantType(widget.currentUserId);

                      return _ThreadTile(
                        thread: thread,
                        otherName: otherName,
                        otherId: otherId,
                        otherType: otherType,
                        unreadCount: unreadCount,
                        threadColor: threadColor,
                        formatTime: _formatTime,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MessageThreadPage(
                                thread: thread,
                                currentUserId: widget.currentUserId,
                                currentUserName: widget.isCoach ? 'Coach' : 'Utilisateur',
                                isCoach: widget.isCoach,
                              ),
                            ),
                          ).then((_) {
                            // Marquer comme lu après retour
                            _messagingNotifier.markThreadAsRead(thread.id, widget.currentUserId);
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour un filtre
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFC300)
              : (isDarkMode ? Colors.grey.shade800 : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFC300)
                : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.black
                : (isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}

/// Widget pour une tuile de conversation
class _ThreadTile extends StatelessWidget {
  final MessageThread thread;
  final String otherName;
  final String otherId;
  final SenderType otherType;
  final int unreadCount;
  final Color threadColor;
  final String Function(DateTime) formatTime;
  final VoidCallback onTap;

  const _ThreadTile({
    required this.thread,
    required this.otherName,
    required this.otherId,
    required this.otherType,
    required this.unreadCount,
    required this.threadColor,
    required this.formatTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: threadColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: threadColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: threadColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: threadColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        formatTime(thread.lastMessageAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: threadColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          otherType == SenderType.coach ? 'Coach' : 'Utilisateur',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: threadColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          thread.lastMessagePreview,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Badge non lus
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: threadColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}















