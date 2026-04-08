import 'package:flutter/material.dart';

/// Énumération des intents possibles pour l'Alter Ego
enum AlterEgoIntent {
  motivation,
  entrainement,
  nutrition,
  sommeil,
  hydratation,
  blessure,
  system, // Mode guide par défaut
}

/// Énumération des pages de l'application
enum UkanPage {
  accueil,
  objectifCalories,
  objectifPas,
  objectifSommeil,
  objectifHydratation,
  objectifSeances,
  nutritionDuJour,
  recettesCommunaute,
  statistiques,
  sessions,
  rooms,
  santeBlessures,
  alterEgoPremium,
  chatMatch,
  gameStory,
  espacePro,
  faqSupport,
}

/// Service pour gérer le contexte et les intents de l'Alter Ego
class AlterEgoContextService {
  static final AlterEgoContextService _instance = AlterEgoContextService._internal();
  factory AlterEgoContextService() => _instance;
  AlterEgoContextService._internal();

  UkanPage? _currentPage;
  AlterEgoIntent? _currentIntent;

  /// Mapping des pages vers les images contextuelles
  static const Map<UkanPage, String> pageImageMapping = {
    UkanPage.accueil: 'system',
    UkanPage.objectifCalories: 'nutrition',
    UkanPage.objectifPas: 'motivation',
    UkanPage.objectifSommeil: 'sommeil',
    UkanPage.objectifHydratation: 'hydratation',
    UkanPage.objectifSeances: 'entrainement',
    UkanPage.nutritionDuJour: 'nutrition',
    UkanPage.recettesCommunaute: 'nutrition',
    UkanPage.statistiques: 'system',
    UkanPage.sessions: 'entrainement',
    UkanPage.rooms: 'entrainement',
    UkanPage.santeBlessures: 'blessure',
    UkanPage.alterEgoPremium: 'system',
    UkanPage.chatMatch: 'motivation',
    UkanPage.gameStory: 'motivation',
    UkanPage.espacePro: 'system',
    UkanPage.faqSupport: 'system',
  };

  /// Mapping des images contextuelles vers les chemins d'assets
  static const Map<String, String> alterEgoImageMapping = {
    'motivation': 'assets/images/alter_motivation_1.png',
    'entrainement': 'assets/images/alter_sport_1.png',
    'nutrition': 'assets/images/alter_nutrition_1.png',
    'sommeil': 'assets/images/alter_sleep_1.png',
    'hydratation': 'assets/images/alter_water_1.png',
    'blessure': 'assets/images/alter_injury_1.png',
    'system': 'assets/images/alter_default_1.png',
  };

  /// Messages GUIDE par page
  static const Map<UkanPage, String> pageGuideMessages = {
    UkanPage.accueil: 'Bienvenue sur ta page d\'accueil ! Ici tu retrouves tous tes objectifs du jour et de la semaine. Tu peux suivre tes pas, calories, hydratation, sommeil et séances. Clique sur une carte pour voir les détails ! 🏠',
    UkanPage.objectifCalories: 'Ici tu vois la limite calorique à ne pas dépasser. Tu peux enregistrer tes repas et suivre ton quota. Chaque repas (petit-déjeuner, déjeuner, collation, dîner) est comptabilisé. 🍽️',
    UkanPage.objectifPas: 'Cette page affiche ton objectif de pas du jour. Tu peux suivre ta progression en temps réel. Chaque pas compte vers ton objectif ! 👟',
    UkanPage.objectifSommeil: 'Ici tu peux voir combien d\'heures tu as dormi la nuit dernière et comparer avec ton objectif. Un bon sommeil est essentiel pour la récupération ! 😴',
    UkanPage.objectifHydratation: 'Suis ta consommation d\'eau du jour. Tu peux ajouter de l\'eau rapidement avec les boutons ou saisir une quantité personnalisée. Reste hydraté ! 💧',
    UkanPage.objectifSeances: 'Voici tes séances de la semaine. Tu peux voir celles que tu as complétées et celles qui restent. Continue comme ça ! 💪',
    UkanPage.nutritionDuJour: 'Voici les repas du jour. Tu peux ajouter petit-déjeuner, déjeuner, collation, dîner. Chaque repas affiche les calories, protéines, glucides et lipides. 🥗',
    UkanPage.recettesCommunaute: 'Tu peux consulter les idées de repas, recettes de la communauté, ou ajouter ta propre recette en vidéo / photo. Partage tes meilleures recettes ! 👨‍🍳',
    UkanPage.statistiques: 'Ici tu retrouves toutes tes statistiques : pas, calories, nutrition, sommeil, hydratation, séances. Tu peux voir l\'évolution sur la semaine ou le mois. 📊',
    UkanPage.sessions: 'Cette page liste toutes tes séances d\'entraînement. Tu peux voir l\'historique et suivre ta progression. 🏋️',
    UkanPage.rooms: 'Cette page te permet de t\'entraîner en groupe, d\'activer la caméra, de mettre en pause, etc. Invite tes amis et entraînez-vous ensemble ! 👥',
    UkanPage.santeBlessures: 'Ici tu peux enregistrer tes blessures, leur évolution, ton groupe sanguin, tes allergies, tes ordonnances. Prends soin de toi ! 🏥',
    UkanPage.alterEgoPremium: 'Bienvenue dans l\'Alter Ego Premium ! Ici tu peux personnaliser ton coach virtuel et accéder à des fonctionnalités avancées. ⭐',
    UkanPage.chatMatch: 'Trouve un partenaire d\'entraînement ! Filtre par sport, niveau, ville et trouve la personne idéale pour t\'entraîner ensemble. 💬',
    UkanPage.gameStory: 'Transforme tes séances en jeu ! Débloque des récompenses, monte de niveau et rends l\'entraînement fun. 🎮',
    UkanPage.espacePro: 'Espace réservé aux coachs. Gère tes programmes, tes clients et développe ton activité. 💼',
    UkanPage.faqSupport: 'Bienvenue sur la page FAQ & Support ! Ici tu trouveras des réponses aux questions fréquentes et tu pourras contacter notre équipe si besoin. ❓',
  };

  /// Mots-clés pour détecter les intents
  static const Map<AlterEgoIntent, List<String>> intentKeywords = {
    AlterEgoIntent.motivation: [
      'maigrir', 'motiver', 'pas envie', 'fatigué', 'découragé', 'abandonner',
      'difficile', 'lâcher', 'motivation', 'encourage', 'boost', 'énergie'
    ],
    AlterEgoIntent.entrainement: [
      'squat', 'pompe', 'room', 'sport', 'entraînement', 'exercice', 'séance',
      'musculation', 'cardio', 'workout', 'gym', 'salle', 'sportif'
    ],
    AlterEgoIntent.nutrition: [
      'recette', 'repas', 'calories', 'protéines', 'glucides', 'lipides',
      'manger', 'alimentation', 'nutrition', 'repas', 'déjeuner', 'dîner',
      'petit-déjeuner', 'collation', 'régime', 'diète'
    ],
    AlterEgoIntent.sommeil: [
      'fatigue', 'dormi', 'sommeil', 'dormir', 'réveil', 'nuit', 'repos',
      'épuisé', 'endormi', 'insomnie', 'réveillé'
    ],
    AlterEgoIntent.hydratation: [
      'eau', 'boire', 'hydratation', 'soif', 'déshydraté', 'liquide',
      'boisson', 'hydraté'
    ],
    AlterEgoIntent.blessure: [
      'mal', 'douleur', 'blessure', 'genou', 'dos', 'épaule', 'cheville',
      'blessé', 'injury', 'souffre', 'souffrance', 'douleurs'
    ],
  };

  /// Définit la page actuelle
  void setCurrentPage(UkanPage? page) {
    _currentPage = page;
    // Réinitialiser l'intent quand on change de page
    _currentIntent = null;
  }

  /// Récupère la page actuelle
  UkanPage? get currentPage => _currentPage;

  /// Détermine l'intent à partir d'un message utilisateur
  AlterEgoIntent detectIntent(String message) {
    final lowerMessage = message.toLowerCase().trim();

    // Vérifier chaque intent
    for (final entry in intentKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerMessage.contains(keyword)) {
          _currentIntent = entry.key;
          return entry.key;
        }
      }
    }

    // Si aucun intent détecté, utiliser le mode system (guide)
    _currentIntent = AlterEgoIntent.system;
    return AlterEgoIntent.system;
  }

  /// Récupère l'intent actuel
  AlterEgoIntent? get currentIntent => _currentIntent;

  /// Récupère le message GUIDE pour la page actuelle
  String? getGuideMessage() {
    if (_currentPage == null) return null;
    return pageGuideMessages[_currentPage];
  }

  /// Récupère l'image contextuelle pour la page actuelle
  String? getContextImage() {
    if (_currentPage == null) return null;
    final imageKey = pageImageMapping[_currentPage];
    if (imageKey == null) return null;
    return alterEgoImageMapping[imageKey];
  }

  /// Récupère l'image contextuelle pour un intent
  String? getIntentImage(AlterEgoIntent intent) {
    final imageKey = _intentToImageKey(intent);
    return alterEgoImageMapping[imageKey];
  }

  /// Convertit un intent en clé d'image
  String _intentToImageKey(AlterEgoIntent intent) {
    switch (intent) {
      case AlterEgoIntent.motivation:
        return 'motivation';
      case AlterEgoIntent.entrainement:
        return 'entrainement';
      case AlterEgoIntent.nutrition:
        return 'nutrition';
      case AlterEgoIntent.sommeil:
        return 'sommeil';
      case AlterEgoIntent.hydratation:
        return 'hydratation';
      case AlterEgoIntent.blessure:
        return 'blessure';
      case AlterEgoIntent.system:
        // Utiliser l'image de la page si disponible, sinon default
        if (_currentPage != null) {
          final pageImageKey = pageImageMapping[_currentPage];
          if (pageImageKey != null) {
            return pageImageKey;
          }
        }
        return 'system';
    }
  }

  /// Récupère l'image contextuelle à utiliser (priorité à l'intent, sinon page)
  String? getCurrentImage() {
    if (_currentIntent != null && _currentIntent != AlterEgoIntent.system) {
      return getIntentImage(_currentIntent!);
    }
    return getContextImage();
  }
}

