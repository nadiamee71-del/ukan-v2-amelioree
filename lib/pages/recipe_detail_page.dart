import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import '../models/recipe.dart';
import '../models/nutrition.dart';
import 'package:url_launcher/url_launcher.dart';

// Couleurs professionnelles : Marron pour DashboardTab
const Color _marronPrincipal = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonce = Color(0xFF5D4037); // Material Brown 700
const Color _marronClair = Color(0xFFA1887F); // Material Brown 300

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  Future<void> _addToMeal() async {
    // Cette fonction sera appelée depuis le parent
    return;
  }

  Future<void> _launchVideo(String url) async {
    // Si c'est une URL web
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  bool _isLocalVideo(String? url) {
    if (url == null) return false;
    if (kIsWeb) return false; // Pas de fichiers locaux sur le web de cette façon
    return url.startsWith('file://') || 
           url.startsWith('/') || 
           url.contains('\\');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: _marronFonce,
        foregroundColor: Colors.white,
        title: Text(recipe.name),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image de la recette
              if (recipe.imagePath != null)
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: _marronClair.withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: _marronPrincipal,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _marronPrincipal.withOpacity(0.1),
                        _marronClair.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: _marronPrincipal.withOpacity(0.5),
                    ),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec type, portions et calories
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _marronPrincipal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getMealTypeIcon(recipe.typeRepas),
                                size: 16,
                                color: _marronPrincipal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                recipe.typeRepas.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _marronPrincipal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${recipe.portions} pers.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (recipe.calories != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${recipe.calories} kcal',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Titre
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    if (recipe.description.isNotEmpty) ...[
                      Text(
                        recipe.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Informations nutritionnelles
                    if (recipe.calories != null ||
                        recipe.proteines != null ||
                        recipe.glucides != null ||
                        recipe.lipides != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations nutritionnelles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (recipe.calories != null)
                                  Expanded(
                                    child: _NutritionInfoCard(
                                      label: 'Calories',
                                      value: '${recipe.calories}',
                                      unit: 'kcal',
                                      color: Colors.orange,
                                    ),
                                  ),
                                if (recipe.proteines != null) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _NutritionInfoCard(
                                      label: 'Protéines',
                                      value: '${recipe.proteines}',
                                      unit: 'g',
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (recipe.glucides != null || recipe.lipides != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (recipe.glucides != null)
                                    Expanded(
                                      child: _NutritionInfoCard(
                                        label: 'Glucides',
                                        value: '${recipe.glucides}',
                                        unit: 'g',
                                        color: Colors.blue,
                                      ),
                                    ),
                                  if (recipe.lipides != null) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _NutritionInfoCard(
                                        label: 'Lipides',
                                        value: '${recipe.lipides}',
                                        unit: 'g',
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Allergènes
                    if (recipe.allergens.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Allergènes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipe.allergens.join(', '),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Ingrédients
                    const Text(
                      'Ingrédients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        recipe.ingredients,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Étapes de préparation
                    const Text(
                      'Étapes de préparation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        recipe.steps,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Vidéo (si présente)
                    if (recipe.videoUrl != null && recipe.videoUrl!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isLocalVideo(recipe.videoUrl)
                                      ? Icons.video_file
                                      : Icons.video_library,
                                  color: _marronPrincipal,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Vidéo de la recette',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (_isLocalVideo(recipe.videoUrl))
                                        Text(
                                          recipe.videoUrl!.replaceFirst('file://', '').split('/').last.split('\\').last,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_isLocalVideo(recipe.videoUrl)) {
                                  // Pour les vidéos locales, on pourrait ouvrir un lecteur
                                  // Pour l'instant, on affiche juste un message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vidéo locale sélectionnée (lecteur vidéo à implémenter)'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  _launchVideo(recipe.videoUrl!);
                                }
                              },
                              icon: Icon(
                                _isLocalVideo(recipe.videoUrl)
                                    ? Icons.play_circle_outline
                                    : Icons.open_in_new,
                                size: 20,
                              ),
                              label: Text(
                                _isLocalVideo(recipe.videoUrl)
                                    ? 'Voir la vidéo locale'
                                    : 'Ouvrir la vidéo',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Bouton "Ajouter à mon repas"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _addRecipeToMeal(context);
                        },
                        icon: const Icon(Icons.restaurant, size: 20),
                        label: const Text(
                          'Ajouter à mon repas du jour',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _marronPrincipal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRecipeToMeal(BuildContext context) {
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
            content: Text('${recipe.name} ajoutée à ton repas du jour'),
            backgroundColor: _marronPrincipal,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Retourner en arrière après un court délai
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cette recette n\'a pas d\'informations nutritionnelles'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
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
}

class _NutritionInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutritionInfoCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

