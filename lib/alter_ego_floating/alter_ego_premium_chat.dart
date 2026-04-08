import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'alter_ego_service.dart';

/// Fenêtre de chat premium draggable avec design glassmorphism
/// Inclut l'avatar Alter Ego animé à droite (comme l'ancienne version)
class AlterEgoPremiumChat extends StatefulWidget {
  final VoidCallback onClose;
  final Size screenSize;
  
  const AlterEgoPremiumChat({
    super.key,
    required this.onClose,
    required this.screenSize,
  });

  @override
  State<AlterEgoPremiumChat> createState() => _AlterEgoPremiumChatState();
}

class _AlterEgoPremiumChatState extends State<AlterEgoPremiumChat>
    with TickerProviderStateMixin {
  final AlterEgoService _service = AlterEgoService();
  final TextEditingController _chatController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  // Position de la fenêtre (draggable)
  late Offset _position;
  bool _isDragging = false;
  
  // Onglet sélectionné
  bool _isGuideTab = true;
  
  // FAQ expandées
  final Set<String> _expandedFaq = {};
  
  // Animations
  late AnimationController _openController;
  late AnimationController _typingController;
  late AnimationController _avatarController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _avatarPulseAnimation;
  
  // Taille de la fenêtre
  late double _chatWidth;
  late double _chatHeight;

  @override
  void initState() {
    super.initState();
    
    // Calculer la taille
    _chatWidth = (widget.screenSize.width * 0.92).clamp(340.0, 500.0);
    _chatHeight = (widget.screenSize.height * 0.75).clamp(520.0, 700.0);
    
    // Position initiale (centrée)
    _position = Offset(
      (widget.screenSize.width - _chatWidth) / 2,
      (widget.screenSize.height - _chatHeight) / 2,
    );
    
    // Animation d'ouverture
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _openController, curve: Curves.easeOutBack),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _openController, curve: Curves.easeOut),
    );
    
    // Animation typing
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    // Animation avatar (pulsation)
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _avatarPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );
    
    _openController.forward();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _openController.dispose();
    _typingController.dispose();
    _avatarController.dispose();
    _chatController.dispose();
    _chatFocusNode.dispose();
    _scrollController.dispose();
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
  
  void _onServiceChanged() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  
  void _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;
    
    _chatController.clear();
    
    if (!_isGuideTab) {
      setState(() => _isGuideTab = true);
    }
    
    await _service.sendMessage(message);
    _scrollToBottom();
  }
  
  void _onDragStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }
  
  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _position = Offset(
        _position.dx.clamp(0, widget.screenSize.width - _chatWidth),
        _position.dy.clamp(0, widget.screenSize.height - _chatHeight),
      );
    });
  }
  
  void _onDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _openController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                // Fond semi-transparent
                Positioned.fill(
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(color: Colors.black.withOpacity(0.4)),
                  ),
                ),
                
                // Fenêtre draggable
                Positioned(
                  left: _position.dx,
                  top: _position.dy,
                  child: _buildChatWindow(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildChatWindow() {
    return GestureDetector(
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: _chatWidth,
            height: _chatHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.95),
                  const Color(0xFF0D1117).withOpacity(0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC300).withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                _buildTabs(),
                Expanded(
                  child: Stack(
                    children: [
                      // Contenu principal (chat uniquement)
                      Positioned.fill(
                        child: _buildGuideContent(),
                      ),
                      // Avatar Alter Ego animé à droite
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: _buildAnimatedAvatar(),
                      ),
                    ],
                  ),
                ),
                if (_service.conversationHistory.isNotEmpty) _buildFeedbackBar(),
                if (_service.isMessageVisible) _buildTypingIndicator(),
                _buildInputField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Avatar Alter Ego animé (figurine complète avec halo)
  /// S'anime à chaque changement de pose
  Widget _buildAnimatedAvatar() {
    return AnimatedBuilder(
      animation: _avatarController,
      builder: (context, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Transform.scale(
            key: ValueKey(_service.currentPose),
            scale: _avatarPulseAnimation.value,
            child: Container(
              width: 140,
              height: 160,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC300).withOpacity(
                      _service.isMessageVisible ? 0.6 : 0.3,
                    ),
                    blurRadius: _service.isMessageVisible ? 40 : 25,
                    spreadRadius: _service.isMessageVisible ? 15 : 8,
                  ),
                ],
              ),
              child: Image.asset(
                AlterEgoService.getImagePath(_service.currentPose),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: Color(0xFFFFC300),
                  size: 80,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC300).withOpacity(0.25),
            const Color(0xFFFFC300).withOpacity(0.08),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          // Icône chat
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chat_bubble, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 12),
          
          // Titre
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat avec ton Alter Ego',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          // Poignée de drag
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.drag_indicator, color: Colors.white.withOpacity(0.5), size: 16),
          ),
          const SizedBox(width: 8),
          
          // Bouton supprimer conversation
          GestureDetector(
            onTap: () => _service.endConversation(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: Colors.white.withOpacity(0.7), size: 18),
            ),
          ),
          const SizedBox(width: 8),
          
          // Bouton fermer
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabs() {
    // Plus d'onglets - juste le chat conversationnel
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: const Color(0xFFFFC300), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pose-moi n\'importe quelle question !',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuideContent() {
    if (_service.conversationHistory.isEmpty) {
      return _buildWelcomeMessage();
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(left: 16, right: 160, top: 16, bottom: 16), // Espace pour l'avatar
      itemCount: _service.conversationHistory.length,
      itemBuilder: (context, index) {
        final message = _service.conversationHistory[index];
        return _buildMessageBubble(message, index);
      },
    );
  }
  
  Widget _buildWelcomeMessage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 160, top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message de bienvenue
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF21262D),
                  const Color(0xFF21262D).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Salut ! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Je suis ton guide Ukan. Pose-moi n\'importe quelle question sur l\'app !',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Suggestions rapides (exemples de questions)
          Text(
            'Exemples de questions :',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSuggestionChip('Comment ajouter un exercice ?'),
              _buildSuggestionChip('C\'est quoi Premium ?'),
              _buildSuggestionChip('Comment scanner un aliment ?'),
              _buildSuggestionChip('Comment trouver un buddy ?'),
              _buildSuggestionChip('Où voir mes stats ?'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _chatController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFC300).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.4)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFFFC300),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isUser;
    final isLast = index == _service.conversationHistory.length - 1;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isUser
                  ? const LinearGradient(colors: [Color(0xFFFFC300), Color(0xFFFFD54F)])
                  : LinearGradient(colors: [const Color(0xFF21262D), const Color(0xFF21262D).withOpacity(0.9)]),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: isUser ? null : Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
            ),
            constraints: BoxConstraints(maxWidth: _chatWidth * 0.6),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.black : Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: isLast ? const Color(0xFFFFC300) : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
            ),
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value = ((_typingController.value + delay) % 1.0);
                    final bounce = math.sin(value * math.pi);
                    
                    return Container(
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      child: Transform.translate(
                        offset: Offset(0, -bounce * 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC300).withOpacity(0.6 + bounce * 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'En train d\'écrire...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Avis sur le chatbot :', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const SizedBox(width: 10),
          _buildFeedbackBtn(Icons.sentiment_satisfied_alt, Colors.green),
          const SizedBox(width: 6),
          _buildFeedbackBtn(Icons.sentiment_neutral, Colors.grey),
          const SizedBox(width: 6),
          _buildFeedbackBtn(Icons.sentiment_dissatisfied, Colors.red),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackBtn(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merci pour ton avis ! 👍'), duration: Duration(seconds: 2)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
  
  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.2)),
              ),
              child: TextField(
                controller: _chatController,
                focusNode: _chatFocusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tape ton message...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFC300), Color(0xFFFFD54F)]),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFFC300).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFaqContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 160, top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFaqCategory('🏋️ Exercices', [
            _FaqItem('Comment ajouter un exercice ?', 'Va dans Séances > Bibliothèque > bouton +'),
            _FaqItem('Comment démarrer une séance ?', 'Clique sur une séance et appuie sur Démarrer'),
          ]),
          const SizedBox(height: 12),
          _buildFaqCategory('🥗 Nutrition', [
            _FaqItem('Comment scanner un aliment ?', 'Nutrition > FoodScan IA > Prendre une photo'),
            _FaqItem('Comment ajouter un repas ?', 'Nutrition > Repas & Courses > bouton +'),
          ]),
          const SizedBox(height: 12),
          _buildFaqCategory('👥 Social', [
            _FaqItem('Comment trouver un buddy ?', 'Va dans Chat Match ou Buddy Workout'),
            _FaqItem('Comment créer une room ?', 'S\'entraîner avec des amis > Créer une Room'),
          ]),
          const SizedBox(height: 12),
          _buildFaqCategory('💳 Compte', [
            _FaqItem('C\'est quoi Premium ?', 'Accès à toutes les fonctionnalités avancées'),
            _FaqItem('Comment modifier mon profil ?', 'Clique sur ton avatar > Modifier'),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildFaqCategory(String title, List<_FaqItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [const Color(0xFFFFC300).withOpacity(0.2), const Color(0xFFFFC300).withOpacity(0.05)]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
            ),
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          ...items.map((item) => _buildFaqQuestion(item)),
        ],
      ),
    );
  }
  
  Widget _buildFaqQuestion(_FaqItem item) {
    final isExpanded = _expandedFaq.contains(item.question);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedFaq.remove(item.question);
          } else {
            _expandedFaq.add(item.question);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.help_outline, color: Color(0xFFFFC300), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.question, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, color: Colors.white.withOpacity(0.5), size: 18),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(36, 0, 12, 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.answer, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, height: 1.4)),
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  _FaqItem(this.question, this.answer);
}
