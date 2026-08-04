import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client_profile.dart';
import '../main.dart';

class SignupClientPage extends StatefulWidget {
  const SignupClientPage({super.key});

  @override
  State<SignupClientPage> createState() => _SignupClientPageState();
}

class _SignupClientPageState extends State<SignupClientPage> {
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
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _mainReasonController = TextEditingController();
  final _difficultiesController = TextEditingController();
  final _maxDistanceController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _healthIssuesController = TextEditingController();

  // State
  DateTime? _birthDate;
  String? _gender;
  List<String> _objectives = [];
  String? _sessionsPerWeek;
  bool _coachingPresentiel = false;
  bool _coachingVisio = false;
  List<String> _preferredTimeSlots = [];
  List<String> _preferredDays = [];
  bool _medicalAuthorization = false;
  double? _calculatedIMC;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplissage avec des valeurs de test (mode démo)
    _firstNameController.text = 'A';
    _lastNameController.text = 'B';
    _emailController.text = 'test@test.com';
    _phoneController.text = '0123456789';
    _heightController.text = '170';
    _weightController.text = '70';
    _mainReasonController.text = 'Test';
    _birthDate = DateTime.now().subtract(const Duration(days: 365 * 30));
    _gender = 'Homme';
    _objectives = ['Perte de poids'];
    _sessionsPerWeek = '2';
    _coachingVisio = true;
    _preferredTimeSlots = ['Matin'];
    _preferredDays = ['Lundi'];
    _medicalAuthorization = true;
    _calculateIMC();
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
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _mainReasonController.dispose();
    _difficultiesController.dispose();
    _maxDistanceController.dispose();
    _allergiesController.dispose();
    _healthIssuesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateIMC() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (height != null && weight != null && height > 0 && weight > 0) {
      setState(() {
        _calculatedIMC = ClientProfile.calculateIMC(weight, height);
      });
    } else {
      setState(() {
        _calculatedIMC = null;
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
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

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre date de naissance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre genre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_objectives.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un objectif'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_sessionsPerWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner le nombre de séances par semaine'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_medicalAuthorization) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous devez confirmer avoir l\'autorisation médicale de pratiquer une activité physique',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Calcul de l'IMC
    final height = double.parse(_heightController.text);
    final weight = double.parse(_weightController.text);
    final imc = ClientProfile.calculateIMC(weight, height);

    // Création du profil
    final profile = ClientProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthDate: _birthDate!,
      gender: _gender!,
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
      heightCm: height,
      weightKg: weight,
      targetWeightKg: _targetWeightController.text.trim().isEmpty
          ? null
          : double.tryParse(_targetWeightController.text.trim()),
      waistCm: _waistController.text.trim().isEmpty
          ? null
          : double.tryParse(_waistController.text.trim()),
      hipsCm: _hipsController.text.trim().isEmpty
          ? null
          : double.tryParse(_hipsController.text.trim()),
      imc: imc,
      objectives: _objectives,
      mainReason: _mainReasonController.text.trim(),
      difficulties: _difficultiesController.text.trim().isEmpty
          ? null
          : _difficultiesController.text.trim(),
      sessionsPerWeek: _sessionsPerWeek!,
      coachingPresentiel: _coachingPresentiel,
      maxDistanceKm: _maxDistanceController.text.trim().isEmpty
          ? null
          : double.tryParse(_maxDistanceController.text.trim()),
      coachingVisio: _coachingVisio,
      preferredTimeSlots: _preferredTimeSlots,
      preferredDays: _preferredDays,
      allergies: _allergiesController.text.trim().isEmpty
          ? null
          : _allergiesController.text.trim(),
      healthIssues: _healthIssuesController.text.trim().isEmpty
          ? null
          : _healthIssuesController.text.trim(),
      medicalAuthorization: _medicalAuthorization,
    );

    // Log pour debug
    debugPrint('=== PROFIL CLIENT CRÉÉ ===');
    debugPrint(profile.toJson().toString());

    // Sauvegarde en localStorage (SharedPreferences)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fitpro_role', 'client');
      await prefs.setString('fitpro_profile', jsonEncode(profile.toJson()));
      await prefs.setBool('fitpro_is_logged_in', true);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Redirection vers le dashboard (Client : arrivée directe sur le Dashboard utilisateur)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UkanHomeShell(initialRole: 'client')),
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
          'Inscription Client',
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
                    _buildDateField(
                      label: 'Date de naissance *',
                      value: _birthDate,
                      onTap: _selectBirthDate,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Genre *',
                      value: _gender,
                      items: const [
                        'Homme',
                        'Femme',
                        'Autre',
                        'Je ne souhaite pas répondre',
                      ],
                      onChanged: (v) => setState(() => _gender = v),
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

                    const SizedBox(height: 32),
                    // Section 2: Données corporelles
                    _buildSectionTitle('2. Données corporelles'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            label: 'Taille (cm) *',
                            icon: Icons.height,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _calculateIMC(),
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Champ obligatoire';
                              final val = double.tryParse(v!);
                              if (val == null || val <= 0) {
                                return 'Valeur invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'Poids (kg) *',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _calculateIMC(),
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Champ obligatoire';
                              final val = double.tryParse(v!);
                              if (val == null || val <= 0) {
                                return 'Valeur invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_calculatedIMC != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC300).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFFFFC300),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Votre IMC estimé : ${_calculatedIMC!.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _targetWeightController,
                      label: 'Poids objectif (kg)',
                      icon: Icons.flag_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _waistController,
                            label: 'Tour de taille (cm)',
                            icon: Icons.straighten,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _hipsController,
                            label: 'Tour de hanches (cm)',
                            icon: Icons.straighten,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    // Section 3: Objectifs & motivation
                    _buildSectionTitle('3. Objectifs & motivation'),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                      label: 'Objectifs *',
                      options: const [
                        'Perte de poids',
                        'Prise de masse / Musculation',
                        'Remise en forme',
                        'Renforcement musculaire',
                        'Sport santé',
                        'Souplesse / mobilité',
                        'Bien-être général',
                        'Préparation événement (concours, mariage, compétition…)',
                      ],
                      selected: _objectives,
                      onChanged: (selected) =>
                          setState(() => _objectives = selected),
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _mainReasonController,
                      label: 'Pourquoi vous inscrivez-vous sur Ukan ? *',
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ obligatoire' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _difficultiesController,
                      label: 'Quels sont vos principaux obstacles ?',
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Combien de séances par semaine visez-vous ? *',
                      value: _sessionsPerWeek,
                      items: const ['1', '2', '3', '4+'],
                      onChanged: (v) => setState(() => _sessionsPerWeek = v),
                    ),

                    const SizedBox(height: 32),
                    // Section 4: Préférences de coaching
                    _buildSectionTitle('4. Préférences de coaching'),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label: 'Coaching présentiel ?',
                      value: _coachingPresentiel,
                      onChanged: (v) => setState(() => _coachingPresentiel = v),
                    ),
                    if (_coachingPresentiel) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _maxDistanceController,
                        label: 'Distance max en km',
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label: 'Coaching visio ?',
                      value: _coachingVisio,
                      onChanged: (v) => setState(() => _coachingVisio = v),
                    ),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                      label: 'Disponibilités préférées',
                      options: const ['Matin', 'Après-midi', 'Soir'],
                      selected: _preferredTimeSlots,
                      onChanged: (selected) =>
                          setState(() => _preferredTimeSlots = selected),
                    ),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                      label: 'Jours',
                      options: const [
                        'Lundi',
                        'Mardi',
                        'Mercredi',
                        'Jeudi',
                        'Vendredi',
                        'Samedi',
                        'Dimanche',
                      ],
                      selected: _preferredDays,
                      onChanged: (selected) =>
                          setState(() => _preferredDays = selected),
                    ),

                    const SizedBox(height: 32),
                    // Section 5: Santé
                    _buildSectionTitle('5. Santé'),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _allergiesController,
                      label: 'Allergies',
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _healthIssuesController,
                      label: 'Problèmes de santé / blessures',
                    ),
                    const SizedBox(height: 16),
                    _buildCheckbox(
                      label:
                          'Je confirme avoir l\'autorisation médicale de pratiquer une activité physique. *',
                      value: _medicalAuthorization,
                      onChanged: (v) =>
                          setState(() => _medicalAuthorization = v ?? false),
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

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
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
        ),
        child: Text(
          value != null
              ? '${value.day}/${value.month}/${value.year}'
              : 'Sélectionner une date',
          style: TextStyle(
            color: value != null ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
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
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
}

