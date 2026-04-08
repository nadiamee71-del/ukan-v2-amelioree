import 'package:flutter/foundation.dart';

/// Modèle de profil utilisateur (client)
class UserProfile {
  final String name;
  final String email;
  final String level; // Niveau : Débutant, Intermédiaire, Avancé
  final int sessionsPerWeek;
  
  // Infos physiques
  final int? height; // en cm
  final double? currentWeight; // en kg
  final double? targetWeight; // en kg
  final double? waist; // Taille en cm
  final double? hips; // Hanches en cm
  final double? chest; // Poitrine en cm
  
  // Objectifs
  final String mainGoal; // Objectif principal
  final String secondaryGoals; // Objectifs secondaires (texte libre)
  final String deadline; // Date d'échéance (texte pour l'instant)
  
  // Objectifs hebdomadaires
  final int caloriesGoalPerDay; // Calories à brûler par jour (kcal)
  final int stepsGoalPerDay; // Pas à atteindre par jour
  final double distanceGoalPerWeek; // Distance à parcourir par semaine (km)
  final double waterGoalLiters; // Hydratation par jour (L)
  final double sleepGoalHours; // Sommeil par nuit (h)
  final int proteinGoalGrams; // Protéines par jour (g)
  
  // À propos de moi
  final String activityLevel; // Faible, Moyen, Élevé
  final String trainingLocation; // Maison, Salle de sport, Extérieur
  final String dietType; // Équilibrée, Végétarien, Protéinée, Vegan, etc.
  final double usualSleepHours; // Heures de sommeil habituelles
  final String mainMotivation; // Motivation principale (texte libre)

  const UserProfile({
    required this.name,
    required this.email,
    required this.level,
    required this.sessionsPerWeek,
    this.height,
    this.currentWeight,
    this.targetWeight,
    this.waist,
    this.hips,
    this.chest,
    required this.mainGoal,
    this.secondaryGoals = '',
    this.deadline = '',
    this.caloriesGoalPerDay = 2000,
    this.stepsGoalPerDay = 8000,
    this.distanceGoalPerWeek = 20.0,
    this.waterGoalLiters = 2.0,
    this.sleepGoalHours = 7.0,
    this.proteinGoalGrams = 120,
    this.activityLevel = 'Moyen',
    this.trainingLocation = 'Maison',
    this.dietType = 'Équilibrée',
    this.usualSleepHours = 7.0,
    this.mainMotivation = '',
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? level,
    int? sessionsPerWeek,
    int? height,
    double? currentWeight,
    double? targetWeight,
    double? waist,
    double? hips,
    double? chest,
    String? mainGoal,
    String? secondaryGoals,
    String? deadline,
    int? caloriesGoalPerDay,
    int? stepsGoalPerDay,
    double? distanceGoalPerWeek,
    double? waterGoalLiters,
    double? sleepGoalHours,
    int? proteinGoalGrams,
    String? activityLevel,
    String? trainingLocation,
    String? dietType,
    double? usualSleepHours,
    String? mainMotivation,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      chest: chest ?? this.chest,
      mainGoal: mainGoal ?? this.mainGoal,
      secondaryGoals: secondaryGoals ?? this.secondaryGoals,
      deadline: deadline ?? this.deadline,
      caloriesGoalPerDay: caloriesGoalPerDay ?? this.caloriesGoalPerDay,
      stepsGoalPerDay: stepsGoalPerDay ?? this.stepsGoalPerDay,
      distanceGoalPerWeek: distanceGoalPerWeek ?? this.distanceGoalPerWeek,
      waterGoalLiters: waterGoalLiters ?? this.waterGoalLiters,
      sleepGoalHours: sleepGoalHours ?? this.sleepGoalHours,
      proteinGoalGrams: proteinGoalGrams ?? this.proteinGoalGrams,
      activityLevel: activityLevel ?? this.activityLevel,
      trainingLocation: trainingLocation ?? this.trainingLocation,
      dietType: dietType ?? this.dietType,
      usualSleepHours: usualSleepHours ?? this.usualSleepHours,
      mainMotivation: mainMotivation ?? this.mainMotivation,
    );
  }
}

/// Notifier pour gérer le profil utilisateur en mémoire
class UserProfileNotifier extends ChangeNotifier {
  static final UserProfileNotifier _instance = UserProfileNotifier._internal();
  factory UserProfileNotifier() => _instance;
  UserProfileNotifier._internal();

  UserProfile _profile = const UserProfile(
    name: 'Alex Ukan',
    email: 'toi@mail.com',
    level: 'Intermédiaire',
    sessionsPerWeek: 4,
    height: 175,
    currentWeight: 72.5,
    targetWeight: 68.0,
    waist: 85,
    hips: 95,
    chest: 100,
    mainGoal: 'Perte de poids',
    secondaryGoals: 'Renforcement musculaire\nAmélioration de l\'endurance',
    deadline: 'Juin 2026',
    caloriesGoalPerDay: 2200,
    stepsGoalPerDay: 10000,
    distanceGoalPerWeek: 25.0,
    waterGoalLiters: 2.5,
    sleepGoalHours: 7.5,
    proteinGoalGrams: 116,
    activityLevel: 'Moyen',
    trainingLocation: 'Maison',
    dietType: 'Équilibrée',
    usualSleepHours: 7.0,
    mainMotivation: 'Perdre du ventre et reprendre confiance',
  );

  UserProfile get profile => _profile;

  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }
}










