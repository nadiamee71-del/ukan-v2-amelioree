import 'package:flutter/material.dart';
import '../feed/explorer_feed_widget.dart';
import '../pages/recipe_book_page.dart';

// Palette de couleurs
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

/// Page "Recettes et gourmandises" avec onglet "Fil" (Explorer)
class RecipesFeedPage extends StatefulWidget {
  const RecipesFeedPage({super.key});

  @override
  State<RecipesFeedPage> createState() => _RecipesFeedPageState();
}

class _RecipesFeedPageState extends State<RecipesFeedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recettes et gourmandises',
          style: TextStyle(
            color: _textLight,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _primaryGold,
          indicatorWeight: 3,
          labelColor: _primaryGold,
          unselectedLabelColor: _textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(
              icon: Icon(Icons.explore),
              text: 'Explorer',
            ),
            Tab(
              icon: Icon(Icons.menu_book),
              text: 'Mon Livre',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet "Fil" - Contenu Explorer
          const ExplorerFeedWidget(
            showHeader: false, // Pas de header car on a déjà les tabs
            showRecipeBookButton: false, // Pas de bouton car on a l'onglet "Mon Livre"
          ),
          // Onglet "Mon Livre" - Page des recettes
          const RecipeBookPage(showAppBar: false),
        ],
      ),
    );
  }
}

