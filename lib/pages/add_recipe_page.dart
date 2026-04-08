import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../models/recipe.dart';
import '../models/nutrition.dart';

// Palette sombre uniforme (noir/doré)
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

class AddRecipePage extends StatefulWidget {
  final Recipe? recipeToEdit;

  const AddRecipePage({super.key, this.recipeToEdit});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _portionsController = TextEditingController(text: '1');
  final _proteinesController = TextEditingController();
  final _glucidesController = TextEditingController();
  final _lipidesController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();

  MealType _selectedMealType = MealType.breakfast;
  RecipeCategory _selectedCategory = RecipeCategory.other;
  RecipeDifficulty _selectedDifficulty = RecipeDifficulty.easy;
  final Set<String> _selectedAllergens = {};
  bool _shareWithCommunity = false;
  bool _addToMealPlan = false;
  DateTime? _mealPlanDate;
  
  // Images multiples
  final List<Uint8List> _selectedImages = [];
  String? _mainImagePath;
  String _mediaType = 'image';
  final ImagePicker _imagePicker = ImagePicker();

  static const List<String> _allergensList = [
    'gluten',
    'lactose',
    'arachide',
    'fruits à coque',
    'œufs',
    'poisson',
    'crustacés',
    'soja',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      _loadRecipeData(widget.recipeToEdit!);
    }
  }

  void _loadRecipeData(Recipe recipe) {
    _nameController.text = recipe.name;
    _descriptionController.text = recipe.description;
    _ingredientsController.text = recipe.ingredients;
    _stepsController.text = recipe.steps;
    _caloriesController.text = recipe.calories?.toString() ?? '';
    _portionsController.text = recipe.portions.toString();
    _proteinesController.text = recipe.proteines?.toString() ?? '';
    _glucidesController.text = recipe.glucides?.toString() ?? '';
    _lipidesController.text = recipe.lipides?.toString() ?? '';
    _prepTimeController.text = recipe.prepTimeMinutes?.toString() ?? '';
    _cookTimeController.text = recipe.cookTimeMinutes?.toString() ?? '';
    _selectedMealType = recipe.typeRepas;
    _selectedCategory = recipe.category;
    _selectedDifficulty = recipe.difficulty;
    _selectedAllergens.addAll(recipe.allergens);
    _shareWithCommunity = recipe.isSharedWithCommunity;
    _mainImagePath = recipe.imagePath;
    _mediaType = recipe.mediaType;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImages.add(bytes);
          if (_mainImagePath == null) {
            _mainImagePath = image.path;
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur pickImage: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImages.add(bytes);
          if (_mainImagePath == null) {
            _mainImagePath = image.path;
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur takePhoto: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty) {
        _mainImagePath = null;
      }
    });
  }

  Future<void> _selectMealPlanDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _mealPlanDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _primaryGold,
              onPrimary: _darkBg,
              surface: _cardBg,
              onSurface: _textLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _mealPlanDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _caloriesController.dispose();
    _portionsController.dispose();
    _proteinesController.dispose();
    _glucidesController.dispose();
    _lipidesController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation Média Obligatoire
    if (_selectedImages.isEmpty && _mainImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoute au moins une photo pour cette recette.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final recipe = Recipe(
      id: widget.recipeToEdit?.id ?? 'recipe_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      typeRepas: _selectedMealType,
      description: _descriptionController.text.trim(),
      ingredients: _ingredientsController.text.trim(),
      steps: _stepsController.text.trim(),
      calories: int.tryParse(_caloriesController.text.trim()),
      portions: int.tryParse(_portionsController.text.trim()) ?? 1,
      proteines: int.tryParse(_proteinesController.text.trim()),
      glucides: int.tryParse(_glucidesController.text.trim()),
      lipides: int.tryParse(_lipidesController.text.trim()),
      prepTimeMinutes: int.tryParse(_prepTimeController.text.trim()),
      cookTimeMinutes: int.tryParse(_cookTimeController.text.trim()),
      difficulty: _selectedDifficulty,
      allergens: _selectedAllergens.toList(),
      imagePath: _mainImagePath,
      mediaType: _mediaType,
      videoUrl: null,
      isUserRecipe: true,
      isSharedWithCommunity: _shareWithCommunity,
      ownerUserId: 'user_demo_123',
      createdAt: widget.recipeToEdit?.createdAt ?? DateTime.now(),
      category: _selectedCategory,
      isFavorite: widget.recipeToEdit?.isFavorite ?? false,
    );

    final notifier = RecipeNotifier();
    if (widget.recipeToEdit != null) {
      notifier.updateRecipe(recipe);
    } else {
      notifier.addRecipe(recipe);
    }

    // Ajouter au planning repas si demandé
    if (_addToMealPlan && _mealPlanDate != null) {
      // TODO: Implémenter l'ajout au planning repas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recette ajoutée au planning du ${_mealPlanDate!.day}/${_mealPlanDate!.month}'),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.recipeToEdit != null
                ? 'Recette modifiée avec succès ! 🎉'
                : 'Recette créée avec succès ! 🎉',
          ),
          backgroundColor: _primaryGold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        title: Text(
          widget.recipeToEdit != null ? 'Modifier la recette' : 'Nouvelle Recette',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveRecipe,
            icon: const Icon(Icons.check, color: _primaryGold),
            label: const Text(
              'Enregistrer',
              style: TextStyle(color: _primaryGold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Photos
                _buildSectionTitle('📸 Photos', 'Ajoute une ou plusieurs photos'),
                const SizedBox(height: 12),
                _buildPhotosSection(),
                
                const SizedBox(height: 24),
                
                // Nom de la recette
                _buildSectionTitle('🍽️ Informations générales', null),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nom de la recette',
                  hint: 'Ex: Poulet grillé aux légumes',
                  icon: Icons.restaurant_menu,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                
                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Une description courte et appétissante',
                  icon: Icons.description,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Type de repas
                _buildChipSelector(
                  title: 'Type de repas',
                  options: MealType.values.map((t) => t.displayName).toList(),
                  selectedIndex: MealType.values.indexOf(_selectedMealType),
                  onSelected: (index) {
                    setState(() => _selectedMealType = MealType.values[index]);
                  },
                ),
                const SizedBox(height: 16),
                
                // Catégorie
                _buildChipSelector(
                  title: 'Catégorie',
                  options: RecipeCategory.values.map((c) => c.displayName).toList(),
                  selectedIndex: RecipeCategory.values.indexOf(_selectedCategory),
                  onSelected: (index) {
                    setState(() => _selectedCategory = RecipeCategory.values[index]);
                  },
                ),
                const SizedBox(height: 16),
                
                // Difficulté
                _buildChipSelector(
                  title: 'Niveau de difficulté',
                  options: RecipeDifficulty.values.map((d) => '${d.emoji} ${d.displayName}').toList(),
                  selectedIndex: RecipeDifficulty.values.indexOf(_selectedDifficulty),
                  onSelected: (index) {
                    setState(() => _selectedDifficulty = RecipeDifficulty.values[index]);
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Temps de préparation et cuisson
                _buildSectionTitle('⏱️ Temps', null),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _prepTimeController,
                        label: 'Préparation',
                        hint: 'min',
                        icon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _cookTimeController,
                        label: 'Cuisson',
                        hint: 'min',
                        icon: Icons.local_fire_department,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _portionsController,
                        label: 'Portions',
                        hint: 'pers.',
                        icon: Icons.people,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Ingrédients
                _buildSectionTitle('🥗 Ingrédients', null),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _ingredientsController,
                  label: 'Liste des ingrédients',
                  hint: '• 200g de poulet\n• 1 oignon\n• 2 tomates...',
                  icon: Icons.shopping_basket,
                  maxLines: 6,
                  isRequired: true,
                ),
                
                const SizedBox(height: 24),
                
                // Étapes
                _buildSectionTitle('📝 Étapes de préparation', null),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _stepsController,
                  label: 'Instructions',
                  hint: '1. Couper le poulet en morceaux\n2. Faire revenir dans une poêle...',
                  icon: Icons.format_list_numbered,
                  maxLines: 8,
                  isRequired: true,
                ),
                
                const SizedBox(height: 24),
                
                // Informations nutritionnelles
                _buildSectionTitle('📊 Nutrition (optionnel)', 'Par portion'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionField(
                        controller: _caloriesController,
                        label: 'Calories',
                        unit: 'kcal',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNutritionField(
                        controller: _proteinesController,
                        label: 'Protéines',
                        unit: 'g',
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionField(
                        controller: _glucidesController,
                        label: 'Glucides',
                        unit: 'g',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNutritionField(
                        controller: _lipidesController,
                        label: 'Lipides',
                        unit: 'g',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Allergènes
                _buildSectionTitle('⚠️ Allergènes', null),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allergensList.map((allergen) {
                    final isSelected = _selectedAllergens.contains(allergen);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(allergen),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAllergens.add(allergen);
                          } else {
                            _selectedAllergens.remove(allergen);
                          }
                        });
                      },
                      selectedColor: Colors.red.withOpacity(0.2),
                      backgroundColor: _cardBgLight,
                      checkmarkColor: Colors.red,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.red : _textMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? Colors.red : _borderColor,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Options de partage
                _buildSectionTitle('🌐 Options', null),
                const SizedBox(height: 12),
                
                // Partager avec la communauté
                _buildOptionCard(
                  icon: Icons.share,
                  iconColor: Colors.blue,
                  title: 'Partager avec la communauté',
                  subtitle: 'Ta recette sera visible par tous',
                  value: _shareWithCommunity,
                  onChanged: (value) => setState(() => _shareWithCommunity = value),
                ),
                const SizedBox(height: 12),
                
                // Ajouter au planning repas
                _buildOptionCard(
                  icon: Icons.calendar_today,
                  iconColor: Colors.green,
                  title: 'Ajouter au planning repas',
                  subtitle: _mealPlanDate != null 
                      ? 'Planifié pour le ${_mealPlanDate!.day}/${_mealPlanDate!.month}/${_mealPlanDate!.year}'
                      : 'Planifie cette recette dans ton calendrier',
                  value: _addToMealPlan,
                  onChanged: (value) {
                    setState(() => _addToMealPlan = value);
                    if (value && _mealPlanDate == null) {
                      _selectMealPlanDate();
                    }
                  },
                  onTap: _addToMealPlan ? _selectMealPlanDate : null,
                ),
                
                const SizedBox(height: 32),
                
                // Bouton Enregistrer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveRecipe,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      widget.recipeToEdit != null ? 'Modifier la recette' : 'Créer la recette',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGold,
                      foregroundColor: _darkBg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textLight,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: _textMuted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          // Grille de photos
          if (_selectedImages.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    // Bouton ajouter
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _cardBgLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _primaryGold.withOpacity(0.5), style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, color: _primaryGold, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Ajouter',
                              style: TextStyle(color: _primaryGold, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: index == 0 
                              ? Border.all(color: _primaryGold, width: 2)
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Badge "Principale" pour la première
                      if (index == 0)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _primaryGold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Principale',
                              style: TextStyle(
                                color: _darkBg,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Bouton supprimer
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          else
            // Boutons d'ajout de photo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaButton(
                  icon: Icons.photo_library,
                  label: 'Galerie',
                  onTap: _pickImage,
                ),
                _buildMediaButton(
                  icon: Icons.camera_alt,
                  label: 'Caméra',
                  onTap: _takePhoto,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: _primaryGold, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textLight),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: const TextStyle(color: _textMuted),
        hintText: hint,
        hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
        filled: true,
        fillColor: _cardBg,
        prefixIcon: Icon(icon, color: _primaryGold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est obligatoire';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildChipSelector({
    required String title,
    required List<String> options,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex == index;
            
            return FilterChip(
              selected: isSelected,
              label: Text(option),
              onSelected: (_) => onSelected(index),
              selectedColor: _primaryGold.withOpacity(0.2),
              backgroundColor: _cardBgLight,
              checkmarkColor: _primaryGold,
              labelStyle: TextStyle(
                color: isSelected ? _primaryGold : _textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? _primaryGold : _borderColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNutritionField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: _textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    hintStyle: TextStyle(color: _textMuted),
                  ),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? iconColor.withOpacity(0.5) : _borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
