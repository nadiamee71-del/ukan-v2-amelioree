import 'package:flutter/material.dart';
import 'models/rooms.dart';
import 'models/demo_purchase.dart';
import 'models/subscription.dart';
import 'models/exercise_library_item.dart';
import 'data/demo_exercises.dart';
import 'rooms_session_page.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final _roomsNotifier = RoomsNotifier();
  final _workoutTitleController = TextEditingController(text: 'Full body 30 min');
  bool _enableDifficultyEvaluation = true; // Toggle pour activer/désactiver l'évaluation de difficulté
  
  // Sélection des exercices
  String _selectedExerciseSource = 'ukan'; // 'ukan', 'coach', 'perso'
  final List<ExerciseLibraryItem> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _roomsNotifier.addListener(_onRoomsChanged);
  }

  @override
  void dispose() {
    _roomsNotifier.removeListener(_onRoomsChanged);
    _workoutTitleController.dispose();
    super.dispose();
  }

  void _onRoomsChanged() {
    setState(() {});
  }

  void _createRoom() {
    final title = _workoutTitleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un titre pour la séance'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Convertir les exercices sélectionnés en RoomExercise
    List<RoomExercise>? exercises;
    if (_selectedExercises.isNotEmpty) {
      exercises = _selectedExercises.map((e) => RoomExercise(
        id: e.id,
        name: e.name,
        durationSeconds: 60, // Durée par défaut
        videoAsset: e.videoAsset,
        imageAsset: e.imageAsset,
        description: e.description,
      )).toList();
    }

    _roomsNotifier.createRoom(title, exercises: exercises);

    // Réinitialiser les champs
    _workoutTitleController.clear();
    setState(() {
      _selectedExercises.clear();
    });

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room créée avec succès ! Code : ${_roomsNotifier.currentRoom?.code}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildExerciseSourceSelector() {
    return Row(
      children: [
        _buildSourceChip(
          label: '📚 Ukan',
          value: 'ukan',
          isSelected: _selectedExerciseSource == 'ukan',
        ),
        const SizedBox(width: 8),
        _buildSourceChip(
          label: '👨‍🏫 Coach',
          value: 'coach',
          isSelected: _selectedExerciseSource == 'coach',
        ),
        const SizedBox(width: 8),
        _buildSourceChip(
          label: '✏️ Perso',
          value: 'perso',
          isSelected: _selectedExerciseSource == 'perso',
        ),
      ],
    );
  }

  Widget _buildSourceChip({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedExerciseSource = value;
            _selectedExercises.clear(); // Reset selection when source changes
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFC300) : const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFC300) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF111111) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _showExerciseSelector() {
    // Obtenir les exercices selon la source sélectionnée
    List<ExerciseLibraryItem> availableExercises;
    String sourceTitle;
    
    switch (_selectedExerciseSource) {
      case 'coach':
        // Exercices du coach (démo)
        availableExercises = DemoExercises.allExercises.take(5).toList();
        sourceTitle = 'Exercices de mon Coach';
        break;
      case 'perso':
        // Exercices créés par l'utilisateur (démo)
        availableExercises = DemoExercises.allExercises.skip(5).take(4).toList();
        sourceTitle = 'Mes exercices créés';
        break;
      default:
        // Bibliothèque Ukan
        availableExercises = DemoExercises.allExercises;
        sourceTitle = 'Bibliothèque Ukan';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fitness_center, color: Color(0xFF111111), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sourceTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${_selectedExercises.length} sélectionné(s)',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Liste des exercices
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = availableExercises[index];
                    final isSelected = _selectedExercises.any((e) => e.id == exercise.id);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFC300).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFC300)
                              : Colors.white.withValues(alpha: 0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedExercises.removeWhere((e) => e.id == exercise.id);
                            } else {
                              _selectedExercises.add(exercise);
                            }
                          });
                          setModalState(() {}); // Update modal state
                        },
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(exercise.category).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(exercise.category),
                            color: _getCategoryColor(exercise.category),
                          ),
                        ),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          exercise.category,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                        trailing: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFC300)
                                : Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFC300)
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Color(0xFF111111), size: 18)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bouton valider
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: const Color(0xFF111111),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _selectedExercises.isEmpty
                          ? 'Fermer'
                          : 'Valider (${_selectedExercises.length} exercices)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'jambes':
        return Colors.orange;
      case 'haut du corps':
        return Colors.blue;
      case 'abdos':
        return Colors.green;
      case 'full body':
        return Colors.purple;
      case 'cardio':
        return Colors.red;
      case 'mobilité':
        return Colors.teal;
      default:
        return const Color(0xFFFFC300);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'jambes':
        return Icons.directions_walk;
      case 'haut du corps':
        return Icons.fitness_center;
      case 'abdos':
        return Icons.sports_martial_arts;
      case 'full body':
        return Icons.accessibility_new;
      case 'cardio':
        return Icons.favorite;
      case 'mobilité':
        return Icons.self_improvement;
      default:
        return Icons.sports;
    }
  }

  void _joinDemoRoom() {
    _roomsNotifier.joinDemoRoom();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room démo rejointe !')),
    );
  }

  void _openSession() {
    final room = _roomsNotifier.currentRoom;
    if (room == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomsSessionPage(
          roomId: room.id,
          enableDifficultyEvaluation: _enableDifficultyEvaluation,
        ),
      ),
    );
  }

  void _showAddParticipantsDialog(BuildContext context, TrainingRoom room) {
    // Obtenir les participants déjà dans la room
    final currentParticipantIds = room.participants.map((p) => p.id).toSet();
    
    // Filtrer les membres disponibles (exclure ceux déjà présents)
    final availableMembers = RoomsNotifier.availableMembers
        .where((member) => !currentParticipantIds.contains(member.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Inviter des participants',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Liste des membres disponibles
            Expanded(
              child: availableMembers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tous les membres sont déjà invités',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: availableMembers.length,
                      itemBuilder: (context, index) {
                        final member = availableMembers[index];
                        final memberColor = _getColorForParticipant(member.id);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: memberColor,
                              child: Text(
                                member.avatarInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'En ligne • Disponible',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () {
                                _roomsNotifier.addParticipant(member);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${member.name} a été invité(e) à la room'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text('Inviter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Participants actuels
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${room.participants.length} participant${room.participants.length > 1 ? 's' : ''} dans la room',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.participants.map((p) {
                      final participantColor = _getColorForParticipant(p.id);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: participantColor,
                              child: Text(
                                p.avatarInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (p.id != 'you') ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  _roomsNotifier.removeParticipant(p.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${p.name} a quitté la room'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForParticipant(String participantId) {
    switch (participantId) {
      case 'you':
        return const Color(0xFF111111);
      case 'sarah':
        return Colors.purple.shade700;
      case 'bilel':
        return Colors.blue.shade700;
      case 'marie':
        return Colors.pink.shade700;
      case 'lucas':
        return Colors.green.shade700;
      case 'sophie':
        return Colors.orange.shade700;
      case 'thomas':
        return Colors.indigo.shade700;
      case 'julie':
        return Colors.red.shade700;
      case 'pierre':
        return Colors.cyan.shade700;
      default:
        return Colors.teal.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _roomsNotifier.currentRoom;
    final purchaseNotifier = DemoPurchaseNotifier();
    final subscriptionNotifier = SubscriptionNotifier();
    final hasPremium = purchaseNotifier.hasPremium || subscriptionNotifier.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Entraînement à plusieurs'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            onSelected: (value) {
              if (value == 'difficulty') {
                setState(() {
                  _enableDifficultyEvaluation = !_enableDifficultyEvaluation;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _enableDifficultyEvaluation
                          ? 'Évaluation de difficulté activée'
                          : 'Évaluation de difficulté désactivée',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'difficulty',
                child: Row(
                  children: [
                    Switch(
                      value: _enableDifficultyEvaluation,
                      onChanged: (value) {
                        setState(() {
                          _enableDifficultyEvaluation = value;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Évaluation de difficulté activée'
                                  : 'Évaluation de difficulté désactivée',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      activeColor: const Color(0xFFFFC300),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Activer l\'évaluation de la difficulté'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bandeau Mode démo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4CC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFC300),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF111111),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mode démo – paiements simulés',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bandeau Premium si pas acheté
              if (!hasPremium)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFC300),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: Color(0xFFFFC300),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fonctionnalité Premium : Abonnez-vous pour débloquer les Rooms.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Créer une room',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _workoutTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre de la séance',
                        hintText: 'Ex: Full body 30 min',
                        filled: true,
                        fillColor: Color(0xFFF4F4F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Source des exercices
                    const Text(
                      'Source des exercices',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExerciseSourceSelector(),
                    const SizedBox(height: 16),
                    
                    // Bouton sélectionner exercices
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showExerciseSelector,
                        icon: const Icon(Icons.fitness_center),
                        label: Text(
                          _selectedExercises.isEmpty
                              ? 'Sélectionner les exercices'
                              : '${_selectedExercises.length} exercice(s) sélectionné(s)',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111111),
                          side: BorderSide(
                            color: _selectedExercises.isEmpty
                                ? Colors.grey.shade400
                                : const Color(0xFFFFC300),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    
                    // Liste des exercices sélectionnés
                    if (_selectedExercises.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: _selectedExercises.asMap().entries.map((entry) {
                            final index = entry.key;
                            final exercise = entry.value;
                            return Container(
                              margin: EdgeInsets.only(bottom: index < _selectedExercises.length - 1 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFC300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          exercise.category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _selectedExercises.removeAt(index);
                                      });
                                    },
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _createRoom,
                        child: const Text(
                          'Créer une room',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ou rejoindre la room démo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _joinDemoRoom,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black26),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Rejoindre ROOM-1234 (démo)'),
                ),
              ),
              const SizedBox(height: 24),
              if (room != null) ...[
                const Text(
                  'Room actuelle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.workoutTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4CC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Code : ${room.code}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Participants',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: room.participants.map((p) {
                          return _ParticipantChip(participant: p);
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF111111),
                                side: const BorderSide(color: Color(0xFF111111)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Inviter'),
                              onPressed: () => _showAddParticipantsDialog(context, room),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF111111),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Lancer'),
                              onPressed: _openSession,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Aucune room sélectionnée pour le moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticipantChip extends StatelessWidget {
  final RoomParticipant participant;

  const _ParticipantChip({required this.participant});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: const Color(0xFF111111),
        child: Text(
          participant.avatarInitials,
          style: const TextStyle(
            color: Color(0xFFFFC300),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      label: Text(
        participant.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}

