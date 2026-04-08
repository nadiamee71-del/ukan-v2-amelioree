import 'dart:math';

/// Modèle pour un coach avec géolocalisation
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

/// Données mock des coachs (25 coachs variés)
class MockCoachesData {
  // Avatars disponibles dans assets/images/
  static const List<String> _avatars = [
    'assets/images/ChatGPT Image 1 déc. 2025, 15_19_24.png',
    'assets/images/ChatGPT Image 1 déc. 2025, 15_29_12.png',
    'assets/images/ChatGPT Image 1 déc. 2025, 15_40_04.png',
    'assets/images/ChatGPT Image 1 déc. 2025, 15_43_18.png',
    'assets/images/ChatGPT Image 1 déc. 2025, 15_43_23.png',
    'assets/images/ChatGPT Image 1 déc. 2025, 15_43_39.png',
    'assets/images/ChatGPT Image 1 déc. 2025, 15_44_27.png',
    'assets/images/ChatGPT Image 25 nov. 2025, 18_27_24.png',
    'assets/images/ChatGPT Image 25 nov. 2025, 18_32_27.png',
    'assets/images/ChatGPT Image 25 nov. 2025, 18_35_02.png',
    'assets/images/ChatGPT Image 25 nov. 2025, 18_45_34.png',
    'assets/images/ChatGPT Image 25 nov. 2025, 18_51_26.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_03_13.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_03_17.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_03_22.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_03_28.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_13_32.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_13_46.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_13_47.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_13_54.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_16_06.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_34_46.png',
    'assets/images/ChatGPT Image 29 nov. 2025, 23_40_12.png',
    'assets/images/ChatGPT Image 30 nov. 2025, 00_24_33.png',
    'assets/images/ChatGPT Image 30 nov. 2025, 00_24_35.png',
  ];

  static List<CoachData> getAllCoaches() {
    return [
      // Paris et région parisienne
      CoachData(
        id: 'coach_1',
        name: 'Sophie Martin',
        avatarUrl: _avatars[0],
        speciality: 'Yoga',
        city: 'Paris 11ème',
        rating: 4.9,
        gender: 'femme',
        lat: 48.8566,
        lng: 2.3788,
        address: '25 Rue de la Roquette, 75011 Paris',
        reviewsCount: 127,
        isVerified: true,
        specialities: ['Yoga', 'Pilates', 'Méditation'],
      ),
      CoachData(
        id: 'coach_2',
        name: 'Thomas Dubois',
        avatarUrl: _avatars[1],
        speciality: 'Musculation',
        city: 'Paris 15ème',
        rating: 4.7,
        gender: 'homme',
        lat: 48.8421,
        lng: 2.2945,
        address: '10 Rue de Vaugirard, 75015 Paris',
        reviewsCount: 89,
        isVerified: true,
        specialities: ['Musculation', 'Prise de masse', 'Coaching mental'],
      ),
      CoachData(
        id: 'coach_3',
        name: 'Léa Bernard',
        avatarUrl: _avatars[2],
        speciality: 'Danse',
        city: 'Paris 3ème',
        rating: 4.8,
        gender: 'femme',
        lat: 48.8637,
        lng: 2.3615,
        address: '45 Rue de Turbigo, 75003 Paris',
        reviewsCount: 156,
        isVerified: true,
        specialities: ['Danse', 'Cardio / HIIT', 'Remise en forme'],
      ),
      CoachData(
        id: 'coach_4',
        name: 'Alex Jordan',
        avatarUrl: _avatars[3],
        speciality: 'CrossFit',
        city: 'Boulogne-Billancourt',
        rating: 4.6,
        gender: 'non-binaire',
        lat: 48.8397,
        lng: 2.2399,
        address: '8 Avenue Jean-Baptiste Clément, 92100',
        reviewsCount: 64,
        isVerified: false,
        specialities: ['CrossFit', 'Musculation', 'Préparation sportive'],
      ),
      CoachData(
        id: 'coach_5',
        name: 'Marie Leroy',
        avatarUrl: _avatars[4],
        speciality: 'Pilates',
        city: 'Neuilly-sur-Seine',
        rating: 4.9,
        gender: 'femme',
        lat: 48.8848,
        lng: 2.2687,
        address: '15 Avenue Charles de Gaulle, 92200',
        reviewsCount: 203,
        isVerified: true,
        specialities: ['Pilates', 'Yoga', 'Remise en forme'],
      ),
      
      // Lyon
      CoachData(
        id: 'coach_6',
        name: 'Lucas Moreau',
        avatarUrl: _avatars[5],
        speciality: 'Boxe / MMA',
        city: 'Lyon 3ème',
        rating: 4.8,
        gender: 'homme',
        lat: 45.7578,
        lng: 4.8473,
        address: '20 Cours Lafayette, 69003 Lyon',
        reviewsCount: 98,
        isVerified: true,
        specialities: ['Boxe / MMA', 'Cardio / HIIT', 'Préparation sportive'],
      ),
      CoachData(
        id: 'coach_7',
        name: 'Emma Petit',
        avatarUrl: _avatars[6],
        speciality: 'Nutrition',
        city: 'Lyon 6ème',
        rating: 4.7,
        gender: 'femme',
        lat: 45.7701,
        lng: 4.8512,
        address: '5 Place Maréchal Lyautey, 69006 Lyon',
        reviewsCount: 145,
        isVerified: true,
        specialities: ['Nutrition', 'Perte de poids', 'Coaching mental'],
      ),
      
      // Marseille
      CoachData(
        id: 'coach_8',
        name: 'Hugo Garcia',
        avatarUrl: _avatars[7],
        speciality: 'Course à pied',
        city: 'Marseille 8ème',
        rating: 4.5,
        gender: 'homme',
        lat: 43.2584,
        lng: 5.3985,
        address: '30 Avenue du Prado, 13008 Marseille',
        reviewsCount: 67,
        isVerified: false,
        specialities: ['Course à pied', 'Cardio / HIIT', 'Préparation sportive'],
      ),
      CoachData(
        id: 'coach_9',
        name: 'Chloé Roux',
        avatarUrl: _avatars[8],
        speciality: 'Yoga',
        city: 'Marseille 1er',
        rating: 4.9,
        gender: 'femme',
        lat: 43.2965,
        lng: 5.3698,
        address: '12 Rue de la République, 13001 Marseille',
        reviewsCount: 178,
        isVerified: true,
        specialities: ['Yoga', 'Méditation', 'Pilates'],
      ),
      
      // Bordeaux
      CoachData(
        id: 'coach_10',
        name: 'Antoine Fournier',
        avatarUrl: _avatars[9],
        speciality: 'Musculation',
        city: 'Bordeaux',
        rating: 4.6,
        gender: 'homme',
        lat: 44.8378,
        lng: -0.5792,
        address: '45 Cours de l\'Intendance, 33000 Bordeaux',
        reviewsCount: 82,
        isVerified: true,
        specialities: ['Musculation', 'Prise de masse', 'Nutrition'],
      ),
      CoachData(
        id: 'coach_11',
        name: 'Camille Dupont',
        avatarUrl: _avatars[10],
        speciality: 'Danse',
        city: 'Bordeaux',
        rating: 4.8,
        gender: 'femme',
        lat: 44.8412,
        lng: -0.5745,
        address: '8 Place Gambetta, 33000 Bordeaux',
        reviewsCount: 134,
        isVerified: true,
        specialities: ['Danse', 'Cardio / HIIT', 'Remise en forme'],
      ),
      
      // Toulouse
      CoachData(
        id: 'coach_12',
        name: 'Maxime Laurent',
        avatarUrl: _avatars[11],
        speciality: 'CrossFit',
        city: 'Toulouse',
        rating: 4.7,
        gender: 'homme',
        lat: 43.6047,
        lng: 1.4442,
        address: '15 Place du Capitole, 31000 Toulouse',
        reviewsCount: 91,
        isVerified: true,
        specialities: ['CrossFit', 'Musculation', 'Cardio / HIIT'],
      ),
      CoachData(
        id: 'coach_13',
        name: 'Julie Michel',
        avatarUrl: _avatars[12],
        speciality: 'Pilates',
        city: 'Toulouse',
        rating: 4.9,
        gender: 'femme',
        lat: 43.6108,
        lng: 1.4534,
        address: '22 Rue Alsace-Lorraine, 31000 Toulouse',
        reviewsCount: 167,
        isVerified: true,
        specialities: ['Pilates', 'Yoga', 'Remise en forme'],
      ),
      
      // Nice
      CoachData(
        id: 'coach_14',
        name: 'Nicolas Blanc',
        avatarUrl: _avatars[13],
        speciality: 'Natation',
        city: 'Nice',
        rating: 4.6,
        gender: 'homme',
        lat: 43.7102,
        lng: 7.2620,
        address: '5 Promenade des Anglais, 06000 Nice',
        reviewsCount: 73,
        isVerified: false,
        specialities: ['Natation', 'Cardio / HIIT', 'Remise en forme'],
      ),
      CoachData(
        id: 'coach_15',
        name: 'Sarah Cohen',
        avatarUrl: _avatars[14],
        speciality: 'Yoga',
        city: 'Nice',
        rating: 4.8,
        gender: 'femme',
        lat: 43.7034,
        lng: 7.2663,
        address: '18 Avenue Jean Médecin, 06000 Nice',
        reviewsCount: 142,
        isVerified: true,
        specialities: ['Yoga', 'Méditation', 'Coaching mental'],
      ),
      
      // Nantes
      CoachData(
        id: 'coach_16',
        name: 'Pierre Girard',
        avatarUrl: _avatars[15],
        speciality: 'Boxe / MMA',
        city: 'Nantes',
        rating: 4.7,
        gender: 'homme',
        lat: 47.2184,
        lng: -1.5536,
        address: '10 Place Royale, 44000 Nantes',
        reviewsCount: 86,
        isVerified: true,
        specialities: ['Boxe / MMA', 'Musculation', 'Préparation sportive'],
      ),
      CoachData(
        id: 'coach_17',
        name: 'Manon Lefebvre',
        avatarUrl: _avatars[16],
        speciality: 'Nutrition',
        city: 'Nantes',
        rating: 4.9,
        gender: 'femme',
        lat: 47.2133,
        lng: -1.5578,
        address: '25 Rue Crébillon, 44000 Nantes',
        reviewsCount: 198,
        isVerified: true,
        specialities: ['Nutrition', 'Perte de poids', 'Remise en forme'],
      ),
      
      // Strasbourg
      CoachData(
        id: 'coach_18',
        name: 'David Weber',
        avatarUrl: _avatars[17],
        speciality: 'Musculation',
        city: 'Strasbourg',
        rating: 4.5,
        gender: 'homme',
        lat: 48.5734,
        lng: 7.7521,
        address: '8 Place Kléber, 67000 Strasbourg',
        reviewsCount: 54,
        isVerified: false,
        specialities: ['Musculation', 'Prise de masse', 'CrossFit'],
      ),
      CoachData(
        id: 'coach_19',
        name: 'Laura Schneider',
        avatarUrl: _avatars[18],
        speciality: 'Danse',
        city: 'Strasbourg',
        rating: 4.8,
        gender: 'femme',
        lat: 48.5812,
        lng: 7.7509,
        address: '15 Rue des Grandes Arcades, 67000 Strasbourg',
        reviewsCount: 112,
        isVerified: true,
        specialities: ['Danse', 'Cardio / HIIT', 'Pilates'],
      ),
      
      // Lille
      CoachData(
        id: 'coach_20',
        name: 'Julien Vandenberghe',
        avatarUrl: _avatars[19],
        speciality: 'CrossFit',
        city: 'Lille',
        rating: 4.7,
        gender: 'homme',
        lat: 50.6292,
        lng: 3.0573,
        address: '20 Place du Général de Gaulle, 59000 Lille',
        reviewsCount: 79,
        isVerified: true,
        specialities: ['CrossFit', 'Musculation', 'Cardio / HIIT'],
      ),
      CoachData(
        id: 'coach_21',
        name: 'Amélie Delarue',
        avatarUrl: _avatars[20],
        speciality: 'Yoga',
        city: 'Lille',
        rating: 4.9,
        gender: 'femme',
        lat: 50.6365,
        lng: 3.0635,
        address: '5 Rue de Béthune, 59000 Lille',
        reviewsCount: 156,
        isVerified: true,
        specialities: ['Yoga', 'Méditation', 'Pilates'],
      ),
      
      // Montpellier
      CoachData(
        id: 'coach_22',
        name: 'Robin Fabre',
        avatarUrl: _avatars[21],
        speciality: 'Course à pied',
        city: 'Montpellier',
        rating: 4.6,
        gender: 'autre',
        lat: 43.6108,
        lng: 3.8767,
        address: '12 Place de la Comédie, 34000 Montpellier',
        reviewsCount: 68,
        isVerified: false,
        specialities: ['Course à pied', 'Cardio / HIIT', 'Préparation sportive'],
      ),
      CoachData(
        id: 'coach_23',
        name: 'Océane Mercier',
        avatarUrl: _avatars[22],
        speciality: 'Pilates',
        city: 'Montpellier',
        rating: 4.8,
        gender: 'femme',
        lat: 43.6045,
        lng: 3.8803,
        address: '8 Rue de l\'Ancien Courrier, 34000 Montpellier',
        reviewsCount: 123,
        isVerified: true,
        specialities: ['Pilates', 'Yoga', 'Remise en forme'],
      ),
      
      // Coachs sans géolocalisation (pour tester le cas "pas sur la carte")
      CoachData(
        id: 'coach_24',
        name: 'Kevin Morel',
        avatarUrl: _avatars[23],
        speciality: 'Coaching mental',
        city: 'En ligne',
        rating: 4.7,
        gender: 'homme',
        lat: null, // Pas de géolocalisation
        lng: null,
        address: null,
        reviewsCount: 245,
        isVerified: true,
        specialities: ['Coaching mental', 'Nutrition', 'Perte de poids'],
      ),
      CoachData(
        id: 'coach_25',
        name: 'Clara Bonnet',
        avatarUrl: _avatars[24],
        speciality: 'Nutrition',
        city: 'En ligne',
        rating: 4.9,
        gender: 'femme',
        lat: null, // Pas de géolocalisation
        lng: null,
        address: null,
        reviewsCount: 312,
        isVerified: true,
        specialities: ['Nutrition', 'Perte de poids', 'Coaching mental'],
      ),
    ];
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









