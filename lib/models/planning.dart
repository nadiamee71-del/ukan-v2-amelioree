import 'package:flutter/foundation.dart';

enum PlannedSessionType {
  solo,
  coach,
  room,
}

enum PlannedSessionStatus {
  planned,
  done,
  cancelled,
}

/// Type de rendez-vous coach-client
enum AppointmentType {
  visio, // Distanciel
  presentiel, // En personne
}

class PlannedSession {
  final String id;
  final DateTime dateTime;
  final String title;
  final PlannedSessionType type;
  final PlannedSessionStatus status;
  
  // Nouvelles propriétés pour les rendez-vous coach-client
  final String? coachId; // ID du coach (null pour sessions solo)
  final String? clientId; // ID du client (null pour sessions solo)
  final AppointmentType? appointmentType; // Visio ou présentiel (null pour sessions solo)
  final String? address; // Adresse pour présentiel
  final String? videoLink; // Lien visio pour distanciel
  final String? notes; // Notes additionnelles

  PlannedSession({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.type,
    required this.status,
    this.coachId,
    this.clientId,
    this.appointmentType,
    this.address,
    this.videoLink,
    this.notes,
  });

  PlannedSession copyWith({
    DateTime? dateTime,
    String? title,
    PlannedSessionType? type,
    PlannedSessionStatus? status,
    String? coachId,
    String? clientId,
    AppointmentType? appointmentType,
    String? address,
    String? videoLink,
    String? notes,
  }) {
    return PlannedSession(
      id: id,
      dateTime: dateTime ?? this.dateTime,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      coachId: coachId ?? this.coachId,
      clientId: clientId ?? this.clientId,
      appointmentType: appointmentType ?? this.appointmentType,
      address: address ?? this.address,
      videoLink: videoLink ?? this.videoLink,
      notes: notes ?? this.notes,
    );
  }
  
  /// Vérifie si c'est un rendez-vous coach-client
  bool get isCoachClientAppointment => coachId != null && clientId != null;
}

class PlanningNotifier extends ChangeNotifier {
  static final PlanningNotifier _instance = PlanningNotifier._internal();
  factory PlanningNotifier() => _instance;
  PlanningNotifier._internal() {
    _initDemoData();
  }

  final List<PlannedSession> _sessions = [];

  List<PlannedSession> sessionsForDay(DateTime day) {
    return _sessions
        .where((s) =>
            s.dateTime.year == day.year &&
            s.dateTime.month == day.month &&
            s.dateTime.day == day.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Récupère les rendez-vous avec un coach spécifique
  List<PlannedSession> appointmentsWithCoach(String coachId) {
    return _sessions
        .where((s) => s.coachId == coachId && s.isCoachClientAppointment)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Récupère les rendez-vous d'un client
  List<PlannedSession> appointmentsForClient(String clientId) {
    return _sessions
        .where((s) => s.clientId == clientId && s.isCoachClientAppointment)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  void addSession(PlannedSession session) {
    _sessions.add(session);
    notifyListeners();
  }

  void updateStatus(String id, PlannedSessionStatus status) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _sessions[index] = _sessions[index].copyWith(status: status);
    notifyListeners();
  }

  void _initDemoData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _sessions.addAll([
      PlannedSession(
        id: 'ps1',
        dateTime: today.add(const Duration(hours: 18)),
        title: 'Full body avec coach',
        type: PlannedSessionType.coach,
        status: PlannedSessionStatus.planned,
      ),
      PlannedSession(
        id: 'ps2',
        dateTime: today.add(const Duration(days: 1, hours: 7)),
        title: 'Cardio 20 min',
        type: PlannedSessionType.solo,
        status: PlannedSessionStatus.planned,
      ),
      PlannedSession(
        id: 'ps3',
        dateTime: today.add(const Duration(days: 2, hours: 19)),
        title: 'Room avec les amis',
        type: PlannedSessionType.room,
        status: PlannedSessionStatus.planned,
      ),
    ]);
  }
}





