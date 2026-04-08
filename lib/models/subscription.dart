import 'package:flutter/foundation.dart';

enum SubscriptionPlan {
  free,
  premium,
}

enum SubscriptionPack {
  start,
  basic,
  premium,
  duo,
  famille,
}

extension SubscriptionPackX on SubscriptionPack {
  String get displayName {
    switch (this) {
      case SubscriptionPack.start:
        return 'Pack Start';
      case SubscriptionPack.basic:
        return 'Pack Basic';
      case SubscriptionPack.premium:
        return 'Pack Premium';
      case SubscriptionPack.duo:
        return 'Pack Duo';
      case SubscriptionPack.famille:
        return 'Pack Famille';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionPack.start:
        return 'Parfait pour débuter avec les fonctionnalités essentielles';
      case SubscriptionPack.basic:
        return 'Accès aux fonctionnalités de base et suivi de progression';
      case SubscriptionPack.premium:
        return 'Accès complet à toutes les fonctionnalités Ukan';
      case SubscriptionPack.duo:
        return 'Pour 2 personnes - Idéal pour les couples';
      case SubscriptionPack.famille:
        return 'Pour toute la famille - Jusqu\'à 5 personnes';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionPack.start:
        return 4.99;
      case SubscriptionPack.basic:
        return 7.99;
      case SubscriptionPack.premium:
        return 12.99;
      case SubscriptionPack.duo:
        return 19.99;
      case SubscriptionPack.famille:
        return 29.99;
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionPack.start:
        return [
          'Séances d\'entraînement illimitées',
          'Suivi nutrition de base',
          'Statistiques hebdomadaires',
          'Accès à la bibliothèque d\'exercices',
        ];
      case SubscriptionPack.basic:
        return [
          'Tout du Pack Start',
          'Statistiques détaillées',
          'Historique complet',
          'Objectifs personnalisés',
          'Chat avec les coachs',
        ];
      case SubscriptionPack.premium:
        return [
          'Tout du Pack Basic',
          'Rooms (entraînement à plusieurs)',
          'Vidéos d\'exercices',
          'Suivi avancé silhouette',
          'Chat prioritaire',
          'Modules exclusifs',
        ];
      case SubscriptionPack.duo:
        return [
          '2 comptes Premium',
          'Séances partagées',
          'Défis entre partenaires',
          'Statistiques comparatives',
          'Toutes les fonctionnalités Premium',
        ];
      case SubscriptionPack.famille:
        return [
          'Jusqu\'à 5 comptes Premium',
          'Tableau de bord familial',
          'Défis familiaux',
          'Suivi de toute la famille',
          'Toutes les fonctionnalités Premium',
        ];
    }
  }

  String get category {
    switch (this) {
      case SubscriptionPack.start:
      case SubscriptionPack.basic:
      case SubscriptionPack.premium:
        return 'Individuel';
      case SubscriptionPack.duo:
      case SubscriptionPack.famille:
        return 'Groupe';
    }
  }
}

extension SubscriptionPlanX on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Gratuit';
      case SubscriptionPlan.premium:
        return 'Premium';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Accès de base aux séances, nutrition et profil.';
      case SubscriptionPlan.premium:
        return 'Accès complet : multiscreen, suivi avancé, vidéos, etc.';
    }
  }
}

class SubscriptionNotifier extends ChangeNotifier {
  static final SubscriptionNotifier _instance = SubscriptionNotifier._internal();
  factory SubscriptionNotifier() => _instance;
  SubscriptionNotifier._internal();

  SubscriptionPlan _plan = SubscriptionPlan.free;

  SubscriptionPlan get plan => _plan;
  bool get isPremium => _plan == SubscriptionPlan.premium;

  void setPlan(SubscriptionPlan plan) {
    if (_plan == plan) return;
    _plan = plan;
    notifyListeners();
  }

  void activatePremiumDemo() {
    setPlan(SubscriptionPlan.premium);
    // Synchroniser avec DemoPurchaseNotifier si Premium activé manuellement
    // (pour cohérence avec le système de paiement simulé)
    // Note: On évite la dépendance circulaire en gérant la sync dans les pages
  }

  void resetToFree() {
    setPlan(SubscriptionPlan.free);
  }
}


