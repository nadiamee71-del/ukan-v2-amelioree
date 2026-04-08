import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/theme_notifier.dart';
import 'package:intl/intl.dart';

class EditDeadlinePage extends StatefulWidget {
  final String initialDeadline;

  const EditDeadlinePage({
    super.key,
    required this.initialDeadline,
  });

  @override
  State<EditDeadlinePage> createState() => _EditDeadlinePageState();
}

class _EditDeadlinePageState extends State<EditDeadlinePage> {
  late TextEditingController _deadlineController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _deadlineController = TextEditingController(text: widget.initialDeadline);
    // Essayer de parser la date initiale si elle est au format "Mois Année"
    _tryParseInitialDate();
  }

  void _tryParseInitialDate() {
    final initialText = widget.initialDeadline.trim();
    if (initialText.isNotEmpty) {
      // Essayer de parser des formats comme "Juin 2026", "juin 2026", etc.
      try {
        final months = {
          'janvier': 1, 'février': 2, 'mars': 3, 'avril': 4,
          'mai': 5, 'juin': 6, 'juillet': 7, 'août': 8,
          'septembre': 9, 'octobre': 10, 'novembre': 11, 'décembre': 12,
        };
        
        final parts = initialText.toLowerCase().split(' ');
        if (parts.length >= 2) {
          final monthName = parts[0];
          final yearStr = parts[1];
          final month = months[monthName];
          final year = int.tryParse(yearStr);
          
          if (month != null && year != null) {
            _selectedDate = DateTime(year, month, 1);
          }
        }
      } catch (e) {
        // Si le parsing échoue, on garde juste le texte
      }
    }
  }

  @override
  void dispose() {
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year, 1, 1);
    final DateTime lastDate = DateTime(now.year + 10, 12, 31);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('fr', 'FR'),
      helpText: 'Sélectionner la date d\'échéance',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Formater la date en "Mois Année" (ex: "Juin 2026")
        final monthNames = [
          'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
        ];
        _deadlineController.text = '${monthNames[picked.month - 1]} ${picked.year}';
      });
    }
  }

  void _save() {
    final deadline = _deadlineController.text.trim();
    if (deadline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une date d\'échéance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final profileNotifier = UserProfileNotifier();
    final updatedProfile = profileNotifier.profile.copyWith(deadline: deadline);
    profileNotifier.updateProfile(updatedProfile);

    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Date d\'échéance mise à jour'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Date d\'échéance',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Texte explicatif
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFFFFC300),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Date d\'échéance de votre programme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Définissez la date à laquelle vous souhaitez atteindre vos objectifs. Cette date vous aidera à rester motivé et à suivre votre progression.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Champ de saisie
            Text(
              'Date d\'échéance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Bouton pour sélectionner la date
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: const Color(0xFFFFC300),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _deadlineController,
                        enabled: true,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ex: Juin 2026',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white38 : Colors.black38,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            Text(
              'Appuyez sur le champ pour sélectionner une date avec le calendrier, ou saisissez manuellement (ex: "Juin 2026")',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white54 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Bouton de sauvegarde
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

