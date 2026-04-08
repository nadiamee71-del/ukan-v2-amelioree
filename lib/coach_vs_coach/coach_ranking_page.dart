import 'package:flutter/material.dart';
import '../models/coach_vs_coach.dart';
import 'duel_coach_page.dart';
import 'duel_history_page.dart';

class CoachRankingPage extends StatefulWidget {
  const CoachRankingPage({super.key});

  @override
  State<CoachRankingPage> createState() => _CoachRankingPageState();
}

class _CoachRankingPageState extends State<CoachRankingPage> {
  final _rankingNotifier = CoachRankingNotifier();

  @override
  void initState() {
    super.initState();
    _rankingNotifier.addListener(_onRankingChanged);
  }

  @override
  void dispose() {
    _rankingNotifier.removeListener(_onRankingChanged);
    super.dispose();
  }

  void _onRankingChanged() {
    if (mounted) setState(() {});
  }

  String _getRankBadge(int position) {
    switch (position) {
      case 0:
        return '🔥 Top 1';
      case 1:
        return '🥈 Top 2';
      case 2:
        return '🥉 Top 3';
      default:
        return '⚔️ Challenger';
    }
  }

  @override
  Widget build(BuildContext context) {
    final coaches = _rankingNotifier.coaches;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Classement'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DuelHistoryPage(),
                ),
              );
            },
            tooltip: 'Historique des duels',
          ),
          IconButton(
            icon: const Icon(Icons.sports_mma),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DuelCoachPage(),
                ),
              );
            },
            tooltip: 'Lancer un duel',
          ),
        ],
      ),
      body: Column(
        children: [
          // Bandeau narratif
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFC300).withOpacity(0.2),
                  const Color(0xFFFFC300).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Voici les héros de l\'aventure.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Monte dans le classement en réussissant tes missions.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                final position = index + 1;
                final isTopThree = position <= 3;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isTopThree ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: isTopThree
                          ? Border.all(
                              color: const Color(0xFFFFC300),
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Position
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isTopThree
                                ? const Color(0xFF111111)
                                : const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '$position',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isTopThree
                                    ? const Color(0xFFFFC300)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      coach.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (isTopThree)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFC300),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getRankBadge(index),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                coach.specialty,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${coach.wins}V / ${coach.losses}D',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111111),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${coach.score} pts',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DuelCoachPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.sports_mma),
                label: const Text('Lancer un duel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
