part of ukan_main;

// Imports déplacés dans main.dart:
// import 'widgets/weekly_challenge_header.dart';
// import 'widgets/stories_header_row.dart';

/// Page d'accueil regroupant Dashboard et Publications.
class HomePage extends StatefulWidget {
  final VoidCallback onOpenNextWorkout;

  const HomePage({
    super.key,
    required this.onOpenNextWorkout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          _buildTopHeader(),
          _SegmentedControl(
            controller: _tabController,
            selectedIndex: _selectedTabIndex,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const PageScrollPhysics(),
              children: [
                DashboardTab(
                  onOpenNextWorkout: widget.onOpenNextWorkout,
                ),
                const PublicationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTopHeader() {
    if (_selectedTabIndex == 0) {
      return const WeeklyChallengeHeader();
    }
    return const StoriesHeaderRow();
  }
}

class _SegmentedControl extends StatelessWidget {
  final TabController controller;
  final int selectedIndex;

  const _SegmentedControl({
    required this.controller,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final int index = selectedIndex;
    // Palette sombre uniforme
    const Color cardBgLight = Color(0xFF21262D);
    const Color primaryGold = Color(0xFFFFC300);
    const Color borderColor = Color(0xFF30363D);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cardBgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _SegmentedButton(
            label: 'Dashboard',
            isActive: index == 0,
            onPressed: () => controller.animateTo(0),
          ),
          const SizedBox(width: 3),
          _SegmentedButton(
            label: 'Publications',
            isActive: index == 1,
            onPressed: () => controller.animateTo(1),
          ),
        ],
      ),
    );
  }
}

class _SegmentedButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _SegmentedButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Palette sombre uniforme
    const Color primaryGold = Color(0xFFFFC300);
    const Color cardBg = Color(0xFF161B22);
    const Color textMuted = Color(0xFF8B949E);

    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? primaryGold.withOpacity(0.15) : cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? primaryGold : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? primaryGold : textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}




