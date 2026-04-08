import 'package:flutter/foundation.dart';
import '../data/fake_images.dart';

/// Type de contenu dans le feed
enum FeedPostType {
  recipe, // Recette
  sport, // Photo/vidéo de sport
  community, // Post communautaire
}

/// Post dans le feed du profil
class ProfileFeedPost {
  final String id;
  final FeedPostType type;
  final String? imageUrl; // URL de l'image
  final String? videoUrl; // URL de la vidéo (si c'est une vidéo)
  final String? caption; // Légende du post
  final DateTime createdAt;
  final int likes;
  final int comments;
  final String? recipeTitle; // Pour les recettes
  final int? calories; // Pour les recettes
  final String? workoutType; // Pour les posts sport

  ProfileFeedPost({
    required this.id,
    required this.type,
    this.imageUrl,
    this.videoUrl,
    this.caption,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.recipeTitle,
    this.calories,
    this.workoutType,
  });

  bool get isVideo => videoUrl != null;
  
  /// Retourne l'image à afficher (utilise getRandomImage si imageUrl est null ou vide)
  String get displayImage {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    // Utiliser getRandomRecipeImage pour les recettes, getRandomSportImage pour le sport
    if (type == FeedPostType.recipe) {
      return getRandomRecipeImage();
    }
    return getRandomSportImage();
  }
}

/// Notifier pour gérer le feed du profil
class ProfileFeedNotifier extends ChangeNotifier {
  static final ProfileFeedNotifier _instance = ProfileFeedNotifier._internal();
  factory ProfileFeedNotifier() => _instance;
  ProfileFeedNotifier._internal() {
    _initDemoData();
  }

  final List<ProfileFeedPost> _posts = [];
  int _followers = 1247;
  int _following = 389;

  List<ProfileFeedPost> get posts => _posts;
  int get followers => _followers;
  int get following => _following;

  /// Récupère les posts triés par algorithme (mélange recettes et sport)
  List<ProfileFeedPost> getSortedPosts() {
    // Algorithme simple : mélange recettes et sport de manière équilibrée
    final recipePosts = _posts.where((p) => p.type == FeedPostType.recipe).toList().cast<ProfileFeedPost>();
    final sportPosts = _posts.where((p) => p.type == FeedPostType.sport).toList().cast<ProfileFeedPost>();
    
    // Trier par date (plus récent en premier)
    recipePosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    sportPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Mélanger de manière équilibrée (1 recette, 1 sport, etc.)
    final sorted = <ProfileFeedPost>[];
    final maxLength = recipePosts.length > sportPosts.length 
        ? recipePosts.length 
        : sportPosts.length;
    
    for (int i = 0; i < maxLength; i++) {
      if (i < sportPosts.length) {
        sorted.add(sportPosts[i]);
      }
      if (i < recipePosts.length) {
        sorted.add(recipePosts[i]);
      }
    }
    
    return sorted;
  }

  void _initDemoData() {
    final now = DateTime.now();
    _posts.addAll([
      // Posts sport
      ProfileFeedPost(
        id: 'sport_1',
        type: FeedPostType.sport,
        imageUrl: getRandomSportImage(),
        caption: 'Séance HIIT intense ce matin ! 💪',
        createdAt: now.subtract(const Duration(hours: 2)),
        likes: 45,
        comments: 8,
        workoutType: 'HIIT',
      ),
      ProfileFeedPost(
        id: 'sport_2',
        type: FeedPostType.sport,
        videoUrl: null, // Pas de vidéo en démo, on utilise une image
        imageUrl: getRandomSportImage(),
        caption: 'Nouveau PR au squat ! 🏋️',
        createdAt: now.subtract(const Duration(days: 1)),
        likes: 128,
        comments: 23,
        workoutType: 'Musculation',
      ),
      ProfileFeedPost(
        id: 'sport_3',
        type: FeedPostType.sport,
        imageUrl: getRandomSportImage(),
        caption: 'Course matinale dans le parc 🏃',
        createdAt: now.subtract(const Duration(days: 2)),
        likes: 67,
        comments: 12,
        workoutType: 'Cardio',
      ),
      ProfileFeedPost(
        id: 'sport_4',
        type: FeedPostType.sport,
        imageUrl: getRandomSportImage(),
        caption: 'Yoga flow pour la récupération 🧘',
        createdAt: now.subtract(const Duration(days: 3)),
        likes: 89,
        comments: 15,
        workoutType: 'Yoga',
      ),
      
      // Posts recettes avec images ChatGPT adaptées
      ProfileFeedPost(
        id: 'recipe_1',
        type: FeedPostType.recipe,
        imageUrl: 'assets/images/foodscan/salade_poulet_scan.png', // Salade protéinée
        caption: 'Salade protéinée express 🥗',
        createdAt: now.subtract(const Duration(hours: 5)),
        likes: 92,
        comments: 18,
        recipeTitle: 'Salade protéinée express',
        calories: 350,
      ),
      ProfileFeedPost(
        id: 'recipe_2',
        type: FeedPostType.recipe,
        imageUrl: 'assets/images/ChatGPT Image 25 nov. 2025, 18_51_26.png', // Bowl cake
        caption: 'Bowl cake chocolat-banane 🍌',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        likes: 156,
        comments: 34,
        recipeTitle: 'Bowl cake chocolat-banane',
        calories: 450,
      ),
      ProfileFeedPost(
        id: 'recipe_3',
        type: FeedPostType.recipe,
        imageUrl: 'assets/images/ChatGPT Image 25 nov. 2025, 18_45_34.png', // Curry omelette (adapté pour curry)
        caption: 'Poulet curry vert 🍛',
        createdAt: now.subtract(const Duration(days: 2, hours: 2)),
        likes: 203,
        comments: 42,
        recipeTitle: 'Poulet curry vert',
        calories: 400,
      ),
      ProfileFeedPost(
        id: 'recipe_4',
        type: FeedPostType.recipe,
        imageUrl: 'assets/images/ChatGPT Image 25 nov. 2025, 18_35_02.png', // Smoothie protéiné
        caption: 'Smoothie détox fruits rouges 🍓',
        createdAt: now.subtract(const Duration(days: 4)),
        likes: 134,
        comments: 28,
        recipeTitle: 'Smoothie détox fruits rouges',
        calories: 180,
      ),
      ProfileFeedPost(
        id: 'recipe_5',
        type: FeedPostType.recipe,
        imageUrl: 'assets/images/ChatGPT Image 25 nov. 2025, 18_45_34.png', // Curry omelette
        caption: 'Omelette aux légumes 🥚',
        createdAt: now.subtract(const Duration(days: 5)),
        likes: 78,
        comments: 14,
        recipeTitle: 'Omelette aux légumes',
        calories: 280,
      ),
    ]);
  }

  void addPost(ProfileFeedPost post) {
    _posts.add(post);
    notifyListeners();
  }

  void updateFollowers(int count) {
    _followers = count;
    notifyListeners();
  }

  void updateFollowing(int count) {
    _following = count;
    notifyListeners();
  }
}
