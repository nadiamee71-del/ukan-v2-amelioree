import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../data/demo_exercises.dart';
import '../models/exercise_library_item.dart';
import '../models/rooms.dart';
import 'visio_session_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CREATE ROOM PAGE - Création de Room PRO
/// ═══════════════════════════════════════════════════════════════════════════

const Color _primaryBlue = Color(0xFF00D4FF);
const Color _secondaryPurple = Color(0xFF7B2FFF);
const Color _accentPink = Color(0xFFFF2D92);
const Color _successGreen = Color(0xFF00E676);
const Color _warningOrange = Color(0xFFFF9100);
const Color _darkBg = Color(0xFF0A0A1A);
const Color _cardBg = Color(0xFF1A1A2E);
const Color _cardBgLight = Color(0xFF252542);

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> with TickerProviderStateMixin {
  final _titleController = TextEditingController(text: 'Ma séance');
  final _roomsNotifier = RoomsNotifier();
  
  String _selectedSource = 'ukan'; // fitpro, coach, perso
  final List<ExerciseLibraryItem> _selectedExercises = [];
  int _exerciseDuration = 60; // seconds
  int _maxParticipants = 6;
  bool _cameraRequired = false;
  bool _micRequired = false;
  bool _competitionMode = false;
  
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Background
          _buildBackground(),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Title
                        _buildTitleSection(),
                        const SizedBox(height: 24),
                        
                        // Source Selection
                        _buildSourceSelection(),
                        const SizedBox(height: 24),
                        
                        // Exercise Selection
                        _buildExerciseSelection(),
                        const SizedBox(height: 24),
                        
                        // Settings
                        _buildSettingsSection(),
                        const SizedBox(height: 24),
                        
                        // Preview
                        _buildPreviewSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Create Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCreateButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _secondaryPurple.withOpacity(0.1),
            _darkBg,
            _darkBg,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Créer une Room',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primaryBlue.withOpacity(0.5)),
            ),
            child: Text(
              '${_selectedExercises.length} exercices',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_cardBg, _cardBgLight]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_primaryBlue, _secondaryPurple]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nom de la séance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Full Body Challenge',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: _darkBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Source des exercices',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSourceChip('ukan', '📚 Ukan', _primaryBlue),
            const SizedBox(width: 12),
            _buildSourceChip('coach', '👨‍🏫 Coach', _secondaryPurple),
            const SizedBox(width: 12),
            _buildSourceChip('perso', '✏️ Perso', _accentPink),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceChip(String value, String label, Color color) {
    final isSelected = _selectedSource == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedSource = value;
            _selectedExercises.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: [color, color.withOpacity(0.7)]) : null,
            color: isSelected ? null : _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_cardBg, _cardBgLight]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _warningOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fitness_center, color: _warningOrange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Exercices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showExercisePicker,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_selectedExercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _darkBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.fitness_center, color: Colors.white.withOpacity(0.3), size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun exercice sélectionné',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuie sur "Ajouter" pour choisir des exercices',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedExercises.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _selectedExercises.removeAt(oldIndex);
                  _selectedExercises.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final exercise = _selectedExercises[index];
                return _buildExerciseItem(exercise, index, key: ValueKey(exercise.id));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(ExerciseLibraryItem exercise, int index, {Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Drag handle
          const Icon(Icons.drag_handle, color: Colors.white38, size: 20),
          const SizedBox(width: 8),
          // Number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_primaryBlue, _secondaryPurple]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${exercise.category} • ${_exerciseDuration}s',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Remove
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white38, size: 20),
            onPressed: () {
              setState(() => _selectedExercises.removeAt(index));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_cardBg, _cardBgLight]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _successGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings, color: _successGreen, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Duration slider
          _buildSliderSetting(
            label: 'Durée par exercice',
            value: '$_exerciseDuration secondes',
            icon: Icons.timer,
            child: Slider(
              value: _exerciseDuration.toDouble(),
              min: 30,
              max: 120,
              divisions: 6,
              activeColor: _primaryBlue,
              inactiveColor: _primaryBlue.withOpacity(0.2),
              onChanged: (value) => setState(() => _exerciseDuration = value.toInt()),
            ),
          ),
          const SizedBox(height: 16),
          
          // Max participants
          _buildSliderSetting(
            label: 'Participants max',
            value: '$_maxParticipants personnes',
            icon: Icons.people,
            child: Slider(
              value: _maxParticipants.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              activeColor: _secondaryPurple,
              inactiveColor: _secondaryPurple.withOpacity(0.2),
              onChanged: (value) => setState(() => _maxParticipants = value.toInt()),
            ),
          ),
          const SizedBox(height: 16),
          
          // Toggles
          _buildToggleSetting('Caméra obligatoire', Icons.videocam, _cameraRequired, 
            (v) => setState(() => _cameraRequired = v)),
          _buildToggleSetting('Micro obligatoire', Icons.mic, _micRequired,
            (v) => setState(() => _micRequired = v)),
          _buildToggleSetting('Mode compétition', Icons.emoji_events, _competitionMode,
            (v) => setState(() => _competitionMode = v)),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required String value,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white54, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: _primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }

  Widget _buildToggleSetting(String label, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _darkBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? _successGreen : Colors.white38, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: value ? Colors.white : Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    if (_selectedExercises.isEmpty) return const SizedBox.shrink();
    
    final totalDuration = _selectedExercises.length * _exerciseDuration;
    final minutes = totalDuration ~/ 60;
    final seconds = totalDuration % 60;
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _successGreen.withOpacity(0.2),
                _primaryBlue.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _successGreen.withOpacity(_glowAnimation.value)),
            boxShadow: [
              BoxShadow(
                color: _successGreen.withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.preview, color: _successGreen, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Aperçu de la séance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPreviewStat('⏱️', '$minutes:${seconds.toString().padLeft(2, '0')}', 'Durée totale'),
                  _buildPreviewStat('🏋️', '${_selectedExercises.length}', 'Exercices'),
                  _buildPreviewStat('👥', '$_maxParticipants', 'Max participants'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    final canCreate = _titleController.text.isNotEmpty && _selectedExercises.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _darkBg.withOpacity(0),
            _darkBg,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canCreate ? _createRoom : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canCreate ? _successGreen : Colors.grey.shade800,
              foregroundColor: canCreate ? _darkBg : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: canCreate ? 8 : 0,
              shadowColor: _successGreen.withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(canCreate ? Icons.rocket_launch : Icons.block, size: 24),
                const SizedBox(width: 12),
                Text(
                  canCreate ? 'Créer la Room' : 'Ajoute des exercices',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExercisePicker() {
    List<ExerciseLibraryItem> availableExercises;
    String sourceTitle;
    
    switch (_selectedSource) {
      case 'coach':
        availableExercises = DemoExercises.allExercises.take(8).toList();
        sourceTitle = 'Exercices Coach';
        break;
      case 'perso':
        availableExercises = DemoExercises.allExercises.skip(8).take(6).toList();
        sourceTitle = 'Mes Exercices';
        break;
      default:
        availableExercises = DemoExercises.allExercises;
        sourceTitle = 'Bibliothèque Ukan';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_cardBg, _cardBgLight]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sourceTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_selectedExercises.length} sélectionné(s)',
                            style: const TextStyle(
                              color: _primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = availableExercises[index];
                    final isSelected = _selectedExercises.any((e) => e.id == exercise.id);
                    
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (isSelected) {
                            _selectedExercises.removeWhere((e) => e.id == exercise.id);
                          } else {
                            _selectedExercises.add(exercise);
                          }
                        });
                        setModalState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? _primaryBlue.withOpacity(0.2) : _darkBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? _primaryBlue : Colors.white.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getColorForCategory(exercise.category).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getIconForCategory(exercise.category),
                                color: _getColorForCategory(exercise.category),
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
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    exercise.category,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isSelected ? _primaryBlue : Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Done button
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Valider (${_selectedExercises.length} exercices)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'jambes':
        return _warningOrange;
      case 'haut du corps':
        return _primaryBlue;
      case 'abdos':
        return _successGreen;
      case 'full body':
        return _secondaryPurple;
      case 'cardio':
        return _accentPink;
      default:
        return _primaryBlue;
    }
  }

  IconData _getIconForCategory(String category) {
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
      default:
        return Icons.sports;
    }
  }

  void _createRoom() {
    HapticFeedback.heavyImpact();
    
    // Create room exercises
    final exercises = _selectedExercises.map((e) => RoomExercise(
      id: e.id,
      name: e.name,
      durationSeconds: _exerciseDuration,
      videoAsset: e.videoAsset,
      imageAsset: e.imageAsset,
      description: e.description,
    )).toList();
    
    _roomsNotifier.createRoom(_titleController.text, exercises: exercises);
    
    // Navigate to session
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => VisioSessionPage(roomId: _roomsNotifier.currentRoom!.id),
      ),
    );
  }
}


