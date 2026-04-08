/// Planning Client - Ukan
/// Redirige vers le planning unifié
/// Maintenu pour compatibilité avec les navigations existantes

import 'package:flutter/material.dart';
import 'features/appointments/unified_planning_page.dart';

class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirige vers le nouveau planning unifié
    return const UnifiedPlanningPage(isCoachView: false);
  }
}
