import 'package:flutter/material.dart';
import 'feed_detail.dart';
import '../pages/recipe_book_page.dart';
import '../models/recipe.dart';
import '../models/nutrition.dart';
import '../pages/recipe_detail_page.dart';

// Palette moderne et immersive (uniforme avec le reste de l'app)
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryPurple = Color(0xFFA855F7);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);

// Styles uniformes pour tous les conteneurs
const double _uniformBorderRadius = 16.0;
const double _uniformBorderWidth = 1.5;
const List<BoxShadow> _uniformShadow = [
  BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

/// Widget Explorer réutilisable - Grille 3 colonnes style Instagram
/// Utilisé dans Nutrition > Recettes et gourmandises > Fil
class ExplorerFeedWidget extends StatefulWidget {
  final bool showHeader;
  final bool showRecipeBookButton;

  const ExplorerFeedWidget({
    super.key,
    this.showHeader = true,
    this.showRecipeBookButton = true,
  });

  @override
  State<ExplorerFeedWidget> createState() => _ExplorerFeedWidgetState();
}

class _ExplorerFeedWidgetState extends State<ExplorerFeedWidget> {
  // Liste des images avec métadonnées
  static const List<Map<String, dynamic>> _posts = [
    {
      'image': 'assets/images/foodscan/pizza_scan.png',
      'isRecipe': true,
      'title': 'Pizza maison',
    },
    {
      'image': 'assets/images/foodscan/burger_scan.png',
      'isRecipe': true,
      'title': 'Burger healthy',
    },
    {
      'image': 'assets/images/foodscan/pates_bolo_scan.png',
      'isRecipe': true,
      'title': 'Pâtes bolognaise',
    },
    {
      'image': 'assets/images/foodscan/plat_maison_scan.png',
      'isRecipe': true,
      'title': 'Plat maison',
    },
    {
      'image': 'assets/images/foodscan/salade_scan.png',
      'isRecipe': true,
      'title': 'Salade composée',
    },
    {
      'image': 'assets/images/coach1_header.png',
      'isRecipe': false,
      'title': 'Coach Ukan',
    },
    {
      'image': 'assets/images/fitpro_logo_boxeur_droit.png',
      'isRecipe': false,
      'title': 'Ukan Sport',
    },
    {
      'image': 'assets/images/fitpro_logo_boxeur_gauche.png',
      'isRecipe': false,
      'title': 'Ukan Boxe',
    },
    {
      'image': 'assets/images/fitpro_logo_boxeur_replie.png',
      'isRecipe': false,
      'title': 'Ukan Training',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _darkBg,
      child: Column(
        children: [
          // Header optionnel
          if (widget.showHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Titre "Explorer"
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.explore, color: _primaryGold, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Explorer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textLight,
                        ),
                      ),
                    ],
                  ),
                  // Bouton Mon livre de recettes
                  if (widget.showRecipeBookButton)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _cardBgLight,
                          borderRadius: BorderRadius.circular(_uniformBorderRadius),
                          border: Border.all(
                            color: _primaryOrange.withOpacity(0.3),
                            width: _uniformBorderWidth,
                          ),
                          boxShadow: _uniformShadow,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 20,
                          color: _primaryOrange,
                        ),
                      ),
                      tooltip: 'Mon Livre de Recettes',
                      onPressed: () => _openRecipeBook(context),
                    ),
                ],
              ),
            ),
          if (widget.showHeader) const SizedBox(height: 8),
          if (widget.showHeader)
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: _cardBgLight,
            ),
          if (widget.showHeader) const SizedBox(height: 8),
          
          // Grille de publications 3 colonnes
          Expanded(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                final imagePath = post['image'] as String;
                final isRecipe = post['isRecipe'] as bool;
                final title = post['title'] as String;

                return _GridItem(
                  key: ValueKey('explorer_post_${index}_${title.hashCode}'),
                  imagePath: imagePath,
                  isRecipe: isRecipe,
                  title: title,
                  onTap: () {
                    if (isRecipe) {
                      _handleRecipeImageTap(context, title, imagePath);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FeedDetailPage(
                            imagePath: imagePath,
                          ),
                        ),
                      );
                    }
                  },
                  onRecipeTap: isRecipe
                      ? () => _openRecipeDetail(context, title, imagePath)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openRecipeBook(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecipeBookPage()),
    );
  }

  void _openRecipeDetail(BuildContext context, String title, String imagePath) {
    final recipe = Recipe(
      id: 'explorer_temp_${title.hashCode}',
      name: title,
      typeRepas: MealType.lunch,
      description: 'Recette découverte sur le fil d\'actualité.',
      ingredients: '• Ingrédients à découvrir...',
      steps: '1. Préparer les ingrédients\n2. Cuisiner avec amour\n3. Déguster !',
      calories: 450,
      imagePath: imagePath,
      isUserRecipe: false,
      isSharedWithCommunity: true,
      createdAt: DateTime.now(),
      category: RecipeCategory.healthy,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }

  void _addToBookWithCategory(BuildContext context, String title, String imagePath, RecipeCategory category) {
    final notifier = RecipeNotifier();
    final existingRecipe = notifier.getCommunityRecipes().firstWhere(
      (r) => r.name == title,
      orElse: () => Recipe(
        id: 'temp_${title.hashCode}',
        name: title,
        typeRepas: MealType.lunch,
        description: 'Recette sauvegardée depuis le fil d\'actualité',
        ingredients: '',
        steps: '',
        isUserRecipe: false,
        isSharedWithCommunity: true,
        createdAt: DateTime.now(),
        category: category,
        isFavorite: false,
      ),
    );

    if (notifier.getRecipeById(existingRecipe.id) == null) {
      notifier.addRecipe(existingRecipe);
    }

    if (existingRecipe.category != category) {
      final updatedRecipe = existingRecipe.copyWith(category: category);
      notifier.updateRecipe(updatedRecipe);
    }

    final currentRecipe = notifier.getRecipeById(existingRecipe.id);
    if (currentRecipe != null && !currentRecipe.isFavorite) {
      notifier.toggleFavorite(currentRecipe.id);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📌 Ajouté à "$title" dans l\'onglet ${category.displayName} !'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OUVRIR',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecipeBookPage()),
            );
          },
        ),
      ),
    );
  }

  void _handleRecipeImageTap(BuildContext context, String title, String imagePath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter "$title" au Livre',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choisissez un onglet (catégorie) pour cette recette :',
              style: TextStyle(color: _textMuted),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RecipeCategory.values.map((category) {
                return ActionChip(
                  label: Text(category.displayName),
                  onPressed: () {
                    _addToBookWithCategory(context, title, imagePath, category);
                  },
                  backgroundColor: _cardBgLight,
                  side: BorderSide(color: _primaryGold.withOpacity(0.3)),
                  labelStyle: const TextStyle(color: _textLight),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Item de grille pour le feed
class _GridItem extends StatelessWidget {
  final String imagePath;
  final bool isRecipe;
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onRecipeTap;

  const _GridItem({
    super.key,
    required this.imagePath,
    required this.isRecipe,
    required this.title,
    required this.onTap,
    this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBgLight, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _cardBgLight,
                  child: const Icon(Icons.image, color: _textMuted, size: 32),
                ),
              ),
              // Overlay gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Badge recette
              if (isRecipe)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _primaryOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              // Titre en bas
              Positioned(
                bottom: 6,
                left: 6,
                right: 6,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}









