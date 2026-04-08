import 'package:flutter/foundation.dart';
import '../data/fake_images.dart';

/// ─────────────────────────────────────────────
/// Modèle pour le feed du coach (Publications, Recettes, Coaching)
/// ─────────────────────────────────────────────

/// Type de contenu du coach
enum CoachContentType {
  post,      // Publication style réseaux sociaux
  recipe,    // Recette
  coaching,  // Contenu d'entraînement (vidéo, séance, tutoriel)
  live,      // Live (préparation future)
}

/// Type d'accès au contenu
enum AccessType {
  free,         // Gratuit
  subscription, // Accessible par abonnement
  oneTime,      // Achat unique
}

/// Modèle de contenu du coach
class CoachContent {
  final String id;
  final String coachId;
  final CoachContentType type;
  final String title;
  final String description;
  final String? imagePath; // Photo ou thumbnail
  final String? videoPath; // Vidéo (optionnel)
  final Duration? duration; // Pour coaching / live
  final AccessType accessType;
  final double? price; // Prix si achat unique (null si gratuit ou abonnement)
  final DateTime createdAt;
  
  // Champs spécifiques pour les recettes
  final List<String>? tags; // Tags : "Perte de poids", "Prise de masse", "Végé", etc.
  final int? calories; // Calories (démo)
  final Map<String, double>? macros; // Macros : {"proteins": 30, "carbs": 50, "fats": 20}
  
  // Champs spécifiques pour le coaching
  final String? category; // "cardio", "renfo", "stretching", etc.
  final String? level; // "débutant", "intermédiaire", "avancé"
  
  // Champs spécifiques pour les lives
  final DateTime? scheduledAt; // Date/heure du live

  CoachContent({
    required this.id,
    required this.coachId,
    required this.type,
    required this.title,
    required this.description,
    this.imagePath,
    this.videoPath,
    this.duration,
    required this.accessType,
    this.price,
    required this.createdAt,
    this.tags,
    this.calories,
    this.macros,
    this.category,
    this.level,
    this.scheduledAt,
  });

  /// Retourne l'image à afficher (utilise getRandomImage si imagePath est null ou vide)
  String get displayImage {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return imagePath!;
    }
    // Utiliser getRandomRecipeImage pour les recettes, getRandomSportImage pour le reste
    if (type == CoachContentType.recipe) {
      return getRandomRecipeImage();
    }
    return getRandomSportImage();
  }

  /// Vérifie si le contenu est accessible (démo : toujours true pour l'instant)
  bool get isAccessible {
    // En mode démo, tout est accessible
    // Plus tard, on vérifiera l'abonnement ou l'achat
    return true;
  }

  /// Retourne le badge d'accès à afficher
  String get accessBadge {
    switch (accessType) {
      case AccessType.free:
        return 'Gratuit';
      case AccessType.subscription:
        return 'Abonné';
      case AccessType.oneTime:
        return price != null ? 'Achat unique – ${price!.toStringAsFixed(2)} €' : 'Achat unique';
    }
  }

  /// Vérifie si le contenu est payant
  bool get isPaid {
    return accessType == AccessType.subscription || accessType == AccessType.oneTime;
  }
}

/// Notifier pour gérer le feed du coach
class CoachContentNotifier extends ChangeNotifier {
  static final CoachContentNotifier _instance = CoachContentNotifier._internal();
  factory CoachContentNotifier() => _instance;
  CoachContentNotifier._internal() {
    _initDemoData();
  }

  final List<CoachContent> _contents = [];

  /// Récupère tous les contenus d'un coach
  List<CoachContent> getContentsForCoach(String coachId, {CoachContentType? type}) {
    var contents = _contents.where((c) => c.coachId == coachId);
    if (type != null) {
      contents = contents.where((c) => c.type == type);
    }
    return contents.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Plus récents en premier
  }

  /// Récupère les publications (posts)
  List<CoachContent> getPosts(String coachId) {
    return getContentsForCoach(coachId, type: CoachContentType.post);
  }

  /// Récupère les recettes
  List<CoachContent> getRecipes(String coachId) {
    return getContentsForCoach(coachId, type: CoachContentType.recipe);
  }

  /// Récupère les contenus de coaching
  List<CoachContent> getCoachingContents(String coachId) {
    return getContentsForCoach(coachId, type: CoachContentType.coaching);
  }

  /// Récupère les lives
  List<CoachContent> getLives(String coachId) {
    return getContentsForCoach(coachId, type: CoachContentType.live);
  }

  /// Ajoute un nouveau contenu (pour le mode coach)
  void addContent(CoachContent content) {
    _contents.add(content);
    notifyListeners();
  }

  /// Initialise les données de démo
  void _initDemoData() {
    final now = DateTime.now();
    
    // Publications (gratuites)
    _contents.addAll([
      CoachContent(
        id: 'post_1',
        coachId: 'coach_1',
        type: CoachContentType.post,
        title: 'Nouvelle séance en salle !',
        description: 'Super séance aujourd\'hui avec mes clients. On a travaillé le dos et les épaules. 💪',
        imagePath: getRandomSportImage(),
        accessType: AccessType.free,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      CoachContent(
        id: 'post_2',
        coachId: 'coach_1',
        type: CoachContentType.post,
        title: 'Conseil du jour',
        description: 'N\'oubliez pas de bien vous hydrater pendant l\'entraînement ! 💧',
        imagePath: getRandomSportImage(),
        accessType: AccessType.free,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      CoachContent(
        id: 'post_3',
        coachId: 'coach_1',
        type: CoachContentType.post,
        title: 'Transformation incroyable !',
        description: 'Félicitations à mon client pour cette transformation en 3 mois ! 🔥',
        imagePath: getRandomSportImage(),
        accessType: AccessType.free,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      CoachContent(
        id: 'post_4',
        coachId: 'coach_1',
        type: CoachContentType.post,
        title: 'Nouveau programme disponible',
        description: 'Mon nouveau programme "Full Body 30 jours" est maintenant disponible !',
        imagePath: getRandomSportImage(),
        accessType: AccessType.free,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);

    // Recettes
    _contents.addAll([
      CoachContent(
        id: 'recipe_1',
        coachId: 'coach_1',
        type: CoachContentType.recipe,
        title: 'Smoothie protéiné banane',
        description: 'Un smoothie parfait pour la récupération après l\'entraînement.',
        imagePath: getRandomRecipeImage(),
        accessType: AccessType.free,
        createdAt: now.subtract(const Duration(days: 1)),
        tags: ['Récupération', 'Protéines', 'Végé'],
        calories: 250,
        macros: {'proteins': 30.0, 'carbs': 35.0, 'fats': 5.0},
      ),
      CoachContent(
        id: 'recipe_2',
        coachId: 'coach_1',
        type: CoachContentType.recipe,
        title: 'Salade de poulet grillé',
        description: 'Repas équilibré riche en protéines, parfait pour la prise de masse.',
        imagePath: getRandomRecipeImage(),
        accessType: AccessType.subscription,
        createdAt: now.subtract(const Duration(days: 3)),
        tags: ['Prise de masse', 'Protéines', 'Équilibré'],
        calories: 450,
        macros: {'proteins': 45.0, 'carbs': 40.0, 'fats': 15.0},
      ),
      CoachContent(
        id: 'recipe_3',
        coachId: 'coach_1',
        type: CoachContentType.recipe,
        title: 'Bowl protéiné végétarien',
        description: 'Un bowl complet et savoureux, 100% végétarien.',
        imagePath: getRandomRecipeImage(),
        accessType: AccessType.oneTime,
        price: 2.99,
        createdAt: now.subtract(const Duration(days: 5)),
        tags: ['Végé', 'Équilibré', 'Protéines'],
        calories: 380,
        macros: {'proteins': 25.0, 'carbs': 50.0, 'fats': 12.0},
      ),
      CoachContent(
        id: 'recipe_4',
        coachId: 'coach_1',
        type: CoachContentType.recipe,
        title: 'Pancakes protéinés',
        description: 'Des pancakes délicieux et riches en protéines pour le petit-déjeuner.',
        imagePath: getRandomRecipeImage(),
        accessType: AccessType.free,
        createdAt: now.subtract(const Duration(days: 8)),
        tags: ['Petit-déjeuner', 'Protéines', 'Gourmand'],
        calories: 320,
        macros: {'proteins': 35.0, 'carbs': 30.0, 'fats': 8.0},
      ),
    ]);

    // Coaching
    _contents.addAll([
      CoachContent(
        id: 'coaching_1',
        coachId: 'coach_1',
        type: CoachContentType.coaching,
        title: 'Séance HIIT 15 min',
        description: 'Une séance HIIT intense pour brûler les calories rapidement.',
        imagePath: getRandomSportImage(),
        videoPath: null, // Pas de vidéo en démo
        duration: const Duration(minutes: 15),
        accessType: AccessType.free,
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'cardio',
        level: 'intermédiaire',
      ),
      CoachContent(
        id: 'coaching_2',
        coachId: 'coach_1',
        type: CoachContentType.coaching,
        title: 'Renforcement musculaire complet',
        description: 'Séance complète de renforcement pour tout le corps.',
        imagePath: getRandomSportImage(),
        videoPath: null,
        duration: const Duration(minutes: 45),
        accessType: AccessType.subscription,
        createdAt: now.subtract(const Duration(days: 4)),
        category: 'renfo',
        level: 'avancé',
      ),
      CoachContent(
        id: 'coaching_3',
        coachId: 'coach_1',
        type: CoachContentType.coaching,
        title: 'Stretching matinal',
        description: 'Routine de stretching pour bien commencer la journée.',
        imagePath: getRandomSportImage(),
        videoPath: null,
        duration: const Duration(minutes: 10),
        accessType: AccessType.oneTime,
        price: 4.99,
        createdAt: now.subtract(const Duration(days: 6)),
        category: 'stretching',
        level: 'débutant',
      ),
      CoachContent(
        id: 'coaching_4',
        coachId: 'coach_1',
        type: CoachContentType.coaching,
        title: 'Tutoriel : Squats parfaits',
        description: 'Apprenez la technique parfaite pour les squats.',
        imagePath: getRandomSportImage(),
        videoPath: null,
        duration: const Duration(minutes: 8),
        accessType: AccessType.free,
        createdAt: now.subtract(const Duration(days: 9)),
        category: 'renfo',
        level: 'débutant',
      ),
    ]);

    // Lives (préparation)
    _contents.addAll([
      CoachContent(
        id: 'live_1',
        coachId: 'coach_1',
        type: CoachContentType.live,
        title: 'Live : Questions/Réponses',
        description: 'Posez-moi toutes vos questions en direct !',
        imagePath: getRandomSportImage(),
        accessType: AccessType.free,
        createdAt: now,
        scheduledAt: now.add(const Duration(days: 2, hours: 18)),
      ),
      CoachContent(
        id: 'live_2',
        coachId: 'coach_1',
        type: CoachContentType.live,
        title: 'Live : Séance en groupe',
        description: 'Rejoignez-moi pour une séance d\'entraînement en direct !',
        imagePath: getRandomSportImage(),
        accessType: AccessType.subscription,
        createdAt: now,
        scheduledAt: now.add(const Duration(days: 5, hours: 19)),
      ),
    ]);
  }
}
