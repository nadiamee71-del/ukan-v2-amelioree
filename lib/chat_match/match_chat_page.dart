import 'package:flutter/material.dart';
import 'match_engine.dart';
import 'match_profile.dart';

/// ─────────────────────────────────────────────
/// Page de discussion - Buddy Workout
/// ─────────────────────────────────────────────

// Palette sobre
const Color _bleuArdoise = Color(0xFF475569);
const Color _bleuArdoiseFonce = Color(0xFF334155);
const Color _bleuArdoiseClair = Color(0xFF64748B);
const Color _vertSauge = Color(0xFF6B8E7E);
const Color _vertOlive = Color(0xFF4A7C59);
const Color _grisCharbon = Color(0xFF1E293B);
const Color _grisCarte = Color(0xFF2D3A4F);
const Color _grisCarteClair = Color(0xFF3D4A5F);
const Color _texteClair = Color(0xFFF1F5F9);
const Color _texteSecondaire = Color(0xFF94A3B8);

class MatchChatPage extends StatefulWidget {
  final String matchId;

  const MatchChatPage({
    super.key,
    required this.matchId,
  });

  @override
  State<MatchChatPage> createState() => _MatchChatPageState();
}

class _MatchChatPageState extends State<MatchChatPage> {
  final _matchEngine = MatchEngine();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  MatchProfile? _matchProfile;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMatchProfile();
    _initDemoMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMatchProfile() {
    final matches = _matchEngine.getMatches();
    try {
      _matchProfile = matches.firstWhere((m) => m.id == widget.matchId);
      setState(() {});
    } catch (e) {
      final allProfiles = _matchEngine.getAvailableProfiles();
      try {
        _matchProfile = allProfiles.firstWhere((m) => m.id == widget.matchId);
        setState(() {});
      } catch (e2) {
        _matchProfile = MatchProfile(
          id: widget.matchId,
          name: 'Buddy',
          age: 25,
          level: 'Intermédiaire',
          goals: ['Sport'],
          availability: 'Flexible',
          city: 'Paris',
          distance: 0,
          sportPreferences: {'fitness': true},
          sportCharacter: 'Motivé',
          compatibilityScore: 0,
          createdAt: DateTime.now(),
        );
        setState(() {});
      }
    }
  }

  void _initDemoMessages() {
    _messages.addAll([
      ChatMessage(
        id: 'msg_1',
        senderId: widget.matchId,
        text: 'Salut ! Super qu\'on ait matché ! 💪 Ça te dit qu\'on s\'entraîne ensemble ?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isFromMe: false,
      ),
      ChatMessage(
        id: 'msg_2',
        senderId: 'me',
        text: 'Oui avec plaisir ! Tu préfères quel type d\'entraînement ?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
        isFromMe: true,
      ),
      ChatMessage(
        id: 'msg_3',
        senderId: widget.matchId,
        text: 'Je suis plutôt musculation et HIIT. Et toi ? 🏋️',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        isFromMe: false,
      ),
      ChatMessage(
        id: 'msg_4',
        senderId: 'me',
        text: 'Parfait, moi aussi ! On pourrait faire une séance ensemble cette semaine ?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        isFromMe: true,
      ),
      ChatMessage(
        id: 'msg_5',
        senderId: widget.matchId,
        text: 'Oui ! Dis-moi quand tu es libre et on organise ça 🎯',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isFromMe: false,
      ),
    ]);
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final message = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      senderId: 'me',
      text: _textController.text.trim(),
      timestamp: DateTime.now(),
      isFromMe: true,
    );

    setState(() {
      _messages.add(message);
    });

    _textController.clear();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    // Simulation de réponse automatique
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final autoReplies = [
        'Super idée ! 💪',
        'Oui, on fait ça !',
        'Je suis partant(e) ! 🎯',
        'Parfait, dis-moi quand tu es libre',
        'Excellent ! On organise ça 🔥',
      ];
      final randomReply = autoReplies[DateTime.now().millisecond % autoReplies.length];
      
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'msg_auto_${DateTime.now().microsecondsSinceEpoch}',
            senderId: widget.matchId,
            text: randomReply,
            timestamp: DateTime.now(),
            isFromMe: false,
          ),
        );
      });
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _showProfileInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: _grisCharbon,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _matchProfile!.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_matchProfile!.name}, ${_matchProfile!.age} ans',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _texteClair,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _vertSauge.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_matchProfile!.compatibilityScore}% compatible',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _vertSauge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _InfoRow(icon: Icons.trending_up, label: 'Niveau', value: _matchProfile!.level),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.flag, label: 'Objectifs', value: _matchProfile!.goals.join(', ')),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.schedule, label: 'Disponibilité', value: _matchProfile!.availability),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.location_on, label: 'Distance', value: '${_matchProfile!.distance.toStringAsFixed(1)} km'),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.local_fire_department, label: 'Motivation', value: _matchProfile!.motivation),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_matchProfile == null) {
      return const Scaffold(
        backgroundColor: _grisCharbon,
        body: Center(child: CircularProgressIndicator(color: _vertSauge)),
      );
    }

    return Scaffold(
      backgroundColor: _grisCharbon,
      appBar: AppBar(
        backgroundColor: _grisCharbon,
        foregroundColor: _texteClair,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _matchProfile!.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _matchProfile!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _texteClair,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _vertSauge,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Buddy confirmé',
                        style: TextStyle(
                          fontSize: 12,
                          color: _texteSecondaire,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _grisCarte,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline, size: 20),
            ),
            onPressed: () => _showProfileInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _grisCarte,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.chat_bubble_outline, size: 40, color: _texteSecondaire),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Commence à discuter !',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _texteClair),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Organise tes séances d\'entraînement',
                          style: TextStyle(fontSize: 14, color: _texteSecondaire),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final showAvatar = index == 0 || 
                          (index > 0 && _messages[index - 1].isFromMe != message.isFromMe);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: message.isFromMe 
                              ? MainAxisAlignment.end 
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!message.isFromMe && showAvatar) ...[
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    _matchProfile!.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ] else if (!message.isFromMe) ...[
                              const SizedBox(width: 36),
                            ],
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: message.isFromMe ? _vertSauge : _grisCarte,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(message.isFromMe ? 16 : 4),
                                    bottomRight: Radius.circular(message.isFromMe ? 4 : 16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: message.isFromMe ? Colors.white : _texteClair,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(message.timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: message.isFromMe
                                            ? Colors.white.withOpacity(0.7)
                                            : _texteSecondaire,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (message.isFromMe && showAvatar) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _bleuArdoise,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'M',
                                    style: TextStyle(
                                      color: _texteClair,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (message.isFromMe) ...[
                              const SizedBox(width: 36),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _grisCarte,
              border: Border(top: BorderSide(color: _grisCarteClair.withOpacity(0.5))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Écris un message...',
                        hintStyle: const TextStyle(color: _texteSecondaire),
                        filled: true,
                        fillColor: _grisCarteClair,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: _texteClair),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_vertSauge, _vertOlive]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 22),
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

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
  });
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _texteSecondaire),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: _texteSecondaire),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _texteClair,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
