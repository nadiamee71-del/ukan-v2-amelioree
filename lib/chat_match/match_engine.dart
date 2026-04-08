import 'package:flutter/foundation.dart';
import 'match_profile.dart';
import 'match_filters.dart';
import 'match_compatibility.dart';

/// ─────────────────────────────────────────────
/// Moteur de matching pour Buddy Workout
/// ─────────────────────────────────────────────

class MatchEngine extends ChangeNotifier {
  static final MatchEngine _instance = MatchEngine._internal();
  factory MatchEngine() => _instance;
  MatchEngine._internal() {
    _initDemoProfiles();
  }

  final List<MatchProfile> _allProfiles = [];
  final List<String> _likedProfiles = [];
  final List<String> _matchedProfiles = [];
  MatchFilters _filters = MatchFilters();
  MatchProfile? _currentUserProfile;

  void _initDemoProfiles() {
    // Profils sportifs de démo complets pour le matching
    _allProfiles.addAll([
      MatchProfile(
        id: 'match_1',
        name: 'Lucas',
        age: 28,
        level: 'Intermédiaire',
        goals: ['Prise de masse', 'Force', 'Musculation'],
        availability: 'Soir',
        city: 'Paris 15e',
        distance: 3.2,
        sportPreferences: {'musculation': true, 'hiit': true, 'running': true},
        sportCharacter: 'Très motivé',
        compatibilityScore: 0,
        createdAt: DateTime.now(),
        equipment: ['Haltères', 'Banc', 'Élastiques', 'Barre de traction'],
        motivation: 'Très motivé',
        trainingFrequency: '4-5x/semaine',
        bio: 'Passionné de muscu depuis 3 ans. Je cherche un partenaire pour me motiver et progresser ensemble. Dispo en semaine après 18h.',
        gender: 'Homme',
      ),
      MatchProfile(
        id: 'match_2',
        name: 'Marie',
        age: 32,
        level: 'Confirmé',
        goals: ['Endurance', 'Cardio', 'Bien-être'],
        availability: 'Matin',
        city: 'Paris 14e',
        distance: 1.8,
        sportPreferences: {'running': true, 'yoga': true, 'natation': true},
        sportCharacter: 'Motivé',
        compatibilityScore: 0,
        createdAt: DateTime.now(),
        equipment: ['Tapis', 'Corde à sauter', 'Élastiques'],
        motivation: 'Motivé',
        trainingFrequency: '4-5x/semaine',
        bio: 'Coureuse passionnée, je recherche un buddy pour des runs matinaux et du yoga relaxant.',
        gender: 'Femme',
      ),
      MatchProfile(
        id: 'match_3',
        name: 'Thomas',
        age: 25,
        level: 'Débutant',
        goals: ['Remise en forme', 'Perte de poids', 'Cardio'],
        availability: 'Flexible',
        city: 'Paris 11e',
        distance: 4.5,
        sportPreferences: {'fitness': true, 'running': true, 'hiit': true},
        sportCharacter: 'Motivé',
        compatibilityScore: 0,
        createdAt: DateTime.now(),
        equipment: ['Tapis', 'Haltères'],
        motivation: 'Motivé',
        trainingFrequency: '2-3x/semaine',
        bio: 'Je débute dans le sport et j\'ai besoin d\'un partenaire pour me motiver !',
        gender: 'Homme',
      ),
      MatchProfile(
        id: 'match_4',
        name: 'Sophie',
        age: 29,
        level: 'Intermédiaire',
        goals: ['Tonification', 'Bien-être', 'Cardio'],
        availability: 'Soir',
        city: 'Paris 16e',
        distance: 2.1,
        sportPreferences: {'pilates': true, 'yoga': true, 'dance': true},
        sportCharacter: 'Détendu',
        compatibilityScore: 0,
        createdAt: DateTime.now(),
        equipment: ['Tapis', 'Élastiques', 'Ballon de gym'],
        motivation: 'Détendu',
        trainingFrequency: '2-3x/semaine',
        bio: 'Fan de Pilates et yoga, je cherche une partenaire pour des séances zen.',
        gender: 'Femme',
      ),
      MatchProfile(
        id: 'match_5',
        name: 'Alex',
        age: 27,
        level: 'Expert',
        goals: ['Performance', 'Force', 'Compétition'],
        availability: 'Matin',
        city: 'Paris 8e',
        distance: 5.0,
        sportPreferences: {'crossfit': true, 'musculation': true, 'powerlifting': true},
        sportCharacter: 'Compétiteur',
        compatibilityScore: 0,
        createdAt: DateTime.now(),
        equipment: ['Haltères', 'Barre', 'Banc', 'Kettlebell', 'Rameur'],
        motivation: 'Compétiteur',
        trainingFrequency: 'Tous les jours',
        bio: 'Athlète CrossFit, je cherche un partenaire de niveau pour des WODs intenses.',
        gender: 'Homme',
      ),
      MatchProfile(
        id: 'match_6',
        name: 'Emma',
        age: 26,
        level: 'Intermédiaire',
        goals: ['Cardio', 'Endurance', 'Perte de poids'],
        availability: 'Soir',
        city: 'Paris 12e',
        distance: 1.5,
        sportPreferences: {'running': true, 'hiit': true, 'natation': true},
        sportCharacter: 'Motivé',
        compatibilityScore: 0,
        createdAt: DateTime.now(),
        equipment: ['Corde à sauter', 'Tapis', 'Élastiques'],
        motivation: 'Très motivé',
        trainingFrequency: '4-5x/semaine',
        bio: 'Sportive régulière, je cherche un(e) partenaire pour courir et faire du HIIT ensemble.',
        gender: 'Femme',
      ),
      MatchProfile(
        id: 'match_7',
        name: 'Julien',
        age: 31,
        level: 'Confirmé',
        goals: ['Prise de masse', 'Force', 'Performance'],
        availability: 'Après-midi',
        city: 'Paris 17e',
        distance: 3.8,
        sportPreferences: {'musculation': true, 'powerlifting': true, 'crossfit': true},
        sportCharacter: 'Très motivé',
        compatibilityScore: 0,
        createdAt: DateTime.now(),
        equipment: ['Haltères', 'Barre', 'Banc', 'Barre de traction', 'Kettlebell'],
        motivation: 'Compétiteur',
        trainingFrequency: 'Tous les jours',
        bio: 'Coach sportif de formation, je cherche un buddy sérieux pour des séances intenses.',
        gender: 'Homme',
      ),
      MatchProfile(
        id: 'match_8',
        name: 'Léa',
        age: 24,
        level: 'Débutant',
        goals: ['Remise en forme', 'Tonification', 'Bien-être'],
        availability: 'Week-end',
        city: 'Paris 20e',
        distance: 4.2,
        sportPreferences: {'yoga': true, 'pilates': true, 'stretching': true},
        sportCharacter: 'Détendu',
        compatibilityScore: 0,
        createdAt: DateTime.now(),
        equipment: ['Tapis', 'Élastiques'],
        motivation: 'Motivé',
        trainingFrequency: '1x/semaine',
        bio: 'Je débute le yoga et cherche une partenaire pour progresser ensemble le week-end.',
        gender: 'Femme',
      ),
    ]);
  }

  void setCurrentUserProfile(MatchProfile profile) {
    _currentUserProfile = profile;
    _recalculateCompatibilityScores();
    notifyListeners();
  }

  void _recalculateCompatibilityScores() {
    if (_currentUserProfile == null) return;
    
    final updatedProfiles = _allProfiles.map((p) {
      if (p.id == _currentUserProfile!.id) return p;
      final result = calculateCompatibility(_currentUserProfile!, p);
      return p.copyWith(compatibilityScore: result.score);
    }).toList();
    
    _allProfiles.clear();
    _allProfiles.addAll(updatedProfiles);
  }

  List<MatchProfile> getAvailableProfiles() {
    if (_currentUserProfile == null) return [];

    return _allProfiles.where((profile) {
      // Ne pas afficher son propre profil
      if (profile.id == _currentUserProfile!.id) return false;
      // Ne pas afficher les profils déjà likés
      if (_likedProfiles.contains(profile.id)) return false;
      // Ne pas afficher les profils déjà matchés
      if (_matchedProfiles.contains(profile.id)) return false;

      // Appliquer les filtres
      if (_filters.level != null && 
          _filters.level != 'Tous' && 
          profile.level != _filters.level) return false;

      if (_filters.availability != null && 
          _filters.availability != 'Tous' && 
          profile.availability != _filters.availability) return false;

      if (_filters.maxDistance != null && 
          profile.distance > _filters.maxDistance!) return false;

      if (_filters.sportCharacter != null && 
          _filters.sportCharacter != 'Tous' && 
          profile.sportCharacter != _filters.sportCharacter) return false;

      if (_filters.minAge != null && profile.age < _filters.minAge!) return false;
      if (_filters.maxAge != null && profile.age > _filters.maxAge!) return false;

      if (_filters.goals.isNotEmpty) {
        final hasCommonGoal = profile.goals.any((goal) => _filters.goals.contains(goal));
        if (!hasCommonGoal) return false;
      }

      // Filtre par équipement
      if (_filters.accessories.isNotEmpty) {
        final hasCommonEquipment = profile.equipment.any((e) => _filters.accessories.contains(e));
        if (!hasCommonEquipment) return false;
      }

      // Filtre par sports
      if (_filters.sportInterests.isNotEmpty) {
        final hasCommonSport = profile.sportPreferences.keys.any(
          (s) => _filters.sportInterests.map((e) => e.toLowerCase()).contains(s.toLowerCase())
        );
        if (!hasCommonSport) return false;
      }

      return true;
    }).toList()
    ..sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
  }

  void likeProfile(String profileId) {
    if (_likedProfiles.contains(profileId)) return;
    
    _likedProfiles.add(profileId);
    
    final profile = _allProfiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => _allProfiles.first,
    );
    
    // En mode démo, on crée un match si la compatibilité est >= 60%
    if (_currentUserProfile != null && profile.compatibilityScore >= 60) {
      if (!_matchedProfiles.contains(profileId)) {
        _matchedProfiles.add(profileId);
      }
    }
    
    notifyListeners();
  }

  void dislikeProfile(String profileId) {
    if (!_likedProfiles.contains(profileId)) {
      _likedProfiles.add(profileId);
      notifyListeners();
    }
  }

  List<MatchProfile> getMatches() {
    return _allProfiles.where((p) => _matchedProfiles.contains(p.id)).toList();
  }

  void setFilters(MatchFilters filters) {
    _filters = filters;
    notifyListeners();
  }

  MatchFilters get filters => _filters;

  MatchProfile? get currentUserProfile => _currentUserProfile;

  void generateSmartMatches() {
    if (_currentUserProfile == null) return;

    for (final profile in _allProfiles) {
      if (profile.id == _currentUserProfile!.id) continue;
      if (_matchedProfiles.contains(profile.id)) continue;

      final compatibilityResult = calculateCompatibility(_currentUserProfile!, profile);
      final compatibility = compatibilityResult.score;
      if (compatibility >= 85) {
        if (!_matchedProfiles.contains(profile.id)) {
          _matchedProfiles.add(profile.id);
        }
      }
    }

    notifyListeners();
  }

  void resetForDemo() {
    _likedProfiles.clear();
    _matchedProfiles.clear();
    _recalculateCompatibilityScores();
    notifyListeners();
  }
}
