import 'dart:io';
import 'package:flutter/material.dart';
import 'coach_clients_page.dart';
import 'coach/programs/coach_programs_page.dart';
import 'coach/profile/coach_public_profile_edit_page.dart';
import 'coach/coach_session.dart';
import 'features/appointments/unified_planning_page.dart';
import 'features/appointments/coach_availability_page.dart' show CoachAvailabilityPage;
import 'features/appointments/appointments_repository.dart';
import 'features/appointments/appointment_models.dart';
import 'models/coach_directory.dart';
import 'models/coach_programs.dart';
import 'models/coach_content.dart';

/// Avatar coach : gère un chemin d'asset ou un fichier local (photo éditée).
ImageProvider? _coachAvatarProvider(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('assets/')) return AssetImage(path);
  return FileImage(File(path));
}

class CoachDashboardPage extends StatefulWidget {
  /// Quand `true`, la page est affichée à l'intérieur d'un autre écran
  /// (ex. onglet Accueil du coach) : on retire alors le Scaffold/AppBar
  /// pour éviter une double barre d'application.
  final bool embedded;

  const CoachDashboardPage({super.key, this.embedded = false});

  @override
  State<CoachDashboardPage> createState() => _CoachDashboardPageState();
}

class _CoachDashboardPageState extends State<CoachDashboardPage> {
  final _repository = AppointmentsRepository();
  final _directory = CoachDirectoryNotifier();
  final _programs = CoachProgramsNotifier();
  final _content = CoachContentNotifier();

  /// Identifiant du coach connecté (source unique, plus de valeur en dur).
  String get _coachId => CoachSession().coachId;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
    _directory.addListener(_onDataChanged);
    _programs.addListener(_onDataChanged);
    _content.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    _directory.removeListener(_onDataChanged);
    _programs.removeListener(_onDataChanged);
    _content.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<Appointment> get _todayAppointments {
    final now = DateTime.now();
    return _repository.getAppointmentsForDay(now, coachId: _coachId)
        .where((a) => a.status != AppointmentStatus.cancelled)
        .toList();
  }

  List<Appointment> get _pendingAppointments {
    return _repository.getAppointmentsForCoach(_coachId)
        .where((a) => a.status == AppointmentStatus.pending)
        .toList();
  }

  /// Nombre de programmes réels créés (source : CoachProgramsNotifier).
  int get _programsCount => _programs.programs.length;

  /// Nombre de publications réelles du coach connecté (posts).
  int get _publicationsCount => _content.getPosts(_coachId).length;

  /// Nombre de clients de la démo (source unique : CoachClientsData).
  int get _clientsCount => CoachClientsData.demoClients.length;

  /// Séances (non annulées) planifiées pour le coach dans le mois en cours.
  int get _monthAppointmentsCount {
    final now = DateTime.now();
    return _repository
        .getAppointmentsForCoach(_coachId)
        .where((a) =>
            a.status != AppointmentStatus.cancelled &&
            a.start.year == now.year &&
            a.start.month == now.month)
        .length;
  }

  /// Jours réellement disponibles par semaine (source : Mes disponibilités).
  int get _availableDaysCount {
    return _repository
        .getOrCreateWeekly(_coachId)
        .where((d) => d.enabled && d.ranges.isNotEmpty)
        .length;
  }

  /// Nombre total de créneaux hebdomadaires configurés (source : Mes disponibilités).
  int get _weeklySlotsCount {
    return _repository
        .getOrCreateWeekly(_coachId)
        .where((d) => d.enabled)
        .fold<int>(0, (sum, d) => sum + d.ranges.length);
  }

  /// En-tête affichant l'identité du coach connecté, lue depuis la source
  /// unique (`CoachDirectoryNotifier`). Aucune donnée codée en dur : c'est le
  /// profil du coach connecté (par défaut `coach_1`, ou le coach inscrit).
  Widget _buildConnectedCoachHeader() {
    final coach = _directory.getCoachById(_coachId);
    final name = coach?.name ?? 'Mon espace coach';
    final specialty = coach?.specialty ?? '';
    final city = coach?.city ?? '';
    final subtitle = [specialty, city].where((s) => s.isNotEmpty).join(' · ');
    final avatar = _coachAvatarProvider(coach?.photoUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF161622)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.1),
            backgroundImage: avatar,
            child: avatar == null
                ? const Icon(Icons.person, color: Colors.white70, size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (coach?.isCertified == true) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Color(0xFFFFC300), size: 18),
                    ],
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (coach != null)
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC300), size: 16),
                const SizedBox(width: 4),
                Text(
                  coach.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayCount = _todayAppointments.length;
    final pendingCount = _pendingAppointments.length;

    final Widget body = SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ════════════════════════════════════════════════════════════
              // PROFIL DU COACH CONNECTÉ (source unique)
              // ════════════════════════════════════════════════════════════
              _buildConnectedCoachHeader(),
              const SizedBox(height: 20),
              // ════════════════════════════════════════════════════════════
              // STATISTIQUES
              // ════════════════════════════════════════════════════════════
              Text(
                "Vue d'ensemble",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Clients actifs',
                      value: '$_clientsCount',
                      icon: Icons.people,
                      color: const Color(0xFF3498DB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Programmes',
                      value: '$_programsCount',
                      icon: Icons.fitness_center,
                      color: const Color(0xFF9B59B6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Publications',
                      value: '$_publicationsCount',
                      icon: Icons.article_outlined,
                      color: const Color(0xFFE67E22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Séances du jour',
                      value: '$todayCount',
                      icon: Icons.today,
                      color: const Color(0xFFFFC300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'En attente',
                      value: '$pendingCount',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                      highlight: pendingCount > 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Ce mois',
                      value: '$_monthAppointmentsCount',
                      icon: Icons.calendar_month,
                      color: const Color(0xFF9B59B6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Jours dispo/sem',
                      value: '$_availableDaysCount',
                      icon: Icons.event_available,
                      color: const Color(0xFF2ECC71),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Créneaux/sem',
                      value: '$_weeklySlotsCount',
                      icon: Icons.access_time,
                      color: const Color(0xFF1ABC9C),
                    ),
                  ),
                ],
              ),

              // ════════════════════════════════════════════════════════════
              // RDV EN ATTENTE
              // ════════════════════════════════════════════════════════════
              if (pendingCount > 0) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'RDV en attente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._pendingAppointments.take(3).map((appt) => _PendingAppointmentCard(
                  appointment: appt,
                  onConfirm: () => _repository.confirmAppointment(appt.id),
                  onCancel: () => _repository.cancelAppointment(appt.id),
                )),
              ],

              // ════════════════════════════════════════════════════════════
              // ACTIONS RAPIDES
              // ════════════════════════════════════════════════════════════
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E1E2E),
                      const Color(0xFF161622),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions rapides',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Clients',
                            icon: Icons.people,
                            color: const Color(0xFF3498DB),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CoachClientsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Programmes',
                            icon: Icons.fitness_center,
                            color: const Color(0xFF9B59B6),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CoachProgramsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Mon Planning',
                            icon: Icons.calendar_today,
                            color: const Color(0xFFFFC300),
                            isPrimary: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const UnifiedPlanningPage(
                                    isCoachView: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Mes Dispos',
                            icon: Icons.access_time,
                            color: const Color(0xFF2ECC71),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CoachAvailabilityPage(coachId: _coachId),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      label: 'Mon profil public',
                      icon: Icons.badge_outlined,
                      color: const Color(0xFFFFC300),
                      isPrimary: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                CoachPublicProfileEditPage(coachId: _coachId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ════════════════════════════════════════════════════════════
              // PROCHAINES SÉANCES
              // ════════════════════════════════════════════════════════════
              const SizedBox(height: 24),
              Text(
                'Prochaines séances',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ..._todayAppointments.take(3).map((appt) => _UpcomingSessionCard(
                appointment: appt,
              )),
              if (_todayAppointments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 40,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pas de séance aujourd\'hui',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

    if (widget.embedded) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Dashboard Coach',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: body,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: highlight
            ? Border.all(color: color, width: 2)
            : Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: highlight
                        ? color
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isPrimary ? null : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(isPrimary ? 1 : 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.black : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.black : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PendingAppointmentCard({
    required this.appointment,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = '${appointment.start.hour.toString().padLeft(2, '0')}:${appointment.start.minute.toString().padLeft(2, '0')}';
    final dateStr = '${appointment.start.day}/${appointment.start.month}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange.withOpacity(0.3),
                child: Text(
                  appointment.clientName.isNotEmpty
                      ? appointment.clientName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.clientName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$dateStr à $timeStr • ${appointment.type?.displayName ?? ""}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'EN ATTENTE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Confirmer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Refuser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  final Appointment appointment;

  const _UpcomingSessionCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final timeStr = '${appointment.start.hour.toString().padLeft(2, '0')}:${appointment.start.minute.toString().padLeft(2, '0')}';
    final category = appointment.category;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            category.color.withOpacity(0.15),
            category.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    if (appointment.type != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${appointment.type!.displayName}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: appointment.status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: appointment.status.color.withOpacity(0.5)),
            ),
            child: Text(
              appointment.status.displayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: appointment.status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
