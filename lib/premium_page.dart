import 'package:flutter/material.dart';
import 'models/subscription.dart';
import 'models/demo_purchase.dart';
import 'pages/demo_payment_page.dart';
import 'pages/video_packs_page.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM PAGE - Thème Noir & Or
// ═══════════════════════════════════════════════════════════════════════════

// Palette noir/or uniforme
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final _subscriptionNotifier = SubscriptionNotifier();

  @override
  void initState() {
    super.initState();
    _subscriptionNotifier.addListener(_onSubscriptionChanged);
  }

  @override
  void dispose() {
    _subscriptionNotifier.removeListener(_onSubscriptionChanged);
    super.dispose();
  }

  void _onSubscriptionChanged() {
    setState(() {});
  }

  void _handlePackSelection(BuildContext context, SubscriptionPack pack) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DemoPaymentPage(
          purchaseType: PurchaseType.premium,
          itemTitle: '${pack.displayName} - Abonnement mensuel',
          price: pack.monthlyPrice,
          onPaymentSuccess: () {
            _subscriptionNotifier.activatePremiumDemo();
          },
        ),
      ),
    ).then((success) {
      if (success == true && mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildPackCard({
    required BuildContext context,
    required SubscriptionPack pack,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPopular ? _primaryGold : _borderColor,
            width: isPopular ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              pack.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _textLight,
                              ),
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _primaryGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'POPULAIRE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: _darkBg,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pack.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${pack.monthlyPrice.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _primaryGold,
                      ),
                    ),
                    const Text(
                      '/mois',
                      style: TextStyle(
                        fontSize: 11,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: _borderColor, height: 1),
            const SizedBox(height: 12),
            ...pack.features.take(3).map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: _primaryGold,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
            if (pack.features.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${pack.features.length - 3} autres avantages',
                  style: TextStyle(
                    fontSize: 11,
                    color: _primaryGold.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular ? _primaryGold : _cardBgLight,
                  foregroundColor: isPopular ? _darkBg : _textLight,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isPopular ? _primaryGold : _borderColor,
                    ),
                  ),
                ),
                child: Text(
                  'Choisir ${pack.displayName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
    final plan = _subscriptionNotifier.plan;
    final purchaseNotifier = DemoPurchaseNotifier();
    final hasPremium = purchaseNotifier.hasPremium;

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
          'Ukan Premium',
          style: TextStyle(fontWeight: FontWeight.w700, color: _textLight),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bandeau Mode démo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primaryGold.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: _primaryGold,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mode démo – paiements simulés',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Titre centré
              const Center(
                child: Text(
                  'Ukan Premium',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _textLight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Débloquez tout le potentiel de Ukan',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Carte "Offre actuelle"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Offre actuelle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Tu es actuellement : ${plan.displayName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textLight,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: plan == SubscriptionPlan.premium
                                ? _primaryGold
                                : _cardBgLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            plan.displayName,
                            style: TextStyle(
                              color: plan == SubscriptionPlan.premium
                                  ? _darkBg
                                  : _textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section Version GRATUITE
              const Text(
                'Avec la version GRATUITE, tu peux déjà :',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textLight,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: const Column(
                  children: [
                    _PremiumFeatureItem(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      title: 'Suivre tes séances',
                    ),
                    SizedBox(height: 10),
                    _PremiumFeatureItem(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      title: 'Ajouter tes repas et calories',
                    ),
                    SizedBox(height: 10),
                    _PremiumFeatureItem(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      title: 'Voir ton tableau de bord',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section UKAN PREMIUM
              const Text(
                'Avec UKAN PREMIUM, tu débloques :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primaryGold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primaryGold.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    _PremiumFeatureItem(
                      icon: Icons.group,
                      iconColor: _primaryGold,
                      title: 'Entraînement à plusieurs (Rooms)',
                      description: 'Partage tes séances avec tes amis',
                    ),
                    SizedBox(height: 14),
                    _PremiumFeatureItem(
                      icon: Icons.trending_up,
                      iconColor: _primaryGold,
                      title: 'Suivi avancé de la silhouette',
                      description: 'Mensurations et progression',
                    ),
                    SizedBox(height: 14),
                    _PremiumFeatureItem(
                      icon: Icons.chat_bubble_outline,
                      iconColor: _primaryGold,
                      title: 'Chat coach prioritaire',
                      description: 'Réponses rapides',
                    ),
                    SizedBox(height: 14),
                    _PremiumFeatureItem(
                      icon: Icons.bar_chart,
                      iconColor: _primaryGold,
                      title: 'Statistiques détaillées',
                      description: 'Graphiques avancés',
                    ),
                    SizedBox(height: 14),
                    _PremiumFeatureItem(
                      icon: Icons.video_library_outlined,
                      iconColor: _primaryGold,
                      title: 'Vidéos d\'exercices',
                      description: 'Bibliothèque complète',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Section Packs Vidéos individuels
              const Text(
                'Packs Vidéos individuels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Achetez des packs vidéos sans abonnement.',
                style: TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.video_library_outlined,
                        color: _primaryGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pack HIIT, Renforcement, Yoga...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textLight,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Packs vidéos thématiques',
                            style: TextStyle(
                              fontSize: 12,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: _primaryGold),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoPacksPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section Packs d'abonnement
              const Text(
                'Choisissez votre pack',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Des offres adaptées à vos besoins',
                style: TextStyle(
                  fontSize: 13,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 20),

              // Packs Individuels
              const Text(
                'Packs Individuels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildPackCard(
                context: context,
                pack: SubscriptionPack.start,
                isPopular: false,
                onTap: () => _handlePackSelection(context, SubscriptionPack.start),
              ),
              const SizedBox(height: 12),
              _buildPackCard(
                context: context,
                pack: SubscriptionPack.basic,
                isPopular: false,
                onTap: () => _handlePackSelection(context, SubscriptionPack.basic),
              ),
              const SizedBox(height: 12),
              _buildPackCard(
                context: context,
                pack: SubscriptionPack.premium,
                isPopular: true,
                onTap: () => _handlePackSelection(context, SubscriptionPack.premium),
              ),
              const SizedBox(height: 28),

              // Packs Groupe
              const Text(
                'Packs Groupe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildPackCard(
                context: context,
                pack: SubscriptionPack.duo,
                isPopular: false,
                onTap: () => _handlePackSelection(context, SubscriptionPack.duo),
              ),
              const SizedBox(height: 12),
              _buildPackCard(
                context: context,
                pack: SubscriptionPack.famille,
                isPopular: false,
                onTap: () => _handlePackSelection(context, SubscriptionPack.famille),
              ),
              const SizedBox(height: 28),
              
              // Section abonnement actif
              if (hasPremium) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _primaryGold.withOpacity(0.4)),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: _primaryGold,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Abonnement actif',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _primaryGold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tu es déjà en version Premium (démo).',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _subscriptionNotifier.resetToFree();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Retour à la version gratuite'),
                          backgroundColor: _cardBgLight,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textMuted,
                      side: const BorderSide(color: _borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Revenir à la version gratuite'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumFeatureItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;

  const _PremiumFeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textLight,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                    height: 1.3,
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
