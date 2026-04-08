import 'package:flutter/material.dart';
import 'alter_ego_context_service.dart';
export 'alter_ego_context_service.dart'; // Exporter UkanPage pour faciliter l'utilisation
import 'alter_ego_service.dart';

/// Helper pour détecter automatiquement la page active et mettre à jour le contexte Alter Ego
class AlterEgoPageDetector {
  static final AlterEgoService _service = AlterEgoService();
  static final AlterEgoContextService _contextService = AlterEgoContextService();

  /// Détecte la page depuis le nom de la route ou le type de widget
  static void detectPageFromRoute(String? routeName) {
    if (routeName == null) {
      _contextService.setCurrentPage(UkanPage.accueil);
      _service.setCurrentPage(UkanPage.accueil);
      return;
    }

    final lowerRoute = routeName.toLowerCase();

    // Mapping des routes vers les pages
    UkanPage? page;

    if (lowerRoute.contains('dashboard') || lowerRoute.contains('accueil') || lowerRoute == '/') {
      page = UkanPage.accueil;
    } else if (lowerRoute.contains('calories') && lowerRoute.contains('goal')) {
      page = UkanPage.objectifCalories;
    } else if (lowerRoute.contains('steps') || lowerRoute.contains('pas')) {
      page = UkanPage.objectifPas;
    } else if (lowerRoute.contains('sleep') || lowerRoute.contains('sommeil')) {
      page = UkanPage.objectifSommeil;
    } else if (lowerRoute.contains('hydration') || lowerRoute.contains('hydratation')) {
      page = UkanPage.objectifHydratation;
    } else if (lowerRoute.contains('sessions') && lowerRoute.contains('goal')) {
      page = UkanPage.objectifSeances;
    } else if (lowerRoute.contains('nutrition') && (lowerRoute.contains('jour') || lowerRoute.contains('day'))) {
      page = UkanPage.nutritionDuJour;
    } else if (lowerRoute.contains('recettes') || lowerRoute.contains('recipes')) {
      page = UkanPage.recettesCommunaute;
    } else if (lowerRoute.contains('stats') || lowerRoute.contains('statistiques')) {
      page = UkanPage.statistiques;
    } else if (lowerRoute.contains('sessions') || lowerRoute.contains('workout')) {
      page = UkanPage.sessions;
    } else if (lowerRoute.contains('rooms') || lowerRoute.contains('room')) {
      page = UkanPage.rooms;
    } else if (lowerRoute.contains('sante') || lowerRoute.contains('blessure') || lowerRoute.contains('health')) {
      page = UkanPage.santeBlessures;
    } else if (lowerRoute.contains('alter') && lowerRoute.contains('ego')) {
      page = UkanPage.alterEgoPremium;
    } else if (lowerRoute.contains('chat') && lowerRoute.contains('match')) {
      page = UkanPage.chatMatch;
    } else if (lowerRoute.contains('game') || lowerRoute.contains('story')) {
      page = UkanPage.gameStory;
    } else if (lowerRoute.contains('espace') || lowerRoute.contains('pro') || lowerRoute.contains('advanced')) {
      page = UkanPage.espacePro;
    }

    // Mettre à jour le contexte
    _contextService.setCurrentPage(page ?? UkanPage.accueil);
    _service.setCurrentPage(page ?? UkanPage.accueil);
  }

  /// Détecte la page depuis le type de widget (pour les pages StatefulWidget)
  static void detectPageFromWidget(Widget widget) {
    final widgetType = widget.runtimeType.toString().toLowerCase();

    UkanPage? page;

    if (widgetType.contains('dashboard') || widgetType.contains('accueil')) {
      page = UkanPage.accueil;
    } else if (widgetType.contains('caloriesgoal')) {
      page = UkanPage.objectifCalories;
    } else if (widgetType.contains('stepsgoal') || widgetType.contains('pas')) {
      page = UkanPage.objectifPas;
    } else if (widgetType.contains('sleepgoal') || widgetType.contains('sommeil')) {
      page = UkanPage.objectifSommeil;
    } else if (widgetType.contains('hydrationgoal') || widgetType.contains('hydratation')) {
      page = UkanPage.objectifHydratation;
    } else if (widgetType.contains('sessionsgoal')) {
      page = UkanPage.objectifSeances;
    } else if (widgetType.contains('simplenutrition') || widgetType.contains('nutritionday')) {
      page = UkanPage.nutritionDuJour;
    } else if (widgetType.contains('recipescommunity') || widgetType.contains('recettes')) {
      page = UkanPage.recettesCommunaute;
    } else if (widgetType.contains('statspage') || widgetType.contains('statistiques')) {
      page = UkanPage.statistiques;
    } else if (widgetType.contains('sessions') || widgetType.contains('workout')) {
      page = UkanPage.sessions;
    } else if (widgetType.contains('rooms')) {
      page = UkanPage.rooms;
    } else if (widgetType.contains('healthinjuries') || widgetType.contains('sante')) {
      page = UkanPage.santeBlessures;
    } else if (widgetType.contains('alterego')) {
      page = UkanPage.alterEgoPremium;
    } else if (widgetType.contains('matchhome') || widgetType.contains('chatmatch')) {
      page = UkanPage.chatMatch;
    } else if (widgetType.contains('storyhome') || widgetType.contains('gamestory')) {
      page = UkanPage.gameStory;
    } else if (widgetType.contains('espacepro') || widgetType.contains('advanced')) {
      page = UkanPage.espacePro;
    }

    // Mettre à jour le contexte
    _contextService.setCurrentPage(page ?? UkanPage.accueil);
    _service.setCurrentPage(page ?? UkanPage.accueil);
  }

  /// Méthode helper pour être appelée dans initState de chaque page
  /// Configure le contexte de la page et prépare le message guide
  static void setupPageContext(UkanPage page) {
    _contextService.setCurrentPage(page);
    _service.setCurrentPage(page);
    // Ne pas démarrer automatiquement la conversation pour ne pas interrompre l'utilisateur
    // La conversation se lancera quand l'utilisateur cliquera sur le bouton Alter Ego
  }
}

