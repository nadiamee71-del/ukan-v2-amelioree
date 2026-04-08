import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/coach_content.dart';
import '../models/theme_notifier.dart';

class CreateCoachContentPage extends StatefulWidget {
  final String coachId;
  final CoachContentType? initialType; // Type pré-sélectionné (optionnel)
  final File? initialImage; // Image pré-sélectionnée (optionnel)
  final File? initialVideo; // Vidéo pré-sélectionnée (optionnel)

  const CreateCoachContentPage({
    super.key,
    required this.coachId,
    this.initialType,
    this.initialImage,
    this.initialVideo,
  });

  @override
  State<CreateCoachContentPage> createState() => _CreateCoachContentPageState();
}

class _CreateCoachContentPageState extends State<CreateCoachContentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationMinutesController = TextEditingController();
  final _categoryController = TextEditingController();
  final _levelController = TextEditingController();
  
  CoachContentType _selectedType = CoachContentType.post;
  AccessType _selectedAccessType = AccessType.free;
  final _themeNotifier = ThemeNotifier();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  File? _selectedVideo;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    // Charger l'image ou vidéo pré-sélectionnée
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
    }
    if (widget.initialVideo != null) {
      _selectedVideo = widget.initialVideo;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _priceController.dispose();
    _durationMinutesController.dispose();
    _categoryController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _submitContent() {
    if (!_formKey.currentState!.validate()) return;

    final contentNotifier = CoachContentNotifier();
    final now = DateTime.now();

    // Durée pour le coaching
    Duration? duration;
    if (_selectedType == CoachContentType.coaching && _durationMinutesController.text.isNotEmpty) {
      final minutes = int.tryParse(_durationMinutesController.text);
      if (minutes != null && minutes > 0) {
        duration = Duration(minutes: minutes);
      }
    }

    // Prix pour achat unique
    double? price;
    if (_selectedAccessType == AccessType.oneTime && _priceController.text.isNotEmpty) {
      price = double.tryParse(_priceController.text);
    }

    final content = CoachContent(
      id: 'content_${now.microsecondsSinceEpoch}',
      coachId: widget.coachId,
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath: _selectedImage?.path,
      videoPath: _selectedVideo?.path,
      accessType: _selectedAccessType,
      price: price,
      createdAt: now,
      duration: duration,
      calories: _selectedType == CoachContentType.recipe && _caloriesController.text.isNotEmpty
          ? int.tryParse(_caloriesController.text)
          : null,
      category: _selectedType == CoachContentType.coaching && _categoryController.text.isNotEmpty
          ? _categoryController.text.trim()
          : null,
      level: _selectedType == CoachContentType.coaching && _levelController.text.isNotEmpty
          ? _levelController.text.trim()
          : null,
    );

    contentNotifier.addContent(content);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _getSuccessMessage(),
        ),
        backgroundColor: const Color(0xFFFFC300),
      ),
    );

    Navigator.of(context).pop();
  }

  String _getSuccessMessage() {
    switch (_selectedType) {
      case CoachContentType.post:
        return 'Publication créée avec succès !';
      case CoachContentType.recipe:
        return 'Recette publiée avec succès !';
      case CoachContentType.coaching:
        return 'Contenu de coaching créé avec succès !';
      case CoachContentType.live:
        return 'Live programmé avec succès !';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        title: const Text('Créer du contenu'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submitContent,
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
              // Sélection du type de contenu
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
                      type: CoachContentType.post,
                      icon: Icons.article,
                      label: 'Publication',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeButton(
                      type: CoachContentType.recipe,
                      icon: Icons.restaurant,
                      label: 'Recette',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeButton(
                      type: CoachContentType.coaching,
                      icon: Icons.fitness_center,
                      label: 'Coaching',
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
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
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

              // Titre
              _buildTextField(
                controller: _titleController,
                label: _getTitleLabel(),
                hint: _getTitleHint(),
                icon: Icons.title,
                isDarkMode: isDarkMode,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: _getDescriptionHint(),
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

              // Champs spécifiques selon le type
              if (_selectedType == CoachContentType.recipe) ...[
                _buildTextField(
                  controller: _caloriesController,
                  label: 'Calories (optionnel)',
                  hint: 'Ex: 350',
                  icon: Icons.local_fire_department,
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              if (_selectedType == CoachContentType.coaching) ...[
                _buildTextField(
                  controller: _categoryController,
                  label: 'Catégorie (optionnel)',
                  hint: 'Ex: Cardio, Renforcement, Stretching...',
                  icon: Icons.category,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _levelController,
                  label: 'Niveau (optionnel)',
                  hint: 'Ex: Débutant, Intermédiaire, Avancé',
                  icon: Icons.trending_up,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _durationMinutesController,
                  label: 'Durée en minutes (optionnel)',
                  hint: 'Ex: 30',
                  icon: Icons.access_time,
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              // Type d'accès
              Text(
                'Type d\'accès',
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
                    child: _buildAccessTypeButton(
                      type: AccessType.free,
                      label: 'Gratuit',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAccessTypeButton(
                      type: AccessType.subscription,
                      label: 'Abonné',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAccessTypeButton(
                      type: AccessType.oneTime,
                      label: 'Achat',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Prix (si achat unique)
              if (_selectedAccessType == AccessType.oneTime)
                _buildTextField(
                  controller: _priceController,
                  label: 'Prix (€)',
                  hint: 'Ex: 4.99',
                  icon: Icons.euro,
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (_selectedAccessType == AccessType.oneTime) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer un prix';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Prix invalide';
                      }
                    }
                    return null;
                  },
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
          _selectedImage = File(image.path);
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
          _selectedVideo = File(video.path);
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

  String _getTitleLabel() {
    switch (_selectedType) {
      case CoachContentType.post:
        return 'Titre de la publication';
      case CoachContentType.recipe:
        return 'Titre de la recette';
      case CoachContentType.coaching:
        return 'Titre du contenu';
      case CoachContentType.live:
        return 'Titre du live';
    }
  }

  String _getTitleHint() {
    switch (_selectedType) {
      case CoachContentType.post:
        return 'Ex: Nouvelle séance en salle !';
      case CoachContentType.recipe:
        return 'Ex: Salade protéinée express';
      case CoachContentType.coaching:
        return 'Ex: Full Body Express (15 min)';
      case CoachContentType.live:
        return 'Ex: Live : Séance Abdos Express';
    }
  }

  String _getDescriptionHint() {
    switch (_selectedType) {
      case CoachContentType.post:
        return 'Partagez votre séance...';
      case CoachContentType.recipe:
        return 'Décrivez votre recette...';
      case CoachContentType.coaching:
        return 'Décrivez le contenu de coaching...';
      case CoachContentType.live:
        return 'Décrivez le live...';
    }
  }

  Widget _buildTypeButton({
    required CoachContentType type,
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
        padding: const EdgeInsets.all(12),
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
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.black87
                    : (isDarkMode ? Colors.white70 : Colors.black54),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessTypeButton({
    required AccessType type,
    required String label,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedAccessType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAccessType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.black87
                : (isDarkMode ? Colors.white70 : Colors.black54),
          ),
          textAlign: TextAlign.center,
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

