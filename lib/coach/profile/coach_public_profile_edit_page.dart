import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/coach_directory.dart';
import '../../coach_detail_page.dart';

// Couleur de marque (lisible dans les deux thèmes).
const Color _primaryGold = Color(0xFFFFC300);

/// Fournit l'ImageProvider adapté selon que le chemin est un asset ou un fichier.
ImageProvider? coachAvatarProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;
  if (photoUrl.startsWith('assets/')) return AssetImage(photoUrl);
  return FileImage(File(photoUrl));
}

/// Page de gestion du profil public du coach connecté.
///
/// Édite la MÊME source que la fiche publique (`CoachDirectoryNotifier` /
/// `CoachProfile`). Les modifications sont persistées localement via
/// SharedPreferences. Le bouton « Prévisualiser » ouvre `CoachDetailPage`.
class CoachPublicProfileEditPage extends StatefulWidget {
  final String coachId;

  const CoachPublicProfileEditPage({super.key, this.coachId = 'coach_1'});

  @override
  State<CoachPublicProfileEditPage> createState() =>
      _CoachPublicProfileEditPageState();
}

class _CoachPublicProfileEditPageState
    extends State<CoachPublicProfileEditPage> {
  final _directory = CoachDirectoryNotifier();
  final _formKey = GlobalKey<FormState>();

  // Couleurs dépendantes du thème (suivent le mode clair/sombre global).
  Color get _cardBg => Theme.of(context).colorScheme.surface;
  Color get _cardBgLight => Theme.of(context).colorScheme.surfaceContainerHighest;
  Color get _textLight => Theme.of(context).colorScheme.onSurface;
  Color get _textMuted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _borderColor => Theme.of(context).dividerColor;

  late final TextEditingController _name;
  late final TextEditingController _specialty;
  late final TextEditingController _otherSpecialties;
  late final TextEditingController _city;
  late final TextEditingController _bio;
  late final TextEditingController _years;
  late final TextEditingController _certifications;
  late final TextEditingController _shortPresentation;
  late final TextEditingController _priceInfo;

  bool _isCertified = false;
  String? _photoUrl;
  bool _saving = false;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    final coach = _directory.getCoachById(widget.coachId);
    if (coach == null) {
      _notFound = true;
      _name = TextEditingController();
      _specialty = TextEditingController();
      _otherSpecialties = TextEditingController();
      _city = TextEditingController();
      _bio = TextEditingController();
      _years = TextEditingController();
      _certifications = TextEditingController();
      _shortPresentation = TextEditingController();
      _priceInfo = TextEditingController();
      return;
    }
    _name = TextEditingController(text: coach.name);
    _specialty = TextEditingController(text: coach.specialty);
    _otherSpecialties =
        TextEditingController(text: coach.detailedSpecialties.join('\n'));
    _city = TextEditingController(text: coach.city);
    _bio = TextEditingController(text: coach.bio);
    _years = TextEditingController(
        text: coach.yearsExperience != null ? '${coach.yearsExperience}' : '');
    _certifications =
        TextEditingController(text: coach.certifications.join('\n'));
    _shortPresentation =
        TextEditingController(text: coach.shortPresentation ?? '');
    _priceInfo = TextEditingController(text: coach.priceInfo ?? '');
    _isCertified = coach.isCertified;
    _photoUrl = coach.photoUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _specialty.dispose();
    _otherSpecialties.dispose();
    _city.dispose();
    _bio.dispose();
    _years.dispose();
    _certifications.dispose();
    _shortPresentation.dispose();
    _priceInfo.dispose();
    super.dispose();
  }

  List<String> _splitLines(String raw) => raw
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _photoUrl = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de charger l\'image : $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final coach = _directory.getCoachById(widget.coachId);
    if (coach == null) return;

    setState(() => _saving = true);

    final updated = coach.copyWith(
      name: _name.text.trim(),
      specialty: _specialty.text.trim(),
      city: _city.text.trim(),
      bio: _bio.text.trim(),
      isCertified: _isCertified,
      photoUrl: _photoUrl,
      certifications: _splitLines(_certifications.text),
      detailedSpecialties: _splitLines(_otherSpecialties.text),
      yearsExperience: int.tryParse(_years.text.trim()),
      shortPresentation: _shortPresentation.text.trim(),
      priceInfo: _priceInfo.text.trim(),
    );

    await _directory.updateCoachProfile(updated);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil public enregistré'),
        backgroundColor: _primaryGold,
      ),
    );
  }

  void _preview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachDetailPage(coachId: widget.coachId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_notFound) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mon profil public'),
        ),
        body: Center(
          child: Text('Coach introuvable', style: TextStyle(color: _textMuted)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mon profil public',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Prévisualiser',
            onPressed: _preview,
            icon: const Icon(Icons.visibility_outlined, color: _primaryGold),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              _buildAvatar(),
              const SizedBox(height: 24),
              _sectionTitle('Informations principales'),
              _field(_name, 'Nom affiché', validator: _required),
              _field(_specialty, 'Spécialité principale', validator: _required),
              _field(_city, 'Ville'),
              _field(_years, 'Années d\'expérience',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              _certifiedSwitch(),
              const SizedBox(height: 16),
              _sectionTitle('Présentation'),
              _field(_shortPresentation, 'Présentation courte (accroche)'),
              _field(_bio, 'Description complète', maxLines: 5),
              const SizedBox(height: 16),
              _sectionTitle('Spécialités & certifications'),
              _field(_otherSpecialties, 'Autres spécialités (une par ligne)',
                  maxLines: 4),
              _field(_certifications,
                  'Certifications / badges (une par ligne)',
                  maxLines: 4),
              const SizedBox(height: 16),
              _sectionTitle('Tarif / informations utiles'),
              _field(_priceInfo, 'Ex. 45€ / séance, forfaits…', maxLines: 2),
              const SizedBox(height: 28),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ requis' : null;

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: _textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: _textLight),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _textMuted),
          filled: true,
          fillColor: _cardBgLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primaryGold, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _certifiedSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: SwitchListTile(
        value: _isCertified,
        activeThumbColor: _primaryGold,
        title: Text('Coach certifié',
            style: TextStyle(
                color: _textLight, fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text('Affiche le badge « Coach Certifié »',
            style: TextStyle(color: _textMuted, fontSize: 12)),
        onChanged: (v) => setState(() => _isCertified = v),
      ),
    );
  }

  Widget _buildAvatar() {
    final provider = coachAvatarProvider(_photoUrl);
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: _cardBgLight,
                backgroundImage: provider,
                child: provider == null
                    ? Icon(Icons.person, size: 52, color: _textMuted)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: _primaryGold,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _pickAvatar,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.camera_alt, size: 18, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _pickAvatar,
            child: const Text('Changer la photo',
                style: TextStyle(color: _primaryGold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.save),
            label: const Text('Enregistrer',
                style: TextStyle(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _preview,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Prévisualiser la fiche publique',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _textLight,
              side: BorderSide(color: _borderColor, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
