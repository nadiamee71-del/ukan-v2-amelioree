import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models_demo.dart';
import '../food_icons_library_page.dart';

/// Calculatrice nutritionnelle avec pavé numérique complet
/// Mode Simple (icônes mignonnes) et Mode Expert (valeurs détaillées)
class NumericCalculatorPage extends StatefulWidget {
  const NumericCalculatorPage({super.key});

  @override
  State<NumericCalculatorPage> createState() => _NumericCalculatorPageState();
}

class _NumericCalculatorPageState extends State<NumericCalculatorPage> {
  // Mode d'affichage
  bool _isExpertMode = false;
  
  // Valeur affichée sur l'écran
  String _displayValue = '0';
  
  // Opération en cours
  String? _pendingOperation;
  double? _firstOperand;
  bool _shouldResetDisplay = false;
  
  // Unité sélectionnée
  String _selectedUnit = 'g';
  
  // Catégorie sélectionnée
  DemoIngredientCategory? _selectedCategory;
  
  // Aliment sélectionné
  DemoIngredient? _selectedIngredient;
  
  // Liste des entrées ajoutées (pour le total final)
  final List<_CalculatorEntry> _entries = [];
  
  // Liste des éléments de l'expression en cours (affichés sur l'écran)
  final List<_ExpressionItem> _expressionItems = [];
  
  // Tous les ingrédients disponibles (incluant les personnalisés)
  late List<DemoIngredient> _allIngredients;
  
  // Aliments personnalisés
  final List<DemoIngredient> _customIngredients = [];

  // Unités disponibles
  static const List<String> _availableUnits = ['g', 'kg', 'ml', 'cl', 'L'];

  @override
  void initState() {
    super.initState();
    _allIngredients = buildDemoIngredients();
  }

  // Calculs totaux
  double get _totalKcal => _entries.fold(0.0, (sum, e) => sum + e.calories);
  double get _totalProtein => _entries.fold(0.0, (sum, e) => sum + e.protein);
  double get _totalCarbs => _entries.fold(0.0, (sum, e) => sum + e.carbs);
  double get _totalFat => _entries.fold(0.0, (sum, e) => sum + e.fat);
  double get _totalPrice => _entries.fold(0.0, (sum, e) => sum + e.price);

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    
    setState(() {
      if (key == 'C') {
        // Clear tout
        _displayValue = '0';
        _pendingOperation = null;
        _firstOperand = null;
        _shouldResetDisplay = false;
        _expressionItems.clear();
      } else if (key == '⌫') {
        if (_displayValue.length > 1) {
          _displayValue = _displayValue.substring(0, _displayValue.length - 1);
        } else {
          _displayValue = '0';
        }
      } else if (key == '.') {
        if (_shouldResetDisplay) {
          _displayValue = '0.';
          _shouldResetDisplay = false;
        } else if (!_displayValue.contains('.')) {
          _displayValue += '.';
        }
      } else if (key == '+' || key == '-' || key == '×' || key == '÷') {
        // Ajouter l'aliment actuel à l'expression
        _addCurrentToExpression(key);
        _pendingOperation = key;
        _shouldResetDisplay = true;
      } else if (key == '=') {
        // Ajouter le dernier aliment et calculer le résultat
        _addCurrentToExpression(null);
        _calculateExpressionResult();
        _pendingOperation = null;
        _firstOperand = null;
      } else {
        // Chiffres
        if (_shouldResetDisplay || _displayValue == '0') {
          _displayValue = key;
          _shouldResetDisplay = false;
        } else if (_displayValue.length < 10) {
          _displayValue += key;
        }
      }
    });
  }

  void _addCurrentToExpression(String? operation) {
    final quantity = double.tryParse(_displayValue) ?? 0;
    if (quantity <= 0) return;
    
    // Ajouter l'élément à l'expression
    _expressionItems.add(_ExpressionItem(
      ingredient: _selectedIngredient,
      quantity: quantity,
      unit: _selectedUnit,
      operation: operation,
    ));
    
    // Mettre à jour le premier opérande pour les calculs
    if (_firstOperand == null) {
      _firstOperand = quantity;
    } else if (_pendingOperation != null) {
      _executeOperation();
      _firstOperand = double.tryParse(_displayValue) ?? 0;
    }
  }

  void _calculateExpressionResult() {
    if (_expressionItems.isEmpty) return;
    
    // Calculer le total des quantités
    double totalQuantity = 0;
    for (int i = 0; i < _expressionItems.length; i++) {
      final item = _expressionItems[i];
      if (i == 0) {
        totalQuantity = item.quantity;
      } else {
        final prevItem = _expressionItems[i - 1];
        switch (prevItem.operation) {
          case '+':
            totalQuantity += item.quantity;
            break;
          case '-':
            totalQuantity -= item.quantity;
            break;
          case '×':
            totalQuantity *= item.quantity;
            break;
          case '÷':
            if (item.quantity != 0) {
              totalQuantity /= item.quantity;
            }
            break;
        }
      }
    }
    
    // Formater le résultat
    if (totalQuantity == totalQuantity.roundToDouble()) {
      _displayValue = totalQuantity.toInt().toString();
    } else {
      _displayValue = totalQuantity.toStringAsFixed(2);
    }
    
    // Limiter la longueur
    if (_displayValue.length > 10) {
      _displayValue = _displayValue.substring(0, 10);
    }
  }

  void _executeOperation() {
    if (_pendingOperation == null || _firstOperand == null) return;
    
    final secondOperand = double.tryParse(_displayValue) ?? 0;
    double result = 0;
    
    switch (_pendingOperation) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand != 0) {
          result = _firstOperand! / secondOperand;
        } else {
          result = 0;
        }
        break;
    }
    
    // Formater le résultat
    if (result == result.roundToDouble()) {
      _displayValue = result.toInt().toString();
    } else {
      _displayValue = result.toStringAsFixed(2);
    }
    
    // Limiter la longueur
    if (_displayValue.length > 10) {
      _displayValue = _displayValue.substring(0, 10);
    }
  }
  
  // Calculer les macros totales de l'expression
  double get _expressionTotalKcal => _expressionItems.fold(0.0, (sum, e) => sum + e.calories);
  double get _expressionTotalProtein => _expressionItems.fold(0.0, (sum, e) => sum + e.protein);
  double get _expressionTotalCarbs => _expressionItems.fold(0.0, (sum, e) => sum + e.carbs);
  double get _expressionTotalFat => _expressionItems.fold(0.0, (sum, e) => sum + e.fat);

  void _addCurrentToEntries() {
    if (_selectedIngredient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez d\'abord un aliment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final quantity = double.tryParse(_displayValue) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrez une quantité valide'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _entries.add(_CalculatorEntry(
        ingredient: _selectedIngredient!,
        quantity: quantity,
        unit: _selectedUnit,
      ));
      _displayValue = '0';
      _selectedIngredient = null;
    });

    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0A0E27);
    const Color accentYellow = Color(0xFFFFC300);
    const Color keyBg = Color(0xFF1A1F3A);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calculatrice Nutrition',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Toggle Mode Simple/Expert
          GestureDetector(
            onTap: () => setState(() => _isExpertMode = !_isExpertMode),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isExpertMode ? accentYellow : keyBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentYellow, width: 1.5),
              ),
              child: Text(
                _isExpertMode ? 'EXPERT' : 'SIMPLE',
                style: TextStyle(
                  color: _isExpertMode ? Colors.black : accentYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Partie scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Écran d'affichage principal
                    _buildDisplay(accentYellow),
                    
                    // Catégories d'aliments
                    _buildCategoriesRow(accentYellow),
                    
                    // Liste d'aliments si catégorie sélectionnée
                    if (_selectedCategory != null) _buildIngredientsDropdown(accentYellow),
                    
                    // Sélecteurs d'unité
                    _buildUnitSelector(accentYellow),
                    
                    // Pavé numérique
                    _buildNumericKeypad(accentYellow, keyBg),
                  ],
                ),
              ),
            ),
            
            // Liste des entrées et totaux (fixe en bas)
            if (_entries.isNotEmpty) _buildEntriesSummary(accentYellow),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay(Color accent) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Expression en cours avec icônes des aliments
          if (_expressionItems.isNotEmpty) ...[
            _buildExpressionDisplay(accent),
            const Divider(color: Colors.white24, height: 16),
          ],
          
          // Aliment sélectionné actuellement
          if (_selectedIngredient != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _selectedIngredient!.category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _selectedIngredient!.name,
                    style: TextStyle(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          
          // Valeur affichée
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _displayValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedUnit,
                style: TextStyle(
                  color: accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Infos nutritionnelles en mode expert ou si expression
          if (_isExpertMode && _selectedIngredient != null) ...[
            const Divider(color: Colors.white24, height: 24),
            _buildExpertInfo(),
          ],
          
          // Macros totales de l'expression
          if (_expressionItems.isNotEmpty) ...[
            const Divider(color: Colors.white24, height: 16),
            _buildExpressionMacros(accent),
          ],
        ],
      ),
    );
  }

  Widget _buildExpressionDisplay(Color accent) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: _expressionItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opération (sauf pour le premier)
            if (index > 0 && _expressionItems[index - 1].operation != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _expressionItems[index - 1].operation!,
                  style: TextStyle(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            // Aliment avec icône et quantité
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF252A4A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône de l'aliment
                  Text(
                    item.ingredient?.category.emoji ?? '🍽️',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  // Nom (abrégé) et quantité
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _abbreviateName(item.ingredient?.name ?? 'Aliment'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}${item.unit}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _abbreviateName(String name) {
    if (name.length <= 12) return name;
    return '${name.substring(0, 10)}...';
  }

  Widget _buildExpressionMacros(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252A4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMiniMacro('🔥', '${_expressionTotalKcal.toStringAsFixed(0)}', 'kcal', Colors.orange),
          Container(width: 1, height: 24, color: Colors.white12),
          _buildMiniMacro('🥩', '${_expressionTotalProtein.toStringAsFixed(1)}g', 'P', Colors.red),
          Container(width: 1, height: 24, color: Colors.white12),
          _buildMiniMacro('🍞', '${_expressionTotalCarbs.toStringAsFixed(1)}g', 'G', Colors.amber),
          Container(width: 1, height: 24, color: Colors.white12),
          _buildMiniMacro('🧈', '${_expressionTotalFat.toStringAsFixed(1)}g', 'L', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMiniMacro(String emoji, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildExpertInfo() {
    final ing = _selectedIngredient!;
    final qty = double.tryParse(_displayValue) ?? 0;
    final multiplier = qty / 100;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMacroInfo('🔥', '${(ing.kcalPer100g * multiplier).toStringAsFixed(0)} kcal', Colors.orange),
        _buildMacroInfo('🥩', '${(ing.proteinPer100g * multiplier).toStringAsFixed(1)}g P', Colors.red),
        _buildMacroInfo('🍞', '${(ing.carbsPer100g * multiplier).toStringAsFixed(1)}g G', Colors.amber),
        _buildMacroInfo('🧈', '${(ing.fatPer100g * multiplier).toStringAsFixed(1)}g L', Colors.purple),
        _buildMacroInfo('💰', '${(ing.pricePerKg * qty / 1000).toStringAsFixed(2)}€', Colors.green),
      ],
    );
  }

  Widget _buildMacroInfo(String emoji, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesRow(Color accent) {
    final categories = DemoIngredientCategory.values;
    
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length + 1, // +1 pour le bouton "Ajouter aliment"
        itemBuilder: (context, index) {
          // Dernier élément = bouton ajouter aliment
          if (index == categories.length) {
            return GestureDetector(
              onTap: () => _showAddCustomIngredientDialog(accent),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Nouvel\naliment',
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedCategory = isSelected ? null : cat;
                _selectedIngredient = null;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [accent, accent.withOpacity(0.7)])
                    : null,
                color: isSelected ? null : const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? accent : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(cat.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCustomIngredientDialog(Color accent) {
    final nameController = TextEditingController();
    final kcalController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    final priceController = TextEditingController();
    DemoIngredientCategory selectedCategory = DemoIngredientCategory.proteins;
    String selectedEmoji = '🍽️';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1F3A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.add_circle, color: accent),
                  const SizedBox(width: 10),
                  const Text(
                    'Nouvel Aliment',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icône sélectionnée + bouton bibliothèque
                    Row(
                      children: [
                        // Icône actuelle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: accent),
                          ),
                          child: Text(selectedEmoji, style: const TextStyle(fontSize: 36)),
                        ),
                        const SizedBox(width: 12),
                        // Bouton pour ouvrir la bibliothèque
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.of(context).push<FoodIcon>(
                                MaterialPageRoute(
                                  builder: (_) => const FoodIconsLibraryPage(selectMode: true),
                                ),
                              );
                              if (result != null) {
                                setDialogState(() {
                                  selectedEmoji = result.emoji;
                                  if (nameController.text.isEmpty) {
                                    nameController.text = result.name;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emoji_food_beverage, color: accent, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Bibliothèque\nd\'icônes',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Nom
                    _buildDialogTextField(
                      controller: nameController,
                      label: 'Nom de l\'aliment',
                      icon: Icons.restaurant,
                      accent: accent,
                    ),
                    const SizedBox(height: 12),
                    
                    // Catégorie
                    const Text('Catégorie', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DemoIngredientCategory.values.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? accent.withOpacity(0.3) : Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? accent : Colors.white24,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Valeurs nutritionnelles pour 100g
                    const Text(
                      'Valeurs pour 100g',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogTextField(
                            controller: kcalController,
                            label: 'Calories',
                            icon: Icons.local_fire_department,
                            accent: Colors.orange,
                            keyboardType: TextInputType.number,
                            suffix: 'kcal',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDialogTextField(
                            controller: proteinController,
                            label: 'Protéines',
                            icon: Icons.fitness_center,
                            accent: Colors.red,
                            keyboardType: TextInputType.number,
                            suffix: 'g',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogTextField(
                            controller: carbsController,
                            label: 'Glucides',
                            icon: Icons.grain,
                            accent: Colors.amber,
                            keyboardType: TextInputType.number,
                            suffix: 'g',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDialogTextField(
                            controller: fatController,
                            label: 'Lipides',
                            icon: Icons.water_drop,
                            accent: Colors.purple,
                            keyboardType: TextInputType.number,
                            suffix: 'g',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Prix (optionnel)
                    _buildDialogTextField(
                      controller: priceController,
                      label: 'Prix (optionnel)',
                      icon: Icons.euro,
                      accent: Colors.green,
                      keyboardType: TextInputType.number,
                      suffix: '€/kg',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entrez un nom'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    
                    final newIngredient = DemoIngredient(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      category: selectedCategory,
                      unit: DemoUnit.gram,
                      kcalPer100g: double.tryParse(kcalController.text) ?? 0,
                      proteinPer100g: double.tryParse(proteinController.text) ?? 0,
                      carbsPer100g: double.tryParse(carbsController.text) ?? 0,
                      fatPer100g: double.tryParse(fatController.text) ?? 0,
                      pricePerKg: double.tryParse(priceController.text) ?? 0,
                    );
                    
                    setState(() {
                      _customIngredients.add(newIngredient);
                      _allIngredients.add(newIngredient);
                      _selectedCategory = selectedCategory;
                      _selectedIngredient = newIngredient;
                    });
                    
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$selectedEmoji ${newIngredient.name} ajouté ! 🎉'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accent,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accent.withOpacity(0.7), fontSize: 12),
        prefixIcon: Icon(icon, color: accent, size: 18),
        suffixText: suffix,
        suffixStyle: TextStyle(color: accent, fontSize: 12),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildIngredientsDropdown(Color accent) {
    final filtered = _allIngredients.where((i) => i.category == _selectedCategory).toList();
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final ing = filtered[index];
          final isSelected = _selectedIngredient == ing;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedIngredient = ing);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accent.withOpacity(0.2) : const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? accent : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  ing.name,
                  style: TextStyle(
                    color: isSelected ? accent : Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnitSelector(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Toutes les unités disponibles
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _availableUnits.map((unit) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildUnitButton(unit, accent),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Bouton Ajouter
          GestureDetector(
            onTap: _addCurrentToEntries,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.black, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'AJOUTER',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  Widget _buildUnitButton(String unit, Color accent) {
    final isSelected = _selectedUnit == unit;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedUnit = unit);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accent : const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? accent : Colors.white24),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad(Color accent, Color keyBg) {
    final keys = [
      ['1', '2', '3', '+'],
      ['4', '5', '6', '-'],
      ['7', '8', '9', '×'],
      ['C', '0', '.', '÷'],
      ['⌫', '='],
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: keys.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final row = entry.value;
          
          // Dernière ligne avec 2 boutons plus larges
          if (rowIndex == keys.length - 1) {
            return Row(
              children: [
                // Backspace
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onKeyPressed('⌫'),
                    child: Container(
                      height: 56,
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: keyBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Center(
                        child: Icon(Icons.backspace_outlined, color: Colors.white70, size: 22),
                      ),
                    ),
                  ),
                ),
                // Égal
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () => _onKeyPressed('='),
                    child: Container(
                      height: 56,
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          '=',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          
          return Row(
            children: row.map((key) {
              final isOperation = ['+', '-', '×', '÷'].contains(key);
              final isActiveOperation = _pendingOperation == key;
              final isClear = key == 'C';
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onKeyPressed(key),
                  child: Container(
                    height: 56,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: isClear
                          ? const LinearGradient(colors: [Color(0xFFEF5350), Color(0xFFC62828)])
                          : isOperation
                              ? LinearGradient(
                                  colors: isActiveOperation 
                                    ? [Colors.white, Colors.white70]
                                    : [accent, accent.withOpacity(0.7)]
                                )
                              : null,
                      color: isClear || isOperation ? null : keyBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isOperation || isClear ? Colors.transparent : Colors.white12,
                        width: isActiveOperation ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        key,
                        style: TextStyle(
                          color: isActiveOperation 
                            ? accent 
                            : (isOperation || isClear ? Colors.black : Colors.white),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEntriesSummary(Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        border: Border(top: BorderSide(color: accent.withOpacity(0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Totaux sur une seule ligne
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTotalBadge('🔥', '${_totalKcal.toStringAsFixed(0)}', 'kcal', Colors.orange),
              _buildTotalBadge('🥩', '${_totalProtein.toStringAsFixed(1)}', 'g P', Colors.red),
              _buildTotalBadge('🍞', '${_totalCarbs.toStringAsFixed(1)}', 'g G', Colors.amber),
              _buildTotalBadge('🧈', '${_totalFat.toStringAsFixed(1)}', 'g L', Colors.purple),
              _buildTotalBadge('💰', '${_totalPrice.toStringAsFixed(2)}', '€', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBadge(String emoji, String value, String unit, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _CalculatorEntry {
  final DemoIngredient ingredient;
  final double quantity;
  final String unit;

  _CalculatorEntry({
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });

  double get calories => ingredient.kcalPer100g * quantity / 100;
  double get protein => ingredient.proteinPer100g * quantity / 100;
  double get carbs => ingredient.carbsPer100g * quantity / 100;
  double get fat => ingredient.fatPer100g * quantity / 100;
  double get price => ingredient.pricePerKg * quantity / 1000;
}

/// Représente un élément dans l'expression de calcul (aliment + quantité + opération)
class _ExpressionItem {
  final DemoIngredient? ingredient;
  final double quantity;
  final String unit;
  final String? operation; // +, -, ×, ÷ ou null pour le dernier

  _ExpressionItem({
    this.ingredient,
    required this.quantity,
    required this.unit,
    this.operation,
  });

  double get calories => ingredient != null ? ingredient!.kcalPer100g * quantity / 100 : 0;
  double get protein => ingredient != null ? ingredient!.proteinPer100g * quantity / 100 : 0;
  double get carbs => ingredient != null ? ingredient!.carbsPer100g * quantity / 100 : 0;
  double get fat => ingredient != null ? ingredient!.fatPer100g * quantity / 100 : 0;
}

