import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/difficulty_entry.dart';
import '../services/difficulty_service.dart';
import '../data/demo_exercises.dart';

enum DifficultyHistoryTimeFilter {
  week,
  month,
  threeMonths,
  year,
  all,
}

/// Page complète et redesignée d'historique des difficultés
class DifficultyHistoryPage extends StatefulWidget {
  const DifficultyHistoryPage({super.key});

  @override
  State<DifficultyHistoryPage> createState() => _DifficultyHistoryPageState();
}

class _DifficultyHistoryPageState extends State<DifficultyHistoryPage>
    with SingleTickerProviderStateMixin {
  final _difficultyService = DifficultyService();
  List<DifficultyEntry> _allEntries = [];
  bool _isLoading = true;
  DifficultyHistoryTimeFilter _timeFilter = DifficultyHistoryTimeFilter.month;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEntries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    
    // Charger les entrées réelles
    final entries = await _difficultyService.getAll();
    
    // Si vide, ajouter des données démo
    if (entries.isEmpty) {
      _allEntries = _generateDemoEntries();
    } else {
      _allEntries = entries;
    }
    
    setState(() => _isLoading = false);
  }

  List<DifficultyEntry> _generateDemoEntries() {
    final now = DateTime.now();
    final exercises = ['squat', 'bench_press', 'deadlift', 'pull_up', 'shoulder_press', 'lunges', 'plank', 'bicep_curl'];
    final List<DifficultyEntry> demoEntries = [];
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final exerciseId = exercises[i % exercises.length];
      // Simuler une progression (difficulté qui diminue avec le temps)
      final baseDifficulty = 7 - (i ~/ 5);
      final difficulty = (baseDifficulty + (i % 3) - 1).clamp(1, 10);
      
      demoEntries.add(DifficultyEntry(
        id: 'demo_$i',
        sessionId: 'session_${i % 10}',
        exerciseId: exerciseId,
        level: difficulty,
        date: date,
        comment: i % 5 == 0 ? 'Bonne séance, progression ressentie' : null,
        shared: i % 7 == 0,
      ));
    }
    
    return demoEntries;
  }

  List<DifficultyEntry> get _filteredEntries {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_timeFilter) {
      case DifficultyHistoryTimeFilter.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case DifficultyHistoryTimeFilter.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case DifficultyHistoryTimeFilter.threeMonths:
        startDate = now.subtract(const Duration(days: 90));
        break;
      case DifficultyHistoryTimeFilter.year:
        startDate = now.subtract(const Duration(days: 365));
        break;
      case DifficultyHistoryTimeFilter.all:
        return List.from(_allEntries)..sort((a, b) => b.date.compareTo(a.date));
    }
    
    return _allEntries
        .where((e) => e.date.isAfter(startDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Statistiques globales
  double get _averageDifficulty {
    if (_filteredEntries.isEmpty) return 0;
    return _filteredEntries.map((e) => e.level).reduce((a, b) => a + b) / _filteredEntries.length;
  }

  int get _totalSessions {
    return _filteredEntries.map((e) => e.sessionId).toSet().length;
  }

  int get _totalExercises {
    return _filteredEntries.map((e) => e.exerciseId).toSet().length;
  }

  // Tendance (amélioration ou dégradation)
  double get _trend {
    if (_filteredEntries.length < 4) return 0;
    final recent = _filteredEntries.take(_filteredEntries.length ~/ 2);
    final older = _filteredEntries.skip(_filteredEntries.length ~/ 2);
    
    final recentAvg = recent.map((e) => e.level).reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.map((e) => e.level).reduce((a, b) => a + b) / older.length;
    
    return olderAvg - recentAvg; // Positif = amélioration (difficulté diminue)
  }

  String _getExerciseName(String exerciseId) {
    final exercise = DemoExercises.allExercises.where((e) => e.id == exerciseId).firstOrNull;
    if (exercise != null) return exercise.name;
    
    // Mapping de secours
    final names = {
      'squat': 'Squats',
      'bench_press': 'Développé couché',
      'deadlift': 'Soulevé de terre',
      'pull_up': 'Tractions',
      'shoulder_press': 'Développé épaules',
      'lunges': 'Fentes',
      'plank': 'Gainage',
      'bicep_curl': 'Curl biceps',
      'pushup': 'Pompes',
      'crunch': 'Crunch',
    };
    return names[exerciseId] ?? exerciseId;
  }

  String _getDifficultyEmoji(int level) {
    if (level <= 2) return '😎';
    if (level <= 4) return '🙂';
    if (level <= 6) return '😤';
    if (level <= 8) return '🥵';
    return '💀';
  }

  Color _getDifficultyColor(int level) {
    if (level <= 2) return const Color(0xFF4CAF50);
    if (level <= 4) return const Color(0xFF8BC34A);
    if (level <= 6) return const Color(0xFFFFC107);
    if (level <= 8) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getDifficultyLabel(int level) {
    if (level <= 2) return 'Très facile';
    if (level <= 4) return 'Facile';
    if (level <= 6) return 'Modéré';
    if (level <= 8) return 'Difficile';
    return 'Extrême';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC300)))
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _buildSliverAppBar(),
              ],
              body: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSummaryTab(),
                        _buildHistoryTab(),
                        _buildProgressionTab(),
                        _buildByExerciseTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF0D0D0D)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre avec icône
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC300).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.insights,
                          color: Color(0xFFFFC300),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Historique des Difficultés',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Suivez votre progression',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Filtres de période
                  _buildTimeFilterChips(),
                  const SizedBox(height: 16),
                  
                  // Stats rapides
                  _buildQuickStats(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DifficultyHistoryTimeFilter.values.map((filter) {
          final isSelected = _timeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _timeFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFFFC300) 
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getTimeFilterLabel(filter),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTimeFilterLabel(DifficultyHistoryTimeFilter filter) {
    switch (filter) {
      case DifficultyHistoryTimeFilter.week:
        return '7 jours';
      case DifficultyHistoryTimeFilter.month:
        return '30 jours';
      case DifficultyHistoryTimeFilter.threeMonths:
        return '3 mois';
      case DifficultyHistoryTimeFilter.year:
        return '1 an';
      case DifficultyHistoryTimeFilter.all:
        return 'Tout';
    }
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.speed,
          value: _averageDifficulty.toStringAsFixed(1),
          label: 'Moyenne',
          color: _getDifficultyColor(_averageDifficulty.round()),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: _trend >= 0 ? Icons.trending_down : Icons.trending_up,
          value: '${_trend >= 0 ? '-' : '+'}${_trend.abs().toStringAsFixed(1)}',
          label: _trend >= 0 ? 'Amélioration' : 'À travailler',
          color: _trend >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.fitness_center,
          value: '$_totalSessions',
          label: 'Séances',
          color: const Color(0xFF9B59B6),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFFFC300),
        indicatorWeight: 3,
        labelColor: const Color(0xFFFFC300),
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Résumé'),
          Tab(text: 'Historique'),
          Tab(text: 'Progression'),
          Tab(text: 'Exercices'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: RÉSUMÉ
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distribution des difficultés
          _buildSectionTitle('📊 Distribution des difficultés'),
          const SizedBox(height: 12),
          _buildDifficultyDistribution(),
          const SizedBox(height: 24),
          
          // Records
          _buildSectionTitle('🏆 Vos Records'),
          const SizedBox(height: 12),
          _buildRecordsSection(),
          const SizedBox(height: 24),
          
          // Insights
          _buildSectionTitle('💡 Insights'),
          const SizedBox(height: 12),
          _buildInsightsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDifficultyDistribution() {
    final distribution = <int, int>{};
    for (int i = 1; i <= 10; i++) {
      distribution[i] = _filteredEntries.where((e) => e.level == i).length;
    }
    final maxCount = distribution.values.isEmpty ? 1 : distribution.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(10, (index) {
              final level = index + 1;
              final count = distribution[level] ?? 0;
              final height = maxCount > 0 ? (count / maxCount) * 100 : 0.0;
              
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: height + 10,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(level),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$level',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('Facile', const Color(0xFF4CAF50)),
              _buildLegendItem('Modéré', const Color(0xFFFFC107)),
              _buildLegendItem('Difficile', const Color(0xFFF44336)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRecordsSection() {
    // Trouver les records
    final easiestEntry = _filteredEntries.isEmpty 
        ? null 
        : _filteredEntries.reduce((a, b) => a.level < b.level ? a : b);
    final hardestEntry = _filteredEntries.isEmpty 
        ? null 
        : _filteredEntries.reduce((a, b) => a.level > b.level ? a : b);

    return Row(
      children: [
        Expanded(
          child: _buildRecordCard(
            emoji: '😎',
            title: 'Plus facile',
            exercise: easiestEntry != null ? _getExerciseName(easiestEntry.exerciseId) : '-',
            value: easiestEntry?.level.toString() ?? '-',
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRecordCard(
            emoji: '💪',
            title: 'Plus intense',
            exercise: hardestEntry != null ? _getExerciseName(hardestEntry.exerciseId) : '-',
            value: hardestEntry?.level.toString() ?? '-',
            color: const Color(0xFFF44336),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard({
    required String emoji,
    required String title,
    required String exercise,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exercise,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Niveau: ',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
              Text(
                '$value/10',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    final insights = <Map<String, dynamic>>[];
    
    if (_trend >= 1) {
      insights.add({
        'icon': Icons.trending_down,
        'color': const Color(0xFF4CAF50),
        'text': 'Excellente progression ! La difficulté perçue diminue de ${_trend.toStringAsFixed(1)} points.',
      });
    } else if (_trend <= -1) {
      insights.add({
        'icon': Icons.trending_up,
        'color': const Color(0xFFFF9800),
        'text': 'Les exercices semblent plus difficiles récemment. Pensez à la récupération.',
      });
    }
    
    if (_totalSessions >= 5) {
      insights.add({
        'icon': Icons.star,
        'color': const Color(0xFFFFC300),
        'text': 'Bravo ! $_totalSessions séances enregistrées. La régularité paie !',
      });
    }
    
    if (_averageDifficulty <= 5) {
      insights.add({
        'icon': Icons.fitness_center,
        'color': const Color(0xFF9B59B6),
        'text': 'Niveau moyen de ${_averageDifficulty.toStringAsFixed(1)}/10. Vous pouvez augmenter l\'intensité.',
      });
    }

    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.lightbulb,
        'color': Colors.white54,
        'text': 'Continuez à évaluer vos séances pour obtenir des insights personnalisés.',
      });
    }

    return Column(
      children: insights.map((insight) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (insight['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: (insight['color'] as Color).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              insight['icon'] as IconData,
              color: insight['color'] as Color,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                insight['text'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: HISTORIQUE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHistoryTab() {
    if (_filteredEntries.isEmpty) {
      return _buildEmptyState();
    }

    // Grouper par date
    final groupedByDate = <String, List<DifficultyEntry>>{};
    for (final entry in _filteredEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
      groupedByDate[dateKey] ??= [];
      groupedByDate[dateKey]!.add(entry);
    }

    final sortedDates = groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final entries = groupedByDate[dateKey]!;
        final date = DateTime.parse(dateKey);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de date
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatDateHeader(date),
                      style: const TextStyle(
                        color: Color(0xFFFFC300),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entries.length} évaluation${entries.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Cartes d'entrées
            ...entries.map((entry) => _buildHistoryCard(entry)),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);
    
    if (entryDate == today) return "Aujourd'hui";
    if (entryDate == yesterday) return 'Hier';
    return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
  }

  Widget _buildHistoryCard(DifficultyEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _getDifficultyColor(entry.level).withOpacity(0.15),
            const Color(0xFF1E1E2E),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getDifficultyColor(entry.level).withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEntryDetail(entry),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Emoji et niveau
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(entry.level).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDifficultyEmoji(entry.level),
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${entry.level}/10',
                        style: TextStyle(
                          color: _getDifficultyColor(entry.level),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getExerciseName(entry.exerciseId),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(entry.date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(entry.level).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getDifficultyLabel(entry.level),
                              style: TextStyle(
                                color: _getDifficultyColor(entry.level),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (entry.comment != null && entry.comment!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          entry.comment!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: PROGRESSION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProgressionTab() {
    if (_filteredEntries.isEmpty) {
      return _buildEmptyState();
    }

    // Calculer les moyennes par semaine
    final weeklyAverages = <String, double>{};
    final weeklyData = <String, List<int>>{};
    
    for (final entry in _filteredEntries) {
      final weekKey = _getWeekKey(entry.date);
      weeklyData[weekKey] ??= [];
      weeklyData[weekKey]!.add(entry.level);
    }
    
    for (final key in weeklyData.keys) {
      final values = weeklyData[key]!;
      weeklyAverages[key] = values.reduce((a, b) => a + b) / values.length;
    }

    final sortedWeeks = weeklyAverages.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('📈 Évolution hebdomadaire'),
          const SizedBox(height: 16),
          _buildProgressionChart(sortedWeeks, weeklyAverages),
          const SizedBox(height: 24),
          
          _buildSectionTitle('📅 Détail par semaine'),
          const SizedBox(height: 12),
          ...sortedWeeks.reversed.take(8).map((week) {
            final avg = weeklyAverages[week]!;
            final count = weeklyData[week]!.length;
            return _buildWeekSummaryCard(week, avg, count);
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getWeekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateFormat('yyyy-MM-dd').format(monday);
  }

  Widget _buildProgressionChart(List<String> weeks, Map<String, double> averages) {
    if (weeks.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Pas assez de données',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final recentWeeks = weeks.length > 8 ? weeks.sublist(weeks.length - 8) : weeks;
    final maxValue = 10.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recentWeeks.map((week) {
                final avg = averages[week] ?? 0;
                final height = (avg / maxValue) * 120;
                final color = _getDifficultyColor(avg.round());
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          avg.toStringAsFixed(1),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(20.0, 120.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                color,
                                color.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: recentWeeks.map((week) {
              final date = DateTime.parse(week);
              return Expanded(
                child: Text(
                  'S${_getWeekNumber(date)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return (daysDiff / 7).ceil();
  }

  Widget _buildWeekSummaryCard(String weekKey, double avg, int count) {
    final date = DateTime.parse(weekKey);
    final endDate = date.add(const Duration(days: 6));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getDifficultyColor(avg.round()).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                avg.toStringAsFixed(1),
                style: TextStyle(
                  color: _getDifficultyColor(avg.round()),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('d MMM', 'fr_FR').format(date)} - ${DateFormat('d MMM', 'fr_FR').format(endDate)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$count évaluation${count > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getDifficultyEmoji(avg.round()),
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 4: PAR EXERCICE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildByExerciseTab() {
    if (_filteredEntries.isEmpty) {
      return _buildEmptyState();
    }

    // Grouper par exercice
    final byExercise = <String, List<DifficultyEntry>>{};
    for (final entry in _filteredEntries) {
      byExercise[entry.exerciseId] ??= [];
      byExercise[entry.exerciseId]!.add(entry);
    }

    // Calculer les stats par exercice
    final exerciseStats = byExercise.entries.map((e) {
      final entries = e.value;
      entries.sort((a, b) => b.date.compareTo(a.date));
      final avg = entries.map((x) => x.level).reduce((a, b) => a + b) / entries.length;
      final latest = entries.first;
      final oldest = entries.last;
      final trend = entries.length > 1 ? oldest.level - latest.level : 0.0;
      
      return {
        'exerciseId': e.key,
        'count': entries.length,
        'average': avg,
        'latest': latest.level,
        'trend': trend,
        'entries': entries,
      };
    }).toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exerciseStats.length,
      itemBuilder: (context, index) {
        final stat = exerciseStats[index];
        return _buildExerciseCard(stat);
      },
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> stat) {
    final exerciseId = stat['exerciseId'] as String;
    final count = stat['count'] as int;
    final average = stat['average'] as double;
    final latest = stat['latest'] as int;
    final trend = stat['trend'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _getDifficultyColor(average.round()).withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showExerciseHistory(exerciseId, stat['entries'] as List<DifficultyEntry>),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icône exercice
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(average.round()).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: _getDifficultyColor(average.round()),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Nom et stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getExerciseName(exerciseId),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildMiniStat(Icons.repeat, '$count fois'),
                              const SizedBox(width: 12),
                              _buildMiniStat(Icons.speed, 'Moy: ${average.toStringAsFixed(1)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Tendance
                    Column(
                      children: [
                        Icon(
                          trend > 0 ? Icons.trending_down : (trend < 0 ? Icons.trending_up : Icons.trending_flat),
                          color: trend > 0 
                              ? const Color(0xFF4CAF50) 
                              : (trend < 0 ? const Color(0xFFFF9800) : Colors.white54),
                          size: 24,
                        ),
                        Text(
                          trend > 0 ? '+${trend.toStringAsFixed(1)}' : trend.toStringAsFixed(1),
                          style: TextStyle(
                            color: trend > 0 
                                ? const Color(0xFF4CAF50) 
                                : (trend < 0 ? const Color(0xFFFF9800) : Colors.white54),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // Barre de progression simplifiée
                Row(
                  children: [
                    Text(
                      'Dernière évaluation: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$latest/10 ${_getDifficultyEmoji(latest)}',
                      style: TextStyle(
                        color: _getDifficultyColor(latest),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white54),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS & BOTTOM SHEETS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showEntryDetail(DifficultyEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Emoji et niveau
            Text(
              _getDifficultyEmoji(entry.level),
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.level}/10 - ${_getDifficultyLabel(entry.level)}',
              style: TextStyle(
                color: _getDifficultyColor(entry.level),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Détails
            _buildDetailRow(Icons.fitness_center, 'Exercice', _getExerciseName(entry.exerciseId)),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today, 'Date', DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(entry.date)),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time, 'Heure', DateFormat('HH:mm').format(entry.date)),
            if (entry.comment != null && entry.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.comment, 'Note', entry.comment!),
            ],
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showExerciseHistory(String exerciseId, List<DifficultyEntry> entries) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getExerciseName(exerciseId),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${entries.length} évaluations',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              
              // Liste
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(entries[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assessment_outlined,
              size: 64,
              color: Color(0xFFFFC300),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune évaluation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Évaluez la difficulté de vos exercices\npour suivre votre progression',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
