import 'package:flutter/material.dart';
import 'alter_ego_duel.dart';
import 'alter_ego_model.dart';
import 'injury_log_screen.dart';
import 'alter_ego_floating/alter_ego_service.dart';
import 'alter_ego_floating/alter_ego_floating_widget.dart';
import 'espace_pro_screen.dart';
import 'models/transformation_projection.dart';
import 'dart:math' as math;

/// Configuration du duel Alter Ego
class AlterEgoDuelConfig {
  final String label;
  final int targetSeconds;

  const AlterEgoDuelConfig({
    required this.label,
    required this.targetSeconds,
  });
}

class AlterEgoScreen extends StatefulWidget {
  const AlterEgoScreen({super.key});

  @override
  State<AlterEgoScreen> createState() => _AlterEgoScreenState();
}

class _AlterEgoScreenState extends State<AlterEgoScreen> {
  AlterEgoDuelConfig? _selectedDuel;
  late AlterEgoSnapshot _snapshot;
  final AlterEgoService _alterEgoService = AlterEgoService();
  final TransformationProjectionNotifier _projectionNotifier =
      TransformationProjectionNotifier();
  bool _hasWelcomed = false;

  @override
  void initState() {
    super.initState();
    _snapshot = getDemoSnapshot();
    // Valeur par défaut : Gainage 45 sec
    _selectedDuel = const AlterEgoDuelConfig(
      label: '🧱 Gainage 45 sec',
      targetSeconds: 45,
    );
    
    // Écouter les changements de projections
    _projectionNotifier.addListener(_onProjectionChanged);
    
    // Activer l'Alter Ego flottant et commenter les progrès
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _alterEgoService.setVisible(true);
        _alterEgoService.setPosition(AlterEgoPosition.topRight);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _commentOnProgress();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _projectionNotifier.removeListener(_onProjectionChanged);
    super.dispose();
  }

  void _onProjectionChanged() {
    if (mounted) setState(() {});
  }

  // Obtenir l'image de la phase d'évolution actuelle (dernière phase débloquée)
  Widget _buildCurrentPhaseImage() {
    final unlockedPhases = _projectionNotifier.getUnlockedPhases();
    
    // Si aucune phase débloquée, afficher phase_0mois (Actuel)
    if (unlockedPhases.isEmpty) {
      return _buildPhaseImage('assets/images/phase_0mois.png', 'Actuel');
    }
    
    // Afficher la dernière phase débloquée (la plus avancée)
    final currentPhase = unlockedPhases.last;
    return _buildPhaseImage(currentPhase.imagePath, currentPhase.label);
  }

  Widget _buildPhaseImage(String imagePath, String label) {
    return Image.asset(
      imagePath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain, // Utiliser contain pour ne pas couper l'image
      errorBuilder: (context, error, stackTrace) {
        // Si l'image n'existe pas, afficher un placeholder avec le label
        return Container(
          color: Colors.cyanAccent.withOpacity(0.1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 32,
                  color: Colors.cyanAccent.withOpacity(0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.cyanAccent.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _commentOnProgress() {
    final caloriesProgress = _snapshot.calories / _snapshot.caloriesGoal;
    final waterProgress = _snapshot.waterLiters / _snapshot.waterGoal;
    final stepsProgress = _snapshot.steps / _snapshot.stepsGoal;

    if (!_hasWelcomed) {
      _hasWelcomed = true;
      _alterEgoService.showMessage(
        "Salut ! Voici ton bilan du jour. Je vais t'accompagner pour atteindre tes objectifs ! 💪",
        pose: AlterEgoPose.salut,
      );
      return;
    }

    // Commenter les calories
    if (caloriesProgress >= 1.0) {
      _alterEgoService.showMessage(
        "Excellent ! Tu as atteint ton objectif de calories ! 🔥",
        pose: AlterEgoPose.felicite,
      );
    } else if (caloriesProgress < 0.6) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _alterEgoService.showMessage(
            "Tu es à ${(caloriesProgress * 100).toInt()}% de ton objectif calories. Continue ! 💪",
            pose: AlterEgoPose.encourage,
          );
        }
      });
    }

    // Commenter l'eau
    if (waterProgress < 0.5) {
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted) {
          _alterEgoService.showMessage(
            "N'oublie pas de boire de l'eau ! Tu es à ${(waterProgress * 100).toInt()}% de ton objectif. 💧",
            pose: AlterEgoPose.reflechit,
          );
        }
      });
    } else if (waterProgress >= 1.0) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _alterEgoService.showMessage(
            "Super ! Tu as bien bu de l'eau aujourd'hui ! 💧",
            pose: AlterEgoPose.felicite,
          );
        }
      });
    }

    // Commenter les pas
    if (stepsProgress >= 0.75) {
      Future.delayed(const Duration(seconds: 9), () {
        if (mounted) {
          _alterEgoService.showMessage(
            "Tu es à ${(stepsProgress * 100).toInt()}% de tes pas. Excellent ! 👟",
            pose: AlterEgoPose.clindoeil,
          );
        }
      });
    }

    // Encourager à utiliser Santé & Blessures
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        _alterEgoService.showMessage(
          "N'oublie pas de gérer tes blessures dans Santé & Blessures pour un entraînement sûr ! 🛡️",
          pose: AlterEgoPose.alerte,
        );
      }
    });
  }

  void _selectDuel(AlterEgoDuelConfig config) {
    setState(() {
      _selectedDuel = config;
    });
  }

  void _launchDuel() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlterEgoDuelScreen(
          duelConfig: _selectedDuel,
        ),
      ),
    );
  }

  void _showPaywall() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF050814),
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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Débloque ton Alter Ego Premium",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _PaywallFeature(
                icon: Icons.lock_open_rounded,
                text: "Bilan quotidien détaillé (pas, calories, eau, séances)",
              ),
              const SizedBox(height: 16),
              _PaywallFeature(
                icon: Icons.lock_open_rounded,
                text: "Duo de coachs (motivation + comptable)",
              ),
              const SizedBox(height: 16),
              _PaywallFeature(
                icon: Icons.lock_open_rounded,
                text: "Conseils personnalisés chaque soir",
              ),
              const SizedBox(height: 16),
              _PaywallFeature(
                icon: Icons.lock_open_rounded,
                text: "Intégration future avec podomètre et suivi réel",
              ),
              const SizedBox(height: 16),
              _PaywallFeature(
                icon: Icons.timeline_rounded,
                text: "Timeline d'évolution par phases (Actuel, 3, 6, 9, 12 mois)",
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Découverte Ukan Premium (démo)"),
                        backgroundColor: Color(0xFFFFC300),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC300),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Découvrir Ukan Premium",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Plus tard",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showPremiumLocked() {
    if (!isAlterEgoPremiumUnlocked) {
      _showPaywall();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepsProgress = (_snapshot.steps / _snapshot.stepsGoal).clamp(0.0, 1.0);
    final remainingSteps = math.max(0, _snapshot.stepsGoal - _snapshot.steps);

    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050814),
        elevation: 0,
        title: const Text(
          "Mon Alter Ego Premium",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Section 1 - Avatar & phrase d'accueil
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1020),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar avec image de projection
                  Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.cyanAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          // Image de la phase d'évolution actuelle
                          _buildCurrentPhaseImage(),
                          // Overlay avec le texte
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                    child: const Text(
                                  "Futur Moi\nProjection",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                                    fontSize: 16,
                        fontWeight: FontWeight.bold,
                                    height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Phrase du coach
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "Je suis ton Alter Ego. Aujourd'hui on vise ${_snapshot.stepsGoal} pas, prêt ? 👟",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Section 2 - Barre de progression générale
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Progression vers ton futur",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _snapshot.score / 100,
                    minHeight: 12,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Colors.cyanAccent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${_snapshot.score}% ✨",
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Section Timeline de ton futur (NOUVELLE SECTION - OPTION PAYANTE)
            if (isAlterEgoPremiumUnlocked)
              _TransformationTimelineSection(
                projectionNotifier: _projectionNotifier,
              )
            else
              _TransformationTimelineSectionLocked(
                onUnlock: _showPaywall,
            ),

            const SizedBox(height: 30),

            // Section 3 - Carte PAS (centrale, HUD futuriste)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFC300).withOpacity(0.15),
                    Colors.cyanAccent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFC300).withOpacity(0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Grand cercle de progression des pas
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Fond du cercle
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.cyanAccent.withOpacity(0.3),
                              width: 8,
                            ),
                          ),
                        ),
                        // Arc de progression
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: stepsProgress,
                            strokeWidth: 8,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFFFC300),
                            ),
                          ),
                        ),
                        // Valeur au centre
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${_snapshot.steps}",
                              style: const TextStyle(
                                color: Color(0xFFFFC300),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "pas",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Objectif ${_snapshot.stepsGoal} pas – reste $remainingSteps pas 👟",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Une petite marche après le dîner et on y est.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Section 4 - Objectifs quotidiens refactorisés avec progression animée
            Column(
              children: [
                // Calories
                _ProgressionStatCard(
                  title: "Calories du jour",
                  current: _snapshot.calories.toDouble(),
                  goal: _snapshot.caloriesGoal.toDouble(),
                  unit: "kcal",
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF6B35),
                  progress: (_snapshot.calories / _snapshot.caloriesGoal).clamp(0.0, 1.0),
                ),
                const SizedBox(height: 16),
                // Eau
                _ProgressionStatCard(
                  title: "Hydratation",
                  current: _snapshot.waterLiters,
                  goal: _snapshot.waterGoal,
                  unit: "L",
                  icon: Icons.water_drop_rounded,
                  color: Colors.cyanAccent,
                  progress: (_snapshot.waterLiters / _snapshot.waterGoal).clamp(0.0, 1.0),
                  isDecimal: true,
                ),
                const SizedBox(height: 16),
                // Séances
                _ProgressionStatCard(
                  title: "Séances",
                  current: _snapshot.workoutsDone.toDouble(),
                  goal: _snapshot.workoutsPlanned.toDouble(),
                  unit: "",
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFFFFC300),
                  progress: (_snapshot.workoutsDone / _snapshot.workoutsPlanned).clamp(0.0, 1.0),
                  isDecimal: false,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lien vers l'Espace Avancé (les blocs Premium et Sécurité ont été migrés)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1020),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Coach IA Premium, Santé & Blessures et autres outils avancés sont maintenant dans Mon Espace Avancé",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EspaceProScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text("Voir Mon Espace Avancé"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.cyanAccent,
                      side: const BorderSide(color: Colors.cyanAccent, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 7 - Message du Comptable
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1020),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.cyanAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Note de ton Alter Ego Comptable",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _snapshot.accountantMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 8 - Mode Duel
            GestureDetector(
              onTap: _launchDuel,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.12),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Rattraper mon futur (Mode Duel)",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton Premium verrouillé (si débloqué)
            if (!isAlterEgoPremiumUnlocked)
              Opacity(
                opacity: 0.6,
                child: GestureDetector(
                  onTap: _showPremiumLocked,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1020),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Voir le détail complet de mes stats",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
          // Alter Ego flottant
          const AlterEgoFloatingWidget(),
        ],
      ),
    );
  }
}

/// Widget pour une carte de progression animée avec icône et barre/cercles
class _ProgressionStatCard extends StatefulWidget {
  final String title;
  final double current;
  final double goal;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;
  final bool isDecimal;

  const _ProgressionStatCard({
    required this.title,
    required this.current,
    required this.goal,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
    this.isDecimal = false,
  });

  @override
  State<_ProgressionStatCard> createState() => _ProgressionStatCardState();
}

class _ProgressionStatCardState extends State<_ProgressionStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (widget.progress * 100).clamp(0.0, 100.0);
    final remaining = widget.goal - widget.current;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.color.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.isDecimal
                              ? widget.current.toStringAsFixed(1)
                              : widget.current.toInt().toString(),
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "${widget.unit} / ${widget.isDecimal ? widget.goal.toStringAsFixed(1) : widget.goal.toInt()}${widget.unit}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de progression animée
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _animation.value,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${progressPercent.toStringAsFixed(0)}% complété",
                        style: TextStyle(
                          color: widget.color.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (remaining > 0)
                        Text(
                          "Reste ${widget.isDecimal ? remaining.toStringAsFixed(1) : remaining.toInt()}${widget.unit}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        )
                      else
                        Text(
                          "Objectif atteint ! 🎉",
                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget pour une feature du paywall
class _PaywallFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PaywallFeature({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC300), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget : Section Timeline verrouillée (version payante)
class _TransformationTimelineSectionLocked extends StatelessWidget {
  final VoidCallback onUnlock;

  const _TransformationTimelineSectionLocked({
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUnlock,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1020),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Timeline de ton futur',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.lock_outline,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 48,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Fonctionnalité Premium',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Débloque ton Alter Ego Premium pour voir ta timeline d\'évolution par phases',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: onUnlock,
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Débloquer Premium'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.cyanAccent,
                        side: const BorderSide(color: Colors.cyanAccent, width: 2),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget : Section Timeline de ton futur (NOUVEAU WIDGET)
/// Affiche les phases d'évolution débloquées depuis Transformation Projection™
/// S'actualise automatiquement quand on débloque des phases
class _TransformationTimelineSection extends StatelessWidget {
  final TransformationProjectionNotifier projectionNotifier;

  const _TransformationTimelineSection({
    required this.projectionNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedPhases = projectionNotifier.getUnlockedPhases();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline,
                color: Colors.cyanAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Timeline de ton futur (démo)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fonctionnalité de projection visuelle en mode démo, sans calcul réel.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          if (unlockedPhases.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune phase débloquée',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Va dans Transformation Projection™ pour débloquer des phases',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: unlockedPhases.length,
                itemBuilder: (context, index) {
                  final phase = unlockedPhases[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < unlockedPhases.length - 1 ? 12 : 0,
                    ),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Image
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  phase.imagePath,
                                  fit: BoxFit.contain, // Utiliser contain pour ne pas couper l'image
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder(phase.label);
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Label
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.cyanAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  phase.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Container(
      color: Colors.cyanAccent.withOpacity(0.1),
      child: Center(
        child: Text(
          '$label\nDEMO',
          style: TextStyle(
            color: Colors.cyanAccent.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Widget réutilisable : bandeau compact Alter Ego pour l'écran d'accueil
class AlterEgoMiniBar extends StatelessWidget {
  const AlterEgoMiniBar({super.key});

  @override
  Widget build(BuildContext context) {
    final snapshot = getDemoSnapshot();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AlterEgoScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF050814),
              Colors.cyanAccent.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar rond
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.cyanAccent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                "⚡",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Alter Ego",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${snapshot.steps} / ${snapshot.stepsGoal} pas",
                        style: TextStyle(
                          color: Colors.cyanAccent.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Score ${snapshot.score}/100",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Flèche
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.cyanAccent.withOpacity(0.8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
