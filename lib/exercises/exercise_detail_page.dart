import 'package:flutter/material.dart';
import 'dart:async'; // Pour le chronomètre
import 'package:video_player/video_player.dart';
import '../models/exercise_library_item.dart';
import '../models/exercise.dart' as exercise_model;
import '../models/demo_purchase.dart';
import '../models/user_exercises_notifier.dart';
import '../models/exercise_difficulty_notifier.dart';
import '../data/demo_exercises.dart';
import '../data/exercise_data_helper.dart';
import '../pages/video_packs_page.dart';
import 'exercise_video_page.dart';
import 'create_exercise_page.dart';
import '../workout_session_page.dart';
import '../models/workout_session.dart';
import '../models/workout_step.dart';
import '../models/workout_session_storage.dart';
import 'package:intl/intl.dart';

/// Page de détail d'un exercice avec toutes les informations
class ExerciseDetailPage extends StatefulWidget {
  final ExerciseLibraryItem? exerciseLibraryItem;
  final exercise_model.ExerciseLibrary? exercise;

  const ExerciseDetailPage({
    super.key,
    this.exerciseLibraryItem,
    this.exercise,
  }) : assert(exerciseLibraryItem != null || exercise != null,
          'Either exerciseLibraryItem or exercise must be provided');

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  List<MapEntry<WorkoutSession, ExercisePerformance>>? _exerciseHistory;
  bool _isLoadingHistory = true;

  exercise_model.ExerciseLibrary get _exercise {
    if (widget.exercise != null) {
      return widget.exercise!;
    }
    // Enrichir ExerciseLibraryItem avec toutes les données
    return ExerciseDataHelper.enrichExercise(widget.exerciseLibraryItem!);
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadExerciseHistory();
  }

  Future<void> _loadExerciseHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    final exerciseId = widget.exerciseLibraryItem?.id ?? _exercise.id;
    final history = await WorkoutSessionStorage.getExerciseHistory(exerciseId);
    setState(() {
      _exerciseHistory = history;
      _isLoadingHistory = false;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (_exercise.videoUrl == null) {
      return;
    }

    // Si c'est une URL YouTube ou externe, on ne charge pas de lecteur vidéo
    if (_exercise.videoUrl!.contains('youtube.com') || 
        _exercise.videoUrl!.contains('youtu.be') ||
        _exercise.videoUrl!.startsWith('http')) {
      return;
    }

    // Pour les assets locaux, essayer de charger
    try {
      _videoController = VideoPlayerController.asset(_exercise.videoUrl!);
      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
      _videoController?.dispose();
      _videoController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseNotifier = DemoPurchaseNotifier();
    final userExercisesNotifier = UserExercisesNotifier();
    final pack = widget.exerciseLibraryItem?.packId != null
        ? DemoExercises.getPackById(widget.exerciseLibraryItem!.packId!)
        : null;
    final isOwned = widget.exerciseLibraryItem == null ||
        !widget.exerciseLibraryItem!.isPremium ||
        (pack != null && purchaseNotifier.hasVideoPack(pack.title));
    
    final exerciseItem = widget.exerciseLibraryItem;
    final isUserExercise = exerciseItem != null && exerciseItem.isUserCreated;
    final isPremium = purchaseNotifier.hasPremium;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: Text(_exercise.name),
        centerTitle: true,
        actions: [
          const ExerciseTimerWidget(),
          if (isUserExercise) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateExercisePage(),
                  ),
                ).then((_) {
                  // Rafraîchir la page après modification
                  setState(() {});
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmation(context, exerciseItem!, userExercisesNotifier);
              },
            ),
          ],
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone vidéo/image/placeholder en haut
              _buildMediaSection(isOwned),

              const SizedBox(height: 24),

              // Badge officiel/personnel
              if (exerciseItem != null) ...[
                Row(
                  children: [
                    if (exerciseItem.isOfficial)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC300).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFC300)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Color(0xFFFFC300),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Exercice Ukan officiel',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (exerciseItem.isUserCreated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Color(0xFF4CAF50),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Exercice personnel',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Cadenas Premium si non possédé
              if (widget.exerciseLibraryItem != null && 
                  !isOwned && 
                  widget.exerciseLibraryItem!.isPremium && 
                  pack != null)
                _buildPremiumLockSection(pack),

              // Nom de l'exercice
              Text(
                _exercise.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Catégorie, difficulté, équipement
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.category,
                    label: _exercise.category,
                    color: Colors.blue,
                  ),
                  _InfoChip(
                    icon: Icons.fitness_center,
                    label: _exercise.equipment,
                    color: Colors.orange,
                  ),
                  _InfoChip(
                    icon: Icons.trending_up,
                    label: _exercise.difficulty.displayName,
                    color: _exercise.difficulty.color,
                  ),
                  // Difficulté ressentie (depuis le modèle ou depuis les notes utilisateur)
                  Builder(
                    builder: (context) {
                      final difficultyNotifier = ExerciseDifficultyNotifier();
                      final averageDifficulty = difficultyNotifier.getAverageDifficulty(exerciseItem?.id ?? _exercise.id);
                      final displayedDifficulty = exerciseItem?.perceivedDifficulty ?? 
                          (averageDifficulty != null ? averageDifficulty.value : null);
                      
                      if (displayedDifficulty != null) {
                        return _InfoChip(
                          icon: Icons.sentiment_satisfied,
                          label: 'Ressenti : $displayedDifficulty',
                          color: Colors.purple,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description
              _buildSection(
                title: 'Description',
                child: Text(
                  _exercise.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Muscles ciblés
              _buildSection(
                title: 'Muscles sollicités',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_exercise.mainMuscles.isNotEmpty) ...[
                      const Text(
                        'Principaux',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _exercise.mainMuscles.map((muscle) => Chip(
                          label: Text(muscle),
                          backgroundColor: const Color(0xFFFFC300).withValues(alpha: 0.2),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        )).toList(),
                      ),
                    ],
                    if (_exercise.secondaryMuscles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Secondaires',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _exercise.secondaryMuscles.map((muscle) => Chip(
                          label: Text(muscle),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: const TextStyle(
                            fontSize: 12,
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Étapes détaillées
              if (_exercise.steps.isNotEmpty)
                _buildSection(
                  title: 'Étapes d\'exécution',
                  child: Column(
                    children: _exercise.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC300),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Erreurs fréquentes
              if (_exercise.commonMistakes.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Erreurs fréquentes',
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.orange,
                  child: Column(
                    children: _exercise.commonMistakes.map((mistake) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mistake,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],

              // Conseils
              if (_exercise.tips.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Conseils',
                  icon: Icons.lightbulb_outline,
                  iconColor: const Color(0xFFFFC300),
                  child: Column(
                    children: _exercise.tips.map((tip) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4CC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFC300).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: Color(0xFF111111),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Section Vidéo
              if (exerciseItem?.videoUrl != null || _exercise.videoUrl != null)
                _buildVideoSection(
                  exerciseItem?.videoUrl ?? _exercise.videoUrl!,
                  isOwned,
                  isPremium,
                ),

              // Section Partage (pour exercices personnels)
              if (isUserExercise && exerciseItem != null) ...[
                const SizedBox(height: 24),
                _buildShareSection(exerciseItem, userExercisesNotifier),
              ],

              const SizedBox(height: 24),

              // Section Historique et Progression
              _buildHistoryAndProgressSection(),

              const SizedBox(height: 24),

              // Bouton "Démarrer l'exercice" pour l'exercice de test développeur
              if (exerciseItem?.id == 'test_developer' || _exercise.id == 'test_developer') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Créer des étapes de test pour tester toutes les fonctionnalités
                      final testSteps = [
                        const WorkoutStep(
                          id: 'test_step_1',
                          title: 'Test Chronomètre',
                          description: 'Teste le chronomètre : démarrage, pause, reprise. Durée : 30 secondes.',
                          durationSeconds: 30,
                          restSeconds: 5,
                        ),
                        const WorkoutStep(
                          id: 'test_step_2',
                          title: 'Test Capteurs',
                          description: 'Teste les capteurs (accéléromètre, gyroscope). Utilise les boutons d\'action pour activer les capteurs.',
                          durationSeconds: 20,
                          restSeconds: 5,
                        ),
                        const WorkoutStep(
                          id: 'test_step_3',
                          title: 'Test Caméra',
                          description: 'Teste la caméra. Utilise le bouton caméra pour capturer une photo ou vidéo.',
                          durationSeconds: 15,
                          restSeconds: 5,
                        ),
                        const WorkoutStep(
                          id: 'test_step_4',
                          title: 'Test Voix',
                          description: 'Teste la reconnaissance vocale. Utilise le bouton micro pour activer la voix.',
                          durationSeconds: 20,
                          restSeconds: 5,
                        ),
                        const WorkoutStep(
                          id: 'test_step_5',
                          title: 'Test Coach Vocal IA',
                          description: 'Teste le coach vocal IA. Sélectionne un coach dans l\'AppBar et écoute les phrases d\'encouragement.',
                          durationSeconds: 30,
                          restSeconds: 0,
                        ),
                      ];
                      
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WorkoutSessionPage(
                            workoutTitle: '🧪 Exercice Test Développeur',
                            steps: testSteps,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: const Color(0xFF111111),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      '🧪 Démarrer l\'exercice de test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],

              // Bouton vidéo (si possédé et vidéo disponible)
              if (isOwned && _exercise.videoUrl != null && exerciseItem?.videoUrl == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExerciseVideoPage(
                            exercise: widget.exerciseLibraryItem ?? _exercise.toLibraryItem(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text(
                      'Voir la vidéo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection(bool isOwned) {
    // Si vidéo disponible et initialisée
    if (_isVideoInitialized && _videoController != null) {
      return Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              Center(
                child: IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si image disponible
    if (_exercise.imageUrls.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            _exercise.imageUrls.first,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _PlaceholderImage(exercise: _exercise),
          ),
        ),
      );
    }

    // Sinon placeholder
    return _PlaceholderImage(exercise: _exercise);
  }

  Widget _buildPremiumLockSection(dynamic pack) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFC300),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline,
            color: Color(0xFFFFC300),
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Exercice Premium',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cet exercice fait partie du pack "${pack.title}".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoPacksPage(highlightPackId: pack.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: const Color(0xFF111111),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Voir le pack',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    IconData? icon,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: iconColor ?? const Color(0xFF111111),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildVideoSection(String videoUrl, bool isOwned, bool isPremium) {
    final exerciseItem = widget.exerciseLibraryItem;
    final isUserVideo = exerciseItem != null && exerciseItem.isUserCreated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.video_library, color: Color(0xFF111111)),
              SizedBox(width: 8),
              Text(
                'Vidéo de démonstration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isUserVideo && !isPremium)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4CC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC300)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 18, color: Color(0xFF111111)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Réservé aux membres Premium',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: (isUserVideo && !isPremium) ? null : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExerciseVideoPage(
                        exercise: widget.exerciseLibraryItem ?? _exercise.toLibraryItem(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: const Color(0xFF111111),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.play_circle_fill, size: 32),
                label: const Text(
                  'Lire la vidéo (démo)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection(ExerciseLibraryItem exerciseItem, UserExercisesNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.share, color: Color(0xFF111111)),
              SizedBox(width: 8),
              Text(
                'Partage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Partager à la communauté (démo)'),
            subtitle: const Text(
              'Permet de partager votre exercice avec la communauté Ukan',
              style: TextStyle(fontSize: 12),
            ),
            value: exerciseItem.isShared,
            onChanged: (value) {
              notifier.toggleExerciseShare(exerciseItem.id);
              setState(() {});
            },
            activeColor: const Color(0xFFFFC300),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryAndProgressSection() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_exerciseHistory == null || _exerciseHistory!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF111111)),
                SizedBox(width: 8),
                Text(
                  'Historique et Progression',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune séance enregistrée pour cet exercice',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enregistre ta première séance pour voir ta progression !',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Calculer les statistiques
    final performances = _exerciseHistory!.map((e) => e.value).toList();
    final maxWeight = performances
        .where((p) => p.maxWeight != null)
        .map((p) => p.maxWeight!)
        .fold<double?>(null, (max, w) => max == null || w > max ? w : max);
    final maxVolume = performances
        .where((p) => p.totalVolume > 0)
        .map((p) => p.totalVolume)
        .fold<double?>(null, (max, v) => max == null || v > max ? v : max);
    final lastPerformance = performances.first;
    final previousPerformance = performances.length > 1 ? performances[1] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: Color(0xFF111111)),
              SizedBox(width: 8),
              Text(
                'Historique et Progression',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Statistiques principales
          Row(
            children: [
              Expanded(
                child: _ExerciseStatCard(
                  label: 'Séances',
                  value: '${_exerciseHistory!.length}',
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              if (maxWeight != null)
                Expanded(
                  child: _ExerciseStatCard(
                    label: 'Charge max',
                    value: '${maxWeight.toStringAsFixed(1)} kg',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
              if (maxVolume != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ExerciseStatCard(
                    label: 'Volume max',
                    value: '${maxVolume.toStringAsFixed(0)} kg',
                    icon: Icons.bar_chart,
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Comparaison avec dernière fois
          if (previousPerformance != null) ...[
            _buildComparisonCard(lastPerformance, previousPerformance),
            const SizedBox(height: 16),
          ],
          // Liste des séances récentes
          const Text(
            'Séances récentes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ..._exerciseHistory!.take(5).map((entry) {
            final session = entry.key;
            final performance = entry.value;
            return _ExerciseHistoryItemCard(
              session: session,
              performance: performance,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(ExercisePerformance current, ExercisePerformance previous) {
    final weightDiff = current.maxWeight != null && previous.maxWeight != null
        ? current.maxWeight! - previous.maxWeight!
        : null;
    final volumeDiff = current.totalVolume - previous.totalVolume;
    final repsDiff = current.sets.isNotEmpty && previous.sets.isNotEmpty
        ? (current.sets.first.reps ?? 0) - (previous.sets.first.reps ?? 0)
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparaison avec la dernière fois',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (weightDiff != null) ...[
            _ExerciseComparisonRow(
              label: 'Charge max',
              current: '${current.maxWeight!.toStringAsFixed(1)} kg',
              previous: '${previous.maxWeight!.toStringAsFixed(1)} kg',
              diff: weightDiff,
              isPositive: weightDiff > 0,
            ),
          ],
          if (volumeDiff != 0) ...[
            const SizedBox(height: 4),
            _ExerciseComparisonRow(
              label: 'Volume total',
              current: '${current.totalVolume.toStringAsFixed(0)} kg',
              previous: '${previous.totalVolume.toStringAsFixed(0)} kg',
              diff: volumeDiff,
              isPositive: volumeDiff > 0,
            ),
          ],
          if (repsDiff != null && repsDiff != 0) ...[
            const SizedBox(height: 4),
            _ExerciseComparisonRow(
              label: 'Répétitions (1ère série)',
              current: '${current.sets.first.reps ?? 0}',
              previous: '${previous.sets.first.reps ?? 0}',
              diff: repsDiff.toDouble(),
              isPositive: repsDiff > 0,
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ExerciseLibraryItem exercise,
    UserExercisesNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'exercice'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${exercise.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteUserExercise(exercise.id);
              Navigator.of(context).pop(); // Fermer le dialog
              Navigator.of(context).pop(); // Retourner à la liste
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exercice supprimé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ExerciseStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExerciseComparisonRow extends StatelessWidget {
  final String label;
  final String current;
  final String previous;
  final double diff;
  final bool isPositive;

  const _ExerciseComparisonRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.diff,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
        Text(
          previous,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: isPositive ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          current,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _ExerciseHistoryItemCard extends StatelessWidget {
  final WorkoutSession session;
  final ExercisePerformance performance;

  const _ExerciseHistoryItemCard({
    required this.session,
    required this.performance,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(session.startTime),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (performance.maxWeight != null)
                Text(
                  '${performance.maxWeight!.toStringAsFixed(1)} kg max',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (performance.sets.isNotEmpty) ...[
                Text(
                  '${performance.sets.length} série${performance.sets.length > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (performance.totalVolume > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Volume: ${performance.totalVolume.toStringAsFixed(0)} kg',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final exercise_model.ExerciseLibrary exercise;

  const _PlaceholderImage({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Image à venir',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// WIDGETS CHRONOMÈTRE
// ---------------------------------------------------------------------------

class ExerciseTimerWidget extends StatefulWidget {
  const ExerciseTimerWidget({super.key});

  @override
  State<ExerciseTimerWidget> createState() => _ExerciseTimerWidgetState();
}

class _ExerciseTimerWidgetState extends State<ExerciseTimerWidget> {
  Timer? _timer;
  int _seconds = 0;
  bool _isActive = false;
  bool _isCountdown = false;
  int _initialCountdown = 60;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    _stopTimer();
    setState(() {
      _isActive = true;
      _isCountdown = false;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _startCountdown(int duration) {
    _stopTimer();
    setState(() {
      _isActive = true;
      _isCountdown = true;
      _initialCountdown = duration;
      _seconds = duration;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _stopTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Temps écoulé ! ⏰"), duration: Duration(seconds: 2)),
            );
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
    });
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showTimerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chronomètre & Repos",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Options rapides
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimerOption(
                    icon: Icons.timer,
                    label: "Chrono",
                    color: const Color(0xFFFFC300),
                    onTap: () {
                      _startStopwatch();
                      Navigator.pop(context);
                    },
                  ),
                  _buildTimerOption(
                    icon: Icons.hourglass_bottom,
                    label: "30s",
                    color: Colors.blue,
                    onTap: () {
                      _startCountdown(30);
                      Navigator.pop(context);
                    },
                  ),
                  _buildTimerOption(
                    icon: Icons.hourglass_bottom,
                    label: "1m00",
                    color: Colors.green,
                    onTap: () {
                      _startCountdown(60);
                      Navigator.pop(context);
                    },
                  ),
                  _buildTimerOption(
                    icon: Icons.hourglass_bottom,
                    label: "1m30",
                    color: Colors.orange,
                    onTap: () {
                      _startCountdown(90);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
               if (_isActive) 
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _stopTimer();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Arrêter le minuteur"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTimerOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTimerMenu,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _isActive ? const Color(0xFFFFC300) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: _isActive ? null : Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(
              _isActive 
                  ? (_isCountdown ? Icons.hourglass_bottom : Icons.timer) 
                  : Icons.timer_outlined,
              color: _isActive ? Colors.black : Colors.white,
              size: 20,
            ),
            if (_isActive) ...[
              const SizedBox(width: 6),
              Text(
                _formatTime(_seconds),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace', 
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
