import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coach_profile.dart';
import '../models/coach_diploma.dart';
import '../models/coach_directory.dart' show CoachDirectoryNotifier;
import '../coach/coach_session.dart';
import '../main.dart';

class SignupCoachPage extends StatefulWidget {
  const SignupCoachPage({super.key});

  @override
  State<SignupCoachPage> createState() => _SignupCoachPageState();
}

class _SignupCoachPageState extends State<SignupCoachPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _siretController = TextEditingController();
  final _travelRadiusController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

  // Diplômes
  final List<Map<String, dynamic>> _diplomas = [];
  final Map<int, TextEditingController> _diplomaTitleControllers = {};
  final Map<int, TextEditingController> _diplomaInstitutionControllers = {};
  final Map<int, TextEditingController> _diplomaYearControllers = {};

  // State
  List<String> _coachTypes = [];
  final _otherCoachTypeController = TextEditingController();
  bool _offersVisio = false;
  bool _offersHomeCoaching = false;
  bool _offersGymCoaching = false;
  bool _offersVideoReplay = false;
  List<String> _sessionTypes = [];
  List<String> _availableDays = [];
  List<String> _availableTimeSlots = [];

  // Autorisations RGPD
  bool _consentRGPD = false;
  bool _consentVideoReplay = false;
  bool _consentClientVisibility = false;
  bool _consentDataProcessing = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplissage avec des valeurs de test (mode démo)
    _firstNameController.text = 'A';
    _lastNameController.text = 'B';
    _emailController.text = 'coach@test.com';
    _phoneController.text = '0123456789';
    _experienceController.text = '5';
    _bioController.text = 'Test';
    _coachTypes = ['Coach sportif'];
    _sessionTypes = ['Musculation / prise de masse'];
    _offersVisio = true;
    _availableDays = ['Lundi'];
    _availableTimeSlots = ['Matin'];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _siretController.dispose();
    _travelRadiusController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _otherCoachTypeController.dispose();
    for (var controller in _diplomaTitleControllers.values) {
      controller.dispose();
    }
    for (var controller in _diplomaInstitutionControllers.values) {
      controller.dispose();
    }
    for (var controller in _diplomaYearControllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addDiploma() {
    setState(() {
      final id = DateTime.now().millisecondsSinceEpoch;
      _diplomas.add({'id': id});
      _diplomaTitleControllers[id] = TextEditingController();
      _diplomaInstitutionControllers[id] = TextEditingController();
      _diplomaYearControllers[id] = TextEditingController();
    });
  }

  void _removeDiploma(int id) {
    setState(() {
      _diplomas.removeWhere((d) => d['id'] == id);
      _diplomaTitleControllers[id]?.dispose();
      _diplomaInstitutionControllers[id]?.dispose();
      _diplomaYearControllers[id]?.dispose();
      _diplomaTitleControllers.remove(id);
      _diplomaInstitutionControllers.remove(id);
      _diplomaYearControllers.remove(id);
    });
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_coachTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un type de coach'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_sessionTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un type de séance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation des consentements RGPD
    if (!_consentRGPD) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous devez accepter la politique de confidentialité pour continuer',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_consentDataProcessing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous devez autoriser le traitement de vos données professionnelles',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation spécifique pour visionnage/replay
    if (_offersVideoReplay || _offersGymCoaching) {
      if (!_consentVideoReplay) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vous devez autoriser l\'enregistrement vidéo si vous proposez des séances en visionnage',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (!_consentClientVisibility) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vous devez autoriser la visibilité des clients dans les vidéos',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    // Construction de la liste des diplômes
    final diplomas = _diplomas.map((d) {
      final id = d['id'] as int;
      return CoachDiploma(
        title: _diplomaTitleControllers[id]?.text.trim() ?? '',
        institution: _diplomaInstitutionControllers[id]?.text.trim().isEmpty ??
                true
            ? null
            : _diplomaInstitutionControllers[id]!.text.trim(),
        year: _diplomaYearControllers[id]?.text.trim().isEmpty ?? true
            ? null
            : int.tryParse(_diplomaYearControllers[id]!.text.trim()),
        documentPath: null, // Mode démo
      );
    }).toList();

    // Gestion du type "Autre"
    final coachTypes = List<String>.from(_coachTypes);
    if (coachTypes.contains('Autre') &&
        _otherCoachTypeController.text.trim().isNotEmpty) {
      coachTypes.remove('Autre');
      coachTypes.add(_otherCoachTypeController.text.trim());
    }

    // Création du profil
    final profile = CoachProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      coachTypes: coachTypes,
      experienceYears: int.parse(_experienceController.text.trim()),
      bio: _bioController.text.trim(),
      siret: _siretController.text.trim().isEmpty
          ? null
          : _siretController.text.trim(),
      profilePhotoPath: null, // Mode démo
      diplomas: diplomas,
      sessionTypes: _sessionTypes,
      offersVisio: _offersVisio,
      offersHomeCoaching: _offersHomeCoaching,
      offersGymCoaching: _offersGymCoaching,
      offersVideoReplay: _offersVideoReplay,
      travelRadiusKm: _travelRadiusController.text.trim().isEmpty
          ? null
          : double.tryParse(_travelRadiusController.text.trim()),
      priceMin: _priceMinController.text.trim().isEmpty
          ? null
          : double.tryParse(_priceMinController.text.trim()),
      priceMax: _priceMaxController.text.trim().isEmpty
          ? null
          : double.tryParse(_priceMaxController.text.trim()),
      availableDays: _availableDays,
      availableTimeSlots: _availableTimeSlots,
      consentRGPD: _consentRGPD,
      consentDataProcessing: _consentDataProcessing,
      consentVideoReplay: _consentVideoReplay,
      consentClientVisibility: _consentClientVisibility,
    );

    // Log pour debug
    debugPrint('=== PROFIL COACH CRÉÉ ===');
    debugPrint(profile.toJson().toString());

    // Sauvegarde en localStorage (SharedPreferences)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fitpro_role', 'coach');
      await prefs.setString('fitpro_profile', jsonEncode(profile.toJson()));
      await prefs.setBool('fitpro_is_logged_in', true);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde: $e');
    }

    // Synchronise l'identité du coach connecté avec la source unique
    // (CoachDirectoryNotifier) : le profil public, l'annuaire, la carte, la
    // fiche coach et les réservations affichent désormais CE coach et non plus
    // les données de démonstration « Sophie Martin ».
    try {
      final directory = CoachDirectoryNotifier();
      final base = directory.getCoachById(CoachSession.defaultCoachId);
      if (base != null) {
        final fullName = '${profile.firstName} ${profile.lastName}'.trim();
        String? priceInfo;
        if (profile.priceMin != null && profile.priceMax != null) {
          priceInfo =
              '${profile.priceMin!.toStringAsFixed(0)}€ - ${profile.priceMax!.toStringAsFixed(0)}€ / séance';
        } else if (profile.priceMin != null) {
          priceInfo = 'À partir de ${profile.priceMin!.toStringAsFixed(0)}€';
        }
        await directory.updateCoachProfile(
          base.copyWith(
            name: fullName.isNotEmpty ? fullName : null,
            specialty: coachTypes.isNotEmpty ? coachTypes.first : null,
            city: profile.city,
            bio: profile.bio.trim().isNotEmpty ? profile.bio.trim() : null,
            isCertified: diplomas.isNotEmpty,
            certifications: diplomas.map((d) => d.title).toList(),
            detailedSpecialties: coachTypes.isNotEmpty ? coachTypes : null,
            yearsExperience: profile.experienceYears,
            priceInfo: priceInfo,
          ),
        );
      }
      await CoachSession().setCoachId(CoachSession.defaultCoachId);
    } catch (e) {
      debugPrint('Erreur synchronisation profil coach: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Redirection vers le dashboard (Coach : arrivée directe sur le Dashboard Coach)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UkanHomeShell(initialRole: 'coach')),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Inscription Coach',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFFFC300).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Informations personnelles
                    _buildSectionTitle('1. Informations personnelles'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'Prénom *',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ obligatoire' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Nom *',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ obligatoire' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email *',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Champ obligatoire';
                        if (!v!.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Téléphone *',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ obligatoire' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Adresse',
                      icon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'Ville',
                            icon: Icons.location_city_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _postalCodeController,
                            label: 'Code postal',
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _countryController,
                      label: 'Pays',
                      icon: Icons.public_outlined,
                    ),

                    const SizedBox(height: 32),
                    // Section 2: Profil professionnel
                    _buildSectionTitle('2. Profil professionnel'),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                      label: 'Type de coach *',
                      options: const [
                        'Coach sportif',
                        'Coach nutrition',
                        'Coach bien-être',
                        'Yoga / Pilates',
                        'Danse / Zumba',
                        'Boxe / Sports de combat',
                        'Autre',
                      ],
                      selected: _coachTypes,
                      onChanged: (selected) {
                        setState(() {
                          _coachTypes = selected;
                          if (!selected.contains('Autre')) {
                            _otherCoachTypeController.clear();
                          }
                        });
                      },
                    ),
                    if (_coachTypes.contains('Autre')) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _otherCoachTypeController,
                        label: 'Précisez votre type de coach',
                        icon: Icons.edit_outlined,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _experienceController,
                      label: 'Années d\'expérience *',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Champ obligatoire';
                        final val = int.tryParse(v!);
                        if (val == null || val < 0) return 'Valeur invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _bioController,
                      label: 'Description courte du coach *',
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ obligatoire' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _siretController,
                      label: 'Numéro SIRET',
                      icon: Icons.business_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildFileUpload(
                      label: 'Photo de profil',
                      onTap: () {
                        // Mode démo : simuler l'upload
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Upload simulé (mode démo)'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    // Section 3: Diplômes et certifications
                    _buildSectionTitle('3. Diplômes et certifications'),
                    const SizedBox(height: 16),
                    ..._diplomas.map((diploma) {
                      final id = diploma['id'] as int;
                      return _buildDiplomaCard(id);
                    }),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _addDiploma,
                      icon: const Icon(Icons.add),
                      label: const Text('+ Ajouter un diplôme'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFC300),
                        side: const BorderSide(color: Color(0xFFFFC300)),
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Section 4: Types de séances proposées
                    _buildSectionTitle('4. Types de séances proposées *'),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                      label: '',
                      options: const [
                        'Perte de poids',
                        'Musculation / prise de masse',
                        'Cardio / HIIT',
                        'Remise en forme',
                        'Stretching',
                        'Yoga / Pilates',
                        'Danse / Zumba',
                        'Boxe / Combat',
                        'Coaching nutritionnel',
                        'Programmes personnalisés',
                        'Séances en visio',
                        'Cours/séances en visionnage (replay)',
                      ],
                      selected: _sessionTypes,
                      onChanged: (selected) =>
                          setState(() => _sessionTypes = selected),
                    ),

                    const SizedBox(height: 32),
                    // Section 5: Modalités & organisation
                    _buildSectionTitle('5. Modalités & organisation'),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label: 'Propose du coaching en visio ?',
                      value: _offersVisio,
                      onChanged: (v) => setState(() => _offersVisio = v),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label: 'Propose du coaching à domicile ?',
                      value: _offersHomeCoaching,
                      onChanged: (v) => setState(() => _offersHomeCoaching = v),
                    ),
                    if (_offersHomeCoaching) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _travelRadiusController,
                        label: 'Rayon de déplacement (km)',
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label: 'Propose du coaching en salle ?',
                      value: _offersGymCoaching,
                      onChanged: (v) => setState(() => _offersGymCoaching = v),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label: 'Propose des cours/séances en visionnage (replay) ?',
                      value: _offersVideoReplay,
                      onChanged: (v) => setState(() => _offersVideoReplay = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _priceMinController,
                            label: 'Prix minimum par séance (€)',
                            icon: Icons.euro_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _priceMaxController,
                            label: 'Prix maximum par séance (€)',
                            icon: Icons.euro_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                      label: 'Jours de disponibilité',
                      options: const [
                        'Lundi',
                        'Mardi',
                        'Mercredi',
                        'Jeudi',
                        'Vendredi',
                        'Samedi',
                        'Dimanche',
                      ],
                      selected: _availableDays,
                      onChanged: (selected) =>
                          setState(() => _availableDays = selected),
                    ),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                      label: 'Plages horaires',
                      options: const ['Matin', 'Après-midi', 'Soir'],
                      selected: _availableTimeSlots,
                      onChanged: (selected) =>
                          setState(() => _availableTimeSlots = selected),
                    ),

                    const SizedBox(height: 32),
                    // Section 6: Autorisations RGPD & Consentements
                    _buildSectionTitle('6. Autorisations & Consentements RGPD'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.privacy_tip_outlined,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Protection des données personnelles',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Conformément au RGPD, nous avons besoin de votre consentement explicite pour certaines utilisations de vos données et celles de vos clients.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Consentement RGPD général
                    _buildCheckbox(
                      label:
                          'J\'accepte la politique de confidentialité et le traitement de mes données personnelles par Ukan. *',
                      value: _consentRGPD,
                      onChanged: (v) => setState(() => _consentRGPD = v ?? false),
                    ),
                    const SizedBox(height: 12),
                    // Consentement traitement des données
                    _buildCheckbox(
                      label:
                          'J\'autorise Ukan à traiter et stocker mes données professionnelles (diplômes, certifications, coordonnées) pour la mise en relation avec des clients. *',
                      value: _consentDataProcessing,
                      onChanged: (v) =>
                          setState(() => _consentDataProcessing = v ?? false),
                    ),
                    // Autorisations spécifiques pour visionnage/replay
                    if (_offersVideoReplay || _offersGymCoaching) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 18,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Autorisations pour séances en visionnage/replay',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildCheckbox(
                              label:
                                  'J\'autorise l\'enregistrement et la diffusion en replay de mes séances de coaching. *',
                              value: _consentVideoReplay,
                              onChanged: (v) => setState(
                                  () => _consentVideoReplay = v ?? false),
                            ),
                            const SizedBox(height: 12),
                            _buildCheckbox(
                              label:
                                  'J\'autorise que mes clients puissent être visibles dans les vidéos de séances enregistrées dans ma salle/établissement. *',
                              value: _consentClientVisibility,
                              onChanged: (v) => setState(
                                  () => _consentClientVisibility = v ?? false),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Note : Vous devez informer vos clients et obtenir leur consentement avant de les filmer.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Lien vers les conditions
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          // En mode démo, juste afficher un message
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Conditions d\'utilisation'),
                              content: const Text(
                                'Les conditions d\'utilisation complètes seront disponibles dans la version finale de l\'application.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text(
                          'Voir les conditions d\'utilisation complètes',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    // Bouton de soumission
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC300),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide.none,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Text(
                                'Créer mon compte',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) =>
                              route.settings.name == '/' ||
                              route.isFirst);
                        },
                        child: Text(
                          'Déjà un compte ? Se connecter',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFC300), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFC300), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFFC300),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFFC300),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxGroup({
    required String label,
    required List<String> options,
    required List<String> selected,
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ...options.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: selected.contains(option),
            onChanged: (checked) {
              final newSelected = List<String>.from(selected);
              if (checked == true) {
                newSelected.add(option);
              } else {
                newSelected.remove(option);
              }
              onChanged(newSelected);
            },
            activeColor: const Color(0xFFFFC300),
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildFileUpload({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiplomaCard(int id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diplôme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeDiploma(id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _diplomaTitleControllers[id]!,
            label: 'Titre du diplôme *',
            icon: Icons.school_outlined,
            validator: (v) =>
                v?.isEmpty ?? true ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _diplomaInstitutionControllers[id]!,
            label: 'Institution',
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _diplomaYearControllers[id]!,
            label: 'Année',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildFileUpload(
            label: 'Document (upload simulé)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upload simulé (mode démo)'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

