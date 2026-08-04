/// Repository pour gérer les rendez-vous Coach/Client
/// Ukan - Mode DEMO avec données mock

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'appointment_models.dart';

class AppointmentsRepository extends ChangeNotifier {
  // Singleton
  static final AppointmentsRepository _instance = AppointmentsRepository._internal();
  factory AppointmentsRepository() => _instance;
  AppointmentsRepository._internal() {
    _initDemoData();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DONNÉES EN MÉMOIRE
  // ═══════════════════════════════════════════════════════════════════════════

  final List<Appointment> _appointments = [];
  final Map<String, CoachAvailability> _coachAvailabilities = {};

  // Planning hebdomadaire + exceptions édités dans CoachAvailabilityPage.
  // Source unique des créneaux réservables (via getAvailableSlotsForDay).
  final Map<String, List<DayAvailability>> _weeklyByCoach = {};
  final Map<String, List<AvailabilityException>> _availabilityExceptions = {};
  
  // Utilisateur actuel (DEMO)
  String _currentUserId = 'client_demo_1';
  bool _isCurrentUserCoach = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALISATION DEMO
  // ═══════════════════════════════════════════════════════════════════════════

  void _initDemoData() {
    final now = DateTime.now();
    
    // Créer des disponibilités pour les coachs démo
    _coachAvailabilities['coach_1'] = CoachAvailability(
      coachId: 'coach_1',
      workingDays: [1, 2, 3, 4, 5], // Lun-Ven
      defaultStartTime: TimeOfDay(hour: 8, minute: 0),
      defaultEndTime: TimeOfDay(hour: 19, minute: 0),
      slots: _generateWeekSlots('coach_1', now),
    );

    _coachAvailabilities['coach_2'] = CoachAvailability(
      coachId: 'coach_2',
      workingDays: [1, 2, 3, 4, 5, 6], // Lun-Sam
      defaultStartTime: TimeOfDay(hour: 9, minute: 0),
      defaultEndTime: TimeOfDay(hour: 20, minute: 0),
      slots: _generateWeekSlots('coach_2', now),
    );

    // Planning hebdo + exceptions du coach courant (coach_1) — pilote le booking client
    _weeklyByCoach['coach_1'] = _defaultWeekly();
    _availabilityExceptions['coach_1'] = [
      AvailabilityException(1, DateTime(2026, 8, 14),
          kind: ExceptionKind.unavailable, allDay: true, reason: 'Jour férié'),
      AvailabilityException(2, DateTime(2026, 8, 24),
          kind: ExceptionKind.special, ranges: [TimeRange(9, 0, 12, 0)], reason: 'Créneau exceptionnel'),
      AvailabilityException(3, DateTime(2026, 9, 1), end: DateTime(2026, 9, 5),
          kind: ExceptionKind.vacation, allDay: true, reason: 'Vacances'),
    ];

    // Créer des RDV et séances démo
    _appointments.addAll([
      // ═══════════════════════════════════════════════════════════════
      // SÉANCES SOLO (personnelles)
      // ═══════════════════════════════════════════════════════════════
      Appointment(
        id: 'solo_1',
        category: SessionCategory.solo,
        clientId: 'client_demo_1',
        clientName: 'Thomas Martin',
        start: DateTime(now.year, now.month, now.day, 7, 0),
        end: DateTime(now.year, now.month, now.day, 8, 0),
        title: 'Full body matinal',
        status: AppointmentStatus.confirmed,
        note: 'Échauffement + musculation',
      ),
      Appointment(
        id: 'solo_2',
        category: SessionCategory.solo,
        clientId: 'client_demo_1',
        clientName: 'Thomas Martin',
        start: now.add(const Duration(days: 1, hours: 6)),
        end: now.add(const Duration(days: 1, hours: 7)),
        title: 'Cardio 30 min',
        status: AppointmentStatus.confirmed,
      ),
      Appointment(
        id: 'solo_3',
        category: SessionCategory.solo,
        clientId: 'client_demo_1',
        clientName: 'Thomas Martin',
        start: now.add(const Duration(days: 2, hours: 18)),
        end: now.add(const Duration(days: 2, hours: 19)),
        title: 'Push day',
        status: AppointmentStatus.confirmed,
        note: 'Pectoraux + Épaules + Triceps',
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // SÉANCES GROUPE
      // ═══════════════════════════════════════════════════════════════
      Appointment(
        id: 'group_1',
        category: SessionCategory.group,
        clientId: 'client_demo_1',
        clientName: 'Thomas Martin',
        start: now.add(const Duration(days: 3, hours: 19)),
        end: now.add(const Duration(days: 3, hours: 20)),
        title: 'CrossFit avec amis',
        location: 'Salle Ukan Paris',
        status: AppointmentStatus.confirmed,
        note: 'Avec Marc et Julie',
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // RDV COACH
      // ═══════════════════════════════════════════════════════════════
      // RDV passé
      Appointment(
        id: 'appt_1',
        category: SessionCategory.coach,
        coachId: 'coach_1',
        coachName: 'Coach Ali',
        coachPhotoUrl: 'assets/images/coach1_header.png',
        clientId: 'client_demo_1',
        clientName: 'Thomas Martin',
        start: now.subtract(const Duration(days: 2, hours: 2)),
        end: now.subtract(const Duration(days: 2, hours: 1)),
        type: AppointmentType.presentiel,
        status: AppointmentStatus.completed,
        note: 'Séance de remise en forme',
      ),
      // RDV aujourd'hui
      Appointment(
        id: 'appt_2',
        category: SessionCategory.coach,
        coachId: 'coach_1',
        coachName: 'Coach Ali',
        coachPhotoUrl: 'assets/images/coach1_header.png',
        clientId: 'client_demo_1',
        clientName: 'Thomas Martin',
        start: DateTime(now.year, now.month, now.day, 14, 0),
        end: DateTime(now.year, now.month, now.day, 15, 0),
        type: AppointmentType.visio,
        status: AppointmentStatus.confirmed,
        note: 'Suivi nutrition',
      ),
      // RDV demain
      Appointment(
        id: 'appt_3',
        category: SessionCategory.coach,
        coachId: 'coach_2',
        coachName: 'Coach Sarah',
        coachPhotoUrl: 'assets/images/coach2_header.png',
        clientId: 'client_demo_1',
        clientName: 'Thomas Martin',
        start: now.add(const Duration(days: 1, hours: 3)),
        end: now.add(const Duration(days: 1, hours: 4)),
        type: AppointmentType.salle,
        status: AppointmentStatus.pending,
        note: 'Première séance découverte',
      ),
      // RDV la semaine prochaine
      Appointment(
        id: 'appt_4',
        category: SessionCategory.coach,
        coachId: 'coach_1',
        coachName: 'Coach Ali',
        coachPhotoUrl: 'assets/images/coach1_header.png',
        clientId: 'client_demo_1',
        clientName: 'Thomas Martin',
        start: now.add(const Duration(days: 5)),
        end: now.add(const Duration(days: 5, hours: 1)),
        type: AppointmentType.domicile,
        status: AppointmentStatus.confirmed,
      ),
      // RDV annulé
      Appointment(
        id: 'appt_5',
        category: SessionCategory.coach,
        coachId: 'coach_1',
        coachName: 'Coach Ali',
        coachPhotoUrl: 'assets/images/coach1_header.png',
        clientId: 'client_demo_2',
        clientName: 'Julie Dupont',
        start: now.add(const Duration(days: 3)),
        end: now.add(const Duration(days: 3, hours: 1)),
        type: AppointmentType.presentiel,
        status: AppointmentStatus.cancelled,
      ),
    ]);
  }

  List<AvailableSlot> _generateWeekSlots(String coachId, DateTime baseDate) {
    final slots = <AvailableSlot>[];
    
    // Générer des créneaux pour les 14 prochains jours
    for (int day = 0; day < 14; day++) {
      final date = baseDate.add(Duration(days: day));
      // Pas de créneaux le dimanche
      if (date.weekday == 7) continue;
      
      // Créneaux de 8h à 18h, par tranches d'1h
      for (int hour = 8; hour < 18; hour++) {
        slots.add(AvailableSlot(
          start: DateTime(date.year, date.month, date.day, hour, 0),
          end: DateTime(date.year, date.month, date.day, hour + 1, 0),
        ));
      }
    }
    
    return slots;
  }

  List<DayAvailability> _defaultWeekly() => [
    DayAvailability('Lundi', [TimeRange(9, 0, 12, 0), TimeRange(14, 0, 17, 0)]),
    DayAvailability('Mardi', [TimeRange(9, 0, 17, 0)]),
    DayAvailability('Mercredi', [TimeRange(9, 0, 17, 0)]),
    DayAvailability('Jeudi', [TimeRange(10, 0, 18, 0)]),
    DayAvailability('Vendredi', [TimeRange(9, 0, 12, 0), TimeRange(14, 0, 17, 0)]),
    DayAvailability('Samedi', [TimeRange(9, 0, 13, 0)]),
    DayAvailability('Dimanche', const [], enabled: false),
  ];

  /// Génère les créneaux d'un jour à partir du planning hebdo + exceptions.
  List<AvailableSlot> _generateSlotsForDate(String coachId, DateTime day) {
    final week = _weeklyByCoach[coachId];
    if (week == null) return [];
    final exceptions = _availabilityExceptions[coachId] ?? const [];
    final ranges = availabilityRangesForDate(day, week, exceptions);
    const slotMinutes = 60;
    final slots = <AvailableSlot>[];
    for (final r in ranges) {
      var start = r.begin;
      while (start + slotMinutes <= r.finish) {
        final s = DateTime(day.year, day.month, day.day, start ~/ 60, start % 60);
        final e = DateTime(day.year, day.month, day.day,
            (start + slotMinutes) ~/ 60, (start + slotMinutes) % 60);
        slots.add(AvailableSlot(start: s, end: e));
        start += slotMinutes;
      }
    }
    return slots;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  String get currentUserId => _currentUserId;
  bool get isCurrentUserCoach => _isCurrentUserCoach;

  List<Appointment> get allAppointments => List.unmodifiable(_appointments);

  /// Obtenir les RDV d'un coach
  List<Appointment> getAppointmentsForCoach(String coachId) {
    return _appointments
        .where((a) => a.coachId == coachId && a.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Obtenir les RDV d'un client
  List<Appointment> getAppointmentsForClient(String clientId) {
    return _appointments
        .where((a) => a.clientId == clientId)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Obtenir les RDV de l'utilisateur actuel
  List<Appointment> getMyAppointments() {
    if (_isCurrentUserCoach) {
      return getAppointmentsForCoach(_currentUserId);
    } else {
      return getAppointmentsForClient(_currentUserId);
    }
  }

  /// Obtenir les RDV pour un jour donné
  List<Appointment> getAppointmentsForDay(DateTime day, {String? coachId, String? clientId}) {
    return _appointments.where((a) {
      final sameDay = a.start.year == day.year &&
                      a.start.month == day.month &&
                      a.start.day == day.day;
      if (!sameDay) return false;
      if (coachId != null && a.coachId != coachId) return false;
      if (clientId != null && a.clientId != clientId) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Obtenir les RDV à venir
  List<Appointment> getUpcomingAppointments({String? userId}) {
    final now = DateTime.now();
    return _appointments
        .where((a) => 
            a.start.isAfter(now) && 
            a.status != AppointmentStatus.cancelled &&
            (userId == null || a.coachId == userId || a.clientId == userId))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Obtenir les RDV passés
  List<Appointment> getPastAppointments({String? userId}) {
    final now = DateTime.now();
    return _appointments
        .where((a) => 
            a.end.isBefore(now) &&
            (userId == null || a.coachId == userId || a.clientId == userId))
        .toList()
      ..sort((a, b) => b.start.compareTo(a.start)); // Plus récents d'abord
  }

  /// Obtenir les disponibilités d'un coach
  CoachAvailability? getCoachAvailability(String coachId) {
    return _coachAvailabilities[coachId];
  }

  /// Obtenir les créneaux disponibles pour un coach à une date donnée
  List<AvailableSlot> getAvailableSlotsForDay(String coachId, DateTime day) {
    // Priorité au planning hebdo + exceptions (édité dans CoachAvailabilityPage).
    // Repli sur les créneaux démo statiques pour les coachs sans planning hebdo.
    final List<AvailableSlot> daySlots;
    if (_weeklyByCoach.containsKey(coachId)) {
      daySlots = _generateSlotsForDate(coachId, day);
    } else {
      final availability = _coachAvailabilities[coachId];
      if (availability == null) return [];
      daySlots = availability.slots.where((slot) {
        return slot.start.year == day.year &&
               slot.start.month == day.month &&
               slot.start.day == day.day;
      }).toList();
    }

    // Exclure les créneaux déjà réservés
    final bookedAppointments = getAppointmentsForDay(day, coachId: coachId)
        .where((a) => a.status != AppointmentStatus.cancelled);

    return daySlots.where((slot) {
      // Vérifier si le créneau n'est pas déjà pris
      for (final appt in bookedAppointments) {
        if (slot.overlaps(appt.start, appt.end)) {
          return false;
        }
      }
      // Vérifier que le créneau n'est pas dans le passé
      return slot.start.isAfter(DateTime.now());
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Vérifier si un créneau est libre
  bool isSlotFree(String coachId, DateTime start, DateTime end) {
    final appointments = getAppointmentsForCoach(coachId);
    for (final appt in appointments) {
      if (appt.status == AppointmentStatus.cancelled) continue;
      // Vérifier le chevauchement
      if (start.isBefore(appt.end) && end.isAfter(appt.start)) {
        return false;
      }
    }
    return true;
  }

  /// Obtenir les jours avec des RDV pour un mois
  Map<DateTime, List<Appointment>> getAppointmentsForMonth(int year, int month, {String? userId}) {
    final result = <DateTime, List<Appointment>>{};
    
    for (final appt in _appointments) {
      if (appt.start.year == year && appt.start.month == month) {
        if (userId != null && appt.coachId != userId && appt.clientId != userId) {
          continue;
        }
        final dayKey = DateTime(appt.start.year, appt.start.month, appt.start.day);
        result[dayKey] ??= [];
        result[dayKey]!.add(appt);
      }
    }
    
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MUTATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Changer l'utilisateur actuel (DEMO)
  void setCurrentUser(String userId, {bool isCoach = false}) {
    _currentUserId = userId;
    _isCurrentUserCoach = isCoach;
    notifyListeners();
  }

  /// Ajouter un rendez-vous
  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
    
    // DEMO: Afficher un rappel
    _checkUpcomingReminder(appointment);
  }

  /// Mettre à jour un rendez-vous
  void updateAppointment(Appointment appointment) {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      _appointments[index] = appointment;
      notifyListeners();
    }
  }

  /// Confirmer un rendez-vous
  void confirmAppointment(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.confirmed,
      );
      notifyListeners();
    }
  }

  /// Annuler un rendez-vous
  void cancelAppointment(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      notifyListeners();
    }
  }

  /// Marquer un rendez-vous comme terminé
  void completeAppointment(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.completed,
      );
      notifyListeners();
    }
  }

  /// Modifier la note d'un rendez-vous
  void updateAppointmentNote(String appointmentId, String note) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(note: note);
      notifyListeners();
    }
  }

  /// Reprogrammer un rendez-vous
  void rescheduleAppointment(String appointmentId, DateTime newStart, DateTime newEnd) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        start: newStart,
        end: newEnd,
        status: AppointmentStatus.pending, // Remet en attente de confirmation
      );
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GESTION DES DISPONIBILITÉS COACH
  // ═══════════════════════════════════════════════════════════════════════════

  /// Définir les disponibilités d'un coach
  void setCoachAvailability(CoachAvailability availability) {
    _coachAvailabilities[availability.coachId] = availability;
    notifyListeners();
  }

  /// Ajouter un créneau de disponibilité
  void addAvailabilitySlot(String coachId, AvailableSlot slot) {
    final availability = _coachAvailabilities[coachId];
    if (availability != null) {
      final updatedSlots = List<AvailableSlot>.from(availability.slots)..add(slot);
      _coachAvailabilities[coachId] = availability.copyWith(slots: updatedSlots);
      notifyListeners();
    }
  }

  /// Supprimer un créneau de disponibilité
  void removeAvailabilitySlot(String coachId, String slotId) {
    final availability = _coachAvailabilities[coachId];
    if (availability != null) {
      final updatedSlots = availability.slots.where((s) => s.id != slotId).toList();
      _coachAvailabilities[coachId] = availability.copyWith(slots: updatedSlots);
      notifyListeners();
    }
  }

  /// Mettre à jour les jours travaillés
  void updateWorkingDays(String coachId, List<int> days) {
    final availability = _coachAvailabilities[coachId];
    if (availability != null) {
      _coachAvailabilities[coachId] = availability.copyWith(workingDays: days);
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PLANNING HEBDOMADAIRE + EXCEPTIONS (CoachAvailabilityPage)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Planning hebdomadaire d'un coach (crée un planning par défaut si absent).
  List<DayAvailability> getOrCreateWeekly(String coachId) {
    return _weeklyByCoach.putIfAbsent(coachId, () => _defaultWeekly());
  }

  /// Exceptions de disponibilité d'un coach (lecture seule).
  List<AvailabilityException> getAvailabilityExceptions(String coachId) {
    return List.unmodifiable(_availabilityExceptions[coachId] ?? const []);
  }

  /// Enregistre le planning hebdomadaire (mémoire de session, non persistant sur disque).
  void setWeeklyAvailability(String coachId, List<DayAvailability> week) {
    _weeklyByCoach[coachId] = week.map((d) => d.copy()).toList();
    notifyListeners();
  }

  /// Enregistre les exceptions de disponibilité (mémoire de session).
  void setAvailabilityExceptions(String coachId, List<AvailabilityException> exceptions) {
    _availabilityExceptions[coachId] = exceptions.map((e) => e.copy()).toList();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RAPPELS (DEMO)
  // ═══════════════════════════════════════════════════════════════════════════

  void _checkUpcomingReminder(Appointment appointment) {
    final now = DateTime.now();
    final diff = appointment.start.difference(now);
    
    if (diff.inHours <= 1 && diff.inMinutes > 0) {
      debugPrint('🔔 RAPPEL: RDV dans ${diff.inMinutes} minutes avec ${appointment.coachName}');
    } else if (diff.inHours <= 24 && diff.inHours > 1) {
      debugPrint('🔔 RAPPEL: RDV demain avec ${appointment.coachName}');
    }
  }

  /// Obtenir les prochains rappels
  List<String> getUpcomingReminders() {
    final now = DateTime.now();
    final reminders = <String>[];
    
    for (final appt in getUpcomingAppointments(userId: _currentUserId)) {
      final diff = appt.start.difference(now);
      
      if (diff.inMinutes > 0 && diff.inMinutes <= 60) {
        reminders.add('RDV dans ${diff.inMinutes} min avec ${_isCurrentUserCoach ? appt.clientName : appt.coachName}');
      } else if (diff.inHours > 0 && diff.inHours <= 24) {
        final timeStr = '${appt.start.hour.toString().padLeft(2, '0')}:${appt.start.minute.toString().padLeft(2, '0')}';
        reminders.add('RDV aujourd\'hui à $timeStr avec ${_isCurrentUserCoach ? appt.clientName : appt.coachName}');
      }
    }
    
    return reminders;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITAIRES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Générer un ID unique
  String generateId() {
    return 'appt_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Réinitialiser les données (pour tests)
  void reset() {
    _appointments.clear();
    _coachAvailabilities.clear();
    _weeklyByCoach.clear();
    _availabilityExceptions.clear();
    _initDemoData();
    notifyListeners();
  }
}

