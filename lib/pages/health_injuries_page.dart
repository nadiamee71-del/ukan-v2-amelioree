import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/injury.dart';
import '../models/health_record.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';
import '../alter_ego_floating/alter_ego_context_service.dart';
import '../alter_ego_floating/alter_ego_floating_widget.dart';

// Palette moderne et immersive - Noir & Or
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryPurple = Color(0xFFA855F7);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

/// Page principale "Santé & Blessures" avec design moderne
class HealthInjuriesPage extends StatefulWidget {
  const HealthInjuriesPage({super.key});

  @override
  State<HealthInjuriesPage> createState() => _HealthInjuriesPageState();
}

class _HealthInjuriesPageState extends State<HealthInjuriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AlterEgoPageDetector.setupPageContext(UkanPage.santeBlessures);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Fond avec gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _primaryRed.withOpacity(0.1),
                  _darkBg,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar moderne
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: _darkBg,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _textLight),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_primaryRed, _primaryRed.withOpacity(0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryRed.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.health_and_safety, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Santé & Blessures',
                                    style: TextStyle(
                                      color: _textLight,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Suivi médical complet',
                                    style: TextStyle(
                                      color: _textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // TabBar moderne
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: _primaryRed,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: _primaryRed,
                    unselectedLabelColor: _textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.medical_services, size: 18),
                            SizedBox(width: 8),
                            Text('Blessures'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, size: 18),
                            SizedBox(width: 8),
                            Text('Carnet Santé'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Contenu
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    InjuriesTab(),
                    HealthTab(),
                  ],
                ),
              ),
            ],
          ),
          // Alter Ego flottant
          const AlterEgoFloatingWidget(showFloatingButton: true),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _darkBg,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

/// Onglet 1 : Carnet de blessures
class InjuriesTab extends StatefulWidget {
  const InjuriesTab({super.key});

  @override
  State<InjuriesTab> createState() => _InjuriesTabState();
}

class _InjuriesTabState extends State<InjuriesTab> {
  final _injuryNotifier = InjuryNotifier();

  @override
  void initState() {
    super.initState();
    _injuryNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _injuryNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final injuries = _injuryNotifier.getInjuries();

    return Column(
      children: [
        // Bouton ajouter stylé
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryRed, _primaryRed.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primaryRed.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddInjuryDialog(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Ajouter une blessure',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Liste des blessures
        Expanded(
          child: injuries.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: injuries.length,
                  itemBuilder: (context, index) {
                    return _InjuryCard(
                      injury: injuries[index],
                      onTap: () => _showInjuryDetail(injuries[index]),
                      onEdit: () => _showEditInjuryDialog(injuries[index]),
                      onDelete: () => _deleteInjury(injuries[index].id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.healing,
              size: 48,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune blessure',
            style: TextStyle(
              color: _textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'C\'est une bonne nouvelle ! 💪',
            style: TextStyle(
              color: _textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoute une blessure si besoin',
            style: TextStyle(
              color: _textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddInjuryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditInjurySheet(
        onSave: (injury) {
          _injuryNotifier.addInjury(injury);
        },
      ),
    );
  }

  void _showEditInjuryDialog(Injury injury) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditInjurySheet(
        injuryToEdit: injury,
        onSave: (injury) {
          _injuryNotifier.updateInjury(injury);
        },
      ),
    );
  }

  void _showInjuryDetail(Injury injury) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _InjuryDetailPage(injury: injury),
      ),
    );
  }

  void _deleteInjury(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ?', style: TextStyle(color: _textLight)),
        content: const Text(
          'Cette action est irréversible.',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          TextButton(
            onPressed: () {
              _injuryNotifier.removeInjury(id);
              Navigator.of(context).pop();
              HapticFeedback.mediumImpact();
            },
            child: const Text('Supprimer', style: TextStyle(color: _primaryRed)),
          ),
        ],
      ),
    );
  }
}

/// Carte de blessure moderne
class _InjuryCard extends StatelessWidget {
  final Injury injury;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InjuryCard({
    required this.injury,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(injury.severity);
    final statusColor = _getStatusColor(injury.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBgLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getBodyPartIcon(injury.bodyPart),
                        color: severityColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            injury.bodyPart,
                            style: const TextStyle(
                              color: _textLight,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            injury.type,
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: _textMuted),
                      color: _cardBgLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: _primaryBlue),
                              const SizedBox(width: 12),
                              const Text('Modifier', style: TextStyle(color: _textLight)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: _primaryRed),
                              const SizedBox(width: 12),
                              Text('Supprimer', style: TextStyle(color: _primaryRed)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Badges
                Row(
                  children: [
                    _ModernBadge(
                      label: _getSeverityLabel(injury.severity),
                      color: severityColor,
                      icon: Icons.warning_amber_rounded,
                    ),
                    const SizedBox(width: 8),
                    _ModernBadge(
                      label: _getStatusLabel(injury.status),
                      color: statusColor,
                      icon: _getStatusIcon(injury.status),
                    ),
                    const Spacer(),
                    if (injury.imagePaths.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.photo, size: 14, color: _primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              '${injury.imagePaths.length}',
                              style: TextStyle(color: _primaryBlue, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Infos
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardBgLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today,
                        label: _formatDate(injury.startDate),
                        color: _textMuted,
                      ),
                      const SizedBox(width: 16),
                      _InfoChip(
                        icon: Icons.speed,
                        label: 'Douleur ${injury.painLevel}/10',
                        color: _getPainColor(injury.painLevel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getBodyPartIcon(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'genou':
        return Icons.accessibility_new;
      case 'cheville':
        return Icons.directions_walk;
      case 'dos':
        return Icons.airline_seat_flat;
      case 'épaule':
        return Icons.sports_handball;
      case 'poignet':
        return Icons.pan_tool;
      default:
        return Icons.healing;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
        return Icons.pending;
      case 'en_rééducation':
        return Icons.fitness_center;
      case 'guérie':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'léger':
      case 'légère':
        return 'Légère';
      case 'modéré':
      case 'modérée':
        return 'Modérée';
      case 'sévère':
        return 'Sévère';
      default:
        return severity;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'léger':
      case 'légère':
        return _primaryGreen;
      case 'modéré':
      case 'modérée':
        return _primaryOrange;
      case 'sévère':
        return _primaryRed;
      default:
        return _primaryPurple;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
        return 'En cours';
      case 'en_rééducation':
        return 'Rééducation';
      case 'guérie':
        return 'Guérie';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
        return _primaryOrange;
      case 'en_rééducation':
        return _primaryBlue;
      case 'guérie':
        return _primaryGreen;
      default:
        return _primaryPurple;
    }
  }

  Color _getPainColor(int painLevel) {
    if (painLevel <= 3) return _primaryGreen;
    if (painLevel <= 6) return _primaryOrange;
    return _primaryRed;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ModernBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _ModernBadge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

/// Sheet pour ajouter/modifier une blessure
class _AddEditInjurySheet extends StatefulWidget {
  final Injury? injuryToEdit;
  final Function(Injury) onSave;

  const _AddEditInjurySheet({this.injuryToEdit, required this.onSave});

  @override
  State<_AddEditInjurySheet> createState() => _AddEditInjurySheetState();
}

class _AddEditInjurySheetState extends State<_AddEditInjurySheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _rehabPlanController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _bodyPart = 'Genou';
  String _type = 'Entorse';
  String _severity = 'Modérée';
  String _status = 'en_cours';
  int _painLevel = 5;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  List<String> _imagePaths = [];
  List<Uint8List> _imageBytes = []; // Pour Web
  List<String> _exercisesToAvoid = [];
  final _exerciseToAvoidController = TextEditingController();

  static const List<String> _bodyParts = [
    'Genou', 'Cheville', 'Dos', 'Épaule', 'Poignet', 'Cou', 'Hanche', 'Coude', 'Autre',
  ];

  static const List<String> _types = [
    'Entorse', 'Fracture', 'Tendinite', 'Déchirure', 'Inflammation', 'Luxation', 'Autre',
  ];

  static const List<String> _commonExercisesToAvoid = [
    'Squats', 'Deadlifts', 'Développé couché', 'Tractions', 'Course à pied',
    'Sauts', 'Pompes', 'Rowing', 'Soulevé de terre', 'Fentes',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.injuryToEdit != null) {
      final injury = widget.injuryToEdit!;
      _bodyPart = injury.bodyPart;
      _type = injury.type;
      _severity = injury.severity;
      _status = injury.status;
      _painLevel = injury.painLevel;
      _startDate = injury.startDate;
      _endDate = injury.endDate;
      _notesController.text = injury.notes;
      _rehabPlanController.text = injury.rehabPlan ?? '';
      _imagePaths = List.from(injury.imagePaths);
      _imageBytes = List.from(injury.imageBytes);
      _exercisesToAvoid = List.from(injury.exercisesToAvoid);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _rehabPlanController.dispose();
    _exerciseToAvoidController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_imageBytes.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maximum 3 photos autorisées'),
          backgroundColor: _primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes.add(bytes);
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: _primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageBytes.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  void _addExerciseToAvoid(String exercise) {
    if (exercise.isNotEmpty && !_exercisesToAvoid.contains(exercise)) {
      setState(() {
        _exercisesToAvoid.add(exercise);
      });
      _exerciseToAvoidController.clear();
    }
  }

  void _removeExerciseToAvoid(String exercise) {
    setState(() {
      _exercisesToAvoid.remove(exercise);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final injury = Injury(
        id: widget.injuryToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user_demo_123',
        bodyPart: _bodyPart,
        type: _type,
        severity: _severity,
        status: _status,
        painLevel: _painLevel,
        startDate: _startDate,
        endDate: _endDate,
        rehabPlan: _rehabPlanController.text.trim().isEmpty ? null : _rehabPlanController.text.trim(),
        notes: _notesController.text.trim(),
        imagePaths: _imagePaths,
        imageBytes: _imageBytes,
        videoUrl: null,
        lastUpdated: DateTime.now(),
        exercisesToAvoid: _exercisesToAvoid,
      );
      widget.onSave(injury);
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.medical_services, color: _primaryRed, size: 24),
                ),
                const SizedBox(width: 14),
                Text(
                  widget.injuryToEdit == null ? 'Nouvelle blessure' : 'Modifier',
                  style: const TextStyle(
                    color: _textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: _textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Formulaire
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zone du corps
                    _buildSectionTitle('Zone du corps', Icons.accessibility_new),
                    const SizedBox(height: 10),
                    _buildChipSelector(
                      items: _bodyParts,
                      selected: _bodyPart,
                      onSelected: (v) => setState(() => _bodyPart = v),
                      color: _primaryBlue,
                    ),
                    const SizedBox(height: 20),
                    
                    // Type
                    _buildSectionTitle('Type de blessure', Icons.healing),
                    const SizedBox(height: 10),
                    _buildChipSelector(
                      items: _types,
                      selected: _type,
                      onSelected: (v) => setState(() => _type = v),
                      color: _primaryOrange,
                    ),
                    const SizedBox(height: 20),
                    
                    // Gravité
                    _buildSectionTitle('Gravité', Icons.warning_amber),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildSeverityButton('Légère', _primaryGreen),
                        const SizedBox(width: 10),
                        _buildSeverityButton('Modérée', _primaryOrange),
                        const SizedBox(width: 10),
                        _buildSeverityButton('Sévère', _primaryRed),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Statut
                    _buildSectionTitle('Statut', Icons.pending_actions),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildStatusButton('en_cours', 'En cours', _primaryOrange)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatusButton('en_rééducation', 'Rééducation', _primaryBlue)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatusButton('guérie', 'Guérie', _primaryGreen)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Niveau de douleur
                    _buildSectionTitle('Niveau de douleur: $_painLevel/10', Icons.speed),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _getPainColor(_painLevel),
                        inactiveTrackColor: _cardBgLight,
                        thumbColor: _getPainColor(_painLevel),
                        overlayColor: _getPainColor(_painLevel).withOpacity(0.2),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _painLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (v) => setState(() => _painLevel = v.toInt()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Notes
                    _buildSectionTitle('Notes', Icons.notes),
                    const SizedBox(height: 10),
                    _buildTextField(_notesController, 'Décris ta blessure...', maxLines: 3),
                    const SizedBox(height: 20),
                    
                    // Plan de rééducation
                    _buildSectionTitle('Plan de rééducation', Icons.fitness_center),
                    const SizedBox(height: 10),
                    _buildTextField(_rehabPlanController, 'Exercices, étirements...', maxLines: 3),
                    const SizedBox(height: 20),
                    
                    // Photos de la blessure
                    _buildSectionTitle('Photos (max 3)', Icons.photo_camera),
                    const SizedBox(height: 10),
                    _buildPhotoSection(),
                    const SizedBox(height: 20),
                    
                    // Exercices à éviter
                    _buildSectionTitle('Exercices à éviter', Icons.block),
                    const SizedBox(height: 10),
                    _buildExercisesToAvoidSection(),
                    const SizedBox(height: 30),
                    
                    // Bouton Enregistrer
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryGreen, _primaryGreen.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryGreen.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text(
                          'Enregistrer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _textMuted),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _textLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChipSelector({
    required List<String> items,
    required String selected,
    required Function(String) onSelected,
    required Color color,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onSelected(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : _cardBgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? color : _textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeverityButton(String label, Color color) {
    final isSelected = _severity == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _severity = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : _cardBgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String value, String label, Color color) {
    final isSelected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? color : _textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _textLight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
        filled: true,
        fillColor: _cardBgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        // Grille de photos
        if (_imageBytes.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_imageBytes.length, (index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _imageBytes[index],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        // Bouton ajouter photo
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryBlue.withOpacity(0.3), style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, color: _primaryBlue, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Ajouter une photo',
                  style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesToAvoidSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips des exercices à éviter
        if (_exercisesToAvoid.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _exercisesToAvoid.map((exercise) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _primaryRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primaryRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block, size: 14, color: _primaryRed),
                      const SizedBox(width: 6),
                      Text(
                        exercise,
                        style: TextStyle(color: _primaryRed, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeExerciseToAvoid(exercise),
                        child: Icon(Icons.close, size: 14, color: _primaryRed),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        // Suggestions rapides
        Text('Suggestions :', style: TextStyle(color: _textMuted, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _commonExercisesToAvoid
              .where((e) => !_exercisesToAvoid.contains(e))
              .take(5)
              .map((exercise) {
            return GestureDetector(
              onTap: () => _addExerciseToAvoid(exercise),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _cardBgLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(exercise, style: TextStyle(color: _textMuted, fontSize: 12)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Champ personnalisé
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _exerciseToAvoidController,
                style: const TextStyle(color: _textLight, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Autre exercice...',
                  hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
                  filled: true,
                  fillColor: _cardBgLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onFieldSubmitted: (value) => _addExerciseToAvoid(value),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _addExerciseToAvoid(_exerciseToAvoidController.text),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryGold.withOpacity(0.3)),
                ),
                child: Icon(Icons.add, color: _primaryGold, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getPainColor(int level) {
    if (level <= 3) return _primaryGreen;
    if (level <= 6) return _primaryOrange;
    return _primaryRed;
  }
}

/// Page de détail d'une blessure
class _InjuryDetailPage extends StatefulWidget {
  final Injury injury;

  const _InjuryDetailPage({required this.injury});

  @override
  State<_InjuryDetailPage> createState() => _InjuryDetailPageState();
}

class _InjuryDetailPageState extends State<_InjuryDetailPage> {
  late Injury injury;
  final _injuryNotifier = InjuryNotifier();

  @override
  void initState() {
    super.initState();
    injury = widget.injury;
  }

  void _addPainEntry() {
    int painLevel = injury.painLevel;
    final noteController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textMuted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.speed, color: _primaryOrange, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Ajouter une entrée douleur',
                      style: TextStyle(color: _textLight, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Niveau de douleur: $painLevel/10',
                  style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _getPainColor(painLevel),
                    inactiveTrackColor: _cardBgLight,
                    thumbColor: _getPainColor(painLevel),
                    overlayColor: _getPainColor(painLevel).withOpacity(0.2),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: painLevel.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (v) => setModalState(() => painLevel = v.toInt()),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  style: const TextStyle(color: _textLight),
                  decoration: InputDecoration(
                    hintText: 'Note (optionnel)...',
                    hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
                    filled: true,
                    fillColor: _cardBgLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final newEntry = PainHistoryEntry(
                        date: DateTime.now(),
                        painLevel: painLevel,
                        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                      );
                      final updatedInjury = injury.copyWith(
                        painHistory: [...injury.painHistory, newEntry],
                        painLevel: painLevel,
                        lastUpdated: DateTime.now(),
                      );
                      _injuryNotifier.updateInjury(updatedInjury);
                      setState(() => injury = updatedInjury);
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPainColor(int level) {
    if (level <= 3) return _primaryGreen;
    if (level <= 6) return _primaryOrange;
    return _primaryRed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _darkBg,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _cardBgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _textLight),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getSeverityColor(injury.severity).withOpacity(0.3),
                      _darkBg,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(injury.severity).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.healing,
                                color: _getSeverityColor(injury.severity),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    injury.bodyPart,
                                    style: const TextStyle(
                                      color: _textLight,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    injury.type,
                                    style: TextStyle(color: _textMuted, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      _ModernBadge(
                        label: _getSeverityLabel(injury.severity),
                        color: _getSeverityColor(injury.severity),
                        icon: Icons.warning_amber_rounded,
                      ),
                      const SizedBox(width: 10),
                      _ModernBadge(
                        label: _getStatusLabel(injury.status),
                        color: _getStatusColor(injury.status),
                        icon: Icons.pending,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Photos de la blessure
                  if (injury.imageBytes.isNotEmpty) ...[
                    _buildInfoCard(
                      title: 'Photos',
                      icon: Icons.photo_library,
                      color: _primaryBlue,
                      children: [
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: injury.imageBytes.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _showFullScreenImage(injury.imageBytes[index]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    injury.imageBytes[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Infos principales
                  _buildInfoCard(
                    title: 'Informations',
                    children: [
                      _buildInfoRow(Icons.calendar_today, 'Début', '${injury.startDate.day}/${injury.startDate.month}/${injury.startDate.year}'),
                      if (injury.endDate != null)
                        _buildInfoRow(Icons.event_available, 'Fin', '${injury.endDate!.day}/${injury.endDate!.month}/${injury.endDate!.year}'),
                      _buildInfoRow(Icons.speed, 'Douleur actuelle', '${injury.painLevel}/10'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Historique de douleur
                  _buildPainHistorySection(),
                  
                  // Exercices à éviter
                  if (injury.exercisesToAvoid.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Exercices à éviter',
                      icon: Icons.block,
                      color: _primaryRed,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: injury.exercisesToAvoid.map((exercise) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _primaryRed.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _primaryRed.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.block, size: 14, color: _primaryRed),
                                  const SizedBox(width: 6),
                                  Text(
                                    exercise,
                                    style: TextStyle(color: _primaryRed, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                  
                  if (injury.notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Notes',
                      children: [
                        Text(injury.notes, style: TextStyle(color: _textMuted, height: 1.5)),
                      ],
                    ),
                  ],
                  
                  if (injury.rehabPlan != null && injury.rehabPlan!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Plan de rééducation',
                      icon: Icons.fitness_center,
                      color: _primaryBlue,
                      children: [
                        Text(injury.rehabPlan!, style: TextStyle(color: _textMuted, height: 1.5)),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Bouton Montrer au coach
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryPurple, _primaryPurple.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Fonctionnalité bientôt disponible !'),
                            backgroundColor: _cardBg,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.videocam, color: Colors.white),
                      label: const Text(
                        'Montrer au coach',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(Uint8List imageBytes) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.9)),
          ),
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _darkBg.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: _textLight),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainHistorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.show_chart, color: _primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Historique de douleur',
                  style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: _addPainEntry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primaryGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: _primaryGold),
                      const SizedBox(width: 4),
                      Text('Ajouter', style: TextStyle(color: _primaryGold, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (injury.painHistory.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.timeline, size: 32, color: _textMuted.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun historique',
                    style: TextStyle(color: _textMuted, fontSize: 13),
                  ),
                  Text(
                    'Ajoute des entrées pour suivre l\'évolution',
                    style: TextStyle(color: _textMuted.withOpacity(0.7), fontSize: 11),
                  ),
                ],
              ),
            )
          else ...[
            // Graphique simple
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: injury.painHistory.take(10).toList().reversed.map((entry) {
                  final height = (entry.painLevel / 10) * 60 + 10;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: _getPainColor(entry.painLevel),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.painLevel}',
                            style: TextStyle(color: _textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Liste des entrées récentes
            ...injury.painHistory.take(3).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getPainColor(entry.painLevel),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${entry.date.day}/${entry.date.month}',
                      style: TextStyle(color: _textMuted, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${entry.painLevel}/10',
                      style: TextStyle(
                        color: _getPainColor(entry.painLevel),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.note != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.note!,
                          style: TextStyle(color: _textMuted.withOpacity(0.7), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    IconData icon = Icons.info_outline,
    Color color = _primaryGold,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _textMuted),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: _textMuted, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _getSeverityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'léger':
      case 'légère':
        return 'Légère';
      case 'modéré':
      case 'modérée':
        return 'Modérée';
      case 'sévère':
        return 'Sévère';
      default:
        return severity;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'léger':
      case 'légère':
        return _primaryGreen;
      case 'modéré':
      case 'modérée':
        return _primaryOrange;
      case 'sévère':
        return _primaryRed;
      default:
        return _primaryPurple;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
        return 'En cours';
      case 'en_rééducation':
        return 'Rééducation';
      case 'guérie':
        return 'Guérie';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
        return _primaryOrange;
      case 'en_rééducation':
        return _primaryBlue;
      case 'guérie':
        return _primaryGreen;
      default:
        return _primaryPurple;
    }
  }
}

/// Onglet 2 : Carnet de santé complet
class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  final _healthNotifier = HealthRecordNotifier();

  @override
  void initState() {
    super.initState();
    _healthNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _healthNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final record = _healthNotifier.getHealthRecord();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Infos médicales
          _buildHealthSection(
            title: 'Infos médicales',
            icon: Icons.medical_information,
            color: _primaryRed,
            onEdit: () => _showEditMedicalInfoSheet(record),
            children: [
              _buildHealthItem('Groupe sanguin', record?.bloodGroup ?? 'Non renseigné', Icons.bloodtype),
              _buildHealthItem('Allergies', record?.allergies.isNotEmpty == true ? record!.allergies.join(', ') : 'Aucune', Icons.warning_amber),
              _buildHealthItem('Traitements', record?.medications.isNotEmpty == true ? record!.medications.join(', ') : 'Aucun', Icons.medication),
              _buildHealthItem('Pathologies', record?.conditions.isNotEmpty == true ? record!.conditions.join(', ') : 'Aucune', Icons.local_hospital),
              _buildHealthItem('Chirurgies', record?.surgeries.isNotEmpty == true ? record!.surgeries.join(', ') : 'Aucune', Icons.medical_services),
              _buildHealthItem('Pacemaker', record?.hasPacemaker == true ? 'Oui' : 'Non', Icons.favorite),
              _buildHealthItem('Prothèse', record?.hasProsthesis == true ? 'Oui' : 'Non', Icons.accessibility),
            ],
          ),
          const SizedBox(height: 16),
          
          // Données corporelles avec historique
          _buildHealthSection(
            title: 'Données corporelles',
            icon: Icons.accessibility_new,
            color: _primaryBlue,
            onEdit: () => _showEditBodyDataSheet(record),
            children: [
              _buildHealthItem('Taille', record?.heightCm != null ? '${record!.heightCm} cm' : 'Non renseigné', Icons.height),
              _buildHealthItem('Poids', record?.weightKg != null ? '${record!.weightKg} kg' : 'Non renseigné', Icons.monitor_weight),
              if (record?.heightCm != null && record?.weightKg != null)
                _buildHealthItem('IMC', _calculateBMI(record!.heightCm!, record.weightKg!).toStringAsFixed(1), Icons.analytics),
              if (record?.bodyFatPercent != null)
                _buildHealthItem('Masse grasse', '${record!.bodyFatPercent}%', Icons.pie_chart),
            ],
          ),
          
          // Historique de poids
          if (record?.weightHistory.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildWeightHistorySection(record!),
          ],
          const SizedBox(height: 16),
          
          // Paramètres vitaux
          _buildHealthSection(
            title: 'Paramètres vitaux',
            icon: Icons.favorite,
            color: _primaryGreen,
            onEdit: () => _showEditVitalsSheet(record),
            children: [
              _buildHealthItem('Tension', record?.bloodPressure ?? 'Non renseigné', Icons.speed),
              _buildHealthItem('FC repos', record?.restingHeartRate != null ? '${record!.restingHeartRate} bpm' : 'Non renseigné', Icons.monitor_heart),
            ],
          ),
          const SizedBox(height: 16),
          
          // Contacts médicaux
          _buildMedicalContactsSection(record),
          const SizedBox(height: 16),
          
          // Contacts d'urgence
          _buildEmergencyContactsSection(record),
          const SizedBox(height: 16),
          
          // Vaccinations
          _buildVaccinationsSection(record),
          const SizedBox(height: 16),
          
          // Examens médicaux
          _buildMedicalExamsSection(record),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHealthSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
    VoidCallback? onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.edit, color: _primaryGold, size: 16),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _textMuted),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: _textMuted, fontSize: 14)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightHistorySection(HealthRecord record) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.show_chart, color: _primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Historique de poids',
                style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: record.weightHistory.take(10).toList().reversed.map((entry) {
                final minWeight = record.weightHistory.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
                final maxWeight = record.weightHistory.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
                final range = maxWeight - minWeight;
                final height = range > 0 
                    ? ((entry.weightKg - minWeight) / range) * 60 + 20
                    : 50.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.weightKg.toStringAsFixed(0)}',
                          style: TextStyle(color: _textMuted, fontSize: 9),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [_primaryPurple, _primaryPurple.withOpacity(0.5)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entry.date.day}/${entry.date.month}',
                          style: TextStyle(color: _textMuted, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalContactsSection(HealthRecord? record) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person, color: _primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Contacts médicaux',
                    style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddMedicalContactSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: _primaryGold, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: record?.medicalContacts.isEmpty != false
                ? Center(
                    child: Column(
                      children: [
                        Icon(Icons.person_add, size: 32, color: _textMuted.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text('Aucun contact médical', style: TextStyle(color: _textMuted, fontSize: 13)),
                      ],
                    ),
                  )
                : Column(
                    children: record!.medicalContacts.map((contact) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cardBgLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: contact.isPrimaryDoctor 
                                    ? _primaryGold.withOpacity(0.2) 
                                    : _primaryBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                contact.isPrimaryDoctor ? Icons.star : Icons.person,
                                color: contact.isPrimaryDoctor ? _primaryGold : _primaryBlue,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name,
                                    style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    contact.specialty,
                                    style: TextStyle(color: _textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (contact.phone != null)
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _primaryGreen.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.phone, color: _primaryGreen, size: 16),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection(HealthRecord? record) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryRed.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryRed.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.emergency, color: _primaryRed, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Contacts d\'urgence',
                    style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddEmergencyContactSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: _primaryGold, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: record?.emergencyContacts.isEmpty != false
                ? Center(
                    child: Column(
                      children: [
                        Icon(Icons.contact_phone, size: 32, color: _textMuted.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text('Aucun contact d\'urgence', style: TextStyle(color: _textMuted, fontSize: 13)),
                        Text('Important en cas d\'accident !', style: TextStyle(color: _primaryRed.withOpacity(0.7), fontSize: 11)),
                      ],
                    ),
                  )
                : Column(
                    children: record!.emergencyContacts.map((contact) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cardBgLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.person, color: _primaryRed, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name,
                                    style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${contact.relationship} • ${contact.phone}',
                                    style: TextStyle(color: _textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.phone, color: _primaryGreen, size: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationsSection(HealthRecord? record) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.vaccines, color: _primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Vaccinations',
                    style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddVaccinationSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: _primaryGold, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: record?.vaccinations.isEmpty != false
                ? Center(
                    child: Column(
                      children: [
                        Icon(Icons.vaccines, size: 32, color: _textMuted.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text('Aucune vaccination enregistrée', style: TextStyle(color: _textMuted, fontSize: 13)),
                      ],
                    ),
                  )
                : Column(
                    children: record!.vaccinations.map((vax) {
                      final isExpired = vax.nextDueDate != null && vax.nextDueDate!.isBefore(DateTime.now());
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cardBgLight,
                          borderRadius: BorderRadius.circular(12),
                          border: isExpired ? Border.all(color: _primaryOrange.withOpacity(0.5)) : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isExpired 
                                    ? _primaryOrange.withOpacity(0.2) 
                                    : _primaryGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isExpired ? Icons.warning : Icons.check,
                                color: isExpired ? _primaryOrange : _primaryGreen,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vax.name,
                                    style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${vax.date.day}/${vax.date.month}/${vax.date.year}',
                                    style: TextStyle(color: _textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (vax.nextDueDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isExpired 
                                      ? _primaryOrange.withOpacity(0.15) 
                                      : _primaryBlue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isExpired ? 'À renouveler' : 'Rappel: ${vax.nextDueDate!.day}/${vax.nextDueDate!.month}/${vax.nextDueDate!.year}',
                                  style: TextStyle(
                                    color: isExpired ? _primaryOrange : _primaryBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalExamsSection(HealthRecord? record) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.science, color: _primaryPurple, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Examens médicaux',
                    style: TextStyle(color: _textLight, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddMedicalExamSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: _primaryGold, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: record?.medicalExams.isEmpty != false
                ? Center(
                    child: Column(
                      children: [
                        Icon(Icons.science, size: 32, color: _textMuted.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text('Aucun examen enregistré', style: TextStyle(color: _textMuted, fontSize: 13)),
                      ],
                    ),
                  )
                : Column(
                    children: record!.medicalExams.map((exam) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cardBgLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.description, color: _primaryPurple, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exam.type,
                                    style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${exam.date.day}/${exam.date.month}/${exam.date.year}',
                                    style: TextStyle(color: _textMuted, fontSize: 12),
                                  ),
                                  if (exam.result != null)
                                    Text(
                                      exam.result!,
                                      style: TextStyle(color: _primaryGreen, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // Méthodes pour afficher les sheets d'édition
  void _showEditMedicalInfoSheet(HealthRecord? record) {
    final bloodGroupController = TextEditingController(text: record?.bloodGroup ?? '');
    List<String> allergies = List.from(record?.allergies ?? []);
    List<String> medications = List.from(record?.medications ?? []);
    List<String> conditions = List.from(record?.conditions ?? []);
    List<String> surgeries = List.from(record?.surgeries ?? []);
    bool hasPacemaker = record?.hasPacemaker ?? false;
    bool hasProsthesis = record?.hasProsthesis ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.medical_information, color: _primaryRed, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Infos médicales',
                      style: TextStyle(color: _textLight, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: _textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEditField('Groupe sanguin', bloodGroupController, 'A+, O-, etc.'),
                      const SizedBox(height: 16),
                      _buildEditableListField(
                        'Allergies',
                        allergies,
                        (items) => setModalState(() => allergies = items),
                        _primaryOrange,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableListField(
                        'Traitements en cours',
                        medications,
                        (items) => setModalState(() => medications = items),
                        _primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableListField(
                        'Pathologies',
                        conditions,
                        (items) => setModalState(() => conditions = items),
                        _primaryPurple,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableListField(
                        'Chirurgies',
                        surgeries,
                        (items) => setModalState(() => surgeries = items),
                        _primaryGreen,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSwitchField(
                              'Pacemaker',
                              hasPacemaker,
                              (v) => setModalState(() => hasPacemaker = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSwitchField(
                              'Prothèse',
                              hasProsthesis,
                              (v) => setModalState(() => hasProsthesis = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final updated = (record ?? HealthRecord(
                              id: 'health_${DateTime.now().millisecondsSinceEpoch}',
                              userId: 'user_demo_123',
                              lastUpdated: DateTime.now(),
                            )).copyWith(
                              bloodGroup: bloodGroupController.text.trim().isEmpty ? null : bloodGroupController.text.trim(),
                              allergies: allergies,
                              medications: medications,
                              conditions: conditions,
                              surgeries: surgeries,
                              hasPacemaker: hasPacemaker,
                              hasProsthesis: hasProsthesis,
                            );
                            _healthNotifier.updateHealthRecord(updated);
                            Navigator.pop(context);
                            HapticFeedback.mediumImpact();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGold,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Enregistrer',
                            style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBodyDataSheet(HealthRecord? record) {
    final heightController = TextEditingController(text: record?.heightCm?.toString() ?? '');
    final weightController = TextEditingController(text: record?.weightKg?.toString() ?? '');
    final bodyFatController = TextEditingController(text: record?.bodyFatPercent?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.accessibility_new, color: _primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Données corporelles',
                    style: TextStyle(color: _textLight, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildEditField('Taille (cm)', heightController, '175')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildEditField('Poids (kg)', weightController, '70')),
                ],
              ),
              const SizedBox(height: 16),
              _buildEditField('Masse grasse (%)', bodyFatController, '15'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final height = double.tryParse(heightController.text);
                    final weight = double.tryParse(weightController.text);
                    final bodyFat = double.tryParse(bodyFatController.text);
                    
                    List<WeightHistoryEntry> weightHistory = List.from(record?.weightHistory ?? []);
                    if (weight != null && weight != record?.weightKg) {
                      weightHistory.add(WeightHistoryEntry(
                        date: DateTime.now(),
                        weightKg: weight,
                      ));
                    }
                    
                    final updated = (record ?? HealthRecord(
                      id: 'health_${DateTime.now().millisecondsSinceEpoch}',
                      userId: 'user_demo_123',
                      lastUpdated: DateTime.now(),
                    )).copyWith(
                      heightCm: height,
                      weightKg: weight,
                      bodyFatPercent: bodyFat,
                      weightHistory: weightHistory,
                    );
                    _healthNotifier.updateHealthRecord(updated);
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditVitalsSheet(HealthRecord? record) {
    final bpController = TextEditingController(text: record?.bloodPressure ?? '');
    final hrController = TextEditingController(text: record?.restingHeartRate?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.favorite, color: _primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Paramètres vitaux',
                    style: TextStyle(color: _textLight, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildEditField('Tension artérielle', bpController, '12/8'),
              const SizedBox(height: 16),
              _buildEditField('FC au repos (bpm)', hrController, '65'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final hr = int.tryParse(hrController.text);
                    final updated = (record ?? HealthRecord(
                      id: 'health_${DateTime.now().millisecondsSinceEpoch}',
                      userId: 'user_demo_123',
                      lastUpdated: DateTime.now(),
                    )).copyWith(
                      bloodPressure: bpController.text.trim().isEmpty ? null : bpController.text.trim(),
                      restingHeartRate: hr,
                    );
                    _healthNotifier.updateHealthRecord(updated);
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMedicalContactSheet() {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController();
    final phoneController = TextEditingController();
    bool isPrimary = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textMuted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nouveau contact médical',
                  style: TextStyle(color: _textLight, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                _buildEditField('Nom', nameController, 'Dr. Martin'),
                const SizedBox(height: 12),
                _buildEditField('Spécialité', specialtyController, 'Généraliste, Kiné...'),
                const SizedBox(height: 12),
                _buildEditField('Téléphone', phoneController, '06 12 34 56 78'),
                const SizedBox(height: 12),
                _buildSwitchField('Médecin traitant', isPrimary, (v) => setModalState(() => isPrimary = v)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      final record = _healthNotifier.getHealthRecord();
                      final newContact = MedicalContact(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        specialty: specialtyController.text.trim().isEmpty ? 'Non spécifié' : specialtyController.text.trim(),
                        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                        isPrimaryDoctor: isPrimary,
                      );
                      final updated = record!.copyWith(
                        medicalContacts: [...record.medicalContacts, newContact],
                      );
                      _healthNotifier.updateHealthRecord(updated);
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Ajouter',
                      style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEmergencyContactSheet() {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contact d\'urgence',
                style: TextStyle(color: _textLight, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              _buildEditField('Nom', nameController, 'Marie Dupont'),
              const SizedBox(height: 12),
              _buildEditField('Relation', relationController, 'Conjoint, Parent...'),
              const SizedBox(height: 12),
              _buildEditField('Téléphone', phoneController, '06 12 34 56 78'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty || phoneController.text.isEmpty) return;
                    final record = _healthNotifier.getHealthRecord();
                    final newContact = EmergencyContact(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      relationship: relationController.text.trim().isEmpty ? 'Non spécifié' : relationController.text.trim(),
                      phone: phoneController.text.trim(),
                    );
                    final updated = record!.copyWith(
                      emergencyContacts: [...record.emergencyContacts, newContact],
                    );
                    _healthNotifier.updateHealthRecord(updated);
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Ajouter',
                    style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddVaccinationSheet() {
    final nameController = TextEditingController();
    DateTime date = DateTime.now();
    DateTime? nextDue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textMuted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nouvelle vaccination',
                  style: TextStyle(color: _textLight, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                _buildEditField('Nom du vaccin', nameController, 'Tétanos, Grippe...'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setModalState(() => date = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: _textMuted, size: 18),
                        const SizedBox(width: 12),
                        Text('Date: ${date.day}/${date.month}/${date.year}', style: TextStyle(color: _textLight)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setModalState(() => nextDue = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: _textMuted, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          nextDue != null ? 'Rappel: ${nextDue!.day}/${nextDue!.month}/${nextDue!.year}' : 'Prochain rappel (optionnel)',
                          style: TextStyle(color: nextDue != null ? _textLight : _textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      final record = _healthNotifier.getHealthRecord();
                      final newVax = Vaccination(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        date: date,
                        nextDueDate: nextDue,
                      );
                      final updated = record!.copyWith(
                        vaccinations: [...record.vaccinations, newVax],
                      );
                      _healthNotifier.updateHealthRecord(updated);
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Ajouter',
                      style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMedicalExamSheet() {
    final typeController = TextEditingController();
    final resultController = TextEditingController();
    DateTime date = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textMuted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nouvel examen',
                  style: TextStyle(color: _textLight, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                _buildEditField('Type d\'examen', typeController, 'Bilan sanguin, Radio...'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setModalState(() => date = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: _textMuted, size: 18),
                        const SizedBox(width: 12),
                        Text('Date: ${date.day}/${date.month}/${date.year}', style: TextStyle(color: _textLight)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildEditField('Résultat (optionnel)', resultController, 'Normal, À surveiller...'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (typeController.text.isEmpty) return;
                      final record = _healthNotifier.getHealthRecord();
                      final newExam = MedicalExam(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: typeController.text.trim(),
                        date: date,
                        result: resultController.text.trim().isEmpty ? null : resultController.text.trim(),
                      );
                      final updated = record!.copyWith(
                        medicalExams: [...record.medicalExams, newExam],
                      );
                      _healthNotifier.updateHealthRecord(updated);
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Ajouter',
                      style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: _textLight),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
            filled: true,
            fillColor: _cardBgLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableListField(String label, List<String> items, Function(List<String>) onChanged, Color color) {
    final controller = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        if (items.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => onChanged(items.where((e) => e != item).toList()),
                      child: Icon(Icons.close, size: 14, color: color),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                style: const TextStyle(color: _textLight, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ajouter...',
                  hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
                  filled: true,
                  fillColor: _cardBgLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty && !items.contains(value)) {
                    onChanged([...items, value]);
                    controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (controller.text.isNotEmpty && !items.contains(controller.text)) {
                  onChanged([...items, controller.text]);
                  controller.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(Icons.add, color: color, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchField(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _textLight, fontSize: 14)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _primaryGold,
            inactiveTrackColor: _textMuted.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  double _calculateBMI(double heightCm, double weightKg) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
}
