import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Résultat du dialog de difficulté (difficulté + note optionnelle)
class DifficultyResult {
  final double difficulty;
  final String? note;
  
  DifficultyResult({required this.difficulty, this.note});
}

/// Dialog pour évaluer la difficulté d'un exercice après l'avoir terminé
/// Échelle de 1 à 10 (RPE - Rate of Perceived Exertion)
class DifficultyRatingDialog extends StatefulWidget {
  final String exerciseName;
  final Function(double difficulty, String? note) onSubmit;

  const DifficultyRatingDialog({
    super.key,
    required this.exerciseName,
    required this.onSubmit,
  });

  /// Affiche le dialog et retourne la difficulté + note (ou null si annulé)
  static Future<DifficultyResult?> show(
    BuildContext context, {
    required String exerciseName,
  }) async {
    return showDialog<DifficultyResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return DifficultyRatingDialog(
          exerciseName: exerciseName,
          onSubmit: (difficulty, note) {
            Navigator.of(context).pop(DifficultyResult(
              difficulty: difficulty,
              note: note,
            ));
          },
        );
      },
    );
  }

  @override
  State<DifficultyRatingDialog> createState() => _DifficultyRatingDialogState();
}

class _DifficultyRatingDialogState extends State<DifficultyRatingDialog>
    with SingleTickerProviderStateMixin {
  double _difficulty = 5.0;
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _getDifficultyLabel(double value) {
    if (value <= 2) return 'Très facile 😴';
    if (value <= 4) return 'Facile 🙂';
    if (value <= 6) return 'Modéré 😐';
    if (value <= 8) return 'Difficile 😓';
    return 'Très difficile 🔥';
  }

  Color _getDifficultyColor(double value) {
    if (value <= 2) return Colors.green;
    if (value <= 4) return Colors.lightGreen;
    if (value <= 6) return Colors.yellow;
    if (value <= 8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDifficultyColor(_difficulty);
    final screenHeight = MediaQuery.of(context).size.height;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.75,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône de succès
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),

                // Titre
                const Text(
                  '✅ EXERCICE TERMINÉ !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.exerciseName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // Valeur actuelle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_difficulty.toInt()}/10',
                        style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _getDifficultyLabel(_difficulty),
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Slider
                Row(
                  children: [
                    const Text('😴', style: TextStyle(fontSize: 18)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: color,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: color,
                          overlayColor: color.withOpacity(0.2),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: _difficulty,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _difficulty = value);
                          },
                        ),
                      ),
                    ),
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                  ],
                ),

                // Champ de note
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _noteController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: '📝 Note optionnelle...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton valider
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final note = _noteController.text.trim();
                      widget.onSubmit(_difficulty, note.isEmpty ? null : note);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'VALIDER ✓',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Bouton passer
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    'Passer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget compact pour afficher la difficulté
class DifficultyBadge extends StatelessWidget {
  final double? difficulty;
  final String? note;
  final bool editable;
  final Function(DifficultyResult)? onChanged;

  const DifficultyBadge({
    super.key,
    this.difficulty,
    this.note,
    this.editable = false,
    this.onChanged,
  });

  Color _getColor(double value) {
    if (value <= 2) return Colors.green;
    if (value <= 4) return Colors.lightGreen;
    if (value <= 6) return Colors.yellow;
    if (value <= 8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (difficulty == null) {
      return GestureDetector(
        onTap: editable && onChanged != null
            ? () async {
                final result = await DifficultyRatingDialog.show(
                  context,
                  exerciseName: 'Exercice',
                );
                if (result != null) {
                  onChanged!(result);
                }
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                'Difficulté',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final color = _getColor(difficulty!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${difficulty!.toInt()}/10',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
