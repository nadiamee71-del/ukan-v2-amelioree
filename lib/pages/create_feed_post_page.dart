import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../models/profile_feed.dart';
import '../models/theme_notifier.dart';

class CreateFeedPostPage extends StatefulWidget {
  final FeedPostType? initialType; // Type pré-sélectionné (optionnel)
  final XFile? initialImage; // Image pré-sélectionnée (optionnel)
  final XFile? initialVideo; // Vidéo pré-sélectionnée (optionnel)

  const CreateFeedPostPage({
    super.key,
    this.initialType,
    this.initialImage,
    this.initialVideo,
  });

  @override
  State<CreateFeedPostPage> createState() => _CreateFeedPostPageState();
}

class _CreateFeedPostPageState extends State<CreateFeedPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _workoutTypeController = TextEditingController();
  FeedPostType _selectedType = FeedPostType.sport;
  final _themeNotifier = ThemeNotifier();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  XFile? _selectedVideo;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    // Charger l'image ou vidéo pré-sélectionnée
    if (widget.initialImage != null) {
      _selectedImage = XFile(widget.initialImage!.path);
    }
    if (widget.initialVideo != null) {
      _selectedVideo = XFile(widget.initialVideo!.path);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _caloriesController.dispose();
    _workoutTypeController.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (!_formKey.currentState!.validate()) return;

    // Validation Média Obligatoire
    if (_selectedImage == null && _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoute une photo ou une vidéo pour publier.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation Sub-Category Sport
    if (_selectedType == FeedPostType.sport && _workoutTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie pour votre post sport.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final feedNotifier = ProfileFeedNotifier();
    final now = DateTime.now();

    final post = ProfileFeedPost(
      id: 'post_${now.microsecondsSinceEpoch}',
      type: _selectedType,
      caption: _captionController.text.trim(),
      createdAt: now,
      imageUrl: _selectedImage?.path,
      videoUrl: _selectedVideo?.path,
      recipeTitle: _selectedType == FeedPostType.recipe ? _titleController.text.trim() : null,
      calories: _selectedType == FeedPostType.recipe && _caloriesController.text.isNotEmpty
          ? int.tryParse(_caloriesController.text)
          : null,
      workoutType: _selectedType == FeedPostType.sport ? _workoutTypeController.text.trim() : null,
    );

    feedNotifier.addPost(post);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedType == FeedPostType.recipe
              ? 'Recette publiée avec succès !'
              : 'Publication créée avec succès !',
        ),
        backgroundColor: const Color(0xFFFFC300),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        title: const Text('Créer un post'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text(
              'Publier',
              style: TextStyle(
                color: Color(0xFFFFC300),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection du type de post
              Text(
                'Type de contenu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      type: FeedPostType.sport,
                      icon: Icons.fitness_center,
                      label: 'Publication',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      type: FeedPostType.recipe,
                      icon: Icons.restaurant,
                      label: 'Recette',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Upload Photo/Vidéo
              Text(
                'Média',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Appareil photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galerie'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickVideo(),
                      icon: const Icon(Icons.video_library),
                      label: const Text('Vidéo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Aperçu de l'image/vidéo sélectionnée
              if (_selectedImage != null || _selectedVideo != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _selectedImage != null
                            ? FutureBuilder<Uint8List>(
                                future: _selectedImage!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    );
                                  }
                                  return const Center(child: CircularProgressIndicator());
                                },
                              )
                            : _selectedVideo != null
                                ? Container(
                                    color: Colors.black,
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                              _selectedVideo = null;
                            });
                          },
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Titre (pour recettes) ou Type d'entraînement (pour publications)
              if (_selectedType == FeedPostType.recipe)
                _buildTextField(
                  controller: _titleController,
                  label: 'Titre de la recette',
                  hint: 'Ex: Salade protéinée express',
                  icon: Icons.restaurant,
                  isDarkMode: isDarkMode,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catégorie de post',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Exercice',
                        'Leçon',
                        'Motivation',
                        'Autre'
                      ].map((category) {
                        final isSelected = _workoutTypeController.text == category;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _workoutTypeController.text = selected ? category : '';
                            });
                          },
                          selectedColor: const Color(0xFFFFC300),
                          checkmarkColor: Colors.black87,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black87 : (isDarkMode ? Colors.white70 : Colors.black87),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    if (_workoutTypeController.text.isEmpty) ...[
                      const SizedBox(height: 8),
                       Text(
                        'Sélectionnez une catégorie',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 16),

              // Description/Légende
              _buildTextField(
                controller: _captionController,
                label: 'Description',
                hint: _selectedType == FeedPostType.recipe
                    ? 'Décrivez votre recette...'
                    : 'Partagez votre séance...',
                icon: Icons.description,
                isDarkMode: isDarkMode,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calories (uniquement pour les recettes)
              if (_selectedType == FeedPostType.recipe)
                _buildTextField(
                  controller: _caloriesController,
                  label: 'Calories (optionnel)',
                  hint: 'Ex: 350',
                  icon: Icons.local_fire_department,
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.number,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _selectedVideo = null; // Annuler la vidéo si une image est sélectionnée
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedVideo = video;
          _selectedImage = null; // Annuler l'image si une vidéo est sélectionnée
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de la vidéo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTypeButton({
    required FeedPostType type,
    required IconData icon,
    required String label,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFC300)
              : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFC300)
                : (isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.black87
                  : (isDarkMode ? Colors.white70 : Colors.black54),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.black87
                    : (isDarkMode ? Colors.white70 : Colors.black54),
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
    required bool isDarkMode,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
            ),
            prefixIcon: Icon(icon, color: isDarkMode ? Colors.white54 : Colors.grey.shade600),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFFC300),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

