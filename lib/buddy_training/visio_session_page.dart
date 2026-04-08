import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/rooms.dart';
import 'countdown_overlay.dart';
import 'session_summary_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VISIO SESSION PAGE - Session d'entraînement en LIVE PRO
/// ═══════════════════════════════════════════════════════════════════════════

const Color _primaryBlue = Color(0xFF00D4FF);
const Color _secondaryPurple = Color(0xFF7B2FFF);
const Color _accentPink = Color(0xFFFF2D92);
const Color _successGreen = Color(0xFF00E676);
const Color _warningOrange = Color(0xFFFF9100);
const Color _warningRed = Color(0xFFFF4757);
const Color _darkBg = Color(0xFF0A0A1A);
const Color _cardBg = Color(0xFF1A1A2E);

class VisioSessionPage extends StatefulWidget {
  final String roomId;
  
  const VisioSessionPage({super.key, required this.roomId});

  @override
  State<VisioSessionPage> createState() => _VisioSessionPageState();
}

class _VisioSessionPageState extends State<VisioSessionPage> with TickerProviderStateMixin {
  final _roomsNotifier = RoomsNotifier();
  
  // Timers
  Timer? _sessionTimer;
  Timer? _exerciseTimer;
  Timer? _progressTimer;
  int _totalElapsedSeconds = 0;
  
  // State
  bool _isCountdownActive = true;
  int _countdownValue = 3;
  bool _isExercisePaused = false;
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isSessionStarted = false;
  String? _pinnedParticipantId;
  
  // Video
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  
  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  // Chat reactions
  final List<Map<String, dynamic>> _reactions = [];

  @override
  void initState() {
    super.initState();
    _roomsNotifier.addListener(_onRoomChanged);
    _initAnimations();
    
    // Start countdown after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCountdown();
    });
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _roomsNotifier.removeListener(_onRoomChanged);
    _sessionTimer?.cancel();
    _exerciseTimer?.cancel();
    _progressTimer?.cancel();
    _videoController?.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onRoomChanged() {
    if (mounted) setState(() {});
  }

  void _startCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdownValue = 3;
    });
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_countdownValue > 0) {
        HapticFeedback.mediumImpact();
        setState(() => _countdownValue--);
      } else {
        timer.cancel();
        setState(() => _isCountdownActive = false);
        _startSession();
      }
    });
  }

  void _startSession() {
    setState(() => _isSessionStarted = true);
    _initializeVideo();
    _startTimers();
  }

  void _initializeVideo() async {
    final room = _roomsNotifier.currentRoom;
    final exercise = room?.currentExercise;
    
    if (exercise?.videoAsset != null) {
      try {
        _videoController = VideoPlayerController.asset(exercise!.videoAsset!);
        await _videoController!.initialize();
        _videoController!.setLooping(true);
        if (!_isExercisePaused) _videoController!.play();
        setState(() => _videoInitialized = true);
      } catch (e) {
        debugPrint('Video error: $e');
      }
    }
  }

  void _startTimers() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _totalElapsedSeconds++);
    });
    
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isExercisePaused) return;
      
      final room = _roomsNotifier.currentRoom;
      if (room?.currentExercise == null) return;
      
      final newElapsed = room!.currentExerciseElapsedSeconds + 1;
      final duration = room.currentExercise!.durationSeconds;
      
      if (newElapsed >= duration) {
        _roomsNotifier.updateCurrentRoom(
          room.copyWith(currentExerciseElapsedSeconds: duration),
        );
        
        if (room.hasNextExercise) {
          _showExerciseTransition();
        } else {
          _finishSession();
        }
      } else {
        _roomsNotifier.updateCurrentRoom(
          room.copyWith(currentExerciseElapsedSeconds: newElapsed),
        );
      }
    });
    
    // Simulate other participants progress
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || _isExercisePaused) return;
      _simulateParticipantsProgress();
    });
  }

  void _simulateParticipantsProgress() {
    final room = _roomsNotifier.currentRoom;
    if (room == null) return;
    
    final updated = room.participants.map((p) {
      if (!p.isOwner) {
        final increment = 2 + math.Random().nextInt(5);
        return p.copyWith(
          progressPercent: (p.progressPercent + increment).clamp(0, 100),
        );
      }
      return p;
    }).toList();
    
    _roomsNotifier.updateCurrentRoom(room.copyWith(participants: updated));
  }

  void _showExerciseTransition() {
    _videoController?.pause();
    
    setState(() {
      _isCountdownActive = true;
      _countdownValue = 3;
    });
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_countdownValue > 0) {
        HapticFeedback.mediumImpact();
        setState(() => _countdownValue--);
      } else {
        timer.cancel();
        setState(() => _isCountdownActive = false);
        _roomsNotifier.nextExercise();
        _videoController?.dispose();
        _videoController = null;
        _videoInitialized = false;
        _initializeVideo();
      }
    });
  }

  void _togglePause() {
    HapticFeedback.mediumImpact();
    setState(() => _isExercisePaused = !_isExercisePaused);
    if (_isExercisePaused) {
      _videoController?.pause();
    } else {
      _videoController?.play();
    }
  }

  void _finishSession() {
    _sessionTimer?.cancel();
    _exerciseTimer?.cancel();
    _progressTimer?.cancel();
    _videoController?.pause();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SessionSummaryPage(
          totalSeconds: _totalElapsedSeconds,
          exercisesCompleted: _roomsNotifier.currentRoom?.exercises.length ?? 0,
          participants: _roomsNotifier.currentRoom?.participants ?? [],
        ),
      ),
    );
  }

  void _addReaction(String emoji) {
    HapticFeedback.lightImpact();
    setState(() {
      _reactions.add({
        'emoji': emoji,
        'x': math.Random().nextDouble() * 0.8 + 0.1,
        'id': DateTime.now().millisecondsSinceEpoch,
      });
    });
    
    // Remove after animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _reactions.removeWhere((r) => 
            DateTime.now().millisecondsSinceEpoch - (r['id'] as int) > 2000);
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final room = _roomsNotifier.currentRoom;
    
    if (room == null) {
      return Scaffold(
        backgroundColor: _darkBg,
        body: const Center(
          child: Text('Chargement...', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(room),
                
                // Exercise video + controls
                _buildExerciseSection(room),
                
                // Participants grid
                Expanded(child: _buildParticipantsGrid(room)),
                
                // Bottom controls
                _buildBottomControls(room),
              ],
            ),
          ),
          
          // Countdown overlay
          if (_isCountdownActive)
            CountdownOverlay(
              value: _countdownValue,
              exerciseName: room.currentExercise?.name ?? 'Préparez-vous',
            ),
          
          // Floating reactions
          ..._reactions.map((r) => _buildFloatingReaction(r)),
          
          // Pause overlay
          if (_isExercisePaused && !_isCountdownActive)
            _buildPauseOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader(TrainingRoom room) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_cardBg, _cardBg.withOpacity(0.8)],
        ),
      ),
      child: Row(
        children: [
          // Live badge
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isSessionStarted ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _warningRed,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _warningRed.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primaryBlue.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: _primaryBlue, size: 16),
                const SizedBox(width: 6),
                Text(
                  _formatTime(_totalElapsedSeconds),
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Participants count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${room.participants.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Add participant
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _successGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add, color: Colors.white, size: 18),
            ),
            onPressed: () => _showAddParticipantSheet(room),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSection(TrainingRoom room) {
    final exercise = room.currentExercise;
    if (exercise == null) return const SizedBox.shrink();
    
    final elapsed = room.currentExerciseElapsedSeconds;
    final duration = exercise.durationSeconds;
    final progress = elapsed / duration;
    final remaining = duration - elapsed;
    
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_cardBg, _cardBg.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Exercise tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: room.exercises.length,
              itemBuilder: (context, index) {
                final ex = room.exercises[index];
                final isActive = index == room.currentExerciseIndex;
                final isCompleted = index < room.currentExerciseIndex;
                
                return GestureDetector(
                  onTap: () {
                    if (!isActive) {
                      _roomsNotifier.updateCurrentRoom(
                        room.copyWith(
                          currentExerciseIndex: index,
                          currentExerciseElapsedSeconds: 0,
                        ),
                      );
                      _videoController?.dispose();
                      _videoController = null;
                      _videoInitialized = false;
                      _initializeVideo();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(colors: [_primaryBlue, _secondaryPurple])
                          : null,
                      color: isActive ? null : (isCompleted ? _successGreen.withOpacity(0.3) : _darkBg),
                      borderRadius: BorderRadius.circular(20),
                      border: isActive ? null : Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, size: 14, color: _successGreen)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isActive ? Colors.white : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ex.name,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Video + Timer row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Video preview
                Expanded(
                  flex: 4,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _darkBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _primaryBlue.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_videoInitialized && _videoController != null)
                              VideoPlayer(_videoController!)
                            else
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.fitness_center, color: _primaryBlue, size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      exercise.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            // Overlay gradient
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, _darkBg.withOpacity(0.9)],
                                  ),
                                ),
                                child: Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Timer section
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      // Big timer
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: remaining <= 10
                                  ? LinearGradient(colors: [_warningRed, _warningOrange])
                                  : const LinearGradient(colors: [_primaryBlue, _secondaryPurple]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (remaining <= 10 ? _warningRed : _primaryBlue)
                                      .withOpacity(_glowAnimation.value * 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  remaining <= 10 ? Icons.warning : Icons.timer,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _formatTime(remaining),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: _darkBg,
                          valueColor: AlwaysStoppedAnimation(
                            remaining <= 10 ? _warningRed : _primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: _isExercisePaused ? Icons.play_arrow : Icons.pause,
                            color: _warningOrange,
                            onTap: _togglePause,
                          ),
                          const SizedBox(width: 12),
                          if (room.hasNextExercise)
                            _buildControlButton(
                              icon: Icons.skip_next,
                              color: _primaryBlue,
                              onTap: () {
                                _roomsNotifier.nextExercise();
                                _showExerciseTransition();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Exercise info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              'Exercice ${room.currentExerciseIndex + 1}/${room.exercises.length}',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildParticipantsGrid(TrainingRoom room) {
    final participants = room.participants;
    final crossAxisCount = participants.length <= 2 ? 2 : (participants.length <= 4 ? 2 : 3);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final participant = participants[index];
          return _buildParticipantTile(participant, room.currentExercise);
        },
      ),
    );
  }

  Widget _buildParticipantTile(RoomParticipant participant, RoomExercise? exercise) {
    final isYou = participant.id == 'you';
    final isPinned = participant.id == _pinnedParticipantId;
    final colors = _getParticipantColors(participant.id);
    
    return GestureDetector(
      onTap: () => setState(() {
        _pinnedParticipantId = isPinned ? null : participant.id;
      }),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors[0].withOpacity(0.8), colors[1].withOpacity(0.4)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPinned ? _primaryBlue : Colors.white.withOpacity(0.1),
            width: isPinned ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Avatar
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      participant.avatarInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isYou ? 'Toi' : participant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Live badge
            if (isYou)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _warningRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                      SizedBox(width: 2),
                      Text(
                        'LIVE',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Progress
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _darkBg.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${participant.progressPercent}%',
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            
            // Progress bar at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: LinearProgressIndicator(
                  value: participant.progressPercent / 100,
                  minHeight: 4,
                  backgroundColor: Colors.black26,
                  valueColor: const AlwaysStoppedAnimation(_primaryBlue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getParticipantColors(String id) {
    switch (id) {
      case 'you':
        return [_primaryBlue, _secondaryPurple];
      case 'sarah':
        return [Colors.purple, Colors.pink];
      case 'bilel':
        return [Colors.blue, Colors.cyan];
      case 'marie':
        return [Colors.pink, Colors.orange];
      default:
        return [Colors.teal, Colors.green];
    }
  }

  Widget _buildBottomControls(TrainingRoom room) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, _darkBg],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick reactions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['💪', '🔥', '👏', '😤', '🎯'].map((emoji) {
              return GestureDetector(
                onTap: () => _addReaction(emoji),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          
          // Main controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomButton(
                icon: _isMicOn ? Icons.mic : Icons.mic_off,
                label: 'Micro',
                isActive: _isMicOn,
                onTap: () => setState(() => _isMicOn = !_isMicOn),
              ),
              _buildBottomButton(
                icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                label: 'Caméra',
                isActive: _isCameraOn,
                onTap: () => setState(() => _isCameraOn = !_isCameraOn),
              ),
              _buildBottomButton(
                icon: Icons.add_circle_outline,
                label: '+10%',
                color: _successGreen,
                onTap: () {
                  final room = _roomsNotifier.currentRoom;
                  if (room == null) return;
                  final updated = room.participants.map((p) {
                    if (p.id == 'you') {
                      return p.copyWith(progressPercent: (p.progressPercent + 10).clamp(0, 100));
                    }
                    return p;
                  }).toList();
                  _roomsNotifier.updateCurrentRoom(room.copyWith(participants: updated));
                },
              ),
              _buildBottomButton(
                icon: Icons.call_end,
                label: 'Quitter',
                color: _warningRed,
                onTap: _finishSession,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    bool isActive = true,
    Color? color,
    required VoidCallback onTap,
  }) {
    final buttonColor = color ?? (isActive ? _primaryBlue : Colors.grey);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: buttonColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingReaction(Map<String, dynamic> reaction) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * (reaction['x'] as double),
          bottom: 100 + (value * 300),
          child: Opacity(
            opacity: 1 - value,
            child: Transform.scale(
              scale: 1 + value * 0.5,
              child: Text(
                reaction['emoji'] as String,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: _darkBg.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _warningOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _warningOrange.withOpacity(0.5), blurRadius: 30, spreadRadius: 10),
                ],
              ),
              child: const Icon(Icons.pause, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            const Text(
              'PAUSE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _togglePause,
              style: ElevatedButton.styleFrom(
                backgroundColor: _successGreen,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'Reprendre',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddParticipantSheet(TrainingRoom room) {
    final available = RoomsNotifier.availableMembers
        .where((m) => !room.participants.any((p) => p.id == m.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Inviter des participants',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final member = available[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: _darkBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _primaryBlue,
                        child: Text(
                          member.avatarInitials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(
                        member.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _roomsNotifier.addParticipant(member);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${member.name} a rejoint !'),
                              backgroundColor: _successGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _successGreen),
                        child: const Text('Inviter'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}







