import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../models/nutrition.dart';
import '../models/shared_transformation.dart';
import 'recipe_book_page.dart';
import 'create_feed_post_page.dart'; // Sera créé/adapté
import 'add_recipe_page.dart';
import 'recipe_detail_page.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

// Palette sombre uniforme (noir/doré)
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

// Anciennes couleurs (pour compatibilité)
const Color _marronPrincipal = Color(0xFFFFC300); // Remplacé par doré
const Color _marronFonce = Color(0xFF161B22); // Remplacé par fond sombre
const Color _marronClair = Color(0xFF21262D); // Remplacé par fond clair

class RecipesCommunityPage extends StatefulWidget {
  const RecipesCommunityPage({super.key});

  @override
  State<RecipesCommunityPage> createState() => _RecipesCommunityPageState();
}

class _RecipesCommunityPageState extends State<RecipesCommunityPage>
    with SingleTickerProviderStateMixin {
  final _recipeNotifier = RecipeNotifier();
  final _transformationNotifier = SharedTransformationNotifier();
  late TabController _tabController;
  RecipeCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _recipeNotifier.addListener(_onDataChanged);
    _transformationNotifier.addListener(_onDataChanged);
    // Détecter la page pour l'Alter Ego
    AlterEgoPageDetector.setupPageContext(UkanPage.recettesCommunaute);
  }

  @override
  void dispose() {
    _recipeNotifier.removeListener(_onDataChanged);
    _transformationNotifier.removeListener(_onDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  void _useRecipeInDay(Recipe recipe) {
    // Ouvrir la page de détail de la recette
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        title: const Text(
          'Recettes & Gourmandises',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _textLight,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Livre de recettes (Favoris)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryGold.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: _primaryGold,
              ),
            ),
            tooltip: 'Mon Livre de Recettes',
            onPressed: _openRecipeBook,
          ),
          // Bouton Créer (+)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primaryGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                size: 20,
                color: _darkBg,
              ),
            ),
            tooltip: 'Créer',
            onPressed: _showCreateMenu,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _primaryGold,
          indicatorWeight: 3,
          labelColor: _primaryGold,
          unselectedLabelColor: _textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          tabs: const [
            Tab(text: 'Mes recettes'),
            Tab(text: 'Explorer'),
            Tab(text: 'Ajouter'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyRecipesTab(),
          _buildExplorerTabWithSubTabs(),
          _buildAddRecipeTab(),
        ],
      ),
    );
  }

  Widget _buildMyRecipesTab() {
    final userRecipes = _recipeNotifier.getUserRecipes();

    return SafeArea(
      top: false,
      child: Container(
        color: _darkBg,
        child: userRecipes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 64,
                      color: _textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucune recette personnelle',
                      style: TextStyle(
                        fontSize: 16,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crée ta première recette !',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = userRecipes[index];
                  return _RecipeCard(
                    recipe: recipe,
                    isUserRecipe: true,
                    isFavorite: recipe.isFavorite,
                    onToggleFavorite: () => _recipeNotifier.toggleFavorite(recipe.id),
                    onUse: () => _useRecipeInDay(recipe),
                    onEdit: () => _editRecipe(recipe),
                    onDelete: () => _deleteRecipe(recipe.id),
                    onCopyToUser: null,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCommunityTab() {
    return SafeArea(
      top: false,
      child: Container(
        color: _darkBg,
        child: Column(
          children: [
            // Filtres par catégorie - Thème sombre
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryFilterChip(
                      category: null,
                      label: 'Toutes',
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    ...RecipeCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _CategoryFilterChip(
                          category: category,
                          label: category.displayName,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedCategory = category),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Liste des recettes filtrées
            Expanded(
              child: Builder(
                builder: (context) {
                  final allRecipes = _recipeNotifier.getCommunityRecipes();
                  final filteredRecipes = _selectedCategory == null
                      ? allRecipes
                      : allRecipes.where((r) => r.category == _selectedCategory).toList();

                  if (filteredRecipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu_outlined,
                            size: 64,
                            color: _textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune recette dans cette catégorie',
                            style: TextStyle(
                              fontSize: 16,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return _RecipeCard(
                        recipe: recipe,
                        isUserRecipe: false,
                        isFavorite: recipe.isFavorite,
                        onToggleFavorite: () => _recipeNotifier.toggleFavorite(recipe.id),
                        onUse: () => _useRecipeInDay(recipe),
                        onEdit: null,
                        onDelete: null,
                        onCopyToUser: () => _copyToUserRecipes(recipe.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityFeedTab() {
    return const _CommunityFeedTab();
  }

  Widget _buildExplorerTabWithSubTabs() {
    return _ExplorerWithSubTabs(
      transformationNotifier: _transformationNotifier,
    );
  }

  Widget _buildBeforeAfterTab() {
    final transformations = _transformationNotifier.transformations;

    return SafeArea(
      top: false,
      child: Container(
        color: _darkBg,
        child: transformations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      size: 64,
                      color: _textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucune transformation partagée',
                      style: TextStyle(
                        fontSize: 16,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sois le premier à partager ta transformation !',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _tabController.animateTo(3), // Aller à l'onglet Ajouter
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Partager ma transformation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGold,
                        foregroundColor: _darkBg,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transformations.length,
                itemBuilder: (context, index) {
                  final t = transformations[index];
                  return _BeforeAfterCard(
                    transformation: t,
                    onLike: () => _transformationNotifier.toggleLike(t.id),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildAddRecipeTab() {
    return SafeArea(
      top: false,
      child: Container(
        color: _darkBg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte Ajouter une recette
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _cardBg,
                      _primaryGold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _primaryGold.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: _primaryGold,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Créer une nouvelle recette',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Partage tes recettes favorites avec la communauté',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _addNewRecipe(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          'Ajouter une recette',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGold,
                          foregroundColor: _darkBg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Carte Partager ma transformation Avant/Après
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _cardBg,
                      Colors.green.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.compare_arrows,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Partager ma transformation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inspire la communauté avec ton Avant/Après',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddTransformationDialog(),
                        icon: const Icon(Icons.add_photo_alternate, size: 18),
                        label: const Text(
                          'Ajouter un Avant/Après',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
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

  void _showAddTransformationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTransformationSheet(
        onAdd: (transformation) {
          _transformationNotifier.addTransformation(transformation);
          Navigator.pop(context);
          // Aller à l'onglet Avant/Après
          _tabController.animateTo(2);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Transformation partagée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _openRecipeBook() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RecipeBookPage(),
      ),
    );
  }

  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
                  color: _borderColor,
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
                    color: _primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant_menu, color: _primaryGold),
                ),
                title: const Text(
                  'Nouvelle recette',
                  style: TextStyle(fontWeight: FontWeight.w600, color: _textLight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addNewRecipe();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.post_add_rounded, color: _primaryGold),
                ),
                title: const Text(
                  'Nouveau post nutrition',
                  style: TextStyle(fontWeight: FontWeight.w600, color: _textLight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addNewPost();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateFeedPostPage(),
      ),
    );
  }

  void _addNewRecipe() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddRecipePage(),
      ),
    );
  }

  void _editRecipe(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddRecipePage(recipeToEdit: recipe),
      ),
    );
  }

  void _deleteRecipe(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la recette'),
        content: const Text('Es-tu sûr de vouloir supprimer cette recette ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _recipeNotifier.removeRecipe(id);
              Navigator.of(context).pop();
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

  void _copyToUserRecipes(String recipeId) {
    _recipeNotifier.copyToUserRecipes(recipeId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recette ajoutée à mes recettes'),
        backgroundColor: _marronPrincipal,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isUserRecipe;
  final bool isFavorite; // Nouveau
  final VoidCallback? onUse;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCopyToUser;
  final VoidCallback? onToggleFavorite; // Nouveau

  const _RecipeCard({
    required this.recipe,
    required this.isUserRecipe,
    this.isFavorite = false,
    this.onUse,
    this.onEdit,
    this.onDelete,
    this.onCopyToUser,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image ou placeholder
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: _marronClair.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    recipe.displayImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
                ),
              ),
              // Bouton favori
              if (onToggleFavorite != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite ? const Color(0xFFFFC300) : Colors.black54,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textLight,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isUserRecipe
                                ? _primaryGold.withOpacity(0.15)
                                : Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isUserRecipe ? 'Perso' : 'Communauté',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isUserRecipe ? _primaryGold : Colors.blue.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(recipe.category).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            recipe.category.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(recipe.category),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _getMealTypeIcon(recipe.typeRepas),
                      size: 16,
                      color: _textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.typeRepas.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                      ),
                    ),
                    if (recipe.calories != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.calories} kcal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
                if (recipe.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (recipe.calories != null ||
                    recipe.proteines != null ||
                    recipe.glucides != null ||
                    recipe.lipides != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (recipe.proteines != null)
                        _MacroChip(
                          label: 'P',
                          value: '${recipe.proteines}g',
                          color: Colors.green,
                        ),
                      if (recipe.glucides != null) ...[
                        const SizedBox(width: 8),
                        _MacroChip(
                          label: 'G',
                          value: '${recipe.glucides}g',
                          color: Colors.blue,
                        ),
                      ],
                      if (recipe.lipides != null) ...[
                        const SizedBox(width: 8),
                        _MacroChip(
                          label: 'L',
                          value: '${recipe.lipides}g',
                          color: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onUse != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onUse,
                          icon: const Icon(Icons.restaurant, size: 18),
                          label: const Text(
                            'Utiliser',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGold,
                            foregroundColor: _darkBg,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    if (onCopyToUser != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCopyToUser,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Ajouter',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryGold,
                            side: const BorderSide(color: _primaryGold),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (isUserRecipe && (onEdit != null || onDelete != null)) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: _textMuted),
                        color: _cardBgLight,
                        onSelected: (value) {
                          if (value == 'edit' && onEdit != null) {
                            onEdit!();
                          } else if (value == 'delete' && onDelete != null) {
                            onDelete!();
                          }
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18, color: _primaryGold),
                                  SizedBox(width: 8),
                                  Text('Modifier', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant_menu,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.snack:
        return Icons.cookie;
      case MealType.dinner:
        return Icons.dinner_dining;
    }
  }

  static Color _getCategoryColor(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.weightLoss:
        return Colors.green;
      case RecipeCategory.muscleGain:
        return Colors.blue;
      case RecipeCategory.energy:
        return Colors.orange;
      case RecipeCategory.healthy:
        return Colors.teal;
      case RecipeCategory.quick:
        return Colors.purple;
      case RecipeCategory.vegetarian:
        return Colors.lightGreen;
      case RecipeCategory.other:
        return Colors.grey;
    }
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final RecipeCategory? category;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.category,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: _primaryGold.withOpacity(0.2),
      backgroundColor: _cardBgLight,
      checkmarkColor: _primaryGold,
      labelStyle: TextStyle(
        color: isSelected ? _primaryGold : _textMuted,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? _primaryGold : _borderColor,
        width: 1,
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}


/// Onglet "Fil de la communauté" - Feed visuel style Instagram/Pinterest
class _CommunityFeedTab extends StatefulWidget {
  const _CommunityFeedTab();

  @override
  State<_CommunityFeedTab> createState() => _CommunityFeedTabState();
}

class _CommunityFeedTabState extends State<_CommunityFeedTab> {
  final _recipeNotifier = RecipeNotifier();
  final Set<String> _favorites = {};
  String? _selectedFilter;

  // Filtres disponibles
  static Map<String, FilterRule> get _filters => {
    'Perte de poids': FilterRule(
      name: 'Perte de poids',
      matches: (recipe) => recipe.calories != null && recipe.calories! < 450,
    ),
    'Prise de masse': FilterRule(
      name: 'Prise de masse',
      matches: (recipe) => recipe.calories != null && recipe.calories! > 400 && (recipe.proteines ?? 0) > 25,
    ),
    'Hyperprotéiné': FilterRule(
      name: 'Hyperprotéiné',
      matches: (recipe) => (recipe.proteines ?? 0) > 30,
    ),
    'Low calories': FilterRule(
      name: 'Low calories',
      matches: (recipe) => recipe.calories != null && recipe.calories! < 350,
    ),
    'Végétarien': FilterRule(
      name: 'Végétarien',
      matches: (recipe) => recipe.category == RecipeCategory.vegetarian,
    ),
    'Rapide': FilterRule(
      name: 'Rapide',
      matches: (recipe) => recipe.category == RecipeCategory.quick,
    ),
    'Sans gluten': FilterRule(
      name: 'Sans gluten',
      matches: (recipe) => !recipe.allergens.contains('gluten'),
    ),
    'Sans lactose': FilterRule(
      name: 'Sans lactose',
      matches: (recipe) => !recipe.allergens.contains('lactose'),
    ),
  };

  @override
  void initState() {
    super.initState();
    _recipeNotifier.addListener(_onDataChanged);
    _initializeDemoRecipes();
  }

  @override
  void dispose() {
    _recipeNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _initializeDemoRecipes() {
    // Ajouter des recettes DEMO avec les vraies images
    final demoRecipes = _getDemoRecipes();
    for (final recipe in demoRecipes) {
      // Vérifier si la recette n'existe pas déjà
      if (_recipeNotifier.getRecipeById(recipe.id) == null) {
        _recipeNotifier.addRecipe(recipe);
      }
    }
  }

  List<Recipe> _getDemoRecipes() {
    return [
      Recipe(
        id: 'demo_feed_1',
        name: 'Pâtes bolognaise maison',
        typeRepas: MealType.dinner,
        description: 'Un classique italien réconfortant et savoureux',
        ingredients: '• 200g de pâtes\n• 150g de viande hachée\n• 1 boîte de tomates pelées\n• Oignon, ail\n• Basilic',
        steps: '1. Faire revenir la viande\n2. Ajouter les tomates\n3. Laisser mijoter\n4. Servir sur les pâtes',
        calories: 520,
        proteines: 28,
        glucides: 65,
        lipides: 18,
        allergens: ['gluten'],
        imagePath: 'assets/images/foodscan/pates_bolo_scan.png',
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'demo_user_1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        category: RecipeCategory.healthy,
      ),
      Recipe(
        id: 'demo_feed_2',
        name: 'Hamburger + frites',
        typeRepas: MealType.lunch,
        description: 'Burger gourmand avec frites croustillantes',
        ingredients: '• Pain à burger\n• Steak haché 150g\n• Fromage\n• Salade, tomate\n• Frites',
        steps: '1. Cuire le steak\n2. Assembler le burger\n3. Servir avec frites',
        calories: 680,
        proteines: 32,
        glucides: 75,
        lipides: 28,
        allergens: ['gluten', 'lactose'],
        imagePath: 'assets/images/foodscan/burger_scan.png',
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'demo_user_2',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        category: RecipeCategory.other,
      ),
      Recipe(
        id: 'demo_feed_3',
        name: 'Salade poulet grillé',
        typeRepas: MealType.lunch,
        description: 'Salade complète et protéinée',
        ingredients: '• 150g de blanc de poulet\n• Salade verte\n• Tomates cerises\n• Concombre\n• Avocat',
        steps: '1. Griller le poulet\n2. Couper les légumes\n3. Assembler la salade',
        calories: 380,
        proteines: 35,
        glucides: 15,
        lipides: 18,
        allergens: [],
        imagePath: 'assets/images/foodscan/salade_poulet_scan.png',
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'demo_user_3',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        category: RecipeCategory.weightLoss,
      ),
      Recipe(
        id: 'demo_feed_4',
        name: 'Pizza mozzarella',
        typeRepas: MealType.dinner,
        description: 'Pizza classique mozzarella et basilic',
        ingredients: '• Pâte à pizza\n• Sauce tomate\n• Mozzarella\n• Basilic frais',
        steps: '1. Étaler la pâte\n2. Ajouter la sauce et le fromage\n3. Cuire au four\n4. Garnir de basilic',
        calories: 450,
        proteines: 20,
        glucides: 55,
        lipides: 18,
        allergens: ['gluten', 'lactose'],
        imagePath: 'assets/images/foodscan/pizza_scan.png',
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'demo_user_4',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        category: RecipeCategory.other,
      ),
      Recipe(
        id: 'demo_feed_5',
        name: 'Plat maison varié',
        typeRepas: MealType.dinner,
        description: 'Assiette équilibrée avec viande et légumes',
        ingredients: '• Viande grillée\n• Légumes de saison\n• Riz ou pommes de terre',
        steps: '1. Cuire la viande\n2. Préparer les légumes\n3. Servir ensemble',
        calories: 480,
        proteines: 30,
        glucides: 45,
        lipides: 20,
        allergens: [],
        imagePath: 'assets/images/foodscan/plat_maison_scan.png',
        isUserRecipe: false,
        isSharedWithCommunity: true,
        ownerUserId: 'demo_user_5',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        category: RecipeCategory.healthy,
      ),
    ];
  }

  List<Recipe> _getFilteredRecipes() {
    final allRecipes = _recipeNotifier.getCommunityRecipes();
    
    if (_selectedFilter == null) {
      return allRecipes..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    final filterRule = _filters[_selectedFilter!];
    if (filterRule == null) {
      return allRecipes..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return allRecipes.where(filterRule.matches).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _toggleFavorite(String recipeId) {
    setState(() {
      if (_favorites.contains(recipeId)) {
        _favorites.remove(recipeId);
      } else {
        _favorites.add(recipeId);
      }
    });
  }

  void _useRecipeToday(Recipe recipe) {
    try {
      if (recipe.calories != null) {
        final mealEntry = MealEntry(
          id: 'recipe_${DateTime.now().millisecondsSinceEpoch}',
          date: DateTime.now(),
          type: recipe.typeRepas,
          title: recipe.name,
          calories: recipe.calories!,
          protein: recipe.proteines ?? 0,
          carbs: recipe.glucides ?? 0,
          fats: recipe.lipides ?? 0,
        );

        NutritionNotifier().addMeal(mealEntry);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recipe.name} ajoutée à ta journée (mode démo)'),
            backgroundColor: _marronPrincipal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _getFilteredRecipes();

    return SafeArea(
      top: false,
      child: Container(
        color: _darkBg,
        child: Column(
          children: [
            // Filtres (chips) en haut - Thème sombre
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FeedFilterChip(
                      label: 'Toutes',
                      isSelected: _selectedFilter == null,
                      onTap: () => setState(() => _selectedFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ..._filters.keys.map((filterName) {
                      final isSelected = _selectedFilter == filterName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FeedFilterChip(
                          label: filterName,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedFilter = filterName),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Feed visuel (grille 2 colonnes)
            Expanded(
              child: recipes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu_outlined,
                            size: 64,
                            color: _textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune recette dans cette catégorie',
                            style: TextStyle(
                              fontSize: 16,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _FeedRecipeCard(
                          recipe: recipe,
                          isFavorite: _favorites.contains(recipe.id),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailPage(recipe: recipe),
                              ),
                            );
                          },
                          onFavorite: () => _toggleFavorite(recipe.id),
                          onUseToday: () => _useRecipeToday(recipe),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Règle de filtre
class FilterRule {
  final String name;
  final bool Function(Recipe) matches;

  const FilterRule({
    required this.name,
    required this.matches,
  });
}

/// Chip de filtre pour le feed
class _FeedFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: _primaryGold.withOpacity(0.2),
      backgroundColor: _cardBgLight,
      checkmarkColor: _primaryGold,
      labelStyle: TextStyle(
        color: isSelected ? _primaryGold : _textMuted,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? _primaryGold : _borderColor,
        width: 1,
      ),
    );
  }
}

/// Carte de recette pour le feed (style Instagram/Pinterest)
class _FeedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onUseToday;

  const _FeedRecipeCard({
    required this.recipe,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.onUseToday,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      recipe.displayImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    ),
                  ),
                  // Overlay pour vidéo si présente
                  if (recipe.videoUrl != null && recipe.videoUrl!.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  // Bouton favori
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () {
                        onFavorite();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Informations de la recette
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nom et type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getMealTypeIcon(recipe.typeRepas),
                              size: 12,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.typeRepas.displayName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Calories et tags
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipe.calories != null)
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: Colors.orange.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.calories} kcal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade400,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        // Tag catégorie
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(recipe.category).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            recipe.category.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(recipe.category),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Bouton "Utiliser aujourd'hui"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onUseToday,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGold,
                          foregroundColor: _darkBg,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '+ Aujourd\'hui',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: _cardBgLight,
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 48,
          color: _textMuted,
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.snack:
        return Icons.cookie;
      case MealType.dinner:
        return Icons.dinner_dining;
    }
  }

  Color _getCategoryColor(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.weightLoss:
        return Colors.green;
      case RecipeCategory.muscleGain:
        return Colors.blue;
      case RecipeCategory.energy:
        return Colors.orange;
      case RecipeCategory.healthy:
        return Colors.teal;
      case RecipeCategory.quick:
        return Colors.purple;
      case RecipeCategory.vegetarian:
        return Colors.lightGreen;
      case RecipeCategory.other:
        return Colors.grey;
    }
  }
}

/// Carte Avant/Après pour afficher une transformation
class _BeforeAfterCard extends StatelessWidget {
  final SharedTransformation transformation;
  final VoidCallback onLike;

  const _BeforeAfterCard({
    required this.transformation,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final weightDiff = transformation.weightDifference;
    final isWeightLoss = weightDiff != null && weightDiff < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec avatar et nom
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _cardBgLight,
                  backgroundImage: transformation.userAvatarPath != null
                      ? AssetImage(transformation.userAvatarPath!)
                      : null,
                  child: transformation.userAvatarPath == null
                      ? Text(
                          transformation.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: _primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transformation.userName,
                        style: const TextStyle(
                          color: _textLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${transformation.durationDays} jours de transformation',
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de perte/prise de poids
                if (weightDiff != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isWeightLoss
                          ? Colors.green.withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isWeightLoss
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWeightLoss ? Icons.trending_down : Icons.trending_up,
                          size: 14,
                          color: isWeightLoss ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${weightDiff.abs().toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isWeightLoss ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Images Avant/Après côte à côte
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Image AVANT
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildTransformationImage(
                        transformation.beforeImagePath,
                        transformation.beforeImageBytes,
                      ),
                      // Label AVANT
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'AVANT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Poids AVANT
                      if (transformation.beforeWeight != null)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${transformation.beforeWeight!.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                // Image APRÈS
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildTransformationImage(
                        transformation.afterImagePath,
                        transformation.afterImageBytes,
                      ),
                      // Label APRÈS
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'APRÈS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Poids APRÈS
                      if (transformation.afterWeight != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${transformation.afterWeight!.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Note/description
          if (transformation.note != null && transformation.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                transformation.note!,
                style: const TextStyle(
                  color: _textLight,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

          // Actions (like, commentaires)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // Like
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        transformation.isLikedByMe
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 22,
                        color: transformation.isLikedByMe
                            ? Colors.red
                            : _textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${transformation.likes}',
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Commentaires
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: _textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${transformation.comments}',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Date de partage
                Text(
                  _formatDate(transformation.sharedAt),
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationImage(String? path, Uint8List? bytes) {
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    }
    if (path != null) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: _cardBgLight,
      child: const Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: _textMuted,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Il y a ${diff.inMinutes} min';
      }
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Sheet pour ajouter une transformation Avant/Après
class _AddTransformationSheet extends StatefulWidget {
  final Function(SharedTransformation) onAdd;

  const _AddTransformationSheet({required this.onAdd});

  @override
  State<_AddTransformationSheet> createState() => _AddTransformationSheetState();
}

class _AddTransformationSheetState extends State<_AddTransformationSheet> {
  Uint8List? _beforeImageBytes;
  Uint8List? _afterImageBytes;
  final _beforeWeightController = TextEditingController();
  final _afterWeightController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _beforeDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _afterDate = DateTime.now();

  @override
  void dispose() {
    _beforeWeightController.dispose();
    _afterWeightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBefore) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (isBefore) {
          _beforeImageBytes = bytes;
        } else {
          _afterImageBytes = bytes;
        }
      });
    }
  }

  Future<void> _selectDate(bool isBefore) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBefore ? _beforeDate : _afterDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _primaryGold,
              onPrimary: _darkBg,
              surface: _cardBg,
              onSurface: _textLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBefore) {
          _beforeDate = picked;
        } else {
          _afterDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_beforeImageBytes == null && _afterImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoute au moins une photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transformation = SharedTransformation(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'Moi', // TODO: Récupérer le vrai nom de l'utilisateur
      beforeImageBytes: _beforeImageBytes,
      afterImageBytes: _afterImageBytes,
      beforeWeight: double.tryParse(_beforeWeightController.text),
      afterWeight: double.tryParse(_afterWeightController.text),
      beforeDate: _beforeDate,
      afterDate: _afterDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      sharedAt: DateTime.now(),
    );

    widget.onAdd(transformation);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Titre
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Partager ma transformation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textLight,
              ),
            ),
          ),
          const Divider(color: _borderColor),
          
          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photos Avant/Après
                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Photo AVANT
                      Expanded(
                        child: _buildPhotoSelector(
                          label: 'AVANT',
                          color: Colors.red,
                          bytes: _beforeImageBytes,
                          onTap: () => _pickImage(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Photo APRÈS
                      Expanded(
                        child: _buildPhotoSelector(
                          label: 'APRÈS',
                          color: Colors.green,
                          bytes: _afterImageBytes,
                          onTap: () => _pickImage(false),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Dates
                  const Text(
                    'Dates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateSelector(
                          label: 'Date AVANT',
                          date: _beforeDate,
                          onTap: () => _selectDate(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateSelector(
                          label: 'Date APRÈS',
                          date: _afterDate,
                          onTap: () => _selectDate(false),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Poids
                  const Text(
                    'Poids (optionnel)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _beforeWeightController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: _textLight),
                          decoration: InputDecoration(
                            labelText: 'Poids AVANT (kg)',
                            labelStyle: const TextStyle(color: _textMuted),
                            filled: true,
                            fillColor: _cardBgLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _afterWeightController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: _textLight),
                          decoration: InputDecoration(
                            labelText: 'Poids APRÈS (kg)',
                            labelStyle: const TextStyle(color: _textMuted),
                            filled: true,
                            fillColor: _cardBgLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Note
                  const Text(
                    'Message (optionnel)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: const TextStyle(color: _textLight),
                    decoration: InputDecoration(
                      hintText: 'Raconte ton parcours, tes conseils...',
                      hintStyle: const TextStyle(color: _textMuted),
                      filled: true,
                      fillColor: _cardBgLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Bouton Publier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.share),
                      label: const Text(
                        'Partager avec la communauté',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildPhotoSelector({
    required String label,
    required Color color,
    required Uint8List? bytes,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: bytes != null ? color : _borderColor,
            width: bytes != null ? 2 : 1,
          ),
        ),
        child: bytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.memory(bytes, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 32, color: color),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ajouter photo',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: _primaryGold),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget Explorer avec sous-onglets Fil et Avant/Après
class _ExplorerWithSubTabs extends StatefulWidget {
  final SharedTransformationNotifier transformationNotifier;

  const _ExplorerWithSubTabs({
    required this.transformationNotifier,
  });

  @override
  State<_ExplorerWithSubTabs> createState() => _ExplorerWithSubTabsState();
}

class _ExplorerWithSubTabsState extends State<_ExplorerWithSubTabs>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sous-onglets Fil / Avant/Après
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: _cardBgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: TabBar(
            controller: _subTabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: _primaryGold,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: _darkBg,
            unselectedLabelColor: _textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view, size: 16),
                    SizedBox(width: 6),
                    Text('Fil'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.compare_arrows, size: 16),
                    SizedBox(width: 6),
                    Text('Avant/Après'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Contenu des sous-onglets
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              // Onglet Fil - Grille 3 colonnes
              const _CommunityFeedTab(),
              // Onglet Avant/Après - Transformations
              _buildBeforeAfterContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBeforeAfterContent() {
    final transformations = widget.transformationNotifier.transformations;

    return Container(
      color: _darkBg,
      child: transformations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: 64,
                    color: _textMuted.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune transformation partagée',
                    style: TextStyle(
                      fontSize: 16,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sois le premier à partager ta transformation !',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transformations.length,
              itemBuilder: (context, index) {
                final t = transformations[index];
                return _BeforeAfterCard(
                  transformation: t,
                  onLike: () {
                    widget.transformationNotifier.toggleLike(t.id);
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}
