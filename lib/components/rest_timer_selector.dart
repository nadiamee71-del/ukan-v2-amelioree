import 'package:flutter/material.dart';

/// Widget de sélection de temps de repos avec boutons ronds bleus
/// Style iOS/Apple Fitness - Design premium
class RestTimerSelector extends StatelessWidget {
  final Function(int seconds)? onSelect;
  final int? selectedSeconds;

  const RestTimerSelector({
    super.key,
    this.onSelect,
    this.selectedSeconds,
  });

  /// Durées de repos disponibles (en secondes)
  static const List<int> _restDurations = [
    30,   // 00:30
    60,   // 01:00
    90,   // 01:30
    120,  // 02:00
    150,  // 02:30
    180,  // 03:00
    240,  // 04:00
    300,  // 05:00
  ];

  /// Formate les secondes en MM:SS
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Fond sombre
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Temps de repos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _restDurations.map((seconds) {
              final isSelected = selectedSeconds == seconds;
              return GestureDetector(
                onTap: () => onSelect?.call(seconds),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF007AFF) // Bleu iOS sélectionné
                        : const Color(0xFF007AFF).withOpacity(0.2), // Bleu transparent
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withOpacity(0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF007AFF).withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _formatDuration(seconds),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF007AFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}











