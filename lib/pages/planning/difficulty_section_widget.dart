import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/difficulty_entry.dart';
import '../../services/difficulty_service.dart';
import '../../models/theme_notifier.dart';
import '../../models/planning.dart';
import 'session_details_page.dart';

enum DifficultySortMode {
  date,
  exercise,
  session,
}

enum DifficultyTimeFilter {
  day,
  week,
  month,
  year,
  all,
}

/// Widget pour la section "Mes niveaux de difficulté" avec tri
class DifficultySectionWidget extends StatefulWidget {
  const DifficultySectionWidget({super.key});

  @override
  State<DifficultySectionWidget> createState() => _DifficultySectionWidgetState();
}

class _DifficultySectionWidgetState extends State<DifficultySectionWidget> {
  final _difficultyService = DifficultyService();
  DifficultySortMode _sortMode = DifficultySortMode.date;
  DifficultyTimeFilter _timeFilter = DifficultyTimeFilter.all;
  List<DifficultyEntry> _allEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    final entries = await _difficultyService.getAll();
    setState(() {
      _allEntries = entries;
      _isLoading = false;
    });
  }

  List<DifficultyEntry> get _filteredAndSortedEntries {
    var entries = List<DifficultyEntry>.from(_allEntries);

    // Filtrage par période
    final now = DateTime.now();
    switch (_timeFilter) {
      case DifficultyTimeFilter.day:
        entries = entries.where((e) {
          return e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day;
        }).toList();
        break;
      case DifficultyTimeFilter.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        entries = entries.where((e) {
          return e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              e.date.isBefore(weekStart.add(const Duration(days: 7)));
        }).toList();
        break;
      case DifficultyTimeFilter.month:
        entries = entries.where((e) {
          return e.date.year == now.year && e.date.month == now.month;
        }).toList();
        break;
      case DifficultyTimeFilter.year:
        entries = entries.where((e) => e.date.year == now.year).toList();
        break;
      case DifficultyTimeFilter.all:
        // Pas de filtre
        break;
    }

    // Tri
    switch (_sortMode) {
      case DifficultySortMode.date:
        entries.sort((a, b) => b.date.compareTo(a.date)); // Plus récent en premier
        break;
      case DifficultySortMode.exercise:
        entries.sort((a, b) => a.exerciseId.compareTo(b.exerciseId));
        break;
      case DifficultySortMode.session:
        entries.sort((a, b) => a.sessionId.compareTo(b.sessionId));
        break;
    }

    return entries;
  }

  Color _getDifficultyColor(int level) {
    if (level <= 3) {
      return Colors.green;
    } else if (level <= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getSortModeLabel(DifficultySortMode mode) {
    switch (mode) {
      case DifficultySortMode.date:
        return 'Date';
      case DifficultySortMode.exercise:
        return 'Exercice';
      case DifficultySortMode.session:
        return 'Séance';
    }
  }

  String _getTimeFilterLabel(DifficultyTimeFilter filter) {
    switch (filter) {
      case DifficultyTimeFilter.day:
        return 'Jour';
      case DifficultyTimeFilter.week:
        return 'Semaine';
      case DifficultyTimeFilter.month:
        return 'Mois';
      case DifficultyTimeFilter.year:
        return 'Année';
      case DifficultyTimeFilter.all:
        return 'Tout';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFC300).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, color: Color(0xFFFFC300), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mes niveaux de difficulté',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filtres et tri
          Row(
            children: [
              Expanded(
                child: PopupMenuButton<DifficultyTimeFilter>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Période: ${_getTimeFilterLabel(_timeFilter)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                  onSelected: (value) {
                    setState(() {
                      _timeFilter = value;
                    });
                  },
                  itemBuilder: (context) => DifficultyTimeFilter.values.map((filter) {
                    return PopupMenuItem(
                      value: filter,
                      child: Text(_getTimeFilterLabel(filter)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PopupMenuButton<DifficultySortMode>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tri: ${_getSortModeLabel(_sortMode)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                  onSelected: (value) {
                    setState(() {
                      _sortMode = value;
                    });
                  },
                  itemBuilder: (context) => DifficultySortMode.values.map((mode) {
                    return PopupMenuItem(
                      value: mode,
                      child: Text(_getSortModeLabel(mode)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Liste des évaluations
          if (_isLoading)
            const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredAndSortedEntries.isEmpty)
            SizedBox(
              height: 80,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Aucune évaluation enregistrée',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: ListView.builder(
                shrinkWrap: false,
                itemCount: _filteredAndSortedEntries.length,
                itemBuilder: (context, index) {
                  final entry = _filteredAndSortedEntries[index];
                  return ListTile(
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(entry.level).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.level}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _getDifficultyColor(entry.level),
                        ),
                      ),
                    ),
                    title: Text(
                      'Exercice: ${entry.exerciseId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Séance: ${entry.sessionId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(entry.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    onTap: () {
                      // Naviguer vers les détails de la séance si possible
                      // Pour l'instant, on pourrait afficher un dialog avec les détails
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Détails de l\'évaluation'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Exercice: ${entry.exerciseId}'),
                              const SizedBox(height: 8),
                              Text('Séance: ${entry.sessionId}'),
                              const SizedBox(height: 8),
                              Text('Niveau: ${entry.level}/10'),
                              if (entry.comment != null && entry.comment!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Commentaire: ${entry.comment}'),
                              ],
                              const SizedBox(height: 8),
                              Text('Date: ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(entry.date)}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fermer'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

