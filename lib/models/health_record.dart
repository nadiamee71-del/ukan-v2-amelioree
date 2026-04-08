import 'package:flutter/foundation.dart';

/// Historique de poids
class WeightHistoryEntry {
  final DateTime date;
  final double weightKg;
  final String? note;

  const WeightHistoryEntry({
    required this.date,
    required this.weightKg,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weightKg': weightKg,
    'note': note,
  };

  factory WeightHistoryEntry.fromJson(Map<String, dynamic> json) => WeightHistoryEntry(
    date: DateTime.parse(json['date'] as String),
    weightKg: json['weightKg'] as double,
    note: json['note'] as String?,
  );
}

/// Vaccination
class Vaccination {
  final String id;
  final String name;
  final DateTime date;
  final DateTime? nextDueDate;
  final String? batchNumber;
  final String? administeredBy;

  const Vaccination({
    required this.id,
    required this.name,
    required this.date,
    this.nextDueDate,
    this.batchNumber,
    this.administeredBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'nextDueDate': nextDueDate?.toIso8601String(),
    'batchNumber': batchNumber,
    'administeredBy': administeredBy,
  };

  factory Vaccination.fromJson(Map<String, dynamic> json) => Vaccination(
    id: json['id'] as String,
    name: json['name'] as String,
    date: DateTime.parse(json['date'] as String),
    nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate'] as String) : null,
    batchNumber: json['batchNumber'] as String?,
    administeredBy: json['administeredBy'] as String?,
  );
}

/// Examen médical
class MedicalExam {
  final String id;
  final String type; // Bilan sanguin, Radio, IRM, etc.
  final DateTime date;
  final String? result;
  final String? notes;
  final String? documentPath;

  const MedicalExam({
    required this.id,
    required this.type,
    required this.date,
    this.result,
    this.notes,
    this.documentPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'date': date.toIso8601String(),
    'result': result,
    'notes': notes,
    'documentPath': documentPath,
  };

  factory MedicalExam.fromJson(Map<String, dynamic> json) => MedicalExam(
    id: json['id'] as String,
    type: json['type'] as String,
    date: DateTime.parse(json['date'] as String),
    result: json['result'] as String?,
    notes: json['notes'] as String?,
    documentPath: json['documentPath'] as String?,
  );
}

/// Contact médical (médecin traitant, spécialistes, etc.)
class MedicalContact {
  final String id;
  final String name;
  final String specialty; // Généraliste, Kiné, Cardiologue, etc.
  final String? phone;
  final String? email;
  final String? address;
  final bool isPrimaryDoctor;

  const MedicalContact({
    required this.id,
    required this.name,
    required this.specialty,
    this.phone,
    this.email,
    this.address,
    this.isPrimaryDoctor = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'specialty': specialty,
    'phone': phone,
    'email': email,
    'address': address,
    'isPrimaryDoctor': isPrimaryDoctor,
  };

  factory MedicalContact.fromJson(Map<String, dynamic> json) => MedicalContact(
    id: json['id'] as String,
    name: json['name'] as String,
    specialty: json['specialty'] as String,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    isPrimaryDoctor: json['isPrimaryDoctor'] as bool? ?? false,
  );
}

/// Contact d'urgence
class EmergencyContact {
  final String id;
  final String name;
  final String relationship; // Conjoint, Parent, Ami, etc.
  final String phone;
  final String? secondaryPhone;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.secondaryPhone,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'secondaryPhone': secondaryPhone,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    id: json['id'] as String,
    name: json['name'] as String,
    relationship: json['relationship'] as String,
    phone: json['phone'] as String,
    secondaryPhone: json['secondaryPhone'] as String?,
  );
}

/// Modèle de données pour le carnet de santé
class HealthRecord {
  final String id;
  final String userId;
  
  // Infos médicales
  final String? bloodGroup; // groupe sanguin (A+, O-, etc.)
  final List<String> allergies; // allergies alimentaires / médicamenteuses
  final List<String> medications; // traitements en cours
  final List<String> conditions; // pathologies : asthme, diabète, HTA, etc.
  final List<String> surgeries; // opérations / chirurgies importantes
  final bool hasPacemaker; // pacemaker ou dispositif implanté
  final bool hasProsthesis; // prothèses (hanche, genou, etc.)
  
  // Paramètres vitaux / mesures corporelles
  final double? heightCm; // taille
  final double? weightKg; // poids
  final double? bmi; // IMC (si calculé)
  final double? bodyFatPercent; // masse grasse estimée
  final Map<String, double> measurements; // ex: { "tour_taille": 80, "tour_hanches": 95, "tour_poitrine": 90 }
  final int? restingHeartRate; // fréquence cardiaque au repos
  final String? bloodPressure; // tension ex : "12/8"
  
  // Suivi & documents
  final List<String> medicalDocumentPaths; // ordonnances, radios, bilans (images / pdf simulés)
  final List<String> notes; // remarques libres
  final DateTime? lastCheckupDate; // dernier examen médical
  final DateTime lastUpdated; // dernière mise à jour
  
  // Nouveaux champs
  final List<WeightHistoryEntry> weightHistory; // historique de poids
  final List<Vaccination> vaccinations; // vaccinations
  final List<MedicalExam> medicalExams; // examens médicaux
  final List<MedicalContact> medicalContacts; // contacts médicaux (médecins)
  final List<EmergencyContact> emergencyContacts; // contacts d'urgence

  const HealthRecord({
    required this.id,
    required this.userId,
    this.bloodGroup,
    this.allergies = const [],
    this.medications = const [],
    this.conditions = const [],
    this.surgeries = const [],
    this.hasPacemaker = false,
    this.hasProsthesis = false,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.bodyFatPercent,
    this.measurements = const {},
    this.restingHeartRate,
    this.bloodPressure,
    this.medicalDocumentPaths = const [],
    this.notes = const [],
    this.lastCheckupDate,
    required this.lastUpdated,
    this.weightHistory = const [],
    this.vaccinations = const [],
    this.medicalExams = const [],
    this.medicalContacts = const [],
    this.emergencyContacts = const [],
  });

  /// Crée une copie du carnet de santé avec des valeurs modifiées
  HealthRecord copyWith({
    String? id,
    String? userId,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? medications,
    List<String>? conditions,
    List<String>? surgeries,
    bool? hasPacemaker,
    bool? hasProsthesis,
    double? heightCm,
    double? weightKg,
    double? bmi,
    double? bodyFatPercent,
    Map<String, double>? measurements,
    int? restingHeartRate,
    String? bloodPressure,
    List<String>? medicalDocumentPaths,
    List<String>? notes,
    DateTime? lastCheckupDate,
    DateTime? lastUpdated,
    List<WeightHistoryEntry>? weightHistory,
    List<Vaccination>? vaccinations,
    List<MedicalExam>? medicalExams,
    List<MedicalContact>? medicalContacts,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      conditions: conditions ?? this.conditions,
      surgeries: surgeries ?? this.surgeries,
      hasPacemaker: hasPacemaker ?? this.hasPacemaker,
      hasProsthesis: hasProsthesis ?? this.hasProsthesis,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      measurements: measurements ?? this.measurements,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      medicalDocumentPaths: medicalDocumentPaths ?? this.medicalDocumentPaths,
      notes: notes ?? this.notes,
      lastCheckupDate: lastCheckupDate ?? this.lastCheckupDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      weightHistory: weightHistory ?? this.weightHistory,
      vaccinations: vaccinations ?? this.vaccinations,
      medicalExams: medicalExams ?? this.medicalExams,
      medicalContacts: medicalContacts ?? this.medicalContacts,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  /// Convertit en Map pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'medications': medications,
      'conditions': conditions,
      'surgeries': surgeries,
      'hasPacemaker': hasPacemaker,
      'hasProsthesis': hasProsthesis,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bmi': bmi,
      'bodyFatPercent': bodyFatPercent,
      'measurements': measurements,
      'restingHeartRate': restingHeartRate,
      'bloodPressure': bloodPressure,
      'medicalDocumentPaths': medicalDocumentPaths,
      'notes': notes,
      'lastCheckupDate': lastCheckupDate?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'weightHistory': weightHistory.map((e) => e.toJson()).toList(),
      'vaccinations': vaccinations.map((e) => e.toJson()).toList(),
      'medicalExams': medicalExams.map((e) => e.toJson()).toList(),
      'medicalContacts': medicalContacts.map((e) => e.toJson()).toList(),
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
    };
  }

  /// Crée depuis un Map
  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bloodGroup: json['bloodGroup'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      surgeries: (json['surgeries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hasPacemaker: json['hasPacemaker'] as bool? ?? false,
      hasProsthesis: json['hasProsthesis'] as bool? ?? false,
      heightCm: json['heightCm'] as double?,
      weightKg: json['weightKg'] as double?,
      bmi: json['bmi'] as double?,
      bodyFatPercent: json['bodyFatPercent'] as double?,
      measurements: (json['measurements'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as double)) ??
          {},
      restingHeartRate: json['restingHeartRate'] as int?,
      bloodPressure: json['bloodPressure'] as String?,
      medicalDocumentPaths: (json['medicalDocumentPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lastCheckupDate: json['lastCheckupDate'] != null
          ? DateTime.parse(json['lastCheckupDate'] as String)
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      weightHistory: (json['weightHistory'] as List<dynamic>?)
              ?.map((e) => WeightHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vaccinations: (json['vaccinations'] as List<dynamic>?)
              ?.map((e) => Vaccination.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      medicalExams: (json['medicalExams'] as List<dynamic>?)
              ?.map((e) => MedicalExam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      medicalContacts: (json['medicalContacts'] as List<dynamic>?)
              ?.map((e) => MedicalContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Notifier pour gérer le carnet de santé (en mémoire)
class HealthRecordNotifier extends ChangeNotifier {
  static final HealthRecordNotifier _instance = HealthRecordNotifier._internal();
  factory HealthRecordNotifier() => _instance;
  HealthRecordNotifier._internal();

  HealthRecord? _healthRecord;
  static const String _currentUserId = 'user_demo_123'; // ID simulé

  /// Récupère le carnet de santé de l'utilisateur
  HealthRecord? getHealthRecord() {
    if (_healthRecord == null) {
      // Créer un carnet vide par défaut
      _healthRecord = HealthRecord(
        id: 'health_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId,
        lastUpdated: DateTime.now(),
      );
    }
    return _healthRecord;
  }

  /// Met à jour le carnet de santé
  void updateHealthRecord(HealthRecord record) {
    _healthRecord = record.copyWith(
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  /// Ajoute un élément à une liste (allergies, médicaments, etc.)
  void addToList(String listType, String item) {
    if (_healthRecord == null) {
      getHealthRecord();
    }
    final record = _healthRecord!;
    
    HealthRecord updated;
    switch (listType) {
      case 'allergies':
        updated = record.copyWith(
          allergies: [...record.allergies, item],
        );
        break;
      case 'medications':
        updated = record.copyWith(
          medications: [...record.medications, item],
        );
        break;
      case 'conditions':
        updated = record.copyWith(
          conditions: [...record.conditions, item],
        );
        break;
      case 'surgeries':
        updated = record.copyWith(
          surgeries: [...record.surgeries, item],
        );
        break;
      case 'notes':
        updated = record.copyWith(
          notes: [...record.notes, item],
        );
        break;
      default:
        return;
    }
    updateHealthRecord(updated);
  }

  /// Supprime un élément d'une liste
  void removeFromList(String listType, String item) {
    if (_healthRecord == null) return;
    final record = _healthRecord!;
    
    HealthRecord updated;
    switch (listType) {
      case 'allergies':
        updated = record.copyWith(
          allergies: record.allergies.where((e) => e != item).toList(),
        );
        break;
      case 'medications':
        updated = record.copyWith(
          medications: record.medications.where((e) => e != item).toList(),
        );
        break;
      case 'conditions':
        updated = record.copyWith(
          conditions: record.conditions.where((e) => e != item).toList(),
        );
        break;
      case 'surgeries':
        updated = record.copyWith(
          surgeries: record.surgeries.where((e) => e != item).toList(),
        );
        break;
      case 'notes':
        updated = record.copyWith(
          notes: record.notes.where((e) => e != item).toList(),
        );
        break;
      default:
        return;
    }
    updateHealthRecord(updated);
  }

  /// Ajoute un document médical
  void addMedicalDocument(String documentPath) {
    if (_healthRecord == null) {
      getHealthRecord();
    }
    final record = _healthRecord!;
    updateHealthRecord(
      record.copyWith(
        medicalDocumentPaths: [...record.medicalDocumentPaths, documentPath],
      ),
    );
  }

  /// Supprime un document médical
  void removeMedicalDocument(String documentPath) {
    if (_healthRecord == null) return;
    final record = _healthRecord!;
    updateHealthRecord(
      record.copyWith(
        medicalDocumentPaths:
            record.medicalDocumentPaths.where((p) => p != documentPath).toList(),
      ),
    );
  }
}
















