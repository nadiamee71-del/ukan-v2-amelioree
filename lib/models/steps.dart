import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// ─────────────────────────────────────────────
/// Modèle d'entrée de pas
/// ─────────────────────────────────────────────

class StepEntry {
  final String id;
  final DateTime date; // normalisée AAAA-MM-JJ
  final int steps;

  StepEntry({
    required this.id,
    required DateTime date,
    required this.steps,
  }) : date = DateTime(date.year, date.month, date.day);
}

/// Helper interne pour normaliser une date (AAAA-MM-JJ)
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// ─────────────────────────────────────────────
/// Notifier pour les pas
/// ─────────────────────────────────────────────

class StepsNotifier extends ChangeNotifier {
  static final StepsNotifier _instance = StepsNotifier._internal();
  factory StepsNotifier() => _instance;
  StepsNotifier._internal() {
    // Démarrer automatiquement le compteur si le mode auto est activé
    if (_autoModeEnabled) {
      _initializeStepCounter();
    }
  }

  bool get autoModeEnabled => _autoModeEnabled;
  
  bool get isCounting => _isCounting;

  final List<StepEntry> _entries = [];
  
  // Pour le compteur automatique
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  int _currentDaySteps = 0;
  DateTime? _lastStepUpdateDate;
  bool _isCounting = false;
  bool _autoModeEnabled = true; // Mode automatique activé par défaut
  
  // Pour le compteur web (accéléromètre)
  double _lastAcceleration = 0.0;
  int _webStepCount = 0;
  DateTime? _lastWebStepTime;

  void addSteps({required DateTime date, required int steps}) {
    if (steps <= 0) return;
    
    final d = _dateOnly(date);
    final existingIndex = _entries.indexWhere(
      (e) => _dateOnly(e.date) == d,
    );

    if (existingIndex >= 0) {
      // Additionner les pas si une entrée existe déjà
      final existing = _entries[existingIndex];
      _entries[existingIndex] = StepEntry(
        id: existing.id,
        date: existing.date,
        steps: existing.steps + steps,
      );
    } else {
      // Créer une nouvelle entrée
      final entry = StepEntry(
        id: 'steps_${DateTime.now().microsecondsSinceEpoch}',
        date: date,
        steps: steps,
      );
      _entries.add(entry);
    }
    
    notifyListeners();
  }

  int totalForDate(DateTime date) {
    final d = _dateOnly(date);
    return _entries
        .where((e) => _dateOnly(e.date) == d)
        .fold<int>(0, (sum, e) => sum + e.steps);
  }

  Map<DateTime, int> totalsForLast7Days() {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final Map<DateTime, int> result = {};
    for (int i = 6; i >= 0; i--) {
      final d = _dateOnly(today.subtract(Duration(days: i)));
      result[d] = totalForDate(d);
    }
    return result;
  }

  // ─ Compteur automatique ─

  Future<void> _initializeStepCounter() async {
    try {
      // Sur mobile (Android/iOS), utiliser Pedometer
      if (!kIsWeb) {
        await _startMobileStepCounter();
      } else {
        // Sur web, utiliser l'accéléromètre
        await _startWebStepCounter();
      }
    } catch (e) {
      debugPrint('Erreur initialisation compteur de pas: $e');
    }
  }

  Future<void> _startMobileStepCounter() async {
    try {
      // Démarrer l'écoute des pas
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (error) {
          debugPrint('Erreur compteur de pas: $error');
        },
      );

      // Écouter le statut (marchant/arrêté)
      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        (status) {
          // Le statut peut être 'walking' ou 'stopped' selon la version du package
          _isCounting = status.status.toString().contains('walking');
        },
        onError: (error) {
          debugPrint('Erreur statut piéton: $error');
        },
      );

      // Récupérer le nombre de pas actuel
      final initialStepCount = await Pedometer.stepCountStream.first;
      _onStepCount(initialStepCount);
    } catch (e) {
      debugPrint('Impossible de démarrer le compteur mobile: $e');
    }
  }

  Future<void> _startWebStepCounter() async {
    try {
      // Sur web, utiliser l'accéléromètre pour détecter les pas
      _lastAcceleration = 0.0;
      _webStepCount = 0;
      _lastWebStepTime = null;
      const double stepThreshold = 1.5; // Seuil pour détecter un pas
      const int minStepInterval = 300; // Minimum 300ms entre deux pas

      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          final acceleration = math.sqrt(event.x * event.x + 
                                         event.y * event.y + 
                                         event.z * event.z);
          
          final now = DateTime.now();
          
          // Détecter un pic d'accélération (marche)
          if ((acceleration - _lastAcceleration).abs() > stepThreshold) {
            if (_lastWebStepTime == null || 
                now.difference(_lastWebStepTime!).inMilliseconds > minStepInterval) {
              _webStepCount++;
              _lastWebStepTime = now;
              
              // Mettre à jour toutes les 10 pas pour économiser les ressources
              if (_webStepCount % 10 == 0) {
                final today = _dateOnly(DateTime.now());
                if (_lastStepUpdateDate == null || _dateOnly(_lastStepUpdateDate!) != today) {
                  _currentDaySteps = 0;
                  _lastStepUpdateDate = today;
                }
                _currentDaySteps += 10;
                _saveCurrentDaySteps();
              }
            }
          }
          
          _lastAcceleration = acceleration;
        },
        onError: (error) {
          debugPrint('Erreur accéléromètre web: $error');
        },
      );
    } catch (e) {
      debugPrint('Impossible de démarrer le compteur web: $e');
    }
  }

  void _onStepCount(StepCount stepCount) {
    final today = _dateOnly(DateTime.now());
    
    // Si on change de jour, réinitialiser
    if (_lastStepUpdateDate == null || _dateOnly(_lastStepUpdateDate!) != today) {
      _currentDaySteps = 0;
      _lastStepUpdateDate = today;
    }
    
    // Calculer les nouveaux pas depuis la dernière mise à jour
    final newSteps = stepCount.steps - _currentDaySteps;
    if (newSteps > 0) {
      _currentDaySteps = stepCount.steps;
      _saveCurrentDaySteps();
    }
  }

  void _saveCurrentDaySteps() {
    final today = DateTime.now();
    final d = _dateOnly(today);
    
    // Trouver ou créer l'entrée du jour
    final existingIndex = _entries.indexWhere(
      (e) => _dateOnly(e.date) == d,
    );

    if (existingIndex >= 0) {
      // Mettre à jour l'entrée existante
      final existing = _entries[existingIndex];
      _entries[existingIndex] = StepEntry(
        id: existing.id,
        date: existing.date,
        steps: _currentDaySteps,
      );
    } else {
      // Créer une nouvelle entrée
      final entry = StepEntry(
        id: 'steps_auto_${DateTime.now().microsecondsSinceEpoch}',
        date: today,
        steps: _currentDaySteps,
      );
      _entries.add(entry);
    }
    
    notifyListeners();
  }

  void setAutoMode(bool enabled) {
    _autoModeEnabled = enabled;
    if (enabled && !_isCounting) {
      // Si on active le mode auto et que le compteur n'est pas actif, le démarrer
      _initializeStepCounter();
    } else if (!enabled) {
      // Si on désactive le mode auto, arrêter le compteur
      stopCounting();
    }
    notifyListeners();
  }

  void startCounting() {
    if (!_isCounting) {
      _initializeStepCounter();
      notifyListeners();
    }
  }

  void stopCounting() {
    // Ne pas arrêter si le mode auto est activé
    if (_autoModeEnabled) {
      return;
    }
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _isCounting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopCounting();
    super.dispose();
  }
}

