import 'package:flutter/material.dart';
import '../calculator/models_demo.dart';

class ShoppingListTab extends StatefulWidget {
  const ShoppingListTab({super.key});

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab> {
  final Map<DemoIngredientCategory, List<String>> _shoppingItems = {
    DemoIngredientCategory.vegetables: ['Oignon', 'Poivron', 'Salade', 'Tomates cerise'],
    DemoIngredientCategory.fruit: ['Banane', 'Pomme'],
    DemoIngredientCategory.proteins: ['Poulet', 'Oeufs', 'Thon'],
    DemoIngredientCategory.carbs: ['Riz', 'Pâtes'],
  };

  final Set<String> _checkedItems = {};

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF050505);
    const Color accentYellow = Color(0xFFFFC300);

    return Scaffold(
      backgroundColor: darkBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: accentYellow,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Ajouter'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          ...DemoIngredientCategory.values.map((cat) {
            final items = _shoppingItems[cat] ?? [];
            if (items.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        cat.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: items.map((item) {
                      final isChecked = _checkedItems.contains(item);
                      return CheckboxListTile(
                        value: isChecked,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _checkedItems.add(item);
                            } else {
                              _checkedItems.remove(item);
                            }
                          });
                        },
                        title: Text(
                          item,
                          style: TextStyle(
                            color: isChecked ? Colors.grey : Colors.white,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        activeColor: accentYellow,
                        checkColor: Colors.black,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    String newItem = '';
    DemoIngredientCategory selectedCat = DemoIngredientCategory.vegetables;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Ajouter un article', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<DemoIngredientCategory>(
                value: selectedCat,
                dropdownColor: const Color(0xFF2A2A2A),
                isExpanded: true,
                items: DemoIngredientCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      '${cat.emoji} ${cat.label}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setDialogState(() => selectedCat = val!),
              ),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Nom de l\'article',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                ),
                onChanged: (val) => newItem = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (newItem.isNotEmpty) {
                  setState(() {
                    if (_shoppingItems[selectedCat] == null) {
                      _shoppingItems[selectedCat] = [];
                    }
                    _shoppingItems[selectedCat]!.add(newItem);
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('Ajouter', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}








