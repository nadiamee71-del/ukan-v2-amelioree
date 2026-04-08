import 'package:flutter/material.dart';
import '../models/coach_business.dart';
import 'coach_program_detail_page.dart';

// Couleurs professionnelles : Marron et Gris clair pour Coach Business
const Color _marronPrincipalBusiness = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonceBusiness = Color(0xFF5D4037); // Material Brown 700
const Color _marronClairBusiness = Color(0xFFA1887F); // Material Brown 300
const Color _grisClairBusiness = Color(0xFFE0E0E0); // Material Grey 300
const Color _grisPrincipalBusiness = Color(0xFF9E9E9E); // Material Grey 500
const Color _grisFonceBusiness = Color(0xFF616161); // Material Grey 700

class CoachProductsPage extends StatefulWidget {
  const CoachProductsPage({super.key});

  @override
  State<CoachProductsPage> createState() => _CoachProductsPageState();
}

class _CoachProductsPageState extends State<CoachProductsPage> {
  final _productsNotifier = CoachProductsNotifier();

  // Programmes en dur pour la démo
  final List<CoachProduct> _demoProducts = [
    const CoachProduct(
      id: 'weight_loss',
      title: 'Perte de poids – 12 semaines',
      description: 'Programme complet pour perdre 3 à 6 kg de manière saine et durable.',
      level: 'Débutant à intermédiaire',
      durationWeeks: 12,
      price: 89.0,
    ),
    const CoachProduct(
      id: 'muscle_power',
      title: 'Muscle & Power – 8 semaines',
      description: 'Développe ta masse musculaire et ta force avec des séances intensives.',
      level: 'Intermédiaire à avancé',
      durationWeeks: 8,
      price: 79.0,
    ),
    const CoachProduct(
      id: 'hiit_express',
      title: 'HIIT Express – 4 semaines',
      description: 'Programme court et intense pour des résultats rapides en 4 semaines.',
      level: 'Tous niveaux',
      durationWeeks: 4,
      price: 49.0,
    ),
    const CoachProduct(
      id: 'abs_challenge',
      title: 'Défi Abdos – 6 semaines',
      description: 'Focus sur le renforcement du core et des abdominaux.',
      level: 'Débutant à intermédiaire',
      durationWeeks: 6,
      price: 59.0,
    ),
    const CoachProduct(
      id: 'yoga_flex',
      title: 'Yoga & Flexibilité – 10 semaines',
      description: 'Améliore ta souplesse et ta mobilité avec des séances de yoga.',
      level: 'Tous niveaux',
      durationWeeks: 10,
      price: 69.0,
    ),
    const CoachProduct(
      id: 'endurance',
      title: 'Endurance Cardio – 8 semaines',
      description: 'Programme d\'endurance pour améliorer ta capacité cardio-vasculaire.',
      level: 'Intermédiaire',
      durationWeeks: 8,
      price: 65.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _productsNotifier.addListener(_onProductsChanged);
  }

  @override
  void dispose() {
    _productsNotifier.removeListener(_onProductsChanged);
    super.dispose();
  }

  void _onProductsChanged() {
    if (mounted) setState(() {});
  }

  // Merger les produits du notifier avec les produits démo
  List<CoachProduct> get _allProducts {
    final List<CoachProduct> all = [];
    all.addAll(_demoProducts);
    all.addAll(_productsNotifier.products);
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = _allProducts;

    return Scaffold(
      backgroundColor: _grisClairBusiness,
      appBar: AppBar(
        backgroundColor: _marronFonceBusiness,
        foregroundColor: Colors.white,
        title: const Text('Mes programmes'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: allProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun programme pour l\'instant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: allProducts.length,
                      itemBuilder: (context, index) {
                        final product = allProducts[index];
                        return _ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CoachProgramDetailPage(product: product),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Pour la démo, on peut juste afficher un SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité de création en démonstration'),
                        backgroundColor: _marronFonceBusiness,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Créer un programme'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _marronFonceBusiness,
                    side: const BorderSide(color: _marronFonceBusiness),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CoachProduct product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (product.description.isNotEmpty)
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Prix
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _marronPrincipalBusiness.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${product.price.toStringAsFixed(0)} €',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _marronPrincipalBusiness,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.schedule,
                      label: '${product.durationWeeks} semaines',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.trending_up,
                      label: product.level,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Voir le détail'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.black54,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
