import 'package:flutter/material.dart';
import '../models/transformation_projection.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRANSFORMATION PROJECTION™ - Thème Noir & Or
// Page IA Premium - Projection du futur corps uniquement
// ═══════════════════════════════════════════════════════════════════════════

// Palette noir/or uniforme
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

/// Écran Transformation Projection™ - IA Premium (projection uniquement)
class RAFuturePreviewPage extends StatefulWidget {
  const RAFuturePreviewPage({super.key});

  @override
  State<RAFuturePreviewPage> createState() => _RAFuturePreviewPageState();
}

class _RAFuturePreviewPageState extends State<RAFuturePreviewPage> {
  final TransformationProjectionNotifier _projectionNotifier =
      TransformationProjectionNotifier();

  int? _selectedPhaseMonths;

  @override
  void initState() {
    super.initState();
    _projectionNotifier.addListener(_onProjectionChanged);
    _selectedPhaseMonths = 0;
    if (_projectionNotifier.currentPhotoPath == null) {
      _projectionNotifier.setCurrentPhoto('assets/images/phase_0mois.png');
    }
  }

  @override
  void dispose() {
    _projectionNotifier.removeListener(_onProjectionChanged);
    super.dispose();
  }

  void _onProjectionChanged() {
    if (mounted) setState(() {});
  }

  void _importPhoto() {
    // Pour Flutter Web, on utilise une image de démo
    _projectionNotifier.setCurrentPhoto('assets/images/phase_0mois.png');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de démo chargée (mode Web)'),
          backgroundColor: _primaryGold,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _validatePhase() {
    if (_selectedPhaseMonths == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne une phase à valider'),
          backgroundColor: _cardBgLight,
        ),
      );
      return;
    }

    _projectionNotifier.unlockPhase(_selectedPhaseMonths!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Phase "${_selectedPhaseMonths == 0 ? "Actuel" : "$_selectedPhaseMonths mois"}" validée !',
          ),
          backgroundColor: _primaryGold,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showImageFullScreen(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  imagePath.startsWith('assets/') ? imagePath : 'assets/images/phase_0mois.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      child: const Icon(
                        Icons.error_outline,
                        color: _primaryGold,
                        size: 64,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primaryGold),
                  ),
                  child: const Icon(Icons.close, color: _primaryGold, size: 24),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _primaryGold.withOpacity(0.5)),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _primaryGold,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Projection IA',
          style: TextStyle(fontWeight: FontWeight.w700, color: _textLight),
        ),
        centerTitle: true,
      ),
      body: _buildProjectionTab(),
    );
  }

  Widget _buildProjectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau RA Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: _primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _primaryGold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              '🤖 Projection IA - Visualise ton futur corps',
              style: TextStyle(
                color: _primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Layout responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _CurrentPhotoCard(
                        currentPhotoPath: _projectionNotifier.currentPhotoPath,
                        onImportPhoto: _importPhoto,
                        onImageTap: (imagePath, title) =>
                            _showImageFullScreen(context, imagePath, title),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _EvolutionTimeline(
                        selectedPhaseMonths: _selectedPhaseMonths,
                        onPhaseSelected: (months) {
                          setState(() => _selectedPhaseMonths = months);
                        },
                        onImageTap: (imagePath, title) =>
                            _showImageFullScreen(context, imagePath, title),
                        projectionNotifier: _projectionNotifier,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _CurrentPhotoCard(
                      currentPhotoPath: _projectionNotifier.currentPhotoPath,
                      onImportPhoto: _importPhoto,
                      onImageTap: (imagePath, title) =>
                          _showImageFullScreen(context, imagePath, title),
                    ),
                    const SizedBox(height: 24),
                    _EvolutionTimeline(
                      selectedPhaseMonths: _selectedPhaseMonths,
                      onPhaseSelected: (months) {
                        setState(() => _selectedPhaseMonths = months);
                      },
                      projectionNotifier: _projectionNotifier,
                      onImageTap: (imagePath, title) =>
                          _showImageFullScreen(context, imagePath, title),
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Aperçu phase sélectionnée
          if (_selectedPhaseMonths != null)
            _PhasePreview(
              phaseMonths: _selectedPhaseMonths!,
              projectionNotifier: _projectionNotifier,
              onImageTap: (imagePath, title) =>
                  _showImageFullScreen(context, imagePath, title),
            ),

          const SizedBox(height: 24),

          // Bouton validation
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _validatePhase,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Valider cette phase'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: _darkBg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'Fonctionnalité de projection IA en mode démo.',
              style: TextStyle(
                color: _textMuted.withOpacity(0.7),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIAIRES
// ═══════════════════════════════════════════════════════════════════════════

/// Widget : Photo actuelle de l'utilisateur
class _CurrentPhotoCard extends StatelessWidget {
  final String? currentPhotoPath;
  final VoidCallback onImportPhoto;
  final Function(String, String) onImageTap;

  const _CurrentPhotoCard({
    required this.currentPhotoPath,
    required this.onImportPhoto,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primaryGold.withOpacity(0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ta photo actuelle',
            style: TextStyle(
              color: _textLight,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (currentPhotoPath != null) {
                onImageTap(currentPhotoPath!, 'Photo actuelle');
              }
            },
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: currentPhotoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.asset(
                            currentPhotoPath!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: 300,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _darkBg.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.zoom_in, color: _primaryGold, size: 20),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onImportPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Importer une photo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryGold,
                side: const BorderSide(color: _primaryGold),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 48, color: _textMuted),
          const SizedBox(height: 8),
          const Text(
            'Ajoute ta photo',
            style: TextStyle(color: _textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Widget : Timeline des phases de projection
class _EvolutionTimeline extends StatelessWidget {
  final int? selectedPhaseMonths;
  final ValueChanged<int> onPhaseSelected;
  final TransformationProjectionNotifier projectionNotifier;
  final Function(String, String) onImageTap;

  const _EvolutionTimeline({
    required this.selectedPhaseMonths,
    required this.onPhaseSelected,
    required this.projectionNotifier,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final phases = projectionNotifier.getAllPhases();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primaryGold.withOpacity(0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phases de projection',
            style: TextStyle(
              color: _textLight,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: phases.length,
              itemBuilder: (context, index) {
                final phase = phases[index];
                final isSelected = selectedPhaseMonths == phase.months;
                final isUnlocked = phase.isUnlocked;

                return Padding(
                  padding: EdgeInsets.only(right: index < phases.length - 1 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () => onPhaseSelected(phase.months),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primaryGold.withOpacity(0.2)
                            : _cardBgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _primaryGold
                              : isUnlocked
                                  ? _primaryGold.withOpacity(0.3)
                                  : _borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _cardBgLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isUnlocked
                                  ? GestureDetector(
                                      onTap: () => onImageTap(phase.imagePath, phase.label),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          phase.imagePath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              _buildPlaceholder(phase.label),
                                        ),
                                      ),
                                    )
                                  : _buildLockedPlaceholder(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  phase.label,
                                  style: TextStyle(
                                    color: isUnlocked ? _textLight : _textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (!isUnlocked) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.lock_outline,
                                    size: 12,
                                    color: _textMuted,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Container(
      color: _primaryGold.withOpacity(0.1),
      child: Center(
        child: Text(
          '$label\nDEMO',
          style: TextStyle(
            color: _primaryGold.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLockedPlaceholder() {
    return Container(
      color: _cardBgLight,
      child: Center(
        child: Icon(Icons.lock_outline, size: 24, color: _textMuted),
      ),
    );
  }
}

/// Widget : Aperçu grand format de la phase sélectionnée
class _PhasePreview extends StatelessWidget {
  final int phaseMonths;
  final TransformationProjectionNotifier projectionNotifier;
  final Function(String, String) onImageTap;

  const _PhasePreview({
    required this.phaseMonths,
    required this.projectionNotifier,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final phases = projectionNotifier.getAllPhases();
    final phase = phases.firstWhere(
      (p) => p.months == phaseMonths,
      orElse: () => EvolutionPhase(
        months: phaseMonths,
        imagePath: 'assets/images/phase_${phaseMonths}mois.png',
        isUnlocked: false,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primaryGold.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Aperçu : ${phase.label}',
            style: const TextStyle(
              color: _textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: phase.isUnlocked
                ? GestureDetector(
                    onTap: () => onImageTap(phase.imagePath, phase.label),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.asset(
                            phase.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(phase.label),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _darkBg.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: _primaryGold,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildLockedPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Container(
      color: _primaryGold.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 64, color: _primaryGold.withOpacity(0.7)),
            const SizedBox(height: 12),
            Text(
              '$label\nDEMO',
              style: TextStyle(
                color: _primaryGold.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedPlaceholder() {
    return Container(
      color: _cardBgLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: _textMuted),
            const SizedBox(height: 12),
            const Text(
              'Phase verrouillée',
              style: TextStyle(color: _textMuted, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Valide une phase pour débloquer',
              style: TextStyle(color: _textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
