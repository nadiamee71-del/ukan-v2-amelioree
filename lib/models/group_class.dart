import 'package:flutter/material.dart';

/// Modèle d'un cours collectif live/replay dans Ukan
class GroupClass {
  final String id;
  final String title;
  final String coachName;
  final String coachId;
  final double coachRating;
  final GroupClassLevel level;
  final int durationMinutes;
  final double price;
  final int demoDurationMinutes; // Durée de la démo gratuite
  final DateTime? startDateTime;
  final bool isLive;
  final bool isReplay;
  final List<String> accessories;
  final String category;
  final String? coverImage; // Asset path ou placeholder
  final String description;
  final int estimatedCalories;
  final int currentParticipants; // Pour les live
  final int maxParticipants; // Pour les live

  const GroupClass({
    required this.id,
    required this.title,
    required this.coachName,
    required this.coachId,
    this.coachRating = 4.8,
    required this.level,
    required this.durationMinutes,
    required this.price,
    this.demoDurationMinutes = 5, // 5 min de démo par défaut
    this.startDateTime,
    this.isLive = false,
    this.isReplay = false,
    this.accessories = const [],
    required this.category,
    this.coverImage,
    this.description = '',
    this.estimatedCalories = 0,
    this.currentParticipants = 0,
    this.maxParticipants = 50,
  });

  /// Durée formatée (ex: "45 min")
  String get durationFormatted => '$durationMinutes min';

  /// Prix formaté (ex: "3,99 €")
  String get priceFormatted => '${price.toStringAsFixed(2).replaceAll('.', ',')} €';

  /// Temps restant avant le début (si programmé)
  Duration? get timeUntilStart {
    if (startDateTime == null || isLive) return null;
    final now = DateTime.now();
    if (startDateTime!.isBefore(now)) return null;
    return startDateTime!.difference(now);
  }

  /// Format countdown (ex: "Dans 1h 15min")
  String get countdownFormatted {
    final duration = timeUntilStart;
    if (duration == null) return '';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return 'Dans ${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return 'Dans ${minutes}min';
    } else {
      return 'Bientôt';
    }
  }
}

enum GroupClassLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case GroupClassLevel.beginner:
        return 'Débutant';
      case GroupClassLevel.intermediate:
        return 'Intermédiaire';
      case GroupClassLevel.advanced:
        return 'Avancé';
    }
  }

  String get emoji {
    switch (this) {
      case GroupClassLevel.beginner:
        return '🌱';
      case GroupClassLevel.intermediate:
        return '🔥';
      case GroupClassLevel.advanced:
        return '💪';
    }
  }
}

enum GroupClassCategory {
  hiit,
  yoga,
  pilates,
  strength,
  cardio,
  dance,
  boxing,
  judo,
  karate,
  mma,
  zumba,
  stretching,
  meditation,
  cycling,
  crossfit;

  String get displayName {
    switch (this) {
      case GroupClassCategory.hiit:
        return 'HIIT';
      case GroupClassCategory.yoga:
        return 'Yoga';
      case GroupClassCategory.pilates:
        return 'Pilates';
      case GroupClassCategory.strength:
        return 'Renforcement';
      case GroupClassCategory.cardio:
        return 'Cardio';
      case GroupClassCategory.dance:
        return 'Danse';
      case GroupClassCategory.boxing:
        return 'Boxe';
      case GroupClassCategory.judo:
        return 'Judo';
      case GroupClassCategory.karate:
        return 'Karaté';
      case GroupClassCategory.mma:
        return 'MMA';
      case GroupClassCategory.zumba:
        return 'Zumba';
      case GroupClassCategory.stretching:
        return 'Stretching';
      case GroupClassCategory.meditation:
        return 'Méditation';
      case GroupClassCategory.cycling:
        return 'Cycling';
      case GroupClassCategory.crossfit:
        return 'CrossFit';
    }
  }

  String get emoji {
    switch (this) {
      case GroupClassCategory.hiit:
        return '⚡';
      case GroupClassCategory.yoga:
        return '🧘';
      case GroupClassCategory.pilates:
        return '✨';
      case GroupClassCategory.strength:
        return '💪';
      case GroupClassCategory.cardio:
        return '❤️';
      case GroupClassCategory.dance:
        return '💃';
      case GroupClassCategory.boxing:
        return '🥊';
      case GroupClassCategory.judo:
        return '🥋';
      case GroupClassCategory.karate:
        return '🥷';
      case GroupClassCategory.mma:
        return '🤼';
      case GroupClassCategory.zumba:
        return '🎉';
      case GroupClassCategory.stretching:
        return '🤸';
      case GroupClassCategory.meditation:
        return '🧘‍♀️';
      case GroupClassCategory.cycling:
        return '🚴';
      case GroupClassCategory.crossfit:
        return '🏋️';
    }
  }

  Color get color {
    switch (this) {
      case GroupClassCategory.hiit:
        return const Color(0xFFFF6B6B);
      case GroupClassCategory.yoga:
        return const Color(0xFF4ECDC4);
      case GroupClassCategory.pilates:
        return const Color(0xFFA855F7);
      case GroupClassCategory.strength:
        return const Color(0xFFFFC300);
      case GroupClassCategory.cardio:
        return const Color(0xFFFF6B6B);
      case GroupClassCategory.dance:
        return const Color(0xFFFF9F43);
      case GroupClassCategory.boxing:
        return const Color(0xFFFF6B6B);
      case GroupClassCategory.judo:
        return const Color(0xFF58A6FF);
      case GroupClassCategory.karate:
        return const Color(0xFF8B5CF6);
      case GroupClassCategory.mma:
        return const Color(0xFFDC2626);
      case GroupClassCategory.zumba:
        return const Color(0xFFEC4899);
      case GroupClassCategory.stretching:
        return const Color(0xFF22D3EE);
      case GroupClassCategory.meditation:
        return const Color(0xFF10B981);
      case GroupClassCategory.cycling:
        return const Color(0xFFF59E0B);
      case GroupClassCategory.crossfit:
        return const Color(0xFFEF4444);
    }
  }
}

