part of ukan_main;

/// Modèle représentant une story.
class Story {
  final String id;
  final String name;
  final String? imageUrl;
  final IconData? icon;
  final bool isOwnStory;

  const Story({
    required this.id,
    required this.name,
    this.imageUrl,
    this.icon,
    this.isOwnStory = false,
  });
}

/// Modèle représentant une publication.
class Post {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final String imageAsset;
  final String title;
  final String? subtitle;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final bool isRecipe;

  const Post({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.imageAsset,
    required this.title,
    this.subtitle,
    this.likes = 0,
    this.comments = 0,
    required this.timestamp,
    this.isRecipe = false,
  });
}

/// Stories de démonstration.
const List<Story> demoStories = [
  Story(
    id: 'me',
    name: 'Moi',
    icon: Icons.add,
    isOwnStory: true,
  ),
  Story(
    id: 'nutrition',
    name: 'Nutrition',
    icon: Icons.restaurant_rounded,
  ),
  Story(
    id: 'recipes',
    name: 'Recettes',
    icon: Icons.menu_book_rounded,
  ),
  Story(
    id: 'sport',
    name: 'Sport',
    icon: Icons.fitness_center_rounded,
  ),
  Story(
    id: 'coach',
    name: 'Coach',
    icon: Icons.person_rounded,
  ),
  Story(
    id: 'transformations',
    name: 'Transfo',
    icon: Icons.auto_awesome_rounded,
  ),
];

/// Publications de démonstration.
final List<Post> demoPosts = [
  Post(
    id: '1',
    authorName: 'Ukan Coach',
    imageAsset: 'assets/images/foodscan/pizza_scan.png',
    title: 'Pizza maison protéinée',
    subtitle: '420 kcal • 32g protéines',
    likes: 156,
    comments: 23,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRecipe: true,
  ),
  Post(
    id: '2',
    authorName: 'Marie Fitness',
    imageAsset: 'assets/images/foodscan/burger_scan.png',
    title: 'Burger healthy',
    subtitle: '380 kcal • 28g protéines',
    likes: 89,
    comments: 12,
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    isRecipe: true,
  ),
  Post(
    id: '3',
    authorName: 'Coach Thomas',
    imageAsset: 'assets/images/coach1_header.png',
    title: 'Séance Full Body terminée 💪',
    subtitle: '45 min • 320 kcal brûlées',
    likes: 234,
    comments: 45,
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    isRecipe: false,
  ),
  Post(
    id: '4',
    authorName: 'Ukan Nutrition',
    imageAsset: 'assets/images/foodscan/salade_scan.png',
    title: 'Salade composée équilibrée',
    subtitle: '280 kcal • 18g protéines',
    likes: 67,
    comments: 8,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRecipe: true,
  ),
];








