library ukan_main;

import 'package:flutter/material.dart';
import 'features/nutrition/repas_courses_page.dart';
import 'nutrition/nutrition_hub_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_directory_page.dart';
import 'coach_dashboard_page.dart';
import 'models/user_profile.dart';
import 'pages/edit_profile_page.dart';
import 'pages/edit_deadline_page.dart';
import 'pages/profile_feed_page.dart';
import 'pages/create_feed_post_page.dart';
import 'models/profile_feed.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:io';
import 'models/workout_session.dart';
import 'models/workout_step.dart';
import 'workout_session_page.dart';
import 'models/nutrition.dart';
import 'add_meal_page.dart';
import 'models/goals.dart';
import 'models/workout_history.dart';
import 'add_sleep_page.dart';
import 'add_water_page.dart';
import 'models/steps.dart';
import 'add_steps_page.dart';
import 'rooms_page.dart';
import 'models/subscription.dart';
import 'premium_page.dart';
import 'stats_page.dart';
import 'planning_page.dart';
import 'future_self_advanced_page.dart';
import 'alter_ego.dart';
import 'alter_ego_floating/alter_ego_floating_widget.dart';
import 'alter_ego_floating/alter_ego_service.dart';
import 'alter_ego_floating/dashboard_alter_ego_helper.dart';
import 'alter_ego_floating/alter_ego_page_detector.dart';
import 'home/widgets/weekly_challenge_header.dart';
import 'home/widgets/stories_header_row.dart';
import 'alter_ego_floating/alter_ego_chat_button.dart';
import 'community_chat_page.dart';
import 'body_composition_page.dart';
import 'pedometer_page.dart';
import 'chat_match/match_home_page.dart';
import 'buddy_training/buddy_home_page.dart';
import 'chat_match/match_results_page.dart';
import 'chat_match/match_engine.dart';
import 'chat_match/match_profile.dart';
import 'coach_business/business_dashboard.dart';
import 'game_story/story_home.dart';
import 'coach_vs_coach/coach_ranking_page.dart';
import 'transformation_ra/ra_future_preview.dart';
import 'coach_personality/coach_style_picker.dart';
import 'pages/my_purchases_page.dart';
import 'pages/video_packs_page.dart';
import 'exercises/exercise_library_page.dart';
import 'models/demo_purchase.dart';
import 'pages/weekly_sessions_page.dart';
import 'pages/simple_nutrition_page.dart';
import 'pages/sessions_goal_page.dart';
import 'chat_page.dart';
import 'coach_detail_page.dart';
import 'models/coach_directory.dart';
import 'coach/coach_session.dart';
import 'models/coach_programs.dart';
import 'pages/steps_goal_page.dart';
import 'pages/sleep_goal_page.dart';
import 'pages/calories_goal_page.dart';
import 'pages/hydration_goal_page.dart';
import 'pages/protein_goal_page.dart';
import 'pages/recipes_community_page.dart';
import 'foodscan_ia/foodscan_home_page.dart';
import 'group_classes/group_class_live.dart';
import 'group_classes/group_class_replays.dart';
import 'coach_personality/coach_personality_page.dart';
import 'coach_personality/coach_personality_notifier.dart';
import 'espace_pro_screen.dart';
import 'auth/signup_role_page.dart';
import 'pages/health_injuries_page.dart';
import 'models/injury.dart';
import 'splash_screen.dart';
import 'components/parrainage_button.dart';
import 'pages/parrainage_page.dart';
import 'models/theme_notifier.dart';
import 'components/messaging_icon_button.dart';
import 'models/messaging.dart';
import 'components/chat_bubble_header_button.dart';
import 'pages/settings_page.dart';
import 'feed/feed_page.dart';
import 'pages/message_inbox_page.dart';

part 'home/home_page.dart';
part 'home/models/demo_feed_data.dart';
part 'home/widgets/dashboard_tab.dart';
part 'home/widgets/publications_tab.dart';
part 'home/widgets/stories_row.dart';
part 'home/widgets/publication_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Recharge l'identité du coach connecté puis les modifications du profil
  // coach persistées localement (source unique : CoachDirectoryNotifier).
  await CoachSession().load();
  await CoachDirectoryNotifier().loadPersistedProfile();
  runApp(const UkanApp());
}

// ─────────────────────────────────────────────
// App racine
// ─────────────────────────────────────────────

class UkanApp extends StatefulWidget {
  const UkanApp({super.key});

  @override
  State<UkanApp> createState() => _UkanAppState();
}

class _UkanAppState extends State<UkanApp> {
  final _themeNotifier = ThemeNotifier();

  @override
  void initState() {
    super.initState();
    _themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ukan',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaleFactor: 1.0, // Désactiver le zoom automatique du texte
            devicePixelRatio: mediaQuery.devicePixelRatio.clamp(1.0, 2.0), // Limiter le devicePixelRatio
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9E6), // Jaune très clair pour mode jour
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC300),
          primary: const Color(0xFFFFB366), // Orange pastel au lieu de noir
          secondary: const Color(0xFFFFC300),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFB366), // Orange pastel au lieu de noir
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A0E27), // Noir pour mode nuit
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC300),
          primary: const Color(0xFFFFB366), // Orange pastel même en mode nuit
          secondary: const Color(0xFFFFC300),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFB366), // Orange pastel au lieu de noir
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// Page de connexion
// ─────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'toi@mail.com');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _loading = false;

  Future<void> _onLogin() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const UkanHomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFFFC300).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo mascotte Ukan
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC300).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: -5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/fitpro_logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback si le logo n'existe pas
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Color(0xFFFFC300),
                      size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ukan',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Coaching sportif personnalisé',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Carte de connexion avec ombre
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Retrouve tes programmes et ton suivi.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _LabeledField(
                          label: 'Email',
                          icon: Icons.mail_outline,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _LabeledField(
                          label: 'Mot de passe',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC300),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide.none,
                              ),
                              shadowColor: Colors.transparent,
                            ).copyWith(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return const Color(0xFFFFC300).withOpacity(0.5);
                                  }
                                  return const Color(0xFFFFC300);
                                },
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignupRolePage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.label,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFFFC300),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Shell avec bottom navigation
// ─────────────────────────────────────────────

class UkanHomeShell extends StatefulWidget {
  /// Rôle connu au moment de la navigation (login / inscription).
  /// Si null, le rôle est relu depuis SharedPreferences (clé `fitpro_role`).
  final String? initialRole;

  const UkanHomeShell({super.key, this.initialRole});

  @override
  State<UkanHomeShell> createState() => _UkanHomeShellState();
}

class _UkanHomeShellState extends State<UkanHomeShell> {
  int _currentIndex = 0;

  // Rôle courant : 'coach' ou 'client'. Secours par défaut : 'client'.
  String _role = 'client';

  @override
  void initState() {
    super.initState();
    if (widget.initialRole != null) {
      _role = _normalizeRole(widget.initialRole);
    } else {
      _loadRoleFromPrefs();
    }
  }

  String _normalizeRole(String? raw) => raw == 'coach' ? 'coach' : 'client';

  Future<void> _loadRoleFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = _normalizeRole(prefs.getString('fitpro_role'));
      if (mounted && role != _role) {
        setState(() => _role = role);
      }
    } catch (_) {
      // En cas d'erreur, on conserve le rôle de secours 'client'.
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;
    final bool isCoach = _role == 'coach';
    final pages = [
      HomePage(coachMode: isCoach, onOpenNextWorkout: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkoutDetailPage(
              workout: const Workout(
                title: 'Full body – Niveau intermédiaire',
                durationMinutes: 45,
                difficulty: 'Intermédiaire',
                sessionsPerWeek: 4,
                objective: 'Perte de poids',
                equipment: 'Tapis, haltères légers',
                calories: 500,
                steps: 8000,
              ),
            ),
          ),
        );
      }),
      SessionsTab(
        onWorkoutSelected: (workout) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutDetailPage(workout: workout),
            ),
          );
        },
        onViewWeeklySessions: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const WeeklySessionsPage(),
            ),
          );
        },
      ),
      const NutritionTab(), // Garde l'original, on peut aussi utiliser SimpleNutritionTab plus tard
      EspaceProScreen(isCoach: isCoach),
      const CoachDirectoryPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Fond sombre uniforme
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22), // AppBar sombre
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ukan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _openSettings,
        ),
        actions: [
          // Avatar + Bulle de pensée (avatar à gauche, bulle alignée avec la tête)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 85,
              height: 52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Avatar Alter Ego à gauche
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: AlterEgoProfileIcon(
                      size: 48,
                      onTap: _openProfile,
                    ),
                  ),
                  // Bulle de pensée - alignée avec le haut de la tête
                  // Les petites bulles pointent vers la tête en diagonale
                  Positioned(
                    right: 0,
                    top: -2, // Légèrement au-dessus pour s'aligner avec la tête
                    child: AlterEgoChatButton(
                      onTap: () {
                        final service = AlterEgoService();
                        if (!service.isChatActive) {
                          service.startConversation();
                        } else {
                          service.toggleChatInterface();
                        }
                      },
                      isActive: AlterEgoService().isChatActive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          // Alter Ego fenêtre de chat (le bouton est dans l'AppBar)
          const AlterEgoFloatingWidget(showFloatingButton: false),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: const Color(0xFF161B22), // Fond sombre uniforme
        selectedItemColor: const Color(0xFFFFC300), // Doré sélectionné
        unselectedItemColor: const Color(0xFF8B949E), // Gris non sélectionné
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Séances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications_rounded),
            label: 'Avancé',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Rechercher',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Onglet 1 : Accueil
// ─────────────────────────────────────────────

// Onglet 2 : Séances
// ─────────────────────────────────────────────

class Workout {
  final String title;
  final int durationMinutes;
  final String difficulty;
  final int sessionsPerWeek;
  final String objective;
  final String equipment;
  final int calories;
  final int steps;
  final String? imageAsset; // Chemin vers une image locale (optionnel)
  final String? videoUrl; // URL vidéo YouTube ou chemin local (optionnel)

  const Workout({
    required this.title,
    required this.durationMinutes,
    required this.difficulty,
    required this.sessionsPerWeek,
    required this.objective,
    required this.equipment,
    required this.calories,
    required this.steps,
    this.imageAsset,
    this.videoUrl,
  });
}

// Couleurs professionnelles : Marron et Vert pour SessionsTab
const Color _marronPrincipalSeances = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonceSeances = Color(0xFF5D4037); // Material Brown 700
const Color _marronClairSeances = Color(0xFFA1887F); // Material Brown 300
const Color _vertPrincipalSeances = Color(0xFF4CAF50); // Material Green 500
const Color _vertClairSeances = Color(0xFF66BB6A); // Material Green 300
const Color _vertFonceSeances = Color(0xFF388E3C); // Material Green 700

class SessionsTab extends StatefulWidget {
  final void Function(Workout workout) onWorkoutSelected;
  final VoidCallback? onViewWeeklySessions;

  const SessionsTab({
    super.key,
    required this.onWorkoutSelected,
    this.onViewWeeklySessions,
  });

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedTabIndex = 0;

  List<Workout> get _workouts => const [
        Workout(
          title: 'Programme débutant – 3 séances',
          durationMinutes: 40,
          difficulty: 'Débutant',
          sessionsPerWeek: 3,
          objective: 'Remise en forme',
          equipment: "Tapis, bouteille d'eau",
          calories: 350,
          steps: 6000,
          imageAsset: 'assets/images/exercises/beginner.jpg',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        Workout(
          title: 'Full body sans matériel',
          durationMinutes: 35,
          difficulty: 'Intermédiaire',
          sessionsPerWeek: 4,
          objective: 'Tonification globale',
          equipment: 'Poids du corps uniquement',
          calories: 400,
          steps: 7000,
          imageAsset: 'assets/images/exercises/fullbody.jpg',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        Workout(
          title: 'Bas du corps – Renfo',
          durationMinutes: 45,
          difficulty: 'Intermédiaire',
          sessionsPerWeek: 3,
          objective: 'Renforcement jambes & fessiers',
          equipment: 'Haltères, élastiques',
          calories: 450,
          steps: 6500,
          imageAsset: 'assets/images/exercises/legs.jpg',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        Workout(
          title: 'Haut du corps – Force',
          durationMinutes: 45,
          difficulty: 'Avancé',
          sessionsPerWeek: 4,
          objective: 'Force haut du corps',
          equipment: 'Barre, haltères',
          calories: 500,
          steps: 5000,
          imageAsset: 'assets/images/exercises/upperbody.jpg',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Détecter la page pour l'Alter Ego (sessions)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlterEgoPageDetector.setupPageContext(UkanPage.sessions);
    });
    
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // Segmented control pour les 2 onglets
          _SessionsSegmentedControl(
            controller: _tabController,
            selectedIndex: _selectedTabIndex,
          ),
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const PageScrollPhysics(),
              children: [
                // Onglet 1 : Bibliothèque d'exercices
                const ExerciseLibraryPage(),
                // Onglet 2 : Séances de la semaine
                _WeeklySessionsTab(
                  workouts: _workouts,
                  onWorkoutSelected: widget.onWorkoutSelected,
                  onViewWeeklySessions: widget.onViewWeeklySessions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsSegmentedControl extends StatelessWidget {
  final TabController controller;
  final int selectedIndex;

  const _SessionsSegmentedControl({
    required this.controller,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final int index = selectedIndex;
    // Thème noir/or uniforme
    const Color cardBgLight = Color(0xFF21262D);
    const Color borderColor = Color(0xFF30363D);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBgLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Bibliothèque d\'exercices',
              isSelected: index == 0,
              onTap: () => controller.animateTo(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabButton(
              label: 'Séances de la semaine',
              isSelected: index == 1,
              onTap: () => controller.animateTo(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Thème noir/or uniforme
    const Color primaryGold = Color(0xFFFFC300);
    const Color textMuted = Color(0xFF8B949E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryGold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.black : textMuted,
          ),
        ),
      ),
    );
  }
}

class _WeeklySessionsTab extends StatelessWidget {
  final List<Workout> workouts;
  final void Function(Workout workout) onWorkoutSelected;
  final VoidCallback? onViewWeeklySessions;

  const _WeeklySessionsTab({
    required this.workouts,
    required this.onWorkoutSelected,
    this.onViewWeeklySessions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bannière vers séances de la semaine (si callback fourni)
        if (onViewWeeklySessions != null)
          InkWell(
            onTap: onViewWeeklySessions,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _marronClairSeances,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _marronFonceSeances.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _vertPrincipalSeances.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: _vertPrincipalSeances,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Séances de la semaine',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Voir toutes tes séances (passées et à venir)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return _WorkoutListCard(
                workout: workout,
                onTap: () => onWorkoutSelected(workout),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: workouts.length,
          ),
        ),
      ],
    );
  }
}

class _WorkoutListCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const _WorkoutListCard({
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedia = workout.imageAsset != null || workout.videoUrl != null;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _marronClairSeances,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Image ou icône
          if (hasMedia && workout.imageAsset != null)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _marronClairSeances,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(workout.imageAsset!),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
              child: workout.videoUrl != null
                  ? Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _marronFonceSeances.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    )
                  : null,
            )
          else
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _marronPrincipalSeances,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: _vertPrincipalSeances,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                  workout.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                      ),
                    ),
                    if (workout.videoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.video_library_rounded,
                              size: 14,
                              color: _vertFonceSeances,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Vidéo',
                              style: TextStyle(
                                fontSize: 11,
                                color: _vertFonceSeances,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Entraînement guidé • ${workout.durationMinutes}–45 min',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
                            child: const Text(
              'Voir',
              style: TextStyle(
                color: _vertPrincipalSeances,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Onglet 3 : Nutrition
// ─────────────────────────────────────────────

// Couleurs professionnelles : Marron et Jaune pour NutritionTab
const Color _marronPrincipalNutrition = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonceNutrition = Color(0xFF5D4037); // Material Brown 700
const Color _marronClairNutrition = Color(0xFFA1887F); // Material Brown 300
const Color _jaunePrincipalNutrition = Color(0xFFFFC300); // Material Amber 500
const Color _jauneClairNutrition = Color(0xFFFFD54F); // Material Amber 300
const Color _jauneFonceNutrition = Color(0xFFFFB300); // Material Amber 700

class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key});

  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> with SingleTickerProviderStateMixin {
  final _nutritionNotifier = NutritionNotifier();
  final _goalsNotifier = DailyGoalsNotifier();
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nutritionNotifier.addListener(_onNutritionChanged);
    _goalsNotifier.addListener(_onNutritionChanged);
    // Détecter la page pour l'Alter Ego (Nutrition)
    AlterEgoPageDetector.setupPageContext(UkanPage.nutritionDuJour);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nutritionNotifier.removeListener(_onNutritionChanged);
    _goalsNotifier.removeListener(_onNutritionChanged);
    super.dispose();
  }

  void _onNutritionChanged() {
    // Mettre à jour les protéines dans DailyGoalsNotifier
    final summary = _nutritionNotifier.summaryForDate(_selectedDate);
    _goalsNotifier.setProteinForDate(_selectedDate, summary.totalProtein);
    setState(() {});
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    if (_isToday(date)) {
      return 'Aujourd\'hui';
    }
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'jun',
      'jul',
      'aoû',
      'sep',
      'oct',
      'nov',
      'déc'
    ];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final summary = _nutritionNotifier.summaryForDate(_selectedDate);

    // Palette sombre uniforme
    const Color darkBg = Color(0xFF0D1117);
    const Color cardBg = Color(0xFF161B22);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textMuted = Color(0xFF8B949E);
    
    return SafeArea(
      top: false,
      child: Container(
        color: darkBg,
        child: Column(
          children: [
            // TabBar - Thème noir/doré
            Container(
              color: cardBg,
              child: TabBar(
                controller: _tabController,
                indicatorColor: primaryGold,
                indicatorWeight: 3,
                labelColor: primaryGold,
                unselectedLabelColor: textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Nutrition'),
                  Tab(text: 'Recettes & Gourmandises'),
                ],
              ),
            ),
            
            // Contenu des onglets
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Onglet Nutrition - Nouveau Hub immersif
                  const NutritionHubPage(),
                  // Onglet Recettes & Communauté
                  const RecipesCommunityPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.black87, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealEntry meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _marronFonceNutrition,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restaurant,
              color: _jaunePrincipalNutrition,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.calories} kcal • P: ${meal.protein} g • G: ${meal.carbs} g • L: ${meal.fats} g',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Page Profil
// ─────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late final UserProfileNotifier _profileNotifier;
  final _subscriptionNotifier = SubscriptionNotifier();
  final _themeNotifier = ThemeNotifier();
  late TabController _feedTabController; // TabController pour le feed (Publications, Recettes)

  @override
  void initState() {
    super.initState();
    _profileNotifier = UserProfileNotifier();
    _profileNotifier.addListener(_onProfileChanged);
    _subscriptionNotifier.addListener(_onSubscriptionChanged);
    _themeNotifier.addListener(_onThemeChanged);
    _feedTabController = TabController(length: 2, vsync: this); // 2 onglets : Publications, Recettes
  }

  @override
  void dispose() {
    _profileNotifier.removeListener(_onProfileChanged);
    _subscriptionNotifier.removeListener(_onSubscriptionChanged);
    _themeNotifier.removeListener(_onThemeChanged);
    _feedTabController.dispose();
    super.dispose();
  }

  // Helper pour obtenir la couleur de texte selon le thème
  Color _getTextColor() {
    final isDarkMode = _themeNotifier.isDarkMode;
    return isDarkMode ? Colors.white : Colors.black87;
  }

  // Helper pour obtenir la couleur de texte secondaire selon le thème
  Color _getSecondaryTextColor() {
    final isDarkMode = _themeNotifier.isDarkMode;
    return isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
  }

  void _onProfileChanged() {
    setState(() {});
  }

  void _onSubscriptionChanged() {
    setState(() {});
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _openCameraForPost(BuildContext context) async {
    final imagePicker = ImagePicker();
    
    // Afficher un menu pour choisir entre photo, vidéo ou galerie
    final choice = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFFC300)),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, 'camera_photo'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFFFFC300)),
              title: const Text('Prendre une vidéo'),
              onTap: () => Navigator.pop(context, 'camera_video'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFFC300)),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    try {
      if (choice == 'camera_photo') {
        // Ouvrir directement l'appareil photo pour prendre une photo
        final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
        if (image != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateFeedPostPage(
                initialImage: image,
              ),
            ),
          );
        }
      } else if (choice == 'camera_video') {
        // Ouvrir directement l'appareil vidéo pour prendre une vidéo
        final XFile? video = await imagePicker.pickVideo(source: ImageSource.camera);
        if (video != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateFeedPostPage(
                initialVideo: video,
              ),
            ),
          );
        }
      } else if (choice == 'gallery') {
        // Galerie - proposer image ou vidéo
        final mediaType = await showModalBottomSheet<String?>(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo, color: Color(0xFFFFC300)),
                  title: const Text('Image'),
                  onTap: () => Navigator.pop(context, 'image'),
                ),
                ListTile(
                  leading: const Icon(Icons.video_library, color: Color(0xFFFFC300)),
                  title: const Text('Vidéo'),
                  onTap: () => Navigator.pop(context, 'video'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ),
        );

        if (mediaType == 'image') {
          final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
          if (image != null && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateFeedPostPage(
                  initialImage: image,
                ),
              ),
            );
          }
        } else if (mediaType == 'video') {
          final XFile? video = await imagePicker.pickVideo(source: ImageSource.gallery);
          if (video != null && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateFeedPostPage(
                  initialVideo: video,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSubscriptionSection() {
    final plan = _subscriptionNotifier.plan;
    const Color cardBg = Color(0xFF161B22);
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color borderColor = Color(0xFF30363D);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                'Mon offre',
                              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: plan == SubscriptionPlan.premium
                      ? primaryGold
                      : cardBgLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan.displayName,
                  style: TextStyle(
                    color: plan == SubscriptionPlan.premium
                        ? Colors.black
                        : textMuted,
                    fontWeight: FontWeight.w500,
                                fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
                                style: const TextStyle(
              color: textMuted,
                                  fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PremiumPage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGold,
                side: const BorderSide(color: primaryGold),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Découvrir Ukan Premium'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPurchasesSection() {
    final purchaseNotifier = DemoPurchaseNotifier();
    final purchases = purchaseNotifier.purchaseHistory;
    
    const Color cardBg = Color(0xFF161B22);
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color borderColor = Color(0xFF30363D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mes achats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textLight,
                ),
              ),
              if (purchases.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${purchases.length}',
                    style: const TextStyle(
                      color: primaryGold,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            purchases.isEmpty
                ? 'Aucun achat pour l\'instant.'
                : '${purchases.length} achat${purchases.length > 1 ? 's' : ''} enregistré${purchases.length > 1 ? 's' : ''}.',
            style: const TextStyle(
              fontSize: 13,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyPurchasesPage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGold,
                side: const BorderSide(color: primaryGold),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Voir mes achats'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileNotifier.profile;
    
    // Générer les initiales
    final nameParts = profile.name.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : profile.name.isNotEmpty
            ? profile.name.substring(0, profile.name.length > 2 ? 2 : profile.name.length).toUpperCase()
            : 'AF';

    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;
    
    // Palette sombre uniforme (noir/doré)
    const Color darkBg = Color(0xFF0D1117);
    const Color cardBg = Color(0xFF161B22);
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color borderColor = Color(0xFF30363D);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        foregroundColor: textLight,
        title: const Text(
          'Mon profil',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textLight,
          ),
        ),
        centerTitle: true,
        actions: [
          MessagingIconButton(
            currentUserId: 'user_1', // TODO: Récupérer depuis le profil utilisateur
            isCoach: false,
          ),
          IconButton(
            onPressed: () {
              debugPrint('Bouton + cliqué');
              if (mounted) {
                try {
                  _openCameraForPost(context);
                } catch (e) {
                  debugPrint('Erreur lors de l\'ouverture de la caméra: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(
              Icons.add_box_outlined,
              color: primaryGold,
              size: 28,
            ),
            tooltip: 'Créer une publication',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
          child: Column(
            children: [
              // Carte profil moderne - Thème noir/doré
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryGold.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: primaryGold,
                            size: 32,
                          ),
                            ),
                            // Badge de notification
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cardBg,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: textLight,
                                ),
                                    ),
                                  ),
                                  // Notification icon
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                'Objectif : ${profile.mainGoal}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textMuted,
                                      ),
                                    ),
                                  ),
                                  if (profile.deadline.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => EditDeadlinePage(
                                              initialDeadline: profile.deadline,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: cardBgLight,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: primaryGold.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 12,
                                              color: primaryGold,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              profile.deadline,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: textLight,
                                ),
                              ),
                            ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Compteurs (Abonnés, Suivi, Publications)
                    Builder(
                      builder: (context) {
                        final feedNotifier = ProfileFeedNotifier();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCounterItem(
                              value: feedNotifier.followers,
                              label: 'Abonnés',
                              isDarkMode: true, // Toujours dark mode
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: borderColor,
                            ),
                            _buildCounterItem(
                              value: feedNotifier.following,
                              label: 'Suivi',
                              isDarkMode: true,
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: borderColor,
                            ),
                            _buildCounterItem(
                              value: feedNotifier.posts.length,
                              label: 'Publications',
                              isDarkMode: true,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Sections déroulantes - Scrollable horizontal (Option A)
              SizedBox(
                height: 95, // Hauteur fixe pour les cartes fermées
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Carte Mensurations
                    _buildScrollableProfileCard(
                      icon: Icons.fitness_center,
                      label: 'Mensurations',
                      onTap: () => _showMensurationsBottomSheet(context, profile),
                    ),
                    const SizedBox(width: 12),
                    // Carte Objectifs
                    _buildScrollableProfileCard(
                      icon: Icons.emoji_events,
                      label: 'Objectifs',
                      onTap: () => _showObjectifsBottomSheet(context, profile),
                    ),
                    const SizedBox(width: 12),
                    // Carte Évolution
                    _buildScrollableProfileCard(
                      icon: Icons.show_chart,
                      label: 'Évolution',
                      onTap: () => _showEvolutionBottomSheet(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Section "À propos de moi" - Infos personnelles
              _buildAboutMeSection(profile),
              const SizedBox(height: 16),
              
              // Section "Mon Coach" - Accès aux données du coach (refermable)
              _buildMyCoachSection(isDarkMode),
              const SizedBox(height: 16),
              
              // Section "Blessures / Restrictions" - Pour personnaliser l'entraînement
              _buildInjuriesRestrictionsSection(),
              const SizedBox(height: 16),
              
              // Feed avec onglets (comme la page coach)
              _buildProfileFeed(isDarkMode),
              const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCounterItem({
    required int value,
    required String label,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Text(
          _formatCounterNumber(value),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  /// Section "Mon Coach" - Accès aux données du coach (refermable)
  Widget _buildMyCoachSection(bool isDarkMode) {
    // Palette sombre uniforme
    const Color cardBg = Color(0xFF161B22);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color borderColor = Color(0xFF30363D);
    
    // Simuler un coach assigné (dans une vraie app, cela viendrait d'un service)
    final coachId = 'coach_1'; // ID du coach assigné
    final coachName = 'Sophie Martin'; // Nom du coach
    final coachDirectoryNotifier = CoachDirectoryNotifier();
    final coach = coachDirectoryNotifier.getCoachById(coachId);
    final programsNotifier = CoachProgramsNotifier();
    final clientPrograms = programsNotifier.programsForClient('current_user'); // ID du client actuel

    return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
        color: cardBg,
                  borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryGold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        iconColor: primaryGold,
        collapsedIconColor: textMuted,
        leading: Container(
          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
            color: primaryGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
          child: const Icon(
            Icons.person_outline,
            color: primaryGold,
                            size: 24,
                          ),
                        ),
        title: const Text(
          'Mon Coach',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textLight,
                            ),
                          ),
        subtitle: Text(
          coach != null ? coach.name : coachName,
          style: const TextStyle(
            fontSize: 14,
            color: textMuted,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (coach != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoachDetailPage(coachId: coach.id),
                    ),
                  );
                },
                child: const Text(
                  'Voir le profil',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryGold,
                  ),
                ),
              ),
          ],
        ),
                        children: [
                          const Text(
            'Accès aux données de mon coach',
                            style: TextStyle(
              fontSize: 12,
                              color: textMuted,
                            ),
          ),
          const SizedBox(height: 12),
          // Grille d'accès aux données du coach
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _MyCoachDataCard(
                icon: Icons.chat_bubble_outline,
                title: 'Messages',
                subtitle: 'Conversation',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        clientId: 'current_user',
                        clientName: _profileNotifier.profile.name,
                      ),
                    ),
                  );
                },
              ),
              _MyCoachDataCard(
                icon: Icons.lightbulb_outline,
                title: 'Conseils',
                subtitle: 'Recommandations',
                color: const Color(0xFFFFC300),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Les conseils de votre coach seront disponibles ici'),
                    ),
                  );
                },
              ),
              _MyCoachDataCard(
                icon: Icons.fitness_center,
                title: 'Exercices',
                subtitle: 'Assignés',
                color: Colors.green,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExerciseLibraryPage(),
                    ),
                  );
                },
              ),
              _MyCoachDataCard(
                icon: Icons.assignment,
                title: 'Programmes',
                subtitle: '${clientPrograms.length} actif(s)',
                color: Colors.purple,
                onTap: () {
                  if (clientPrograms.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aucun programme assigné pour le moment'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${clientPrograms.length} programme(s) assigné(s) par votre coach'),
                      ),
                    );
                  }
                },
              ),
              _MyCoachDataCard(
                icon: Icons.calendar_today,
                title: 'Planning',
                subtitle: 'Séances',
                color: Colors.orange,
                onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                      builder: (_) => const PlanningPage(),
                            ),
                          );
                        },
              ),
              _MyCoachDataCard(
                icon: Icons.assessment,
                title: 'Suivi',
                subtitle: 'Progression',
                color: Colors.red,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le suivi de votre progression sera disponible ici'),
                    ),
                  );
                },
              ),
            ],
                    ),
                  ],
                ),
    );
  }

  String _formatCounterNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  /// Section "Blessures / Restrictions" - Pour personnaliser l'entraînement
  Widget _buildInjuriesRestrictionsSection() {
    // Palette sombre uniforme
    const Color cardBg = Color(0xFF161B22);
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color primaryRed = Color(0xFFFF6B6B);
    const Color primaryOrange = Color(0xFFFF9F43);
    const Color primaryBlue = Color(0xFF58A6FF);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color borderColor = Color(0xFF30363D);
    
    // Récupérer les données de blessures
    final injuryNotifier = InjuryNotifier();
    final injuries = injuryNotifier.getInjuries();
    final activeInjuries = injuries.where((i) => i.status != 'guérie').toList();
    
    // Collecter tous les exercices à éviter
    final exercisesToAvoid = <String>{};
    for (final injury in activeInjuries) {
      exercisesToAvoid.addAll(injury.exercisesToAvoid);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryRed.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        iconColor: primaryRed,
        collapsedIconColor: textMuted,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryRed.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.health_and_safety,
            color: primaryRed,
            size: 24,
          ),
        ),
        title: const Text(
          'Blessures & Restrictions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textLight,
          ),
        ),
        subtitle: Text(
          activeInjuries.isEmpty 
              ? 'Aucune restriction active'
              : '${activeInjuries.length} blessure${activeInjuries.length > 1 ? 's' : ''} active${activeInjuries.length > 1 ? 's' : ''}',
          style: const TextStyle(
            fontSize: 14,
            color: textMuted,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HealthInjuriesPage(),
                  ),
                );
              },
              child: const Text(
                'Gérer',
                style: TextStyle(
                  fontSize: 12,
                  color: primaryGold,
                ),
              ),
            ),
          ],
        ),
        children: [
          const Text(
            '🎯 Ces informations personnalisent tes entraînements',
            style: TextStyle(
              fontSize: 12,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 16),
          
          // Blessures actives
          if (activeInjuries.isNotEmpty) ...[
            const Text(
              'Blessures actives',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textLight,
              ),
            ),
            const SizedBox(height: 12),
            ...activeInjuries.take(3).map((injury) {
              Color statusColor;
              IconData statusIcon;
              switch (injury.status) {
                case 'en_cours':
                  statusColor = primaryOrange;
                  statusIcon = Icons.pending;
                  break;
                case 'en_rééducation':
                  statusColor = primaryBlue;
                  statusIcon = Icons.fitness_center;
                  break;
                default:
                  statusColor = primaryRed;
                  statusIcon = Icons.warning;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${injury.bodyPart} - ${injury.type}',
                            style: const TextStyle(
                              color: textLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.speed, size: 12, color: _getPainColor(injury.painLevel)),
                              const SizedBox(width: 4),
                              Text(
                                'Douleur ${injury.painLevel}/10',
                                style: TextStyle(
                                  color: _getPainColor(injury.painLevel),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        injury.status == 'en_cours' ? 'En cours' : 'Rééducation',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          
          // Exercices à éviter
          if (exercisesToAvoid.isNotEmpty) ...[
            const Text(
              'Exercices à éviter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textLight,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercisesToAvoid.take(6).map((exercise) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.block, size: 14, color: primaryRed),
                      const SizedBox(width: 6),
                      Text(
                        exercise,
                        style: const TextStyle(
                          color: primaryRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (exercisesToAvoid.length > 6)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${exercisesToAvoid.length - 6} autres',
                  style: const TextStyle(color: textMuted, fontSize: 11),
                ),
              ),
          ] else ...[
            // État vide
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBgLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 32,
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucune restriction !',
                    style: TextStyle(
                      color: textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tu peux t\'entraîner sans limitation 💪',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPainColor(int level) {
    if (level <= 3) return const Color(0xFF4ECDC4);
    if (level <= 6) return const Color(0xFFFF9F43);
    return const Color(0xFFFF6B6B);
  }

  /// Section "À propos de moi" - Infos personnelles de l'utilisateur
  Widget _buildAboutMeSection(UserProfile profile) {
    const Color cardBg = Color(0xFF161B22);
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color primaryCyan = Color(0xFF4ECDC4);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color borderColor = Color(0xFF30363D);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryCyan.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        iconColor: primaryCyan,
        collapsedIconColor: textMuted,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryCyan.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline,
            color: primaryCyan,
            size: 24,
          ),
        ),
        title: const Text(
          'À propos de moi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textLight,
          ),
        ),
        subtitle: const Text(
          'Mes habitudes et préférences',
          style: TextStyle(
            fontSize: 14,
            color: textMuted,
          ),
        ),
        children: [
          // Niveau d'activité
          _buildAboutMeItem(
            icon: Icons.speed,
            label: 'Niveau d\'activité',
            value: profile.activityLevel,
            color: _getActivityLevelColor(profile.activityLevel),
          ),
          const SizedBox(height: 12),
          
          // Où je m'entraîne
          _buildAboutMeItem(
            icon: Icons.location_on_outlined,
            label: 'Où je m\'entraîne',
            value: profile.trainingLocation,
            color: primaryCyan,
          ),
          const SizedBox(height: 12),
          
          // Type d'alimentation
          _buildAboutMeItem(
            icon: Icons.restaurant_menu,
            label: 'Type d\'alimentation',
            value: profile.dietType,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          
          // Sommeil habituel
          _buildAboutMeItem(
            icon: Icons.bedtime_outlined,
            label: 'Sommeil habituel',
            value: '${profile.usualSleepHours.toStringAsFixed(1)} heures / nuit',
            color: const Color(0xFF58A6FF),
          ),
          const SizedBox(height: 12),
          
          // Motivation principale
          if (profile.mainMotivation.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryGold.withOpacity(0.15),
                    primaryGold.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryGold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 18, color: primaryGold),
                      const SizedBox(width: 8),
                      const Text(
                        'Ma motivation principale',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${profile.mainMotivation}"',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textLight,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutMeItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    const Color cardBgLight = Color(0xFF21262D);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'faible':
        return const Color(0xFF58A6FF); // Bleu
      case 'moyen':
        return const Color(0xFFFFC300); // Or
      case 'élevé':
        return const Color(0xFFFF6B6B); // Rouge
      default:
        return const Color(0xFF4ECDC4); // Cyan
    }
  }

  /// Carte scrollable pour le profil (Option A)
  Widget _buildScrollableProfileCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const Color primaryGold = Color(0xFFFFC300);
    const Color cardBg = Color(0xFF161B22);
    const Color borderColor = Color(0xFF30363D);
    const Color textLight = Color(0xFFF0F6FC);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryGold, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet pour les Mensurations
  void _showMensurationsBottomSheet(BuildContext context, UserProfile profile) {
    const Color primaryGold = Color(0xFFFFC300);
    const Color cardBg = Color(0xFF161B22);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.fitness_center, color: primaryGold, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Mensurations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textLight,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Contenu
            _buildMensurationRow('Taille', profile.height != null ? '${profile.height} cm' : '—'),
            _buildMensurationRow('Poids actuel', profile.currentWeight != null ? '${profile.currentWeight!.toStringAsFixed(1)} kg' : '—'),
            _buildMensurationRow('Poids objectif', profile.targetWeight != null ? '${profile.targetWeight!.toStringAsFixed(1)} kg' : '—'),
            const Divider(color: textMuted, height: 32),
            _buildMensurationRow('Tour de taille', profile.waist != null ? '${profile.waist!.toStringAsFixed(1)} cm' : '—'),
            _buildMensurationRow('Hanches', profile.hips != null ? '${profile.hips!.toStringAsFixed(1)} cm' : '—'),
            _buildMensurationRow('Poitrine', profile.chest != null ? '${profile.chest!.toStringAsFixed(1)} cm' : '—'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMensurationRow(String label, String value) {
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color primaryGold = Color(0xFFFFC300);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: value == '—' ? textMuted : textLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet pour les Objectifs
  void _showObjectifsBottomSheet(BuildContext context, UserProfile profile) {
    const Color primaryGold = Color(0xFFFFC300);
    const Color cardBg = Color(0xFF161B22);
    const Color cardBgLight = Color(0xFF21262D);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.emoji_events, color: primaryGold, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Objectifs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textLight,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Objectif principal
              const Text(
                'Objectif principal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                profile.mainGoal,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textLight),
              ),
              // Objectifs secondaires
              if (profile.secondaryGoals.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Objectifs secondaires',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMuted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.secondaryGoals
                      .split('\n')
                      .where((goal) => goal.trim().isNotEmpty)
                      .map((goal) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardBgLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryGold.withOpacity(0.3)),
                      ),
                      child: Text(
                        goal.trim(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textLight),
                      ),
                    );
                  }).toList(),
                ),
              ],
              // Objectifs de la semaine
              const SizedBox(height: 24),
              const Text(
                'Objectifs de la semaine',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMuted),
              ),
              const SizedBox(height: 12),
              _buildWeeklyGoalRow(Icons.fitness_center, 'Séances', '${profile.sessionsPerWeek} / semaine'),
              _buildWeeklyGoalRow(Icons.local_fire_department, 'Calories', '${profile.caloriesGoalPerDay} kcal / jour'),
              _buildWeeklyGoalRow(Icons.directions_walk, 'Pas', '${profile.stepsGoalPerDay} pas / jour'),
              _buildWeeklyGoalRow(Icons.route, 'Distance', '${profile.distanceGoalPerWeek} km / semaine'),
              _buildWeeklyGoalRow(Icons.water_drop, 'Hydratation', '${profile.waterGoalLiters} L / jour'),
              _buildWeeklyGoalRow(Icons.bedtime, 'Sommeil', '${profile.sleepGoalHours}h / nuit'),
              const SizedBox(height: 20),
              // Widget de progression
              _buildProfileProgressWidget(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyGoalRow(IconData icon, String label, String value) {
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryGold, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: textMuted),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textLight),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet pour l'Évolution
  void _showEvolutionBottomSheet(BuildContext context) {
    const Color primaryGold = Color(0xFFFFC300);
    const Color cardBg = Color(0xFF161B22);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.show_chart, color: primaryGold, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Évolution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textLight,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Contenu
            const Icon(Icons.insert_chart_outlined, size: 60, color: textMuted),
            const SizedBox(height: 16),
            const Text(
              'Les courbes de progression et les photos avant/après seront disponibles prochainement.',
              style: TextStyle(
                fontSize: 14,
                color: textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileGoalTag(IconData icon, String label) {
    const Color primaryGold = Color(0xFFFFC300);
    const Color cardBgLight = Color(0xFF21262D);
    const Color textLight = Color(0xFFF0F6FC);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cardBgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: primaryGold),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileProgressWidget() {
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color accentGreen = Color(0xFF4ECDC4);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    
    // Simuler une progression (dans une vraie app, calculer depuis les données réelles)
    final goalsNotifier = DailyGoalsNotifier();
    final stepsNotifier = StepsNotifier();
    final historyNotifier = WorkoutHistoryNotifier();
    final profile = _profileNotifier.profile;
    
    final weekSummary = historyNotifier.summaryForWeek(DateTime.now());
    final sessionsProgress = (weekSummary.sessionsCount / profile.sessionsPerWeek).clamp(0.0, 1.0);
    final stepsProgress = (stepsNotifier.totalForDate(DateTime.now()) / profile.stepsGoalPerDay).clamp(0.0, 1.0);
    final waterProgress = goalsNotifier.waterProgressForDate(DateTime.now()).clamp(0.0, 1.0);
    
    final totalProgress = (sessionsProgress + stepsProgress + waterProgress) / 3;
    final progressPercent = (totalProgress * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: accentGreen),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Progression',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getProgressColorProfile(totalProgress).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$progressPercent%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _getProgressColorProfile(totalProgress),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalProgress,
              minHeight: 8,
              backgroundColor: cardBgLight,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColorProfile(totalProgress)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColorProfile(double progress) {
    if (progress >= 0.8) return const Color(0xFF4ECDC4);
    if (progress >= 0.5) return const Color(0xFFFFC300);
    if (progress >= 0.25) return const Color(0xFFFF9F43);
    return const Color(0xFFFF6B6B);
  }

  /// Feed du profil avec onglets (comme la page coach)
  Widget _buildProfileFeed(bool isDarkMode) {
    // Palette sombre uniforme
    const Color cardBg = Color(0xFF161B22);
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône grille (au lieu d'un titre texte)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.grid_on,
                color: primaryGold,
                size: 24,
              ),
            ],
              ),
              const SizedBox(height: 16),
          // TabBar pour les 2 onglets du feed - Thème noir/doré
              Container(
                decoration: BoxDecoration(
              color: cardBgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _feedTabController,
              labelColor: primaryGold,
              unselectedLabelColor: textMuted,
              indicatorColor: primaryGold,
              indicatorWeight: 3,
              indicator: BoxDecoration(
                color: primaryGold,
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Publications'),
                Tab(text: 'Recettes'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Contenu des onglets du feed - Hauteur réduite pour voir plus de contenu
          SizedBox(
            height: 320, // Hauteur réduite pour afficher la grille de façon compacte
            child: TabBarView(
              controller: _feedTabController,
              children: [
                _buildProfilePublicationsTab(true), // Toujours dark mode
                _buildProfileRecipesTab(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Onglet Publications du profil - Format grille compact (style Instagram)
  Widget _buildProfilePublicationsTab(bool isDarkMode) {
    // Palette sombre uniforme
    const Color textMuted = Color(0xFF8B949E);
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    
    final feedNotifier = ProfileFeedNotifier();
    // Filtrer uniquement les posts sport (publications)
    final posts = feedNotifier.posts.where((p) => p.type == FeedPostType.sport).toList();

    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Aucune publication pour le moment',
            style: TextStyle(
              color: textMuted,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Grille 3 colonnes style Instagram
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1, // Carré
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildProfilePostGridItem(post);
      },
    );
  }

  /// Item de grille pour publication du profil (style Instagram)
  Widget _buildProfilePostGridItem(ProfileFeedPost post) {
    const Color cardBgLight = Color(0xFF21262D);
    const Color textMuted = Color(0xFF8B949E);
    const Color primaryGold = Color(0xFFFFC300);
    
    return GestureDetector(
      onTap: () {
        // Afficher le détail du post dans un modal
        _showPostDetail(post);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBgLight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                post.displayImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 30,
                      color: textMuted,
                    ),
                  );
                },
              ),
            ),
            // Overlay avec likes/comments au survol (optionnel)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, size: 12, color: primaryGold),
                    const SizedBox(width: 2),
                    Text(
                      '${post.likes}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  /// Afficher le détail d'un post dans un modal
  void _showPostDetail(ProfileFeedPost post) {
    const Color cardBg = Color(0xFF161B22);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color primaryGold = Color(0xFFFFC300);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de drag
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Image - Format 4:3 pour voir plus de contenu
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  child: Image.asset(
                    post.displayImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF21262D),
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Contenu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.workoutType != null) ...[
                      Text(
                        post.workoutType!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (post.caption != null) ...[
                      Text(
                        post.caption!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Date et interactions
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: textMuted),
                        const SizedBox(width: 6),
                        Text(
                          _formatPostDate(post.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.favorite_border, size: 16, color: primaryGold),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likes}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment_outlined, size: 16, color: primaryGold),
                        const SizedBox(width: 4),
                        Text(
                          '${post.comments}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Onglet Recettes du profil - Format grille compact
  Widget _buildProfileRecipesTab(bool isDarkMode) {
    const Color textMuted = Color(0xFF8B949E);
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    
    final feedNotifier = ProfileFeedNotifier();
    // Filtrer uniquement les recettes
    final recipes = feedNotifier.posts.where((p) => p.type == FeedPostType.recipe).toList();

    if (recipes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Aucune recette pour le moment',
            style: TextStyle(
              color: textMuted,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Grille 3 colonnes style Instagram
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1, // Carré
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return _buildProfileRecipeGridItem(recipes[index]);
      },
    );
  }

  /// Item de grille pour recette du profil (style Instagram)
  Widget _buildProfileRecipeGridItem(ProfileFeedPost recipe) {
    const Color cardBgLight = Color(0xFF21262D);
    const Color textMuted = Color(0xFF8B949E);
    const Color primaryGold = Color(0xFFFFC300);
    
    return GestureDetector(
      onTap: () {
        _showRecipeDetail(recipe);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBgLight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                recipe.displayImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 30,
                      color: textMuted,
                    ),
                  );
                },
              ),
            ),
            // Badge recette
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 10,
                  color: Colors.black,
                ),
              ),
            ),
            // Likes
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, size: 12, color: primaryGold),
                    const SizedBox(width: 2),
                    Text(
                      '${recipe.likes}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  /// Afficher le détail d'une recette dans un modal
  void _showRecipeDetail(ProfileFeedPost recipe) {
    const Color cardBg = Color(0xFF161B22);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color primaryGold = Color(0xFFFFC300);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de drag
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Image
              AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  recipe.displayImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF21262D),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 60,
                          color: textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Contenu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.recipeTitle != null) ...[
                      Text(
                        recipe.recipeTitle!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (recipe.caption != null) ...[
                      Text(
                        recipe.caption!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Infos nutritionnelles
                    if (recipe.calories != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${recipe.calories} kcal',
                              style: const TextStyle(
                                fontSize: 12,
                                color: primaryGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Date et interactions
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: textMuted),
                        const SizedBox(width: 6),
                        Text(
                          _formatPostDate(recipe.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.favorite_border, size: 16, color: primaryGold),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.likes}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment_outlined, size: 16, color: primaryGold),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.comments}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ancienne méthode supprimée - remplacée par _buildProfileRecipeGridItem
  Widget _buildProfileRecipeCardLegacy(ProfileFeedPost recipe, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de la recette
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 120,
                width: double.infinity,
              color: isDarkMode ? const Color(0xFF2A2A3E) : Colors.grey.shade200,
              child: Image.asset(
                recipe.displayImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                    ),
                  );
                },
                    ),
                  ),
                ),
          // Contenu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeTitle ?? 'Recette',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (recipe.caption != null) ...[
                    Text(
                      recipe.caption!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (recipe.calories != null) ...[
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 14, color: isDarkMode ? Colors.white54 : Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.calories} kcal',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 14, color: isDarkMode ? Colors.white54 : Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.likes}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPostDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ─────────────────────────────────────────────
// Widgets réutilisables ProfilePage
// ─────────────────────────────────────────────

class _ProfileSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;

  const _ProfileSectionCard({
    required this.title,
    this.subtitle,
    required this.child,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (iconColor ?? const Color(0xFFFFB366)).withOpacity(0.2), // Orange pastel
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? const Color(0xFFFFB366), // Orange pastel
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String text;

  const _SmallChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BetaChip extends StatelessWidget {
  const _BetaChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4CC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'BÊTA',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _ProfileFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ProfileFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFFC300), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else
              const Icon(Icons.chevron_right, size: 20, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiLine;
  final bool isDarkMode;

  const _InfoItem({
    required this.label,
    required this.value,
    this.isMultiLine = false,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Palette sombre
    const Color cardBgLight = Color(0xFF21262D);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? cardBgLight : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? textMuted : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isMultiLine ? 13 : 15,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? textLight : Colors.black87,
              height: isMultiLine ? 1.4 : 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Page détaillée d’une séance
// ─────────────────────────────────────────────

class WorkoutDetailPage extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailPage({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final chips = [
      workout.difficulty,
      '${workout.sessionsPerWeek} séances / semaine',
      '${workout.durationMinutes} min',
      workout.objective,
    ];

    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode 
          ? const Color(0xFF0A0E27) // Noir pour mode nuit
          : const Color(0xFFFFF9E6), // Jaune très clair pour mode jour
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB366), // Orange pastel au lieu de noir
        foregroundColor: Colors.white,
        title: const Text('Détail de la séance'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map(
                      (c) => Chip(
                        label: Text(c),
                        backgroundColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.local_fire_department_outlined,
                label: 'Calories estimées',
                value: '${workout.calories} kcal',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.directions_walk_outlined,
                label: 'Pas à viser dans la journée',
                value: '${workout.steps} pas',
              ),
              const SizedBox(height: 16),
              const Text(
                'Matériel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                workout.equipment,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Plan de séance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const _WorkoutStepCard(
                title: 'Échauffement',
                subtitle: '5–7 minutes de cardio léger + mobilité',
                imageAsset: 'assets/images/exercises/warmup.jpg',
                videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
              ),
              const SizedBox(height: 8),
              const _WorkoutStepCard(
                title: 'Bloc 1',
                subtitle: 'Squats, fentes, gainage • 3 séries',
                imageAsset: 'assets/images/exercises/squats.jpg',
                videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
              ),
              const SizedBox(height: 8),
              const _WorkoutStepCard(
                title: 'Bloc 2',
                subtitle: 'Pompes, rowing, planche • 3 séries',
                imageAsset: 'assets/images/exercises/pushups.jpg',
                videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
              ),
              const SizedBox(height: 8),
              const _WorkoutStepCard(
                title: 'Retour au calme',
                subtitle: 'Étirements + respiration • 5 minutes',
                imageAsset: 'assets/images/exercises/stretch.jpg',
              ),
              const SizedBox(height: 24),
              const Text(
                'Conseils du coach',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reste à un niveau d’effort où tu peux encore parler. '
                'Bois régulièrement, et adapte l’intensité si tu es fatigué(e).',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Créer la liste des étapes de séance basée sur le plan
                    final steps = [
                      const WorkoutStep(
                        id: 'warmup',
                        title: 'Échauffement',
                        description: '5–7 minutes de cardio léger + mobilité',
                        durationSeconds: 300, // 5 minutes
                        restSeconds: 30,
                        imageAsset: 'assets/images/exercises/warmup.jpg',
                        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                      ),
                      const WorkoutStep(
                        id: 'bloc1',
                        title: 'Bloc 1',
                        description: 'Squats, fentes, gainage • 3 séries',
                        durationSeconds: 600, // 10 minutes
                        restSeconds: 60,
                        imageAsset: 'assets/images/exercises/squats.jpg',
                        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                      ),
                      const WorkoutStep(
                        id: 'bloc2',
                        title: 'Bloc 2',
                        description: 'Pompes, rowing, planche • 3 séries',
                        durationSeconds: 600, // 10 minutes
                        restSeconds: 60,
                        imageAsset: 'assets/images/exercises/pushups.jpg',
                        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                      ),
                      const WorkoutStep(
                        id: 'cooldown',
                        title: 'Retour au calme',
                        description: 'Étirements + respiration • 5 minutes',
                        durationSeconds: 300, // 5 minutes
                        restSeconds: null,
                        imageAsset: 'assets/images/exercises/stretch.jpg',
                      ),
                    ];

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WorkoutSessionPage(
                          workoutTitle: workout.title,
                          steps: steps,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB366), // Orange pastel
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Démarrer la séance',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _WorkoutStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageAsset;
  final String? videoUrl;

  const _WorkoutStepCard({
    required this.title,
    required this.subtitle,
    this.imageAsset,
    this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedia = imageAsset != null || videoUrl != null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image ou vidéo si disponible
          if (hasMedia)
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                image: imageAsset != null
                    ? DecorationImage(
                        image: AssetImage(imageAsset!),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: imageAsset == null
                  ? Center(
                      child: Icon(
                        videoUrl != null
                            ? Icons.play_circle_filled_rounded
                            : Icons.fitness_center_rounded,
                        color: const Color(0xFFFFC300),
                        size: 32,
                      ),
                    )
                  : videoUrl != null
                      ? Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const Center(
                              child: Icon(
                                Icons.play_circle_filled_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        )
                      : null,
            )
          else
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFFFFC300),
              size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                      ),
                    ),
                    if (videoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.video_library_rounded,
                              size: 14,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Vidéo',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Outils personnels & coach
// ─────────────────────────────────────────────

class PersonalToolsSection extends StatelessWidget {
  const PersonalToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: 'Outils personnels & coach',
      subtitle: 'Fonctionnalités pour t\'accompagner au quotidien.',
      child: Column(
        children: [
          _ProfileFeatureTile(
            icon: Icons.auto_awesome,
            title: 'Coach Alter Ego Futur (démo)',
            subtitle: 'Projection de ton moi futur.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FutureSelfAdvancedPage(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.psychology_alt_outlined,
            title: 'Mon Alter Ego (v1)',
            subtitle: 'Version futuriste simple (démo).',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AlterEgoScreen(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.forum_outlined,
            title: 'Chat d\'entraide communautaire',
            subtitle: 'Discussions entre membres sur nutrition et entraînement.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CommunityChatPage(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.search,
            title: 'Trouver un coach',
            subtitle: 'Découvrir des coachs adaptés à tes objectifs.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CoachDirectoryPage(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.monitor_weight_outlined,
            title: 'Analyse corporelle avancée',
            subtitle: 'Suivi détaillé de la composition corporelle (à venir).',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BodyCompositionPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Nouveaux modules
// ─────────────────────────────────────────────

class NewModulesSection extends StatelessWidget {
  final String profileName;
  final String profileGoal;

  const NewModulesSection({
    super.key,
    required this.profileName,
    required this.profileGoal,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: 'Nouveaux modules',
      subtitle: 'Fonctionnalités en version démo / bêta, pour tester tranquillement.',
      child: Column(
        children: [
          _ProfileFeatureTile(
            icon: Icons.favorite_border,
            title: 'Chat Match™',
            subtitle: 'Trouve des partenaires sportifs compatibles.',
            trailing: const _BetaChip(),
            onTap: () {
              // Initialiser le profil utilisateur pour le matching
              final matchEngine = MatchEngine();
              matchEngine.setCurrentUserProfile(
                MatchProfile(
                  id: 'current_user',
                  name: profileName,
                  age: 25, // À récupérer du profil
                  level: 'Intermédiaire',
                  goals: [profileGoal],
                  availability: 'Flexible',
                  city: 'Paris',
                  distance: 0,
                  sportPreferences: {},
                  sportCharacter: 'Motivé',
                  compatibilityScore: 0,
                  createdAt: DateTime.now(),
                ),
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MatchHomePage(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.videocam_outlined,
            title: 'S\'entraîner avec des amis',
            subtitle: 'Visio training en live avec tes buddies.',
            trailing: const _BetaChip(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BuddyHomePage(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.store_mall_directory_outlined,
            title: 'Coach Business Pack™',
            subtitle: 'Vendre ses programmes',
            trailing: const _BetaChip(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CoachBusinessDashboard(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.videogame_asset_outlined,
            title: 'Sport Gaming Story™',
            subtitle: 'Le sport comme un jeu',
            trailing: const _BetaChip(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StoryHomePage(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.military_tech_outlined,
            title: 'Coach VS Coach™',
            subtitle: 'Classement des coachs',
            trailing: const _BetaChip(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CoachRankingPage(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.visibility_outlined,
            title: 'Transformation Projection™',
            subtitle: 'Toi en version future',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RAFuturePreviewPage(),
                ),
              );
            },
          ),
          _ProfileFeatureTile(
            icon: Icons.psychology_alt_outlined,
            title: 'Coach Personnalité™',
            subtitle: 'Coach gentil / dur / fun',
            trailing: const _BetaChip(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CoachStylePickerPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget pour afficher une carte d'accès aux données du coach
class _MyCoachDataCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MyCoachDataCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
