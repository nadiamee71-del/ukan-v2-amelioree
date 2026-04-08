import 'package:flutter/material.dart';
import '../models/exercise_library_item.dart';
import '../models/demo_purchase.dart';
import '../models/user_exercises_notifier.dart';
import '../data/demo_exercises.dart';
import 'exercise_detail_page.dart';
import 'create_exercise_page.dart';
import '../workout/my_workout_programs_page.dart';
import '../workout/my_workout_sessions_page.dart';
import '../workout/workout_program_edit_page.dart';
import '../workout/workout_session_recording_page.dart';
import 'exercises_tab_widget.dart';
import 'exercises_calendar_tab.dart';
import '../pages/difficulty_history_page.dart';

/// Page bibliothèque d'exercices
class ExerciseLibraryPage extends StatefulWidget {
  final String? initialPackId; // Pour filtrer sur un pack spécifique au démarrage
  final bool selectionMode; // Si true, retourne l'exercice sélectionné au lieu d'ouvrir la page de détail

  const ExerciseLibraryPage({super.key, this.initialPackId, this.selectionMode = false});

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> with SingleTickerProviderStateMixin {
  final _purchaseNotifier = DemoPurchaseNotifier();
  final _userExercisesNotifier = UserExercisesNotifier();
  
  String? _selectedCategory;
  ExerciseDifficulty? _selectedDifficulty;
  String? _selectedSource; // 'Tous', 'Ukan', 'Mes exercices'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  List<String> get _categories => [
    'Toutes',
    'Jambes',
    'Haut du corps',
    'Abdos',
    'Full body',
    'Cardio',
    'Mobilité',
  ];

  List<String> get _sourceFilters => [
    'Tous',
    'Exercices Ukan',
    'Mes exercices',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild pour mettre à jour le FAB
    });
    _selectedCategory = 'Toutes';
    _selectedSource = 'Tous';
    _purchaseNotifier.addListener(_onPurchasesChanged);
    _userExercisesNotifier.addListener(_onUserExercisesChanged);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    
    // Si un pack initial est spécifié, filtrer les exercices de ce pack
    if (widget.initialPackId != null) {
      final packExercises = DemoExercises.getExercisesByPackId(widget.initialPackId!);
      if (packExercises.isNotEmpty) {
        // Pré-remplir la recherche avec le nom du pack pour faciliter la recherche
        final pack = DemoExercises.getPackById(widget.initialPackId!);
        if (pack != null) {
          _searchController.text = pack.title;
          _searchQuery = pack.title.toLowerCase();
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _purchaseNotifier.removeListener(_onPurchasesChanged);
    _userExercisesNotifier.removeListener(_onUserExercisesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onPurchasesChanged() {
    setState(() {});
  }

  void _onUserExercisesChanged() {
    setState(() {});
  }

  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // Exercices - Petit bouton rond discret
        return FloatingActionButton.small(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CreateExercisePage(),
              ),
            ).then((_) {
              // Rafraîchir la liste après création
              setState(() {});
            });
          },
          backgroundColor: const Color(0xFFFFC300), // Jaune Ukan
          tooltip: 'Ajouter un exercice',
          child: const Icon(Icons.add, color: Color(0xFF111111), size: 20),
        );
      case 1: // Mes Programmes - Petit bouton rond discret
        return FloatingActionButton.small(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WorkoutProgramEditPage(),
              ),
            );
            // Recharger les programmes si nécessaire
            setState(() {});
          },
          tooltip: 'Nouveau programme',
          backgroundColor: const Color(0xFF111111),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        );
      case 2: // Mes Séances - pas de FAB car bouton dans l'état vide
        return null;
      default:
        return null;
    }
  }

  void _showGlobalStats(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GlobalStatsSheet(),
    );
  }

  void _showGlobalPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GlobalPreferencesSheet(),
    );
  }

  List<ExerciseLibraryItem> get _filteredExercises {
    // Combiner exercices officiels et personnels
    var allExercises = <ExerciseLibraryItem>[];
    
    // Ajouter exercices officiels
    if (_selectedSource == null || _selectedSource == 'Tous' || _selectedSource == 'Exercices Ukan') {
      allExercises.addAll(DemoExercises.allExercises);
    }
    
    // Ajouter exercices personnels
    if (_selectedSource == null || _selectedSource == 'Tous' || _selectedSource == 'Mes exercices') {
      allExercises.addAll(_userExercisesNotifier.userExercises);
    }

    // Filtre par catégorie
    if (_selectedCategory != null && _selectedCategory != 'Toutes') {
      allExercises = allExercises.where((ex) => ex.category == _selectedCategory).toList();
    }

    // Filtre par difficulté
    if (_selectedDifficulty != null) {
      allExercises = allExercises.where((ex) => ex.difficulty == _selectedDifficulty).toList();
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      allExercises = allExercises.where((ex) =>
          ex.name.toLowerCase().contains(_searchQuery) ||
          ex.description.toLowerCase().contains(_searchQuery) ||
          ex.muscles.any((m) => m.toLowerCase().contains(_searchQuery)) ||
          (ex.secondaryMuscles != null && ex.secondaryMuscles!.any((m) => m.toLowerCase().contains(_searchQuery)))
      ).toList();
    }

    return allExercises;
  }

  Widget _buildExercisesTab(List<ExerciseLibraryItem> exercises) {
    return Column(
      children: [
        // Bandeau Mode démo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4CC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFC300),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Color(0xFF111111),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Données fictives pour maquette',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Barre de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un exercice...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Filtres
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Filtre Source
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButton<String>(
                  value: _selectedSource,
                  items: _sourceFilters.map((source) => DropdownMenuItem(
                    value: source,
                    child: Text(source),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSource = value);
                  },
                  underline: const SizedBox.shrink(),
                  isDense: true,
                ),
              ),
              const SizedBox(width: 8),

              // Filtre Catégorie
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                  underline: const SizedBox.shrink(),
                  isDense: true,
                ),
              ),
              const SizedBox(width: 8),

              // Filtre Difficulté
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButton<ExerciseDifficulty>(
                  value: _selectedDifficulty,
                  hint: const Text('Niveau'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tous niveaux'),
                    ),
                    ...ExerciseDifficulty.values.map((diff) => DropdownMenuItem(
                      value: diff,
                      child: Text(diff.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDifficulty = value);
                  },
                  underline: const SizedBox.shrink(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Liste des exercices
        Expanded(
          child: exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun exercice trouvé',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final isOwned = !exercise.isPremium || 
                        (exercise.packId != null && 
                         _purchaseNotifier.hasVideoPack(DemoExercises.getPackById(exercise.packId!)?.title ?? ''));
                    
                    return _ExerciseCard(
                      exercise: exercise,
                      isOwned: isOwned,
                      onTap: () {
                        if (widget.selectionMode) {
                          Navigator.of(context).pop(exercise);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailPage(exerciseLibraryItem: exercise),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fond sombre iOS
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A), // AppBar sombre
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bibliothèque d\'exercices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          // Bouton Historique des difficultés
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique difficultés',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DifficultyHistoryPage(),
                ),
              );
            },
          ),
          // Bouton Statistiques globales
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistiques',
            onPressed: () => _showGlobalStats(context),
          ),
          // Bouton Préférences globales
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Préférences',
            onPressed: () => _showGlobalPreferences(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF1A1A1A),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFFC300), // Jaune Ukan pour l'onglet sélectionné
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: const Color(0xFFFFC300),
              indicatorWeight: 3,
              isScrollable: false,
              enableFeedback: true,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              onTap: (index) {
                // S'assurer que le changement d'onglet fonctionne
                _tabController.animateTo(index);
              },
              tabs: const [
                Tab(text: 'Exercices'),
                Tab(text: 'Programmes'),
                Tab(text: 'Séances'),
                Tab(text: 'Calendrier'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(), // Permet le swipe entre les onglets
          children: [
            // Onglet Exercices - Nouveau widget avec design iOS
            ExercisesTabWidget(
              selectionMode: widget.selectionMode,
              onExerciseSelected: (exercise) {
                if (widget.selectionMode) {
                  Navigator.of(context).pop(exercise);
                }
              },
            ),
            // Onglet Mes Programmes
            const MyWorkoutProgramsPage(embedInTab: true),
            // Onglet Mes Séances
            const MyWorkoutSessionsPage(embedInTab: true),
            // Onglet Calendrier (historique + objectifs)
            const ExercisesCalendarTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseLibraryItem exercise;
  final bool isOwned;
  final VoidCallback onTap;

  _ExerciseCard({
    Key? key,
    required this.exercise,
    required this.isOwned,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOwned ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: !isOwned
                  ? Border.all(color: const Color(0xFFFFC300), width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                // Image/Icone
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: exercise.imageAsset != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            exercise.imageAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.fitness_center,
                              color: !isOwned ? Colors.grey.shade400 : const Color(0xFFFFC300),
                              size: 32,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fitness_center,
                          color: !isOwned ? Colors.grey.shade400 : const Color(0xFFFFC300),
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),

                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: !isOwned ? Colors.grey.shade600 : Colors.black87,
                              ),
                            ),
                          ),
                          // Badge Perso
                          if (exercise.isUserCreated)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 12,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Perso',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Badge Partagé
                          if (exercise.isUserCreated && exercise.isShared)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.share,
                                    size: 12,
                                    color: Color(0xFF2196F3),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Partagé',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                ],
                            ),
                          ),
                          if (exercise.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4CC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    !isOwned ? Icons.lock : Icons.star,
                                    size: 12,
                                    color: const Color(0xFF111111),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Premium',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: exercise.difficulty.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise.difficulty.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: exercise.difficulty.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${exercise.muscles.take(2).join(', ')}${exercise.muscles.length > 2 ? '...' : ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Icône cadenas ou flèche
                Icon(
                  !isOwned ? Icons.lock_outline : Icons.chevron_right,
                  color: !isOwned ? const Color(0xFFFFC300) : Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS STATISTIQUES ET PRÉFÉRENCES GLOBALES
// ═══════════════════════════════════════════════════════════════════════════

/// Bottom sheet des statistiques globales
class _GlobalStatsSheet extends StatelessWidget {
  const _GlobalStatsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFC300).withOpacity(0.2),
                        const Color(0xFFFF8C00).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Color(0xFFFFC300),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistiques globales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vue d\'ensemble de tes performances',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),

          // Contenu
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Cartes de stats principales
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.fitness_center,
                          iconColor: const Color(0xFF2ECC71),
                          value: '156',
                          label: 'Séances',
                          trend: '+12%',
                          trendUp: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF3498DB),
                          value: '48h',
                          label: 'Temps total',
                          trend: '+5h',
                          trendUp: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department,
                          iconColor: const Color(0xFFE74C3C),
                          value: '24.5k',
                          label: 'Calories',
                          trend: '+2.1k',
                          trendUp: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events,
                          iconColor: const Color(0xFFFFC300),
                          value: '12',
                          label: 'Records',
                          trend: '+3',
                          trendUp: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section Exercices favoris
                  _buildSection(
                    title: '💪 Exercices les plus pratiqués',
                    child: Column(
                      children: [
                        _buildExerciseStatRow('Développé couché', 45, const Color(0xFF2ECC71)),
                        _buildExerciseStatRow('Squat', 38, const Color(0xFF3498DB)),
                        _buildExerciseStatRow('Tractions', 32, const Color(0xFFFFC300)),
                        _buildExerciseStatRow('Soulevé de terre', 28, const Color(0xFFE74C3C)),
                        _buildExerciseStatRow('Curl biceps', 24, const Color(0xFF9B59B6)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Progression
                  _buildSection(
                    title: '📈 Progression ce mois',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2ECC71).withOpacity(0.1),
                            const Color(0xFF2ECC71).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2ECC71).withOpacity(0.2),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Volume total',
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                '+18% vs mois dernier',
                                style: TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Régularité',
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                '4.2 séances/semaine',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildExerciseStatRow(String name, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            '$count séances',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (trendUp ? Colors.green : Colors.red).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      color: trendUp ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: trendUp ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet des préférences globales
class _GlobalPreferencesSheet extends StatefulWidget {
  const _GlobalPreferencesSheet();

  @override
  State<_GlobalPreferencesSheet> createState() => _GlobalPreferencesSheetState();
}

class _GlobalPreferencesSheetState extends State<_GlobalPreferencesSheet> {
  // Préférences générales
  String _weightUnit = 'kg';
  int _defaultRestTime = 90;
  bool _autoStartTimer = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  
  // Rappels globaux
  bool _remindersEnabled = true;
  String _reminderFrequency = 'daily';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  List<int> _reminderDays = [1, 3, 5];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Color(0xFFFFC300),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Préférences',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Paramètres de la bibliothèque',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),

          // Contenu
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Unités
                  _buildSectionTitle('⚖️ Unités & Mesures'),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Unité de poids',
                    trailing: ToggleButtons(
                      isSelected: [_weightUnit == 'kg', _weightUnit == 'lbs'],
                      onPressed: (index) {
                        setState(() {
                          _weightUnit = index == 0 ? 'kg' : 'lbs';
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.black,
                      fillColor: const Color(0xFFFFC300),
                      color: Colors.white54,
                      constraints: const BoxConstraints(minWidth: 50, minHeight: 36),
                      children: const [Text('kg'), Text('lbs')],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Timer
                  _buildSectionTitle('⏱️ Timer de repos'),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    icon: Icons.timer,
                    title: 'Temps par défaut',
                    subtitle: '$_defaultRestTime secondes',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuickButton('-', () {
                          if (_defaultRestTime > 15) {
                            setState(() => _defaultRestTime -= 15);
                          }
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${_defaultRestTime}s',
                            style: const TextStyle(
                              color: Color(0xFFFFC300),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildQuickButton('+', () {
                          setState(() => _defaultRestTime += 15);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSwitchCard(
                    icon: Icons.play_circle_outline,
                    title: 'Démarrage auto',
                    subtitle: 'Lance le timer après chaque série',
                    value: _autoStartTimer,
                    onChanged: (v) => setState(() => _autoStartTimer = v),
                  ),
                  _buildSwitchCard(
                    icon: Icons.vibration,
                    title: 'Vibration',
                    subtitle: 'Vibre à la fin du repos',
                    value: _vibrationEnabled,
                    onChanged: (v) => setState(() => _vibrationEnabled = v),
                  ),
                  _buildSwitchCard(
                    icon: Icons.volume_up,
                    title: 'Son',
                    subtitle: 'Alerte sonore',
                    value: _soundEnabled,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                  ),

                  const SizedBox(height: 24),

                  // Section Rappels
                  _buildSectionTitle('🔔 Rappels d\'entraînement'),
                  const SizedBox(height: 12),
                  _buildSwitchCard(
                    icon: Icons.notifications_active,
                    title: 'Activer les rappels',
                    subtitle: 'Reçois des notifications',
                    value: _remindersEnabled,
                    onChanged: (v) => setState(() => _remindersEnabled = v),
                  ),
                  
                  if (_remindersEnabled) ...[
                    const SizedBox(height: 12),
                    _buildFrequencySelector(),
                    const SizedBox(height: 12),
                    _buildTimeSelector(),
                    if (_reminderFrequency == 'weekly') ...[
                      const SizedBox(height: 12),
                      _buildDaysSelector(),
                    ],
                  ],

                  const SizedBox(height: 32),

                  // Bouton Sauvegarder
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Préférences sauvegardées'),
                            backgroundColor: Color(0xFF2E7D32),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC300),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'SAUVEGARDER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFFC300),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    final frequencies = [
      {'id': 'daily', 'label': 'Quotidien'},
      {'id': 'weekly', 'label': 'Hebdomadaire'},
      {'id': 'monthly', 'label': 'Mensuel'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fréquence',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: frequencies.map((f) {
              final isSelected = _reminderFrequency == f['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _reminderFrequency = f['id'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFC300) : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        f['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _reminderTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFFFC300),
                  surface: Color(0xFF1A1A1A),
                ),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          setState(() => _reminderTime = time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white54, size: 22),
            const SizedBox(width: 14),
            const Text(
              'Heure du rappel',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
              ),
              child: Text(
                '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Color(0xFFFFC300),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSelector() {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jours de rappel',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = _reminderDays.contains(dayNum);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _reminderDays.remove(dayNum);
                    } else {
                      _reminderDays.add(dayNum);
                    }
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFC300) : const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
