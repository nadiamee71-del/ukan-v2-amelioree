import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SYSTÈME DE GUIDE DE POSE POUR PHOTOS D'ÉVOLUTION
// Permet de capturer des photos avec la même pose pour une comparaison parfaite
// ═══════════════════════════════════════════════════════════════════════════

// Palette noir/or uniforme
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

/// Entrée de photo d'évolution avec pose
class PoseEvolutionEntry {
  final String id;
  final DateTime date;
  final double? weight;
  final Uint8List? imageBytes;
  final String? imagePath;
  final String? note;
  final String poseType; // 'front', 'side', 'back'

  PoseEvolutionEntry({
    required this.id,
    required this.date,
    this.weight,
    this.imageBytes,
    this.imagePath,
    this.note,
    required this.poseType,
  });
}

/// Page principale de l'évolution avec guide de pose
class PoseGuideEvolutionPage extends StatefulWidget {
  const PoseGuideEvolutionPage({super.key});

  @override
  State<PoseGuideEvolutionPage> createState() => _PoseGuideEvolutionPageState();
}

class _PoseGuideEvolutionPageState extends State<PoseGuideEvolutionPage> 
    with SingleTickerProviderStateMixin {
  
  final List<PoseEvolutionEntry> _entries = [];
  String _selectedPoseType = 'front';
  int _comparisonMode = 0; // 0: côte à côte, 1: slider, 2: swipe, 3: fondu
  double _fadeOpacity = 0.5; // Pour le mode fondu
  double _sliderPosition = 0.5;
  int _swipeIndex = 0;
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _loadDemoData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    final now = DateTime.now();
    _entries.addAll([
      PoseEvolutionEntry(
        id: '1',
        date: now.subtract(const Duration(days: 90)),
        weight: 85.0,
        note: 'Début du programme',
        poseType: 'front',
      ),
      PoseEvolutionEntry(
        id: '2',
        date: now.subtract(const Duration(days: 60)),
        weight: 82.0,
        note: '1 mois de progrès',
        poseType: 'front',
      ),
      PoseEvolutionEntry(
        id: '3',
        date: now.subtract(const Duration(days: 30)),
        weight: 79.5,
        note: '2 mois de progrès',
        poseType: 'front',
      ),
      PoseEvolutionEntry(
        id: '4',
        date: now,
        weight: 77.0,
        note: 'Aujourd\'hui',
        poseType: 'front',
      ),
    ]);
  }

  List<PoseEvolutionEntry> get _filteredEntries =>
      _entries.where((e) => e.poseType == _selectedPoseType).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        title: const Text(
          'Mon Évolution',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _primaryGold,
          labelColor: _primaryGold,
          unselectedLabelColor: _textMuted,
          tabs: const [
            Tab(text: 'Galerie'),
            Tab(text: 'Comparer'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGalleryTab(),
          _buildCompareTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPoseGuideCamera,
        backgroundColor: _primaryGold,
        icon: const Icon(Icons.add_a_photo, color: _darkBg),
        label: const Text(
          'Nouvelle photo',
          style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET GALERIE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildGalleryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélecteur de type de pose
          _buildPoseTypeSelector(),
          const SizedBox(height: 20),

          // Grille de photos
          if (_filteredEntries.isEmpty)
            _buildEmptyState()
          else
            _buildPhotoGrid(),
        ],
      ),
    );
  }

  Widget _buildPoseTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPoseTypeButton('front', 'Face', Icons.person),
          _buildPoseTypeButton('side', 'Profil', Icons.person_outline),
          _buildPoseTypeButton('back', 'Dos', Icons.person_off_outlined),
        ],
      ),
    );
  }

  Widget _buildPoseTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedPoseType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPoseType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? _darkBg : _textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _darkBg : _textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.photo_camera_outlined, size: 64, color: _textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Aucune photo pour cette pose',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textLight),
          ),
          const SizedBox(height: 8),
          const Text(
            'Prenez votre première photo avec le guide de pose',
            style: TextStyle(fontSize: 13, color: _textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openPoseGuideCamera,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGold,
              foregroundColor: _darkBg,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Prendre une photo', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_filteredEntries.length} photos',
          style: const TextStyle(fontSize: 14, color: _textMuted),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: _filteredEntries.length,
          itemBuilder: (context, index) => _buildPhotoCard(_filteredEntries[index]),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(PoseEvolutionEntry entry) {
    return GestureDetector(
      onTap: () => _showPhotoDetail(entry),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: entry.imageBytes != null
                    ? Image.memory(entry.imageBytes!, fit: BoxFit.cover)
                    : Container(
                        color: _cardBgLight,
                        child: const Center(
                          child: Icon(Icons.person, size: 60, color: _textMuted),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                  if (entry.weight != null)
                    Text(
                      '${entry.weight!.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _primaryGold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetail(PoseEvolutionEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 0.75,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: entry.imageBytes != null
                      ? Image.memory(entry.imageBytes!, fit: BoxFit.cover)
                      : Container(
                          color: _cardBgLight,
                          child: const Center(
                            child: Icon(Icons.person, size: 100, color: _textMuted),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textLight),
                      ),
                      if (entry.note != null)
                        Text(entry.note!, style: const TextStyle(fontSize: 14, color: _textMuted)),
                    ],
                  ),
                  if (entry.weight != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primaryGold.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${entry.weight!.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryGold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET COMPARER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCompareTab() {
    if (_filteredEntries.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare, size: 64, color: _textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Ajoutez au moins 2 photos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textLight),
            ),
            const SizedBox(height: 8),
            const Text(
              'pour comparer votre évolution',
              style: TextStyle(fontSize: 14, color: _textMuted),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Sélecteur de mode de comparaison
          _buildComparisonModeSelector(),
          const SizedBox(height: 20),

          // Zone de comparaison
          _buildComparisonView(),
          const SizedBox(height: 20),

          // Infos sur les photos comparées
          _buildComparisonInfo(),
        ],
      ),
    );
  }

  Widget _buildComparisonModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildModeButton(0, 'Côte à côte', Icons.view_column),
          _buildModeButton(1, 'Slider', Icons.compare),
          _buildModeButton(2, 'Swipe', Icons.swipe),
          _buildModeButton(3, 'Fondu', Icons.blur_on),
        ],
      ),
    );
  }

  Widget _buildModeButton(int mode, String label, IconData icon) {
    final isSelected = _comparisonMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _comparisonMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? _darkBg : _textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _darkBg : _textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonView() {
    final before = _filteredEntries.first;
    final after = _filteredEntries.last;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: _comparisonMode == 0
            ? _buildSideBySide(before, after)
            : _comparisonMode == 1
                ? _buildSliderComparison(before, after)
                : _comparisonMode == 2
                    ? _buildSwipeComparison()
                    : _buildFadeComparison(before, after),
      ),
    );
  }

  Widget _buildSideBySide(PoseEvolutionEntry before, PoseEvolutionEntry after) {
    return Row(
      children: [
        Expanded(child: _buildComparisonPhoto(before, 'AVANT')),
        Container(width: 2, color: _primaryGold),
        Expanded(child: _buildComparisonPhoto(after, 'APRÈS')),
      ],
    );
  }

  Widget _buildSliderComparison(PoseEvolutionEntry before, PoseEvolutionEntry after) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _sliderPosition += details.delta.dx / context.size!.width;
          _sliderPosition = _sliderPosition.clamp(0.0, 1.0);
        });
      },
      child: Stack(
        children: [
          // Photo APRÈS (fond)
          Positioned.fill(child: _buildComparisonPhoto(after, 'APRÈS')),
          
          // Photo AVANT (clipée)
          ClipRect(
            clipper: _SliderClipper(_sliderPosition),
            child: _buildComparisonPhoto(before, 'AVANT'),
          ),
          
          // Ligne de séparation
          Positioned(
            left: MediaQuery.of(context).size.width * _sliderPosition - 40,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _primaryGold,
                boxShadow: [
                  BoxShadow(
                    color: _primaryGold.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryGold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGold.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.compare_arrows, color: _darkBg, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeComparison() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _filteredEntries.length,
          onPageChanged: (index) => setState(() => _swipeIndex = index),
          itemBuilder: (context, index) {
            final entry = _filteredEntries[index];
            final label = index == 0 ? 'DÉBUT' : index == _filteredEntries.length - 1 ? 'MAINTENANT' : 'ÉTAPE ${index + 1}';
            return _buildComparisonPhoto(entry, label);
          },
        ),
        // Indicateurs de page
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_filteredEntries.length, (index) {
              return Container(
                width: index == _swipeIndex ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index == _swipeIndex ? _primaryGold : _textMuted.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
        // Flèches de navigation
        Positioned(
          left: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton(
              onPressed: _swipeIndex > 0
                  ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
              icon: Icon(
                Icons.chevron_left,
                size: 40,
                color: _swipeIndex > 0 ? _primaryGold : _textMuted.withOpacity(0.3),
              ),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton(
              onPressed: _swipeIndex < _filteredEntries.length - 1
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
              icon: Icon(
                Icons.chevron_right,
                size: 40,
                color: _swipeIndex < _filteredEntries.length - 1 ? _primaryGold : _textMuted.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFadeComparison(PoseEvolutionEntry before, PoseEvolutionEntry after) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _fadeOpacity += details.delta.dx / context.size!.width;
          _fadeOpacity = _fadeOpacity.clamp(0.0, 1.0);
        });
      },
      child: Stack(
        children: [
          // Photo AVANT (fond)
          Positioned.fill(child: _buildComparisonPhoto(before, 'AVANT')),
          
          // Photo APRÈS (avec opacité variable)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 50),
              opacity: _fadeOpacity,
              child: _buildComparisonPhoto(after, 'APRÈS'),
            ),
          ),
          
          // Indicateur de fondu au centre
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _primaryRed,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AVANT',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textLight),
                          ),
                        ],
                      ),
                      Text(
                        '${(100 - _fadeOpacity * 100).toInt()}% / ${(_fadeOpacity * 100).toInt()}%',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _primaryGold),
                      ),
                      Row(
                        children: [
                          const Text(
                            'APRÈS',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textLight),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _primaryGreen,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _primaryGreen,
                      inactiveTrackColor: _primaryRed,
                      thumbColor: _primaryGold,
                      overlayColor: _primaryGold.withOpacity(0.2),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _fadeOpacity,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (v) => setState(() => _fadeOpacity = v),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Glissez pour voir la transition',
                    style: TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonPhoto(PoseEvolutionEntry entry, String label) {
    return Stack(
      fit: StackFit.expand,
      children: [
        entry.imageBytes != null
            ? Image.memory(entry.imageBytes!, fit: BoxFit.cover)
            : Container(
                color: _cardBgLight,
                child: const Center(
                  child: Icon(Icons.person, size: 80, color: _textMuted),
                ),
              ),
        // Label
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: label.contains('AVANT') || label.contains('DÉBUT')
                  ? _primaryRed
                  : _primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Date et poids
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: const TextStyle(fontSize: 11, color: _textLight),
                ),
                if (entry.weight != null)
                  Text(
                    '${entry.weight!.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _primaryGold),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonInfo() {
    if (_filteredEntries.length < 2) return const SizedBox();

    final before = _filteredEntries.first;
    final after = _filteredEntries.last;
    final daysDiff = after.date.difference(before.date).inDays;
    final weightDiff = (before.weight != null && after.weight != null)
        ? after.weight! - before.weight!
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              Icons.calendar_today,
              '$daysDiff jours',
              'de progression',
            ),
          ),
          Container(width: 1, height: 50, color: _borderColor),
          if (weightDiff != null)
            Expanded(
              child: _buildInfoItem(
                weightDiff < 0 ? Icons.trending_down : Icons.trending_up,
                '${weightDiff > 0 ? '+' : ''}${weightDiff.toStringAsFixed(1)} kg',
                weightDiff < 0 ? 'perdu' : 'pris',
                color: weightDiff < 0 ? _primaryGreen : _primaryRed,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? _primaryGold, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color ?? _primaryGold,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: _textMuted)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET STATS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStatsTab() {
    final entriesWithWeight = _entries.where((e) => e.weight != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (entriesWithWeight.isEmpty) {
      return const Center(
        child: Text(
          'Pas encore de données',
          style: TextStyle(color: _textMuted),
        ),
      );
    }

    final firstWeight = entriesWithWeight.first.weight!;
    final lastWeight = entriesWithWeight.last.weight!;
    final totalChange = lastWeight - firstWeight;
    final daysDiff = entriesWithWeight.last.date.difference(entriesWithWeight.first.date).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Résumé
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryGold.withOpacity(0.2),
                  _cardBg,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primaryGold.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Votre progression',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textLight),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Début', '${firstWeight.toStringAsFixed(1)} kg'),
                    Icon(
                      totalChange < 0 ? Icons.trending_down : Icons.trending_up,
                      size: 40,
                      color: totalChange < 0 ? _primaryGreen : _primaryRed,
                    ),
                    _buildStatColumn('Maintenant', '${lastWeight.toStringAsFixed(1)} kg'),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: totalChange < 0 ? _primaryGreen.withOpacity(0.2) : _primaryRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${totalChange > 0 ? '+' : ''}${totalChange.toStringAsFixed(1)} kg en $daysDiff jours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: totalChange < 0 ? _primaryGreen : _primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Graphique simple
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 168),
              painter: _WeightChartPainter(entriesWithWeight),
            ),
          ),
          const SizedBox(height: 20),

          // Liste des entrées
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Historique',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textLight),
            ),
          ),
          const SizedBox(height: 12),
          ...entriesWithWeight.reversed.map((entry) => _buildHistoryItem(entry)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _primaryGold),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(PoseEvolutionEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: entry.imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(entry.imageBytes!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.person, color: _textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textLight),
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
          ),
          Text(
            '${entry.weight?.toStringAsFixed(1) ?? '-'} kg',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primaryGold),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CAMÉRA AVEC GUIDE DE POSE
  // ═══════════════════════════════════════════════════════════════════════════

  void _openPoseGuideCamera() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PoseGuideCameraPage(
          referenceEntry: _filteredEntries.isNotEmpty ? _filteredEntries.first : null,
          poseType: _selectedPoseType,
          onPhotoTaken: (entry) {
            setState(() => _entries.add(entry));
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE CAMÉRA AVEC GUIDE DE POSE
// ═══════════════════════════════════════════════════════════════════════════

class PoseGuideCameraPage extends StatefulWidget {
  final PoseEvolutionEntry? referenceEntry;
  final String poseType;
  final Function(PoseEvolutionEntry) onPhotoTaken;

  const PoseGuideCameraPage({
    super.key,
    this.referenceEntry,
    required this.poseType,
    required this.onPhotoTaken,
  });

  @override
  State<PoseGuideCameraPage> createState() => _PoseGuideCameraPageState();
}

class _PoseGuideCameraPageState extends State<PoseGuideCameraPage> {
  final ImagePicker _picker = ImagePicker();
  double _overlayOpacity = 0.4;
  bool _showGuide = true;
  Uint8List? _capturedImage;
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();

  String get _poseLabel {
    switch (widget.poseType) {
      case 'front':
        return 'Face';
      case 'side':
        return 'Profil';
      case 'back':
        return 'Dos';
      default:
        return 'Face';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        title: Text(
          'Photo $_poseLabel',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          if (widget.referenceEntry != null)
            IconButton(
              icon: Icon(_showGuide ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _showGuide = !_showGuide),
              tooltip: _showGuide ? 'Masquer le guide' : 'Afficher le guide',
            ),
        ],
      ),
      body: _capturedImage == null ? _buildCameraView() : _buildPreviewView(),
    );
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Zone de prévisualisation (simulation)
              Container(
                width: double.infinity,
                color: _cardBgLight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: _textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Prévisualisation caméra',
                      style: TextStyle(fontSize: 16, color: _textMuted),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Alignez-vous avec le guide',
                      style: TextStyle(fontSize: 14, color: _textMuted),
                    ),
                  ],
                ),
              ),

              // Guide de pose (silhouette de référence)
              if (_showGuide && widget.referenceEntry != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: _overlayOpacity,
                    child: widget.referenceEntry!.imageBytes != null
                        ? Image.memory(
                            widget.referenceEntry!.imageBytes!,
                            fit: BoxFit.cover,
                            color: _primaryGold.withOpacity(0.3),
                            colorBlendMode: BlendMode.srcOver,
                          )
                        : Container(
                            color: Colors.transparent,
                            child: Center(
                              child: Icon(
                                Icons.person_outline,
                                size: 200,
                                color: _primaryGold.withOpacity(0.5),
                              ),
                            ),
                          ),
                  ),
                ),

              // Grille d'alignement
              if (_showGuide)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AlignmentGridPainter(),
                  ),
                ),

              // Instructions
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: _primaryGold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.referenceEntry != null
                              ? 'Alignez-vous avec la silhouette dorée'
                              : 'Prenez votre première photo de référence',
                          style: const TextStyle(fontSize: 13, color: _textLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Contrôles
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Slider opacité
              if (widget.referenceEntry != null) ...[
                Row(
                  children: [
                    const Icon(Icons.opacity, color: _textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: _overlayOpacity,
                        min: 0.1,
                        max: 0.8,
                        activeColor: _primaryGold,
                        inactiveColor: _cardBgLight,
                        onChanged: (v) => setState(() => _overlayOpacity = v),
                      ),
                    ),
                    Text(
                      '${(_overlayOpacity * 100).toInt()}%',
                      style: const TextStyle(color: _textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Bouton capture
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Galerie
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _cardBgLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: _borderColor),
                      ),
                      child: const Icon(Icons.photo_library, color: _textMuted),
                    ),
                  ),

                  // Capture
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _primaryGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryGold.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, color: _darkBg, size: 36),
                    ),
                  ),

                  // Flip caméra
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: _borderColor),
                    ),
                    child: const Icon(Icons.flip_camera_ios, color: _textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Photo capturée
          AspectRatio(
            aspectRatio: 0.75,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(_capturedImage!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),

          // Champ poids
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _textLight),
            decoration: InputDecoration(
              labelText: 'Poids (kg)',
              labelStyle: const TextStyle(color: _textMuted),
              prefixIcon: const Icon(Icons.monitor_weight, color: _primaryGold),
              filled: true,
              fillColor: _cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryGold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Champ note
          TextField(
            controller: _noteController,
            style: const TextStyle(color: _textLight),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Note (optionnel)',
              labelStyle: const TextStyle(color: _textMuted),
              prefixIcon: const Icon(Icons.note, color: _primaryGold),
              filled: true,
              fillColor: _cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryGold),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _capturedImage = null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textMuted,
                    side: const BorderSide(color: _borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reprendre'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _savePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGold,
                    foregroundColor: _darkBg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _capturedImage = bytes);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _capturedImage = bytes);
    }
  }

  void _savePhoto() {
    final weight = double.tryParse(_weightController.text);

    final entry = PoseEvolutionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weight: weight,
      imageBytes: _capturedImage,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      poseType: widget.poseType,
    );

    widget.onPhotoTaken(entry);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo enregistrée ! 📸'),
        backgroundColor: _primaryGreen,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAINTERS PERSONNALISÉS
// ═══════════════════════════════════════════════════════════════════════════

class _SliderClipper extends CustomClipper<Rect> {
  final double position;

  _SliderClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) => position != oldClipper.position;
}

class _AlignmentGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _primaryGold.withOpacity(0.3)
      ..strokeWidth = 1;

    // Lignes verticales (règle des tiers)
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );

    // Lignes horizontales
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );

    // Ligne centrale verticale (plus visible)
    final centerPaint = Paint()
      ..color = _primaryGold.withOpacity(0.5)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WeightChartPainter extends CustomPainter {
  final List<PoseEvolutionEntry> entries;

  _WeightChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final weights = entries.map((e) => e.weight!).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxWeight = weights.reduce((a, b) => a > b ? a : b) + 2;
    final range = maxWeight - minWeight;

    final paint = Paint()
      ..color = _primaryGold
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = _primaryGold
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final x = (i / (entries.length - 1)) * size.width;
      final y = size.height - ((entries[i].weight! - minWeight) / range) * size.height;
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Dessiner la ligne
    canvas.drawPath(path, paint);

    // Dessiner les points
    for (final point in points) {
      canvas.drawCircle(point, 6, dotPaint);
      canvas.drawCircle(point, 4, Paint()..color = _darkBg);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}




