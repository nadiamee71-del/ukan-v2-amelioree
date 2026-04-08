import 'package:flutter/material.dart';
import '../models/exercise_library_item.dart';
import '../models/demo_purchase.dart';
import '../models/user_exercises_notifier.dart';
import '../data/demo_exercises.dart';
import 'exercise_detail_page.dart';
import 'exercise_detail_pro_page.dart';
import '../components/exercise_icon_helper.dart';
import '../components/difficulty_form.dart';
import '../services/difficulty_service.dart';
import '../models/difficulty_entry.dart';
import '../models/workout_session_storage.dart';
import '../models/workout_session.dart';
import 'package:intl/intl.dart';

/// Onglet Exercices avec liste groupée par catégorie musculaire
/// Design sombre style iOS/Apple Fitness
class ExercisesTabWidget extends StatefulWidget {
  final Function(ExerciseLibraryItem)? onExerciseSelected;
  final bool selectionMode;

  const ExercisesTabWidget({
    super.key,
    this.onExerciseSelected,
    this.selectionMode = false,
  });

  @override
  State<ExercisesTabWidget> createState() => _ExercisesTabWidgetState();
}

class _ExercisesTabWidgetState extends State<ExercisesTabWidget> {
  final _purchaseNotifier = DemoPurchaseNotifier();
  final _userExercisesNotifier = UserExercisesNotifier();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _purchaseNotifier.addListener(_onPurchasesChanged);
    _userExercisesNotifier.addListener(_onUserExercisesChanged);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _purchaseNotifier.removeListener(_onPurchasesChanged);
    _userExercisesNotifier.removeListener(_onUserExercisesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onPurchasesChanged() => setState(() {});
  void _onUserExercisesChanged() => setState(() {});

  /// Récupère tous les exercices (officiels + personnels)
  List<ExerciseLibraryItem> get _allExercises {
    final all = <ExerciseLibraryItem>[];
    all.addAll(DemoExercises.allExercises);
    all.addAll(_userExercisesNotifier.userExercises);
    return all;
  }

  /// Filtre les exercices selon la recherche
  List<ExerciseLibraryItem> get _filteredExercises {
    if (_searchQuery.isEmpty) return _allExercises;
    return _allExercises.where((ex) =>
        ex.name.toLowerCase().contains(_searchQuery) ||
        ex.description.toLowerCase().contains(_searchQuery) ||
        ex.muscles.any((m) => m.toLowerCase().contains(_searchQuery)) ||
        (ex.secondaryMuscles != null &&
            ex.secondaryMuscles!.any((m) => m.toLowerCase().contains(_searchQuery)))).toList();
  }

  /// Groupe les exercices par catégorie musculaire
  Map<String, List<ExerciseLibraryItem>> _groupExercisesByCategory(List<ExerciseLibraryItem> exercises) {
    final grouped = <String, List<ExerciseLibraryItem>>{};
    
    // Mapper les catégories existantes vers les groupes musculaires iOS
    final categoryMapping = {
      'Abdos': 'Abdominaux',
      'Abdominaux': 'Abdominaux',
      'Haut du corps': 'Pectoraux', // Par défaut
      'Jambes': 'Jambes',
      'Full body': 'Autres',
      'Cardio': 'Autres',
      'Mobilité': 'Autres',
    };

    for (final exercise in exercises) {
      // Déterminer le groupe musculaire principal
      String muscleGroup = 'Autres';
      
      // Vérifier d'abord les muscles travaillés
      if (exercise.muscles.isNotEmpty) {
        final firstMuscle = exercise.muscles.first.toLowerCase();
        if (firstMuscle.contains('abdo') || firstMuscle.contains('core')) {
          muscleGroup = 'Abdominaux';
        } else if (firstMuscle.contains('pecto') || firstMuscle.contains('pec')) {
          muscleGroup = 'Pectoraux';
        } else if (firstMuscle.contains('dos') || firstMuscle.contains('back') || firstMuscle.contains('lats')) {
          muscleGroup = 'Dos';
        } else if (firstMuscle.contains('jambe') || firstMuscle.contains('quad') || firstMuscle.contains('fessier')) {
          muscleGroup = 'Jambes';
        } else if (firstMuscle.contains('biceps')) {
          muscleGroup = 'Biceps';
        } else if (firstMuscle.contains('triceps')) {
          muscleGroup = 'Triceps';
        } else if (firstMuscle.contains('delto') || firstMuscle.contains('épaule') || firstMuscle.contains('shoulder')) {
          muscleGroup = 'Deltoïdes';
        }
      }
      
      // Sinon utiliser le mapping de catégorie
      if (muscleGroup == 'Autres') {
        muscleGroup = categoryMapping[exercise.category] ?? 'Autres';
      }

      grouped.putIfAbsent(muscleGroup, () => []).add(exercise);
    }

    // Trier les groupes selon l'ordre iOS Fitness
    final orderedGroups = <String, List<ExerciseLibraryItem>>{};
    for (final group in ExerciseIconHelper.muscleGroups) {
      if (grouped.containsKey(group)) {
        orderedGroups[group] = grouped[group]!;
      }
    }
    // Ajouter les groupes non listés à la fin
    for (final entry in grouped.entries) {
      if (!orderedGroups.containsKey(entry.key)) {
        orderedGroups[entry.key] = entry.value;
      }
    }

    return orderedGroups;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExercises;
    final grouped = _groupExercisesByCategory(filtered);

    return Container(
      color: const Color(0xFF121212), // Fond sombre iOS
      child: Column(
        children: [
          // Bandeau Mode Sélection (si actif)
          if (widget.selectionMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFC300), Color(0xFFFFD54F)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, color: Colors.black, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Sélectionnez un exercice pour l\'ajouter',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1A1A1A),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Liste groupée par catégorie
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final entry = grouped.entries.elementAt(index);
                      return _MuscleGroupSection(
                        muscleGroup: entry.key,
                        exercises: entry.value,
                        purchaseNotifier: _purchaseNotifier,
                        onExerciseTap: (exercise) {
                          if (widget.selectionMode) {
                            widget.onExerciseSelected?.call(exercise);
                            Navigator.of(context).pop(exercise);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailProPage(exercise: exercise),
                            ),
                          );
                        }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun exercice trouvé',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section d'un groupe musculaire avec ses exercices
class _MuscleGroupSection extends StatelessWidget {
  final String muscleGroup;
  final List<ExerciseLibraryItem> exercises;
  final DemoPurchaseNotifier purchaseNotifier;
  final Function(ExerciseLibraryItem) onExerciseTap;

  const _MuscleGroupSection({
    required this.muscleGroup,
    required this.exercises,
    required this.purchaseNotifier,
    required this.onExerciseTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 1000;
        // Plus de colonnes sur très grand écran pour une vue plus globale
        final crossAxisCount = constraints.maxWidth >= 1400 
            ? 3 
            : (isWideScreen ? 2 : 1);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de section amélioré
            Container(
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  ExerciseIconHelper.buildMuscleGroupAvatar(muscleGroup, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          muscleGroup,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exercises.length} exercice${exercises.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Liste des exercices (grid compact)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWideScreen ? crossAxisCount : 2,
                  childAspectRatio: isWideScreen ? 3.5 : 2.8, // Plus compact
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final isOwned = !exercise.isPremium ||
                      (exercise.packId != null &&
                          purchaseNotifier.hasVideoPack(
                              DemoExercises.getPackById(exercise.packId!)?.title ?? ''));

                  return _ExerciseCompactCard(
                    exercise: exercise,
                    isOwned: isOwned,
                    onTap: () => onExerciseTap(exercise),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 8), // Séparateur entre sections
          ],
        );
      },
    );
  }
}

/// Carte d'exercice compacte pour la grille
class _ExerciseCompactCard extends StatelessWidget {
  final ExerciseLibraryItem exercise;
  final bool isOwned;
  final VoidCallback onTap;

  const _ExerciseCompactCard({
    required this.exercise,
    required this.isOwned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isOwned ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOwned 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              // Avatar compact
              ExerciseIconHelper.buildExerciseAvatar(
                exercise.name,
                exercise.category,
                size: 32,
              ),
              const SizedBox(width: 8),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                        color: isOwned ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exercise.category,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item d'exercice dans la liste (style iOS pro) - Gardé pour compatibilité
class _ExerciseListItem extends StatelessWidget {
  final ExerciseLibraryItem exercise;
  final bool isOwned;
  final VoidCallback onTap;
  final bool isCard;

  const _ExerciseListItem({
    required this.exercise,
    required this.isOwned,
    required this.onTap,
    this.isCard = false,
  });

  String _getAbbreviatedName(String fullName) {
    if (fullName.length <= 12) return fullName;
    final words = fullName.split(' ');
    if (words.length >= 2) {
      final abbreviated = words.take(3).map((word) {
        if (word.length <= 3) return word;
        return word.substring(0, 3).toUpperCase();
      }).join(' ');
      if (abbreviated.length <= 15) return abbreviated;
      return '${abbreviated.substring(0, 12)}...';
    }
    return fullName.substring(0, fullName.length > 12 ? 12 : fullName.length);
  }

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isOwned ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: isCard ? const EdgeInsets.all(0) : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOwned 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ExerciseIconHelper.buildExerciseAvatar(
                exercise.name,
                exercise.category,
                size: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getAbbreviatedName(exercise.name),
                      style: TextStyle(
                        color: isOwned ? Colors.white : Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3), // Réduit de 6 à 3
                    // Groupe musculaire / Matériel
                    Text(
                      exercise.muscleGroup.isNotEmpty
                          ? exercise.muscleGroup
                          : (exercise.muscles.isNotEmpty
                              ? exercise.muscles.take(1).join(', ') // Prendre seulement le premier muscle
                              : exercise.category),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11, // Réduit de 13 à 11
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Infos de performance (optionnel, masqué si pas de place)
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getExerciseStats(exercise.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final stats = snapshot.data!;
                          final maxWeight = stats['maxWeight'] as double?;
                          final maxReps = stats['maxReps'] as int?;
                          
                          if (maxWeight != null || maxReps != null) {
                            final parts = <String>[];
                            if (maxWeight != null) {
                              parts.add('${maxWeight.toStringAsFixed(0)}kg');
                            }
                            if (maxReps != null) {
                              parts.add('${maxReps}r');
                            }
                            
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                parts.join(' • '),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 9, // Très petit
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6), // Réduit de 12 à 6

              // Icône de difficulté ressentie (plus petite, optionnel)
              FutureBuilder<List<DifficultyEntry>>(
                future: DifficultyService().getByExercise(exercise.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final difficulties = snapshot.data!;
                    final average = (difficulties.map((e) => e.level).reduce((a, b) => a + b) /
                            difficulties.length)
                        .round();
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(average).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getDifficultyColor(average).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$average',
                        style: TextStyle(
                          color: _getDifficultyColor(average),
                          fontSize: 9, // Réduit de 11 à 9
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Flèche ou cadenas (plus petite)
              Icon(
                isOwned ? Icons.chevron_right : Icons.lock_outline,
                color: isOwned
                    ? Colors.white.withOpacity(0.4)
                    : const Color(0xFFFFC300),
                size: 18, // Réduit de 24 à 18
              ),
            ],
          ),
        ),
      ),
    );

    return content;
  }

  Color _getDifficultyColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  /// Récupère les statistiques d'un exercice (charge max, reps max, dernière date)
  Future<Map<String, dynamic>> _getExerciseStats(String exerciseId) async {
    try {
      final performances = await WorkoutSessionStorage.getExercisePerformances(exerciseId);
      if (performances.isEmpty) {
        return {};
      }

      double? maxWeight;
      int? maxReps;
      DateTime? lastDate;

      for (final perf in performances) {
        // Dernière date
        final perfDate = perf.completedAt ?? perf.startedAt;
        if (perfDate != null && (lastDate == null || perfDate.isAfter(lastDate))) {
          lastDate = perfDate;
        }

        // Charge max et reps max
        for (final set in perf.sets) {
          if (set.weight != null && (maxWeight == null || set.weight! > maxWeight)) {
            maxWeight = set.weight;
          }
          if (set.reps != null && (maxReps == null || set.reps! > maxReps)) {
            maxReps = set.reps;
          }
        }
      }

      return {
        'maxWeight': maxWeight,
        'maxReps': maxReps,
        'lastDate': lastDate,
      };
    } catch (e) {
      return {};
    }
  }
}

