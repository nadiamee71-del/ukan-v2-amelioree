import 'dart:math';
import '../models/coach_directory.dart';
import '../models/coach_reviews.dart';

/// Modèle pour un coach avec géolocalisation (vue carte).
///
/// Les champs d'identité (id, nom, photo, ville, spécialité, certification…)
/// proviennent de la SOURCE UNIQUE `CoachDirectoryNotifier`. Les seules
/// données propres à la carte sont les coordonnées géographiques et le genre.
class CoachData {
  final String id;
  final String name;
  final String avatarUrl;
  final String speciality;
  final String city;
  final double rating;
  final String gender; // 'femme', 'homme', 'non-binaire', 'autre'
  final double? lat;
  final double? lng;
  final String? address;
  final int reviewsCount;
  final bool isVerified;
  final List<String> specialities;

  CoachData({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.speciality,
    required this.city,
    required this.rating,
    required this.gender,
    this.lat,
    this.lng,
    this.address,
    this.reviewsCount = 0,
    this.isVerified = false,
    this.specialities = const [],
  });

  /// Calcule la distance en km depuis une position donnée
  double? distanceFrom(double? userLat, double? userLng) {
    if (lat == null || lng == null || userLat == null || userLng == null) {
      return null;
    }

    const double earthRadius = 6371; // km
    final double dLat = _toRadians(lat! - userLat);
    final double dLng = _toRadians(lng! - userLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) * cos(_toRadians(lat!)) *
        sin(dLng / 2) * sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'speciality': speciality,
    'city': city,
    'rating': rating,
    'gender': gender,
    'lat': lat,
    'lng': lng,
    'address': address,
    'reviewsCount': reviewsCount,
    'isVerified': isVerified,
    'specialities': specialities,
  };

  factory CoachData.fromJson(Map<String, dynamic> json) => CoachData(
    id: json['id'],
    name: json['name'],
    avatarUrl: json['avatarUrl'],
    speciality: json['speciality'],
    city: json['city'],
    rating: (json['rating'] as num).toDouble(),
    gender: json['gender'],
    lat: json['lat']?.toDouble(),
    lng: json['lng']?.toDouble(),
    address: json['address'],
    reviewsCount: json['reviewsCount'] ?? 0,
    isVerified: json['isVerified'] ?? false,
    specialities: List<String>.from(json['specialities'] ?? []),
  );
}

/// Liste des spécialités disponibles
class CoachSpecialities {
  static const List<String> all = [
    'Musculation',
    'Yoga',
    'Cardio / HIIT',
    'CrossFit',
    'Pilates',
    'Boxe / MMA',
    'Danse',
    'Nutrition',
    'Coaching mental',
    'Perte de poids',
    'Prise de masse',
    'Remise en forme',
    'Préparation sportive',
    'Course à pied',
    'Natation',
    'Méditation',
  ];
}

/// Liste des genres
class CoachGenders {
  static const String all = 'tous';
  static const String femme = 'femme';
  static const String homme = 'homme';
  static const String nonBinaire = 'non-binaire';
  static const String autre = 'autre';

  static const List<String> values = [all, femme, homme, nonBinaire, autre];

  static String label(String gender) {
    switch (gender) {
      case all: return 'Genre : Tous';
      case femme: return 'Femme';
      case homme: return 'Homme';
      case nonBinaire: return 'Non-binaire';
      case autre: return 'Autre / Non spécifié';
      default: return gender;
    }
  }
}

/// Options de rayon de recherche
class SearchRadius {
  static const List<double> options = [1, 5, 10, 20, 50, 100, -1]; // -1 = Partout

  static String label(double radius) {
    if (radius < 0) return 'Partout';
    return '${radius.toInt()} km';
  }
}

/// Données coachs pour la carte, DÉRIVÉES de la source unique
/// `CoachDirectoryNotifier`. Aucune liste parallèle : identité partagée avec
/// l'annuaire, la fiche publique, le dashboard et la réservation.
class MockCoachesData {
  // Avatar de repli si un coach n'a pas de photo dans la source unique.
  static const String _fallbackAvatar =
      'assets/images/ChatGPT Image 1 déc. 2025, 15_19_24.png';

  // Genre par coach (métadonnée propre à la carte / filtre).
  static const Map<String, String> _genderForId = {
    'coach_1': 'femme',
    'coach_2': 'homme',
    'coach_3': 'femme',
    'coach_4': 'homme',
    'coach_5': 'femme',
  };

  /// Retourne tous les coachs (dérivés de la source unique).
  static List<CoachData> getAllCoaches() {
    return CoachDirectoryNotifier().allCoaches.map(_fromProfile).toList();
  }

  static CoachData _fromProfile(CoachProfile p) {
    final coords = _coordsForCity(p.city);
    return CoachData(
      id: p.id,
      name: p.name,
      avatarUrl: (p.photoUrl != null && p.photoUrl!.isNotEmpty)
          ? p.photoUrl!
          : _fallbackAvatar,
      speciality: p.specialty,
      city: p.city,
      rating: p.rating,
      gender: _genderForId[p.id] ?? CoachGenders.autre,
      lat: coords?[0],
      lng: coords?[1],
      address: p.city,
      reviewsCount: CoachReviewsNotifier().getReviewsForCoach(p.id).length,
      isVerified: p.isCertified,
      specialities:
          p.detailedSpecialties.isNotEmpty ? p.detailedSpecialties : [p.specialty],
    );
  }

  // Coordonnées approximatives par ville (métadonnée carte).
  static List<double>? _coordsForCity(String city) {
    final c = city.toLowerCase();
    if (c.contains('paris')) return [48.8566, 2.3522];
    if (c.contains('lyon')) return [45.7578, 4.8320];
    if (c.contains('marseille')) return [43.2965, 5.3698];
    if (c.contains('bordeaux')) return [44.8378, -0.5792];
    if (c.contains('toulouse')) return [43.6047, 1.4442];
    if (c.contains('nice')) return [43.7102, 7.2620];
    if (c.contains('nantes')) return [47.2184, -1.5536];
    if (c.contains('strasbourg')) return [48.5734, 7.7521];
    if (c.contains('lille')) return [50.6292, 3.0573];
    if (c.contains('montpellier')) return [43.6108, 3.8767];
    return null;
  }

  /// Filtre les coachs selon les critères
  static List<CoachData> filterCoaches({
    String? gender,
    String? speciality,
    String? city,
    double? ratingMin,
    double? userLat,
    double? userLng,
    double? radiusKm,
  }) {
    var coaches = getAllCoaches();

    // Filtre par genre
    if (gender != null && gender != CoachGenders.all) {
      coaches = coaches.where((c) => c.gender == gender).toList();
    }

    // Filtre par spécialité
    if (speciality != null && speciality.isNotEmpty) {
      coaches = coaches.where((c) =>
        c.speciality.toLowerCase().contains(speciality.toLowerCase()) ||
        c.specialities.any((s) => s.toLowerCase().contains(speciality.toLowerCase()))
      ).toList();
    }

    // Filtre par ville
    if (city != null && city.isNotEmpty) {
      coaches = coaches.where((c) =>
        c.city.toLowerCase().contains(city.toLowerCase())
      ).toList();
    }

    // Filtre par note minimum
    if (ratingMin != null && ratingMin > 0) {
      coaches = coaches.where((c) => c.rating >= ratingMin).toList();
    }

    // Filtre par distance (si position utilisateur fournie)
    if (userLat != null && userLng != null && radiusKm != null && radiusKm > 0) {
      coaches = coaches.where((c) {
        final distance = c.distanceFrom(userLat, userLng);
        return distance != null && distance <= radiusKm;
      }).toList();
    }

    return coaches;
  }

  /// Retourne uniquement les coachs avec géolocalisation (pour la carte)
  static List<CoachData> getCoachesWithLocation() {
    return getAllCoaches().where((c) => c.lat != null && c.lng != null).toList();
  }
}
