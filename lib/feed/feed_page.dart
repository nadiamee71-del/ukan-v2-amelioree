import 'package:flutter/material.dart';
import 'feed_detail.dart';
import '../pages/recipe_book_page.dart';
import '../pages/create_feed_post_page.dart';
import '../pages/add_recipe_page.dart';
import '../models/recipe.dart';
import '../models/nutrition.dart';
import '../pages/recipe_detail_page.dart';
import '../models/profile_feed.dart'; // Pour FeedPostType
import '../pages/notes_page.dart';

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

/// Page principale du feed Instagram avec grille 3 colonnes
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
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

  final Set<String> _followedUsers = {'demo_user_1', 'demo_user_3', 'community_user_1'};

  @override
  Widget build(BuildContext context) {
    // Afficher uniquement les posts des utilisateurs suivis
    final displayedPosts = _posts.where((post) => (post['image'] as String).hashCode % 2 == 0).toList();

    return Container(
      color: _darkBg,
      child: Column(
        children: [
          // Header "Mémo" + bouton Mon livre de recettes à droite
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton "Mémo" - accès rapide aux notes
                GestureDetector(
                  onTap: () => _openNotesPage(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _primaryGold,
                      borderRadius: BorderRadius.circular(_uniformBorderRadius),
                      boxShadow: _uniformShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sticky_note_2, color: Colors.black, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Mémo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bouton Mon livre de recettes à droite - style uniforme
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
          const SizedBox(height: 8),
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: _cardBgLight,
          ),
          const SizedBox(height: 8),
          // Grille de publications 3 colonnes
          Expanded(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 100), // Padding bas pour bien voir le dernier item
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemCount: displayedPosts.length,
              itemBuilder: (context, index) {
                final post = displayedPosts[index];
                final imagePath = post['image'] as String;
                final isRecipe = post['isRecipe'] as bool;
                final title = post['title'] as String;
                
                return _GridItem(
                  key: ValueKey('post_${index}_${title.hashCode}'),
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

  void _openNotesPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotesPage()),
    );
  }

  void _openRecipeDetail(BuildContext context, String title, String imagePath) {
    // Créer une recette temporaire pour l'affichage
    final recipe = Recipe(
      id: 'feed_temp_${title.hashCode}',
      name: title,
      typeRepas: MealType.lunch, // Par défaut
      description: 'Recette découverte sur le fil d\'actualité.',
      ingredients: '• Ingrédients à découvrir...',
      steps: '1. Préparer les ingrédients\n2. Cuisiner avec amour\n3. Déguster !',
      calories: 450, // Valeur par défaut
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
    // Chercher une recette existante avec ce titre
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
        category: category, // Utiliser la catégorie choisie
        isFavorite: false, // Sera mis à true
      ),
    );

    // Ajouter si n'existe pas
    if (notifier.getRecipeById(existingRecipe.id) == null) {
      notifier.addRecipe(existingRecipe);
    }
    
    // Mettre à jour la catégorie si elle a changé et mettre en favori
    if (existingRecipe.category != category) {
      final updatedRecipe = existingRecipe.copyWith(category: category);
      notifier.updateRecipe(updatedRecipe);
    }
    
    // Mettre en favori si ce n'est pas déjà le cas
    final currentRecipe = notifier.getRecipeById(existingRecipe.id);
    if (currentRecipe != null && !currentRecipe.isFavorite) {
      notifier.toggleFavorite(currentRecipe.id);
    }

    Navigator.pop(context); // Fermer la modale

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Choisissez un onglet (catégorie) pour cette recette :'),
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
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_uniformBorderRadius),
            topRight: Radius.circular(_uniformBorderRadius),
          ),
          border: Border.all(
            color: _cardBgLight.withOpacity(0.5),
            width: _uniformBorderWidth,
          ),
          boxShadow: _uniformShadow,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Créer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textLight,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryOrange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(_uniformBorderRadius),
                    border: Border.all(
                      color: _primaryOrange.withOpacity(0.5),
                      width: _uniformBorderWidth,
                    ),
                    boxShadow: _uniformShadow,
                  ),
                  child: const Icon(Icons.restaurant_menu, color: Colors.white),
                ),
                title: const Text(
                  'Nouvelle recette',
                  style: TextStyle(fontWeight: FontWeight.w600, color: _textLight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddRecipePage()),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryGold.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(_uniformBorderRadius),
                    border: Border.all(
                      color: _primaryGold.withOpacity(0.5),
                      width: _uniformBorderWidth,
                    ),
                    boxShadow: _uniformShadow,
                  ),
                  child: const Icon(Icons.post_add_rounded, color: Colors.black),
                ),
                title: const Text(
                  'Nouveau post nutrition',
                  style: TextStyle(fontWeight: FontWeight.w600, color: _textLight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CreateFeedPostPage(initialType: FeedPostType.recipe)),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(_uniformBorderRadius),
                    border: Border.all(
                      color: _primaryBlue.withOpacity(0.5),
                      width: _uniformBorderWidth,
                    ),
                    boxShadow: _uniformShadow,
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.white),
                ),
                title: const Text(
                  'Nouveau post sport',
                  style: TextStyle(fontWeight: FontWeight.w600, color: _textLight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CreateFeedPostPage(initialType: FeedPostType.sport)),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGold.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(_uniformBorderRadius),
          border: Border.all(
            color: isSelected ? _primaryGold : Colors.transparent,
            width: _uniformBorderWidth,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? _primaryGold : _textMuted,
          ),
        ),
      ),
    );
  }
}

/// Item de la grille avec badge recette cliquable
class _GridItem extends StatefulWidget {
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
  State<_GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<_GridItem> {
  bool isLiked = false;
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(_uniformBorderRadius),
          border: Border.all(
            color: _cardBgLight.withOpacity(0.5),
            width: _uniformBorderWidth,
          ),
          boxShadow: _uniformShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_uniformBorderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 32,
                    ),
                  );
                },
              ),
              // Overlay gradient pour lisibilité
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
              // Badge recette cliquable - style uniforme
              if (widget.isRecipe)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: widget.onRecipeTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryGold.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(_uniformBorderRadius / 2),
                        border: Border.all(
                          color: _primaryGold.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: _uniformShadow,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🍽️',
                            style: TextStyle(fontSize: 10),
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Recette',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Actions en bas (like, comment, partager)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionIcon(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                      color: isLiked ? _primaryRed : _textLight,
                      onTap: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isLiked ? '❤️ Aimé !' : '💔 J\'aime retiré'),
                            duration: const Duration(milliseconds: 500),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    _ActionIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: () => _showComments(context),
                    ),
                    _ActionIcon(
                      icon: Icons.share_outlined,
                      onTap: () => _showShare(context),
                    ),
                    _ActionIcon(
                      icon: isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                      color: isSaved ? _primaryGold : _textLight,
                      onTap: () {
                        setState(() {
                          isSaved = !isSaved;
                        });
                        
                        // Gestion des favoris recettes pour le mode démo
                        if (widget.isRecipe) {
                          final notifier = RecipeNotifier();
                          // Chercher une recette existante avec ce titre
                          final existingRecipe = notifier.getCommunityRecipes().firstWhere(
                            (r) => r.name == widget.title,
                            orElse: () => Recipe(
                              id: 'temp_${widget.title.hashCode}',
                              name: widget.title,
                              typeRepas: MealType.lunch,
                              description: 'Recette sauvegardée depuis le fil d\'actualité',
                              ingredients: '',
                              steps: '',
                              isUserRecipe: false,
                              isSharedWithCommunity: true,
                              createdAt: DateTime.now(),
                              category: RecipeCategory.healthy,
                              isFavorite: false, // Sera inversé par toggleFavorite
                            ),
                          );
                          
                          // Ajouter ou retirer des favoris
                          if (notifier.getRecipeById(existingRecipe.id) == null) {
                            // Si elle n'existe pas encore dans le notifier, on l'ajoute
                            notifier.addRecipe(existingRecipe);
                          }
                          notifier.toggleFavorite(existingRecipe.id);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isSaved 
                              ? '📌 Enregistré dans votre Livre de Recettes !' 
                              : '📌 Retiré de votre Livre de Recettes'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            action: isSaved ? SnackBarAction(
                              label: 'OUVRIR',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RecipeBookPage()),
                                );
                              },
                            ) : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBgLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_uniformBorderRadius)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Commentaires',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textLight),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCommentItem('Alice', 'Super recette ! 😋', '2h'),
                  _buildCommentItem('Coach Bob', 'Belle exécution, continue comme ça ! 💪', '5h'),
                  _buildCommentItem('Clara', 'Je vais tester ça ce soir.', '1j'),
                  _buildCommentItem('Thomas', 'Miam !', '2j'),
                ],
              ),
            ),
            Divider(height: 1, color: _cardBg),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/images/coach1_header.png'), // Placeholder avatar
                    backgroundColor: _cardBg,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: _textLight),
                      decoration: InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_uniformBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: _cardBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Publier', style: TextStyle(color: _primaryGold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(String author, String text, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.primaries[author.hashCode % Colors.primaries.length],
            child: Text(author[0], style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textLight)),
                    const SizedBox(width: 8),
                    Text(time, style: TextStyle(color: _textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(fontSize: 14, color: _textLight)),
                const SizedBox(height: 4),
                const Text('Répondre', style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.favorite_border, size: 16, color: _textMuted),
        ],
      ),
    );
  }

  void _showShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBgLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_uniformBorderRadius)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.copy, 'Copier'),
                _buildShareOption(Icons.message_outlined, 'Message'),
                _buildShareOption(Icons.send, 'Envoyer'),
                _buildShareOption(Icons.share, 'Autre'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: _cardBgLight.withOpacity(0.5),
              width: _uniformBorderWidth,
            ),
            boxShadow: _uniformShadow,
          ),
          child: Icon(icon, size: 24, color: _textLight),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: _textLight)),
      ],
    );
  }
}

/// Icône d'action cliquable - style uniforme
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.color = _textLight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _cardBgLight.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: _cardBgLight.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: _uniformShadow,
        ),
        child: Icon(
          icon,
          size: 14,
          color: color,
        ),
      ),
    );
  }
}
