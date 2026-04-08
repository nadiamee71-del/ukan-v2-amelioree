import 'package:flutter/material.dart';
import 'foodscan_engine_demo.dart';
import '../models/nutrition.dart';
import '../pages/simple_nutrition_page.dart';

/// Page démo scan photo d'assiette
class FoodScanPhotoDemoPage extends StatefulWidget {
  final MealType? presetMealType;
  
  const FoodScanPhotoDemoPage({
    super.key,
    this.presetMealType,
  });

  @override
  State<FoodScanPhotoDemoPage> createState() => _FoodScanPhotoDemoPageState();
}

class _FoodScanPhotoDemoPageState extends State<FoodScanPhotoDemoPage> {
  String? _selectedLabel;
  String _portionSize = 'Normale';
  FoodScanResult? _result;
  bool _isAddingMeal = false;

  final List<String> _availablePlats = [
    'Salade / Poulet',
    'Pizza',
    'Burger',
    'Pâtes bolo',
    'Plat maison varié',
  ];

  // Mapping entre les types de plats et les images de scan
  String? _getScanImagePath(String? platLabel) {
    if (platLabel == null) return null;
    
    // Sur Flutter Web, le chemin doit correspondre à la structure assets/assets/...
    switch (platLabel) {
      case 'Salade / Poulet':
        return 'assets/images/foodscan/salade_poulet_scan.png';
      case 'Pizza':
        return 'assets/images/foodscan/pizza_scan.png';
      case 'Burger':
        return 'assets/images/foodscan/burger_scan.png';
      case 'Pâtes bolo':
        return 'assets/images/foodscan/pates_bolo_scan.png';
      case 'Plat maison varié':
        return 'assets/images/foodscan/plat_maison_scan.png';
      default:
        return null;
    }
  }

  void _analyzePlate() {
    if (_selectedLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisis un type de plat d\'abord'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _result = FoodScanEngineDemo.fromPhotoLabel(_selectedLabel!);
      // Debug: vérifier que l'image existe
      final imagePath = _getScanImagePath(_selectedLabel!);
      debugPrint('Plat sélectionné: $_selectedLabel');
      debugPrint('Chemin image: $imagePath');
    });
  }

  void _addToDay() {
    if (_result == null || !mounted || _isAddingMeal) return;

    final now = DateTime.now();
    final mealId = 'foodscan_${now.millisecondsSinceEpoch}';
    
    // Utiliser le type de repas prédéfini ou le déterminer selon l'heure
    MealType mealType;
    if (widget.presetMealType != null) {
      mealType = widget.presetMealType!;
    } else {
      final hour = now.hour;
      if (hour < 10) {
        mealType = MealType.breakfast;
      } else if (hour < 15) {
        mealType = MealType.lunch;
      } else if (hour < 20) {
        mealType = MealType.dinner;
      } else {
        mealType = MealType.snack;
      }
    }

    final meal = MealEntry(
      id: mealId,
      date: DateTime(now.year, now.month, now.day),
      type: mealType,
      title: '${_result!.label} (IA démo)',
      calories: _result!.calories,
      protein: _result!.protein,
      carbs: _result!.carbs,
      fats: _result!.fat,
      notes: _result!.note,
    );

    // Désactiver le bouton immédiatement
    setState(() {
      _isAddingMeal = true;
    });

    // Utiliser postFrameCallback pour différer après tous les listeners
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Ajouter le repas de manière synchrone
        NutritionNotifier().addMeal(meal);

        // Vérifier que le widget est toujours monté
        if (!mounted) {
          _isAddingMeal = false;
          return;
        }

        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repas IA ajouté à aujourd\'hui ✅'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFFFFC300),
          ),
        );

        // Attendre que le frame suivant soit complété avant de naviguer
        await Future.delayed(const Duration(milliseconds: 1000));

        // Vérifier à nouveau que le widget est toujours monté
        if (!mounted) return;

        // Rediriger vers la page nutrition pour voir le repas ajouté
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          
          // Fermer la page actuelle et naviguer vers la page nutrition
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SimpleNutritionPage(),
            ),
          );
        });
      } catch (e) {
        // Réactiver le bouton en cas d'erreur
        if (mounted) {
          setState(() {
            _isAddingMeal = false;
          });

          // Gérer l'erreur en affichant un message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout du repas: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        debugPrint('Erreur lors de l\'ajout du repas: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Scan assiette (démo)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Explication
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choisis un type de plat pour simuler l\'analyse IA. Dans la vraie version, tu prendras une photo de ton assiette.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    if (widget.presetMealType != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC300).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFC300).withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restaurant_menu, size: 16, color: const Color(0xFFFFC300)),
                            const SizedBox(width: 8),
                            Text(
                              'Type de repas : ${widget.presetMealType!.displayName}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFC300),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Liste des plats
              const Text(
                'Type de plat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availablePlats.map((plat) {
                  final isSelected = _selectedLabel == plat;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLabel = plat;
                        _result = null; // Reset result
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFC300)
                            : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFC300)
                              : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        plat,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Portion (info uniquement)
              const Text(
                'Portion estimée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _portionSize,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '(Info uniquement)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Bouton Analyser
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _analyzePlate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC300),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Analyser l\'assiette (démo)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              
              // Résultat
              if (_result != null) ...[
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image de scan du plat
                      if (_getScanImagePath(_selectedLabel) != null) ...[
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              _getScanImagePath(_selectedLabel)!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Erreur chargement image: $error');
                                debugPrint('Chemin recherché: ${_getScanImagePath(_selectedLabel)}');
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Image non trouvée',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getScanImagePath(_selectedLabel) ?? 'null',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC300).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Color(0xFFFFC300),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _result!.label,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Portion estimée : ${_result!.portionGrams} g',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              color: Colors.orange.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '~ ${_result!.calories} kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _MacroItem(label: 'P', value: '${_result!.protein} g', color: Colors.blue),
                          const SizedBox(width: 16),
                          _MacroItem(label: 'G', value: '${_result!.carbs} g', color: Colors.orange),
                          const SizedBox(width: 16),
                          _MacroItem(label: 'L', value: '${_result!.fat} g', color: Colors.red),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                color: Colors.green.shade600, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Confiance IA : ${_result!.confidence} %',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_result!.note.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _result!.note,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAddingMeal ? null : _addToDay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111111),
                            foregroundColor: const Color(0xFFFFC300),
                            disabledBackgroundColor: Colors.grey.shade800,
                            disabledForegroundColor: Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isAddingMeal
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC300)),
                                  ),
                                )
                              : const Text(
                                  'Ajouter à ma journée',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

