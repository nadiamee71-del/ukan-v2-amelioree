import 'package:flutter/foundation.dart';

/// Modèle pour une personnalité de coach
class CoachPersonality {
  final String id;
  final String name;
  final String description;
  final String tone; // 'gentil', 'dur', 'militaire', 'humour'
  final String emoji;

  const CoachPersonality({
    required this.id,
    required this.name,
    required this.description,
    required this.tone,
    required this.emoji,
  });

  static const List<CoachPersonality> personalities = [
    CoachPersonality(
      id: 'gentil',
      name: 'Coach gentil',
      description: 'Soutien et bienveillant, toujours là pour t\'encourager',
      tone: 'gentil',
      emoji: '🤝',
    ),
    CoachPersonality(
      id: 'dur',
      name: 'Coach dur',
      description: 'Exigeant et direct, te pousse au-delà de tes limites',
      tone: 'dur',
      emoji: '💀',
    ),
    CoachPersonality(
      id: 'militaire',
      name: 'Coach militaire',
      description: 'Strict et discipliné, comme un sergent instructeur',
      tone: 'militaire',
      emoji: '🪖',
    ),
    CoachPersonality(
      id: 'humour',
      name: 'Coach humour',
      description: 'Décontracté et drôle, rend l\'entraînement fun',
      tone: 'humour',
      emoji: '😂',
    ),
  ];
}

/// Notifier pour gérer la personnalité du coach choisie
class CoachPersonalityNotifier extends ChangeNotifier {
  static final CoachPersonalityNotifier _instance = CoachPersonalityNotifier._internal();
  factory CoachPersonalityNotifier() => _instance;
  CoachPersonalityNotifier._internal();

  String _selectedPersonalityId = 'gentil'; // Par défaut

  String get selectedPersonalityId => _selectedPersonalityId;

  CoachPersonality get selectedPersonality {
    return CoachPersonality.personalities.firstWhere(
      (p) => p.id == _selectedPersonalityId,
      orElse: () => CoachPersonality.personalities[0],
    );
  }

  void selectPersonality(String personalityId) {
    _selectedPersonalityId = personalityId;
    notifyListeners();
  }
}









