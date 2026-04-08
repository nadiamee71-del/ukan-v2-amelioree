import 'package:flutter/material.dart';
import '../models/group_class.dart';
import 'dart:math' as math;

/// Carte verticale style TikTok pour cours live/upcoming
class GroupClassCardLive extends StatefulWidget {
  final GroupClass groupClass;
  final VoidCallback onTap;

  const GroupClassCardLive({
    super.key,
    required this.groupClass,
    required this.onTap,
  });

  @override
  State<GroupClassCardLive> createState() => _GroupClassCardLiveState();
}

class _GroupClassCardLiveState extends State<GroupClassCardLive>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: 480,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: widget.groupClass.isLive
                  ? Colors.red.withOpacity(0.4)
                  : const Color(0xFFFFC300).withOpacity(0.2),
              blurRadius: widget.groupClass.isLive ? 20 : 12,
              spreadRadius: widget.groupClass.isLive ? 2 : 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond (placeholder avec gradient)
              _buildBackground(),
              
              // Overlay gradient sombre
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Animation Halo rouge si LIVE
              if (widget.groupClass.isLive) _buildLiveHalo(),

              // Contenu
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Badge LIVE + Countdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLiveBadge(),
                        if (!widget.groupClass.isLive && widget.groupClass.countdownFormatted.isNotEmpty)
                          _buildCountdownBadge(),
                      ],
                    ),

                    // Bottom: Infos cours
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(
                          widget.groupClass.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Coach + Niveau
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D111C).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFFC300).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: const Color(0xFFFFC300),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.groupClass.coachName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: widget.groupClass.level == GroupClassLevel.beginner
                                    ? Colors.green.withOpacity(0.2)
                                    : widget.groupClass.level == GroupClassLevel.intermediate
                                        ? Colors.orange.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: widget.groupClass.level == GroupClassLevel.beginner
                                      ? Colors.green
                                      : widget.groupClass.level == GroupClassLevel.intermediate
                                          ? Colors.orange
                                          : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.groupClass.level.emoji,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.groupClass.level.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: widget.groupClass.level == GroupClassLevel.beginner
                                          ? Colors.green
                                          : widget.groupClass.level == GroupClassLevel.intermediate
                                              ? Colors.orange
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Durée + Calories + Participants
                        Row(
                          children: [
                            _buildInfoChip(
                              Icons.timer_outlined,
                              widget.groupClass.durationFormatted,
                            ),
                            const SizedBox(width: 8),
                            if (widget.groupClass.estimatedCalories > 0)
                              _buildInfoChip(
                                Icons.local_fire_department_outlined,
                                '${widget.groupClass.estimatedCalories} kcal',
                              ),
                            if (widget.groupClass.isLive) ...[
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.people_outline,
                                '${widget.groupClass.currentParticipants}',
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Accessoires
                        if (widget.groupClass.accessories.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.groupClass.accessories.map((acc) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  acc,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Bouton PARTICIPER
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC300),
                              foregroundColor: const Color(0xFF050814),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.groupClass.isLive)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Text(
                                  widget.groupClass.isLive
                                      ? 'PARTICIPER — ${widget.groupClass.priceFormatted}'
                                      : 'RÉSERVER — ${widget.groupClass.priceFormatted}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    // Placeholder avec gradient animé
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor().withOpacity(0.4),
            _getCategoryColor().withOpacity(0.2),
            const Color(0xFF050814),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              const Color(0xFFFFC300).withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHalo() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.6 * _glowController.value),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveBadge() {
    if (!widget.groupClass.isLive) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            '🔴',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(width: 6),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC300).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC300),
          width: 2,
        ),
      ),
      child: Text(
        widget.groupClass.countdownFormatted,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFC300),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.groupClass.category) {
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







