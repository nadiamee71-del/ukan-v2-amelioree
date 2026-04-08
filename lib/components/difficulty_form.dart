import 'package:flutter/material.dart';
import '../models/difficulty_entry.dart';

// Thème spécifique : Marron + Aubergine + Texte Noir (identique au Carnet de Blessures)
const Color _marronPrincipal = Color(0xFF733F24); // Marron principal
const Color _auberginePrincipal = Color(0xFF4B234A); // Aubergine principal
const Color _texteNoir = Color(0xFF000000); // Texte noir

/// Formulaire pour évaluer la difficulté d'un exercice
/// Reproduit exactement le style du slider du Carnet de Blessures
class DifficultyForm extends StatefulWidget {
  final String exerciseId;
  final String sessionId;
  final Function(DifficultyEntry)? onSave;
  final Function()? onCancel;

  const DifficultyForm({
    super.key,
    required this.exerciseId,
    required this.sessionId,
    this.onSave,
    this.onCancel,
  });

  @override
  State<DifficultyForm> createState() => _DifficultyFormState();
}

class _DifficultyFormState extends State<DifficultyForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _level = 5; // Valeur par défaut : 5/10
  bool _shared = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Calcule la couleur du slider selon le niveau (vert → rouge)
  Widget _buildEmojiButton(String emoji, String label, int level) {
    final isSelected = _level == level || (_level >= level - 1 && _level <= level + 1);
    return GestureDetector(
      onTap: () {
        setState(() {
          _level = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _getSliderColor(level).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _getSliderColor(level)
                : _auberginePrincipal.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _texteNoir,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSliderColor(int level) {
    // 0-3 : Vert (facile)
    // 4-6 : Jaune/Orange (moyen)
    // 7-10 : Rouge (difficile)
    if (level <= 3) {
      // Vert : interpolation de vert clair à vert moyen
      final ratio = level / 3.0;
      return Color.lerp(
        const Color(0xFF4CAF50), // Vert clair
        const Color(0xFF8BC34A), // Vert moyen
        ratio,
      )!;
    } else if (level <= 6) {
      // Jaune/Orange : interpolation de vert moyen à orange
      final ratio = (level - 3) / 3.0;
      return Color.lerp(
        const Color(0xFF8BC34A), // Vert moyen
        const Color(0xFFFF9800), // Orange
        ratio,
      )!;
    } else {
      // Rouge : interpolation d'orange à rouge
      final ratio = (level - 6) / 4.0;
      return Color.lerp(
        const Color(0xFFFF9800), // Orange
        const Color(0xFFF44336), // Rouge
        ratio,
      )!;
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final entry = DifficultyEntry(
        id: 'difficulty_${DateTime.now().millisecondsSinceEpoch}',
        exerciseId: widget.exerciseId,
        sessionId: widget.sessionId,
        date: DateTime.now(),
        level: _level,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        shared: _shared,
      );

      if (widget.onSave != null) {
        // Appeler le callback de manière asynchrone
        widget.onSave!(entry);
      }

      // Fermer le popup immédiatement
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _auberginePrincipal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Évaluer la difficulté',
                    style: TextStyle(
                      color: _texteNoir,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Slider de difficulté (0 à 10)
                  Text(
                    'Niveau de difficulté: $_level/10',
                    style: const TextStyle(
                      color: _texteNoir,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _level.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: '$_level',
                    activeColor: _getSliderColor(_level),
                    inactiveColor: _auberginePrincipal.withOpacity(0.3),
                    onChanged: (value) {
                      setState(() {
                        _level = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Boutons avec visages emoji
                  const Text(
                    'Ou choisissez rapidement :',
                    style: TextStyle(
                      color: _texteNoir,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmojiButton('😄', 'Très facile', 1),
                      _buildEmojiButton('🙂', 'Facile', 3),
                      _buildEmojiButton('😐', 'Moyen', 5),
                      _buildEmojiButton('😣', 'Difficile', 7),
                      _buildEmojiButton('😵', 'Très difficile', 9),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Champ commentaire
                  const Text(
                    'Commentaire',
                    style: TextStyle(
                      color: _texteNoir,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _auberginePrincipal.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _auberginePrincipal.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: _marronPrincipal,
                          width: 2,
                        ),
                      ),
                      hintText: 'Ajouter un commentaire (optionnel)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    maxLines: 4,
                    style: const TextStyle(color: _texteNoir),
                  ),
                  const SizedBox(height: 24),
                  // Switch partager avec la communauté
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _auberginePrincipal.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Partager avec la communauté',
                                style: TextStyle(
                                  color: _texteNoir,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ton évaluation sera visible par tous',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _shared,
                          onChanged: (value) {
                            setState(() {
                              _shared = value;
                            });
                          },
                          activeColor: _marronPrincipal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _texteNoir,
                            side: BorderSide(
                              color: _auberginePrincipal.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _marronPrincipal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

