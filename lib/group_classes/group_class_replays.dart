import 'package:flutter/material.dart';
import '../models/group_class.dart';
import '../models/group_class_notifier.dart';
import 'group_class_detail.dart';

/// Page Replays - Style Netflix
class GroupClassReplaysPage extends StatefulWidget {
  const GroupClassReplaysPage({super.key});

  @override
  State<GroupClassReplaysPage> createState() => _GroupClassReplaysPageState();
}

class _GroupClassReplaysPageState extends State<GroupClassReplaysPage> {
  late GroupClassNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = GroupClassNotifier();
    _notifier.initializeMockData();
    _notifier.addListener(_onNotifierChanged);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    super.dispose();
  }

  void _onNotifierChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildSection(
                    title: 'Top replays de la semaine',
                    subtitle: 'Les plus visionnés',
                    classes: _notifier.getPopularReplays(limit: 10),
                  ),
                  const SizedBox(height: 32),
                  _buildSection(
                    title: 'Pour débutants 🌱',
                    subtitle: 'Parfait pour commencer',
                    classes: _notifier.getReplaysByLevel(GroupClassLevel.beginner),
                  ),
                  const SizedBox(height: 32),
                  _buildSection(
                    title: 'Pour intermédiaires 🔥',
                    subtitle: 'Tu es prêt pour plus d\'intensité',
                    classes: _notifier.getReplaysByLevel(GroupClassLevel.intermediate),
                  ),
                  const SizedBox(height: 32),
                  _buildSection(
                    title: 'Pour avancés 💪',
                    subtitle: 'Challenge maximum',
                    classes: _notifier.getReplaysByLevel(GroupClassLevel.advanced),
                  ),
                  const SizedBox(height: 32),
                  _buildSection(
                    title: 'Les plus populaires',
                    subtitle: 'Les favoris de la communauté',
                    classes: _notifier.getReplays(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D111C),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Flèche de retour
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC300)),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.video_library_rounded,
            color: Color(0xFFFFC300),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Replays',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {
              // TODO: Recherche
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<GroupClass> classes,
  }) {
    if (classes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final groupClass = classes[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: _buildReplayCard(groupClass),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReplayCard(GroupClass groupClass) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupClassDetailPage(groupClass: groupClass),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D111C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(groupClass.category).withOpacity(0.4),
                      _getCategoryColor(groupClass.category).withOpacity(0.2),
                      const Color(0xFF050814),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    // Badge REPLAY
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'REPLAY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Durée en bas
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          groupClass.durationFormatted,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Infos
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupClass.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: groupClass.level == GroupClassLevel.beginner
                                ? Colors.green.withOpacity(0.2)
                                : groupClass.level == GroupClassLevel.intermediate
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${groupClass.level.emoji} ${groupClass.level.displayName}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: groupClass.level == GroupClassLevel.beginner
                                  ? Colors.green
                                  : groupClass.level == GroupClassLevel.intermediate
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: const Color(0xFFFFC300),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          groupClass.coachRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          groupClass.priceFormatted,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFC300),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'hiit':
        return Colors.orange;
      case 'yoga':
        return Colors.purple;
      case 'pilates':
        return Colors.pink;
      case 'strength':
        return Colors.blue;
      case 'cardio':
        return Colors.red;
      case 'dance':
        return Colors.pink;
      case 'boxing':
        return Colors.red;
      case 'stretching':
        return Colors.blue;
      case 'meditation':
        return Colors.indigo;
      default:
        return const Color(0xFFFFC300);
    }
  }
}







