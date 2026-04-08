import 'package:flutter/material.dart';

class DaySummaryCard extends StatelessWidget {
  final double totalKcal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalPrice;

  const DaySummaryCard({
    super.key,
    required this.totalKcal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Couleurs mode sombre / expert
    const Color darkBg = Color(0xFF1A1A1A);
    const Color accentYellow = Color(0xFFFFC300);
    const Color textWhite = Colors.white;
    const Color textGrey = Colors.grey;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Résumé du jour',
                style: TextStyle(
                  color: textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${totalPrice.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: accentYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MacroIndicator(label: 'Calories', value: '${totalKcal.toInt()}', unit: 'kcal', color: accentYellow),
              _MacroIndicator(label: 'Protéines', value: '${totalProtein.toInt()}', unit: 'g', color: Colors.blue.shade400),
              _MacroIndicator(label: 'Glucides', value: '${totalCarbs.toInt()}', unit: 'g', color: Colors.orange.shade400),
              _MacroIndicator(label: 'Lipides', value: '${totalFat.toInt()}', unit: 'g', color: Colors.purple.shade400),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroIndicator extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroIndicator({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
      ],
    );
  }
}








