import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/group_class.dart';
import 'group_class_create_page.dart';

// Palette ludique et colorée
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryPink = Color(0xFFEC4899);
const Color _primaryPurple = Color(0xFFA855F7);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

class GroupClassPlanningPage extends StatefulWidget {
  final bool isCoachView;
  
  const GroupClassPlanningPage({super.key, this.isCoachView = false});

  @override
  State<GroupClassPlanningPage> createState() => _GroupClassPlanningPageState();
}

class _GroupClassPlanningPageState extends State<GroupClassPlanningPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  int _selectedDayIndex = 0; // 0 = Lundi, 6 = Dimanche
  
  final List<String> _weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final List<String> _weekDaysFull = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  // Données mock des cours de la semaine
  late List<_ScheduledClass> _weeklyClasses;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateMockClasses();
    
    // Sélectionner le jour actuel
    final today = DateTime.now().weekday - 1; // 0-6
    _selectedDayIndex = today.clamp(0, 6);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateMockClasses() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    _weeklyClasses = [
      // Lundi
      _ScheduledClass(
        id: '1',
        title: 'HIIT Matinal 🔥',
        coachName: 'Sarah Martin',
        coachAvatar: '👩‍🦰',
        category: GroupClassCategory.hiit,
        level: GroupClassLevel.intermediate,
        dayIndex: 0,
        time: '07:00',
        durationMinutes: 30,
        price: 4.99,
        demoDurationMinutes: 5,
        participants: 23,
        maxParticipants: 30,
        accessories: ['Tapis', 'Bouteille d\'eau'],
      ),
      _ScheduledClass(
        id: '2',
        title: 'Yoga Flow Doux 🧘',
        coachName: 'Emma Dubois',
        coachAvatar: '👩',
        category: GroupClassCategory.yoga,
        level: GroupClassLevel.beginner,
        dayIndex: 0,
        time: '12:30',
        durationMinutes: 45,
        price: 5.99,
        demoDurationMinutes: 7,
        participants: 15,
        maxParticipants: 25,
        accessories: ['Tapis de yoga'],
      ),
      _ScheduledClass(
        id: '3',
        title: 'Boxe Cardio Punch! 🥊',
        coachName: 'Marc Dupont',
        coachAvatar: '👨‍🦱',
        category: GroupClassCategory.boxing,
        level: GroupClassLevel.intermediate,
        dayIndex: 0,
        time: '18:30',
        durationMinutes: 45,
        price: 6.99,
        demoDurationMinutes: 5,
        participants: 28,
        maxParticipants: 30,
        accessories: ['Gants', 'Bouteille d\'eau'],
      ),
      
      // Mardi
      _ScheduledClass(
        id: '4',
        title: 'Zumba Party 🎉',
        coachName: 'Sofia Rodriguez',
        coachAvatar: '💃',
        category: GroupClassCategory.zumba,
        level: GroupClassLevel.beginner,
        dayIndex: 1,
        time: '10:00',
        durationMinutes: 50,
        price: 4.99,
        demoDurationMinutes: 10,
        participants: 35,
        maxParticipants: 50,
        accessories: [],
      ),
      _ScheduledClass(
        id: '5',
        title: 'Judo Initiation 🥋',
        coachName: 'Kenji Tanaka',
        coachAvatar: '🥷',
        category: GroupClassCategory.judo,
        level: GroupClassLevel.beginner,
        dayIndex: 1,
        time: '14:00',
        durationMinutes: 60,
        price: 7.99,
        demoDurationMinutes: 5,
        participants: 12,
        maxParticipants: 20,
        accessories: ['Kimono'],
      ),
      _ScheduledClass(
        id: '6',
        title: 'CrossFit WOD 🏋️',
        coachName: 'Alex Strong',
        coachAvatar: '💪',
        category: GroupClassCategory.crossfit,
        level: GroupClassLevel.advanced,
        dayIndex: 1,
        time: '19:00',
        durationMinutes: 45,
        price: 6.99,
        demoDurationMinutes: 3,
        participants: 18,
        maxParticipants: 20,
        accessories: ['Serviette', 'Bouteille d\'eau'],
      ),
      
      // Mercredi
      _ScheduledClass(
        id: '7',
        title: 'Pilates Core 💫',
        coachName: 'Marie Laurent',
        coachAvatar: '👱‍♀️',
        category: GroupClassCategory.pilates,
        level: GroupClassLevel.intermediate,
        dayIndex: 2,
        time: '09:00',
        durationMinutes: 45,
        price: 5.99,
        demoDurationMinutes: 5,
        participants: 20,
        maxParticipants: 25,
        accessories: ['Tapis', 'Balle Pilates'],
      ),
      _ScheduledClass(
        id: '8',
        title: 'Danse Hip-Hop 🕺',
        coachName: 'DJ Mike',
        coachAvatar: '🎤',
        category: GroupClassCategory.dance,
        level: GroupClassLevel.beginner,
        dayIndex: 2,
        time: '17:00',
        durationMinutes: 60,
        price: 5.99,
        demoDurationMinutes: 8,
        participants: 25,
        maxParticipants: 40,
        accessories: [],
      ),
      
      // Jeudi
      _ScheduledClass(
        id: '9',
        title: 'Cycling Intense 🚴',
        coachName: 'Lucas Velo',
        coachAvatar: '🚴',
        category: GroupClassCategory.cycling,
        level: GroupClassLevel.intermediate,
        dayIndex: 3,
        time: '07:30',
        durationMinutes: 45,
        price: 6.99,
        demoDurationMinutes: 5,
        participants: 15,
        maxParticipants: 20,
        accessories: ['Serviette', 'Bouteille d\'eau'],
      ),
      _ScheduledClass(
        id: '10',
        title: 'Méditation Zen 🧘‍♀️',
        coachName: 'Yuki Sato',
        coachAvatar: '🙏',
        category: GroupClassCategory.meditation,
        level: GroupClassLevel.beginner,
        dayIndex: 3,
        time: '12:00',
        durationMinutes: 30,
        price: 3.99,
        demoDurationMinutes: 10,
        participants: 30,
        maxParticipants: 100,
        accessories: ['Coussin'],
      ),
      _ScheduledClass(
        id: '11',
        title: 'Karaté Katas 🥷',
        coachName: 'Hiroshi Yamamoto',
        coachAvatar: '🥋',
        category: GroupClassCategory.karate,
        level: GroupClassLevel.intermediate,
        dayIndex: 3,
        time: '18:00',
        durationMinutes: 60,
        price: 7.99,
        demoDurationMinutes: 5,
        participants: 10,
        maxParticipants: 15,
        accessories: ['Kimono'],
      ),
      
      // Vendredi
      _ScheduledClass(
        id: '12',
        title: 'Full Body Burn 🔥',
        coachName: 'Sarah Martin',
        coachAvatar: '👩‍🦰',
        category: GroupClassCategory.strength,
        level: GroupClassLevel.intermediate,
        dayIndex: 4,
        time: '08:00',
        durationMinutes: 45,
        price: 5.99,
        demoDurationMinutes: 5,
        participants: 22,
        maxParticipants: 30,
        accessories: ['Haltères', 'Tapis'],
      ),
      _ScheduledClass(
        id: '13',
        title: 'Stretching Relax 🤸',
        coachName: 'Emma Dubois',
        coachAvatar: '👩',
        category: GroupClassCategory.stretching,
        level: GroupClassLevel.beginner,
        dayIndex: 4,
        time: '19:30',
        durationMinutes: 30,
        price: 3.99,
        demoDurationMinutes: 7,
        participants: 18,
        maxParticipants: 40,
        accessories: ['Tapis'],
      ),
      
      // Samedi
      _ScheduledClass(
        id: '14',
        title: 'Cardio Dance Party 💃',
        coachName: 'Sofia Rodriguez',
        coachAvatar: '💃',
        category: GroupClassCategory.cardio,
        level: GroupClassLevel.beginner,
        dayIndex: 5,
        time: '10:00',
        durationMinutes: 50,
        price: 4.99,
        demoDurationMinutes: 10,
        participants: 40,
        maxParticipants: 50,
        accessories: [],
      ),
      _ScheduledClass(
        id: '15',
        title: 'Boxe Technique 🥊',
        coachName: 'Marc Dupont',
        coachAvatar: '👨‍🦱',
        category: GroupClassCategory.boxing,
        level: GroupClassLevel.advanced,
        dayIndex: 5,
        time: '14:00',
        durationMinutes: 60,
        price: 8.99,
        demoDurationMinutes: 5,
        participants: 12,
        maxParticipants: 15,
        accessories: ['Gants', 'Bandages'],
      ),
      
      // Dimanche
      _ScheduledClass(
        id: '16',
        title: 'Yoga Détente 🧘',
        coachName: 'Emma Dubois',
        coachAvatar: '👩',
        category: GroupClassCategory.yoga,
        level: GroupClassLevel.beginner,
        dayIndex: 6,
        time: '10:00',
        durationMinutes: 60,
        price: 5.99,
        demoDurationMinutes: 10,
        participants: 25,
        maxParticipants: 30,
        accessories: ['Tapis de yoga'],
      ),
      _ScheduledClass(
        id: '17',
        title: 'HIIT Express ⚡',
        coachName: 'Alex Strong',
        coachAvatar: '💪',
        category: GroupClassCategory.hiit,
        level: GroupClassLevel.intermediate,
        dayIndex: 6,
        time: '17:00',
        durationMinutes: 20,
        price: 2.99,
        demoDurationMinutes: 3,
        participants: 28,
        maxParticipants: 30,
        accessories: ['Tapis'],
      ),
    ];
  }

  List<_ScheduledClass> get _filteredClasses {
    return _weeklyClasses.where((c) {
      final matchesDay = c.dayIndex == _selectedDayIndex;
      final matchesCategory = _selectedCategory == null || 
          c.category.displayName == _selectedCategory;
      return matchesDay && matchesCategory;
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildWeekSelector(),
            _buildCategoryFilter(),
            Expanded(child: _buildClassesList()),
          ],
        ),
      ),
      floatingActionButton: widget.isCoachView ? _buildCoachFAB() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryPink.withOpacity(0.2), _primaryPurple.withOpacity(0.1)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cardBgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: _textLight, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        const Text(
                          'Planning des Cours',
                          style: TextStyle(
                            color: _textLight,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_weeklyClasses.length} cours cette semaine',
                      style: const TextStyle(color: _textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Bouton recherche
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _cardBgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.search, color: _textMuted, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == _selectedDayIndex;
          final isToday = index == DateTime.now().weekday - 1;
          final hasClasses = _weeklyClasses.any((c) => c.dayIndex == index);
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedDayIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [_primaryGold, _primaryOrange])
                    : null,
                color: isSelected ? null : (isToday ? _cardBgLight : Colors.transparent),
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: _primaryGold.withOpacity(0.5), width: 2)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    _weekDays[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateTime.now().add(Duration(days: index - (DateTime.now().weekday - 1))).day}',
                    style: TextStyle(
                      color: isSelected ? Colors.black : _textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasClasses) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black54 : _primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Tous', ...GroupClassCategory.values.map((c) => c.displayName)];
    
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = (cat == 'Tous' && _selectedCategory == null) ||
              cat == _selectedCategory;
          
          Color chipColor = _primaryGold;
          String emoji = '✨';
          
          if (cat != 'Tous') {
            final category = GroupClassCategory.values.firstWhere(
              (c) => c.displayName == cat,
              orElse: () => GroupClassCategory.hiit,
            );
            chipColor = category.color;
            emoji = category.emoji;
          }
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedCategory = cat == 'Tous' ? null : cat;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? chipColor : _cardBgLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? chipColor : _borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : _textMuted,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassesList() {
    final classes = _filteredClasses;
    
    if (classes.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return _ClassCard(
          scheduledClass: classes[index],
          onTap: () => _showClassDetail(classes[index]),
          onDemo: () => _watchDemo(classes[index]),
          onBook: () => _bookClass(classes[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😴', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Pas de cours ${_selectedCategory != null ? 'de $_selectedCategory' : ''}\nce ${_weekDaysFull[_selectedDayIndex].toLowerCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => setState(() => _selectedCategory = null),
            icon: const Icon(Icons.refresh, color: _primaryGold),
            label: const Text('Voir tous les cours', style: TextStyle(color: _primaryGold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroupClassCreatePage()),
        );
      },
      backgroundColor: _primaryGold,
      icon: const Icon(Icons.add, color: Colors.black),
      label: const Text(
        'Créer un cours',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showClassDetail(_ScheduledClass c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ClassDetailSheet(
        scheduledClass: c,
        onDemo: () {
          Navigator.pop(context);
          _watchDemo(c);
        },
        onBook: () {
          Navigator.pop(context);
          _bookClass(c);
        },
      ),
    );
  }

  void _watchDemo(_ScheduledClass c) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎬', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Démo de ${c.demoDurationMinutes} min - ${c.title}'),
            ),
          ],
        ),
        backgroundColor: _primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _bookClass(_ScheduledClass c) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Réserver ce cours ?',
                style: TextStyle(color: _textLight, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.title, style: const TextStyle(color: _textLight, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${c.category.emoji} ${c.category.displayName} • ${c.durationMinutes} min', 
                style: const TextStyle(color: _textMuted)),
            Text('👤 ${c.coachName}', style: const TextStyle(color: _textMuted)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${c.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: _primaryGold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${c.title} réservé !')),
                    ],
                  ),
                  backgroundColor: _primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Réserver', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MODÈLE COURS PLANIFIÉ
// ═══════════════════════════════════════════════════════════
class _ScheduledClass {
  final String id;
  final String title;
  final String coachName;
  final String coachAvatar;
  final GroupClassCategory category;
  final GroupClassLevel level;
  final int dayIndex; // 0 = Lundi
  final String time; // "HH:mm"
  final int durationMinutes;
  final double price;
  final int demoDurationMinutes;
  final int participants;
  final int maxParticipants;
  final List<String> accessories;

  _ScheduledClass({
    required this.id,
    required this.title,
    required this.coachName,
    required this.coachAvatar,
    required this.category,
    required this.level,
    required this.dayIndex,
    required this.time,
    required this.durationMinutes,
    required this.price,
    required this.demoDurationMinutes,
    required this.participants,
    required this.maxParticipants,
    this.accessories = const [],
  });

  bool get isFull => participants >= maxParticipants;
  double get fillRatio => participants / maxParticipants;
}

// ═══════════════════════════════════════════════════════════
// CARTE DE COURS
// ═══════════════════════════════════════════════════════════
class _ClassCard extends StatelessWidget {
  final _ScheduledClass scheduledClass;
  final VoidCallback onTap;
  final VoidCallback onDemo;
  final VoidCallback onBook;

  const _ClassCard({
    required this.scheduledClass,
    required this.onTap,
    required this.onDemo,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final c = scheduledClass;
    final categoryColor = c.category.color;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: categoryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header avec gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [categoryColor.withOpacity(0.3), categoryColor.withOpacity(0.1)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // Heure
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _darkBg.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          c.time,
                          style: const TextStyle(
                            color: _textLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${c.durationMinutes} min',
                          style: const TextStyle(color: _textMuted, fontSize: 11),
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
                          c.title,
                          style: const TextStyle(
                            color: _textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(c.coachAvatar, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              c.coachName,
                              style: const TextStyle(color: _textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Badge catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${c.category.emoji} ${c.category.displayName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Niveau + Places + Démo
                  Row(
                    children: [
                      _buildInfoChip(c.level.emoji, c.level.displayName),
                      const SizedBox(width: 8),
                      _buildInfoChip('👥', '${c.participants}/${c.maxParticipants}'),
                      const SizedBox(width: 8),
                      _buildInfoChip('🎬', '${c.demoDurationMinutes} min gratuit'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Accessoires
                  if (c.accessories.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.backpack, color: _textMuted, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            c.accessories.join(' • '),
                            style: const TextStyle(color: _textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Jauge de remplissage
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.fillRatio,
                      backgroundColor: _cardBgLight,
                      valueColor: AlwaysStoppedAnimation(
                        c.isFull ? _primaryRed : _primaryGreen,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Boutons
                  Row(
                    children: [
                      // Bouton Démo
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDemo,
                          icon: const Text('🎬', style: TextStyle(fontSize: 16)),
                          label: const Text('Démo gratuite'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryBlue,
                            side: const BorderSide(color: _primaryBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bouton Réserver
                      Expanded(
                        child: ElevatedButton(
                          onPressed: c.isFull ? null : onBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.isFull ? _cardBgLight : _primaryGold,
                            foregroundColor: c.isFull ? _textMuted : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            c.isFull ? 'Complet' : '${c.price.toStringAsFixed(2)} €',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
  }

  Widget _buildInfoChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// DETAIL SHEET
// ═══════════════════════════════════════════════════════════
class _ClassDetailSheet extends StatelessWidget {
  final _ScheduledClass scheduledClass;
  final VoidCallback onDemo;
  final VoidCallback onBook;

  const _ClassDetailSheet({
    required this.scheduledClass,
    required this.onDemo,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final c = scheduledClass;
    
    return Container(
      decoration: const BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(c.category.emoji, style: const TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.title,
                            style: const TextStyle(
                              color: _textLight,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${c.category.displayName} • ${c.level.displayName}',
                            style: TextStyle(color: c.category.color, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Infos
                _buildDetailRow('👤', 'Coach', c.coachName),
                _buildDetailRow('⏰', 'Horaire', '${c.time} (${c.durationMinutes} min)'),
                _buildDetailRow('👥', 'Places', '${c.participants}/${c.maxParticipants} participants'),
                _buildDetailRow('🎬', 'Démo gratuite', '${c.demoDurationMinutes} minutes'),
                if (c.accessories.isNotEmpty)
                  _buildDetailRow('🎒', 'Matériel', c.accessories.join(', ')),
                
                const SizedBox(height: 24),
                
                // Prix
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryGold.withOpacity(0.2), _primaryOrange.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primaryGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        '${c.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: _primaryGold,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDemo,
                        icon: const Text('🎬', style: TextStyle(fontSize: 18)),
                        label: const Text('Voir la démo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryBlue,
                          side: const BorderSide(color: _primaryBlue, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: c.isFull ? null : onBook,
                        icon: Text(c.isFull ? '😢' : '🎉', style: const TextStyle(fontSize: 18)),
                        label: Text(c.isFull ? 'Complet' : 'Réserver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.isFull ? _cardBgLight : _primaryGold,
                          foregroundColor: c.isFull ? _textMuted : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: _textMuted, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}









