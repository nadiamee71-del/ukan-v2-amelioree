import 'package:flutter/foundation.dart';

/// Type d'achat disponible en démo
enum PurchaseType {
  premium, // Abonnement Premium
  businessPack, // Coach Business Pack™
  videoPack, // Pack de vidéos
  coachProgram, // Programme de coach
  coachVocalIA, // Coach Vocal IA
}

/// Extension pour obtenir le nom affiché
extension PurchaseTypeX on PurchaseType {
  String get displayName {
    switch (this) {
      case PurchaseType.premium:
        return 'Ukan Premium';
      case PurchaseType.businessPack:
        return 'Coach Business Pack™';
      case PurchaseType.videoPack:
        return 'Pack Vidéos';
      case PurchaseType.coachProgram:
        return 'Programme de Coach';
      case PurchaseType.coachVocalIA:
        return 'Coach Vocal IA';
    }
  }
}

/// Modèle d'un achat simulé
class Purchase {
  final String id;
  final PurchaseType type;
  final String title;
  final double price; // Prix en euros
  final DateTime purchaseDate;
  final bool isActive; // Pour les abonnements récurrents
  final String? programId; // ID du programme si type = coachProgram
  final String? coachId; // ID du coach si type = coachProgram

  Purchase({
    required this.id,
    required this.type,
    required this.title,
    required this.price,
    required this.purchaseDate,
    this.isActive = true,
    this.programId,
    this.coachId,
  });
}

/// Notifier pour gérer les achats simulés (100% local, en mémoire)
class DemoPurchaseNotifier extends ChangeNotifier {
  static final DemoPurchaseNotifier _instance = DemoPurchaseNotifier._internal();
  factory DemoPurchaseNotifier() => _instance;
  DemoPurchaseNotifier._internal();

  final List<Purchase> _purchases = [];

  // Getters rapides
  bool get hasPremium => _purchases.any((p) => 
      p.type == PurchaseType.premium && p.isActive);
  
  bool get hasBusinessPack => _purchases.any((p) => 
      p.type == PurchaseType.businessPack);
  
  bool get hasCoachVocalIA => _purchases.any((p) => 
      p.type == PurchaseType.coachVocalIA && p.isActive);
  
  List<String> get ownedVideoPacks => _purchases
      .where((p) => p.type == PurchaseType.videoPack)
      .map((p) => p.title)
      .toList();
  
  List<Purchase> get purchaseHistory => List.unmodifiable(_purchases);

  /// Vérifie si un pack vidéo spécifique est possédé
  bool hasVideoPack(String packName) {
    return _purchases.any((p) => 
        p.type == PurchaseType.videoPack && 
        p.title == packName &&
        p.isActive);
  }

  /// Ajoute un achat (simulé)
  void addPurchase(Purchase purchase) {
    // Pour Premium, désactiver les anciens abonnements Premium
    if (purchase.type == PurchaseType.premium) {
      for (var i = 0; i < _purchases.length; i++) {
        if (_purchases[i].type == PurchaseType.premium) {
          _purchases[i] = Purchase(
            id: _purchases[i].id,
            type: _purchases[i].type,
            title: _purchases[i].title,
            price: _purchases[i].price,
            purchaseDate: _purchases[i].purchaseDate,
            isActive: false,
          );
        }
      }
    }

    _purchases.add(purchase);
    _purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate)); // Plus récent en premier
    notifyListeners();
  }

  /// Simule l'achat de Premium (abonnement mensuel)
  void purchasePremium() {
    final purchase = Purchase(
      id: 'premium_${DateTime.now().millisecondsSinceEpoch}',
      type: PurchaseType.premium,
      title: 'Ukan Premium - Abonnement mensuel',
      price: 9.99,
      purchaseDate: DateTime.now(),
      isActive: true,
    );
    addPurchase(purchase);
  }

  /// Simule l'achat du Coach Business Pack™
  void purchaseBusinessPack() {
    final purchase = Purchase(
      id: 'business_${DateTime.now().millisecondsSinceEpoch}',
      type: PurchaseType.businessPack,
      title: 'Coach Business Pack™',
      price: 29.99,
      purchaseDate: DateTime.now(),
      isActive: true,
    );
    addPurchase(purchase);
  }

  /// Simule l'achat d'un pack vidéos
  void purchaseVideoPack(String packName, double price) {
    final purchase = Purchase(
      id: 'video_${DateTime.now().millisecondsSinceEpoch}',
      type: PurchaseType.videoPack,
      title: packName,
      price: price,
      purchaseDate: DateTime.now(),
      isActive: true,
    );
    addPurchase(purchase);
  }

  /// Simule l'achat d'un programme de coach
  void purchaseCoachProgram(String programId, String programTitle, double price, String coachId) {
    final purchase = Purchase(
      id: 'program_${DateTime.now().millisecondsSinceEpoch}',
      type: PurchaseType.coachProgram,
      title: programTitle,
      price: price,
      purchaseDate: DateTime.now(),
      isActive: true,
      programId: programId,
      coachId: coachId,
    );
    addPurchase(purchase);
  }

  /// Vérifie si un programme de coach est possédé
  bool hasCoachProgram(String programId) {
    return _purchases.any((p) => 
        p.type == PurchaseType.coachProgram && 
        p.programId == programId &&
        p.isActive);
  }

  /// Récupère tous les programmes achetés
  List<Purchase> get purchasedPrograms {
    return _purchases.where((p) => 
        p.type == PurchaseType.coachProgram && 
        p.isActive).toList();
  }

  /// Simule l'achat du Coach Vocal IA
  void purchaseCoachVocalIA() {
    final purchase = Purchase(
      id: 'coach_vocal_ia_${DateTime.now().millisecondsSinceEpoch}',
      type: PurchaseType.coachVocalIA,
      title: 'Coach Vocal IA',
      price: 4.99,
      purchaseDate: DateTime.now(),
      isActive: true,
    );
    addPurchase(purchase);
  }
}




