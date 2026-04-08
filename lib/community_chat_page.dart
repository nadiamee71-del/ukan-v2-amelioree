import 'package:flutter/material.dart';
import 'models/community_chat.dart';

// Palette noir/or pour Communauté
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);
// Couleurs héritées pour compatibilité
const Color _marronPrincipal = Color(0xFFFFC300); // Remplacé par or
const Color _marronFonce = Color(0xFF161B22); // Remplacé par cardBg
const Color _marronClair = Color(0xFF21262D); // Remplacé par cardBgLight
const Color _vertPrincipal = Color(0xFF4ECDC4); // Vert accent
const Color _vertFonce = Color(0xFF2ECC71); // Vert foncé
const Color _vertClair = Color(0xFF58A6FF); // Bleu accent

class CommunityChatPage extends StatefulWidget {
  const CommunityChatPage({super.key});

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final _chatNotifier = CommunityChatNotifier();
  final _textController = TextEditingController();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _categoriesScrollController = ScrollController();
  bool _showRepliesToMessage = false;
  String? _replyingToMessageId;
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    _chatNotifier.addListener(_onMessagesChanged);
    _searchController.addListener(() {
      _chatNotifier.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _chatNotifier.removeListener(_onMessagesChanged);
    _textController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _categoriesScrollController.dispose();
    super.dispose();
  }

  void _onMessagesChanged() {
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && _chatNotifier.messages.isNotEmpty) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    if (_replyingToMessageId != null) {
      _chatNotifier.addReply(_replyingToMessageId!, _textController.text);
      _replyingToMessageId = null;
      _replyingToUsername = null;
    } else {
      _chatNotifier.addMessage(_textController.text, _chatNotifier.selectedCategory);
    }
    
    _textController.clear();
    setState(() {});
  }

  void _startReply(CommunityMessage message) {
    setState(() {
      _replyingToMessageId = message.id;
      _replyingToUsername = message.username;
    });
    _textController.clear();
  }

  void _cancelReply() {
    setState(() {
      _replyingToMessageId = null;
      _replyingToUsername = null;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getAvatarColor(String? colorHex) {
    if (colorHex == null) return _marronFonce;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return _marronFonce;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _chatNotifier.messages;
    final pinnedMessages = _chatNotifier.pinnedMessages;
    final stats = _chatNotifier;

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Chat Communautaire',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textLight),
            ),
            Text(
              '${stats.activeUsers} membres actifs • ${stats.totalMessages} messages',
              style: TextStyle(
                fontSize: 11,
                color: _textMuted,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: _primaryGold),
            onPressed: () => _showCategoryFilter(context),
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _cardBg,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _textLight),
              decoration: InputDecoration(
                hintText: 'Rechercher dans les messages...',
                hintStyle: const TextStyle(color: _textMuted),
                prefixIcon: const Icon(Icons.search, color: _textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: _textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _chatNotifier.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: _cardBgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),

          // Catégories (filtres horizontaux scrollables avec barre de scroll visible)
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: Scrollbar(
              controller: _categoriesScrollController,
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(2),
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                controller: _categoriesScrollController,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ChatCategory.values.map((category) {
                    final isSelected = _chatNotifier.selectedCategory == category;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 18,
                              color: isSelected ? Colors.white : category.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          _chatNotifier.setCategory(selected ? category : ChatCategory.all);
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: category.color,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        elevation: isSelected ? 2 : 0,
                        pressElevation: 4,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Messages épinglés
          if (pinnedMessages.isNotEmpty && _chatNotifier.selectedCategory == ChatCategory.all) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _vertClair.withOpacity(0.2),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: _marronFonce,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${pinnedMessages.length} message${pinnedMessages.length > 1 ? 's' : ''} épinglé${pinnedMessages.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _marronFonce,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Liste des messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _chatNotifier.selectedCategory.icon,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _chatNotifier.searchQuery.isNotEmpty
                              ? 'Aucun résultat pour "${_chatNotifier.searchQuery}"'
                              : 'Aucun message dans cette catégorie',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isYou = message.userId == 'you';
                      
                      return _MessageCard(
                        message: message,
                        isYou: isYou,
                        formatDate: _formatDate,
                        getAvatarColor: _getAvatarColor,
                        onReply: _startReply,
                        onToggleReaction: (emoji) {
                          _chatNotifier.toggleReaction(message.id, emoji);
                        },
                        onTogglePin: () {
                          _chatNotifier.togglePin(message.id);
                        },
                      );
                    },
                  ),
          ),

          // Zone de réponse (si on répond à un message)
          if (_replyingToMessageId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _vertClair.withOpacity(0.2),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Répondre à $_replyingToUsername',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _marronFonce,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Appuyez pour annuler',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _cancelReply,
                    color: _marronFonce,
                  ),
                ],
              ),
            ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                        hintText: _replyingToMessageId != null
                            ? 'Répondre à $_replyingToUsername...'
                            : 'Écrire un message...',
                        filled: true,
                        fillColor: const Color(0xFFF4F4F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _marronFonce,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: _vertPrincipal),
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

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer par catégorie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...ChatCategory.values.map((category) {
              final isSelected = _chatNotifier.selectedCategory == category;
              return ListTile(
                leading: Icon(
                  category.icon,
                  color: isSelected ? category.color : Colors.grey,
                ),
                title: Text(category.displayName),
                trailing: isSelected
                    ? Icon(Icons.check, color: category.color)
                    : null,
                onTap: () {
                  _chatNotifier.setCategory(category);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final CommunityMessage message;
  final bool isYou;
  final String Function(DateTime) formatDate;
  final Color Function(String?) getAvatarColor;
  final void Function(CommunityMessage) onReply;
  final void Function(String) onToggleReaction;
  final VoidCallback onTogglePin;

  const _MessageCard({
    required this.message,
    required this.isYou,
    required this.formatDate,
    required this.getAvatarColor,
    required this.onReply,
    required this.onToggleReaction,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = getAvatarColor(message.avatarColor);
    final isSystemMessage = message.type == MessageType.system;
    final isAnnouncement = message.type == MessageType.announcement;

    if (isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message principal
          Container(
            decoration: BoxDecoration(
              color: isAnnouncement
                  ? _vertClair.withOpacity(0.2)
                  : (isYou ? _marronFonce : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: message.isPinned
                  ? Border.all(color: _vertPrincipal, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec avatar, nom, date
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: avatarColor,
                        child: Text(
                          message.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  message.username,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isAnnouncement
                                        ? _marronFonce
                                        : (isYou ? Colors.white : Colors.black87),
                                  ),
                                ),
                                if (message.isPinned) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.push_pin,
                                    size: 14,
                                    color: _vertPrincipal,
                                  ),
                                ],
                                if (isAnnouncement) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _marronFonce,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'ANNONCE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: message.category.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        message.category.icon,
                                        size: 12,
                                        color: message.category.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        message.category.displayName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: message.category.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatDate(message.date),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isAnnouncement
                                        ? Colors.grey.shade600
                                        : (isYou ? Colors.white70 : Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu du message
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isAnnouncement
                          ? _marronFonce
                          : (isYou ? Colors.white : Colors.black87),
                    ),
                  ),
                ),

                // Réactions et actions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAnnouncement
                        ? Colors.white.withValues(alpha: 0.5)
                        : (isYou ? Colors.black.withValues(alpha: 0.1) : Colors.grey.shade100),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Réactions existantes
                      ...message.reactions.map((reaction) {
                        final hasReacted = reaction.userIds.contains('you');
                        return GestureDetector(
                          onTap: () => onToggleReaction(reaction.emoji),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: hasReacted
                                  ? _vertPrincipal.withValues(alpha: 0.2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: hasReacted
                                  ? Border.all(color: _vertPrincipal, width: 1)
                                  : Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  reaction.emoji,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (reaction.userIds.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '${reaction.userIds.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: hasReacted
                                          ? _marronFonce
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),

                      // Bouton pour ajouter une réaction
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.add_reaction_outlined,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: '👍',
                            child: Text('👍 J\'aime'),
                          ),
                          const PopupMenuItem(
                            value: '💪',
                            child: Text('💪 Motivant'),
                          ),
                          const PopupMenuItem(
                            value: '🔥',
                            child: Text('🔥 Incroyable'),
                          ),
                          const PopupMenuItem(
                            value: '❤️',
                            child: Text('❤️ Super'),
                          ),
                          const PopupMenuItem(
                            value: '🎉',
                            child: Text('🎉 Bravo'),
                          ),
                        ],
                        onSelected: (emoji) => onToggleReaction(emoji),
                      ),

                      const Spacer(),

                      // Bouton Répondre
                      TextButton.icon(
                        onPressed: () => onReply(message),
                        icon: const Icon(Icons.reply, size: 16),
                        label: const Text('Répondre'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),

                      // Bouton Épingler (si vous êtes l'auteur ou admin)
                      if (!message.isPinned)
                        IconButton(
                          icon: const Icon(Icons.push_pin_outlined, size: 18),
                          color: Colors.grey.shade600,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onTogglePin,
                          tooltip: 'Épingler',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Réponses (thread)
          if (message.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 60),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Afficher les réponses
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 2,
                            height: 30,
                            color: _vertPrincipal,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${message.replies.length} réponse${message.replies.length > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _marronFonce,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...message.replies.take(2).map((reply) {
                                  final replyAvatarColor = Color(int.parse(
                                    (reply.avatarColor ?? '#111111').replaceFirst('#', '0xFF')
                                  ));
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: replyAvatarColor,
                                          child: Text(
                                            reply.username[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            reply.text,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                if (message.replies.length > 2)
                                  Text(
                                    'Voir ${message.replies.length - 2} réponse${message.replies.length - 2 > 1 ? 's' : ''} supplémentaire${message.replies.length - 2 > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
