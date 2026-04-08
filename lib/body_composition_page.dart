import 'package:flutter/material.dart';
import 'models/advanced_body_data.dart';

class BodyCompositionPage extends StatefulWidget {
  const BodyCompositionPage({super.key});

  @override
  State<BodyCompositionPage> createState() => _BodyCompositionPageState();
}

class _BodyCompositionPageState extends State<BodyCompositionPage> {
  final _notifier = AdvancedBodyDataNotifier();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_onDataChanged);
    _initializeControllers();
  }

  @override
  void dispose() {
    _notifier.removeListener(_onDataChanged);
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeControllers() {
    final data = _notifier.data;
    _controllers['weight'] = TextEditingController(text: data.weight?.toString() ?? '');
    _controllers['height'] = TextEditingController(text: data.height?.toString() ?? '');
    _controllers['bodyFat'] = TextEditingController(text: data.bodyFat?.toString() ?? '');
    _controllers['chest'] = TextEditingController(text: data.chest?.toString() ?? '');
    _controllers['waist'] = TextEditingController(text: data.waist?.toString() ?? '');
    _controllers['hips'] = TextEditingController(text: data.hips?.toString() ?? '');
    _controllers['arm'] = TextEditingController(text: data.arm?.toString() ?? '');
    _controllers['thigh'] = TextEditingController(text: data.thigh?.toString() ?? '');
    _controllers['calf'] = TextEditingController(text: data.calf?.toString() ?? '');
    _controllers['allergies'] = TextEditingController(text: data.allergies ?? '');
    _controllers['healthIssues'] = TextEditingController(text: data.healthIssues ?? '');
    _controllers['medications'] = TextEditingController(text: data.medications ?? '');
  }

  void _onDataChanged() {
    setState(() {});
  }

  void _updateData() {
    final data = _notifier.data;
    final newData = AdvancedBodyData(
      weight: double.tryParse(_controllers['weight']?.text ?? '') ?? data.weight,
      height: double.tryParse(_controllers['height']?.text ?? '') ?? data.height,
      bodyFat: double.tryParse(_controllers['bodyFat']?.text ?? '') ?? data.bodyFat,
      bodyType: data.bodyType,
      gender: data.gender,
      chest: double.tryParse(_controllers['chest']?.text ?? '') ?? data.chest,
      waist: double.tryParse(_controllers['waist']?.text ?? '') ?? data.waist,
      hips: double.tryParse(_controllers['hips']?.text ?? '') ?? data.hips,
      arm: double.tryParse(_controllers['arm']?.text ?? '') ?? data.arm,
      thigh: double.tryParse(_controllers['thigh']?.text ?? '') ?? data.thigh,
      calf: double.tryParse(_controllers['calf']?.text ?? '') ?? data.calf,
      bloodType: data.bloodType,
      allergies: _controllers['allergies']?.text ?? data.allergies,
      healthIssues: _controllers['healthIssues']?.text ?? data.healthIssues,
      medications: _controllers['medications']?.text ?? data.medications,
      fitnessLevel: data.fitnessLevel,
      sessionDifficulty: data.sessionDifficulty,
    );
    _notifier.updateData(newData);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Données mises à jour avec succès !'),
        backgroundColor: Color(0xFFFFC300),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _notifier.data;
    final history = _notifier.history;

    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D111C),
        foregroundColor: Colors.white,
        title: const Text(
          'Analyse corporelle avancée',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFC300).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFFC300),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tapez dans les champs pour modifier vos informations, puis cliquez sur "Mettre à jour mes données" en bas de page.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 1. Informations corporelles générales
            _buildGeneralDataCard(data),
            const SizedBox(height: 20),

            // 2. Mensurations détaillées
            _buildMeasurementsCard(data),
            const SizedBox(height: 20),

            // 3. Informations médicales
            _buildHealthCard(data),
            const SizedBox(height: 20),

            // 4. Niveau de forme physique
            _buildFitnessCard(data),
            const SizedBox(height: 20),

            // 5. Historique des mesures
            _buildHistoryCard(history),
            const SizedBox(height: 20),

            // 6. Bouton Mettre à jour
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: const Color(0xFF050814),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Mettre à jour mes données',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 1. Carte Données générales
  Widget _buildGeneralDataCard(AdvancedBodyData data) {
    return _buildCard(
      title: 'Données générales',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildTextField(
            label: 'Poids (kg)',
            controller: _controllers['weight'],
            icon: Icons.monitor_weight_outlined,
            hint: 'Ex: 75.0',
            onChanged: (value) {
              setState(() {
                // Recalculer IMC automatiquement
                final weight = double.tryParse(value);
                if (weight != null && data.height != null) {
                  final heightInMeters = data.height! / 100;
                  final bmi = weight / (heightInMeters * heightInMeters);
                  _notifier.updateWeight(weight);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Taille (cm)',
            controller: _controllers['height'],
            icon: Icons.height,
            hint: 'Ex: 175',
            onChanged: (value) {
              setState(() {
                final height = double.tryParse(value);
                if (height != null && data.weight != null) {
                  _notifier.updateHeight(height);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'IMC',
            value: data.bmi != null ? data.bmi!.toStringAsFixed(1) : '--',
            icon: Icons.calculate_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Body Fat estimé (%)',
            controller: _controllers['bodyFat'],
            icon: Icons.analytics_outlined,
            hint: 'Ex: 18.0',
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Morphologie',
            value: data.bodyType,
            items: const ['ectomorphe', 'mésomorphe', 'endomorphe'],
            icon: Icons.accessibility_new,
            onChanged: (value) {
              _notifier.updateData(data.copyWith(bodyType: value));
            },
          ),
        ],
      ),
    );
  }

  // 2. Carte Mensurations
  Widget _buildMeasurementsCard(AdvancedBodyData data) {
    return _buildCard(
      title: 'Mensurations',
      icon: Icons.straighten,
      child: Column(
        children: [
          _buildMeasurementRow('Tour de poitrine', _controllers['chest'], Icons.man_outlined),
          const SizedBox(height: 12),
          _buildMeasurementRow('Tour de taille', _controllers['waist'], Icons.crop_free),
          const SizedBox(height: 12),
          _buildMeasurementRow('Tour de hanches', _controllers['hips'], Icons.woman_outlined),
          const SizedBox(height: 12),
          _buildMeasurementRow('Tour de bras', _controllers['arm'], Icons.fitness_center),
          const SizedBox(height: 12),
          _buildMeasurementRow('Tour de cuisses', _controllers['thigh'], Icons.directions_run),
          const SizedBox(height: 12),
          _buildMeasurementRow('Tour de mollets', _controllers['calf'], Icons.directions_walk),
        ],
      ),
    );
  }

  // 3. Carte Santé
  Widget _buildHealthCard(AdvancedBodyData data) {
    return _buildCard(
      title: 'Santé',
      icon: Icons.health_and_safety_outlined,
      child: Column(
        children: [
          _buildDropdownField(
            label: 'Groupe sanguin',
            value: data.bloodType,
            items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
            icon: Icons.bloodtype,
            onChanged: (value) {
              _notifier.updateData(data.copyWith(bloodType: value));
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Allergies',
            controller: _controllers['allergies'],
            icon: Icons.warning_amber_rounded,
            hint: 'Tapez vos allergies ou "Aucune"',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Problèmes de santé',
            controller: _controllers['healthIssues'],
            icon: Icons.medical_services_outlined,
            hint: 'Tapez vos problèmes de santé ou "Aucun"',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Médicaments / Traitement',
            controller: _controllers['medications'],
            icon: Icons.medication_outlined,
            hint: 'Tapez vos médicaments ou "Aucun"',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // 4. Carte Forme & Performance
  Widget _buildFitnessCard(AdvancedBodyData data) {
    return _buildCard(
      title: 'Forme & Performance',
      icon: Icons.fitness_center,
      child: Column(
        children: [
          _buildDropdownField(
            label: 'Niveau actuel',
            value: data.fitnessLevel,
            items: const ['Débutant', 'Intermédiaire', 'Avancé'],
            icon: Icons.trending_up,
            onChanged: (value) {
              _notifier.updateData(data.copyWith(fitnessLevel: value));
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Difficulté ressentie lors des séances',
            value: data.sessionDifficulty,
            items: const ['Facile', 'Moyen', 'Intense'],
            icon: Icons.speed,
            onChanged: (value) {
              _notifier.updateData(data.copyWith(sessionDifficulty: value));
            },
          ),
        ],
      ),
    );
  }

  // 5. Carte Historique
  Widget _buildHistoryCard(List<MonthlyHistoryEntry> history) {
    return _buildCard(
      title: 'Historique des mesures',
      icon: Icons.history,
      child: history.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Aucun historique disponible',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            )
          : Column(
              children: history.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC300).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFFFC300),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mois ${entry.month}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildHistoryValue('Poids', '${entry.weight.toStringAsFixed(1)} kg'),
                                  const SizedBox(width: 12),
                                  _buildHistoryValue('IMC', entry.bmi.toStringAsFixed(1)),
                                  const SizedBox(width: 12),
                                  _buildHistoryValue('Body Fat', '${entry.bodyFat.toStringAsFixed(1)}%'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildHistoryValue(String label, String value) {
    return Text(
      '$label: $value',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 12,
      ),
    );
  }

  // Widgets réutilisables
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D111C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC300).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFFC300),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController? controller,
    required IconData icon,
    int maxLines = 1,
    void Function(String)? onChanged,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? 'Tapez pour modifier',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFFFFC300)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFC300), width: 2),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC300), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFFFFC300)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFC300), width: 2),
        ),
      ),
      dropdownColor: const Color(0xFF0D111C),
      style: const TextStyle(color: Colors.white),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMeasurementRow(String label, TextEditingController? controller, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC300), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tapez',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              suffixText: 'cm',
              suffixStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFFC300), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
