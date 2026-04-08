import 'package:flutter/material.dart';

// Couleurs professionnelles : Marron et Gris clair pour Coach Business
const Color _marronPrincipalBusiness = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonceBusiness = Color(0xFF5D4037); // Material Brown 700
const Color _marronClairBusiness = Color(0xFFA1887F); // Material Brown 300
const Color _grisClairBusiness = Color(0xFFE0E0E0); // Material Grey 300
const Color _grisPrincipalBusiness = Color(0xFF9E9E9E); // Material Grey 500
const Color _grisFonceBusiness = Color(0xFF616161); // Material Grey 700

/// Page Planning coach : séances du jour avec liste statique
class CoachSessionsTodayPage extends StatelessWidget {
  const CoachSessionsTodayPage({super.key});

  // Séances du jour (statiques pour la démo)
  static final List<_SessionToday> _sessionsToday = [
    const _SessionToday(
      clientName: 'Sarah',
      time: '18:00',
      workout: 'Full body',
      duration: 45,
      status: 'confirmé',
    ),
    const _SessionToday(
      clientName: 'Mehdi',
      time: '19:00',
      workout: 'HIIT',
      duration: 30,
      status: 'confirmé',
    ),
    const _SessionToday(
      clientName: 'Lina',
      time: '20:00',
      workout: 'Renforcement jambes',
      duration: 40,
      status: 'en attente',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _grisClairBusiness,
      appBar: AppBar(
        backgroundColor: _marronFonceBusiness,
        foregroundColor: Colors.white,
        title: const Text('Séances du jour'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Bannière résumé
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aujourd\'hui',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_sessionsToday.length} séances prévues',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _marronPrincipalBusiness.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: _marronPrincipalBusiness,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Liste des séances
            Expanded(
              child: _sessionsToday.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune séance prévue aujourd\'hui',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _sessionsToday.length,
                      itemBuilder: (context, index) {
                        final session = _sessionsToday[index];
                        return _SessionCard(session: session);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionToday {
  final String clientName;
  final String time;
  final String workout;
  final int duration; // minutes
  final String status; // 'confirmé', 'en attente', 'annulé'

  const _SessionToday({
    required this.clientName,
    required this.time,
    required this.workout,
    required this.duration,
    required this.status,
  });
}

class _SessionCard extends StatelessWidget {
  final _SessionToday session;

  const _SessionCard({required this.session});

  Color _getStatusColor() {
    switch (session.status) {
      case 'confirmé':
        return _marronPrincipalBusiness;
      case 'en attente':
        return _grisPrincipalBusiness;
      case 'annulé':
        return _grisFonceBusiness;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBgColor() {
    switch (session.status) {
      case 'confirmé':
        return _marronPrincipalBusiness.withOpacity(0.1);
      case 'en attente':
        return _grisPrincipalBusiness.withOpacity(0.1);
      case 'annulé':
        return _grisFonceBusiness.withOpacity(0.1);
      default:
        return Colors.grey.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Heure
          Container(
            width: 70,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _marronFonceBusiness,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  session.time,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _marronPrincipalBusiness,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.duration} min',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.clientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.workout,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
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
                      const SizedBox(width: 6),
                      Text(
                        session.status,
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
          ),

          // Icône flèche
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}








