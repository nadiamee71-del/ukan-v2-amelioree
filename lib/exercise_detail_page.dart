import 'package:flutter/material.dart';
import 'models/coach_programs.dart';
import 'exercise_video_page.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0 && secs > 0) {
      return '$minutes min $secs s';
    } else if (minutes > 0) {
      return '$minutes min';
    } else {
      return '$secs s';
    }
  }

  String _formatRest(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0 && secs > 0) {
      return '$minutes min $secs s';
    } else if (minutes > 0) {
      return '$minutes min';
    } else {
      return '$secs s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: Text(exercise.name),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte principale avec nom et badge zone
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFFFFC300),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      exercise.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text(
                        exercise.zone,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: const Color(0xFFFFF4CC),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Carte "Détails de la charge"
              const Text(
                'Détails de la charge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    // Séries
                    _DetailRow(
                      icon: Icons.repeat,
                      label: 'Séries',
                      value: '${exercise.sets}',
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Répétitions ou Durée
                    if (exercise.reps != null)
                      _DetailRow(
                        icon: Icons.repeat_one,
                        label: 'Répétitions',
                        value: '${exercise.reps}',
                      )
                    else if (exercise.durationSeconds != null)
                      _DetailRow(
                        icon: Icons.timer_outlined,
                        label: 'Durée',
                        value: _formatDuration(exercise.durationSeconds!),
                      )
                    else
                      const _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Répétitions / Durée',
                        value: 'Non spécifié',
                      ),

                    // Poids (si renseigné)
                    if (exercise.weightKg != null && exercise.weightKg! > 0) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.scale_outlined,
                        label: 'Poids',
                        value: '${exercise.weightKg!.toStringAsFixed(1)} kg',
                      ),
                    ],

                    // Repos
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.timer_off_outlined,
                      label: 'Repos entre les séries',
                      value: _formatRest(exercise.restSeconds),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Carte "Notes du coach"
              const Text(
                'Notes du coach',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  exercise.notes != null && exercise.notes!.isNotEmpty
                      ? exercise.notes!
                      : 'Aucune note particulière.',
                  style: TextStyle(
                    fontSize: 14,
                    color: exercise.notes != null && exercise.notes!.isNotEmpty
                        ? Colors.black87
                        : Colors.black54,
                    height: 1.4,
                    fontStyle: exercise.notes != null && exercise.notes!.isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Bouton "Voir la vidéo (démo)"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Voir la vidéo (démo)'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseVideoPage(exercise: exercise),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

