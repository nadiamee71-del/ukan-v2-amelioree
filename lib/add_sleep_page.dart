import 'package:flutter/material.dart';
import 'models/goals.dart';

class AddSleepPage extends StatefulWidget {
  const AddSleepPage({super.key});

  @override
  State<AddSleepPage> createState() => _AddSleepPageState();
}

class _AddSleepPageState extends State<AddSleepPage> {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1)); // Hier par défaut
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);

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

  Future<void> _selectBedTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _bedTime,
    );
    if (picked != null) {
      setState(() {
        _bedTime = picked;
      });
    }
  }

  Future<void> _selectWakeTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
    );
    if (picked != null) {
      setState(() {
        _wakeTime = picked;
      });
    }
  }

  int _calculateDurationMinutes() {
    final bedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _bedTime.hour,
      _bedTime.minute,
    );
    final wakeDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    
    // Si l'heure de réveil est avant l'heure de coucher, c'est que la nuit continue le lendemain
    DateTime adjustedWakeDateTime = wakeDateTime;
    if (wakeDateTime.isBefore(bedDateTime) || wakeDateTime.isAtSameMomentAs(bedDateTime)) {
      adjustedWakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }
    
    return adjustedWakeDateTime.difference(bedDateTime).inMinutes;
  }

  void _save() {
    final durationMinutes = _calculateDurationMinutes();
    if (durationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La durée de sommeil doit être positive.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _bedTime.hour,
      _bedTime.minute,
    );
    final wakeDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    
    DateTime adjustedWakeDateTime = wakeDateTime;
    if (wakeDateTime.isBefore(bedDateTime) || wakeDateTime.isAtSameMomentAs(bedDateTime)) {
      adjustedWakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }

    final entry = SleepEntry(
      id: 'sleep_${DateTime.now().microsecondsSinceEpoch}',
      date: _selectedDate,
      bedTime: bedDateTime,
      wakeTime: adjustedWakeDateTime,
      durationMinutes: durationMinutes,
    );

    SleepNotifier().addSleep(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sommeil enregistré'),
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.of(context).pop();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
    final durationMinutes = _calculateDurationMinutes();
    final durationHours = (durationMinutes / 60).floor();
    final durationMins = durationMinutes % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Ajouter mon sommeil'),
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
              
              // Heure de coucher
              _LabeledField(
                label: 'Heure de coucher',
                value: _formatTimeOfDay(_bedTime),
                onTap: _selectBedTime,
                icon: Icons.bedtime_outlined,
              ),
              const SizedBox(height: 24),
              
              // Heure de réveil
              _LabeledField(
                label: 'Heure de réveil',
                value: _formatTimeOfDay(_wakeTime),
                onTap: _selectWakeTime,
                icon: Icons.wb_sunny_outlined,
              ),
              const SizedBox(height: 24),
              
              // Durée calculée
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Durée de sommeil',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$durationHours h ${durationMins.toString().padLeft(2, '0')} min',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
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

