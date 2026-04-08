import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_directory.dart';
import '../coach_detail_page.dart';
import '../chat_page.dart';

// Palette moderne et immersive
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryPurple = Color(0xFFA855F7);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);

// Styles uniformes pour tous les conteneurs
const double _uniformBorderRadius = 16.0;
const double _uniformBorderWidth = 1.5;
const List<BoxShadow> _uniformShadow = [
  BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

class UserProfilePage extends StatefulWidget {
  final PublicUserProfile user;

  const UserProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                  _primaryGold.withOpacity(0.15),
                  _darkBg,
                ],
                stops: const [0.0, 0.4],
              ),
            ),
          ),
          // Cercle décoratif
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryGold.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar moderne
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: _darkBg,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(_uniformBorderRadius),
                      border: Border.all(
                        color: _cardBgLight.withOpacity(0.5),
                        width: _uniformBorderWidth,
                      ),
                      boxShadow: _uniformShadow,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _textLight),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _cardBgLight,
                        borderRadius: BorderRadius.circular(_uniformBorderRadius),
                        border: Border.all(
                          color: _cardBgLight.withOpacity(0.5),
                          width: _uniformBorderWidth,
                        ),
                        boxShadow: _uniformShadow,
                      ),
                      child: const Icon(Icons.more_horiz, size: 20, color: _textLight),
                    ),
                    onPressed: () => _showOptionsMenu(),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: _buildProfileHeader(),
                  ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Boutons d'action
                      _buildActionButtons(),
                      const SizedBox(height: 20),

                      // Stats rapides
                      _buildQuickStats(),
                      const SizedBox(height: 20),

                      // Objectif
                      _buildInfoCard(
                        icon: Icons.flag_rounded,
                        title: 'Objectif principal',
                        content: widget.user.mainGoal,
                        color: _primaryOrange,
                      ),
                      const SizedBox(height: 12),

                      // Niveau
                      _buildInfoCard(
                        icon: Icons.trending_up,
                        title: 'Niveau',
                        content: widget.user.level,
                        color: _primaryGreen,
                        showBadge: true,
                      ),
                      const SizedBox(height: 12),

                      // Localisation
                      if (widget.user.city != null)
                        _buildInfoCard(
                          icon: Icons.location_on,
                          title: 'Localisation',
                          content: widget.user.city!,
                          color: _primaryBlue,
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar avec animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_animationController.value * 0.2),
                child: Opacity(
                  opacity: _animationController.value,
                  child: child,
                ),
              );
            },
            child: Stack(
              children: [
                // Cercle lumineux
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _primaryGold.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Avatar principal
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primaryGold,
                        _primaryGold.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGold.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.user.name.isNotEmpty
                          ? widget.user.name.substring(0, widget.user.name.length > 2 ? 2 : widget.user.name.length).toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Badge Coach
                if (widget.user.isCoach)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: _darkBg, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryGreen.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.verified, color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nom
          Text(
            widget.user.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textLight,
            ),
          ),
          const SizedBox(height: 8),

          // Badge Coach
          if (widget.user.isCoach)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(_uniformBorderRadius),
                border: Border.all(
                  color: _primaryGreen.withOpacity(0.3),
                  width: _uniformBorderWidth,
                ),
                boxShadow: _uniformShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: _primaryGreen, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Coach Certifié',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Bouton Message
        Expanded(
          child: _ActionButton(
            icon: Icons.message_rounded,
            label: 'Message',
            color: _primaryBlue,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    clientId: widget.user.id,
                    clientName: widget.user.name,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.user.isCoach) ...[
          const SizedBox(width: 12),
          // Bouton Voir profil coach
          Expanded(
            child: _ActionButton(
              icon: Icons.sports,
              label: 'Profil Coach',
              color: _primaryGold,
              isPrimary: true,
              onTap: () {
                HapticFeedback.lightImpact();
                if (widget.user.coachId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoachDetailPage(coachId: widget.user.coachId!),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(_uniformBorderRadius),
        border: Border.all(
          color: _cardBgLight.withOpacity(0.5),
          width: _uniformBorderWidth,
        ),
        boxShadow: _uniformShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.fitness_center,
            value: '42',
            label: 'Séances',
            color: _primaryOrange,
          ),
          Container(
            width: 1,
            height: 40,
            color: _cardBgLight,
          ),
          _StatItem(
            icon: Icons.local_fire_department,
            value: '12',
            label: 'Streak',
            color: _primaryGold,
          ),
          Container(
            width: 1,
            height: 40,
            color: _cardBgLight,
          ),
          _StatItem(
            icon: Icons.emoji_events,
            value: '8',
            label: 'Badges',
            color: _primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool showBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(_uniformBorderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: _uniformBorderWidth,
        ),
        boxShadow: _uniformShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(_uniformBorderRadius),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: _uniformBorderWidth,
              ),
              boxShadow: _uniformShadow,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                if (showBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(_uniformBorderRadius),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: _uniformBorderWidth,
                      ),
                      boxShadow: _uniformShadow,
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  )
                else
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: _textMuted, size: 24),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_uniformBorderRadius),
            topRight: Radius.circular(_uniformBorderRadius),
          ),
          border: Border.all(
            color: _cardBgLight.withOpacity(0.5),
            width: _uniformBorderWidth,
          ),
          boxShadow: _uniformShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _OptionTile(
              icon: Icons.share,
              label: 'Partager le profil',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Partage bientôt disponible !'),
                    backgroundColor: _cardBg,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            _OptionTile(
              icon: Icons.block,
              label: 'Bloquer',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _OptionTile(
              icon: Icons.flag,
              label: 'Signaler',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? color.withOpacity(0.8) : _cardBgLight,
        borderRadius: BorderRadius.circular(_uniformBorderRadius),
        border: Border.all(
          color: isPrimary ? color.withOpacity(0.5) : color.withOpacity(0.3),
          width: _uniformBorderWidth,
        ),
        boxShadow: _uniformShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.black : color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.black : color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(_uniformBorderRadius),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: _uniformBorderWidth,
            ),
            boxShadow: _uniformShadow,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _textLight,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _textMuted,
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? _textLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_uniformBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: tileColor, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: tileColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: _textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
