import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/workout_timer.dart';
import '../models/workout_session.dart';

/// Modale pour ajouter/éditer une série d'exercice
/// Design moderne et intuitif
class ExerciseSeriesDialog extends StatefulWidget {
  final String? exerciseName;
  final int? initialReps;
  final double? initialWeight;
  final bool initialIsBodyweight;
  final int? initialDurationSeconds;
  final int? initialRestSeconds;
  final Function(int? reps, double? weight, bool isBodyweight, int? durationSeconds, bool isBestSet, int? restSeconds)? onSave;
  final int? previousReps;
  final double? previousWeight;
  final bool previousIsBodyweight;
  final int? previousDurationSeconds;
  final bool allowTimeMode;
  final int seriesNumber;

  const ExerciseSeriesDialog({
    super.key,
    this.exerciseName,
    this.initialReps,
    this.initialWeight,
    this.initialIsBodyweight = false,
    this.initialDurationSeconds,
    this.initialRestSeconds,
    this.onSave,
    this.previousReps,
    this.previousWeight,
    this.previousIsBodyweight = false,
    this.previousDurationSeconds,
    this.allowTimeMode = true,
    this.seriesNumber = 1,
  });

  @override
  State<ExerciseSeriesDialog> createState() => _ExerciseSeriesDialogState();
}

class _ExerciseSeriesDialogState extends State<ExerciseSeriesDialog> with SingleTickerProviderStateMixin {
  int _reps = 0;
  double _weight = 20.0;
  bool _isBodyweight = false;
  bool _isBestSeries = false;
  bool _isTimeMode = false;
  int _durationSeconds = 0;
  int? _selectedRestSeconds;
  late AnimationController _animController;

  // Presets de répétitions populaires
  final List<int> _repsPresets = [6, 8, 10, 12, 15, 20];
  
  // Presets de poids
  final List<double> _weightPresets = [5, 10, 15, 20, 25, 30, 40, 50, 60, 80];

  @override
  void initState() {
    super.initState();
    _reps = widget.initialReps ?? 0;
    _weight = widget.initialWeight ?? 20.0;
    _isBodyweight = widget.initialIsBodyweight;
    _durationSeconds = widget.initialDurationSeconds ?? 0;
    _selectedRestSeconds = widget.initialRestSeconds;
    if (widget.initialDurationSeconds != null && widget.initialDurationSeconds! > 0) {
      _isTimeMode = true;
    }
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _incrementReps() {
    HapticFeedback.lightImpact();
    setState(() => _reps++);
  }

  void _decrementReps() {
    if (_reps > 0) {
      HapticFeedback.lightImpact();
      setState(() => _reps--);
    }
  }

  void _setReps(int value) {
    HapticFeedback.selectionClick();
    setState(() => _reps = value);
  }

  void _incrementWeight(double delta) {
    HapticFeedback.lightImpact();
    setState(() {
      _weight = (_weight + delta).clamp(0, 500);
      _isBodyweight = false;
    });
  }

  void _setWeight(double value) {
    HapticFeedback.selectionClick();
    setState(() {
      _weight = value;
      _isBodyweight = false;
    });
  }

  void _toggleBodyweight() {
    HapticFeedback.mediumImpact();
    setState(() => _isBodyweight = !_isBodyweight);
  }

  void _copyPrevious() {
    HapticFeedback.mediumImpact();
    if (_isTimeMode) {
      if (widget.previousDurationSeconds != null) {
        setState(() => _durationSeconds = widget.previousDurationSeconds!);
      }
    } else {
      if (widget.previousReps != null) {
        setState(() => _reps = widget.previousReps!);
      }
      if (widget.previousWeight != null) {
        setState(() {
          _weight = widget.previousWeight!;
          _isBodyweight = widget.previousIsBodyweight;
        });
      }
    }
  }

  final GlobalKey<_TimeSeriesTimerWidgetState> _timerKey = GlobalKey<_TimeSeriesTimerWidgetState>();
  
  void _save() {
    HapticFeedback.heavyImpact();
    if (_isTimeMode) {
      _timerKey.currentState?.stop();
      if (_durationSeconds > 0) {
        widget.onSave?.call(null, null, false, _durationSeconds, _isBestSeries, _selectedRestSeconds);
        Navigator.of(context).pop();
      }
    } else {
      if (_reps > 0) {
        widget.onSave?.call(_reps, _isBodyweight ? null : _weight, _isBodyweight, null, _isBestSeries, _selectedRestSeconds);
        Navigator.of(context).pop();
      }
    }
  }
  
  bool get _canSave => _isTimeMode ? _durationSeconds > 0 : _reps > 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E1E), Color(0xFF141414)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: _isTimeMode
                      ? _buildTimeModeContent()
                      : _buildRepsModeContent(),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Numéro de série
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC300), Color(0xFFFF9500)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Série ${widget.seriesNumber}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.exerciseName ?? 'Nouvelle série',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Toggle Reps / Temps
              if (widget.allowTimeMode)
                _buildModeToggle(),
              // Étoile
              IconButton(
                icon: Icon(
                  _isBestSeries ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: _isBestSeries ? const Color(0xFFFFC300) : Colors.white38,
                  size: 26,
                ),
                onPressed: () => setState(() => _isBestSeries = !_isBestSeries),
                tooltip: 'Meilleure série',
              ),
              // Fermer
              IconButton(
                icon: Icon(Icons.close, color: Colors.white.withOpacity(0.5)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          // Copier série précédente
          if ((widget.previousReps != null || widget.previousWeight != null) && !_isTimeMode)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: _copyPrevious,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.content_copy, size: 14, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text(
                        'Copier : ${widget.previousReps} reps @ ${widget.previousWeight?.toInt() ?? 'PDC'} kg',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('Reps', Icons.repeat, !_isTimeMode),
          _buildToggleOption('Temps', Icons.timer_outlined, _isTimeMode),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _isTimeMode = label == 'Temps');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF007AFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : Colors.white54),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRepsModeContent() {
    return [
      const SizedBox(height: 20),
      
      // Section Répétitions
      _buildSectionTitle('Répétitions', Icons.repeat_rounded),
      const SizedBox(height: 12),
      
      // Compteur principal de reps
      _buildRepsCounter(),
      const SizedBox(height: 16),
      
      // Presets de reps
      _buildRepsPresets(),
      const SizedBox(height: 28),
      
      // Section Charge
      _buildSectionTitle('Charge (kg)', Icons.fitness_center_rounded),
      const SizedBox(height: 12),
      
      // Slider de poids + compteur
      _buildWeightSelector(),
      const SizedBox(height: 16),
      
      // Presets de poids
      _buildWeightPresets(),
      const SizedBox(height: 28),
      
      // Section Repos
      _buildSectionTitle('Temps de repos', Icons.timer_off_outlined),
      const SizedBox(height: 12),
      _buildRestTimePresets(),
    ];
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFFC300)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRepsCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton -
          _buildCounterButton(Icons.remove, _decrementReps, _reps > 0),
          const SizedBox(width: 24),
          
          // Valeur
          GestureDetector(
            onTap: () => _showNumberInputDialog('Répétitions', _reps, (val) => setState(() => _reps = val)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC300).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC300).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '$_reps',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'reps',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Bouton +
          _buildCounterButton(Icons.add, _incrementReps, true),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? () {
        // Incrémentation continue
        HapticFeedback.mediumImpact();
        Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 80));
          if (!mounted) return false;
          onTap();
          return true;
        });
      } : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF007AFF) : Colors.grey.shade800,
          shape: BoxShape.circle,
          boxShadow: enabled ? [
            BoxShadow(
              color: const Color(0xFF007AFF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white38,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildRepsPresets() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _repsPresets.map((preset) {
        final isSelected = _reps == preset;
        return GestureDetector(
          onTap: () => _setReps(preset),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFFC300)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFC300)
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              '$preset',
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // PDC Toggle + Valeur
          Row(
            children: [
              // Bouton PDC
              GestureDetector(
                onTap: _toggleBodyweight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isBodyweight
                        ? const Color(0xFF34C759)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isBodyweight
                          ? const Color(0xFF34C759)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.accessibility_new,
                        size: 18,
                        color: _isBodyweight ? Colors.white : Colors.white54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PDC',
                        style: TextStyle(
                          color: _isBodyweight ? Colors.white : Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Bouton -
              _buildSmallButton(Icons.remove, () => _incrementWeight(-2.5), !_isBodyweight && _weight > 0),
              
              const SizedBox(width: 8),
              
              // Valeur du poids
              Expanded(
                child: GestureDetector(
                  onTap: _isBodyweight ? null : () => _showNumberInputDialog(
                    'Charge (kg)',
                    _weight.toInt(),
                    (val) => setState(() => _weight = val.toDouble()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _isBodyweight ? 'Poids du corps' : '${_weight.toStringAsFixed(_weight % 1 == 0 ? 0 : 1)} kg',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isBodyweight ? const Color(0xFF34C759) : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Bouton +
              _buildSmallButton(Icons.add, () => _incrementWeight(2.5), !_isBodyweight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF007AFF).withOpacity(0.2) : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF007AFF) : Colors.white24,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildWeightPresets() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _weightPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final preset = _weightPresets[index];
          final isSelected = !_isBodyweight && _weight == preset;
          return GestureDetector(
            onTap: () => _setWeight(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF007AFF)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: Text(
                  '${preset.toInt()}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestTimePresets() {
    final presets = [30, 45, 60, 90, 120, 180];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((seconds) {
        final isSelected = _selectedRestSeconds == seconds;
        final label = seconds >= 60 ? '${seconds ~/ 60}min${seconds % 60 > 0 ? ' ${seconds % 60}s' : ''}' : '${seconds}s';
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedRestSeconds = isSelected ? null : seconds);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFF9500).withOpacity(0.2)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF9500)
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF9500) : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildTimeModeContent() {
    return [
      const SizedBox(height: 20),
      _buildSectionTitle('Chronomètre', Icons.timer_rounded),
      const SizedBox(height: 16),
      Center(
        child: _TimeSeriesTimerWidget(
          key: _timerKey,
          onDurationChanged: (duration) {
            setState(() => _durationSeconds = duration.inSeconds);
          },
          onRunningChanged: (isRunning) {},
        ),
      ),
      const SizedBox(height: 20),
      if (_durationSeconds > 0)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF34C759).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF34C759).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF34C759), size: 28),
              const SizedBox(height: 8),
              Text(
                _formatDuration(_durationSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Durée enregistrée',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          // Résumé
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_reps > 0 && !_isTimeMode) ...[
                  Text(
                    '$_reps reps${!_isBodyweight ? ' @ ${_weight.toStringAsFixed(_weight % 1 == 0 ? 0 : 1)} kg' : ' (PDC)'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedRestSeconds != null)
                    Text(
                      'Repos: ${_selectedRestSeconds}s',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                ] else if (_isTimeMode && _durationSeconds > 0)
                  Text(
                    _formatDuration(_durationSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    _isTimeMode ? 'Lance le chrono' : 'Remplis les champs',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  ),
              ],
            ),
          ),
          
          // Bouton Valider
          ElevatedButton.icon(
            onPressed: _canSave ? _save : null,
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text('Valider'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSave ? const Color(0xFF34C759) : Colors.grey.shade700,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade700,
              disabledForegroundColor: Colors.white38,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: _canSave ? 4 : 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showNumberInputDialog(String title, int initialValue, Function(int) onConfirm) {
    final controller = TextEditingController(text: initialValue.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 24),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                onConfirm(val);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC300),
              foregroundColor: Colors.black,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

/// Widget chronomètre pour les séries en temps
class _TimeSeriesTimerWidget extends StatefulWidget {
  final Function(Duration) onDurationChanged;
  final Function(bool) onRunningChanged;
  
  const _TimeSeriesTimerWidget({
    super.key,
    required this.onDurationChanged,
    required this.onRunningChanged,
  });

  @override
  State<_TimeSeriesTimerWidget> createState() => _TimeSeriesTimerWidgetState();
}

class _TimeSeriesTimerWidgetState extends State<_TimeSeriesTimerWidget> {
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  bool _isRunning = false;
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _start() {
    if (_isRunning) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
      widget.onRunningChanged(true);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentDuration += const Duration(seconds: 1);
        });
        widget.onDurationChanged(_currentDuration);
      }
    });
  }
  
  void _pause() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      widget.onRunningChanged(false);
    });
  }
  
  void stop() => _pause();
  
  void _reset() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentDuration = Duration.zero;
      widget.onRunningChanged(false);
      widget.onDurationChanged(Duration.zero);
    });
  }
  
  String _format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            _isRunning ? const Color(0xFF34C759).withOpacity(0.15) : Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: _isRunning ? const Color(0xFF34C759).withOpacity(0.5) : Colors.white.withOpacity(0.1),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _format(_currentDuration),
            style: TextStyle(
              color: _isRunning ? const Color(0xFF34C759) : Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause
              GestureDetector(
                onTap: _isRunning ? _pause : _start,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isRunning ? const Color(0xFFFF9500) : const Color(0xFF34C759),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRunning ? const Color(0xFFFF9500) : const Color(0xFF34C759)).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Reset
              GestureDetector(
                onTap: _reset,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.refresh_rounded, color: Colors.white70, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
