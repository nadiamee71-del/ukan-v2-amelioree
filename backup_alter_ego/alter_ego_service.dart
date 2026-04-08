import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'alter_ego_context_service.dart';

/// Énumération pour définir les positions possibles du Bitmoji
enum AlterEgoPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

/// Énumération pour les poses de l'Alter Ego
enum AlterEgoPose {
  neutre,
  salut,
  felicite,
  encourage,
  reflechit,
  alerte,
  repose,
  applaudit,
  clindoeil,
}

/// Service global pour gérer l'état de l'Alter Ego flottant
/// Singleton pattern avec ChangeNotifier
class AlterEgoService extends ChangeNotifier {
  static final AlterEgoService _instance = AlterEgoService._internal();
  factory AlterEgoService() => _instance;
  AlterEgoService._internal() {
    _initTts();
  }

  // TTS instance
  final FlutterTts _tts = FlutterTts();
  bool _ttsInitialized = false;

  // État de l'Alter Ego
  AlterEgoPose _currentPose = AlterEgoPose.neutre;
  String _currentMessage = '';
  AlterEgoPosition _currentPosition = AlterEgoPosition.bottomRight;
  bool _isVisible = false; // Désactivé par défaut pour éviter les erreurs au démarrage
  bool _isMessageVisible = false;
  
  // État du chatbot
  bool _isChatActive = false;
  List<ChatMessage> _conversationHistory = [];
  bool _showChatInterface = false;
  
  // Service de contexte
  final AlterEgoContextService _contextService = AlterEgoContextService();
  
  // Image contextuelle actuelle
  String? _currentContextImage;
  
  // Pattern de réponses du chatbot (mode démo)
  static final Map<String, ChatResponse> _responsePatterns = {
    // Salutations
    'salut': ChatResponse(
      'Salut ! Comment puis-je t\'aider aujourd\'hui ? 💪',
      AlterEgoPose.salut,
    ),
    'bonjour': ChatResponse(
      'Bonjour ! Je suis là pour t\'accompagner dans tes objectifs fitness ! 🎯',
      AlterEgoPose.salut,
    ),
    'bonsoir': ChatResponse(
      'Bonsoir ! J\'espère que ta journée s\'est bien passée ! 🌙',
      AlterEgoPose.repose,
    ),
    'coucou': ChatResponse(
      'Coucou ! Prêt à te dépasser aujourd\'hui ? 💪',
      AlterEgoPose.clindoeil,
    ),
    // Questions sur les objectifs
    'objectif': ChatResponse(
      'Tes objectifs sont importants ! Veux-tu que je t\'aide à les définir ou à les atteindre ? 🎯',
      AlterEgoPose.reflechit,
    ),
    'perdre du poids': ChatResponse(
      'Super objectif ! Je peux t\'aider avec des programmes de nutrition et d\'exercices adaptés. On y va ? 💪',
      AlterEgoPose.encourage,
    ),
    'prendre du muscle': ChatResponse(
      'Excellente décision ! La musculation avec une bonne nutrition, c\'est la clé. Je peux te guider ! 🏋️',
      AlterEgoPose.felicite,
    ),
    'forme': ChatResponse(
      'Rester en forme, c\'est un mode de vie ! Je suis là pour te motiver chaque jour. Tu commences par quoi ? 💪',
      AlterEgoPose.encourage,
    ),
    // Motivation
    'motivation': ChatResponse(
      'La motivation vient de l\'action ! Chaque petit pas compte. Tu es plus fort que tu ne le penses ! 💪✨',
      AlterEgoPose.encourage,
    ),
    'motiver': ChatResponse(
      'Rappelle-toi pourquoi tu as commencé ! Tu as déjà fait le plus dur : commencer. Continue ! 💪',
      AlterEgoPose.applaudit,
    ),
    'difficile': ChatResponse(
      'Je comprends, ce n\'est pas facile. Mais chaque jour tu deviens plus fort. Ne lâche pas ! 💪',
      AlterEgoPose.encourage,
    ),
    // Nutrition
    'nutrition': ChatResponse(
      'La nutrition, c\'est 70% du succès ! Veux-tu que je t\'aide avec ton alimentation ? 🥗',
      AlterEgoPose.reflechit,
    ),
    'manger': ChatResponse(
      'Manger équilibré est essentiel ! Je peux te donner des conseils adaptés à tes objectifs. Intéressé ? 🍎',
      AlterEgoPose.reflechit,
    ),
    // Exercices
    'exercice': ChatResponse(
      'Les exercices sont la base ! Que veux-tu travailler aujourd\'hui ? 🏋️',
      AlterEgoPose.salut,
    ),
    'entraînement': ChatResponse(
      'Super ! Un bon entraînement régulier fait la différence. Prêt à commencer ? 💪',
      AlterEgoPose.encourage,
    ),
    'programme': ChatResponse(
      'Les programmes structurés accélèrent les résultats ! Je peux te recommander quelque chose d\'adapté. 🎯',
      AlterEgoPose.reflechit,
    ),
    // Félicitations
    'merci': ChatResponse(
      'De rien ! Je suis toujours là pour t\'aider. Continue comme ça ! 💪✨',
      AlterEgoPose.felicite,
    ),
    'réussi': ChatResponse(
      'Bravo ! Tu es incroyable ! Chaque réussite te rapproche de tes objectifs. Continue ! 🎉',
      AlterEgoPose.applaudit,
    ),
    // Fin de conversation
    'au revoir': ChatResponse(
      'À bientôt ! N\'oublie pas : chaque jour compte ! 💪',
      AlterEgoPose.salut,
    ),
    'bye': ChatResponse(
      'Bye ! Reviens quand tu veux, je suis toujours là ! 👋',
      AlterEgoPose.salut,
    ),
    'fin': ChatResponse(
      'D\'accord ! N\'hésite pas si tu as besoin de moi. Bon courage ! 💪',
      AlterEgoPose.neutre,
    ),
  };

  // Getters
  AlterEgoPose get currentPose => _currentPose;
  String get currentMessage => _currentMessage;
  AlterEgoPosition get currentPosition => _currentPosition;
  bool get isVisible => _isVisible;
  bool get isMessageVisible => _isMessageVisible;
  bool get isChatActive => _isChatActive;
  bool get showChatInterface => _showChatInterface;
  List<ChatMessage> get conversationHistory => List.unmodifiable(_conversationHistory);
  String? get currentContextImage => _currentContextImage;
  
  /// Définit la page actuelle pour le contexte
  void setCurrentPage(FitProPage? page) {
    _contextService.setCurrentPage(page);
    _updateContextImage();
  }
  
  /// Démarre une conversation avec le message guide de la page actuelle
  /// Cette méthode est appelée automatiquement quand on change de page
  void startConversationWithGuideMessage() {
    // Si le chat est déjà actif, on ne fait rien (pour ne pas interrompre l'utilisateur)
    if (_isChatActive) {
      return;
    }
    
    // Sinon, on démarre la conversation avec le message guide
    startConversation();
  }
  
  /// Met à jour l'image contextuelle
  void _updateContextImage() {
    _currentContextImage = _contextService.getCurrentImage();
    notifyListeners();
  }
  
  // Couleurs pour la bulle iMessage
  Color get backgroundColor => const Color(0xFF0B1020); // Fond de la bulle
  Color get textColor => Colors.white; // Couleur du texte

  /// Retourne le chemin de l'image pour une pose donnée
  static String getImagePath(AlterEgoPose pose) {
    return 'assets/images/alter_ego_${pose.name}.png';
  }

  /// Initialise le TTS
  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(0.8);
      _ttsInitialized = true;
    } catch (e) {
      debugPrint('Erreur initialisation TTS: $e');
      // Continuer même si TTS échoue
      _ttsInitialized = false;
    }
  }

  /// Met à jour la pose de l'Alter Ego
  void setPose(AlterEgoPose pose) {
    if (_currentPose != pose) {
      _currentPose = pose;
      notifyListeners();
    }
  }

  /// Affiche un message et le lit avec TTS
  Future<void> showMessage(String message, {AlterEgoPose? pose}) async {
    if (pose != null) {
      setPose(pose);
    }
    _currentMessage = message;
    _isMessageVisible = true;
    notifyListeners();

    // Lire le message avec TTS
    if (_ttsInitialized && message.isNotEmpty) {
      try {
        await _tts.stop(); // Arrêter tout message en cours
        await _tts.speak(message);
      } catch (e) {
        debugPrint('Erreur TTS: $e');
        // Continuer même si TTS échoue
      }
    }
  }

  /// Masque le message (mais garde le Bitmoji visible)
  void hideMessage() {
    if (_isMessageVisible) {
      _isMessageVisible = false;
      _currentMessage = '';
      notifyListeners();
    }
  }

  /// Change la position de l'Alter Ego
  void setPosition(AlterEgoPosition position) {
    if (_currentPosition != position) {
      _currentPosition = position;
      notifyListeners();
    }
  }

  /// Affiche ou masque complètement l'Alter Ego
  void setVisible(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      if (!visible) {
        _isMessageVisible = false;
        _currentMessage = '';
      }
      notifyListeners();
    }
  }

  /// Méthode de commodité pour déplacer l'Alter Ego vers une position avec un message
  Future<void> moveToPosition(
    AlterEgoPosition position, {
    String? message,
    AlterEgoPose? pose,
  }) async {
    setPosition(position);
    if (message != null) {
      await showMessage(message, pose: pose);
    }
  }

  /// Démarre une conversation (affiche le Bitmoji dans le chat)
  void startConversation() {
    if (!_isChatActive) {
      _isChatActive = true;
      _showChatInterface = true;
      _conversationHistory.clear();
      setVisible(true);
      setPose(AlterEgoPose.salut);
      
      // Notifier immédiatement pour afficher l'interface rapidement
      notifyListeners();
      
      // Afficher le message GUIDE si disponible (après le premier notifyListeners pour réactivité)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final guideMessage = _contextService.getGuideMessage();
        if (guideMessage != null) {
          _conversationHistory.add(ChatMessage(
            text: guideMessage,
            isUser: false,
            timestamp: DateTime.now(),
            intent: AlterEgoIntent.system,
            imageAsset: _contextService.getContextImage(),
          ));
        } else {
          // Message par défaut
          _conversationHistory.add(ChatMessage(
            text: 'Salut ! Je suis ton Alter Ego.\nComment puis-je t\'aider ? 💪',
            isUser: false,
            timestamp: DateTime.now(),
            intent: AlterEgoIntent.system,
            imageAsset: _contextService.getCurrentImage(),
          ));
        }
        
        _updateContextImage();
        notifyListeners();
      });
    }
  }
  
  /// Affiche ou masque l'interface de chat
  void toggleChatInterface() {
    if (_isChatActive) {
      _showChatInterface = !_showChatInterface;
      notifyListeners();
    }
  }
  
  /// Force l'affichage de l'interface de chat
  void forceShowChatInterface() {
    if (_isChatActive && !_showChatInterface) {
      _showChatInterface = true;
      notifyListeners();
    }
  }
  
  /// Force le masquage de l'interface de chat
  void hideChatInterface() {
    if (_showChatInterface) {
      _showChatInterface = false;
      notifyListeners();
    }
  }

  /// Envoie un message au chatbot et obtient une réponse
  Future<void> sendMessage(String userMessage) async {
    if (!_isChatActive) {
      startConversation();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Ajouter le message de l'utilisateur à l'historique
    _conversationHistory.add(ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    notifyListeners();

    // Attendre un peu pour l'effet de réflexion
    await Future.delayed(const Duration(milliseconds: 800));
    setPose(AlterEgoPose.reflechit);

    // Trouver une réponse appropriée
    final response = _findResponse(userMessage);

    // Détecter l'intent du message
    final intent = _contextService.detectIntent(userMessage);
    _updateContextImage();
    
    // Ajouter la réponse à l'historique avec l'intent et l'image
    _conversationHistory.add(ChatMessage(
      text: response.message,
      isUser: false,
      timestamp: DateTime.now(),
      intent: intent,
      imageAsset: _contextService.getCurrentImage(),
    ));

    // Changer la pose et notifier (le message est dans l'historique du chat)
    setPose(response.pose);
    _isMessageVisible = true; // Pour l'animation du Bitmoji
    notifyListeners();

    // Lire le message avec TTS
    if (_ttsInitialized && response.message.isNotEmpty) {
      try {
        await _tts.stop();
        await _tts.speak(response.message);
      } catch (e) {
        debugPrint('Erreur TTS: $e');
      }
    }

    // Vérifier si la conversation doit se terminer
    if (_shouldEndConversation(userMessage)) {
      await Future.delayed(const Duration(seconds: 3));
      endConversation();
    }
  }

  /// Trouve une réponse appropriée pour un message utilisateur
  ChatResponse _findResponse(String message) {
    final lowerMessage = message.toLowerCase().trim();
    
    // Détecter l'intent
    final intent = _contextService.detectIntent(message);
    
    // Réponses contextuelles selon l'intent
    final intentResponse = _getIntentResponse(intent, lowerMessage);
    if (intentResponse != null) {
      return intentResponse;
    }

    // Rechercher un pattern correspondant dans les réponses de base
    for (final entry in _responsePatterns.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    // Réponses génériques par défaut
    if (lowerMessage.length < 3) {
      return ChatResponse(
        'Peux-tu être plus précis ? Je peux t\'aider avec tes objectifs, la nutrition, les exercices... 🤔',
        AlterEgoPose.reflechit,
      );
    }

    // Réponses aléatoires pour les messages non reconnus
    final defaultResponses = [
      ChatResponse(
        'Intéressant ! Peux-tu me donner plus de détails ? Je suis là pour t\'aider ! 💪',
        AlterEgoPose.reflechit,
      ),
      ChatResponse(
        'Je comprends. Comment puis-je t\'aider avec ça ? 🤔',
        AlterEgoPose.reflechit,
      ),
      ChatResponse(
        'D\'accord ! Parle-moi de tes objectifs fitness, je peux t\'accompagner ! 🎯',
        AlterEgoPose.encourage,
      ),
      ChatResponse(
        'Je suis là pour toi ! Que veux-tu travailler aujourd\'hui ? 💪',
        AlterEgoPose.salut,
      ),
    ];

    return defaultResponses[lowerMessage.hashCode % defaultResponses.length];
  }
  
  /// Récupère une réponse selon l'intent détecté
  ChatResponse? _getIntentResponse(AlterEgoIntent intent, String lowerMessage) {
    switch (intent) {
      case AlterEgoIntent.motivation:
        return _getMotivationResponse(lowerMessage);
      case AlterEgoIntent.entrainement:
        return _getEntrainementResponse(lowerMessage);
      case AlterEgoIntent.nutrition:
        return _getNutritionResponse(lowerMessage);
      case AlterEgoIntent.sommeil:
        return _getSommeilResponse(lowerMessage);
      case AlterEgoIntent.hydratation:
        return _getHydratationResponse(lowerMessage);
      case AlterEgoIntent.blessure:
        return _getBlessureResponse(lowerMessage);
      case AlterEgoIntent.system:
        // Mode guide - utiliser les données fictives si demandé
        if (lowerMessage.contains('stat') || lowerMessage.contains('donnée') || lowerMessage.contains('progression')) {
          return _getAssistantDataResponse();
        }
        return null; // Utiliser les réponses par défaut
    }
  }
  
  /// Réponses pour l'intent motivation
  ChatResponse _getMotivationResponse(String lowerMessage) {
    if (lowerMessage.contains('pas envie') || lowerMessage.contains('découragé')) {
      return ChatResponse(
        'Je comprends, c\'est normal d\'avoir des moments difficiles. Mais rappelle-toi : chaque jour où tu agis, tu progresses. Même un petit pas compte ! 💪✨',
        AlterEgoPose.encourage,
      );
    }
    if (lowerMessage.contains('maigrir') || lowerMessage.contains('perdre')) {
      return ChatResponse(
        'Super objectif ! La clé c\'est la régularité. Combine une alimentation équilibrée avec de l\'exercice régulier. Tu peux y arriver ! 🎯',
        AlterEgoPose.felicite,
      );
    }
    return ChatResponse(
      'La motivation vient de l\'action ! Chaque petit pas compte. Tu es plus fort que tu ne le penses ! 💪✨',
      AlterEgoPose.encourage,
    );
  }
  
  /// Réponses pour l'intent entrainement
  ChatResponse _getEntrainementResponse(String lowerMessage) {
    if (lowerMessage.contains('squat') || lowerMessage.contains('pompe')) {
      return ChatResponse(
        'Excellent choix ! Les exercices au poids du corps sont parfaits pour commencer. Veux-tu que je te guide pour bien les exécuter ? 🏋️',
        AlterEgoPose.encourage,
      );
    }
    if (lowerMessage.contains('room') || lowerMessage.contains('groupe')) {
      return ChatResponse(
        'S\'entraîner en groupe, c\'est motivant ! Tu peux créer une room et inviter tes amis. C\'est plus fun ensemble ! 👥',
        AlterEgoPose.felicite,
      );
    }
    return ChatResponse(
      'Super ! Un bon entraînement régulier fait la différence. Prêt à commencer ? 💪',
      AlterEgoPose.encourage,
    );
  }
  
  /// Réponses pour l'intent nutrition
  ChatResponse _getNutritionResponse(String lowerMessage) {
    if (lowerMessage.contains('recette')) {
      return ChatResponse(
        'Tu veux une recette perte de poids, prise de masse ou équilibrée ? Je peux te proposer des idées adaptées à tes objectifs ! 👨‍🍳',
        AlterEgoPose.reflechit,
      );
    }
    if (lowerMessage.contains('calories') || lowerMessage.contains('protéines')) {
      return ChatResponse(
        'La nutrition, c\'est 70% du succès ! Suis tes macros et reste dans tes objectifs caloriques. Je peux t\'aider à équilibrer tes repas ! 🥗',
        AlterEgoPose.reflechit,
      );
    }
    return ChatResponse(
      'La nutrition, c\'est essentiel ! Veux-tu que je t\'aide avec ton alimentation ? 🥗',
      AlterEgoPose.reflechit,
    );
  }
  
  /// Réponses pour l'intent sommeil
  ChatResponse _getSommeilResponse(String lowerMessage) {
    return ChatResponse(
      'Un bon sommeil est crucial pour la récupération ! Essaie de dormir 7-9h par nuit. Évite les écrans avant de te coucher. 😴',
      AlterEgoPose.repose,
    );
  }
  
  /// Réponses pour l'intent hydratation
  ChatResponse _getHydratationResponse(String lowerMessage) {
    // Utiliser les données fictives
    final waterLiters = 1.4;
    final waterGoal = 2.0;
    final remaining = waterGoal - waterLiters;
    
    if (remaining > 0) {
      return ChatResponse(
        'Ton hydratation est basse aujourd\'hui ! Tu as bu ${waterLiters}L sur ${waterGoal}L. Il te reste ${remaining.toStringAsFixed(1)}L à boire. Bois un peu d\'eau ! 💧',
        AlterEgoPose.alerte,
      );
    }
    return ChatResponse(
      'Super ! Tu es bien hydraté. Continue comme ça ! 💧',
      AlterEgoPose.felicite,
    );
  }
  
  /// Réponses pour l'intent blessure
  ChatResponse _getBlessureResponse(String lowerMessage) {
    return ChatResponse(
      'Je ne peux pas te donner de diagnostic médical. Si tu as une douleur, je te recommande de consulter un professionnel de santé. Tu peux enregistrer ta blessure dans le Carnet Santé & Blessures pour suivre son évolution. Prends soin de toi ! 🏥',
      AlterEgoPose.alerte,
    );
  }
  
  /// Réponses pour l'assistant data (mode démo avec données fictives)
  ChatResponse _getAssistantDataResponse() {
    // Données fictives en démo
    final steps = 6245;
    final stepsGoal = 8000;
    final stepsRemaining = stepsGoal - steps;
    final calories = 1850;
    final caloriesGoal = 1800;
    final waterLiters = 1.4;
    final waterGoal = 2.0;
    final workoutsDone = 2;
    
    String message = 'Voici ton état du jour :\n\n';
    
    if (stepsRemaining > 0) {
      message += '👟 Pas : $steps / $stepsGoal (il manque $stepsRemaining pas)\n';
    } else {
      message += '👟 Pas : $steps / $stepsGoal ✅\n';
    }
    
    if (calories > caloriesGoal) {
      message += '🍽️ Calories : $calories / $caloriesGoal (dépassement de ${calories - caloriesGoal} kcal)\n';
    } else {
      message += '🍽️ Calories : $calories / $caloriesGoal ✅\n';
    }
    
    if (waterLiters < waterGoal) {
      final remaining = waterGoal - waterLiters;
      message += '💧 Eau : ${waterLiters}L / ${waterGoal}L (il reste ${remaining.toStringAsFixed(1)}L)\n';
    } else {
      message += '💧 Eau : ${waterLiters}L / ${waterGoal}L ✅\n';
    }
    
    message += '💪 Séances : $workoutsDone réalisées aujourd\'hui\n\n';
    message += 'Continue comme ça ! 💪';
    
    return ChatResponse(message, AlterEgoPose.reflechit);
  }

  /// Détermine si la conversation doit se terminer
  bool _shouldEndConversation(String message) {
    final lowerMessage = message.toLowerCase().trim();
    final endKeywords = ['au revoir', 'bye', 'à bientôt', 'fin', 'terminer', 'merci'];

    return endKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Termine la conversation (cache le Bitmoji)
  Future<void> endConversation() async {
    if (_isChatActive) {
      _isChatActive = false;
      _showChatInterface = false;
      _isMessageVisible = false;
      _currentMessage = '';
      await Future.delayed(const Duration(milliseconds: 500));
      setVisible(false);
      _conversationHistory.clear();
      setPose(AlterEgoPose.neutre);
      notifyListeners();
    }
  }

  /// Dispose les ressources
  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

/// Modèle pour un message de chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AlterEgoIntent? intent;
  final String? imageAsset;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.imageAsset,
  });
}

/// Modèle pour une réponse du chatbot
class ChatResponse {
  final String message;
  final AlterEgoPose pose;

  ChatResponse(this.message, this.pose);
}
