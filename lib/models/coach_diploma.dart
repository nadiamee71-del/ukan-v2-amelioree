class CoachDiploma {
  final String title; // Ex: "BPJEPS AF"
  final String? institution;
  final int? year;
  final String? documentPath; // Pour l'upload (mode démo)

  CoachDiploma({
    required this.title,
    this.institution,
    this.year,
    this.documentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'institution': institution,
      'year': year,
      'documentPath': documentPath,
    };
  }

  factory CoachDiploma.fromJson(Map<String, dynamic> json) {
    return CoachDiploma(
      title: json['title'] as String,
      institution: json['institution'] as String?,
      year: json['year'] as int?,
      documentPath: json['documentPath'] as String?,
    );
  }
}


