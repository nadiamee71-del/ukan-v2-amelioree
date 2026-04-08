import 'package:flutter/material.dart';

/// Liste complète des muscles disponibles
const List<String> _allMuscles = [
  'Pectoraux',
  'Pectoral majeur',
  'Pectoral inférieur',
  'Grand dorsal',
  'Trapèzes',
  'Deltoïdes antérieurs',
  'Deltoïdes latéraux',
  'Deltoïdes postérieurs',
  'Biceps',
  'Triceps',
  'Quadriceps',
  'Ischios',
  'Fessiers',
  'Mollets',
  'Abdominaux',
  'Obliques',
  'Lombaires',
  'Avant-bras',
  'Érecteurs du rachis',
];

/// Widget d'autocomplete pour les muscles avec chips
class MuscleAutocompleteField extends StatefulWidget {
  final List<String> selectedMuscles;
  final Function(List<String>) onChanged;
  final String label;
  final bool required;

  const MuscleAutocompleteField({
    super.key,
    required this.selectedMuscles,
    required this.onChanged,
    required this.label,
    this.required = false,
  });

  @override
  State<MuscleAutocompleteField> createState() => _MuscleAutocompleteFieldState();
}

class _MuscleAutocompleteFieldState extends State<MuscleAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addMuscle(String muscle) {
    if (!widget.selectedMuscles.contains(muscle)) {
      widget.onChanged([...widget.selectedMuscles, muscle]);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  void _removeMuscle(String muscle) {
    widget.onChanged(widget.selectedMuscles.where((m) => m != muscle).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips des muscles sélectionnés
        if (widget.selectedMuscles.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedMuscles.map((muscle) {
              return Chip(
                label: Text(muscle),
                onDeleted: () => _removeMuscle(muscle),
                deleteIcon: const Icon(Icons.close, size: 18),
                backgroundColor: const Color(0xFF007AFF).withOpacity(0.2),
                labelStyle: const TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        // Champ autocomplete
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _allMuscles.where((muscle) => 
                !widget.selectedMuscles.contains(muscle)
              );
            }
            return _allMuscles.where((muscle) {
              final query = textEditingValue.text.toLowerCase();
              return muscle.toLowerCase().contains(query) &&
                  !widget.selectedMuscles.contains(muscle);
            });
          },
          onSelected: _addMuscle,
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Synchroniser les controllers
            _controller.addListener(() {
              if (_controller.text != textEditingController.text) {
                textEditingController.text = _controller.text;
              }
            });
            textEditingController.addListener(() {
              if (textEditingController.text != _controller.text) {
                _controller.text = textEditingController.text;
              }
            });
            
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: 'Tapez pour rechercher un muscle...',
                helperText: widget.required ? 'Au moins un muscle est obligatoire' : null,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          textEditingController.clear();
                          _controller.clear();
                        },
                      )
                    : null,
              ),
              validator: widget.required
                  ? (value) {
                      if (widget.selectedMuscles.isEmpty) {
                        return 'Au moins un muscle est obligatoire';
                      }
                      return null;
                    }
                  : null,
            );
          },
        ),
      ],
    );
  }
}
