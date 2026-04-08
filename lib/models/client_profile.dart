class ClientProfile {
  // Informations personnelles
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String gender;
  final String email;
  final String phone;
  final String? address;
  final String? city;
  final String? postalCode;

  // Données corporelles
  final double heightCm;
  final double weightKg;
  final double? targetWeightKg;
  final double? waistCm;
  final double? hipsCm;
  final double? imc; // Calculé automatiquement

  // Objectifs & motivation
  final List<String> objectives;
  final String mainReason;
  final String? difficulties;
  final String sessionsPerWeek;

  // Préférences de coaching
  final bool coachingPresentiel;
  final double? maxDistanceKm;
  final bool coachingVisio;
  final List<String> preferredTimeSlots; // Matin, Après-midi, Soir
  final List<String> preferredDays; // Lundi, Mardi, etc.

  // Santé
  final String? allergies;
  final String? healthIssues;
  final bool medicalAuthorization;

  ClientProfile({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.email,
    required this.phone,
    this.address,
    this.city,
    this.postalCode,
    required this.heightCm,
    required this.weightKg,
    this.targetWeightKg,
    this.waistCm,
    this.hipsCm,
    this.imc,
    required this.objectives,
    required this.mainReason,
    this.difficulties,
    required this.sessionsPerWeek,
    required this.coachingPresentiel,
    this.maxDistanceKm,
    required this.coachingVisio,
    required this.preferredTimeSlots,
    required this.preferredDays,
    this.allergies,
    this.healthIssues,
    required this.medicalAuthorization,
  });

  // Calcul de l'IMC
  static double calculateIMC(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Conversion en Map pour localStorage/JSON
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'targetWeightKg': targetWeightKg,
      'waistCm': waistCm,
      'hipsCm': hipsCm,
      'imc': imc,
      'objectives': objectives,
      'mainReason': mainReason,
      'difficulties': difficulties,
      'sessionsPerWeek': sessionsPerWeek,
      'coachingPresentiel': coachingPresentiel,
      'maxDistanceKm': maxDistanceKm,
      'coachingVisio': coachingVisio,
      'preferredTimeSlots': preferredTimeSlots,
      'preferredDays': preferredDays,
      'allergies': allergies,
      'healthIssues': healthIssues,
      'medicalAuthorization': medicalAuthorization,
    };
  }

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      targetWeightKg: json['targetWeightKg'] != null
          ? (json['targetWeightKg'] as num).toDouble()
          : null,
      waistCm:
          json['waistCm'] != null ? (json['waistCm'] as num).toDouble() : null,
      hipsCm:
          json['hipsCm'] != null ? (json['hipsCm'] as num).toDouble() : null,
      imc: json['imc'] != null ? (json['imc'] as num).toDouble() : null,
      objectives: List<String>.from(json['objectives'] as List),
      mainReason: json['mainReason'] as String,
      difficulties: json['difficulties'] as String?,
      sessionsPerWeek: json['sessionsPerWeek'] as String,
      coachingPresentiel: json['coachingPresentiel'] as bool,
      maxDistanceKm: json['maxDistanceKm'] != null
          ? (json['maxDistanceKm'] as num).toDouble()
          : null,
      coachingVisio: json['coachingVisio'] as bool,
      preferredTimeSlots: List<String>.from(json['preferredTimeSlots'] as List),
      preferredDays: List<String>.from(json['preferredDays'] as List),
      allergies: json['allergies'] as String?,
      healthIssues: json['healthIssues'] as String?,
      medicalAuthorization: json['medicalAuthorization'] as bool,
    );
  }
}


