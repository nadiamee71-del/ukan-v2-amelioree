import 'package:flutter/foundation.dart';
import 'user_profile.dart';

/// Profil utilisateur public (pour la recherche)
class PublicUserProfile {
  final String id;
  final String name;
  final String email;
  final String level; // Niveau : Débutant, Intermédiaire, Avancé
  final String? city;
  final String? photoUrl;
  final String mainGoal;
  final bool isCoach; // Si l'utilisateur est aussi coach
  final String? coachId; // ID du coach si isCoach = true

  PublicUserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    this.city,
    this.photoUrl,
    required this.mainGoal,
    this.isCoach = false,
    this.coachId,
  });
}

/// Notifier pour gérer le répertoire des utilisateurs
class UserDirectoryNotifier extends ChangeNotifier {
  static final UserDirectoryNotifier _instance = UserDirectoryNotifier._internal();
  factory UserDirectoryNotifier() => _instance;
  UserDirectoryNotifier._internal() {
    _initDemo();
  }

  final List<PublicUserProfile> _users = [];
  String _searchQuery = '';

  List<PublicUserProfile> get users => _users;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  /// Recherche les utilisateurs selon la requête
  List<PublicUserProfile> searchUsers(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
             user.email.toLowerCase().contains(lowerQuery) ||
             user.mainGoal.toLowerCase().contains(lowerQuery) ||
             (user.city != null && user.city!.toLowerCase().contains(lowerQuery)) ||
             user.level.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Récupère un utilisateur par son ID
  PublicUserProfile? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  void _initDemo() {
    _users.addAll([
      PublicUserProfile(
        id: 'user_1',
        name: 'Marie Dubois',
        email: 'marie.dubois@mail.com',
        level: 'Débutant',
        city: 'Lyon',
        mainGoal: 'Perte de poids',
        isCoach: false,
      ),
      PublicUserProfile(
        id: 'user_2',
        name: 'Thomas Bernard',
        email: 'thomas.bernard@mail.com',
        level: 'Intermédiaire',
        city: 'Marseille',
        mainGoal: 'Prise de masse',
        isCoach: false,
      ),
      PublicUserProfile(
        id: 'user_3',
        name: 'Julie Martin',
        email: 'julie.martin@mail.com',
        level: 'Avancé',
        city: 'Paris',
        mainGoal: 'Endurance',
        isCoach: true,
        coachId: 'coach_1', // Sophie Martin est aussi coach
      ),
      PublicUserProfile(
        id: 'user_4',
        name: 'Lucas Petit',
        email: 'lucas.petit@mail.com',
        level: 'Débutant',
        city: 'Toulouse',
        mainGoal: 'Remise en forme',
        isCoach: false,
      ),
      PublicUserProfile(
        id: 'user_5',
        name: 'Emma Rousseau',
        email: 'emma.rousseau@mail.com',
        level: 'Intermédiaire',
        city: 'Nice',
        mainGoal: 'Renforcement musculaire',
        isCoach: false,
      ),
      PublicUserProfile(
        id: 'user_6',
        name: 'Pierre Moreau',
        email: 'pierre.moreau@mail.com',
        level: 'Avancé',
        city: 'Bordeaux',
        mainGoal: 'Performance sportive',
        isCoach: true,
        coachId: 'coach_2',
      ),
      PublicUserProfile(
        id: 'user_7',
        name: 'Sophie Martin',
        email: 'sophie.martin@mail.com',
        level: 'Avancé',
        city: 'Paris',
        mainGoal: 'Perte de poids',
        isCoach: true,
        coachId: 'coach_1', // C'est aussi le coach Sophie Martin
      ),
      PublicUserProfile(
        id: 'user_8',
        name: 'Alexandre Durand',
        email: 'alexandre.durand@mail.com',
        level: 'Intermédiaire',
        city: 'Lille',
        mainGoal: 'Musculation',
        isCoach: false,
      ),
    ]);
  }
}















