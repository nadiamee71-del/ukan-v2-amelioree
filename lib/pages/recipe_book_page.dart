import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'recipe_detail_page.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MON LIVRE DE RECETTES - Design Professionnel Noir & Or
// ═══════════════════════════════════════════════════════════════════════════

// Palette noir/or
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);
const Color _accentOrange = Color(0xFFFF9F43);
const Color _accentGreen = Color(0xFF4ECDC4);
const Color _accentBlue = Color(0xFF58A6FF);

class RecipeBookPage extends StatefulWidget {
  final bool showAppBar;
  
  const RecipeBookPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<RecipeBookPage> createState() => _RecipeBookPageState();
}

class _RecipeBookPageState extends State<RecipeBookPage> {
  final _recipeNotifier = RecipeNotifier();
  RecipeCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _recipeNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _recipeNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final favoriteRecipes = _recipeNotifier.getFavoriteRecipes();
    final filteredRecipes = _selectedCategory == null
        ? favoriteRecipes
        : favoriteRecipes.where((r) => r.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryGold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded, color: _primaryGold, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mon Livre de Recettes',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _textLight,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (favoriteRecipes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark, color: _primaryGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${favoriteRecipes.length}',
                    style: const TextStyle(
                      color: _primaryGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ) : null,
      body: Column(
        children: [
          // Filtres par catégorie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _cardBg,
              border: Border(
                bottom: BorderSide(color: _borderColor, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _BookFilterChip(
                    label: 'Toutes',
                    icon: Icons.grid_view_rounded,
                    isSelected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: 10),
                  ...RecipeCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _BookFilterChip(
                        label: category.displayName,
                        icon: _getCategoryIcon(category),
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedCategory = category),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Liste des favoris
          Expanded(
            child: filteredRecipes.isEmpty
                ? _buildEmptyState(favoriteRecipes.isEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return _BookRecipeCard(
                        recipe: recipe,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                        onToggleFavorite: () {
                          _recipeNotifier.toggleFavorite(recipe.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.weightLoss:
        return Icons.trending_down;
      case RecipeCategory.muscleGain:
        return Icons.fitness_center;
      case RecipeCategory.energy:
        return Icons.bolt;
      case RecipeCategory.healthy:
        return Icons.balance;
      case RecipeCategory.quick:
        return Icons.timer;
      case RecipeCategory.vegetarian:
        return Icons.eco;
      case RecipeCategory.other:
        return Icons.restaurant;
    }
  }

  Widget _buildEmptyState(bool isCompletelyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: _borderColor, width: 2),
              ),
              child: Icon(
                isCompletelyEmpty ? Icons.bookmark_border_rounded : Icons.filter_list_off,
                size: 60,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isCompletelyEmpty
                  ? 'Ton livre de recettes est vide'
                  : 'Aucune recette dans cette catégorie',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isCompletelyEmpty
                  ? 'Ajoute des favoris depuis la communauté\npour les retrouver ici !'
                  : 'Essaie une autre catégorie ou\najoute de nouvelles recettes',
              style: const TextStyle(
                fontSize: 14,
                color: _textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (isCompletelyEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.explore, size: 20),
                label: const Text('Explorer les recettes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGold,
                  foregroundColor: _darkBg,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BookFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGold : _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryGold : _borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryGold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? _darkBg : _textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _darkBg : _textLight,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _BookRecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: Container(
                width: 110,
                height: 110,
                color: _cardBgLight,
                child: Image.asset(
                  recipe.displayImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _cardBgLight,
                    child: const Icon(Icons.restaurant, color: _textMuted, size: 40),
                  ),
                ),
              ),
            ),
            // Infos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onToggleFavorite,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _primaryGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.bookmark,
                              color: _primaryGold,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accentGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recipe.category.displayName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildInfoBadge(
                          Icons.local_fire_department,
                          '${recipe.calories ?? 0} kcal',
                          _accentOrange,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoBadge(
                          Icons.people,
                          '${recipe.portions} pers.',
                          _accentBlue,
                        ),
                      ],
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

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
