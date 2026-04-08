import 'package:flutter/material.dart';
import '../calculator/models_demo.dart';

class MealCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<DemoFoodEntry> entries;
  final VoidCallback onSendToCalculator;
  final Function(DemoFoodEntry, double) onUpdateQuantity;

  const MealCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.entries,
    required this.onSendToCalculator,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    // Style sombre
    const Color darkBg = Color(0xFF1A1A1A);
    const Color accentYellow = Color(0xFFFFC300);

    final totalKcal = entries.fold(0.0, (sum, e) => sum + e.totalKcal);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Repas
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: accentYellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                '${totalKcal.toInt()} kcal',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Liste Ingrédients
          ...entries.map((entry) => _IngredientRow(
            entry: entry,
            onUpdate: (newQty) => onUpdateQuantity(entry, newQty),
          )),

          const SizedBox(height: 12),
          
          // Bouton Send to Simulator
          Center(
            child: TextButton.icon(
              onPressed: onSendToCalculator,
              icon: const Icon(Icons.auto_graph, size: 16),
              label: const Text('Envoyer au simulateur'),
              style: TextButton.styleFrom(
                foregroundColor: accentYellow,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                side: BorderSide(color: accentYellow.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final DemoFoodEntry entry;
  final Function(double) onUpdate;

  const _IngredientRow({required this.entry, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            entry.ingredient.category.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.ingredient.name,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () {
              if (entry.quantityGrams > 10) onUpdate(entry.quantityGrams - 10);
            },
            icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${entry.quantityGrams.toInt()} g',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: () => onUpdate(entry.quantityGrams + 10),
            icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}


