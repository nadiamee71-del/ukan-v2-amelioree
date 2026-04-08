import 'dart:math';

/// Liste de toutes les images disponibles dans l'application
/// Inclut les images de assets/images/ et assets/images/foodscan/
const List<String> kAppImages = [
  // Images de assets/images/ (hors foodscan)
  'assets/images/alter_ego_alerte.png',
  'assets/images/alter_ego_applaudit.png',
  'assets/images/alter_ego_clindoeil.png',
  'assets/images/alter_ego_encourage.png',
  'assets/images/alter_ego_felicite.png',
  'assets/images/alter_ego_neutre.png',
  'assets/images/alter_ego_perd.png',
  'assets/images/alter_ego_reflechit.png',
  'assets/images/alter_ego_repose.png',
  'assets/images/alter_ego_salut.png',
  'assets/images/assiette_connectee_fitpro.png',
  'assets/images/badge_boss_slayer.png',
  'assets/images/badge_en_marche.png',
  'assets/images/badge_endurant.png',
  'assets/images/badge_hydro_boost.png',
  'assets/images/badge_legende.png',
  'assets/images/badge_repos_guerrier.png',
  'assets/images/badge_starter.png',
  'assets/images/before_after_1.png',
  'assets/images/before_after_2.png',
  'assets/images/before_after_3.png',
  'assets/images/boss_squat_0.png',
  'assets/images/ChatGPT Image 25 nov. 2025, 18_27_24.png',
  'assets/images/ChatGPT Image 25 nov. 2025, 18_32_27.png',
  'assets/images/ChatGPT Image 25 nov. 2025, 18_35_02.png',
  'assets/images/ChatGPT Image 25 nov. 2025, 18_45_34.png',
  'assets/images/ChatGPT Image 25 nov. 2025, 18_51_26.png',
  'assets/images/coach_1_header.png',
  'assets/images/fitpro_logo.png',
  'assets/images/fitpro_logo_boxeur_droit.png',
  'assets/images/fitpro_logo_boxeur_replie.png',
  'assets/images/Gemini_Generated_Image_fz3t1cfz3t1cfz3t.png',
  'assets/images/gourde_connectee_fitpro.png',
  'assets/images/mon_profil_gagnant.png',
  'assets/images/mon_profil_neutre.png',
  'assets/images/phase_0mois.png',
  'assets/images/phase_12mois.png',
  'assets/images/phase_3mois.png',
  'assets/images/phase_6mois.png',
  'assets/images/phase_9mois.png',
  'assets/images/program_1_image_1.png',
  'assets/images/program_1_image_2.png',
  'assets/images/boss_squat_0.png',
  'assets/images/mon_profil_gagnant.png',
  'assets/images/mon_profil_neutre.png',
  'assets/images/fitpro_logo.png',
  'assets/images/tapis_compteur_mouvements_fitpro_1.png',
  'assets/images/tapis_compteur_mouvements_fitpro_2.png',
  
  // Images de assets/images/foodscan/ (EN LECTURE SEULE - utilisées pour FoodScan mais aussi pour les feeds)
  'assets/images/foodscan/burger_scan.png',
  'assets/images/foodscan/pates_bolo_scan.png',
  'assets/images/foodscan/pizza_scan.png',
  'assets/images/foodscan/plat_maison_scan.png',
  'assets/images/foodscan/salade_poulet_scan.png',
];

/// Instance Random pour la sélection aléatoire
final Random _rnd = Random();

/// Retourne une image aléatoire depuis la liste des images disponibles
String getRandomImage() {
  if (kAppImages.isEmpty) {
    return 'assets/images/fitpro_logo.png'; // Fallback
  }
  return kAppImages[_rnd.nextInt(kAppImages.length)];
}

/// Retourne une image par index (pour un accès séquentiel)
String getImageByIndex(int index) {
  if (kAppImages.isEmpty) {
    return 'assets/images/fitpro_logo.png'; // Fallback
  }
  return kAppImages[index % kAppImages.length];
}

/// Retourne une image spécifique pour les recettes (filtre les images foodscan)
String getRandomRecipeImage() {
  final recipeImages = kAppImages.where((img) => 
    img.contains('foodscan') || 
    img.contains('ChatGPT') || 
    img.contains('Gemini') ||
    img.contains('before_after') ||
    img.contains('program_1')
  ).toList().cast<String>();
  
  if (recipeImages.isEmpty) {
    return getRandomImage();
  }
  return recipeImages[_rnd.nextInt(recipeImages.length)];
}

/// Retourne une image spécifique pour les posts sport/communauté
String getRandomSportImage() {
  final sportImages = kAppImages.where((img) => 
    !img.contains('foodscan') && 
    !img.contains('alter_ego') &&
    !img.contains('badge') &&
    !img.contains('logo')
  ).toList().cast<String>();
  
  if (sportImages.isEmpty) {
    return getRandomImage();
  }
  return sportImages[_rnd.nextInt(sportImages.length)];
}

