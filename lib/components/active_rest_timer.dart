import 'dart:async';
import 'package:flutter/material.dart';

/// Chronomètre de repos actif avec play/pause
/// Style iOS/Apple Fitness - Design premium
class ActiveRestTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onComplete;
  final Function(int remaining)? onTick;

  const ActiveRestTimer({
    super.key,
    this.initialSeconds = 90,
    this.onComplete,
    this.onTick,
  });

  @override
  State<ActiveRestTimer> createState() => _ActiveRestTimerState();
}

class _ActiveRestTimerState extends State<ActiveRestTimer> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) {
      _resetTimer();
    }

    setState(() {
      _isRunning = true;
      _isInitialized = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        widget.onTick?.call(_remainingSeconds);
      } else {
        _stopTimer();
        widget.onComplete?.call();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.initialSeconds;
      _isRunning = false;
      _isInitialized = false;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (widget.initialSeconds == 0) return 0.0;
    return 1.0 - (_remainingSeconds / widget.initialSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Repos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_isInitialized)
                Text(
                  _formatDuration(_remainingSeconds),
                  style: TextStyle(
                    color: _remainingSeconds <= 10
                        ? Colors.red
                        : const Color(0xFF007AFF),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                Text(
                  _formatDuration(widget.initialSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (_isInitialized) ...[
            const SizedBox(height: 12),
            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _remainingSeconds <= 10
                      ? Colors.red
                      : const Color(0xFF007AFF),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Boutons de contrôle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isInitialized || !_isRunning)
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  iconSize: 32,
                  onPressed: _startTimer,
                  tooltip: 'Démarrer',
                )
              else
                IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  iconSize: 32,
                  onPressed: _pauseTimer,
                  tooltip: 'Pause',
                ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
                iconSize: 28,
                onPressed: _resetTimer,
                tooltip: 'Réinitialiser',
              ),
            ],
          ),
        ],
      ),
    );
  }
}











