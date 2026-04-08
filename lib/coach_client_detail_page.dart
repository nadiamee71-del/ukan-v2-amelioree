import 'package:flutter/material.dart';
import 'coach_clients_page.dart';
import 'new_program_page.dart';
import 'models/coach_programs.dart';
import 'coach_program_detail_page.dart';
import 'models/coach_directory.dart' as directory_models;
import 'coach/programs/coach_programs_page.dart';
import 'coach/programs/coach_program_create_page.dart';
import 'chat_page.dart';
import 'models/client_tracking.dart';
import 'add_client_progress_page.dart';
import 'edit_client_notes_page.dart';
import 'pages/health_injuries_page.dart';
import 'body_composition_page.dart';
import 'pages/simple_nutrition_page.dart';
import 'exercises/exercise_library_page.dart';
import 'pages/difficulty_history_page.dart';
import 'features/appointments/unified_planning_page.dart';
import 'features/appointments/appointments_repository.dart';
import 'features/appointments/appointment_models.dart';
import 'features/appointments/appointment_details_view.dart';

class CoachClientDetailPage extends StatefulWidget {
  final CoachClient client;

  const CoachClientDetailPage({super.key, required this.client});

  @override
  State<CoachClientDetailPage> createState() => _CoachClientDetailPageState();
}

class _CoachClientDetailPageState extends State<CoachClientDetailPage> {
  late final CoachProgramsNotifier _programsNotifier;
  final _progressNotifier = ClientProgressNotifier();
  final _notesNotifier = ClientNotesNotifier();

  @override
  void initState() {
    super.initState();
    _programsNotifier = CoachProgramsNotifier();
    _programsNotifier.addListener(_onProgramsChanged);
    _progressNotifier.addListener(_onTrackingChanged);
    _notesNotifier.addListener(_onTrackingChanged);
  }

  @override
  void dispose() {
    _programsNotifier.removeListener(_onProgramsChanged);
    _progressNotifier.removeListener(_onTrackingChanged);
    _notesNotifier.removeListener(_onTrackingChanged);
    super.dispose();
  }

  void _onProgramsChanged() {
    setState(() {});
  }

  void _onTrackingChanged() {
    setState(() {});
  }

  void _assignExistingProgram(BuildContext context, String clientId) {
    final allPrograms = _programsNotifier.programs;
    final availablePrograms = allPrograms.where((p) => !p.isAssignedToClient(clientId)).toList();

    if (availablePrograms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun programme disponible à assigner. Crée-en un nouveau !'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Sélectionner un programme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: availablePrograms.length,
                itemBuilder: (context, index) {
                  final program = availablePrograms[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.grey.shade50,
                    title: Text(
                      program.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${program.durationWeeks} semaines • ${program.sessionsPerWeek} séances / semaine',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                program.goal,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                program.level,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _programsNotifier.assignProgramToClient(program.id, clientId);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Programme "${program.title}" assigné à ${widget.client.name}')),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildClientDataAccessSection(CoachClient client) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accès aux données de ${client.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'En tant que coach, vous avez accès à toutes les données de votre client',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          // Grille d'accès aux données
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _ClientDataCard(
                icon: Icons.fitness_center,
                title: 'Exercices',
                subtitle: 'Bibliothèque',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExerciseLibraryPage(),
                    ),
                  );
                },
              ),
              _ClientDataCard(
                icon: Icons.healing,
                title: 'Santé & Blessures',
                subtitle: 'Carnet',
                color: const Color(0xFF733F24),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HealthInjuriesPage(),
                    ),
                  );
                },
              ),
              _ClientDataCard(
                icon: Icons.scale,
                title: 'Poids & Composition',
                subtitle: 'Corporelle',
                color: Colors.purple,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BodyCompositionPage(),
                    ),
                  );
                },
              ),
              _ClientDataCard(
                icon: Icons.restaurant,
                title: 'Nutrition',
                subtitle: 'Repas & calories',
                color: Colors.orange,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SimpleNutritionPage(),
                    ),
                  );
                },
              ),
              _ClientDataCard(
                icon: Icons.assessment,
                title: 'Difficultés',
                subtitle: 'Évaluations',
                color: Colors.red,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DifficultyHistoryPage(),
                    ),
                  );
                },
              ),
              _ClientDataCard(
                icon: Icons.calendar_today,
                title: 'Planning',
                subtitle: 'Séances',
                color: const Color(0xFFFFC300),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UnifiedPlanningPage(
                        isCoachView: false,
                        clientId: client.id,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingSection(CoachClient client) {
    final latest = _progressNotifier.latestForClient(client.id);
    final history = _progressNotifier.entriesForClient(client.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (latest == null)
            const Text(
              'Aucun suivi enregistré pour le moment.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            )
          else ...[
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  'Dernier suivi : ${_formatDate(latest.date)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (latest.weightKg != null) ...[
              _TrackingItem(
                label: 'Poids',
                value: '${latest.weightKg!.toStringAsFixed(1)} kg',
                icon: Icons.scale_outlined,
              ),
              const SizedBox(height: 12),
            ],
            if (latest.waistCm != null ||
                latest.hipsCm != null ||
                latest.chestCm != null) ...[
              const Text(
                'Mensurations',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              if (latest.waistCm != null)
                _TrackingItem(
                  label: 'Taille',
                  value: '${latest.waistCm!.toStringAsFixed(1)} cm',
                  icon: Icons.accessibility_new_outlined,
                ),
              if (latest.waistCm != null) const SizedBox(height: 8),
              if (latest.hipsCm != null)
                _TrackingItem(
                  label: 'Hanches',
                  value: '${latest.hipsCm!.toStringAsFixed(1)} cm',
                  icon: Icons.accessibility_new_outlined,
                ),
              if (latest.hipsCm != null) const SizedBox(height: 8),
              if (latest.chestCm != null)
                _TrackingItem(
                  label: 'Poitrine',
                  value: '${latest.chestCm!.toStringAsFixed(1)} cm',
                  icon: Icons.accessibility_new_outlined,
                ),
              const SizedBox(height: 12),
            ],
            if (latest.workoutsDone != null ||
                latest.workoutsPlanned != null) ...[
              const Divider(),
              const SizedBox(height: 12),
              _TrackingItem(
                label: 'Assiduité',
                value: latest.workoutsDone != null &&
                        latest.workoutsPlanned != null
                    ? '${latest.workoutsDone} / ${latest.workoutsPlanned} séances'
                    : latest.workoutsDone != null
                        ? '${latest.workoutsDone} séances faites'
                        : '${latest.workoutsPlanned} séances prévues',
                icon: Icons.check_circle_outline,
              ),
            ],
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // TODO: Afficher l'historique complet (BottomSheet ou page)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Historique (${history.length} entrées) - À venir',
                  ),
                ),
              );
            },
            child: Text(
              'Voir l\'historique (${history.length})',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddClientProgressPage(
                      clientId: client.id,
                      clientName: client.name,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Ajouter un point de suivi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black26),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(CoachClient client) {
    final note = _notesNotifier.noteForClient(client.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note == null || note.trim().isEmpty)
            const Text(
              'Aucune note enregistrée pour le moment.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Text(
              note,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.edit_note),
              label: const Text('Modifier les notes'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditClientNotesPage(
                      clientId: client.id,
                      clientName: client.name,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    final programs = _programsNotifier.programsForClient(client.id);
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: Text(client.name),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bloc résumé en haut
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          client.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFC300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${client.age} ans • ${client.goal}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.scale,
                                label: '${client.currentWeight.toStringAsFixed(1)} kg',
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.track_changes,
                                label: '${client.targetWeight.toStringAsFixed(1)} kg',
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.fitness_center,
                                label: '${client.sessionsPerWeek}/sem',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Section Données du client (accès coach)
              Text(
                'Données du client',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildClientDataAccessSection(client),
              const SizedBox(height: 24),
              // Section Suivi & historique
              Text(
                'Suivi & historique',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildTrackingSection(client),
              const SizedBox(height: 24),
              // Section Notes du coach
              Text(
                'Notes du coach (privées)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildNotesSection(client),
              const SizedBox(height: 24),
              Text(
                'Programmes en cours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Liste dynamique des programmes
              if (programs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Aucun programme assigné pour le moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _assignExistingProgram(context, client.id),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Associer un programme existant'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black26),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return _ProgramCard(program: program);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: programs.length,
                ),
              const SizedBox(height: 24),
              Text(
                'Prochaines séances',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Séances dynamiques depuis le repository
              _ClientUpcomingSessions(clientId: client.id),
              const SizedBox(height: 24),
              // Section Communication
              Text(
                'Communication',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          clientId: client.id,
                          clientName: client.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Ouvrir le chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black26),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _assignExistingProgram(context, client.id),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Associer un programme'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CoachProgramCreatePage(
                              preselectedClientId: client.id,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC300),
                        foregroundColor: const Color(0xFF111111),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Nouveau programme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.black54,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final CoachProgram program;

  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.assignment,
              color: Color(0xFFFFC300),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        program.level,
                        style: const TextStyle(fontSize: 11),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      backgroundColor: Colors.grey.shade100,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${program.exercises.length} exercices • ${program.sessionsPerWeek} séances/semaine',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Convertir le programme de coach_programs.dart vers coach_directory.dart
              final directoryProgram = directory_models.CoachProgram(
                id: program.id,
                title: program.title,
                description: program.notes ?? 'Programme personnalisé',
                price: 0.0, // Les programmes assignés aux clients sont gratuits
                durationWeeks: program.durationWeeks,
                level: program.level,
                coachId: 'coach_current',
              );
              
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CoachProgramDetailPage(
                    program: directoryProgram,
                    coachId: 'coach_current',
                    coachName: 'Votre Coach',
                  ),
                ),
              );
            },
            child: const Text(
              'Voir le programme',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TrackingItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// Widget pour afficher une carte d'accès aux données client
class _ClientDataCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ClientDataCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher les prochaines séances d'un client (dynamique)
class _ClientUpcomingSessions extends StatefulWidget {
  final String clientId;

  const _ClientUpcomingSessions({required this.clientId});

  @override
  State<_ClientUpcomingSessions> createState() => _ClientUpcomingSessionsState();
}

class _ClientUpcomingSessionsState extends State<_ClientUpcomingSessions> {
  final _repository = AppointmentsRepository();

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<Appointment> get _upcomingAppointments {
    final now = DateTime.now();
    return _repository.getAppointmentsForClient(widget.clientId)
        .where((a) => 
            a.start.isAfter(now) && 
            a.status != AppointmentStatus.cancelled
        )
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _upcomingAppointments;

    if (appointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 32,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 8),
              Text(
                'Aucune séance prévue',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: appointments.map((appt) {
        final timeStr = '${appt.start.hour.toString().padLeft(2, '0')}:${appt.start.minute.toString().padLeft(2, '0')}';
        final dateStr = '${_getDayName(appt.start.weekday)}. ${appt.start.day}/${appt.start.month}';
        final category = appt.category;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppointmentDetailsView(
                  appointment: appt,
                  isCoachView: true,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color.withOpacity(0.15),
                  category.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: category.color.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                // Indicateur de couleur
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Icône
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$dateStr • $timeStr',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge catégorie
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category == SessionCategory.solo 
                        ? 'PERSO' 
                        : category == SessionCategory.coach 
                            ? 'COACH' 
                            : 'GROUPE',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Badge statut
                if (appt.status == AppointmentStatus.pending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: const Text(
                      '⏳',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }
}





