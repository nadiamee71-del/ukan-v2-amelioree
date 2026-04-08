import 'package:flutter/material.dart';
import '../models/group_class.dart';
import 'group_class_payment_demo.dart';

/// Page Détail d'un cours collectif
class GroupClassDetailPage extends StatelessWidget {
  final GroupClass groupClass;

  const GroupClassDetailPage({
    super.key,
    required this.groupClass,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      body: CustomScrollView(
        slivers: [
          // AppBar avec image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0D111C),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderImage(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {
                  // TODO: Partage
                },
              ),
            ],
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (groupClass.isLive)
                              _buildLiveBadge(),
                            if (!groupClass.isLive && !groupClass.isReplay && groupClass.startDateTime != null)
                              _buildUpcomingBadge(),
                            if (groupClass.isReplay)
                              _buildReplayBadge(),
                            const SizedBox(height: 12),
                            Text(
                              groupClass.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Coach + Note
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFC300).withOpacity(0.3),
                              const Color(0xFFFFC300).withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFC300).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFFFFC300),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              groupClass.coachName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFC300),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${groupClass.coachRating.toStringAsFixed(1)} (4.2k avis)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Infos principales (durée, calories, niveau)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildInfoCard(
                        icon: Icons.timer_outlined,
                        label: 'Durée',
                        value: groupClass.durationFormatted,
                      ),
                      if (groupClass.estimatedCalories > 0)
                        _buildInfoCard(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Calories',
                          value: '~${groupClass.estimatedCalories} kcal',
                        ),
                      _buildInfoCard(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: 'Niveau',
                        value: '${groupClass.level.emoji} ${groupClass.level.displayName}',
                      ),
                      if (groupClass.isLive)
                        _buildInfoCard(
                          icon: Icons.people_outline,
                          label: 'Participants',
                          value: '${groupClass.currentParticipants}/${groupClass.maxParticipants}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Accessoires requis
                  if (groupClass.accessories.isNotEmpty) ...[
                    const Text(
                      'Accessoires requis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: groupClass.accessories.map((acc) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D111C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: const Color(0xFFFFC300),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                acc,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  if (groupClass.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D111C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        groupClass.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bouton d'action
                  _buildActionButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(groupClass.category).withOpacity(0.6),
            _getCategoryColor(groupClass.category).withOpacity(0.3),
            const Color(0xFF050814),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Badge status en haut
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: groupClass.isLive
                    ? Colors.red
                    : groupClass.isReplay
                        ? Colors.blue
                        : const Color(0xFFFFC300),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (groupClass.isLive
                            ? Colors.red
                            : groupClass.isReplay
                                ? Colors.blue
                                : const Color(0xFFFFC300))
                        .withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (groupClass.isLive)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    groupClass.isLive
                        ? 'LIVE'
                        : groupClass.isReplay
                            ? 'REPLAY'
                            : 'BIENTÔT',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔴', style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text(
            'EN DIRECT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC300).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFC300),
          width: 2,
        ),
      ),
      child: Text(
        groupClass.countdownFormatted.isNotEmpty
            ? groupClass.countdownFormatted
            : 'Bientôt',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFFFFC300),
        ),
      ),
    );
  }

  Widget _buildReplayBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_fill, color: Colors.blue, size: 16),
          SizedBox(width: 6),
          Text(
            'REPLAY DISPONIBLE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.blue,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D111C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFC300), size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    String buttonText;
    VoidCallback onPressed;

    if (groupClass.isLive) {
      buttonText = 'PARTICIPER — ${groupClass.priceFormatted}';
      onPressed = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupClassPaymentDemoPage(groupClass: groupClass),
          ),
        );
      };
    } else if (groupClass.isReplay) {
      buttonText = 'VOIR LE REPLAY — ${groupClass.priceFormatted}';
      onPressed = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupClassPaymentDemoPage(groupClass: groupClass),
          ),
        );
      };
    } else if (groupClass.startDateTime != null) {
      buttonText = 'S\'INSCRIRE — ${groupClass.priceFormatted}';
      onPressed = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupClassPaymentDemoPage(groupClass: groupClass),
          ),
        );
      };
    } else {
      buttonText = 'EN SAVOIR PLUS';
      onPressed = () {};
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC300),
          foregroundColor: const Color(0xFF050814),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (groupClass.isLive)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'hiit':
        return Colors.orange;
      case 'yoga':
        return Colors.purple;
      case 'pilates':
        return Colors.pink;
      case 'strength':
        return Colors.blue;
      case 'cardio':
        return Colors.red;
      case 'dance':
        return Colors.pink;
      case 'boxing':
        return Colors.red;
      case 'stretching':
        return Colors.blue;
      case 'meditation':
        return Colors.indigo;
      default:
        return const Color(0xFFFFC300);
    }
  }
}







