import 'package:flutter/foundation.dart';

/// Modèle pour une phase d'évolution
class EvolutionPhase {
  final int months; // 0 = actuel, 3 = 3 mois, 6 = 6 mois, 9 = 9 mois, 12 = 12 mois
  final String imagePath; // Chemin vers l'image de démo
  final bool isUnlocked; // Si la projection est débloquée
  final DateTime? unlockedDate; // Date de déblocage (en démo)

  const EvolutionPhase({
    required this.months,
    required this.imagePath,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  EvolutionPhase copyWith({
    int? months,
    String? imagePath,
    bool? isUnlocked,
    DateTime? unlockedDate,
  }) {
    return EvolutionPhase(
      months: months ?? this.months,
      imagePath: imagePath ?? this.imagePath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }

  String get label {
    if (months == 0) return 'Actuel';
    return '$months mois';
  }
}

/// Notifier pour gérer les projections de transformation
class TransformationProjectionNotifier extends ChangeNotifier {
  static final TransformationProjectionNotifier _instance =
      TransformationProjectionNotifier._internal();
  factory TransformationProjectionNotifier() {
    _instance._initializeDemoData();
    return _instance;
  }
  TransformationProjectionNotifier._internal();

  // Photo actuelle (chemin vers l'image)
  String? _currentPhotoPath;

  // Phases d'évolution débloquées (0 = actuel, 3, 6, 9, 12 mois)
  final List<EvolutionPhase> _unlockedPhases = [];

  // Phases pré-débloquées pour la démo (Actuel et 3 mois déjà actifs)
  void _initializeDemoData() {
    // Ne réinitialiser que si la liste est vide
    if (_unlockedPhases.isEmpty) {
      // Initialiser la photo actuelle avec phase_0mois.png par défaut
      if (_currentPhotoPath == null) {
        _currentPhotoPath = _getImagePath(0);
      }
      // Pré-débloquer Actuel (0 mois) et 3 mois en démo
      _unlockedPhases.addAll([
        EvolutionPhase(
          months: 0,
          imagePath: _getImagePath(0),
          isUnlocked: true,
        ),
        EvolutionPhase(
          months: 3,
          imagePath: _getImagePath(3),
          isUnlocked: true,
          unlockedDate: DateTime.now(),
        ),
      ]);
    }
  }

  String? get currentPhotoPath => _currentPhotoPath;

  // Obtenir toutes les phases disponibles (actuel, 3, 6, 9, 12 mois)
  List<EvolutionPhase> getAllPhases() {
    final List<int> phaseMonths = [0, 3, 6, 9, 12];
    return phaseMonths.map((months) {
      final unlocked = _unlockedPhases.firstWhere(
        (p) => p.months == months,
        orElse: () => EvolutionPhase(
          months: months,
          imagePath: _getImagePath(months),
          isUnlocked: false,
        ),
      );
      return unlocked;
    }).toList();
  }

  // Obtenir les phases débloquées uniquement
  List<EvolutionPhase> getUnlockedPhases() {
    return _unlockedPhases.where((p) => p.isUnlocked).toList()
      ..sort((a, b) => a.months.compareTo(b.months));
  }

  void setCurrentPhoto(String? photoPath) {
    _currentPhotoPath = photoPath;
    notifyListeners();
  }

  void unlockPhase(int months) {
    final existingIndex = _unlockedPhases.indexWhere((p) => p.months == months);

    if (existingIndex == -1) {
      _unlockedPhases.add(
        EvolutionPhase(
          months: months,
          imagePath: _getImagePath(months),
          isUnlocked: true,
          unlockedDate: DateTime.now(),
        ),
      );
    } else {
      _unlockedPhases[existingIndex] = _unlockedPhases[existingIndex].copyWith(
        isUnlocked: true,
        unlockedDate: DateTime.now(),
      );
    }

    notifyListeners();
  }

  bool isPhaseUnlocked(int months) {
    return _unlockedPhases.any((p) => p.months == months && p.isUnlocked);
  }

  // Chemin vers l'image de démo selon la phase (0, 3, 6, 9, 12 mois)
  String _getImagePath(int months) {
    // Structure simple : une image par phase
    return 'assets/images/phase_${months}mois.png';
  }
}
