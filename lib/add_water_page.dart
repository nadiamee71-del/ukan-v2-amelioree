import 'package:flutter/material.dart';
import 'models/goals.dart';

class AddWaterPage extends StatefulWidget {
  const AddWaterPage({super.key});

  @override
  State<AddWaterPage> createState() => _AddWaterPageState();
}

class _AddWaterPageState extends State<AddWaterPage> {
  DateTime _selectedDate = DateTime.now();
  final _millilitersController = TextEditingController(text: '250');

  @override
  void dispose() {
    _millilitersController.dispose();
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

  void _addWater() {
    final milliliters = int.tryParse(_millilitersController.text.trim());
    if (milliliters == null || milliliters <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une quantité valide.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    HydrationNotifier().addWater(
      date: _selectedDate,
      milliliters: milliliters,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${milliliters} ml d\'eau ajoutés'),
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.of(context).pop();
  }

  void _quickAdd(int milliliters) {
    _millilitersController.text = milliliters.toString();
    _addWater();
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
        title: const Text('Ajouter de l\'eau'),
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

              // Quantité d'eau
              const Text(
                'Quantité d\'eau',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _millilitersController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '250',
                  suffixText: 'ml',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Boutons rapides
              const Text(
                'Ajout rapide',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAddButton(
                      label: '250 ml',
                      milliliters: 250,
                      onTap: () => _quickAdd(250),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAddButton(
                      label: '500 ml',
                      milliliters: 500,
                      onTap: () => _quickAdd(500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAddButton(
                      label: '1 L',
                      milliliters: 1000,
                      onTap: () => _quickAdd(1000),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAddButton(
                      label: '1.5 L',
                      milliliters: 1500,
                      onTap: () => _quickAdd(1500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addWater,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
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

class _QuickAddButton extends StatelessWidget {
  final String label;
  final int milliliters;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.milliliters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black26),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

