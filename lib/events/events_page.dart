import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Palette
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

/// Catégories d'événements
enum EventCategory {
  boxing,
  mma,
  judo,
  karate,
  marathon,
  crossfit,
  bodybuilding,
  yoga,
  dance,
  cycling,
  swimming,
  football,
  basketball,
  tennis,
  other;

  String get displayName {
    switch (this) {
      case EventCategory.boxing: return 'Boxe';
      case EventCategory.mma: return 'MMA';
      case EventCategory.judo: return 'Judo';
      case EventCategory.karate: return 'Karaté';
      case EventCategory.marathon: return 'Marathon / Course';
      case EventCategory.crossfit: return 'CrossFit';
      case EventCategory.bodybuilding: return 'Bodybuilding';
      case EventCategory.yoga: return 'Yoga / Retraite';
      case EventCategory.dance: return 'Danse / Battle';
      case EventCategory.cycling: return 'Cyclisme';
      case EventCategory.swimming: return 'Natation';
      case EventCategory.football: return 'Football';
      case EventCategory.basketball: return 'Basketball';
      case EventCategory.tennis: return 'Tennis';
      case EventCategory.other: return 'Autre';
    }
  }

  String get emoji {
    switch (this) {
      case EventCategory.boxing: return '🥊';
      case EventCategory.mma: return '🤼';
      case EventCategory.judo: return '🥋';
      case EventCategory.karate: return '🥷';
      case EventCategory.marathon: return '🏃';
      case EventCategory.crossfit: return '🏋️';
      case EventCategory.bodybuilding: return '💪';
      case EventCategory.yoga: return '🧘';
      case EventCategory.dance: return '💃';
      case EventCategory.cycling: return '🚴';
      case EventCategory.swimming: return '🏊';
      case EventCategory.football: return '⚽';
      case EventCategory.basketball: return '🏀';
      case EventCategory.tennis: return '🎾';
      case EventCategory.other: return '🎯';
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.boxing: return const Color(0xFFFF6B6B);
      case EventCategory.mma: return const Color(0xFFDC2626);
      case EventCategory.judo: return const Color(0xFF58A6FF);
      case EventCategory.karate: return const Color(0xFF8B5CF6);
      case EventCategory.marathon: return const Color(0xFF10B981);
      case EventCategory.crossfit: return const Color(0xFFEF4444);
      case EventCategory.bodybuilding: return const Color(0xFFFFC300);
      case EventCategory.yoga: return const Color(0xFF4ECDC4);
      case EventCategory.dance: return const Color(0xFFEC4899);
      case EventCategory.cycling: return const Color(0xFFF59E0B);
      case EventCategory.swimming: return const Color(0xFF06B6D4);
      case EventCategory.football: return const Color(0xFF22C55E);
      case EventCategory.basketball: return const Color(0xFFF97316);
      case EventCategory.tennis: return const Color(0xFFEAB308);
      case EventCategory.other: return const Color(0xFF6B7280);
    }
  }
}

/// Modèle d'événement
class SportEvent {
  final String id;
  final String title;
  final EventCategory category;
  final DateTime dateTime;
  final String location;
  final String address;
  final String description;
  final double price; // 0 = gratuit
  final int maxParticipants;
  final int currentParticipants;
  final String organizerName;
  final String organizerAvatar;
  final bool isFeatured;

  SportEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.location,
    required this.address,
    required this.description,
    required this.price,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.organizerName,
    required this.organizerAvatar,
    this.isFeatured = false,
  });

  bool get isFree => price == 0;
  bool get isFull => currentParticipants >= maxParticipants;
  int get remainingPlaces => maxParticipants - currentParticipants;
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EventCategory? _selectedCategory;
  late List<SportEvent> _events;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateMockEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateMockEvents() {
    final now = DateTime.now();
    
    _events = [
      // Boxe
      SportEvent(
        id: '1',
        title: 'Gala de Boxe - Paris Fight Night 🥊',
        category: EventCategory.boxing,
        dateTime: now.add(const Duration(days: 5, hours: 20)),
        location: 'Paris',
        address: 'AccorHotels Arena, 8 Bd de Bercy',
        description: 'Grande soirée de boxe avec 8 combats professionnels ! Venez vibrer avec les meilleurs boxeurs français.',
        price: 45.00,
        maxParticipants: 5000,
        currentParticipants: 3200,
        organizerName: 'Boxing Events France',
        organizerAvatar: '🥊',
        isFeatured: true,
      ),
      SportEvent(
        id: '2',
        title: 'Championnat Régional de Boxe Amateur',
        category: EventCategory.boxing,
        dateTime: now.add(const Duration(days: 12, hours: 14)),
        location: 'Lyon',
        address: 'Palais des Sports de Gerland',
        description: 'Compétition régionale ouverte à tous les boxeurs amateurs licenciés.',
        price: 15.00,
        maxParticipants: 500,
        currentParticipants: 280,
        organizerName: 'Fédération Boxe Rhône',
        organizerAvatar: '🏆',
      ),

      // MMA
      SportEvent(
        id: '3',
        title: 'UFC Fight Night - Marseille 🤼',
        category: EventCategory.mma,
        dateTime: now.add(const Duration(days: 20, hours: 21)),
        location: 'Marseille',
        address: 'Orange Vélodrome',
        description: 'L\'UFC débarque à Marseille ! Main event : Cyril Gane vs Ciryl Gane. Ne manquez pas cet événement historique !',
        price: 89.00,
        maxParticipants: 30000,
        currentParticipants: 25000,
        organizerName: 'UFC Europe',
        organizerAvatar: '🔥',
        isFeatured: true,
      ),
      SportEvent(
        id: '4',
        title: 'Gala MMA Amateur - Fight Club',
        category: EventCategory.mma,
        dateTime: now.add(const Duration(days: 8, hours: 19)),
        location: 'Bordeaux',
        address: 'Arkéa Arena',
        description: '12 combats amateurs de haut niveau. Ambiance garantie !',
        price: 25.00,
        maxParticipants: 2000,
        currentParticipants: 1500,
        organizerName: 'Fight Club Bordeaux',
        organizerAvatar: '💪',
      ),

      // Marathon
      SportEvent(
        id: '5',
        title: 'Marathon de Paris 2025 🏃',
        category: EventCategory.marathon,
        dateTime: now.add(const Duration(days: 45, hours: 8)),
        location: 'Paris',
        address: 'Champs-Élysées - Départ',
        description: 'Le plus grand marathon de France ! 42,195 km à travers les plus beaux monuments parisiens.',
        price: 120.00,
        maxParticipants: 50000,
        currentParticipants: 42000,
        organizerName: 'ASO Running',
        organizerAvatar: '🏅',
        isFeatured: true,
      ),
      SportEvent(
        id: '6',
        title: 'Trail des Calanques - 30km',
        category: EventCategory.marathon,
        dateTime: now.add(const Duration(days: 15, hours: 7)),
        location: 'Marseille',
        address: 'Parc National des Calanques',
        description: 'Trail magnifique avec vue sur la mer ! Parcours technique de 30km.',
        price: 55.00,
        maxParticipants: 800,
        currentParticipants: 650,
        organizerName: 'Trail Provence',
        organizerAvatar: '🏔️',
      ),

      // CrossFit
      SportEvent(
        id: '7',
        title: 'CrossFit Games Qualifier - France 🏋️',
        category: EventCategory.crossfit,
        dateTime: now.add(const Duration(days: 30, hours: 9)),
        location: 'Toulouse',
        address: 'Zénith de Toulouse',
        description: 'Qualifications françaises pour les CrossFit Games ! Les meilleurs athlètes s\'affrontent.',
        price: 30.00,
        maxParticipants: 3000,
        currentParticipants: 2800,
        organizerName: 'CrossFit France',
        organizerAvatar: '🏆',
        isFeatured: true,
      ),

      // Judo
      SportEvent(
        id: '8',
        title: 'Tournoi International de Judo 🥋',
        category: EventCategory.judo,
        dateTime: now.add(const Duration(days: 18, hours: 10)),
        location: 'Paris',
        address: 'INSEP - Institut National du Sport',
        description: 'Tournoi international avec des judokas de 15 pays. Toutes catégories.',
        price: 20.00,
        maxParticipants: 1500,
        currentParticipants: 900,
        organizerName: 'Fédération Française Judo',
        organizerAvatar: '🥋',
      ),

      // Yoga
      SportEvent(
        id: '9',
        title: 'Retraite Yoga & Méditation - Weekend 🧘',
        category: EventCategory.yoga,
        dateTime: now.add(const Duration(days: 10, hours: 9)),
        location: 'Provence',
        address: 'Domaine de la Sérénité, Luberon',
        description: '2 jours de yoga, méditation et bien-être dans un cadre exceptionnel. Hébergement inclus.',
        price: 250.00,
        maxParticipants: 30,
        currentParticipants: 22,
        organizerName: 'Zen Retreats',
        organizerAvatar: '🙏',
      ),
      SportEvent(
        id: '10',
        title: 'Yoga Géant au Parc - Gratuit !',
        category: EventCategory.yoga,
        dateTime: now.add(const Duration(days: 3, hours: 10)),
        location: 'Lyon',
        address: 'Parc de la Tête d\'Or',
        description: 'Séance de yoga collective gratuite en plein air ! Apportez votre tapis.',
        price: 0,
        maxParticipants: 500,
        currentParticipants: 320,
        organizerName: 'Yoga Lyon',
        organizerAvatar: '☀️',
      ),

      // Danse
      SportEvent(
        id: '11',
        title: 'Battle Hip-Hop International 💃',
        category: EventCategory.dance,
        dateTime: now.add(const Duration(days: 25, hours: 18)),
        location: 'Paris',
        address: 'La Cigale, 120 Bd de Rochechouart',
        description: 'Les meilleurs danseurs s\'affrontent dans une battle épique ! Prix : 5000€',
        price: 35.00,
        maxParticipants: 1200,
        currentParticipants: 950,
        organizerName: 'Urban Dance Events',
        organizerAvatar: '🎤',
        isFeatured: true,
      ),

      // Cyclisme
      SportEvent(
        id: '12',
        title: 'Cyclosportive des Alpes 🚴',
        category: EventCategory.cycling,
        dateTime: now.add(const Duration(days: 40, hours: 7)),
        location: 'Grenoble',
        address: 'Départ Place Victor Hugo',
        description: '150km avec 3500m de dénivelé ! Cols mythiques : Galibier, Croix de Fer.',
        price: 65.00,
        maxParticipants: 2000,
        currentParticipants: 1800,
        organizerName: 'Cyclo Alpes',
        organizerAvatar: '🏔️',
      ),

      // Bodybuilding
      SportEvent(
        id: '13',
        title: 'Championnat de France Bodybuilding 💪',
        category: EventCategory.bodybuilding,
        dateTime: now.add(const Duration(days: 35, hours: 14)),
        location: 'Nice',
        address: 'Palais Nikaïa',
        description: 'Les plus beaux physiques de France s\'affrontent ! Catégories : Classic, Men\'s Physique, Bikini.',
        price: 40.00,
        maxParticipants: 2500,
        currentParticipants: 2100,
        organizerName: 'IFBB France',
        organizerAvatar: '🏆',
      ),

      // Football
      SportEvent(
        id: '14',
        title: 'Tournoi de Foot à 5 - Caritatif ⚽',
        category: EventCategory.football,
        dateTime: now.add(const Duration(days: 7, hours: 14)),
        location: 'Nantes',
        address: 'Complexe Sportif de la Beaujoire',
        description: 'Tournoi caritatif au profit des enfants malades. Inscrivez votre équipe !',
        price: 50.00,
        maxParticipants: 32,
        currentParticipants: 24,
        organizerName: 'Association Sourire',
        organizerAvatar: '❤️',
      ),
    ];

    // Trier par date
    _events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<SportEvent> get _filteredEvents {
    if (_selectedCategory == null) {
      return _events;
    }
    return _events.where((e) => e.category == _selectedCategory).toList();
  }

  Map<EventCategory, List<SportEvent>> get _groupedEvents {
    final grouped = <EventCategory, List<SportEvent>>{};
    for (final event in _filteredEvents) {
      if (!grouped.containsKey(event.category)) {
        grouped[event.category] = [];
      }
      grouped[event.category]!.add(event);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(child: _buildEventsList()),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    final featuredEvents = _events.where((e) => e.isFeatured).toList();
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
              const Text('🎉', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Événements',
                      style: TextStyle(
                        color: _textLight,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_events.length} événements à venir',
                      style: const TextStyle(color: _textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
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
          
          // Featured events carousel
          if (featuredEvents.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredEvents.length,
                itemBuilder: (context, index) {
                  return _buildFeaturedCard(featuredEvents[index]);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(SportEvent event) {
    return GestureDetector(
      onTap: () => _showEventDetail(event),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [event.category.color, event.category.color.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: event.category.color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              'À la une',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(event.category.emoji, style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(event.dateTime),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildCategoryFilter() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, '✨', 'Tous'),
          ...EventCategory.values.map((cat) => _buildCategoryChip(cat, cat.emoji, cat.displayName)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(EventCategory? category, String emoji, String label) {
    final isSelected = _selectedCategory == category;
    final color = category?.color ?? _primaryGold;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedCategory = category);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : _cardBgLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : _borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
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
  }

  Widget _buildEventsList() {
    final grouped = _groupedEvents;
    
    if (grouped.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final category = grouped.keys.elementAt(index);
        final events = grouped[category]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [category.color.withOpacity(0.2), category.color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: category.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.displayName,
                          style: const TextStyle(
                            color: _textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${events.length} événement${events.length > 1 ? 's' : ''}',
                          style: TextStyle(color: category.color, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Events list
            ...events.map((event) => _buildEventCard(event)),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(SportEvent event) {
    return GestureDetector(
      onTap: () => _showEventDetail(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [event.category.color.withOpacity(0.15), Colors.transparent],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Date badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _darkBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${event.dateTime.day}',
                          style: const TextStyle(
                            color: _primaryGold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getMonthShort(event.dateTime.month),
                          style: const TextStyle(color: _textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: _textLight,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: event.category.color, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(color: _textMuted, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: event.isFree ? _primaryGreen : _primaryGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.isFree ? 'Gratuit' : '${event.price.toStringAsFixed(0)}€',
                      style: TextStyle(
                        color: event.isFree ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  // Organizer
                  Text(event.organizerAvatar, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.organizerName,
                      style: const TextStyle(color: _textMuted, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Participants
                  Icon(Icons.people, color: _textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${event.currentParticipants}/${event.maxParticipants}',
                    style: TextStyle(
                      color: event.isFull ? _primaryRed : _textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time
                  Icon(Icons.access_time, color: _textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: _textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😢', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Aucun événement trouvé',
            style: TextStyle(color: _textMuted, fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => setState(() => _selectedCategory = null),
            icon: const Icon(Icons.refresh, color: _primaryGold),
            label: const Text('Voir tous les événements', style: TextStyle(color: _primaryGold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateEventSheet(),
      backgroundColor: _primaryGold,
      icon: const Icon(Icons.add, color: Colors.black),
      label: const Text(
        'Créer un événement',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showEventDetail(SportEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EventDetailSheet(
        event: event,
        onParticipate: () {
          Navigator.pop(context);
          _participateToEvent(event);
        },
      ),
    );
  }

  void _participateToEvent(SportEvent event) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(event.category.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Participer ?', style: TextStyle(color: _textLight, fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: const TextStyle(color: _textLight, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('📅 ${_formatDate(event.dateTime)}', style: const TextStyle(color: _textMuted)),
            Text('📍 ${event.location}', style: const TextStyle(color: _textMuted)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: event.isFree ? _primaryGreen.withOpacity(0.2) : _primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(event.isFree ? '🎉' : '💰', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    event.isFree ? 'Gratuit !' : '${event.price.toStringAsFixed(2)} €',
                    style: TextStyle(
                      color: event.isFree ? _primaryGreen : _primaryGold,
                      fontSize: 22,
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
                      const Expanded(child: Text('Inscription confirmée !')),
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
            child: Text(
              event.isFree ? 'S\'inscrire' : 'Payer et s\'inscrire',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateEventSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEventPage()),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  String _getMonthShort(int month) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }
}

// ═══════════════════════════════════════════════════════════
// EVENT DETAIL SHEET
// ═══════════════════════════════════════════════════════════
class _EventDetailSheet extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onParticipate;

  const _EventDetailSheet({required this.event, required this.onParticipate});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
          
          Flexible(
            child: SingleChildScrollView(
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
                          color: event.category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(event.category.emoji, style: const TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: event.category.color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event.category.displayName,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: _textLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Info rows
                  _buildInfoRow('📅', 'Date', _formatDateFull(event.dateTime)),
                  _buildInfoRow('⏰', 'Heure', '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}'),
                  _buildInfoRow('📍', 'Lieu', event.location),
                  _buildInfoRow('🗺️', 'Adresse', event.address),
                  _buildInfoRow('👥', 'Places', '${event.currentParticipants}/${event.maxParticipants} (${event.remainingPlaces} restantes)'),
                  _buildInfoRow('👤', 'Organisateur', event.organizerName),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(color: _textMuted, fontSize: 14, height: 1.5),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Price
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: event.isFree 
                            ? [_primaryGreen.withOpacity(0.2), _primaryGreen.withOpacity(0.1)]
                            : [_primaryGold.withOpacity(0.2), _primaryGold.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: event.isFree ? _primaryGreen.withOpacity(0.3) : _primaryGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(event.isFree ? '🎉' : '💰', style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Text(
                          event.isFree ? 'Gratuit !' : '${event.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: event.isFree ? _primaryGreen : _primaryGold,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: event.isFull ? null : onParticipate,
                      icon: Text(event.isFull ? '😢' : '🎉', style: const TextStyle(fontSize: 20)),
                      label: Text(
                        event.isFull ? 'Complet' : (event.isFree ? 'S\'inscrire gratuitement' : 'Participer'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.isFull ? _cardBgLight : _primaryGold,
                        foregroundColor: event.isFull ? _textMuted : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: _textMuted, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: _textLight, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _formatDateFull(DateTime date) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════
// CREATE EVENT PAGE
// ═══════════════════════════════════════════════════════════
class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _maxParticipantsController = TextEditingController(text: '100');
  
  EventCategory _selectedCategory = EventCategory.other;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isFree = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            const Text('Créer un événement', style: TextStyle(color: _textLight, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            _buildTextField(
              controller: _titleController,
              label: 'Nom de l\'événement *',
              hint: 'Ex: Gala de Boxe - Paris Fight Night',
              icon: Icons.title,
            ),
            const SizedBox(height: 20),
            
            // Catégorie
            const Text('Catégorie *', style: TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EventCategory.values.map((cat) {
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color : _cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? cat.color : _borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          cat.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Décris ton événement...',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            
            // Date et heure
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker()),
              ],
            ),
            const SizedBox(height: 20),
            
            // Lieu
            _buildTextField(
              controller: _locationController,
              label: 'Ville *',
              hint: 'Ex: Paris',
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Adresse complète',
              hint: 'Ex: AccorHotels Arena, 8 Bd de Bercy',
              icon: Icons.map,
            ),
            const SizedBox(height: 20),
            
            // Prix
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      const Text('Tarification', style: TextStyle(color: _textLight, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const Text('Gratuit', style: TextStyle(color: _textMuted, fontSize: 13)),
                      Switch(
                        value: !_isFree,
                        activeColor: _primaryGold,
                        onChanged: (v) => setState(() => _isFree = !v),
                      ),
                      const Text('Payant', style: TextStyle(color: _textMuted, fontSize: 13)),
                    ],
                  ),
                  if (!_isFree) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: _textLight, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        suffixText: '€',
                        suffixStyle: const TextStyle(color: _primaryGold, fontSize: 20),
                        filled: true,
                        fillColor: _cardBgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Places
            _buildTextField(
              controller: _maxParticipantsController,
              label: 'Nombre de places *',
              hint: '100',
              icon: Icons.people,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            
            // Bouton créer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createEvent,
                icon: const Text('🚀', style: TextStyle(fontSize: 20)),
                label: const Text(
                  'Publier l\'événement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: _textLight),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: _textMuted, size: 20),
            filled: true,
            fillColor: _cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primaryGold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _primaryGold)),
            child: child!,
          ),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: _primaryGold, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date', style: TextStyle(color: _textMuted, fontSize: 11)),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(color: _textLight, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _primaryGold)),
            child: child!,
          ),
        );
        if (time != null) setState(() => _selectedTime = time);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: _primaryGold, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Heure', style: TextStyle(color: _textMuted, fontSize: 11)),
                Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: _textLight, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createEvent() {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis les champs obligatoires !'), backgroundColor: _primaryRed),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(child: Text('Événement "${_titleController.text}" publié !')),
          ],
        ),
        backgroundColor: _primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}









