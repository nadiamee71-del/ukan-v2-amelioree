import 'package:flutter/material.dart';
import '../models/group_class.dart';
import '../models/group_class_notifier.dart';
import 'group_class_card_live.dart';
import 'group_class_detail.dart';
import 'group_class_payment_demo.dart';
import 'group_class_planning_page.dart';

/// Page Live - Style TikTok
class GroupClassLivePage extends StatefulWidget {
  const GroupClassLivePage({super.key});

  @override
  State<GroupClassLivePage> createState() => _GroupClassLivePageState();
}

class _GroupClassLivePageState extends State<GroupClassLivePage>
    with SingleTickerProviderStateMixin {
  late GroupClassNotifier _notifier;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _notifier = GroupClassNotifier();
    _notifier.initializeMockData();
    _notifier.addListener(_onNotifierChanged);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    _tabController.dispose();
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
            // AppBar personnalisé
            _buildAppBar(),

            // Tabs
            _buildTabs(),

            // Contenu
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLiveNowSection(),
                  _buildUpcomingSection(),
                  _buildTodayScheduleSection(),
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
        color: const Color(0xFF161B22),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF30363D),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Flèche retour
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFFF0F6FC), size: 18),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.videocam_rounded,
            color: Color(0xFFFFC300),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Cours Collectifs Live',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFFF0F6FC),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Bouton Planning
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('📅', style: TextStyle(fontSize: 18)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupClassPlanningPage()),
              );
            },
          ),
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

  Widget _buildTabs() {
    return Container(
      color: const Color(0xFF0D111C),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFFFC300),
        indicatorWeight: 3,
        labelColor: const Color(0xFFFFC300),
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(text: '🔴 Live maintenant'),
          Tab(text: '⏰ Bientôt'),
          Tab(text: '📅 Aujourd\'hui'),
        ],
      ),
    );
  }

  Widget _buildLiveNowSection() {
    final liveClasses = _notifier.getLiveNow();

    if (liveClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D111C),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                color: Colors.white30,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun cours en direct',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reviens plus tard pour les cours live',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: liveClasses.length,
      itemBuilder: (context, index) {
        final groupClass = liveClasses[index];
        return GroupClassCardLive(
          groupClass: groupClass,
          onTap: () => _openDetailOrPayment(groupClass),
        );
      },
    );
  }

  Widget _buildUpcomingSection() {
    final upcomingClasses = _notifier.getUpcoming();

    if (upcomingClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D111C),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: Colors.white30,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun cours à venir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consulte le planning pour voir les prochains cours',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: upcomingClasses.length,
      itemBuilder: (context, index) {
        final groupClass = upcomingClasses[index];
        return GroupClassCardLive(
          groupClass: groupClass,
          onTap: () => _openDetailOrPayment(groupClass),
        );
      },
    );
  }

  Widget _buildTodayScheduleSection() {
    final today = DateTime.now();
    final todayClasses = _notifier.getScheduleForDay(today);

    if (todayClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D111C),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white30,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun cours aujourd\'hui',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consulte les replays ou le planning complet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Carrousel horizontal style TikTok Stories
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: todayClasses.length,
      itemBuilder: (context, index) {
        final groupClass = todayClasses[index];
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          child: _buildStoryCard(groupClass),
        );
      },
    );
  }

  Widget _buildStoryCard(GroupClass groupClass) {
    final isLive = groupClass.isLive;
    final isPast = groupClass.startDateTime != null &&
        groupClass.startDateTime!.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () => _openDetailOrPayment(groupClass),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLive
                ? [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)]
                : isPast
                    ? [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.1)]
                    : [
                        const Color(0xFFFFC300).withOpacity(0.3),
                        const Color(0xFFFFC300).withOpacity(0.1),
                      ],
          ),
          border: Border.all(
            color: isLive
                ? Colors.red.withOpacity(0.5)
                : isPast
                    ? Colors.blue.withOpacity(0.5)
                    : const Color(0xFFFFC300).withOpacity(0.5),
            width: 2,
          ),
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: Stack(
                  children: [
                    // Badge status
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLive
                              ? Colors.red
                              : isPast
                                  ? Colors.blue
                                  : const Color(0xFFFFC300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLive)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              isLive
                                  ? 'LIVE'
                                  : isPast
                                      ? 'TERMINÉ'
                                      : groupClass.countdownFormatted,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupClass.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          groupClass.durationFormatted,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
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
                            groupClass.level.emoji,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      groupClass.priceFormatted,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFC300),
                      ),
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

  void _openDetailOrPayment(GroupClass groupClass) {
    if (groupClass.isLive || groupClass.startDateTime != null) {
      // Ouvrir directement la page de paiement si live ou bientôt
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GroupClassPaymentDemoPage(groupClass: groupClass),
        ),
      );
    } else {
      // Ouvrir la page détail pour les replays
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GroupClassDetailPage(groupClass: groupClass),
        ),
      );
    }
  }
}







