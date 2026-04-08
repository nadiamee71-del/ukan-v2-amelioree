import 'coach_diploma.dart';

class CoachProfile {
  // Informations personnelles
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;

  // Profil professionnel
  final List<String> coachTypes;
  final int experienceYears;
  final String bio;
  final String? siret;
  final String? profilePhotoPath; // Pour l'upload (mode démo)

  // Diplômes et certifications
  final List<CoachDiploma> diplomas;

  // Types de séances proposées
  final List<String> sessionTypes;

  // Modalités & organisation
  final bool offersVisio;
  final bool offersHomeCoaching;
  final bool offersGymCoaching;
  final bool offersVideoReplay;
  final double? travelRadiusKm;
  final double? priceMin;
  final double? priceMax;
  final List<String> availableDays; // Lundi, Mardi, etc.
  final List<String> availableTimeSlots; // Matin, Après-midi, Soir

  // Consentements RGPD
  final bool consentRGPD;
  final bool consentDataProcessing;
  final bool consentVideoReplay;
  final bool consentClientVisibility;

  CoachProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    required this.coachTypes,
    required this.experienceYears,
    required this.bio,
    this.siret,
    this.profilePhotoPath,
    required this.diplomas,
    required this.sessionTypes,
    required this.offersVisio,
    required this.offersHomeCoaching,
    required this.offersGymCoaching,
    required this.offersVideoReplay,
    this.travelRadiusKm,
    this.priceMin,
    this.priceMax,
    required this.availableDays,
    required this.availableTimeSlots,
    required this.consentRGPD,
    required this.consentDataProcessing,
    required this.consentVideoReplay,
    required this.consentClientVisibility,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'coachTypes': coachTypes,
      'experienceYears': experienceYears,
      'bio': bio,
      'siret': siret,
      'profilePhotoPath': profilePhotoPath,
      'diplomas': diplomas.map((d) => d.toJson()).toList(),
      'sessionTypes': sessionTypes,
      'offersVisio': offersVisio,
      'offersHomeCoaching': offersHomeCoaching,
      'offersGymCoaching': offersGymCoaching,
      'offersVideoReplay': offersVideoReplay,
      'travelRadiusKm': travelRadiusKm,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
      'consentRGPD': consentRGPD,
      'consentDataProcessing': consentDataProcessing,
      'consentVideoReplay': consentVideoReplay,
      'consentClientVisibility': consentClientVisibility,
    };
  }

  factory CoachProfile.fromJson(Map<String, dynamic> json) {
    return CoachProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      coachTypes: List<String>.from(json['coachTypes'] as List),
      experienceYears: json['experienceYears'] as int,
      bio: json['bio'] as String,
      siret: json['siret'] as String?,
      profilePhotoPath: json['profilePhotoPath'] as String?,
      diplomas: (json['diplomas'] as List)
          .map((d) => CoachDiploma.fromJson(d as Map<String, dynamic>))
          .toList(),
      sessionTypes: List<String>.from(json['sessionTypes'] as List),
      offersVisio: json['offersVisio'] as bool,
      offersHomeCoaching: json['offersHomeCoaching'] as bool,
      offersGymCoaching: json['offersGymCoaching'] as bool,
      offersVideoReplay: json['offersVideoReplay'] as bool? ?? false,
      travelRadiusKm: json['travelRadiusKm'] != null
          ? (json['travelRadiusKm'] as num).toDouble()
          : null,
      priceMin:
          json['priceMin'] != null ? (json['priceMin'] as num).toDouble() : null,
      priceMax:
          json['priceMax'] != null ? (json['priceMax'] as num).toDouble() : null,
      availableDays: List<String>.from(json['availableDays'] as List),
      availableTimeSlots: List<String>.from(json['availableTimeSlots'] as List),
      consentRGPD: json['consentRGPD'] as bool? ?? false,
      consentDataProcessing: json['consentDataProcessing'] as bool? ?? false,
      consentVideoReplay: json['consentVideoReplay'] as bool? ?? false,
      consentClientVisibility: json['consentClientVisibility'] as bool? ?? false,
    );
  }
}

