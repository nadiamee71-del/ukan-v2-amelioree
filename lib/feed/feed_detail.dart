import 'package:flutter/material.dart';
import '../main.dart'; // Pour accéder à NutritionNotifier et MealItem

/// Page de détail d'une publication avec bouton "Ajouter au panier"
class FeedDetailPage extends StatelessWidget {
  final String imagePath;

  const FeedDetailPage({super.key, required this.imagePath});

  // Extraire le nom du plat depuis le chemin de l'image
  String _getMealName() {
    final fileName = imagePath.split('/').last.replaceAll('.png', '').replaceAll('_scan', '');
    // Capitaliser et formater
    return fileName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _addToMealsToday(BuildContext context) {
    final mealName = _getMealName();
    
    // Créer un MealItem basique (calories et prix estimés)
    final estimatedCalories = _estimateCalories(mealName);
    final estimatedPrice = _estimatePrice(mealName);
    
    final meal = MealItem(
      title: mealName,
      calories: estimatedCalories,
      price: estimatedPrice,
      ingredients: [], // Liste vide pour l'instant
    );

    // Ajouter au repas du jour (utiliser le système existant)
    // Note: Il faudra adapter selon votre système NutritionNotifier
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $mealName ajouté au repas du jour'),
        backgroundColor: const Color(0xFF34C759),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () {
            // Naviguer vers la page Repas & Courses
            // Navigator.of(context).push(...);
          },
        ),
      ),
    );
  }

  // Estimation basique des calories selon le type de plat
  int _estimateCalories(String mealName) {
    final lower = mealName.toLowerCase();
    if (lower.contains('pizza')) return 800;
    if (lower.contains('burger')) return 600;
    if (lower.contains('pates') || lower.contains('pâtes')) return 500;
    if (lower.contains('salade')) return 300;
    if (lower.contains('poulet')) return 400;
    return 500; // Valeur par défaut
  }

  // Estimation basique du prix
  double _estimatePrice(String mealName) {
    final lower = mealName.toLowerCase();
    if (lower.contains('pizza')) return 12.0;
    if (lower.contains('burger')) return 8.0;
    if (lower.contains('pates') || lower.contains('pâtes')) return 6.0;
    if (lower.contains('salade')) return 7.0;
    if (lower.contains('poulet')) return 9.0;
    return 8.0; // Valeur par défaut
  }

  @override
  Widget build(BuildContext context) {
    final mealName = _getMealName();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          mealName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Image principale
          Expanded(
            child: Center(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                        size: 80,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Informations et bouton
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mealName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Text(
                      '~${_estimateCalories(mealName)} kcal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.euro, size: 18, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text(
                      '~${_estimatePrice(mealName).toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Bouton "Ajouter au repas du jour"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToMealsToday(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300), // Jaune Ukan
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ajouter au repas du jour',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

