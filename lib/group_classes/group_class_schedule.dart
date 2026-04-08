import 'package:flutter/material.dart';
import '../models/group_class.dart';
import '../models/group_class_notifier.dart';
import 'group_class_card_schedule.dart';
import 'group_class_card_live.dart';
import 'group_class_detail.dart';
import 'group_class_payment_demo.dart';

/// Page Planning - Mix TikTok/Netflix
class GroupClassSchedulePage extends StatefulWidget {
  const GroupClassSchedulePage({super.key});

  @override
  State<GroupClassSchedulePage> createState() => _GroupClassSchedulePageState();
}

class _GroupClassSchedulePageState extends State<GroupClassSchedulePage> {
  late GroupClassNotifier _notifier;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _notifier = GroupClassNotifier();
    _notifier.initializeMockData();
    _notifier.addListener(_onNotifierChanged);
    _selectedDate = DateTime.now();
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
    final upcoming = _notifier.getUpcoming(maxMinutes: 240);
    final todayClasses = _notifier.getScheduleForDay(_selectedDate);

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
                  // Section TikTok: Cours imminents
                  if (upcoming.isNotEmpty) ...[
                    _buildImminentSection(upcoming),
                    const SizedBox(height: 32),
                  ],

                  // Section Netflix: Planning sur 7 jours
                  _buildScheduleSection(todayClasses),
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
          const Icon(
            Icons.calendar_today_rounded,
            color: Color(0xFFFFC300),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Planning',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          TextButton(
            onPressed: _selectDate,
            child: Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                color: Color(0xFFFFC300),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImminentSection(List<GroupClass> upcoming) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Color(0xFFFFC300),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Cours imminents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 500,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: upcoming.length,
            itemBuilder: (context, index) {
              final groupClass = upcoming[index];
              return Container(
                width: 320,
                margin: const EdgeInsets.only(right: 16),
                child: GroupClassCardLive(
                  groupClass: groupClass,
                  onTap: () => _openDetailOrPayment(groupClass),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(List<GroupClass> classes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Planning du jour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatFullDate(_selectedDate),
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
        if (classes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
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
                      Icons.event_busy_rounded,
                      color: Colors.white30,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucun cours ce jour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: classes.map((groupClass) {
                return GroupClassCardSchedule(
                  groupClass: groupClass,
                  onTap: () => _openDetailOrPayment(groupClass),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Aujourd\'hui';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Demain';
    }
    return '${date.day}/${date.month}';
  }

  String _formatFullDate(DateTime date) {
    const weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: const Color(0xFFFFC300),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC300),
              surface: Color(0xFF0D111C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _openDetailOrPayment(GroupClass groupClass) {
    if (groupClass.isLive || groupClass.startDateTime != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GroupClassPaymentDemoPage(groupClass: groupClass),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GroupClassDetailPage(groupClass: groupClass),
        ),
      );
    }
  }
}







