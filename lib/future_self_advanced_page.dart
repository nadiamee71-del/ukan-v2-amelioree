import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models/user_profile.dart';
import 'models/workout_history.dart';
import 'models/nutrition.dart';
import 'models/future_self_advanced.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRANSFORMATION & PROJECTION - Page avec onglets Projection | Évolution
// Thème noir/or uniforme
// ═══════════════════════════════════════════════════════════════════════════

// Palette noir/or uniforme
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

class FutureSelfAdvancedPage extends StatefulWidget {
  const FutureSelfAdvancedPage({super.key});

  @override
  State<FutureSelfAdvancedPage> createState() => _FutureSelfAdvancedPageState();
}

class _FutureSelfAdvancedPageState extends State<FutureSelfAdvancedPage>
    with SingleTickerProviderStateMixin {
  final _profileNotifier = UserProfileNotifier();
  final _historyNotifier = WorkoutHistoryNotifier();
  final _nutritionNotifier = NutritionNotifier();

  late TabController _tabController;

  Timer? _duelTimer;
  bool _duelActive = false;
  int _targetSeconds = 0;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _profileNotifier.addListener(_onDataChanged);
    _historyNotifier.addListener(_onDataChanged);
    _nutritionNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _profileNotifier.removeListener(_onDataChanged);
    _historyNotifier.removeListener(_onDataChanged);
    _nutritionNotifier.removeListener(_onDataChanged);
    _duelTimer?.cancel();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _startDuel() {
    _duelTimer?.cancel();
    setState(() {
      _duelActive = true;
      _elapsedSeconds = 0;
      _targetSeconds = 20 + DateTime.now().second % 21;
    });

    _duelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopDuel() {
    _duelTimer?.cancel();
    _duelTimer = null;

    final won = _elapsedSeconds <= _targetSeconds;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          won ? 'Victoire sur ton moi futur 👊' : 'Ton moi futur a gagné',
          style: const TextStyle(color: _textLight),
        ),
        content: Text(
          won
              ? 'Tu as arrêté en $_elapsedSeconds s pour un objectif de $_targetSeconds s.\nContinue comme ça !'
              : 'Objectif: $_targetSeconds s, tu as fait $_elapsedSeconds s.\nRetente le duel !',
          style: const TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: _primaryGold)),
          ),
        ],
      ),
    );
    setState(() => _duelActive = false);
  }

  String _formatCountdown(DateTime target) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(target.year, target.month, target.day);
    final days = targetDate.difference(today).inDays;
    return days <= 0 ? 'Objectif aujourd\'hui' : 'D-$days jours';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Transformation & Projection',
          style: TextStyle(fontWeight: FontWeight.w700, color: _textLight),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _primaryGold,
          labelColor: _primaryGold,
          unselectedLabelColor: _textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Projection'),
            Tab(text: 'Évolution'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectionTab(),
          const _EvolutionTab(),
        ],
      ),
    );
  }

  Widget _buildProjectionTab() {
    final profile = _profileNotifier.profile;
    final weekSummary = _historyNotifier.summaryForWeek(DateTime.now());
    final todaySummary = _nutritionNotifier.summaryForDate(DateTime.now());
    final futureSelf = FutureSelfAdvanced.compute(
      profile: profile,
      weekSummary: weekSummary,
      todaySummary: todaySummary,
    );
    final countdownText = _formatCountdown(futureSelf.targetDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Carte "Ton moi futur"
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ton moi futur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _primaryGold.withOpacity(0.3)),
                      ),
                      child: Text(
                        countdownText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  futureSelf.goal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (futureSelf.targetWeightKg != null)
                      Expanded(
                        child: _buildStatItem(
                          'Poids cible',
                          '${futureSelf.targetWeightKg!.toStringAsFixed(1)} kg',
                        ),
                      ),
                    Expanded(
                      child: _buildStatItem(
                        'Séances / semaine',
                        '${futureSelf.targetSessionsPerWeek}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Score futur estimé',
                  style: TextStyle(fontSize: 13, color: _textMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (futureSelf.estimatedFutureScore / 100).clamp(0.0, 1.0),
                          backgroundColor: _cardBgLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(_primaryGold),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${futureSelf.estimatedFutureScore} / 100',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mode Duel
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sports_martial_arts, color: _primaryGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Mode Duel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ton moi futur te lance un défi : tenir un effort pendant un certain temps. Bats son chrono !',
                  style: TextStyle(fontSize: 13, color: _textMuted, height: 1.4),
                ),
                const SizedBox(height: 16),
                if (_duelActive) ...[
                  Text('Objectif : $_targetSeconds secondes',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textLight)),
                  const SizedBox(height: 8),
                  Text('Ton temps : $_elapsedSeconds secondes',
                      style: const TextStyle(fontSize: 14, color: _textMuted)),
                  const SizedBox(height: 12),
                  _buildButton('Arrêter le chrono', _stopDuel, filled: true),
                ] else
                  _buildButton('Affronter mon moi futur', _startDuel),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Message du moi futur
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message de ton moi futur',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textLight),
                ),
                const SizedBox(height: 12),
                Text(
                  futureSelf.futureMessage,
                  style: const TextStyle(fontSize: 14, color: _textMuted, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: child,
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _textMuted)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textLight)),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {bool filled = false}) {
    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryGold,
                side: const BorderSide(color: _primaryGold),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ONGLET ÉVOLUTION - Photos avant/après, suivi poids, comparaison
// ═══════════════════════════════════════════════════════════════════════════

class _EvolutionTab extends StatefulWidget {
  const _EvolutionTab();

  @override
  State<_EvolutionTab> createState() => _EvolutionTabState();
}

class _EvolutionTabState extends State<_EvolutionTab> {
  final List<EvolutionEntry> _entries = [];
  bool _shareWithCoach = true;
  bool _shareWithCommunity = false;
  String _selectedPeriod = 'Semaines';

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  void _loadDemoData() {
    final now = DateTime.now();
    _entries.addAll([
      EvolutionEntry(
        id: '1',
        date: now.subtract(const Duration(days: 90)),
        weight: 85.0,
        photoPath: null,
        note: 'Début du programme - Objectif: -10kg',
        period: 'Semaine 1',
      ),
      EvolutionEntry(
        id: '2',
        date: now.subtract(const Duration(days: 60)),
        weight: 82.5,
        photoPath: null,
        note: 'Premiers résultats visibles !',
        period: 'Semaine 5',
      ),
      EvolutionEntry(
        id: '3',
        date: now.subtract(const Duration(days: 30)),
        weight: 79.8,
        photoPath: null,
        note: 'Plus de 5kg perdus, motivation au max',
        period: 'Semaine 9',
      ),
      EvolutionEntry(
        id: '4',
        date: now,
        weight: 77.2,
        photoPath: null,
        note: 'Objectif presque atteint !',
        period: 'Semaine 13',
      ),
    ]);
  }

  void _addEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEntrySheet(
        onAdd: (entry) {
          setState(() => _entries.add(entry));
          Navigator.pop(context);
        },
        selectedPeriod: _selectedPeriod,
        entryCount: _entries.length,
      ),
    );
  }

  void _showComparison() {
    if (_entries.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins 2 entrées pour comparer'),
          backgroundColor: _cardBg,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ComparisonSheet(entries: _entries),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Options de partage
          _buildSharingOptions(),
          const SizedBox(height: 16),

          // Sélection de période
          _buildPeriodSelector(),
          const SizedBox(height: 16),

          // Bouton Comparer
          _buildCompareButton(),
          const SizedBox(height: 16),

          // Graphique de progression du poids
          if (_entries.isNotEmpty) ...[
            _buildWeightChart(),
            const SizedBox(height: 16),
          ],

          // Liste des entrées
          _buildEntriesList(),
          const SizedBox(height: 16),

          // Bouton ajouter
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildSharingOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.share, color: _primaryGold, size: 20),
              SizedBox(width: 8),
              Text(
                'Options de partage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textLight),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            'Partager avec mon coach',
            'Votre coach peut suivre votre évolution',
            _shareWithCoach,
            (v) => setState(() => _shareWithCoach = v),
          ),
          const Divider(color: _borderColor),
          _buildSwitchTile(
            'Partager avec la communauté',
            'Inspirez les autres avec vos progrès',
            _shareWithCommunity,
            (v) => setState(() => _shareWithCommunity = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textLight)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: _textMuted)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _primaryGold,
          inactiveTrackColor: _cardBgLight,
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Semaines', 'Mois'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.black : _textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompareButton() {
    return GestureDetector(
      onTap: _showComparison,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryGold, _primaryGold.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryGold.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, color: Colors.black, size: 28),
            SizedBox(width: 12),
            Text(
              'COMPARER AVANT / APRÈS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    if (_entries.isEmpty) return const SizedBox.shrink();

    final minWeight = _entries.map((e) => e.weight).reduce(math.min) - 2;
    final maxWeight = _entries.map((e) => e.weight).reduce(math.max) + 2;
    final range = maxWeight - minWeight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: _primaryGold, size: 20),
              SizedBox(width: 8),
              Text(
                'Évolution du poids',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textLight),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _WeightChartPainter(
                entries: _entries,
                minWeight: minWeight,
                maxWeight: maxWeight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Début: ${_entries.first.weight.toStringAsFixed(1)} kg',
                style: const TextStyle(fontSize: 12, color: _textMuted),
              ),
              Text(
                'Actuel: ${_entries.last.weight.toStringAsFixed(1)} kg',
                style: const TextStyle(fontSize: 12, color: _primaryGold, fontWeight: FontWeight.w700),
              ),
              Text(
                'Diff: ${(_entries.last.weight - _entries.first.weight).toStringAsFixed(1)} kg',
                style: TextStyle(
                  fontSize: 12,
                  color: _entries.last.weight < _entries.first.weight ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.photo_library, color: _primaryGold, size: 20),
                SizedBox(width: 8),
                Text(
                  'Mes photos d\'évolution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textLight),
                ),
              ],
            ),
          ),
          if (_entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Aucune entrée pour le moment.\nAjoutez votre première photo !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const Divider(color: _borderColor, height: 1),
              itemBuilder: (context, index) {
                final entry = _entries[_entries.length - 1 - index]; // Plus récent en premier
                return _buildEntryTile(entry);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEntryTile(EvolutionEntry entry) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _primaryGold.withOpacity(0.3)),
        ),
        child: entry.photoPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(entry.photoPath!, fit: BoxFit.cover),
              )
            : const Icon(Icons.person, color: _textMuted, size: 28),
      ),
      title: Text(
        entry.period,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textLight),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.weight.toStringAsFixed(1)} kg',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primaryGold),
          ),
          if (entry.note != null)
            Text(
              entry.note!,
              style: const TextStyle(fontSize: 12, color: _textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Text(
        '${entry.date.day}/${entry.date.month}/${entry.date.year}',
        style: const TextStyle(fontSize: 11, color: _textMuted),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addEntry,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryGold.withOpacity(0.5), width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: _primaryGold, size: 24),
            SizedBox(width: 12),
            Text(
              'Ajouter une entrée',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primaryGold),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODÈLE EVOLUTION ENTRY
// ═══════════════════════════════════════════════════════════════════════════

class EvolutionEntry {
  final String id;
  final DateTime date;
  final double weight;
  final String? photoPath;
  final String? note;
  final String period;

  EvolutionEntry({
    required this.id,
    required this.date,
    required this.weight,
    this.photoPath,
    this.note,
    required this.period,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// SHEET AJOUT ENTRÉE
// ═══════════════════════════════════════════════════════════════════════════

class _AddEntrySheet extends StatefulWidget {
  final Function(EvolutionEntry) onAdd;
  final String selectedPeriod;
  final int entryCount;

  const _AddEntrySheet({
    required this.onAdd,
    required this.selectedPeriod,
    required this.entryCount,
  });

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  String? _photoPath;
  int _periodNumber = 1;

  @override
  void initState() {
    super.initState();
    _periodNumber = widget.entryCount + 1;
  }

  void _pickPhoto() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _primaryGold),
              title: const Text('Prendre une photo', style: TextStyle(color: _textLight)),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _primaryGold),
              title: const Text('Choisir depuis la galerie', style: TextStyle(color: _textLight)),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final XFile? image = await picker.pickImage(
        source: result == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
      if (image != null) {
        setState(() => _photoPath = image.path);
      }
    }
  }

  void _submit() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un poids valide')),
      );
      return;
    }

    final periodLabel = widget.selectedPeriod == 'Semaines'
        ? 'Semaine $_periodNumber'
        : 'Mois $_periodNumber';

    widget.onAdd(EvolutionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weight: weight,
      photoPath: _photoPath,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      period: periodLabel,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Nouvelle entrée',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textLight),
            ),
          ),
          const SizedBox(height: 20),

          // Photo
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _primaryGold.withOpacity(0.5)),
              ),
              child: _photoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(_photoPath!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: _primaryGold, size: 40),
                        SizedBox(height: 8),
                        Text('Ajouter une photo', style: TextStyle(color: _textMuted)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Période
          Row(
            children: [
              const Text('Période: ', style: TextStyle(color: _textLight)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _cardBgLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _periodNumber,
                  dropdownColor: _cardBg,
                  underline: const SizedBox(),
                  style: const TextStyle(color: _primaryGold, fontWeight: FontWeight.w700),
                  items: List.generate(52, (i) => i + 1)
                      .map((n) => DropdownMenuItem(
                            value: n,
                            child: Text(
                              widget.selectedPeriod == 'Semaines' ? 'Semaine $n' : 'Mois $n',
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _periodNumber = v ?? 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Poids
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _textLight),
            decoration: InputDecoration(
              labelText: 'Poids (kg)',
              labelStyle: const TextStyle(color: _textMuted),
              filled: true,
              fillColor: _cardBgLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryGold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Note
          TextField(
            controller: _noteController,
            style: const TextStyle(color: _textLight),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Note (optionnel)',
              labelStyle: const TextStyle(color: _textMuted),
              filled: true,
              fillColor: _cardBgLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryGold),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Bouton
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHEET COMPARAISON - 3 MODES : Côte à côte, Slider, Fondu
// ═══════════════════════════════════════════════════════════════════════════

class _ComparisonSheet extends StatefulWidget {
  final List<EvolutionEntry> entries;

  const _ComparisonSheet({required this.entries});

  @override
  State<_ComparisonSheet> createState() => _ComparisonSheetState();
}

class _ComparisonSheetState extends State<_ComparisonSheet> with SingleTickerProviderStateMixin {
  int _selectedMode = 0; // 0: côte à côte, 1: slider, 2: fondu
  int _beforeIndex = 0;
  int _afterIndex = 0;
  double _sliderPosition = 0.5;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showBefore = true;

  @override
  void initState() {
    super.initState();
    _afterIndex = widget.entries.length - 1;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _startFadeAnimation() {
    _fadeController.reset();
    setState(() => _showBefore = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _fadeController.forward();
        setState(() => _showBefore = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final beforeEntry = widget.entries[_beforeIndex];
    final afterEntry = widget.entries[_afterIndex];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Barre de drag
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Text(
                'Comparer Avant / Après',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textLight),
              ),
              const SizedBox(height: 16),

              // Sélecteurs d'entrées
              Row(
                children: [
                  Expanded(
                    child: _buildEntrySelector('AVANT', _beforeIndex, (v) => setState(() => _beforeIndex = v)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEntrySelector('APRÈS', _afterIndex, (v) => setState(() => _afterIndex = v)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sélecteur de mode
              _buildModeSelector(),
              const SizedBox(height: 16),

              // Zone de comparaison
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _cardBgLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _buildComparisonView(beforeEntry, afterEntry),
                ),
              ),
              const SizedBox(height: 16),

              // Infos
              _buildComparisonInfo(beforeEntry, afterEntry),

              if (_selectedMode == 1) ...[
                const SizedBox(height: 16),
                _buildSliderControl(),
              ],

              if (_selectedMode == 2) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _startFadeAnimation,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Lancer l\'animation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGold,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntrySelector(String label, int selectedIndex, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _primaryGold, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButton<int>(
            value: selectedIndex,
            isExpanded: true,
            dropdownColor: _cardBg,
            underline: const SizedBox(),
            style: const TextStyle(color: _textLight),
            items: widget.entries.asMap().entries.map((e) {
              return DropdownMenuItem(
                value: e.key,
                child: Text(
                  '${e.value.period} - ${e.value.weight.toStringAsFixed(1)}kg',
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (v) => onChanged(v ?? 0),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final modes = [
      {'icon': Icons.view_column, 'label': 'Côte à côte'},
      {'icon': Icons.swap_horiz, 'label': 'Slider'},
      {'icon': Icons.animation, 'label': 'Fondu'},
    ];

    return Row(
      children: modes.asMap().entries.map((e) {
        final isSelected = _selectedMode == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMode = e.key),
            child: Container(
              margin: EdgeInsets.only(right: e.key < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? _primaryGold : _cardBgLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(
                    e.value['icon'] as IconData,
                    color: isSelected ? Colors.black : _textMuted,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.value['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComparisonView(EvolutionEntry before, EvolutionEntry after) {
    switch (_selectedMode) {
      case 0: // Côte à côte
        return Row(
          children: [
            Expanded(child: _buildPhotoPlaceholder(before, 'AVANT')),
            Container(width: 2, color: _primaryGold),
            Expanded(child: _buildPhotoPlaceholder(after, 'APRÈS')),
          ],
        );
      case 1: // Slider
        return Stack(
          children: [
            _buildPhotoPlaceholder(after, 'APRÈS'),
            ClipRect(
              clipper: _SliderClipper(_sliderPosition),
              child: _buildPhotoPlaceholder(before, 'AVANT'),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * _sliderPosition - 40,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: _primaryGold,
                child: const Center(
                  child: Icon(Icons.drag_handle, color: _primaryGold),
                ),
              ),
            ),
          ],
        );
      case 2: // Fondu
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                _buildPhotoPlaceholder(before, 'AVANT'),
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildPhotoPlaceholder(after, 'APRÈS'),
                ),
              ],
            );
          },
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildPhotoPlaceholder(EvolutionEntry entry, String label) {
    return Container(
      color: _cardBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (entry.photoPath != null)
            Image.asset(entry.photoPath!, fit: BoxFit.cover)
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: _textMuted.withOpacity(0.5), size: 80),
                const SizedBox(height: 8),
                Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _primaryGold),
                ),
                Text(entry.period, style: const TextStyle(color: _textMuted)),
              ],
            ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _primaryGold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl() {
    return Column(
      children: [
        const Text('Glissez pour comparer', style: TextStyle(color: _textMuted)),
        Slider(
          value: _sliderPosition,
          onChanged: (v) => setState(() => _sliderPosition = v),
          activeColor: _primaryGold,
          inactiveColor: _cardBgLight,
        ),
      ],
    );
  }

  Widget _buildComparisonInfo(EvolutionEntry before, EvolutionEntry after) {
    final diff = after.weight - before.weight;
    final isLoss = diff < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Avant', '${before.weight.toStringAsFixed(1)} kg', before.period),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLoss ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${isLoss ? '' : '+'}${diff.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isLoss ? Colors.green : Colors.red,
              ),
            ),
          ),
          _buildInfoItem('Après', '${after.weight.toStringAsFixed(1)} kg', after.period),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, String period) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _textMuted)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textLight)),
        Text(period, style: const TextStyle(fontSize: 11, color: _textMuted)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════════════

class _WeightChartPainter extends CustomPainter {
  final List<EvolutionEntry> entries;
  final double minWeight;
  final double maxWeight;

  _WeightChartPainter({
    required this.entries,
    required this.minWeight,
    required this.maxWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final paint = Paint()
      ..color = _primaryGold
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = _primaryGold
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = _borderColor
      ..strokeWidth = 1;

    // Grille
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Ligne du graphique
    final path = Path();
    final range = maxWeight - minWeight;

    for (int i = 0; i < entries.length; i++) {
      final x = size.width * i / (entries.length - 1);
      final y = size.height - (entries[i].weight - minWeight) / range * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Points
      canvas.drawCircle(Offset(x, y), 6, dotPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SliderClipper extends CustomClipper<Rect> {
  final double position;

  _SliderClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(covariant _SliderClipper oldClipper) => position != oldClipper.position;
}
