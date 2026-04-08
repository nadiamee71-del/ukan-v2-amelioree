import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'foodscan_engine_demo.dart';
import '../models/nutrition.dart';
import '../pages/simple_nutrition_page.dart';

/// Page démo description vocale/textuelle avec reconnaissance vocale réelle
class FoodScanVoiceDemoPage extends StatefulWidget {
  final MealType? presetMealType;
  
  const FoodScanVoiceDemoPage({
    super.key,
    this.presetMealType,
  });

  @override
  State<FoodScanVoiceDemoPage> createState() => _FoodScanVoiceDemoPageState();
}

class _FoodScanVoiceDemoPageState extends State<FoodScanVoiceDemoPage> {
  final _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  String _portionHint = 'Normale';
  FoodScanResult? _result;
  bool _isListening = false;
  bool _isAvailable = false;
  String _statusText = 'Prêt à écouter';
  String _lastWords = '';
  bool _isAddingMeal = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onError: (val) {
        setState(() {
          _statusText = 'Erreur: $val';
          _isListening = false;
        });
      },
      onStatus: (val) {
        setState(() {
          if (val == 'done' || val == 'notListening') {
            _isListening = false;
            _statusText = 'Écoute terminée';
          } else if (val == 'listening') {
            _statusText = 'Écoute en cours...';
          }
        });
      },
    );

    setState(() {
      _isAvailable = available;
      if (!available) {
        _statusText = 'Reconnaissance vocale non disponible';
      }
    });
  }

  Future<void> _checkPermissionAndStart() async {
    // Demander la permission micro
    final status = await Permission.microphone.request();
    
    if (status.isDenied) {
      setState(() {
        _statusText = 'Permission micro refusée. Va dans les paramètres.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission micro requise pour la dictée vocale'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _statusText = 'Permission micro refusée définitivement';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Active la permission micro dans les paramètres'),
          action: SnackBarAction(
            label: 'Ouvrir',
            textColor: const Color(0xFFFFC300),
            onPressed: () => openAppSettings(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Démarrer l'écoute
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reconnaissance vocale non disponible sur cet appareil'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _speech.listen(
      onResult: (val) {
        setState(() {
          _lastWords = val.recognizedWords;
          _textController.text = _lastWords;
        });
      },
      localeId: 'fr_FR', // Français par défaut, ou null pour langue système
      listenMode: stt.ListenMode.confirmation,
    );

    setState(() {
      _isListening = true;
      _statusText = 'Écoute en cours...';
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _statusText = 'Écoute terminée';
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.cancel();
    super.dispose();
  }

  void _analyzeMeal() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Décris ton repas avant d\'analyser.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _result = FoodScanEngineDemo.fromTextDescription(text, portionHint: _portionHint);
    });
  }

  void _addToDay() {
    if (_result == null || !mounted || _isAddingMeal) return;

    final now = DateTime.now();
    final mealId = 'foodscan_voice_${now.millisecondsSinceEpoch}';
    
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
          'Description vocale',
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
                      'Dicte ce que tu as mangé et l\'IA analysera ton repas automatiquement. Tu peux aussi taper manuellement.',
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
              
              // Bouton Micro
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isListening
                      ? const Color(0xFFFFC300).withOpacity(0.2)
                      : Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isListening
                        ? const Color(0xFFFFC300)
                        : Colors.white.withOpacity(0.2),
                    width: _isListening ? 2 : 1,
                  ),
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFC300).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _checkPermissionAndStart,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? Colors.red.shade600
                              : const Color(0xFFFFC300),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening
                                      ? Colors.red.shade600
                                      : const Color(0xFFFFC300))
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none_rounded,
                          color: _isListening ? Colors.white : Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isListening ? 'Appuie pour arrêter' : 'Appuie pour dicter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _isListening ? Colors.white : const Color(0xFFFFC300),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Champ texte
              const Text(
                'Description du repas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Ex : petite assiette de riz + poulet + légumes...\n\nOu utilise le micro ci-dessus',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _result = null; // Reset result when text changes
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Chips portion
              const Text(
                'Taille de portion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PortionChip(
                    label: 'Petite',
                    isSelected: _portionHint == 'Petite',
                    onTap: () => setState(() {
                      _portionHint = 'Petite';
                      _result = null;
                    }),
                  ),
                  const SizedBox(width: 12),
                  _PortionChip(
                    label: 'Normale',
                    isSelected: _portionHint == 'Normale',
                    onTap: () => setState(() {
                      _portionHint = 'Normale';
                      _result = null;
                    }),
                  ),
                  const SizedBox(width: 12),
                  _PortionChip(
                    label: 'Grande',
                    isSelected: _portionHint == 'Grande',
                    onTap: () => setState(() {
                      _portionHint = 'Grande';
                      _result = null;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Bouton Analyser
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _analyzeMeal,
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
                    'Analyser ce repas',
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

class _PortionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PortionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : Colors.white,
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
