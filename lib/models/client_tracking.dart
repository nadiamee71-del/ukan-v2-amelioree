import 'package:flutter/foundation.dart';

/// Point de suivi pour un client
class ClientProgressEntry {
  final String id;
  final String clientId;
  final DateTime date;
  final double? weightKg;
  final double? waistCm; // tour de taille
  final double? hipsCm; // hanches
  final double? chestCm; // poitrine / buste
  final int? workoutsDone; // séances faites cette semaine
  final int? workoutsPlanned; // séances prévues cette semaine
  final String? notes;

  const ClientProgressEntry({
    required this.id,
    required this.clientId,
    required this.date,
    this.weightKg,
    this.waistCm,
    this.hipsCm,
    this.chestCm,
    this.workoutsDone,
    this.workoutsPlanned,
    this.notes,
  });
}

/// Notifier pour gérer les points de suivi (en mémoire)
class ClientProgressNotifier extends ChangeNotifier {
  static final ClientProgressNotifier _instance =
      ClientProgressNotifier._internal();
  factory ClientProgressNotifier() => _instance;
  ClientProgressNotifier._internal() {
    // Entrées de démo pour le client "sarah"
    _entries.addAll([
      ClientProgressEntry(
        id: 'demo_1',
        clientId: 'sarah',
        date: DateTime(2024, 1, 10),
        weightKg: 72.5,
        waistCm: 78.0,
        hipsCm: 96.0,
        chestCm: 90.0,
        workoutsDone: 3,
        workoutsPlanned: 3,
        notes: 'Bon début, motivation au rendez-vous.',
      ),
      ClientProgressEntry(
        id: 'demo_2',
        clientId: 'sarah',
        date: DateTime(2024, 1, 17),
        weightKg: 71.8,
        waistCm: 76.5,
        hipsCm: 95.0,
        workoutsDone: 3,
        workoutsPlanned: 3,
        notes: 'Progression visible, continue !',
      ),
    ]);
  }

  final List<ClientProgressEntry> _entries = [];

  /// Récupère les entrées pour un client donné (triées par date)
  List<ClientProgressEntry> entriesForClient(String clientId) {
    final list = _entries
        .where((e) => e.clientId == clientId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Récupère la dernière entrée pour un client
  ClientProgressEntry? latestForClient(String clientId) {
    final list = entriesForClient(clientId);
    if (list.isEmpty) return null;
    return list.last;
  }

  /// Ajoute une nouvelle entrée
  void addEntry(ClientProgressEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }
}

/// Notifier pour gérer les notes privées du coach (en mémoire)
class ClientNotesNotifier extends ChangeNotifier {
  static final ClientNotesNotifier _instance = ClientNotesNotifier._internal();
  factory ClientNotesNotifier() => _instance;
  ClientNotesNotifier._internal();

  final Map<String, String> _notesByClient = {};

  /// Récupère la note pour un client
  String? noteForClient(String clientId) => _notesByClient[clientId];

  /// Définit ou met à jour la note pour un client
  void setNote(String clientId, String note) {
    _notesByClient[clientId] = note;
    notifyListeners();
  }
}









