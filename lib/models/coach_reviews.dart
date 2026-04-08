import 'package:flutter/foundation.dart';

/// Modèle pour les avis clients sur un coach
class CoachReview {
  final String id;
  final String coachId;
  final String clientId;
  final String clientName;
  final String? clientPhotoUrl;
  final double rating; // 1.0 à 5.0
  final String comment;
  final DateTime createdAt;
  final bool isVerified; // Client vérifié

  CoachReview({
    required this.id,
    required this.coachId,
    required this.clientId,
    required this.clientName,
    this.clientPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVerified = false,
  });
}

/// Notifier pour gérer les avis des coaches
class CoachReviewsNotifier extends ChangeNotifier {
  static final CoachReviewsNotifier _instance = CoachReviewsNotifier._internal();
  factory CoachReviewsNotifier() => _instance;
  CoachReviewsNotifier._internal() {
    _initDemoData();
  }

  final List<CoachReview> _reviews = [];

  List<CoachReview> getReviewsForCoach(String coachId) {
    return _reviews
        .where((r) => r.coachId == coachId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Plus récents en premier
  }

  double getAverageRating(String coachId) {
    final reviews = getReviewsForCoach(coachId);
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.map((r) => r.rating).reduce((a, b) => a + b);
    return sum / reviews.length;
  }

  void addReview(CoachReview review) {
    _reviews.add(review);
    notifyListeners();
  }

  bool hasClientReviewed(String coachId, String clientId) {
    return _reviews.any((r) => r.coachId == coachId && r.clientId == clientId);
  }

  void _initDemoData() {
    _reviews.addAll([
      CoachReview(
        id: 'rev_1',
        coachId: 'coach_1',
        clientId: 'client_1',
        clientName: 'Marie Dupont',
        rating: 5.0,
        comment: 'Excellent coach ! Sophie m\'a aidée à perdre 10 kg en 3 mois. Très professionnelle et motivante.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
      ),
      CoachReview(
        id: 'rev_2',
        coachId: 'coach_1',
        clientId: 'client_2',
        clientName: 'Jean Martin',
        rating: 4.5,
        comment: 'Superbe expérience, programmes adaptés à mes besoins. Je recommande !',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        isVerified: true,
      ),
      CoachReview(
        id: 'rev_3',
        coachId: 'coach_2',
        clientId: 'client_3',
        clientName: 'Paul Bernard',
        rating: 5.0,
        comment: 'Marc est un coach exceptionnel ! J\'ai pris 8 kg de muscle en 6 mois grâce à ses programmes.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        isVerified: true,
      ),
      CoachReview(
        id: 'rev_4',
        coachId: 'coach_3',
        clientId: 'client_4',
        clientName: 'Sophie Leroy',
        rating: 4.8,
        comment: 'Léa est une professeure de yoga incroyable. Ses cours m\'ont apporté beaucoup de sérénité.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isVerified: false,
      ),
    ]);
  }
}





