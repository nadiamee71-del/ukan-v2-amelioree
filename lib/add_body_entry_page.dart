import 'package:flutter/material.dart';
import 'models/body_composition.dart';

class AddBodyEntryPage extends StatefulWidget {
  const AddBodyEntryPage({super.key});

  @override
  State<AddBodyEntryPage> createState() => _AddBodyEntryPageState();
}

class _AddBodyEntryPageState extends State<AddBodyEntryPage> {
  DateTime _selectedDate = DateTime.now();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _chestController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    final weight = double.tryParse(_weightController.text.trim());
    final waist = double.tryParse(_waistController.text.trim());
    final hips = double.tryParse(_hipsController.text.trim());
    final chest = double.tryParse(_chestController.text.trim());

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un poids valide.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (waist == null || waist <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un tour de taille valide.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (hips == null || hips <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un tour de hanches valide.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (chest == null || chest <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un tour de poitrine valide.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    BodyCompositionNotifier().addEntry(
      date: _selectedDate,
      weight: weight,
      waist: waist,
      hips: hips,
      chest: chest,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mesure enregistrée'),
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Aujourd\'hui';
    } else if (targetDate == yesterday) {
      return 'Hier';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Ajouter une mesure'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélecteur de date
              _LabeledField(
                label: 'Date',
                value: _formatDate(_selectedDate),
                onTap: _selectDate,
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 24),

              // Poids
              _LabeledTextField(
                label: 'Poids (kg)',
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                icon: Icons.monitor_weight_outlined,
              ),
              const SizedBox(height: 16),

              // Tour de taille
              _LabeledTextField(
                label: 'Tour de taille (cm)',
                controller: _waistController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                icon: Icons.straighten_outlined,
              ),
              const SizedBox(height: 16),

              // Tour de hanches
              _LabeledTextField(
                label: 'Tour de hanches (cm)',
                controller: _hipsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                icon: Icons.straighten_outlined,
              ),
              const SizedBox(height: 16),

              // Tour de poitrine
              _LabeledTextField(
                label: 'Tour de poitrine (cm)',
                controller: _chestController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                icon: Icons.straighten_outlined,
              ),
              const SizedBox(height: 32),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer la mesure',
                    style: TextStyle(fontSize: 16),
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

class _LabeledField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  const _LabeledField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData icon;

  const _LabeledTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade700),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}









