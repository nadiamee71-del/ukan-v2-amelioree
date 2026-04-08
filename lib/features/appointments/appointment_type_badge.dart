/// Badge pour afficher le type de rendez-vous
/// Ukan - Style cohérent

import 'package:flutter/material.dart';
import 'appointment_models.dart';

class AppointmentTypeBadge extends StatelessWidget {
  final AppointmentType type;
  final bool showLabel;
  final bool compact;

  const AppointmentTypeBadge({
    super.key,
    required this.type,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: type.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 12 : 8,
        vertical: showLabel ? 6 : 6,
      ),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: type.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type.icon,
            size: showLabel ? 16 : 14,
            color: type.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              type.displayName,
              style: TextStyle(
                color: type.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppointmentStatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  final bool compact;

  const AppointmentStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: status.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 14,
            color: status.color,
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card pour afficher un rendez-vous dans une liste
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isCoachView;
  final VoidCallback? onTap;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isCoachView = false,
    this.onTap,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = appointment.status == AppointmentStatus.cancelled;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isCancelled 
              ? Colors.grey.withOpacity(0.1)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCancelled 
                ? Colors.grey.withOpacity(0.2)
                : appointment.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Bande colorée à gauche
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isCancelled ? Colors.grey : appointment.color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec heure et type
                  Row(
                    children: [
                      // Heure
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${appointment.start.hour.toString().padLeft(2, '0')}:${appointment.start.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: isCancelled ? Colors.grey : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: isCancelled 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Durée
                      Text(
                        '${appointment.duration.inMinutes} min',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Type badge (si coach) ou category badge
                      if (appointment.type != null)
                        AppointmentTypeBadge(type: appointment.type!)
                      else
                        _CategoryBadge(category: appointment.category),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Nom de la personne ou titre de séance
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: appointment.color.withOpacity(0.2),
                        child: Text(
                          appointment.displayName.isNotEmpty 
                              ? appointment.displayName.substring(0, 1).toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: appointment.color,
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
                              isCoachView 
                                  ? appointment.clientName 
                                  : (appointment.coachName ?? appointment.displayName),
                              style: TextStyle(
                                color: isCancelled ? Colors.grey : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                decoration: isCancelled 
                                    ? TextDecoration.lineThrough 
                                    : null,
                              ),
                            ),
                            if (appointment.note != null && appointment.note!.isNotEmpty)
                              Text(
                                appointment.note!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      
                      // Status badge
                      AppointmentStatusBadge(status: appointment.status),
                    ],
                  ),
                  
                  // Actions (si RDV en attente et vue coach)
                  if (appointment.status == AppointmentStatus.pending && 
                      isCoachView && 
                      (onConfirm != null || onCancel != null)) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (onConfirm != null)
                          Expanded(
                            child: _ActionButton(
                              label: 'Confirmer',
                              color: const Color(0xFF2ECC71),
                              onTap: onConfirm!,
                            ),
                          ),
                        if (onConfirm != null && onCancel != null)
                          const SizedBox(width: 8),
                        if (onCancel != null)
                          Expanded(
                            child: _ActionButton(
                              label: 'Refuser',
                              color: Colors.red,
                              onTap: onCancel!,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge pour la catégorie de séance (Solo, Coach, Groupe)
class _CategoryBadge extends StatelessWidget {
  final SessionCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: category.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 16, color: category.color),
          const SizedBox(width: 6),
          Text(
            category.displayName,
            style: TextStyle(
              color: category.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

