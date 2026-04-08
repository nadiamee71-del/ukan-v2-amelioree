import 'package:flutter/material.dart';
import '../models/coach_business.dart';

// Couleurs professionnelles : Marron et Gris clair pour Coach Business
const Color _marronPrincipalBusiness = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonceBusiness = Color(0xFF5D4037); // Material Brown 700
const Color _marronClairBusiness = Color(0xFFA1887F); // Material Brown 300
const Color _grisClairBusiness = Color(0xFFE0E0E0); // Material Grey 300
const Color _grisPrincipalBusiness = Color(0xFF9E9E9E); // Material Grey 500
const Color _grisFonceBusiness = Color(0xFF616161); // Material Grey 700

class CoachBrandingPage extends StatefulWidget {
  const CoachBrandingPage({super.key});

  @override
  State<CoachBrandingPage> createState() => _CoachBrandingPageState();
}

class _CoachBrandingPageState extends State<CoachBrandingPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandNameController = TextEditingController();
  final _taglineController = TextEditingController();
  String _selectedColor = 'jaune';
  String _selectedTone = 'Motivée';
  final _brandingNotifier = CoachBrandingNotifier();

  // Données locales pour la prévisualisation (en dur pour la démo)
  String _displayName = 'Coach Bilel';
  String _displayTagline = 'Transforme ton corps, pas ta vie sociale.';
  String _displayColor = 'jaune';
  String _displayTone = 'Motivée, Exigeante, Bienveillante';

  @override
  void initState() {
    super.initState();
    final branding = _brandingNotifier.branding;
    _brandNameController.text = branding.brandName.isEmpty ? 'Coach Bilel' : branding.brandName;
    _taglineController.text = branding.tagline.isEmpty ? 'Transforme ton corps, pas ta vie sociale.' : branding.tagline;
    _selectedColor = branding.primaryColor;
    _displayName = _brandNameController.text;
    _displayTagline = _taglineController.text;
    _displayColor = _selectedColor;
    _brandingNotifier.addListener(_onBrandingChanged);
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _taglineController.dispose();
    _brandingNotifier.removeListener(_onBrandingChanged);
    super.dispose();
  }

  void _onBrandingChanged() {
    if (mounted) setState(() {});
  }

  void _updatePreview() {
    setState(() {
      _displayName = _brandNameController.text.trim().isEmpty
          ? 'Coach Bilel'
          : _brandNameController.text.trim();
      _displayTagline = _taglineController.text.trim().isEmpty
          ? 'Transforme ton corps, pas ta vie sociale.'
          : _taglineController.text.trim();
      _displayColor = _selectedColor;
      _displayTone = _getToneText(_selectedTone);
    });
  }

  void _saveBranding() {
    if (_formKey.currentState!.validate()) {
      _updatePreview();
      _brandingNotifier.updateBranding(
        CoachBranding(
          brandName: _brandNameController.text.trim(),
          tagline: _taglineController.text.trim(),
          primaryColor: _selectedColor,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Branding mis à jour (démo)'),
          backgroundColor: _marronFonceBusiness,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getToneText(String tone) {
    switch (tone) {
      case 'Sérieux':
        return 'Sérieux, Professionnel, Rigoureux';
      case 'Fun':
        return 'Fun, Dynamique, Énergique';
      case 'Militaire':
        return 'Strict, Discipliné, Exigeant';
      case 'Luxe':
        return 'Élégant, Premium, Exclusif';
      default:
        return 'Motivée, Exigeante, Bienveillante';
    }
  }

  Color _getColorValue(String colorName) {
    switch (colorName) {
      case 'jaune':
        return _marronPrincipalBusiness;
      case 'noir':
        return _marronFonceBusiness;
      case 'bleu':
        return _grisPrincipalBusiness;
      case 'rouge':
        return _marronClairBusiness;
      default:
        return _marronPrincipalBusiness;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _grisClairBusiness,
      appBar: AppBar(
        backgroundColor: _marronFonceBusiness,
        foregroundColor: Colors.white,
        title: const Text('Mon identité de coach'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de prévisualisation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aperçu de ta vitrine',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nom du coach
                    Text(
                      _displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _marronFonceBusiness,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Slogan
                    Text(
                      _displayTagline,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Palette de couleurs
                    const Text(
                      'Palette de couleurs',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ColorCircle(color: _getColorValue(_displayColor)),
                        const SizedBox(width: 12),
                        _ColorCircle(color: _marronFonceBusiness),
                        const SizedBox(width: 12),
                        _ColorCircle(color: Colors.grey.shade600),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Tonalité
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tonalité :',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _displayTone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Formulaire
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personnaliser mon branding',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Personnalise ton identité de coach.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _brandNameController,
                        onChanged: (_) => _updatePreview(),
                        decoration: InputDecoration(
                          labelText: 'Nom affiché',
                          hintText: 'Ex: Coach Bilel',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _taglineController,
                        onChanged: (_) => _updatePreview(),
                        decoration: InputDecoration(
                          labelText: 'Slogan',
                          hintText: 'Ex: Transforme ton corps, pas ta vie sociale.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Couleur principale',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedColor,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                        ),
                        items: ['jaune', 'noir', 'bleu', 'rouge']
                            .map((color) => DropdownMenuItem(
                                  value: color,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: _getColorValue(color),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.black26),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        color.substring(0, 1).toUpperCase() + color.substring(1),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedColor = value;
                              _updatePreview();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tonalité principale',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedTone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                        ),
                        items: ['Motivée', 'Sérieux', 'Fun', 'Militaire', 'Luxe']
                            .map((tone) => DropdownMenuItem(
                                  value: tone,
                                  child: Text(tone),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTone = value;
                              _updatePreview();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveBranding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _marronFonceBusiness,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Mettre à jour (démo)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;

  const _ColorCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
    );
  }
}
