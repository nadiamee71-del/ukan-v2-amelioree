import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'match_profile.dart';
import 'match_engine.dart';
import '../data/demo_exercises.dart';
import '../models/exercise_library_item.dart';
import '../models/rooms.dart';
import '../rooms_session_page.dart';

/// ─────────────────────────────────────────────
/// Buddy Training™ - Sélecteur d'exercices
/// Proposer un exercice à un buddy
/// ─────────────────────────────────────────────

// Palette de couleurs sportives
const Color _bleuSportif = Color(0xFF2196F3);
const Color _bleuFonce = Color(0xFF1565C0);
const Color _bleuClair = Color(0xFF64B5F6);
const Color _orangeEnergie = Color(0xFFFF9800);
const Color _orangeFonce = Color(0xFFE65100);
const Color _vertSucces = Color(0xFF4CAF50);
const Color _fondSombre = Color(0xFF1A1A2E);
const Color _fondCarte = Color(0xFF16213E);
const Color _fondCarteLight = Color(0xFF1F2B47);

class BuddyExercisePickerPage extends StatefulWidget {
  final MatchProfile buddy;

  const BuddyExercisePickerPage({super.key, required this.buddy});

  @override
  State<BuddyExercisePickerPage> createState() => _BuddyExercisePickerPageState();
}

class _BuddyExercisePickerPageState extends State<BuddyExercisePickerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  ExerciseLibraryItem? _selectedExercise;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '18:00';
  String _selectedLocation = 'Parc';
  final TextEditingController _messageController = TextEditingController();

  final List<String> _categories = [
    'Toutes',
    'Jambes',
    'Haut du corps',
    'Abdos',
    'Full body',
    'Cardio',
    'Mobilité',
  ];

  final List<String> _timeSlots = [
    '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedCategory = 'Toutes';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  List<ExerciseLibraryItem> get _filteredExercises {
    var exercises = DemoExercises.allExercises;
    
    if (_searchQuery.isNotEmpty) {
      exercises = exercises.where((e) => 
        e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_selectedCategory != null && _selectedCategory != 'Toutes') {
      exercises = exercises.where((e) => e.category == _selectedCategory).toList();
    }
    
    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondSombre,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tabs
            _buildTabBar(),
            
            // Contenu
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExercisesList(),
                  _buildScheduleTab(),
                  _buildConfirmationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_fondCarte, _fondCarteLight],
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
                    color: _fondSombre,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proposer un exercice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'à ${widget.buddy.name}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _orangeEnergie,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar du buddy
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bleuSportif, _orangeEnergie],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.buddy.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Barre de recherche
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _fondSombre,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bleuSportif.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: _bleuClair),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white60),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _fondCarteLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(colors: [_bleuSportif, _bleuClair]),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(text: '1. Exercice'),
          Tab(text: '2. Quand'),
          Tab(text: '3. Envoyer'),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    return Column(
      children: [
        // Filtres catégories
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'Toutes';
                    });
                  },
                  backgroundColor: _fondCarteLight,
                  selectedColor: _bleuSportif,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? _bleuSportif : Colors.white.withOpacity(0.2),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Liste des exercices
        Expanded(
          child: _filteredExercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.white30),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun exercice trouvé',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    final isSelected = _selectedExercise?.id == exercise.id;
                    
                    return _ExerciseCard(
                      exercise: exercise,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedExercise = exercise;
                        });
                      },
                    );
                  },
                ),
        ),
        
        // Bouton suivant
        if (_selectedExercise != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _tabController.animateTo(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orangeEnergie,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Suivant',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercice sélectionné
          if (_selectedExercise != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _fondCarteLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _vertSucces.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _vertSucces.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.fitness_center, color: _vertSucces),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedExercise!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _selectedExercise!.category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white60),
                    onPressed: () => _tabController.animateTo(0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Date
          const Text(
            '📅 Quand ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _fondCarteLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _bleuSportif,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Changer'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Heure
          const Text(
            '⏰ À quelle heure ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((time) {
              final isSelected = _selectedTime == time;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = time),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [_bleuSportif, _bleuClair])
                        : null,
                    color: isSelected ? null : _fondCarteLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _bleuSportif : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Lieu
          const Text(
            '📍 Où ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BuddyProfileOptions.locations.map((location) {
              final isSelected = _selectedLocation == location;
              return GestureDetector(
                onTap: () => setState(() => _selectedLocation = location),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [_orangeEnergie, _orangeFonce])
                        : null,
                    color: isSelected ? null : _fondCarteLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _orangeEnergie : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    location,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Bouton suivant
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedExercise != null ? () => _tabController.animateTo(2) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orangeEnergie,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Suivant',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Récapitulatif
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_fondCarteLight, _fondCarte],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _bleuSportif.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.summarize, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Récapitulatif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Buddy
                _buildRecapRow(
                  '🤝 Buddy',
                  widget.buddy.name,
                ),
                
                // Exercice
                if (_selectedExercise != null)
                  _buildRecapRow(
                    '💪 Exercice',
                    _selectedExercise!.name,
                  ),
                
                // Date et heure
                _buildRecapRow(
                  '📅 Date',
                  '${_formatDate(_selectedDate)} à $_selectedTime',
                ),
                
                // Lieu
                _buildRecapRow(
                  '📍 Lieu',
                  _selectedLocation,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Message optionnel
          const Text(
            '💬 Ajouter un message (optionnel)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _fondCarteLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ex: On se retrouve à l\'entrée du parc ?',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: InputBorder.none,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Bouton envoyer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedExercise != null ? _sendProposal : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _vertSucces,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded),
                  const SizedBox(width: 8),
                  const Text(
                    'Envoyer la proposition',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bleuSportif.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _bleuSportif.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: _bleuClair, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.buddy.name} recevra une notification et pourra accepter ou proposer un autre créneau.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _bleuClair,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _bleuSportif,
              onPrimary: Colors.white,
              surface: _fondCarte,
              onSurface: Colors.white,
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

  String _formatDate(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  void _sendProposal() {
    if (_selectedExercise == null) return;

    HapticFeedback.heavyImpact();

    // Créer la proposition
    final proposal = BuddyWorkoutProposal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromUserId: 'user',
      toUserId: widget.buddy.id,
      exerciseId: _selectedExercise!.id,
      exerciseName: _selectedExercise!.name,
      exerciseCategory: _selectedExercise!.category,
      proposedDate: _selectedDate,
      proposedTime: _selectedTime,
      location: _selectedLocation,
      message: _messageController.text.isNotEmpty ? _messageController.text : null,
      createdAt: DateTime.now(),
    );

    // Enregistrer la proposition
    MatchEngine().proposeWorkout(proposal);

    // Afficher confirmation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_fondCarte, _fondSombre],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _vertSucces.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_vertSucces, _bleuSportif],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                '🎉 Proposition envoyée !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.buddy.name} va recevoir ta proposition d\'entraînement.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Bouton créer une Room Visio
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    _createVisioRoom();
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('🎥 Créer une Room Visio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orangeEnergie,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Créer une Room Visio avec le buddy et l'exercice sélectionné
  void _createVisioRoom() {
    if (_selectedExercise == null) return;

    final roomsNotifier = RoomsNotifier();
    
    // Créer l'exercice pour la room
    final roomExercise = RoomExercise(
      id: _selectedExercise!.id,
      name: _selectedExercise!.name,
      durationSeconds: 60,
      videoAsset: _selectedExercise!.videoAsset,
      imageAsset: _selectedExercise!.imageAsset,
      description: _selectedExercise!.description,
    );

    // Créer la room avec l'exercice
    roomsNotifier.createRoom(
      'Entraînement avec ${widget.buddy.name}',
      exercises: [roomExercise],
    );

    // Ajouter le buddy comme participant
    final buddyParticipant = RoomParticipant(
      id: widget.buddy.id,
      name: widget.buddy.name,
      avatarInitials: widget.buddy.name.substring(0, 2).toUpperCase(),
      progressPercent: 0,
      isOwner: false,
    );
    roomsNotifier.addParticipant(buddyParticipant);

    // Naviguer vers la session
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomsSessionPage(
          roomId: roomsNotifier.currentRoom!.id,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget carte exercice
// ─────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final ExerciseLibraryItem exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [_bleuSportif.withOpacity(0.3), _bleuFonce.withOpacity(0.3)],
              )
            : null,
        color: isSelected ? null : _fondCarteLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? _bleuSportif : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image ou icône
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(exercise.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: exercise.imageAsset != null && exercise.imageAsset!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            exercise.imageAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              _getCategoryIcon(exercise.category),
                              color: _getCategoryColor(exercise.category),
                              size: 28,
                            ),
                          ),
                        )
                      : Icon(
                          _getCategoryIcon(exercise.category),
                          color: _getCategoryColor(exercise.category),
                          size: 28,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(exercise.category).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getCategoryColor(exercise.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getDifficultyLabel(exercise.difficulty),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_vertSucces, _bleuSportif]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Jambes':
        return _orangeEnergie;
      case 'Haut du corps':
        return _bleuSportif;
      case 'Abdos':
        return _vertSucces;
      case 'Full body':
        return Colors.purple;
      case 'Cardio':
        return Colors.red;
      case 'Mobilité':
        return Colors.teal;
      default:
        return _bleuClair;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Jambes':
        return Icons.directions_walk;
      case 'Haut du corps':
        return Icons.fitness_center;
      case 'Abdos':
        return Icons.sports_martial_arts;
      case 'Full body':
        return Icons.accessibility_new;
      case 'Cardio':
        return Icons.favorite;
      case 'Mobilité':
        return Icons.self_improvement;
      default:
        return Icons.sports;
    }
  }

  String _getDifficultyLabel(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return '🌱 Débutant';
      case ExerciseDifficulty.intermediate:
        return '💪 Intermédiaire';
      case ExerciseDifficulty.advanced:
        return '🔥 Avancé';
    }
  }
}

