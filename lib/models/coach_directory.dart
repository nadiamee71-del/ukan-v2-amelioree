import 'package:flutter/foundation.dart';

/// ─────────────────────────────────────────────
/// Modèle de profil coach
/// ─────────────────────────────────────────────

class CoachProgram {
  final String id;
  final String title;
  final String description;
  final double price;
  final int durationWeeks;
  final String level;
  final String? heroImage; // Image pour le header/hero (différente des images du programme)
  final List<String> images; // Images du programme (galerie)
  final List<String> videos; // Vidéos du programme (URLs ou chemins)
  final List<ProgramInstruction> instructions; // Instructions détaillées
  final String? coachId; // ID du coach qui propose le programme

  CoachProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.durationWeeks,
    required this.level,
    this.heroImage,
    this.images = const [],
    this.videos = const [],
    this.instructions = const [],
    this.coachId,
  });
}

class ProgramInstruction {
  final String id;
  final String title;
  final String description;
  final int? weekNumber; // Semaine du programme
  final int? dayNumber; // Jour de la semaine
  final List<String> steps; // Étapes détaillées
  final List<String> tips; // Conseils
  final String? videoUrl; // Vidéo associée (optionnel)

  ProgramInstruction({
    required this.id,
    required this.title,
    required this.description,
    this.weekNumber,
    this.dayNumber,
    this.steps = const [],
    this.tips = const [],
    this.videoUrl,
  });
}

class CoachProfile {
  final String id;
  final String name;
  final String specialty;
  final String city;
  final String level; // Débutant, Intermédiaire, Avancé
  final double rating; // 0.0 à 5.0
  final bool isCertified;
  final String bio; // Bio complète pour la page détail
  final List<String> certifications; // Liste des certifications
  final bool isOnline; // Statut de connexion (actif/inactif)
  final String? photoUrl; // Photo du coach
  final List<String> coachingPhotos; // Photos de coaching
  final List<String> beforeAfterPhotos; // Photos avant/après
  final List<String> detailedSpecialties; // Spécialités détaillées
  final List<CoachProgram> programs; // Programmes d'exercices avec tarifs

  CoachProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.city,
    required this.level,
    required this.rating,
    required this.isCertified,
    required this.bio,
    required this.certifications,
    this.isOnline = false,
    this.photoUrl,
    this.coachingPhotos = const [],
    this.beforeAfterPhotos = const [],
    this.detailedSpecialties = const [],
    this.programs = const [],
  });
}

/// ─────────────────────────────────────────────
/// Notifier pour le répertoire des coachs
/// ─────────────────────────────────────────────

class CoachDirectoryNotifier extends ChangeNotifier {
  static final CoachDirectoryNotifier _instance = CoachDirectoryNotifier._internal();
  factory CoachDirectoryNotifier() => _instance;
  CoachDirectoryNotifier._internal() {
    _initDemo();
  }

  final List<CoachProfile> _coaches = [];
  String _searchQuery = '';
  String? _filterCity;
  String? _filterSpecialty;

  void _initDemo() {
    _coaches.addAll([
      CoachProfile(
        id: 'coach_1',
        name: 'Sophie Martin',
        specialty: 'Perte de poids',
        city: 'Paris',
        level: 'Avancé',
        rating: 4.8,
        isCertified: true,
        isOnline: true,
        photoUrl: 'assets/images/coach_1_header.png', // Image pour le header du profil coach
        bio: 'Coach sportive depuis 10 ans, spécialisée en perte de poids et remise en forme. J\'aide mes clients à atteindre leurs objectifs grâce à des programmes personnalisés et un suivi régulier.',
        certifications: ['BPJEPS AF', 'Diplôme nutrition sportive', 'Certification coach sportif IFBB'],
        detailedSpecialties: [
          'Perte de poids personnalisée',
          'Nutrition sportive',
          'Remise en forme',
          'Coaching en ligne',
        ],
        coachingPhotos: ['assets/images/coach_photo_1.jpg', 'assets/images/coach_photo_2.jpg'],
        beforeAfterPhotos: ['assets/images/before_after_1.png', 'assets/images/before_after_2.png'],
        programs: [
          CoachProgram(
            id: 'prog_1',
            title: 'Programme Perte de Poids 3 mois',
            description: 'Programme complet avec suivi nutritionnel et séances personnalisées',
            price: 299.0,
            durationWeeks: 12,
            level: 'Tous niveaux',
            coachId: 'coach_1',
            heroImage: 'assets/images/program_1_hero.png', // Image pour le header en haut
            images: ['assets/images/program_1_image_1.png', 'assets/images/program_1_image_2.png'],
            videos: ['assets/videos/program_1_intro.mp4'],
            instructions: [
              ProgramInstruction(
                id: 'inst_1',
                title: 'Semaine 1 - Démarrage',
                description: 'Première semaine pour prendre de bonnes habitudes',
                weekNumber: 1,
                steps: [
                  'Échauffement : 5 minutes de marche rapide',
                  'Circuit training : 3 séries de 10 répétitions',
                  'Cardio : 20 minutes de course modérée',
                  'Étirements : 10 minutes',
                ],
                tips: [
                  'Hydratez-vous bien avant et pendant l\'exercice',
                  'Mangez léger 2 heures avant la séance',
                  'Reposez-vous au moins 1 jour entre les séances',
                ],
              ),
              ProgramInstruction(
                id: 'inst_2',
                title: 'Semaine 2 - Intensification',
                description: 'Augmentation progressive de l\'intensité',
                weekNumber: 2,
                steps: [
                  'Échauffement : 7 minutes',
                  'Circuit training : 4 séries de 12 répétitions',
                  'Cardio : 25 minutes',
                  'Renforcement : 15 minutes',
                ],
                tips: [
                  'Augmentez progressivement l\'intensité',
                  'Notez vos progrès quotidiennement',
                ],
              ),
            ],
          ),
          CoachProgram(
            id: 'prog_2',
            title: 'Coaching Intensif 1 mois',
            description: 'Programme intensif pour résultats rapides',
            price: 149.0,
            durationWeeks: 4,
            level: 'Intermédiaire',
            coachId: 'coach_1',
            images: ['assets/images/program_2_image_1.jpg'],
            videos: ['assets/videos/program_2_intro.mp4'],
            instructions: [
              ProgramInstruction(
                id: 'inst_3',
                title: 'Semaine 1 - Phase intensive',
                description: 'Démarrage intensif du programme',
                weekNumber: 1,
                steps: [
                  'Échauffement dynamique : 10 minutes',
                  'HIIT : 4 séries de 30 secondes',
                  'Renforcement musculaire : 20 minutes',
                ],
                tips: [
                  'Respectez les temps de repos',
                  'Écoutez votre corps',
                ],
              ),
            ],
          ),
        ],
      ),
      CoachProfile(
        id: 'coach_2',
        name: 'Marc Dubois',
        specialty: 'Prise de masse',
        city: 'Lyon',
        level: 'Avancé',
        rating: 4.9,
        isCertified: true,
        isOnline: false,
        bio: 'Coach en musculation et prise de masse depuis 8 ans. Ancien compétiteur, je transmets mon expérience pour t\'aider à construire le corps de tes rêves.',
        certifications: ['BPJEPS Musculation', 'Certification nutrition', 'IFBB Pro'],
        detailedSpecialties: [
          'Prise de masse musculaire',
          'Bodybuilding',
          'Nutrition pour la musculation',
        ],
        coachingPhotos: ['assets/images/coach_photo_3.jpg'],
        beforeAfterPhotos: ['assets/images/before_after_3.png'],
        programs: [
          CoachProgram(
            id: 'prog_3',
            title: 'Programme Prise de Masse 6 mois',
            description: 'Programme complet avec plan nutritionnel détaillé',
            price: 499.0,
            durationWeeks: 24,
            level: 'Avancé',
            coachId: 'coach_2',
            images: ['assets/images/program_3_image_1.jpg'],
            videos: ['assets/videos/program_3_intro.mp4'],
            instructions: [
              ProgramInstruction(
                id: 'inst_4',
                title: 'Semaine 1 - Fondations',
                description: 'Mise en place des bases du programme',
                weekNumber: 1,
                steps: [
                  'Échauffement : 10 minutes',
                  'Musculation : 5 exercices de base',
                  'Nutrition : Plan alimentaire détaillé',
                ],
                tips: [
                  'Augmentez progressivement les charges',
                  'Respectez les temps de repos',
                ],
              ),
            ],
          ),
        ],
      ),
      CoachProfile(
        id: 'coach_3',
        name: 'Léa Bernard',
        specialty: 'Yoga & Mobilité',
        city: 'Marseille',
        level: 'Intermédiaire',
        rating: 4.6,
        isCertified: false,
        isOnline: true,
        bio: 'Professeure de yoga certifiée, je combine postures, respiration et méditation pour t\'aider à améliorer ta mobilité et ton bien-être global.',
        certifications: ['Certification Yoga Alliance'],
        detailedSpecialties: [
          'Hatha Yoga',
          'Vinyasa Flow',
          'Mobilité fonctionnelle',
        ],
        programs: [
          CoachProgram(
            id: 'prog_4',
            title: 'Cours de Yoga en ligne',
            description: 'Cours de yoga personnalisés par visioconférence',
            price: 79.0,
            durationWeeks: 8,
            level: 'Débutant',
            coachId: 'coach_3',
            images: ['assets/images/program_4_image_1.jpg'],
            videos: ['assets/videos/program_4_intro.mp4'],
            instructions: [
              ProgramInstruction(
                id: 'inst_5',
                title: 'Semaine 1 - Introduction au Yoga',
                description: 'Découvrez les bases du yoga',
                weekNumber: 1,
                steps: [
                  'Échauffement respiratoire : 5 minutes',
                  'Postures de base : 10 postures',
                  'Méditation : 10 minutes',
                ],
                tips: [
                  'Pratiquez dans un espace calme',
                  'Respirez profondément',
                ],
              ),
            ],
          ),
        ],
      ),
      CoachProfile(
        id: 'coach_4',
        name: 'Thomas Leroy',
        specialty: 'Cardio & Endurance',
        city: 'Paris',
        level: 'Avancé',
        rating: 4.7,
        isCertified: true,
        isOnline: true,
        bio: 'Coach running et triathlon, j\'aide les sportifs à améliorer leur endurance et leurs performances. Des programmes adaptés pour tous les niveaux.',
        certifications: ['BPJEPS AF', 'Certification triathlon'],
        detailedSpecialties: [
          'Running',
          'Triathlon',
          'Endurance',
        ],
        programs: [
          CoachProgram(
            id: 'prog_5',
            title: 'Préparation Marathon',
            description: 'Programme complet de préparation marathon',
            price: 199.0,
            durationWeeks: 16,
            level: 'Intermédiaire',
            coachId: 'coach_4',
            images: ['assets/images/program_5_image_1.jpg'],
            videos: ['assets/videos/program_5_intro.mp4'],
            instructions: [
              ProgramInstruction(
                id: 'inst_6',
                title: 'Semaine 1 - Endurance de base',
                description: 'Construire une base d\'endurance solide',
                weekNumber: 1,
                steps: [
                  'Course lente : 30 minutes',
                  'Renforcement : 15 minutes',
                  'Étirements : 10 minutes',
                ],
                tips: [
                  'Augmentez la distance progressivement',
                  'Hydratez-vous régulièrement',
                ],
              ),
            ],
          ),
        ],
      ),
      CoachProfile(
        id: 'coach_5',
        name: 'Julie Moreau',
        specialty: 'Remise en forme',
        city: 'Nice',
        level: 'Intermédiaire',
        rating: 4.5,
        isCertified: false,
        isOnline: false,
        bio: 'Coach bienveillante spécialisée en remise en forme douce. J\'accompagne les personnes qui reprennent le sport après une pause ou qui débutent.',
        certifications: ['BPJEPS AF'],
        detailedSpecialties: [
          'Remise en forme douce',
          'Gym douce',
        ],
        programs: [
          CoachProgram(
            id: 'prog_6',
            title: 'Débutant - Programme Doux',
            description: 'Programme adapté pour débuter ou reprendre le sport',
            price: 99.0,
            durationWeeks: 8,
            level: 'Débutant',
            coachId: 'coach_5',
            images: ['assets/images/program_6_image_1.jpg'],
            videos: ['assets/videos/program_6_intro.mp4'],
            instructions: [
              ProgramInstruction(
                id: 'inst_7',
                title: 'Semaine 1 - Découverte',
                description: 'Premier pas vers une vie active',
                weekNumber: 1,
                steps: [
                  'Marche : 20 minutes',
                  'Exercices au sol : 10 minutes',
                  'Étirements doux : 5 minutes',
                ],
                tips: [
                  'Allez-y doucement',
                  'Écoutez votre corps',
                ],
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  List<CoachProfile> get coaches {
    var filtered = List<CoachProfile>.from(_coaches);

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((coach) {
        return coach.name.toLowerCase().contains(query) ||
            coach.specialty.toLowerCase().contains(query);
      }).toList();
    }

    // Filtre par ville
    if (_filterCity != null && _filterCity!.isNotEmpty) {
      filtered = filtered.where((coach) => coach.city == _filterCity).toList();
    }

    // Filtre par spécialité
    if (_filterSpecialty != null && _filterSpecialty!.isNotEmpty) {
      filtered = filtered.where((coach) => coach.specialty == _filterSpecialty).toList();
    }

    return filtered;
  }

  List<String> get availableCities {
    final cities = _coaches.map((c) => c.city).toSet().toList();
    cities.sort();
    return cities;
  }

  List<String> get availableSpecialties {
    final specialties = _coaches.map((c) => c.specialty).toSet().toList();
    specialties.sort();
    return specialties;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCity(String? city) {
    _filterCity = city;
    notifyListeners();
  }

  void setFilterSpecialty(String? specialty) {
    _filterSpecialty = specialty;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCity = null;
    _filterSpecialty = null;
    notifyListeners();
  }

  String? get filterCity => _filterCity;
  String? get filterSpecialty => _filterSpecialty;

  CoachProfile? getCoachById(String id) {
    try {
      return _coaches.firstWhere((coach) => coach.id == id);
    } catch (e) {
      return null;
    }
  }
}

