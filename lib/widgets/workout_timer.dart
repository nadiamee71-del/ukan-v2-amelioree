import 'dart:async';
import 'package:flutter/material.dart';

/// Modes possibles du timer :
/// - stopwatch : compte à la hausse (0 -> ...)
/// - countdown : compte à rebours (ex : 01:30 -> 0)
enum TimerMode { stopwatch, countdown }

/// Widget de chronomètre réutilisable pour Ukan
/// Style iOS/Apple Fitness - Design premium
class WorkoutTimer extends StatefulWidget {
  final TimerMode mode;
  final Duration initialDuration;
  final void Function(Duration elapsedOrRemaining)? onFinish;
  final String? label; // ex : "repos", "effort", "gainage"
  final bool showControls; // Afficher les boutons play/pause/reset
  final Color? backgroundColor;
  final Color? textColor;
  final Color? buttonColor;

  const WorkoutTimer({
    super.key,
    this.mode = TimerMode.countdown,
    this.initialDuration = const Duration(minutes: 1, seconds: 30),
    this.onFinish,
    this.label,
    this.showControls = true,
    this.backgroundColor,
    this.textColor,
    this.buttonColor,
  });

  @override
  State<WorkoutTimer> createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {
  Timer? _timer;
  late Duration _current;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _current = widget.mode == TimerMode.countdown
        ? widget.initialDuration
        : Duration.zero;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (widget.mode == TimerMode.stopwatch) {
          _current += const Duration(seconds: 1);
        } else {
          if (_current.inSeconds > 0) {
            _current -= const Duration(seconds: 1);
          } else {
            // Fin du compte à rebours
            _stop(internal: true);
            widget.onFinish?.call(Duration.zero);
          }
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _current = widget.mode == TimerMode.countdown
          ? widget.initialDuration
          : Duration.zero;
    });
  }

  void _stop({bool internal = false}) {
    _timer?.cancel();
    setState(() => _isRunning = false);
    if (!internal) {
      // Pour un chrono simple, on peut remonter la durée au parent
      widget.onFinish?.call(_current);
    }
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? const Color(0xFF1D1D1D);
    final txtColor = widget.textColor ?? Colors.white;
    final btnColor = widget.buttonColor ?? const Color(0xFF007AFF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.label!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Affichage du temps
              Text(
                _format(_current),
                style: TextStyle(
                  color: txtColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (widget.showControls) ...[
                const SizedBox(width: 16),
                // Bouton Play / Pause
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    if (_isRunning) {
                      _pause();
                    } else {
                      _start();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: btnColor,
                    ),
                    child: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Reset
                IconButton(
                  onPressed: _reset,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}








