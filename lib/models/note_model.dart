import 'package:flutter/material.dart';

/// Catégories de notes
enum NoteCategory {
  training,    // Entraînement
  nutrition,   // Nutrition
  motivation,  // Motivation
  general,     // Général
}

extension NoteCategoryExtension on NoteCategory {
  String get label {
    switch (this) {
      case NoteCategory.training:
        return 'Entraînement';
      case NoteCategory.nutrition:
        return 'Nutrition';
      case NoteCategory.motivation:
        return 'Motivation';
      case NoteCategory.general:
        return 'Général';
    }
  }

  IconData get icon {
    switch (this) {
      case NoteCategory.training:
        return Icons.fitness_center;
      case NoteCategory.nutrition:
        return Icons.restaurant;
      case NoteCategory.motivation:
        return Icons.emoji_events;
      case NoteCategory.general:
        return Icons.note_alt;
    }
  }

  Color get color {
    switch (this) {
      case NoteCategory.training:
        return const Color(0xFF4ECDC4); // Vert
      case NoteCategory.nutrition:
        return const Color(0xFFFF9F43); // Orange
      case NoteCategory.motivation:
        return const Color(0xFFFFC300); // Or
      case NoteCategory.general:
        return const Color(0xFF58A6FF); // Bleu
    }
  }
}

/// Modèle de note
class Note {
  final String id;
  String title;
  String content;
  NoteCategory category;
  bool isPinned;
  final DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.category = NoteCategory.general,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? title,
    String? content,
    NoteCategory? category,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Notifier pour gérer les notes
class NotesNotifier extends ChangeNotifier {
  final List<Note> _notes = [];

  NotesNotifier() {
    _loadMockNotes();
  }

  List<Note> get notes => List.unmodifiable(_notes);

  /// Notes triées : épinglées en premier, puis par date de mise à jour
  List<Note> get sortedNotes {
    final sorted = List<Note>.from(_notes);
    sorted.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return sorted;
  }

  /// Notes filtrées par catégorie
  List<Note> notesByCategory(NoteCategory category) {
    return sortedNotes.where((n) => n.category == category).toList();
  }

  /// Ajouter une note
  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  /// Mettre à jour une note
  void updateNote(String id, {String? title, String? content, NoteCategory? category, bool? isPinned}) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        title: title,
        content: content,
        category: category,
        isPinned: isPinned,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Supprimer une note
  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Épingler/désépingler une note
  void togglePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isPinned: !_notes[index].isPinned,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Charger des notes de démo
  void _loadMockNotes() {
    final now = DateTime.now();
    _notes.addAll([
      Note(
        id: 'note_1',
        title: 'Objectif du mois',
        content: '💪 Objectif : Atteindre 80kg de développé couché\n\nPlan :\n- Semaine 1-2 : 70kg x 8 reps\n- Semaine 3-4 : 75kg x 6 reps\n- Test max semaine 5',
        category: NoteCategory.training,
        isPinned: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Note(
        id: 'note_2',
        title: 'Recette shake protéiné',
        content: '🥤 Mon shake post-workout :\n\n- 300ml lait d\'amande\n- 30g whey vanille\n- 1 banane\n- 1 cuillère beurre de cacahuète\n- Glaçons\n\n= ~400 kcal, 35g protéines',
        category: NoteCategory.nutrition,
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Note(
        id: 'note_3',
        title: 'Citation motivation',
        content: '"Le succès n\'est pas final, l\'échec n\'est pas fatal : c\'est le courage de continuer qui compte."\n\n- Winston Churchill',
        category: NoteCategory.motivation,
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Note(
        id: 'note_4',
        title: 'Mesures à prendre',
        content: '📏 Prochaine prise de mesures : 15 du mois\n\n- Tour de bras\n- Tour de poitrine\n- Tour de taille\n- Tour de cuisses\n\nPenser à prendre les photos !',
        category: NoteCategory.general,
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }
}









