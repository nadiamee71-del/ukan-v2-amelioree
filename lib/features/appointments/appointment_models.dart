/// Modèles de données pour le système de rendez-vous Coach/Client
/// Ukan - Mode DEMO

import 'package:flutter/material.dart';

/// Catégorie de séance (Solo, Coach, Groupe)
enum SessionCategory {
  solo,      // Séance personnelle
  coach,     // RDV avec coach
  group,     // Séance en groupe/room
}

extension SessionCategoryExtension on SessionCategory {
  String get displayName {
    switch (this) {
      case SessionCategory.solo:
        return 'Séance solo';
      case SessionCategory.coach:
        return 'RDV Coach';
      case SessionCategory.group:
        return 'Séance groupe';
    }
  }

  IconData get icon {
    switch (this) {
      case SessionCategory.solo:
        return Icons.person;
      case SessionCategory.coach:
        return Icons.sports;
      case SessionCategory.group:
        return Icons.groups;
    }
  }

  Color get color {
    switch (this) {
      case SessionCategory.solo:
        return const Color(0xFF3498DB); // Bleu
      case SessionCategory.coach:
        return const Color(0xFFFFC300); // Jaune Ukan
      case SessionCategory.group:
        return const Color(0xFF9B59B6); // Violet
    }
  }
}

/// Types de rendez-vous disponibles (pour RDV coach uniquement)
enum AppointmentType {
  visio,
  presentiel,
  salle,
  domicile,
}

extension AppointmentTypeExtension on AppointmentType {
  String get displayName {
    switch (this) {
      case AppointmentType.visio:
        return 'Visio';
      case AppointmentType.presentiel:
        return 'Présentiel';
      case AppointmentType.salle:
        return 'En salle';
      case AppointmentType.domicile:
        return 'À domicile';
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentType.visio:
        return Icons.videocam;
      case AppointmentType.presentiel:
        return Icons.person;
      case AppointmentType.salle:
        return Icons.fitness_center;
      case AppointmentType.domicile:
        return Icons.home;
    }
  }

  Color get color {
    switch (this) {
      case AppointmentType.visio:
        return const Color(0xFF9B59B6); // Violet Ukan
      case AppointmentType.presentiel:
        return const Color(0xFFFFC300); // Jaune Ukan
      case AppointmentType.salle:
        return const Color(0xFF5C4033); // Marron Ukan
      case AppointmentType.domicile:
        return const Color(0xFF1ABC9C); // Turquoise
    }
  }
}

/// Statut d'un rendez-vous
enum AppointmentStatus {
  pending,    // En attente de confirmation
  confirmed,  // Confirmé
  cancelled,  // Annulé
  completed,  // Terminé
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'En attente';
      case AppointmentStatus.confirmed:
        return 'Confirmé';
      case AppointmentStatus.cancelled:
        return 'Annulé';
      case AppointmentStatus.completed:
        return 'Terminé';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return const Color(0xFF2ECC71);
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.completed:
        return Icons.done_all;
    }
  }
}

/// Modèle de rendez-vous / séance
class Appointment {
  final String id;
  final SessionCategory category; // Solo, Coach, ou Groupe
  final String? coachId;      // Null pour séances solo
  final String? coachName;    // Null pour séances solo
  final String coachPhotoUrl;
  final String clientId;
  final String clientName;
  final String clientPhotoUrl;
  final DateTime start;
  final DateTime end;
  final AppointmentType? type; // Null pour séances solo/groupe
  final AppointmentStatus status;
  final String? note;
  final String? title;        // Titre de la séance (pour solo/groupe)
  final String? location;     // Lieu (pour groupe)
  final DateTime createdAt;

  Appointment({
    required this.id,
    this.category = SessionCategory.coach,
    this.coachId,
    this.coachName,
    this.coachPhotoUrl = '',
    required this.clientId,
    required this.clientName,
    this.clientPhotoUrl = '',
    required this.start,
    required this.end,
    this.type,
    this.status = AppointmentStatus.pending,
    this.note,
    this.title,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get color => category == SessionCategory.coach 
      ? (type?.color ?? category.color)
      : category.color;

  Duration get duration => end.difference(start);

  bool get isPast => end.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return start.year == now.year && 
           start.month == now.month && 
           start.day == now.day;
  }
  bool get isUpcoming => start.isAfter(DateTime.now());

  /// Nom à afficher selon la catégorie
  String get displayName {
    if (category == SessionCategory.solo) {
      return title ?? 'Séance solo';
    } else if (category == SessionCategory.group) {
      return title ?? 'Séance groupe';
    } else {
      return coachName ?? 'RDV Coach';
    }
  }

  Appointment copyWith({
    String? id,
    SessionCategory? category,
    String? coachId,
    String? coachName,
    String? coachPhotoUrl,
    String? clientId,
    String? clientName,
    String? clientPhotoUrl,
    DateTime? start,
    DateTime? end,
    AppointmentType? type,
    AppointmentStatus? status,
    String? note,
    String? title,
    String? location,
  }) {
    return Appointment(
      id: id ?? this.id,
      category: category ?? this.category,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      coachPhotoUrl: coachPhotoUrl ?? this.coachPhotoUrl,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhotoUrl: clientPhotoUrl ?? this.clientPhotoUrl,
      start: start ?? this.start,
      end: end ?? this.end,
      type: type ?? this.type,
      status: status ?? this.status,
      note: note ?? this.note,
      title: title ?? this.title,
      location: location ?? this.location,
      createdAt: createdAt,
    );
  }
}

/// Créneau de disponibilité du coach
class AvailableSlot {
  final String id;
  final DateTime start;
  final DateTime end;
  final bool isRecurring;
  final List<int>? recurringDays; // 1=Lundi, 7=Dimanche

  AvailableSlot({
    String? id,
    required this.start,
    required this.end,
    this.isRecurring = false,
    this.recurringDays,
  }) : id = id ?? '${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';

  Duration get duration => end.difference(start);

  bool containsTime(DateTime time) {
    return time.isAfter(start) && time.isBefore(end) ||
           time.isAtSameMomentAs(start);
  }

  bool overlaps(DateTime otherStart, DateTime otherEnd) {
    return start.isBefore(otherEnd) && end.isAfter(otherStart);
  }

  AvailableSlot copyWith({
    DateTime? start,
    DateTime? end,
    bool? isRecurring,
    List<int>? recurringDays,
  }) {
    return AvailableSlot(
      id: id,
      start: start ?? this.start,
      end: end ?? this.end,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
    );
  }
}

/// Disponibilités d'un coach
class CoachAvailability {
  final String coachId;
  final List<AvailableSlot> slots;
  final List<int> workingDays; // 1=Lundi, 7=Dimanche
  final TimeOfDay defaultStartTime;
  final TimeOfDay defaultEndTime;
  final Duration defaultSlotDuration;

  CoachAvailability({
    required this.coachId,
    this.slots = const [],
    this.workingDays = const [1, 2, 3, 4, 5], // Lun-Ven par défaut
    TimeOfDay? defaultStartTime,
    TimeOfDay? defaultEndTime,
    this.defaultSlotDuration = const Duration(hours: 1),
  }) : defaultStartTime = defaultStartTime ?? TimeOfDay(hour: 8, minute: 0),
       defaultEndTime = defaultEndTime ?? TimeOfDay(hour: 18, minute: 0);

  CoachAvailability copyWith({
    List<AvailableSlot>? slots,
    List<int>? workingDays,
    TimeOfDay? defaultStartTime,
    TimeOfDay? defaultEndTime,
    Duration? defaultSlotDuration,
  }) {
    return CoachAvailability(
      coachId: coachId,
      slots: slots ?? this.slots,
      workingDays: workingDays ?? this.workingDays,
      defaultStartTime: defaultStartTime ?? this.defaultStartTime,
      defaultEndTime: defaultEndTime ?? this.defaultEndTime,
      defaultSlotDuration: defaultSlotDuration ?? this.defaultSlotDuration,
    );
  }
}

/// Informations utilisateur simplifiées
class AppointmentUser {
  final String id;
  final String name;
  final String photoUrl;
  final bool isCoach;
  final String? specialty; // Pour les coachs

  const AppointmentUser({
    required this.id,
    required this.name,
    this.photoUrl = '',
    this.isCoach = false,
    this.specialty,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// DISPONIBILITÉS HEBDOMADAIRES + EXCEPTIONS
// Modèles partagés entre CoachAvailabilityPage (édition) et
// AppointmentsRepository (génération des créneaux réservables côté client).
// ═══════════════════════════════════════════════════════════════════════════

class DayAvailability{DayAvailability(this.name,List<TimeRange> r,{this.enabled=true}):ranges=[...r];final String name;bool enabled;List<TimeRange> ranges;DayAvailability copy()=>DayAvailability(name,ranges.map((e)=>e.copy()).toList(),enabled:enabled);String get summary=>!enabled?'Aucun créneau — journée indisponible':ranges.isEmpty?'Aucun créneau configuré':ranges.map((e)=>e.label).join(' · ');}
class TimeRange{TimeRange(this.sh,this.sm,this.eh,this.em);final int sh,sm,eh,em;TimeOfDay get start=>TimeOfDay(hour:sh,minute:sm);TimeOfDay get end=>TimeOfDay(hour:eh,minute:em);int get begin=>sh*60+sm;int get finish=>eh*60+em;String get label=>'${two(sh)}:${two(sm)}–${two(eh)}:${two(em)}';TimeRange copy()=>TimeRange(sh,sm,eh,em);TimeRange withStart(TimeOfDay t)=>TimeRange(t.hour,t.minute,eh,em);TimeRange withEnd(TimeOfDay t)=>TimeRange(sh,sm,t.hour,t.minute);}
class DayResult{DayResult(this.day,Set<int> t):targets={...t};final DayAvailability day;final Set<int> targets;}
enum ExceptionKind{unavailable('Indisponible'),special('Disponibilité exceptionnelle'),vacation('Vacances'),modified('Horaires modifiés');const ExceptionKind(this.label);final String label;}
class AvailabilityException{AvailabilityException(this.id,this.start,{this.end,required this.kind,this.allDay=false,List<TimeRange> ranges=const[],this.reason=''}):ranges=[...ranges];int id;DateTime start;DateTime? end;ExceptionKind kind;bool allDay;List<TimeRange> ranges;String reason;AvailabilityException copy()=>AvailabilityException(id,start,end:end,kind:kind,allDay:allDay,ranges:ranges.map((e)=>e.copy()).toList(),reason:reason);String get dateLabel=>end==null?fullDate(start):'${shortDate(start)} – ${shortDate(end!)}';}

String two(int n)=>n.toString().padLeft(2,'0');
const months=['janvier','février','mars','avril','mai','juin','juillet','août','septembre','octobre','novembre','décembre'];
String monthKey(DateTime d)=>'${d.year}-${two(d.month)}';
String monthLabel(DateTime d)=>'${months[d.month-1][0].toUpperCase()}${months[d.month-1].substring(1)} ${d.year}';
String fullDate(DateTime d)=>'${d.day} ${months[d.month-1]} ${d.year}';
String shortDate(DateTime d)=>'${d.day} ${months[d.month-1].substring(0,3)} ${d.year}';

/// Calcule les plages horaires réellement disponibles pour [date] à partir du
/// planning hebdomadaire [week] (index 0=Lundi … 6=Dimanche) et des [exceptions]
/// (vacances, journées indisponibles, créneaux exceptionnels/horaires modifiés).
List<TimeRange> availabilityRangesForDate(
  DateTime date,
  List<DayAvailability> week,
  List<AvailabilityException> exceptions,
) {
  if (week.isEmpty) return const [];
  final day = week[(date.weekday - 1) % 7];
  var ranges = day.enabled ? day.ranges.map((r) => r.copy()).toList() : <TimeRange>[];

  final d = DateTime(date.year, date.month, date.day);
  final applicable = exceptions.where((e) {
    final s = DateTime(e.start.year, e.start.month, e.start.day);
    final ed = e.end ?? e.start;
    final f = DateTime(ed.year, ed.month, ed.day);
    return !d.isBefore(s) && !d.isAfter(f);
  }).toList();

  // Créneaux exceptionnels (special = ajout) / horaires modifiés (remplacement)
  final extra = <TimeRange>[];
  var replace = false;
  for (final e in applicable) {
    if (e.kind == ExceptionKind.special || e.kind == ExceptionKind.modified) {
      if (e.kind == ExceptionKind.modified) replace = true;
      if (!e.allDay) extra.addAll(e.ranges.map((r) => r.copy()));
    }
  }
  if (extra.isNotEmpty) {
    ranges = replace ? extra : [...ranges, ...extra];
  }

  // Vacances / indisponibilités (journée complète = bloquée, sinon soustraction)
  for (final e in applicable) {
    if (e.kind == ExceptionKind.vacation || e.kind == ExceptionKind.unavailable) {
      if (e.allDay) return const [];
      ranges = _subtractRanges(ranges, e.ranges);
    }
  }

  ranges.sort((a, b) => a.begin.compareTo(b.begin));
  return ranges;
}

List<TimeRange> _subtractRanges(List<TimeRange> base, List<TimeRange> blocks) {
  var segments = base.map((r) => [r.begin, r.finish]).toList();
  for (final b in blocks) {
    final next = <List<int>>[];
    for (final seg in segments) {
      final s = seg[0], e = seg[1];
      if (b.finish <= s || b.begin >= e) {
        next.add([s, e]);
        continue;
      }
      if (b.begin > s) next.add([s, b.begin]);
      if (b.finish < e) next.add([b.finish, e]);
    }
    segments = next;
  }
  return segments
      .where((seg) => seg[1] > seg[0])
      .map((seg) => TimeRange(seg[0] ~/ 60, seg[0] % 60, seg[1] ~/ 60, seg[1] % 60))
      .toList();
}

