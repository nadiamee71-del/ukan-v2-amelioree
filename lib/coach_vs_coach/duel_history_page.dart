import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/coach_vs_coach.dart';

/// Page d'historique des duels avec barème, palmarès et statistiques
class DuelHistoryPage extends StatefulWidget {
  const DuelHistoryPage({super.key});

  @override
  State<DuelHistoryPage> createState() => _DuelHistoryPageState();
}

class _DuelHistoryPageState extends State<DuelHistoryPage>
    with SingleTickerProviderStateMixin {
  final _historyNotifier = DuelHistoryNotifier();
  DuelType? _selectedType;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyNotifier.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _historyNotifier.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  // Palette noir/or
  static const _darkBg = Color(0xFF0D1117);
  static const _cardBg = Color(0xFF161B22);
  static const _cardBgLight = Color(0xFF21262D);
  static const _primaryGold = Color(0xFFFFC300);
  static const _textLight = Color(0xFFF0F6FC);
  static const _textMuted = Color(0xFF8B949E);
  static const _borderColor = Color(0xFF30363D);

  @override
  Widget build(BuildContext context) {
    final history = _selectedType != null
        ? _historyNotifier.getDuelsByType(_selectedType!)
        : _historyNotifier.history;

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Historique des duels',
          style: TextStyle(fontWeight: FontWeight.w700, color: _textLight),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primaryGold,
          unselectedLabelColor: _textMuted,
          indicatorColor: _primaryGold,
          tabs: const [
            Tab(text: 'Historique', icon: Icon(Icons.history)),
            Tab(text: 'Palmarès', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtres par type de duel
          Container(
            padding: const EdgeInsets.all(16),
            color: _cardBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrer par type de duel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Tous', null),
                    _buildFilterChip('Coach vs Coach', DuelType.coachVsCoach),
                    _buildFilterChip('Coach vs Élève', DuelType.coachVsStudent),
                    _buildFilterChip('Élèves vs Élèves', DuelType.studentVsStudent),
                  ],
                ),
              ],
            ),
          ),

          // Contenu avec onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet Historique
                _buildHistoryTab(history),
                // Onglet Palmarès
                _buildPalmaresTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DuelType? type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      backgroundColor: _cardBgLight,
      selectedColor: _primaryGold.withOpacity(0.3),
      checkmarkColor: _primaryGold,
      side: BorderSide(color: isSelected ? _primaryGold : _borderColor),
      labelStyle: TextStyle(
        color: isSelected ? _primaryGold : _textMuted,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildHistoryTab(List<DuelHistory> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: _textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun duel dans l\'historique',
              style: TextStyle(
                fontSize: 16,
                color: _textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final duel = history[index];
        return _buildDuelHistoryCard(duel);
      },
    );
  }

  Widget _buildDuelHistoryCard(DuelHistory duel) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final hasResult = duel.result != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec type de duel et date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getDuelTypeLabel(duel.duelType),
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(duel.createdAt),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Corps de la carte
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Participants
                Row(
                  children: [
                    Expanded(
                      child: _buildParticipantInfo(
                        duel.participantAName,
                        duel.coachA.specialty,
                        hasResult && duel.result != null
                            ? (duel.result!.winner.id == duel.coachA.id ? 'Gagnant' : 'Perdant')
                            : null,
                        hasResult && duel.result != null
                            ? (duel.result!.winner.id == duel.coachA.id
                                ? duel.result!.winnerScoreChange
                                : duel.result!.loserScoreChange)
                            : null,
                        duel.scoreA,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildParticipantInfo(
                        duel.participantBName,
                        duel.opponent.specialty ?? 'Élève',
                        hasResult && duel.result != null
                            ? (duel.result!.loserName == duel.participantBName ? 'Perdant' : 'Gagnant')
                            : null,
                        hasResult && duel.result != null
                            ? (duel.result!.loserName == duel.participantBName
                                ? duel.result!.loserScoreChange
                                : duel.result!.winnerScoreChange)
                            : null,
                        duel.scoreB,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Informations du duel
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Défi : ${duel.challengeType}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      if (duel.duration != null) ...[
                        Icon(
                          Icons.timer_outlined,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${duel.duration!.inSeconds}s',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Scores finaux si disponibles
                if (duel.scoreA != null && duel.scoreB != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Score A',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${duel.scoreA}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Score B',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${duel.scoreB}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantInfo(
    String name,
    String specialty,
    String? status,
    int? pointsChange,
    int? score,
  ) {
    final isWinner = status == 'Gagnant';
    final isLoser = status == 'Perdant';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.green.shade50
            : isLoser
                ? Colors.red.shade50
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner
              ? Colors.green.shade200
              : isLoser
                  ? Colors.red.shade200
                  : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isWinner
                  ? Colors.green.shade900
                  : isLoser
                      ? Colors.red.shade900
                      : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            specialty,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          if (status != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isWinner ? Icons.emoji_events : Icons.arrow_downward,
                  size: 14,
                  color: isWinner ? Colors.green.shade700 : Colors.red.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isWinner ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
          if (pointsChange != null) ...[
            const SizedBox(height: 4),
            Text(
              pointsChange > 0 ? '+$pointsChange pts' : '$pointsChange pts',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: pointsChange > 0 ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPalmaresTab() {
    final palmaresByCategory = _selectedType != null
        ? _historyNotifier.getPalmaresByCategory(type: _selectedType)
        : _historyNotifier.getPalmaresByCategory();
    final stats = _historyNotifier.getStatsByType();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Statistiques globales
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistiques par type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...DuelType.values.map((type) {
                final stat = stats[type] ?? const DuelTypeStats(
                  totalDuels: 0,
                  completedDuels: 0,
                  totalParticipants: 0,
                );
                return _buildStatRow(_getDuelTypeLabel(type), stat);
              }),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Palmarès par catégorie
        Text(
          'Palmarès par catégorie ${_selectedType != null ? _getDuelTypeLabel(_selectedType!) : ''}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        if (palmaresByCategory.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun palmarès disponible',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ...palmaresByCategory.entries.map((categoryEntry) {
            final category = categoryEntry.key;
            final palmares = categoryEntry.value;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de la catégorie
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: const Color(0xFFFFC300),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${palmares.length} participant${palmares.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Liste des participants de cette catégorie
                ...palmares.asMap().entries.map((entry) {
                  final index = entry.key;
                  final entryData = entry.value;
                  return _buildPalmaresCard(entryData, index + 1);
                }),
                const SizedBox(height: 24),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildStatRow(String label, DuelTypeStats stats) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${stats.completedDuels}/${stats.totalDuels} duels',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalmaresCard(PalmaresEntry entry, int rank) {
    final isTopThree = rank <= 3;
    final rankColors = [
      const Color(0xFFFFD700), // Or
      const Color(0xFFC0C0C0), // Argent
      const Color(0xFFCD7F32), // Bronze
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isTopThree
            ? Border.all(
                color: rankColors[rank - 1],
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree ? rankColors[rank - 1] : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.specialty,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Victoires
          Column(
            children: [
              Icon(
                Icons.emoji_events,
                color: isTopThree ? rankColors[rank - 1] : Colors.grey.shade400,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.wins}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? rankColors[rank - 1] : Colors.black87,
                ),
              ),
              Text(
                entry.wins == 1 ? 'victoire' : 'victoires',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDuelTypeLabel(DuelType type) {
    switch (type) {
      case DuelType.coachVsCoach:
        return 'Coach vs Coach';
      case DuelType.coachVsStudent:
        return 'Coach vs Élève';
      case DuelType.studentVsStudent:
        return 'Élèves vs Élèves';
    }
  }
}

