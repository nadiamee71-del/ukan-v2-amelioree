import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../models/goals.dart';

// Palette moderne et immersive
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);

class EditProfilePage extends StatefulWidget {
  final UserProfile initialProfile;

  const EditProfilePage({
    super.key,
    required this.initialProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _waistController;
  late TextEditingController _hipsController;
  late TextEditingController _chestController;
  late TextEditingController _mainGoalController;
  late TextEditingController _secondaryGoalsController;
  late TextEditingController _deadlineController;
  late TextEditingController _waterGoalController;
  late TextEditingController _sleepGoalController;
  late TextEditingController _proteinGoalController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentSection = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
    _heightController = TextEditingController(
      text: widget.initialProfile.height?.toString() ?? '',
    );
    _currentWeightController = TextEditingController(
      text: widget.initialProfile.currentWeight?.toString() ?? '',
    );
    _targetWeightController = TextEditingController(
      text: widget.initialProfile.targetWeight?.toString() ?? '',
    );
    _waistController = TextEditingController(
      text: widget.initialProfile.waist?.toString() ?? '',
    );
    _hipsController = TextEditingController(
      text: widget.initialProfile.hips?.toString() ?? '',
    );
    _chestController = TextEditingController(
      text: widget.initialProfile.chest?.toString() ?? '',
    );
    _mainGoalController = TextEditingController(
      text: widget.initialProfile.mainGoal,
    );
    _secondaryGoalsController = TextEditingController(
      text: widget.initialProfile.secondaryGoals,
    );
    _deadlineController = TextEditingController(
      text: widget.initialProfile.deadline,
    );
    final goalsNotifier = DailyGoalsNotifier();
    _waterGoalController = TextEditingController(
      text: goalsNotifier.waterGoalLiters.toStringAsFixed(1),
    );
    _sleepGoalController = TextEditingController(
      text: goalsNotifier.sleepGoalHours.toStringAsFixed(1),
    );
    _proteinGoalController = TextEditingController(
      text: goalsNotifier.proteinGoalGrams.toString(),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    _mainGoalController.dispose();
    _secondaryGoalsController.dispose();
    _deadlineController.dispose();
    _waterGoalController.dispose();
    _sleepGoalController.dispose();
    _proteinGoalController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _save() {
    HapticFeedback.mediumImpact();
    
    final updatedProfile = widget.initialProfile.copyWith(
      name: _nameController.text.trim(),
      height: _heightController.text.trim().isEmpty
          ? null
          : int.tryParse(_heightController.text.trim()),
      currentWeight: _currentWeightController.text.trim().isEmpty
          ? null
          : double.tryParse(_currentWeightController.text.trim()),
      targetWeight: _targetWeightController.text.trim().isEmpty
          ? null
          : double.tryParse(_targetWeightController.text.trim()),
      waist: _waistController.text.trim().isEmpty
          ? null
          : double.tryParse(_waistController.text.trim()),
      hips: _hipsController.text.trim().isEmpty
          ? null
          : double.tryParse(_hipsController.text.trim()),
      chest: _chestController.text.trim().isEmpty
          ? null
          : double.tryParse(_chestController.text.trim()),
      mainGoal: _mainGoalController.text.trim(),
      secondaryGoals: _secondaryGoalsController.text.trim(),
      deadline: _deadlineController.text.trim(),
    );

    UserProfileNotifier().updateProfile(updatedProfile);

    // Mettre à jour les objectifs avancés
    final goalsNotifier = DailyGoalsNotifier();
    final waterGoal = double.tryParse(_waterGoalController.text.trim());
    final sleepGoal = double.tryParse(_sleepGoalController.text.trim());
    final proteinGoal = int.tryParse(_proteinGoalController.text.trim());

    goalsNotifier.updateGoals(
      waterGoalLiters: waterGoal,
      sleepGoalHours: sleepGoal,
      proteinGoalGrams: proteinGoal,
    );

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _primaryGreen.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: _primaryGreen.withOpacity(0.2),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: _primaryGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profil mis à jour !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tes modifications ont été enregistrées',
                style: TextStyle(
                  fontSize: 14,
                  color: _textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar moderne
            _buildSliverAppBar(),
            
            // Contenu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  children: [
                    // Navigation des sections
                    _buildSectionNav(),
                    const SizedBox(height: 24),
                    
                    // Avatar et stats rapides
                    _buildProfileHeader(),
                    const SizedBox(height: 28),
                    
                    // Section Identité
                    _buildSection(
                      title: 'Identité',
                      icon: Icons.person_outline,
                      color: _primaryBlue,
                      children: [
                        _ModernTextField(
                          controller: _nameController,
                          label: 'Nom complet',
                          hint: 'Ton nom',
                          icon: Icons.badge_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Section Physique
                    _buildSection(
                      title: 'Données physiques',
                      icon: Icons.accessibility_new,
                      color: _primaryGreen,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ModernTextField(
                                controller: _heightController,
                                label: 'Taille',
                                hint: '175',
                                icon: Icons.height,
                                suffix: 'cm',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ModernTextField(
                                controller: _currentWeightController,
                                label: 'Poids actuel',
                                hint: '70',
                                icon: Icons.monitor_weight_outlined,
                                suffix: 'kg',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _ModernTextField(
                          controller: _targetWeightController,
                          label: 'Poids objectif',
                          hint: '65',
                          icon: Icons.flag_outlined,
                          suffix: 'kg',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        
                        // Mensurations
                        Text(
                          'Mensurations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _CompactField(
                                controller: _waistController,
                                label: 'Tour de taille',
                                icon: Icons.straighten,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _CompactField(
                                controller: _hipsController,
                                label: 'Hanches',
                                icon: Icons.straighten,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _CompactField(
                                controller: _chestController,
                                label: 'Poitrine',
                                icon: Icons.straighten,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Section Objectifs quotidiens
                    _buildSection(
                      title: 'Objectifs quotidiens',
                      icon: Icons.track_changes,
                      color: _primaryOrange,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _GoalCard(
                                controller: _waterGoalController,
                                label: 'Hydratation',
                                unit: 'L/jour',
                                icon: Icons.water_drop,
                                color: _primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GoalCard(
                                controller: _sleepGoalController,
                                label: 'Sommeil',
                                unit: 'h/nuit',
                                icon: Icons.bedtime,
                                color: const Color(0xFF9B59B6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _GoalCard(
                          controller: _proteinGoalController,
                          label: 'Protéines',
                          unit: 'g/jour',
                          icon: Icons.egg_alt,
                          color: _primaryOrange,
                          isWide: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Section Objectifs personnels
                    _buildSection(
                      title: 'Objectifs personnels',
                      icon: Icons.emoji_events_outlined,
                      color: _primaryGold,
                      children: [
                        _ModernTextField(
                          controller: _mainGoalController,
                          label: 'Objectif principal',
                          hint: 'Ex: Perdre 5kg, Gagner en muscle...',
                          icon: Icons.star_outline,
                        ),
                        const SizedBox(height: 16),
                        _ModernTextField(
                          controller: _secondaryGoalsController,
                          label: 'Objectifs secondaires',
                          hint: 'Ex: Améliorer mon endurance, Mieux dormir...',
                          icon: Icons.checklist,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _ModernTextField(
                          controller: _deadlineController,
                          label: 'Date limite',
                          hint: 'Ex: Juin 2026',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bouton flottant de sauvegarde
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: _save,
          backgroundColor: _primaryGold,
          foregroundColor: Colors.black,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.save_outlined),
          label: const Text(
            'Enregistrer les modifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: _darkBg,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _cardBgLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: _textLight, size: 20),
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
                _primaryGold.withOpacity(0.15),
                _darkBg,
              ],
            ),
          ),
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _textLight,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.help_outline, color: _textMuted, size: 20),
          ),
          onPressed: () {
            // Aide
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionNav() {
    final sections = [
      {'icon': Icons.person, 'label': 'Identité'},
      {'icon': Icons.accessibility_new, 'label': 'Physique'},
      {'icon': Icons.track_changes, 'label': 'Objectifs'},
      {'icon': Icons.emoji_events, 'label': 'Goals'},
    ];

    return Container(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final isSelected = _currentSection == index;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentSection = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: index < sections.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _primaryGold.withOpacity(0.15) : _cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? _primaryGold : _cardBgLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    section['icon'] as IconData,
                    size: 18,
                    color: isSelected ? _primaryGold : _textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    section['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? _primaryGold : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    final profile = widget.initialProfile;
    final initials = profile.name.isNotEmpty
        ? profile.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardBg,
            _cardBgLight.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBgLight),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryGold, _primaryOrange],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryGold.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isNotEmpty ? profile.name : 'Nouvel utilisateur',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.mainGoal.isNotEmpty
                      ? profile.mainGoal
                      : 'Définir un objectif',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Stats rapides
                Row(
                  children: [
                    _QuickStat(
                      icon: Icons.height,
                      value: profile.height != null ? '${profile.height}cm' : '--',
                      color: _primaryBlue,
                    ),
                    const SizedBox(width: 16),
                    _QuickStat(
                      icon: Icons.monitor_weight_outlined,
                      value: profile.currentWeight != null
                          ? '${profile.currentWeight}kg'
                          : '--',
                      color: _primaryGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBgLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Contenu
          ...children,
        ],
      ),
    );
  }
}

// Widget pour les stats rapides
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textLight,
          ),
        ),
      ],
    );
  }
}

// Champ de texte moderne
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? suffix;
  final TextInputType? keyboardType;
  final int maxLines;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textLight,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: _textLight, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: _textMuted, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: _primaryGold,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: _cardBgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _cardBgLight, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _primaryGold, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// Champ compact pour les mensurations
class _CompactField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _CompactField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _textLight,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '--',
            hintStyle: TextStyle(color: _textMuted.withOpacity(0.3)),
            suffixText: 'cm',
            suffixStyle: TextStyle(
              color: _textMuted,
              fontSize: 12,
            ),
            filled: true,
            fillColor: _cardBgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryGold, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// Carte d'objectif
class _GoalCard extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isWide;

  const _GoalCard({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      width: isWide ? 80 : 50,
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: color.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
