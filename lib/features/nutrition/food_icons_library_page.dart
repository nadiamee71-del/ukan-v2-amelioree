import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Palette sombre uniforme (noir/doré)
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

/// Catégorie d'icône alimentaire
class FoodIconCategory {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final List<FoodIcon> icons;

  const FoodIconCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.icons,
  });
}

/// Icône alimentaire
class FoodIcon {
  final String emoji;
  final String name;
  final String? description;
  bool isCustom;

  FoodIcon({
    required this.emoji,
    required this.name,
    this.description,
    this.isCustom = false,
  });
}

/// Bibliothèque d'icônes alimentaires
class FoodIconsLibraryPage extends StatefulWidget {
  final bool selectMode; // Si true, retourne l'icône sélectionnée
  
  const FoodIconsLibraryPage({
    super.key,
    this.selectMode = false,
  });

  @override
  State<FoodIconsLibraryPage> createState() => _FoodIconsLibraryPageState();
}

class _FoodIconsLibraryPageState extends State<FoodIconsLibraryPage> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  
  // Icônes personnalisées ajoutées par l'utilisateur
  final List<FoodIcon> _customIcons = [];

  // Catégories d'icônes prédéfinies
  late final List<FoodIconCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _buildCategories();
  }

  List<FoodIconCategory> _buildCategories() {
    return [
      FoodIconCategory(
        id: 'proteins',
        name: 'Protéines',
        emoji: '🥩',
        color: Colors.red,
        icons: [
          FoodIcon(emoji: '🍗', name: 'Poulet', description: 'Blanc de poulet, cuisse'),
          FoodIcon(emoji: '🥩', name: 'Bœuf', description: 'Steak, viande hachée'),
          FoodIcon(emoji: '🍖', name: 'Porc', description: 'Côtelette, jambon'),
          FoodIcon(emoji: '🦃', name: 'Dinde', description: 'Escalope, rôti'),
          FoodIcon(emoji: '🐑', name: 'Agneau', description: 'Côtelette, gigot'),
          FoodIcon(emoji: '🐟', name: 'Poisson', description: 'Saumon, cabillaud, thon'),
          FoodIcon(emoji: '🦐', name: 'Crevettes', description: 'Crevettes, gambas'),
          FoodIcon(emoji: '🦑', name: 'Calamars', description: 'Calamars, poulpe'),
          FoodIcon(emoji: '🦀', name: 'Crabe', description: 'Crabe, homard'),
          FoodIcon(emoji: '🦞', name: 'Homard', description: 'Homard, langouste'),
          FoodIcon(emoji: '🥚', name: 'Œufs', description: 'Œufs entiers'),
          FoodIcon(emoji: '🍳', name: 'Œuf au plat', description: 'Œuf cuit'),
          FoodIcon(emoji: '🥓', name: 'Bacon', description: 'Bacon, lardons'),
          FoodIcon(emoji: '🌭', name: 'Saucisse', description: 'Saucisse, hot-dog'),
        ],
      ),
      FoodIconCategory(
        id: 'carbs',
        name: 'Féculents',
        emoji: '🍝',
        color: Colors.amber,
        icons: [
          FoodIcon(emoji: '🍝', name: 'Pâtes', description: 'Spaghetti, penne, fusilli'),
          FoodIcon(emoji: '🍚', name: 'Riz', description: 'Riz blanc, basmati, complet'),
          FoodIcon(emoji: '🥖', name: 'Pain', description: 'Baguette, pain de mie'),
          FoodIcon(emoji: '🥐', name: 'Croissant', description: 'Viennoiseries'),
          FoodIcon(emoji: '🥯', name: 'Bagel', description: 'Bagel, pain rond'),
          FoodIcon(emoji: '🫓', name: 'Galette', description: 'Tortilla, wrap'),
          FoodIcon(emoji: '🥞', name: 'Pancakes', description: 'Crêpes, pancakes'),
          FoodIcon(emoji: '🧇', name: 'Gaufres', description: 'Gaufres'),
          FoodIcon(emoji: '🥔', name: 'Pomme de terre', description: 'Patate, frites'),
          FoodIcon(emoji: '🍠', name: 'Patate douce', description: 'Patate douce'),
          FoodIcon(emoji: '🌽', name: 'Maïs', description: 'Épi de maïs, pop-corn'),
          FoodIcon(emoji: '🍞', name: 'Pain de mie', description: 'Toast, sandwich'),
        ],
      ),
      FoodIconCategory(
        id: 'cereals',
        name: 'Céréales',
        emoji: '🥣',
        color: Colors.brown,
        icons: [
          FoodIcon(emoji: '🥣', name: 'Flocons', description: 'Flocons d\'avoine, muesli'),
          FoodIcon(emoji: '🌾', name: 'Blé', description: 'Blé, semoule'),
          FoodIcon(emoji: '🫘', name: 'Légumineuses', description: 'Lentilles, pois chiches'),
          FoodIcon(emoji: '🥜', name: 'Cacahuètes', description: 'Arachides'),
          FoodIcon(emoji: '🌰', name: 'Châtaignes', description: 'Marrons'),
          FoodIcon(emoji: '🥗', name: 'Quinoa', description: 'Quinoa, boulgour'),
        ],
      ),
      FoodIconCategory(
        id: 'fruits',
        name: 'Fruits',
        emoji: '🍎',
        color: Colors.green,
        icons: [
          FoodIcon(emoji: '🍎', name: 'Pomme', description: 'Pomme rouge'),
          FoodIcon(emoji: '🍏', name: 'Pomme verte', description: 'Granny Smith'),
          FoodIcon(emoji: '🍌', name: 'Banane', description: 'Banane'),
          FoodIcon(emoji: '🍊', name: 'Orange', description: 'Orange, clémentine'),
          FoodIcon(emoji: '🍋', name: 'Citron', description: 'Citron jaune'),
          FoodIcon(emoji: '🍋‍🟩', name: 'Citron vert', description: 'Lime'),
          FoodIcon(emoji: '🍇', name: 'Raisin', description: 'Raisin'),
          FoodIcon(emoji: '🍓', name: 'Fraise', description: 'Fraises'),
          FoodIcon(emoji: '🫐', name: 'Myrtilles', description: 'Bleuets'),
          FoodIcon(emoji: '🍒', name: 'Cerise', description: 'Cerises'),
          FoodIcon(emoji: '🍑', name: 'Pêche', description: 'Pêche, nectarine'),
          FoodIcon(emoji: '🥭', name: 'Mangue', description: 'Mangue'),
          FoodIcon(emoji: '🍍', name: 'Ananas', description: 'Ananas'),
          FoodIcon(emoji: '🥝', name: 'Kiwi', description: 'Kiwi'),
          FoodIcon(emoji: '🍈', name: 'Melon', description: 'Melon, cantaloup'),
          FoodIcon(emoji: '🍉', name: 'Pastèque', description: 'Pastèque'),
          FoodIcon(emoji: '🍐', name: 'Poire', description: 'Poire'),
          FoodIcon(emoji: '🥥', name: 'Noix de coco', description: 'Coco'),
          FoodIcon(emoji: '🫒', name: 'Olive', description: 'Olives'),
        ],
      ),
      FoodIconCategory(
        id: 'vegetables',
        name: 'Légumes',
        emoji: '🥦',
        color: Colors.lightGreen,
        icons: [
          FoodIcon(emoji: '🥦', name: 'Brocoli', description: 'Brocoli'),
          FoodIcon(emoji: '🥕', name: 'Carotte', description: 'Carottes'),
          FoodIcon(emoji: '🥬', name: 'Salade', description: 'Laitue, roquette'),
          FoodIcon(emoji: '🍅', name: 'Tomate', description: 'Tomates'),
          FoodIcon(emoji: '🥒', name: 'Concombre', description: 'Concombre'),
          FoodIcon(emoji: '🧅', name: 'Oignon', description: 'Oignon'),
          FoodIcon(emoji: '🧄', name: 'Ail', description: 'Ail'),
          FoodIcon(emoji: '🌶️', name: 'Piment', description: 'Piment, poivron'),
          FoodIcon(emoji: '🫑', name: 'Poivron', description: 'Poivron vert'),
          FoodIcon(emoji: '🥑', name: 'Avocat', description: 'Avocat'),
          FoodIcon(emoji: '🍆', name: 'Aubergine', description: 'Aubergine'),
          FoodIcon(emoji: '🥜', name: 'Haricots', description: 'Haricots verts'),
          FoodIcon(emoji: '🍄', name: 'Champignon', description: 'Champignons'),
          FoodIcon(emoji: '🌿', name: 'Herbes', description: 'Basilic, persil'),
          FoodIcon(emoji: '🥗', name: 'Salade composée', description: 'Mix légumes'),
        ],
      ),
      FoodIconCategory(
        id: 'fats',
        name: 'Lipides',
        emoji: '🧈',
        color: Colors.orange,
        icons: [
          FoodIcon(emoji: '🧈', name: 'Beurre', description: 'Beurre'),
          FoodIcon(emoji: '🫒', name: 'Huile d\'olive', description: 'Huile végétale'),
          FoodIcon(emoji: '🥜', name: 'Beurre de cacahuète', description: 'Pâte d\'arachide'),
          FoodIcon(emoji: '🥑', name: 'Avocat', description: 'Graisse saine'),
          FoodIcon(emoji: '🧀', name: 'Fromage gras', description: 'Fromage'),
          FoodIcon(emoji: '🥓', name: 'Lard', description: 'Graisse animale'),
          FoodIcon(emoji: '🌰', name: 'Noix', description: 'Noix, amandes'),
          FoodIcon(emoji: '🫘', name: 'Graines', description: 'Graines de chia, lin'),
        ],
      ),
      FoodIconCategory(
        id: 'dairy',
        name: 'Produits laitiers',
        emoji: '🥛',
        color: Colors.blue,
        icons: [
          FoodIcon(emoji: '🥛', name: 'Lait', description: 'Lait entier, écrémé'),
          FoodIcon(emoji: '🧀', name: 'Fromage', description: 'Fromage'),
          FoodIcon(emoji: '🍦', name: 'Yaourt', description: 'Yaourt, fromage blanc'),
          FoodIcon(emoji: '🧁', name: 'Crème', description: 'Crème fraîche'),
          FoodIcon(emoji: '🍨', name: 'Glace', description: 'Crème glacée'),
          FoodIcon(emoji: '🥧', name: 'Dessert lacté', description: 'Flan, crème dessert'),
        ],
      ),
      FoodIconCategory(
        id: 'sugars',
        name: 'Sucres',
        emoji: '🍬',
        color: Colors.pink,
        icons: [
          FoodIcon(emoji: '🍬', name: 'Bonbons', description: 'Confiseries'),
          FoodIcon(emoji: '🍫', name: 'Chocolat', description: 'Chocolat'),
          FoodIcon(emoji: '🍯', name: 'Miel', description: 'Miel'),
          FoodIcon(emoji: '🍩', name: 'Donut', description: 'Beignet'),
          FoodIcon(emoji: '🍪', name: 'Cookie', description: 'Biscuits'),
          FoodIcon(emoji: '🎂', name: 'Gâteau', description: 'Pâtisserie'),
          FoodIcon(emoji: '🧁', name: 'Cupcake', description: 'Muffin'),
          FoodIcon(emoji: '🍰', name: 'Part de gâteau', description: 'Cheesecake'),
          FoodIcon(emoji: '🍮', name: 'Flan', description: 'Crème caramel'),
          FoodIcon(emoji: '🍭', name: 'Sucette', description: 'Sucre'),
          FoodIcon(emoji: '🍿', name: 'Pop-corn', description: 'Pop-corn sucré'),
        ],
      ),
      FoodIconCategory(
        id: 'drinks',
        name: 'Boissons',
        emoji: '🥤',
        color: Colors.cyan,
        icons: [
          FoodIcon(emoji: '💧', name: 'Eau', description: 'Eau plate'),
          FoodIcon(emoji: '🥤', name: 'Soda', description: 'Boisson gazeuse'),
          FoodIcon(emoji: '☕', name: 'Café', description: 'Café, expresso'),
          FoodIcon(emoji: '🍵', name: 'Thé', description: 'Thé, infusion'),
          FoodIcon(emoji: '🧃', name: 'Jus', description: 'Jus de fruits'),
          FoodIcon(emoji: '🥛', name: 'Lait', description: 'Lait, boisson lactée'),
          FoodIcon(emoji: '🍺', name: 'Bière', description: 'Bière'),
          FoodIcon(emoji: '🍷', name: 'Vin', description: 'Vin rouge, blanc'),
          FoodIcon(emoji: '🍹', name: 'Cocktail', description: 'Cocktail'),
          FoodIcon(emoji: '🧋', name: 'Bubble tea', description: 'Thé aux perles'),
          FoodIcon(emoji: '🍶', name: 'Saké', description: 'Alcool de riz'),
          FoodIcon(emoji: '🫖', name: 'Théière', description: 'Infusion'),
        ],
      ),
      FoodIconCategory(
        id: 'meals',
        name: 'Plats préparés',
        emoji: '🍽️',
        color: Colors.purple,
        icons: [
          FoodIcon(emoji: '🍕', name: 'Pizza', description: 'Pizza'),
          FoodIcon(emoji: '🍔', name: 'Burger', description: 'Hamburger'),
          FoodIcon(emoji: '🌮', name: 'Tacos', description: 'Tacos, fajitas'),
          FoodIcon(emoji: '🌯', name: 'Burrito', description: 'Wrap, burrito'),
          FoodIcon(emoji: '🍣', name: 'Sushi', description: 'Sushi, maki'),
          FoodIcon(emoji: '🍱', name: 'Bento', description: 'Repas japonais'),
          FoodIcon(emoji: '🍜', name: 'Ramen', description: 'Nouilles, soupe'),
          FoodIcon(emoji: '🍲', name: 'Pot-au-feu', description: 'Ragoût, curry'),
          FoodIcon(emoji: '🥘', name: 'Paella', description: 'Plat mijoté'),
          FoodIcon(emoji: '🫕', name: 'Fondue', description: 'Fondue'),
          FoodIcon(emoji: '🥙', name: 'Kebab', description: 'Döner, pita'),
          FoodIcon(emoji: '🥪', name: 'Sandwich', description: 'Sandwich'),
          FoodIcon(emoji: '🥗', name: 'Salade', description: 'Salade composée'),
          FoodIcon(emoji: '🍛', name: 'Curry', description: 'Curry, riz'),
          FoodIcon(emoji: '🍝', name: 'Spaghetti', description: 'Pâtes sauce'),
        ],
      ),
      FoodIconCategory(
        id: 'supplements',
        name: 'Compléments',
        emoji: '💊',
        color: Colors.teal,
        icons: [
          FoodIcon(emoji: '💊', name: 'Compléments', description: 'Vitamines, minéraux'),
          FoodIcon(emoji: '🥤', name: 'Protéine', description: 'Whey, caséine'),
          FoodIcon(emoji: '⚡', name: 'Pré-workout', description: 'Booster'),
          FoodIcon(emoji: '🧪', name: 'BCAA', description: 'Acides aminés'),
          FoodIcon(emoji: '🥛', name: 'Créatine', description: 'Créatine monohydrate'),
          FoodIcon(emoji: '🍵', name: 'Thé vert', description: 'Brûleur de graisse'),
        ],
      ),
      FoodIconCategory(
        id: 'charcuterie',
        name: 'Charcuterie',
        emoji: '🥓',
        color: Colors.deepOrange,
        icons: [
          FoodIcon(emoji: '🥓', name: 'Bacon', description: 'Bacon, lardons'),
          FoodIcon(emoji: '🍖', name: 'Jambon', description: 'Jambon blanc, cru'),
          FoodIcon(emoji: '🌭', name: 'Saucisse', description: 'Saucisse, knack'),
          FoodIcon(emoji: '🥩', name: 'Saucisson', description: 'Saucisson sec'),
          FoodIcon(emoji: '🍗', name: 'Rillettes', description: 'Rillettes, pâté'),
          FoodIcon(emoji: '🥪', name: 'Mortadelle', description: 'Mortadelle'),
          FoodIcon(emoji: '🧆', name: 'Chorizo', description: 'Chorizo, pepperoni'),
          FoodIcon(emoji: '🥓', name: 'Pancetta', description: 'Pancetta, guanciale'),
          FoodIcon(emoji: '🍖', name: 'Coppa', description: 'Coppa, bresaola'),
          FoodIcon(emoji: '🥩', name: 'Terrine', description: 'Terrine, pâté en croûte'),
          FoodIcon(emoji: '🌭', name: 'Merguez', description: 'Merguez, chipolata'),
          FoodIcon(emoji: '🍗', name: 'Andouille', description: 'Andouille, andouillette'),
        ],
      ),
      FoodIconCategory(
        id: 'oils',
        name: 'Huiles',
        emoji: '🫒',
        color: Colors.lime,
        icons: [
          FoodIcon(emoji: '🫒', name: 'Huile d\'olive', description: 'Extra vierge, vierge'),
          FoodIcon(emoji: '🌻', name: 'Huile de tournesol', description: 'Tournesol'),
          FoodIcon(emoji: '🥜', name: 'Huile d\'arachide', description: 'Cacahuète'),
          FoodIcon(emoji: '🌽', name: 'Huile de maïs', description: 'Maïs'),
          FoodIcon(emoji: '🥥', name: 'Huile de coco', description: 'Noix de coco'),
          FoodIcon(emoji: '🌾', name: 'Huile de colza', description: 'Colza, canola'),
          FoodIcon(emoji: '🌰', name: 'Huile de noix', description: 'Noix'),
          FoodIcon(emoji: '🥑', name: 'Huile d\'avocat', description: 'Avocat'),
          FoodIcon(emoji: '🌿', name: 'Huile de lin', description: 'Lin, oméga-3'),
          FoodIcon(emoji: '🌱', name: 'Huile de sésame', description: 'Sésame'),
          FoodIcon(emoji: '🍇', name: 'Huile de pépins', description: 'Pépins de raisin'),
          FoodIcon(emoji: '🧈', name: 'Beurre clarifié', description: 'Ghee'),
          FoodIcon(emoji: '🫗', name: 'Huile neutre', description: 'Huile de cuisson'),
          FoodIcon(emoji: '🥗', name: 'Vinaigrette', description: 'Huile + vinaigre'),
        ],
      ),
    ];
  }

  List<FoodIcon> get _filteredIcons {
    List<FoodIcon> allIcons = [];
    
    // Ajouter les icônes personnalisées
    allIcons.addAll(_customIcons);
    
    // Ajouter les icônes des catégories
    if (_selectedCategoryId != null) {
      final category = _categories.firstWhere((c) => c.id == _selectedCategoryId);
      allIcons.addAll(category.icons);
    } else {
      for (final category in _categories) {
        allIcons.addAll(category.icons);
      }
    }
    
    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      allIcons = allIcons.where((icon) {
        return icon.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (icon.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    
    return allIcons;
  }

  void _showAddCustomIconDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedEmoji = '🍽️';
    
    // Liste d'emojis suggérés
    final suggestedEmojis = ['🍽️', '🥗', '🍲', '🥘', '🍱', '🥡', '🥢', '🧆', '🥠', '🍙', '🍘', '🥟', '🍥', '🥮', '🧇', '🥯', '🫓', '🧊', '🫙'];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.add_circle, color: _primaryGold),
                  SizedBox(width: 10),
                  Text(
                    'Ajouter une icône',
                    style: TextStyle(color: _textLight, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélection d'emoji
                    const Text('Choisir un emoji', style: TextStyle(color: _textMuted, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _cardBgLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Emoji sélectionné
                          Text(
                            selectedEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 12),
                          // Grille d'emojis suggérés
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: suggestedEmojis.map((emoji) {
                              final isSelected = selectedEmoji == emoji;
                              return GestureDetector(
                                onTap: () => setDialogState(() => selectedEmoji = emoji),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? _primaryGold.withOpacity(0.3) : Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? _primaryGold : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nom
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: _textLight),
                      decoration: InputDecoration(
                        labelText: 'Nom de l\'aliment',
                        labelStyle: const TextStyle(color: _textMuted),
                        filled: true,
                        fillColor: _cardBgLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primaryGold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: _textLight),
                      decoration: InputDecoration(
                        labelText: 'Description (optionnel)',
                        labelStyle: const TextStyle(color: _textMuted),
                        filled: true,
                        fillColor: _cardBgLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primaryGold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler', style: TextStyle(color: _textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entrez un nom'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    
                    setState(() {
                      _customIcons.add(FoodIcon(
                        emoji: selectedEmoji,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim().isNotEmpty 
                            ? descriptionController.text.trim() 
                            : null,
                        isCustom: true,
                      ));
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$selectedEmoji ${nameController.text} ajouté !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGold,
                    foregroundColor: _darkBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCustomIcon(FoodIcon icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text('Supprimer', style: TextStyle(color: _textLight)),
        content: Text(
          'Supprimer ${icon.emoji} ${icon.name} ?',
          style: const TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customIcons.remove(icon);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Icône supprimée'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _selectIcon(FoodIcon icon) {
    if (widget.selectMode) {
      Navigator.pop(context, icon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bibliothèque d\'Icônes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: _primaryGold),
            onPressed: _showAddCustomIconDialog,
            tooltip: 'Ajouter une icône',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: _cardBg,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _textLight),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un aliment...',
                hintStyle: const TextStyle(color: _textMuted),
                prefixIcon: const Icon(Icons.search, color: _primaryGold),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: _textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: _cardBgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Catégories horizontales
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Bouton "Toutes"
                  final isSelected = _selectedCategoryId == null;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = null),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryGold : _cardBgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? _primaryGold : _borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '🌐 Toutes',
                          style: TextStyle(
                            color: isSelected ? _darkBg : _textLight,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                final category = _categories[index - 1];
                final isSelected = _selectedCategoryId == category.id;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = category.id),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? category.color.withOpacity(0.2) : _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? category.color : _borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${category.emoji} ${category.name}',
                        style: TextStyle(
                          color: isSelected ? category.color : _textLight,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Compteur
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredIcons.length} icône${_filteredIcons.length > 1 ? 's' : ''}',
                  style: const TextStyle(color: _textMuted, fontSize: 13),
                ),
                if (_customIcons.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_customIcons.length} perso',
                      style: const TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Grille d'icônes
          Expanded(
            child: _filteredIcons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: _textMuted),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune icône trouvée',
                          style: TextStyle(color: _textMuted, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _showAddCustomIconDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Créer une icône'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGold,
                            foregroundColor: _darkBg,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _filteredIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _filteredIcons[index];
                      return _buildIconCard(icon);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomIconDialog,
        backgroundColor: _primaryGold,
        foregroundColor: _darkBg,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle icône', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildIconCard(FoodIcon icon) {
    return GestureDetector(
      onTap: () => _selectIcon(icon),
      onLongPress: icon.isCustom ? () => _deleteCustomIcon(icon) : null,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: icon.isCustom ? Colors.green.withOpacity(0.5) : _borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    icon.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    icon.name,
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (icon.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      icon.description!,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Badge personnalisé
            if (icon.isCustom)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Perso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // Indicateur de sélection (mode sélection)
            if (widget.selectMode)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _primaryGold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.touch_app,
                    color: _primaryGold,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

