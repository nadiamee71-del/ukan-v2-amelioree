import 'package:flutter/foundation.dart';

/// Types d'unités de mesure disponibles
enum WeightUnit { kg, lbs }
enum HeightUnit { cm, ftIn }
enum DistanceUnit { km, miles }
enum LiquidUnit { ml, flOz }
enum FoodWeightUnit { g, oz }

/// Extensions pour afficher les noms des unités
extension WeightUnitExtension on WeightUnit {
  String get displayName {
    switch (this) {
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lbs:
        return 'lbs';
    }
  }

  String get fullName {
    switch (this) {
      case WeightUnit.kg:
        return 'Kilogrammes (kg)';
      case WeightUnit.lbs:
        return 'Livres (lbs)';
    }
  }
}

extension HeightUnitExtension on HeightUnit {
  String get displayName {
    switch (this) {
      case HeightUnit.cm:
        return 'cm';
      case HeightUnit.ftIn:
        return 'ft/in';
    }
  }

  String get fullName {
    switch (this) {
      case HeightUnit.cm:
        return 'Centimètres (cm)';
      case HeightUnit.ftIn:
        return 'Pieds & Pouces (ft/in)';
    }
  }
}

extension DistanceUnitExtension on DistanceUnit {
  String get displayName {
    switch (this) {
      case DistanceUnit.km:
        return 'km';
      case DistanceUnit.miles:
        return 'mi';
    }
  }

  String get fullName {
    switch (this) {
      case DistanceUnit.km:
        return 'Kilomètres (km)';
      case DistanceUnit.miles:
        return 'Miles (mi)';
    }
  }
}

extension LiquidUnitExtension on LiquidUnit {
  String get displayName {
    switch (this) {
      case LiquidUnit.ml:
        return 'ml';
      case LiquidUnit.flOz:
        return 'fl oz';
    }
  }

  String get fullName {
    switch (this) {
      case LiquidUnit.ml:
        return 'Millilitres (ml)';
      case LiquidUnit.flOz:
        return 'Onces liquides (fl oz)';
    }
  }
}

extension FoodWeightUnitExtension on FoodWeightUnit {
  String get displayName {
    switch (this) {
      case FoodWeightUnit.g:
        return 'g';
      case FoodWeightUnit.oz:
        return 'oz';
    }
  }

  String get fullName {
    switch (this) {
      case FoodWeightUnit.g:
        return 'Grammes (g)';
      case FoodWeightUnit.oz:
        return 'Onces (oz)';
    }
  }
}

/// Singleton Notifier pour gérer les unités de mesure globalement
class UnitsNotifier extends ChangeNotifier {
  // Singleton
  static final UnitsNotifier _instance = UnitsNotifier._internal();
  factory UnitsNotifier() => _instance;
  UnitsNotifier._internal();

  // Unités actuelles (par défaut : système métrique)
  WeightUnit _weightUnit = WeightUnit.kg;
  HeightUnit _heightUnit = HeightUnit.cm;
  DistanceUnit _distanceUnit = DistanceUnit.km;
  LiquidUnit _liquidUnit = LiquidUnit.ml;
  FoodWeightUnit _foodWeightUnit = FoodWeightUnit.g;

  // Getters
  WeightUnit get weightUnit => _weightUnit;
  HeightUnit get heightUnit => _heightUnit;
  DistanceUnit get distanceUnit => _distanceUnit;
  LiquidUnit get liquidUnit => _liquidUnit;
  FoodWeightUnit get foodWeightUnit => _foodWeightUnit;

  // Vérifier si on utilise le système métrique
  bool get isMetric => _weightUnit == WeightUnit.kg;

  // Setters avec notification
  void setWeightUnit(WeightUnit unit) {
    if (_weightUnit != unit) {
      _weightUnit = unit;
      notifyListeners();
    }
  }

  void setHeightUnit(HeightUnit unit) {
    if (_heightUnit != unit) {
      _heightUnit = unit;
      notifyListeners();
    }
  }

  void setDistanceUnit(DistanceUnit unit) {
    if (_distanceUnit != unit) {
      _distanceUnit = unit;
      notifyListeners();
    }
  }

  void setLiquidUnit(LiquidUnit unit) {
    if (_liquidUnit != unit) {
      _liquidUnit = unit;
      notifyListeners();
    }
  }

  void setFoodWeightUnit(FoodWeightUnit unit) {
    if (_foodWeightUnit != unit) {
      _foodWeightUnit = unit;
      notifyListeners();
    }
  }

  // Basculer vers le système métrique ou impérial
  void setMetricSystem() {
    _weightUnit = WeightUnit.kg;
    _heightUnit = HeightUnit.cm;
    _distanceUnit = DistanceUnit.km;
    _liquidUnit = LiquidUnit.ml;
    _foodWeightUnit = FoodWeightUnit.g;
    notifyListeners();
  }

  void setImperialSystem() {
    _weightUnit = WeightUnit.lbs;
    _heightUnit = HeightUnit.ftIn;
    _distanceUnit = DistanceUnit.miles;
    _liquidUnit = LiquidUnit.flOz;
    _foodWeightUnit = FoodWeightUnit.oz;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FONCTIONS DE CONVERSION
  // ═══════════════════════════════════════════════════════════════════════════

  // Poids : kg ↔ lbs
  double convertWeight(double value, {required bool toDisplay}) {
    if (_weightUnit == WeightUnit.kg) return value;
    // kg → lbs ou lbs → kg
    return toDisplay ? value * 2.20462 : value / 2.20462;
  }

  String formatWeight(double valueInKg) {
    if (_weightUnit == WeightUnit.kg) {
      return '${valueInKg.toStringAsFixed(1)} kg';
    } else {
      return '${(valueInKg * 2.20462).toStringAsFixed(1)} lbs';
    }
  }

  // Taille : cm ↔ ft/in
  String formatHeight(double valueInCm) {
    if (_heightUnit == HeightUnit.cm) {
      return '${valueInCm.toStringAsFixed(0)} cm';
    } else {
      final totalInches = valueInCm / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return '$feet\'$inches"';
    }
  }

  double convertHeightToCm(int feet, int inches) {
    return (feet * 12 + inches) * 2.54;
  }

  // Distance : km ↔ miles
  double convertDistance(double valueInKm, {required bool toDisplay}) {
    if (_distanceUnit == DistanceUnit.km) return valueInKm;
    return toDisplay ? valueInKm * 0.621371 : valueInKm / 0.621371;
  }

  String formatDistance(double valueInKm) {
    if (_distanceUnit == DistanceUnit.km) {
      return '${valueInKm.toStringAsFixed(2)} km';
    } else {
      return '${(valueInKm * 0.621371).toStringAsFixed(2)} mi';
    }
  }

  // Liquides : ml ↔ fl oz
  double convertLiquid(double valueInMl, {required bool toDisplay}) {
    if (_liquidUnit == LiquidUnit.ml) return valueInMl;
    return toDisplay ? valueInMl * 0.033814 : valueInMl / 0.033814;
  }

  String formatLiquid(double valueInMl) {
    if (_liquidUnit == LiquidUnit.ml) {
      return '${valueInMl.toStringAsFixed(0)} ml';
    } else {
      return '${(valueInMl * 0.033814).toStringAsFixed(1)} fl oz';
    }
  }

  // Nourriture (poids) : g ↔ oz
  double convertFoodWeight(double valueInG, {required bool toDisplay}) {
    if (_foodWeightUnit == FoodWeightUnit.g) return valueInG;
    return toDisplay ? valueInG * 0.035274 : valueInG / 0.035274;
  }

  String formatFoodWeight(double valueInG) {
    if (_foodWeightUnit == FoodWeightUnit.g) {
      return '${valueInG.toStringAsFixed(0)} g';
    } else {
      return '${(valueInG * 0.035274).toStringAsFixed(1)} oz';
    }
  }

  // Résumé des unités actuelles
  String get unitsSummary {
    return '${_weightUnit.displayName}, ${_heightUnit.displayName}, ${_distanceUnit.displayName}';
  }
}











