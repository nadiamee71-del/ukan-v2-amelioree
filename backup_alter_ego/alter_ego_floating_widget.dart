import 'package:flutter/material.dart';
import 'alter_ego_service.dart';
import 'chat_bubble_painter.dart';

/// Widget flottant pour l'Alter Ego (Bitmoji + bulle de texte)
/// Version simplifiée, stable et propre :
class AlterEgoFloatingWidget extends StatefulWidget {
  final bool showFloatingButton;
  
  const AlterEgoFloatingWidget({
    super.key,
    this.showFloatingButton = true, // Par défaut, afficher le bouton flottant partout
  });

  @override
  State<AlterEgoFloatingWidget> createState() =>
      _AlterEgoFloatingWidgetState();
}

class _AlterEgoFloatingWidgetState extends State<AlterEgoFloatingWidget>
    with SingleTickerProviderStateMixin {
  final AlterEgoService _service = AlterEgoService();
  final TextEditingController _chatController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();
  final ScrollController _chatScrollController = ScrollController();
  bool _showChatInterface = false;
  late AnimationController _speakingAnimationController;
  late Animation<double> _speakingAnimation;
  bool _selectedTabIsGuide = true; // true = Guide, false = FAQ & Support
  Set<String> _expandedFaqQuestions = {}; // Questions FAQ déployées

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
    
    // Animation pour le Bitmoji qui parle
    _speakingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _speakingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _speakingAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _speakingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _speakingAnimationController.dispose();
    _chatController.dispose();
    _chatFocusNode.dispose();
    _chatScrollController.dispose();
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _toggleChatInterface() {
    _service.toggleChatInterface();
  }

  void _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    _chatController.clear();
    
    // Basculer automatiquement vers l'onglet Guide quand on envoie un message
    if (!_selectedTabIsGuide) {
      setState(() {
        _selectedTabIsGuide = true;
      });
    }
    
    await _service.sendMessage(message);

    // Scroll automatique après l'envoi
    _scrollToBottom();

    // Vérifier si la conversation est terminée
    // Le service gère déjà la visibilité de l'interface
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Supprimer la conversation ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous vraiment supprimer toute la conversation ? Cette action est irréversible.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _service.endConversation();
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _onServiceChanged() {
    if (!mounted) return;
    
    // Synchroniser l'état local avec le service
    final newShowChatInterface = _service.showChatInterface;
    final shouldUpdate = _showChatInterface != newShowChatInterface;
    
    if (shouldUpdate) {
      setState(() {
        _showChatInterface = newShowChatInterface;
      });
      
      // Donner le focus au champ de texte après que le chat soit affiché
      if (_showChatInterface && _service.isChatActive) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _chatFocusNode.canRequestFocus) {
            _chatFocusNode.requestFocus();
          }
        });
      }
    }
    
    // Animer le Bitmoji quand il parle
    if (_service.isMessageVisible && _service.isChatActive) {
      if (!_speakingAnimationController.isAnimating) {
        _speakingAnimationController.repeat(reverse: true);
      }
    } else {
      if (_speakingAnimationController.isAnimating) {
        _speakingAnimationController.stop();
        _speakingAnimationController.reset();
      }
    }
    
    // Scroll automatique vers le bas quand un nouveau message arrive
    if (_service.conversationHistory.isNotEmpty) {
      _scrollToBottom();
    }
    
    // Mettre à jour l'UI si nécessaire (pour les changements de conversation)
    setState(() {});
  }

  /// Position de base de l'avatar pour chaque AlterEgoPosition
  Offset _computeAvatarOffset(
    AlterEgoPosition position,
    Size screenSize,
    Size avatarSize,
  ) {
    const double margin = 16.0;
    const double topOffset =
        80.0; // distance par rapport au haut de l'écran (sous la barre noire)
    const double bottomOffset = 96.0; // au-dessus de la bottom nav

    switch (position) {
      case AlterEgoPosition.topLeft:
        return const Offset(margin, topOffset);
      case AlterEgoPosition.topRight:
        return Offset(screenSize.width - margin - avatarSize.width, topOffset);
      case AlterEgoPosition.bottomLeft:
        return Offset(
          margin,
          screenSize.height - bottomOffset - avatarSize.height,
        );
      case AlterEgoPosition.bottomRight:
        return Offset(
          screenSize.width - margin - avatarSize.width,
          screenSize.height - bottomOffset - avatarSize.height,
        );
      case AlterEgoPosition.center:
        return Offset(
          (screenSize.width - avatarSize.width) / 2,
          (screenSize.height - avatarSize.height) / 2,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Toujours afficher le bouton, même si le Bitmoji n'est pas visible
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize =
            Size(constraints.maxWidth, constraints.maxHeight);
        const Size avatarSize = Size(96, 96);
        const double minPadding = 16.0;

        final Offset avatarOffset =
            _computeAvatarOffset(_service.currentPosition, screenSize, avatarSize);

        // ---- Calcul de la position de la bulle ----
        // Largeur "propre" de la bulle : ~45% de la largeur de l'écran
        final double bubbleWidth =
            (screenSize.width * 0.45).clamp(260.0, 380.0).toDouble();

        double bubbleLeft;
        double bubbleTop;

        final bool avatarOnRight =
            _service.currentPosition == AlterEgoPosition.topRight ||
                _service.currentPosition == AlterEgoPosition.bottomRight;

        final bool avatarOnLeft =
            _service.currentPosition == AlterEgoPosition.topLeft ||
                _service.currentPosition == AlterEgoPosition.bottomLeft;

        // Position verticale : bulle juste en dessous de l'avatar
        bubbleTop = avatarOffset.dy + avatarSize.height + 12;
        // Sécurité pour ne pas coller trop en haut
        if (bubbleTop < minPadding + 40) {
          bubbleTop = minPadding + 40;
        }

        // Centrer la bulle exactement sous le Bitmoji
        final double avatarCenterX = avatarOffset.dx + avatarSize.width / 2;
        
        // Largeur cible de la bulle (même logique que plus bas)
        final double bubbleTargetWidth =
            (screenSize.width * 0.65).clamp(200.0, 280.0).toDouble();

        // On centre la bulle exactement sous le Bitmoji
        double centeredLeft = avatarCenterX - bubbleTargetWidth / 2;

        // Sécurité : ne jamais coller les bords
        if (centeredLeft < minPadding) {
          centeredLeft = minPadding;
        }
        if (centeredLeft + bubbleTargetWidth >
            screenSize.width - minPadding) {
          centeredLeft = screenSize.width - minPadding - bubbleTargetWidth;
        }

        bubbleLeft = centeredLeft;

        final String message = _service.currentMessage;

        return Stack(
          children: [
            // ==== INTERFACE DE CHAT UNIFIÉE (avec Bitmoji intégré) ====
            // Afficher l'interface si le chat est actif et visible (contrôlé par le service)
            if (_service.showChatInterface && _service.isChatActive)
              _buildUnifiedChatInterface(screenSize),

            // ==== BOUTON FLOTTANT POUR OUVRIR LE CHAT ====
            // Afficher uniquement si showFloatingButton est true
            if (widget.showFloatingButton)
            _buildChatButton(screenSize),
          ],
        );
      },
    );
  }

  Widget _buildUnifiedChatInterface(Size screenSize) {
    // Interface de chat unifiée avec Bitmoji flottant
    final double chatWidth = (screenSize.width * 0.92).clamp(350.0, 500.0).toDouble();
    final double chatHeight = (screenSize.height * 0.75).clamp(550.0, 750.0).toDouble();
    final double chatLeft = (screenSize.width - chatWidth) / 2;
    final double chatTop = (screenSize.height - chatHeight) / 2;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: chatLeft,
      top: chatTop,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: chatWidth,
          height: chatHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFC300),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: 8,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Zone de conversation (pleine largeur)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    // En-tête du chat
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFC300).withOpacity(0.3),
                            const Color(0xFFFFC300).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(21),
                          topRight: Radius.circular(21),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '💬 Chat avec ton Alter Ego',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // Bouton corbeille pour supprimer la conversation
                          if (_service.conversationHistory.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 22),
                              onPressed: _clearConversation,
                              tooltip: 'Supprimer la conversation',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            onPressed: () {
                              _service.hideChatInterface();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                  // Barre d'onglets : Guide / FAQ & Support
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Onglet "Guide"
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTabIsGuide = true;
                              });
                            },
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTabIsGuide
                                    ? const Color(0xFFF5D547) // JAUNE
                                    : const Color(0xFFE7E7E7), // GRIS CLAIR
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Guide',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: _selectedTabIsGuide
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Onglet "FAQ & Support"
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTabIsGuide = false;
                              });
                            },
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_selectedTabIsGuide
                                    ? const Color(0xFFF5D547) // JAUNE
                                    : const Color(0xFFE7E7E7), // GRIS CLAIR
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                'FAQ & Support',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: !_selectedTabIsGuide
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenu selon l'onglet sélectionné
                  Expanded(
                    child: _selectedTabIsGuide
                        ? _buildGuideContent()
                        : _buildFaqSupportContent(),
                  ),

                  // Boutons d'avis sur le chatbot
                  if (_service.conversationHistory.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0B1E),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Avis sur le chatbot :',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildFeedbackButton(Icons.sentiment_very_satisfied, 'Content', Colors.green),
                          const SizedBox(width: 8),
                          _buildFeedbackButton(Icons.sentiment_neutral, 'Neutre', Colors.grey),
                          const SizedBox(width: 8),
                          _buildFeedbackButton(Icons.sentiment_very_dissatisfied, 'Mécontent', Colors.red),
                        ],
                      ),
                    ),

                  // Indicateur "En train d'écrire..." juste au-dessus du champ de saisie
                  if (_service.isMessageVisible && _service.isChatActive)
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC300).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFC300).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'En train d\'écrire...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Champ de saisie
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0B1E),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(21),
                        bottomRight: Radius.circular(21),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            focusNode: _chatFocusNode,
                            enabled: true,
                            readOnly: false,
                            autofocus: false,
                            enableInteractiveSelection: true,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.send,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Tape ton message...',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: const Color(0xFF1A1A2E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: const Color(0xFFFFC300).withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            onTap: () {
                              // S'assurer que le TextField a le focus quand on clique dessus
                              _chatFocusNode.requestFocus();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC300),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFC300).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.black, size: 22),
                            onPressed: _sendMessage,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Bitmoji flottant à droite (overlay) - Ignorer les touches pour ne pas bloquer le TextField
              Positioned(
                right: 20,
                top: 80,
                bottom: 120,
                child: IgnorePointer(
                  ignoring: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    // Bitmoji flottant (grand et statique, animé par changement de pose)
                    AnimatedBuilder(
                      animation: _speakingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _service.isMessageVisible && _service.isChatActive
                              ? _speakingAnimation.value
                              : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: _service.isMessageVisible && _service.isChatActive
                                      ? const Color(0xFFFFC300).withOpacity(0.5)
                                      : Colors.transparent,
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AlterEgoService.getImagePath(_service.currentPose),
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 120,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeBitmoji(double size) {
    return AnimatedBuilder(
      animation: _speakingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _service.isMessageVisible && _service.isChatActive
              ? _speakingAnimation.value
              : 1.0,
          child: Image.asset(
            AlterEgoService.getImagePath(_service.currentPose),
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                color: Colors.white,
                size: size * 0.7,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeedbackButton(IconData icon, String label, Color color) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Merci pour votre avis : $label 👍'),
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xFF1A1A2E),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// Contenu de l'onglet "Guide"
  Widget _buildGuideContent() {
    // Si il y a des messages dans l'historique, afficher l'historique de conversation
    if (_service.conversationHistory.isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 200; // Moins l'espace du Bitmoji
          final double maxMessageWidth = (availableWidth * 0.75).clamp(200.0, 400.0).toDouble();
          
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 200, 16), // Padding droit pour le Bitmoji
            child: ListView.builder(
              controller: _chatScrollController,
              reverse: false,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _service.conversationHistory.length,
              itemBuilder: (context, index) {
                final chatMessage = _service.conversationHistory[index];
                return _buildChatMessage(chatMessage, maxMessageWidth);
              },
            ),
          );
        },
      );
    }
    
    // Sinon, afficher le contenu statique du guide
    return SingleChildScrollView(
      controller: _chatScrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenue dans le Guide FitPro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bienvenue dans le Guide FitPro. Je t\'explique la page où tu te trouves.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Le guide s\'adapte automatiquement à la page sur laquelle tu te trouves pour te donner des conseils et des explications contextuelles.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Contenu de l'onglet "FAQ & Support"
  Widget _buildFaqSupportContent() {
    return Container(
      color: const Color(0xFF1A1A2E), // Fond opaque pour éviter la transparence
      child: SingleChildScrollView(
        controller: _chatScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FAQ & Support FitPro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trouve rapidement des réponses à tes questions.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Catégorie : Compte & Connexion
          _buildFaqCategoryInChat(
            title: 'Compte & Connexion',
            questions: [
              _FaqItem('Je n\'arrive plus à me connecter', 'Vérifiez que votre email et mot de passe sont corrects. Si le problème persiste, utilisez la fonction "Mot de passe oublié" ou contactez le support.'),
              _FaqItem('Je veux supprimer mon compte', 'Pour supprimer votre compte, allez dans Paramètres > Mon profil > Supprimer mon compte. Cette action est irréversible.'),
              _FaqItem('Je veux changer mon email', 'Allez dans Paramètres > Mon profil > Modifier l\'email. Vous recevrez un email de confirmation sur votre nouvelle adresse.'),
              _FaqItem('J\'ai un problème avec mon mot de passe', 'Utilisez la fonction "Mot de passe oublié" sur l\'écran de connexion. Vous recevrez un lien par email pour réinitialiser votre mot de passe.'),
            ],
          ),
          const SizedBox(height: 16),
          // Catégorie : Paiements & Abonnement
          _buildFaqCategoryInChat(
            title: 'Paiements & Abonnement',
            questions: [
              _FaqItem('Comment fonctionne l\'abonnement Premium ?', 'L\'abonnement Premium vous donne accès à toutes les fonctionnalités avancées : Coach IA, séances en visio, statistiques détaillées, etc. Il se renouvelle automatiquement chaque mois.'),
              _FaqItem('Je vois un paiement que je ne comprends pas', 'Vérifiez vos achats dans Mon Espace Avancé > Mes achats. Si vous avez des questions, contactez le support avec le numéro de transaction.'),
              _FaqItem('Comment changer ma carte bancaire ?', 'Allez dans Mon Espace Avancé > Abonnements & Achats > Gérer l\'abonnement. Vous pourrez modifier votre moyen de paiement.'),
              _FaqItem('Comment annuler mon abonnement ?', 'Allez dans Mon Espace Avancé > Abonnements & Achats > Gérer l\'abonnement > Annuler l\'abonnement. L\'annulation prend effet à la fin de la période payée.'),
            ],
          ),
          const SizedBox(height: 16),
          // Catégorie : Coachs & Séances
          _buildFaqCategoryInChat(
            title: 'Coachs & Séances en Visio',
            questions: [
              _FaqItem('Comment réserver une séance avec un coach ?', 'Allez dans l\'onglet Coachs, choisissez un coach et sélectionnez "Réserver une séance". Choisissez la date et l\'heure qui vous conviennent.'),
              _FaqItem('Comment annuler une séance ?', 'Allez dans Mes séances, sélectionnez la séance à annuler et cliquez sur "Annuler". Vous pouvez annuler jusqu\'à 24h avant la séance.'),
              _FaqItem('Comment rejoindre une séance en visio ?', 'Quelques minutes avant votre séance, vous recevrez un lien par email. Cliquez sur ce lien pour rejoindre la séance en visio.'),
            ],
          ),
          const SizedBox(height: 16),
          // Catégorie : Nutrition
          _buildFaqCategoryInChat(
            title: 'Nutrition & Recettes',
            questions: [
              _FaqItem('Comment ajouter un repas ?', 'Allez dans l\'onglet Nutrition, cliquez sur le bouton "+" et remplissez les informations du repas (nom, calories, protéines, etc.).'),
              _FaqItem('Comment ajouter une recette ?', 'Allez dans Recettes & Communauté, cliquez sur "Ajouter une recette" et suivez les étapes pour ajouter votre recette avec photo/vidéo.'),
              _FaqItem('Comment enregistrer les calories ?', 'Les calories sont automatiquement enregistrées lorsque vous ajoutez un repas. Vous pouvez voir le total du jour dans l\'onglet Nutrition.'),
            ],
          ),
          const SizedBox(height: 16),
          // Catégorie : Santé & Blessures
          _buildFaqCategoryInChat(
            title: 'Santé & Blessures',
            questions: [
              _FaqItem('Où ajouter mon groupe sanguin ?', 'Allez dans Santé & Blessures > Informations médicales, vous pourrez ajouter votre groupe sanguin et autres informations importantes.'),
              _FaqItem('Comment enregistrer une blessure ?', 'Allez dans Santé & Blessures > Blessures, cliquez sur "Ajouter une blessure" et remplissez les informations (type, date, localisation, etc.).'),
              _FaqItem('Comment ajouter une ordonnance ou un document médical ?', 'Dans Santé & Blessures > Documents médicaux, cliquez sur "Ajouter un document" et sélectionnez une photo de votre ordonnance ou document.'),
            ],
          ),
          const SizedBox(height: 16),
          // Catégorie : Rooms & Entraînements
          _buildFaqCategoryInChat(
            title: 'Rooms & Entraînements',
            questions: [
              _FaqItem('Comment créer une room d\'entraînement ?', 'Allez dans S\'entraîner avec ses amis, cliquez sur "Créer une room" et invitez vos amis avec le code de la room.'),
              _FaqItem('Comment rejoindre une room ?', 'Demandez le code de la room à votre ami, puis allez dans S\'entraîner avec ses amis > Rejoindre une room et entrez le code.'),
              _FaqItem('Comment mettre en pause une séance ?', 'Pendant une séance, cliquez sur le bouton "Pause" en bas de l\'écran. Vous pourrez reprendre quand vous le souhaitez.'),
            ],
          ),
          const SizedBox(height: 16),
          // Catégorie : Alter Ego & IA
          _buildFaqCategoryInChat(
            title: 'Alter Ego & IA',
            questions: [
              _FaqItem('Qu\'est-ce que l\'Alter Ego ?', 'L\'Alter Ego est votre coach virtuel intelligent. Il vous guide dans chaque page, répond à vos questions et vous motive dans votre parcours fitness.'),
              _FaqItem('Comment utiliser l\'Alter Ego ?', 'Cliquez sur l\'icône flottante de l\'Alter Ego présente sur toutes les pages. Vous pouvez lui poser des questions ou le laisser vous guider automatiquement.'),
              _FaqItem('L\'Alter Ego est-il disponible partout ?', 'Oui, l\'Alter Ego est disponible sur toutes les pages de l\'application. Il s\'adapte automatiquement au contexte de la page où vous vous trouvez.'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: const Color(0xFFFFC300), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Besoin d\'aide supplémentaire ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Pour accéder au formulaire de contact complet, va dans Mon Espace Avancé > FAQ & Support.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Widget pour afficher une catégorie FAQ dans le chat
  Widget _buildFaqCategoryInChat({
    required String title,
    required List<_FaqItem> questions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFC300).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la catégorie
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Questions
          ...questions.map((faq) => _buildFaqQuestionInChat(faq)),
        ],
      ),
    );
  }

  /// Widget pour afficher une question FAQ cliquable dans le chat avec réponse déployable
  Widget _buildFaqQuestionInChat(_FaqItem faq) {
    final isExpanded = _expandedFaqQuestions.contains(faq.question);
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedFaqQuestions.remove(faq.question);
          } else {
            _expandedFaqQuestions.add(faq.question);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFFFFC300).withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question (toujours visible)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: const Color(0xFFFFC300),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Réponse (déployable avec animation)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                padding: const EdgeInsets.fromLTRB(46, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFC300).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    faq.answer,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message, double maxWidth) {
    if (message.isUser) {
      // Message de l'utilisateur à droite (jaune)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC300),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
      );
    } else {
      // Message du chatbot à gauche (Bitmoji flottant à droite)
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, right: 40),
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image contextuelle si disponible
              if (message.imageAsset != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      message.imageAsset!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Si l'image n'existe pas, ne rien afficher
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              // Bulle de texte
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3E),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFFC300).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMessageBubble(String message, {required bool pointDown}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(message),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: CustomPaint(
          painter: ChatBubblePainter(
            backgroundColor: const Color(0xFF0B1020),
            borderColor: const Color(0xFFFFC300),
            borderWidth: 2,
            pointDown: pointDown,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              softWrap: true,
              maxLines: null,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Size avatarSize) {
    // Permettre de cliquer sur le Bitmoji pour ouvrir le chat aussi
    return GestureDetector(
      onTap: () {
        if (!_service.isChatActive) {
          _service.startConversation();
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted && _chatFocusNode.canRequestFocus) {
              _chatFocusNode.requestFocus();
            }
          });
        } else {
          _service.toggleChatInterface();
        }
      },
      child: AnimatedBuilder(
        animation: _speakingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _service.isMessageVisible && _service.isChatActive
                ? _speakingAnimation.value
                : 1.0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey(_service.currentPose),
                width: avatarSize.width,
                height: avatarSize.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black, // fond noir
                  border: Border.all(
                    color: _service.isMessageVisible && _service.isChatActive
                        ? const Color(0xFFFFC300)
                        : const Color(0xFFFFC300).withOpacity(0.7),
                    width: _service.isMessageVisible && _service.isChatActive
                        ? 4
                        : 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _service.isMessageVisible && _service.isChatActive
                          ? const Color(0xFFFFC300).withOpacity(0.5)
                          : Colors.black.withOpacity(0.35),
                      blurRadius: _service.isMessageVisible && _service.isChatActive
                          ? 25
                          : 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    AlterEgoService.getImagePath(_service.currentPose),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatButton(Size screenSize) {
    // Toujours afficher le bouton, le cacher seulement quand le chat est ouvert
    // Positionné en haut à droite
    return Positioned(
      top: 80,
      right: 16,
      child: AnimatedOpacity(
        opacity: _service.showChatInterface && _service.isChatActive ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: _service.showChatInterface && _service.isChatActive,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC300).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (!_service.isChatActive) {
                    _service.startConversation();
                  } else {
                    _service.toggleChatInterface();
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _service.isChatActive ? Icons.chat : Icons.chat_bubble_outline,
                        color: Colors.black,
                        size: 32,
                      ),
                      if (_service.isChatActive && !_service.showChatInterface)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red,
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Classe pour une question/réponse FAQ
class _FaqItem {
  final String question;
  final String answer;
  _FaqItem(this.question, this.answer);
}
