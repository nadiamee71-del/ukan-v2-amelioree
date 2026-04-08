import 'package:flutter/material.dart';
import 'simple_nutrition_page.dart';

/// Onglet Nutrition simplifié qui redirige vers SimpleNutritionPage
class SimpleNutritionTab extends StatelessWidget {
  const SimpleNutritionTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Rediriger directement vers la page simplifiée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SimpleNutritionPage(),
        ),
      );
    });
    
    // Page temporaire pendant la navigation
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}








