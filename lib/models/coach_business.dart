import 'package:flutter/foundation.dart';

/// Modèle pour le branding d'un coach
class CoachBranding {
  final String brandName;
  final String tagline;
  final String primaryColor; // 'jaune', 'noir', 'bleu', 'rouge'

  const CoachBranding({
    this.brandName = '',
    this.tagline = '',
    this.primaryColor = 'jaune',
  });

  CoachBranding copyWith({
    String? brandName,
    String? tagline,
    String? primaryColor,
  }) {
    return CoachBranding(
      brandName: brandName ?? this.brandName,
      tagline: tagline ?? this.tagline,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}

/// Modèle pour un programme vendable
class CoachProduct {
  final String id;
  final String title;
  final String description;
  final String level; // Débutant, Intermédiaire, Avancé
  final int durationWeeks;
  final double price; // en €

  const CoachProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.durationWeeks,
    required this.price,
  });
}

/// Notifier pour gérer le branding coach en mémoire
class CoachBrandingNotifier extends ChangeNotifier {
  static final CoachBrandingNotifier _instance = CoachBrandingNotifier._internal();
  factory CoachBrandingNotifier() => _instance;
  CoachBrandingNotifier._internal();

  CoachBranding _branding = const CoachBranding();

  CoachBranding get branding => _branding;

  void updateBranding(CoachBranding newBranding) {
    _branding = newBranding;
    notifyListeners();
  }
}

/// Notifier pour gérer les produits coach en mémoire
class CoachProductsNotifier extends ChangeNotifier {
  static final CoachProductsNotifier _instance = CoachProductsNotifier._internal();
  factory CoachProductsNotifier() => _instance;
  CoachProductsNotifier._internal();

  final List<CoachProduct> _products = [];

  List<CoachProduct> get products => List.unmodifiable(_products);

  void addProduct(CoachProduct product) {
    _products.add(product);
    notifyListeners();
  }

  void removeProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  int get totalProducts => _products.length;

  double get averagePrice {
    if (_products.isEmpty) return 0.0;
    final total = _products.fold<double>(0.0, (sum, p) => sum + p.price);
    return total / _products.length;
  }

  double get estimatedRevenue {
    // Estimation fictive : nombre de programmes × 49€
    return _products.length * 49.0;
  }
}









