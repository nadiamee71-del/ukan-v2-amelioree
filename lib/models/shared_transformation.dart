import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Modèle pour une transformation Avant/Après partagée avec la communauté
class SharedTransformation {
  final String id;
  final String userName;
  final String? userAvatarPath;
  final String? beforeImagePath;
  final Uint8List? beforeImageBytes;
  final String? afterImagePath;
  final Uint8List? afterImageBytes;
  final double? beforeWeight;
  final double? afterWeight;
  final DateTime beforeDate;
  final DateTime afterDate;
  final String? note;
  final int likes;
  final int comments;
  final DateTime sharedAt;
  final bool isLikedByMe;

  SharedTransformation({
    required this.id,
    required this.userName,
    this.userAvatarPath,
    this.beforeImagePath,
    this.beforeImageBytes,
    this.afterImagePath,
    this.afterImageBytes,
    this.beforeWeight,
    this.afterWeight,
    required this.beforeDate,
    required this.afterDate,
    this.note,
    this.likes = 0,
    this.comments = 0,
    required this.sharedAt,
    this.isLikedByMe = false,
  });

  /// Calcule la différence de poids
  double? get weightDifference {
    if (beforeWeight != null && afterWeight != null) {
      return afterWeight! - beforeWeight!;
    }
    return null;
  }

  /// Calcule la durée de la transformation
  int get durationDays => afterDate.difference(beforeDate).inDays;

  SharedTransformation copyWith({
    String? id,
    String? userName,
    String? userAvatarPath,
    String? beforeImagePath,
    Uint8List? beforeImageBytes,
    String? afterImagePath,
    Uint8List? afterImageBytes,
    double? beforeWeight,
    double? afterWeight,
    DateTime? beforeDate,
    DateTime? afterDate,
    String? note,
    int? likes,
    int? comments,
    DateTime? sharedAt,
    bool? isLikedByMe,
  }) {
    return SharedTransformation(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatarPath: userAvatarPath ?? this.userAvatarPath,
      beforeImagePath: beforeImagePath ?? this.beforeImagePath,
      beforeImageBytes: beforeImageBytes ?? this.beforeImageBytes,
      afterImagePath: afterImagePath ?? this.afterImagePath,
      afterImageBytes: afterImageBytes ?? this.afterImageBytes,
      beforeWeight: beforeWeight ?? this.beforeWeight,
      afterWeight: afterWeight ?? this.afterWeight,
      beforeDate: beforeDate ?? this.beforeDate,
      afterDate: afterDate ?? this.afterDate,
      note: note ?? this.note,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      sharedAt: sharedAt ?? this.sharedAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

/// Notifier singleton pour gérer les transformations partagées
class SharedTransformationNotifier extends ChangeNotifier {
  static final SharedTransformationNotifier _instance = SharedTransformationNotifier._internal();
  factory SharedTransformationNotifier() => _instance;
  SharedTransformationNotifier._internal() {
    _initDemoData();
  }

  final List<SharedTransformation> _transformations = [];

  List<SharedTransformation> get transformations => List.unmodifiable(_transformations);

  void _initDemoData() {
    // Données démo
    _transformations.addAll([
      SharedTransformation(
        id: 'demo_1',
        userName: 'Marie L.',
        userAvatarPath: 'assets/images/ChatGPT Image 1 déc. 2025, 15_43_23.png',
        beforeImagePath: 'assets/images/phase_0mois.png',
        afterImagePath: 'assets/images/phase_6mois.png',
        beforeWeight: 78.0,
        afterWeight: 65.0,
        beforeDate: DateTime.now().subtract(const Duration(days: 180)),
        afterDate: DateTime.now().subtract(const Duration(days: 7)),
        note: '6 mois de travail acharné ! 💪 Merci à mon coach pour le soutien.',
        likes: 124,
        comments: 18,
        sharedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      SharedTransformation(
        id: 'demo_2',
        userName: 'Thomas D.',
        userAvatarPath: 'assets/images/ChatGPT Image 25 nov. 2025, 18_27_24.png',
        beforeImagePath: 'assets/images/phase_0mois.png',
        afterImagePath: 'assets/images/phase_3mois.png',
        beforeWeight: 92.0,
        afterWeight: 82.0,
        beforeDate: DateTime.now().subtract(const Duration(days: 90)),
        afterDate: DateTime.now().subtract(const Duration(days: 3)),
        note: 'Prise de masse réussie ! 3 mois de discipline.',
        likes: 89,
        comments: 12,
        sharedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SharedTransformation(
        id: 'demo_3',
        userName: 'Sophie M.',
        userAvatarPath: 'assets/images/ChatGPT Image 1 déc. 2025, 15_43_39.png',
        beforeImagePath: 'assets/images/phase_0mois.png',
        afterImagePath: 'assets/images/phase_12mois.png',
        beforeWeight: 85.0,
        afterWeight: 62.0,
        beforeDate: DateTime.now().subtract(const Duration(days: 365)),
        afterDate: DateTime.now().subtract(const Duration(days: 10)),
        note: '1 an de transformation ! De la persévérance et beaucoup de sport.',
        likes: 256,
        comments: 34,
        sharedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ]);
  }

  /// Ajouter une nouvelle transformation partagée
  void addTransformation(SharedTransformation transformation) {
    _transformations.insert(0, transformation); // Ajouter en premier
    notifyListeners();
  }

  /// Toggle like sur une transformation
  void toggleLike(String id) {
    final index = _transformations.indexWhere((t) => t.id == id);
    if (index != -1) {
      final t = _transformations[index];
      _transformations[index] = t.copyWith(
        isLikedByMe: !t.isLikedByMe,
        likes: t.isLikedByMe ? t.likes - 1 : t.likes + 1,
      );
      notifyListeners();
    }
  }

  /// Supprimer une transformation (pour l'utilisateur qui l'a créée)
  void removeTransformation(String id) {
    _transformations.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}









