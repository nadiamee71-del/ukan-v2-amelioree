import 'package:flutter/material.dart';
import 'coach_client_detail_page.dart';

class CoachClientsPage extends StatelessWidget {
  const CoachClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = CoachClientsData.demoClients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes clients'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${clients.length} clients suivis actuellement.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return _ClientCard(
                    client: client,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CoachClientDetailPage(client: client),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: clients.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Source unique des clients de démonstration du coach.
///
/// Réutilisée par la page « Mes clients » ET par le Dashboard Coach
/// (compteur « Clients actifs »), afin d'éviter toute donnée dupliquée.
/// Reste en mémoire (démo) : ces clients ne sont pas encore rattachés à un
/// identifiant de coach ni persistés.
class CoachClientsData {
  const CoachClientsData._();

  static const List<CoachClient> demoClients = [
    CoachClient(
      id: 'sarah',
      name: 'Sarah',
      age: 29,
      goal: 'Perte de poids',
      sessionsPerWeek: 3,
      level: 'Intermédiaire',
      currentWeight: 72,
      targetWeight: 65,
      status: 'Actif',
    ),
    CoachClient(
      id: 'mehdi',
      name: 'Mehdi',
      age: 26,
      goal: 'Prise de masse',
      sessionsPerWeek: 4,
      level: 'Intermédiaire',
      currentWeight: 70,
      targetWeight: 78,
      status: 'Actif',
    ),
    CoachClient(
      id: 'lina',
      name: 'Lina',
      age: 34,
      goal: 'Remise en forme',
      sessionsPerWeek: 2,
      level: 'Débutante',
      currentWeight: 60,
      targetWeight: 58,
      status: 'Actif',
    ),
    CoachClient(
      id: 'alex',
      name: 'Alex',
      age: 31,
      goal: 'Perte de poids',
      sessionsPerWeek: 3,
      level: 'Avancé',
      currentWeight: 85,
      targetWeight: 75,
      status: 'En pause',
    ),
    CoachClient(
      id: 'marie',
      name: 'Marie',
      age: 28,
      goal: 'Prise de masse',
      sessionsPerWeek: 5,
      level: 'Avancé',
      currentWeight: 65,
      targetWeight: 72,
      status: 'Nouveau',
    ),
  ];

  /// Nombre de clients au statut « Actif ».
  static int get activeCount =>
      demoClients.where((c) => c.status == 'Actif').length;
}

class CoachClient {
  final String id;
  final String name;
  final int age;
  final String goal;
  final int sessionsPerWeek;
  final String level;
  final double currentWeight;
  final double targetWeight;
  final String status; // 'Actif', 'En pause', 'Nouveau'

  const CoachClient({
    required this.id,
    required this.name,
    required this.age,
    required this.goal,
    required this.sessionsPerWeek,
    required this.level,
    required this.currentWeight,
    required this.targetWeight,
    this.status = 'Actif',
  });
}

class _ClientCard extends StatelessWidget {
  final CoachClient client;
  final VoidCallback onTap;

  const _ClientCard({
    required this.client,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (client.status) {
      case 'Actif':
        return Colors.green;
      case 'En pause':
        return Colors.orange;
      case 'Nouveau':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBgColor() {
    switch (client.status) {
      case 'Actif':
        return Colors.green.shade50;
      case 'En pause':
        return Colors.orange.shade50;
      case 'Nouveau':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
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
                    fontSize: 24,
                    color: Color(0xFFFFC300),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          client.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      // Badge statut
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getStatusColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              client.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.track_changes,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Objectif : ${client.goal}',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${client.sessionsPerWeek}/semaine',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        client.level,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Flèche
            Icon(
              Icons.chevron_right,
              color: cs.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
