import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/theme_notifier.dart';
import '../models/units_notifier.dart';
import 'edit_profile_page.dart';
import 'faq_support_page.dart';
import '../main.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PAGE PARAMÈTRES - Design Professionnel Noir & Or
// ═══════════════════════════════════════════════════════════════════════════

// Palette noir/or
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);
const Color _accentRed = Color(0xFFFF6B6B);
const Color _accentGreen = Color(0xFF4ECDC4);
const Color _accentBlue = Color(0xFF58A6FF);
const Color _accentPurple = Color(0xFFA855F7);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserProfileNotifier _profileNotifier = UserProfileNotifier();
  final ThemeNotifier _themeNotifier = ThemeNotifier();
  final UnitsNotifier _unitsNotifier = UnitsNotifier();

  @override
  void initState() {
    super.initState();
    _profileNotifier.addListener(_onProfileChanged);
    _themeNotifier.addListener(_onThemeChanged);
    _unitsNotifier.addListener(_onUnitsChanged);
  }

  @override
  void dispose() {
    _profileNotifier.removeListener(_onProfileChanged);
    _themeNotifier.removeListener(_onThemeChanged);
    _unitsNotifier.removeListener(_onUnitsChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _onUnitsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileNotifier.profile;
    final isDarkMode = _themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        foregroundColor: _textLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryGold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings, color: _primaryGold, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Paramètres',
              style: TextStyle(fontWeight: FontWeight.w700, color: _textLight),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte profil en haut
            _buildProfileCard(profile),
            const SizedBox(height: 24),

            // Section Compte
            _buildSectionTitle('Compte', Icons.person_outline),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.edit_outlined,
              title: 'Modifier mon profil',
              subtitle: 'Nom, email, avatar',
              color: _accentBlue,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(initialProfile: profile),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.shield_outlined,
              title: 'Sécurité',
              subtitle: 'Mot de passe, authentification 2FA',
              color: _accentGreen,
              onTap: () => _showDemoSnackbar('Sécurité'),
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Gérer les alertes et rappels',
              color: _accentPurple,
              onTap: () => _showDemoSnackbar('Notifications'),
            ),

            const SizedBox(height: 28),

            // Section Préférences
            _buildSectionTitle('Préférences', Icons.tune),
            const SizedBox(height: 12),
            _buildSettingsTileWithSwitch(
              icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
              title: 'Mode sombre',
              subtitle: isDarkMode ? 'Activé' : 'Désactivé',
              color: _primaryGold,
              value: isDarkMode,
              onChanged: (value) => _themeNotifier.toggleTheme(),
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Langue',
              subtitle: 'Français 🇫🇷',
              color: _accentBlue,
              onTap: () => _showLanguageDialog(),
            ),
            const SizedBox(height: 28),

            // Section Unités de mesure (IMPORTANT pour une app sport)
            _buildSectionTitle('Unités de mesure', Icons.straighten),
            const SizedBox(height: 8),
            _buildUnitsQuickSwitch(),
            const SizedBox(height: 12),
            _buildUnitSelector(
              icon: Icons.monitor_weight_outlined,
              title: 'Poids',
              subtitle: 'Pour ton poids, haltères, etc.',
              color: _primaryGold,
              currentValue: _unitsNotifier.weightUnit.fullName,
              options: WeightUnit.values.map((u) => u.fullName).toList(),
              onSelected: (index) => _unitsNotifier.setWeightUnit(WeightUnit.values[index]),
              selectedIndex: _unitsNotifier.weightUnit.index,
            ),
            const SizedBox(height: 10),
            _buildUnitSelector(
              icon: Icons.height,
              title: 'Taille',
              subtitle: 'Pour ta taille, mesures corporelles',
              color: _accentBlue,
              currentValue: _unitsNotifier.heightUnit.fullName,
              options: HeightUnit.values.map((u) => u.fullName).toList(),
              onSelected: (index) => _unitsNotifier.setHeightUnit(HeightUnit.values[index]),
              selectedIndex: _unitsNotifier.heightUnit.index,
            ),
            const SizedBox(height: 10),
            _buildUnitSelector(
              icon: Icons.directions_run,
              title: 'Distances',
              subtitle: 'Pour la course, marche, vélo',
              color: _accentGreen,
              currentValue: _unitsNotifier.distanceUnit.fullName,
              options: DistanceUnit.values.map((u) => u.fullName).toList(),
              onSelected: (index) => _unitsNotifier.setDistanceUnit(DistanceUnit.values[index]),
              selectedIndex: _unitsNotifier.distanceUnit.index,
            ),
            const SizedBox(height: 10),
            _buildUnitSelector(
              icon: Icons.water_drop_outlined,
              title: 'Liquides',
              subtitle: 'Pour l\'eau, boissons',
              color: _accentBlue,
              currentValue: _unitsNotifier.liquidUnit.fullName,
              options: LiquidUnit.values.map((u) => u.fullName).toList(),
              onSelected: (index) => _unitsNotifier.setLiquidUnit(LiquidUnit.values[index]),
              selectedIndex: _unitsNotifier.liquidUnit.index,
            ),
            const SizedBox(height: 10),
            _buildUnitSelector(
              icon: Icons.restaurant_outlined,
              title: 'Nourriture (poids)',
              subtitle: 'Pour les aliments, portions',
              color: _accentPurple,
              currentValue: _unitsNotifier.foodWeightUnit.fullName,
              options: FoodWeightUnit.values.map((u) => u.fullName).toList(),
              onSelected: (index) => _unitsNotifier.setFoodWeightUnit(FoodWeightUnit.values[index]),
              selectedIndex: _unitsNotifier.foodWeightUnit.index,
            ),

            const SizedBox(height: 28),

            // Section Données & Confidentialité
            _buildSectionTitle('Données & Confidentialité', Icons.security),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.download_rounded,
              title: 'Exporter mes données',
              subtitle: 'Télécharger toutes mes données',
              color: _accentBlue,
              onTap: () => _showExportDialog(),
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Politique de confidentialité',
              subtitle: 'Comment nous utilisons vos données',
              color: _textMuted,
              onTap: () => _showDemoSnackbar('Confidentialité'),
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.delete_forever_outlined,
              title: 'Supprimer mon compte',
              subtitle: 'Action irréversible',
              color: _accentRed,
              isDanger: true,
              onTap: () => _showDeleteAccountDialog(),
            ),

            const SizedBox(height: 28),

            // Section À propos
            _buildSectionTitle('À propos', Icons.info_outline),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.help_center_outlined,
              title: 'Aide & Support',
              subtitle: 'FAQ, contact, tutoriels',
              color: _primaryGold,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FaqSupportPage()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.star_outline,
              title: 'Noter l\'application',
              subtitle: 'Donnez-nous votre avis',
              color: _primaryGold,
              onTap: () => _showDemoSnackbar('Note'),
            ),
            const SizedBox(height: 10),
            _buildVersionTile(),

            const SizedBox(height: 28),

            // Bouton Déconnexion
            _buildLogoutButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryGold.withOpacity(0.15),
            _cardBg,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryGold.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryGold, _primaryGold.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryGold.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _darkBg,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(fontSize: 14, color: _textMuted),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accentGreen.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: _accentGreen, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Compte vérifié',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Chevron
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_right, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primaryGold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textLight,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDanger ? _accentRed.withOpacity(0.3) : _borderColor,
          ),
        ),
        child: Row(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? _accentRed : _textLight,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: _textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTileWithSwitch({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textLight,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _primaryGold,
            activeTrackColor: _primaryGold.withOpacity(0.3),
            inactiveThumbColor: _textMuted,
            inactiveTrackColor: _cardBgLight,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _textMuted.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline, color: _textMuted, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textLight,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Ukan v1.0.0 (Build 2024.11)',
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'DÉMO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentRed.withOpacity(0.15),
          foregroundColor: _accentRed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: _accentRed.withOpacity(0.3)),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildUnitsQuickSwitch() {
    final isMetric = _unitsNotifier.isMetric;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _unitsNotifier.setMetricSystem(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isMetric ? _primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.public,
                      size: 18,
                      color: isMetric ? _darkBg : _textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Métrique',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isMetric ? _darkBg : _textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(kg, cm, km)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isMetric ? _darkBg.withOpacity(0.7) : _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _unitsNotifier.setImperialSystem(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isMetric ? _primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      size: 18,
                      color: !isMetric ? _darkBg : _textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Impérial',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: !isMetric ? _darkBg : _textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(lbs, ft, mi)',
                      style: TextStyle(
                        fontSize: 11,
                        color: !isMetric ? _darkBg.withOpacity(0.7) : _textMuted,
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

  Widget _buildUnitSelector({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String currentValue,
    required List<String> options,
    required Function(int) onSelected,
    required int selectedIndex,
  }) {
    return InkWell(
      onTap: () => _showUnitPickerDialog(
        title: title,
        options: options,
        selectedIndex: selectedIndex,
        onSelected: onSelected,
        color: color,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                currentValue.split(' ')[0], // Affiche juste "Kilogrammes" pas "(kg)"
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: _textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  void _showUnitPickerDialog({
    required String title,
    required List<String> options,
    required int selectedIndex,
    required Function(int) onSelected,
    required Color color,
  }) {
    showModalBottomSheet(
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
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Titre
            Row(
              children: [
                Icon(Icons.straighten, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Choisir l\'unité de $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Options
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = index == selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    onSelected(index);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : _borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? color : _textLight,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: color, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showDemoSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fonctionnalité à venir'),
        backgroundColor: _primaryGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
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
            const Text(
              'Choisir la langue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textLight,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption('Français', '🇫🇷', true),
            _buildLanguageOption('English', '🇬🇧', false),
            _buildLanguageOption('Español', '🇪🇸', false),
            _buildLanguageOption('Deutsch', '🇩🇪', false),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String lang, String flag, bool selected) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(lang, style: const TextStyle(color: _textLight)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: _primaryGold)
          : null,
      onTap: () {
        Navigator.pop(context);
        if (!selected) _showDemoSnackbar('Langue');
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: _primaryGold),
            SizedBox(width: 10),
            Text('Exporter mes données', style: TextStyle(color: _textLight)),
          ],
        ),
        content: const Text(
          'Un fichier contenant toutes vos données sera préparé et envoyé à votre adresse email.',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDemoSnackbar('Export');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGold,
              foregroundColor: _darkBg,
            ),
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: _accentRed),
            SizedBox(width: 10),
            Text('Supprimer mon compte', style: TextStyle(color: _accentRed)),
          ],
        ),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront définitivement supprimées.',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Suppression du compte (mode démo)'),
                  backgroundColor: _accentRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentRed,
              foregroundColor: _textLight,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
