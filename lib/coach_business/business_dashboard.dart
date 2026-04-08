import 'package:flutter/material.dart';
import '../models/coach_business.dart';
import '../models/demo_purchase.dart';
import '../pages/demo_payment_page.dart';
import 'coach_branding_page.dart';
import 'coach_products_page.dart';
import 'coach_programs_catalog_page.dart';
import 'fitpro_accessories_shop_page.dart';
import '../coach_clients_page.dart';
import 'coach_sessions_today_page.dart';
import '../coach_planning_page.dart';

// Palette noir/or pour Coach Business
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);
const Color _borderColor = Color(0xFF30363D);
// Couleurs héritées pour compatibilité
const Color _marronPrincipalBusiness = Color(0xFFFFC300); // Remplacé par or
const Color _marronFonceBusiness = Color(0xFF161B22); // Remplacé par cardBg
const Color _marronClairBusiness = Color(0xFF21262D); // Remplacé par cardBgLight
const Color _grisClairBusiness = Color(0xFF30363D); // Remplacé par borderColor
const Color _grisPrincipalBusiness = Color(0xFF8B949E); // Remplacé par textMuted
const Color _grisFonceBusiness = Color(0xFFF0F6FC); // Remplacé par textLight

class CoachBusinessDashboard extends StatefulWidget {
  const CoachBusinessDashboard({super.key});

  @override
  State<CoachBusinessDashboard> createState() => _CoachBusinessDashboardState();
}

class _CoachBusinessDashboardState extends State<CoachBusinessDashboard> {
  final _brandingNotifier = CoachBrandingNotifier();
  final _productsNotifier = CoachProductsNotifier();

  @override
  void initState() {
    super.initState();
    _brandingNotifier.addListener(_onDataChanged);
    _productsNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _brandingNotifier.removeListener(_onDataChanged);
    _productsNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  // Méthode pour afficher les démos de features
  void _showFeatureDemo(String title, String featureType) {
      showModalBottomSheet(
      context: this.context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (featureType == 'branding') _buildBrandingDemo(),
              if (featureType == 'programmes') _buildProgrammesDemo(),
              if (featureType == 'analytics') _buildAnalyticsDemo(),
              if (featureType == 'crm') _buildCrmDemo(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bientôt disponible dans la vraie version ! 🚀'),
                        backgroundColor: _marronPrincipalBusiness,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _marronPrincipalBusiness,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Voir en démo',
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

  Widget _buildBrandingDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personnalise ton identité de marque :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Exemple de nom de marque
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _grisPrincipalBusiness.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.abc, size: 20, color: _grisPrincipalBusiness),
                  const SizedBox(width: 12),
                  const Text(
                    'Nom de marque',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FitBody by Sarah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Exemple de palette de couleurs
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _grisPrincipalBusiness.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette, size: 20, color: _grisPrincipalBusiness),
                  const SizedBox(width: 12),
                  const Text(
                    'Palette de couleurs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ColorBox(color: _marronPrincipalBusiness),
                  const SizedBox(width: 8),
                  _ColorBox(color: _grisPrincipalBusiness),
                  const SizedBox(width: 8),
                  _ColorBox(color: _marronClairBusiness),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _DemoItem(
          icon: Icons.image,
          title: 'Visuels réseaux sociaux',
          description: 'Templates personnalisés pour Instagram, Facebook, etc.',
        ),
      ],
    );
  }

  Widget _buildProgrammesDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Templates de programmes vendables :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _DemoItem(
          icon: Icons.fitness_center,
          title: 'Pack Perte de poids 12 semaines',
          description: 'Programme complet avec suivi nutritionnel et entraînements personnalisés',
        ),
        const SizedBox(height: 12),
        _DemoItem(
          icon: Icons.trending_up,
          title: 'Pack Prise de masse premium',
          description: 'Plan d\'entraînement et nutrition pour gagner en masse musculaire',
        ),
        const SizedBox(height: 12),
        _DemoItem(
          icon: Icons.favorite,
          title: 'Pack Post-partum en douceur',
          description: 'Retour au sport adapté après la grossesse',
        ),
      ],
    );
  }

  Widget _buildAnalyticsDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vue globale de ton activité (fake) :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _StatRow(label: 'Revenus estimés (démo)', value: '2 450 €', color: _marronPrincipalBusiness),
              const SizedBox(height: 12),
              _StatRow(label: 'Programmes vendus (démo)', value: '34', color: _grisPrincipalBusiness),
              const SizedBox(height: 12),
              _StatRow(label: 'Clients actifs (démo)', value: '18', color: _marronClairBusiness),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCrmDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suivi simple de tes clients (fictifs) :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _ClientRow(name: 'Emma', program: 'Perte de poids', status: 'En cours', statusColor: _marronPrincipalBusiness),
        const SizedBox(height: 12),
        _ClientRow(name: 'Karim', program: 'CrossFit', status: 'Fidèle', statusColor: _grisPrincipalBusiness),
        const SizedBox(height: 12),
        _ClientRow(name: 'Sarah', program: 'Post-partum', status: 'Fin de programme', statusColor: Colors.grey),
      ],
    );
  }

  // Données en dur pour la démo
  double get _revenueThisMonth => 1280.0; // €
  int get _activeClients => 18;
  int get _activePrograms => 6;
  double get _satisfactionRate => 4.7; // /5

  // Ventes sur 4 semaines (fictives)
  final List<int> _weeklySales = [280, 320, 290, 390]; // €

  // Top programmes (fictifs)
  final List<_TopProgram> _topPrograms = [
    const _TopProgram(title: 'Perte de poids – 12 semaines', sales: 32),
    const _TopProgram(title: 'Muscle & Power – 8 semaines', sales: 20),
    const _TopProgram(title: 'HIIT Express – 4 semaines', sales: 11),
  ];

  @override
  Widget build(BuildContext context) {
    final purchaseNotifier = DemoPurchaseNotifier();
    final hasBusinessPack = purchaseNotifier.hasBusinessPack;

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
          'Coach Business Pack™',
          style: TextStyle(fontWeight: FontWeight.w700, color: _textLight),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Tag Mode démo
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _cardBgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryGold.withOpacity(0.3)),
                ),
                child: const Text(
                  'Mode démo',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primaryGold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sous-titre
              Text(
                'Tout ton business de coach en un coup d\'œil.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Section "Résumé du pack" (visible même si acheté ou non)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Mode démo en haut à droite
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
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _marronPrincipalBusiness.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.store_mall_directory_outlined,
                                      color: _marronPrincipalBusiness,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Coach Business Pack™',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          '29,99 €',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: _marronFonceBusiness,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Mode démo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Débloque les outils essentiels pour développer ton activité de coach.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _FeatureListItem(
                      text: 'Branding personnalisé complet (logo, couleurs, visuels)',
                      icon: Icons.palette,
                    ),
                    const SizedBox(height: 12),
                    const _FeatureListItem(
                      text: 'Création de programmes vendables (templates d\'offres)',
                      icon: Icons.fitness_center,
                    ),
                    const SizedBox(height: 12),
                    const _FeatureListItem(
                      text: 'Dashboard analytics avancé (suivi revenus / clients en démo)',
                      icon: Icons.analytics,
                    ),
                    const SizedBox(height: 12),
                    const _FeatureListItem(
                      text: 'Gestion clients professionnelle (CRM simplifié en démo)',
                      icon: Icons.people,
                    ),
                    const SizedBox(height: 12),
                    const _FeatureListItem(
                      text: 'Accès catalogue de programmes & boutique d\'accessoires (mode démo)',
                      icon: Icons.shopping_bag,
                    ),
                    if (!hasBusinessPack) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DemoPaymentPage(
                                  purchaseType: PurchaseType.businessPack,
                                  itemTitle: 'Coach Business Pack™',
                                  price: 29.99,
                                ),
                              ),
                            ).then((success) {
                              if (success == true && mounted) {
                                setState(() {});
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _marronPrincipalBusiness,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Acheter (démo)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Section "Ce que tu débloques" (visible même si pas encore acheté)
              if (!hasBusinessPack) ...[
                const SizedBox(height: 32),
                const Text(
                  'Ce que tu débloques',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _FeaturePreviewCard(
                  title: 'Branding & Image',
                  subtitle: 'Logo, couleurs, visuels personnalisés',
                  status: 'En démo – maquette uniquement',
                  icon: Icons.palette,
                  color: _grisPrincipalBusiness,
                  onTap: () {
                    _showFeatureDemo('Branding & Image', 'branding');
                  },
                ),
                const SizedBox(height: 12),
                _FeaturePreviewCard(
                  title: 'Programmes & Offres coach',
                  subtitle: 'Catalogue de programmes vendables (démo)',
                  status: 'En démo – maquette uniquement',
                  icon: Icons.fitness_center,
                  color: _marronPrincipalBusiness,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CoachProgramsCatalogPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _FeaturePreviewCard(
                  title: 'Analytics Business',
                  subtitle: 'Vue globale de ton chiffre & de tes clients (fake)',
                  status: 'En démo – maquette uniquement',
                  icon: Icons.analytics,
                  color: _grisPrincipalBusiness,
                  onTap: () {
                    _showFeatureDemo('Analytics Business', 'analytics');
                  },
                ),
                const SizedBox(height: 12),
                _FeaturePreviewCard(
                  title: 'Gestion clients (CRM)',
                  subtitle: 'Suivi de tes clients en un coup d\'œil',
                  status: 'En démo – maquette uniquement',
                  icon: Icons.people,
                  color: _marronClairBusiness,
                  onTap: () {
                    _showFeatureDemo('Gestion clients (CRM)', 'crm');
                  },
                ),
                const SizedBox(height: 24),

                // Section Boutique Accessoires Ukan (visible même si pas acheté)
                const Text(
                  'Boutique Accessoires Ukan (démo)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accessoires vendus par l\'application, que les coachs peuvent recommander à leurs clients.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                _FeaturePreviewCard(
                  title: 'Boutique Accessoires Ukan',
                  subtitle: 'Accessoires officiels vendus par l\'application (démo)',
                  status: 'En démo – maquette uniquement',
                  icon: Icons.shopping_bag,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UkanAccessoriesShopPage(),
                      ),
                    );
                  },
                ),
              ] else ...[
                // Si déjà acheté, afficher badge "Pack actif"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _grisFonceBusiness.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _grisFonceBusiness,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _grisPrincipalBusiness,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pack actif',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _grisClairBusiness,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tu as accès à tous les outils du Business Pack.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bloc 1 : KPIs (4 cartes sur 2 lignes)
                Row(
                  children: [
                    Expanded(
                      child: _KPICard(
                        label: 'Revenu estimé\nce mois',
                        value: '${_revenueThisMonth.toStringAsFixed(0)} €',
                        icon: Icons.euro,
                        color: _marronPrincipalBusiness,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KPICard(
                        label: 'Clients actifs',
                        value: '$_activeClients',
                        icon: Icons.people,
                        color: _marronPrincipalBusiness,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _KPICard(
                        label: 'Programmes actifs',
                        value: '$_activePrograms',
                        icon: Icons.fitness_center,
                        color: _grisPrincipalBusiness,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KPICard(
                        label: 'Taux de satisfaction',
                        value: '$_satisfactionRate / 5',
                        icon: Icons.star,
                        color: _grisPrincipalBusiness,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bloc 2 : Ventes sur 4 semaines
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ventes sur 4 semaines',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Tendance : ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const Text(
                            'en hausse ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _grisPrincipalBusiness,
                            ),
                          ),
                          const Text('👍', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Graphique simple avec barres
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SalesBar(week: 'S1', amount: _weeklySales[0], maxAmount: _weeklySales.reduce((a, b) => a > b ? a : b)),
                          _SalesBar(week: 'S2', amount: _weeklySales[1], maxAmount: _weeklySales.reduce((a, b) => a > b ? a : b)),
                          _SalesBar(week: 'S3', amount: _weeklySales[2], maxAmount: _weeklySales.reduce((a, b) => a > b ? a : b)),
                          _SalesBar(week: 'S4', amount: _weeklySales[3], maxAmount: _weeklySales.reduce((a, b) => a > b ? a : b)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _weeklySales.map((amount) {
                          return Text(
                            '$amount€',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bloc 3 : Top programmes
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top programmes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._topPrograms.map((program) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    program.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _marronPrincipalBusiness.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${program.sales} ventes',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _marronFonceBusiness,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bloc 4 : Actions rapides
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Voir mes clients',
                  icon: Icons.people,
                  iconEmoji: '👥',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CoachClientsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Mes programmes',
                  icon: Icons.fitness_center,
                  iconEmoji: '📦',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CoachProductsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Mon branding',
                  icon: Icons.palette,
                  iconEmoji: '🎨',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CoachBrandingPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Mon Planning',
                  icon: Icons.calendar_today,
                  iconEmoji: '📅',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CoachPlanningPage(
                          coachId: 'sophie_martin', // ID du coach actuel (à adapter)
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Séances du jour',
                  icon: Icons.calendar_today,
                  iconEmoji: '📅',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CoachSessionsTodayPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Section Boutique Accessoires Ukan
                const Text(
                  'Boutique Accessoires Ukan (démo)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accessoires vendus par l\'application, que les coachs peuvent recommander à leurs clients.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: 'Voir la boutique accessoires',
                  icon: Icons.shopping_bag,
                  iconEmoji: '🛍️',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UkanAccessoriesShopPage(),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesBar extends StatelessWidget {
  final String week;
  final int amount;
  final int maxAmount;

  const _SalesBar({
    required this.week,
    required this.amount,
    required this.maxAmount,
  });

  @override
  Widget build(BuildContext context) {
    final height = (amount / maxAmount) * 100.0; // Hauteur relative
    return Column(
      children: [
        Container(
          width: 40,
          height: height.clamp(20.0, 100.0),
          decoration: BoxDecoration(
            color: _marronPrincipalBusiness,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          week,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TopProgram {
  final String title;
  final int sales;

  const _TopProgram({
    required this.title,
    required this.sales,
  });
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String iconEmoji;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.iconEmoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _marronFonceBusiness.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  iconEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FeatureListItem({
    required this.text,
    this.icon = Icons.check_circle_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: _marronPrincipalBusiness,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeaturePreviewCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}


class _DemoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _DemoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _marronPrincipalBusiness.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: _marronPrincipalBusiness),
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
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClientRow extends StatelessWidget {
  final String name;
  final String program;
  final String status;
  final Color statusColor;

  const _ClientRow({
    required this.name,
    required this.program,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  program,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;

  const _ColorBox({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
    );
  }
}
