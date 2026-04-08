import '../data/default_workout_programs.dart';
import '../models/workout_session_storage.dart';

/// Service pour initialiser les programmes prédéfinis
/// Vérifie s'il y a 0 programme et enregistre les 5 programmes par défaut
class DefaultProgramSeeder {
  /// Initialise les programmes prédéfinis si aucun programme n'existe
  /// Retourne true si des programmes ont été ajoutés, false sinon
  static Future<bool> seedIfNeeded() async {
    final existingPrograms = await WorkoutSessionStorage.getAllPrograms();
    
    // Si des programmes existent déjà, ne rien faire
    if (existingPrograms.isNotEmpty) {
      return false;
    }
    
    // Sinon, créer et enregistrer les 5 programmes prédéfinis
    final defaultPrograms = DefaultWorkoutPrograms.buildAll();
    
    for (final program in defaultPrograms) {
      await WorkoutSessionStorage.saveProgram(program);
    }
    
    return true;
  }
}

