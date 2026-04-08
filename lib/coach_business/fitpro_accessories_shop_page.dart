import 'package:flutter/material.dart';

// Couleurs professionnelles : Marron et Gris clair pour Coach Business
const Color _marronPrincipalBusiness = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonceBusiness = Color(0xFF5D4037); // Material Brown 700
const Color _marronClairBusiness = Color(0xFFA1887F); // Material Brown 300
const Color _grisClairBusiness = Color(0xFFE0E0E0); // Material Grey 300
const Color _grisPrincipalBusiness = Color(0xFF9E9E9E); // Material Grey 500
const Color _grisFonceBusiness = Color(0xFF616161); // Material Grey 700

/// Modèle pour un accessoire Ukan
class UkanAccessory {
  final String id;
  final String name;
  final String description;
  final double price;
  final String materials;
  final String usage;
  final String sportType;
  final String imageEmoji; // Emoji à la place d'une vraie image
  final String? imagePath; // Chemin vers l'image principale (optionnel)
  final List<String>? imagePaths; // Liste de chemins vers plusieurs images (optionnel)

  const UkanAccessory({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.materials,
    required this.usage,
    required this.sportType,
    required this.imageEmoji,
    this.imagePath,
    this.imagePaths,
  });
  
  // Retourne la première image disponible
  String? get firstImagePath => imagePath ?? (imagePaths != null && imagePaths!.isNotEmpty ? imagePaths!.first : null);
  
  // Retourne toutes les images disponibles
  List<String> get allImagePaths {
    final List<String> paths = [];
    if (imagePath != null) paths.add(imagePath!);
    if (imagePaths != null) paths.addAll(imagePaths!);
    return paths;
  }
}

/// Page boutique d'accessoires Ukan (mode démo)
class UkanAccessoriesShopPage extends StatefulWidget {
  const UkanAccessoriesShopPage({super.key});

  @override
  State<UkanAccessoriesShopPage> createState() => _UkanAccessoriesShopPageState();
}

class _UkanAccessoriesShopPageState extends State<UkanAccessoriesShopPage> {
  // Accessoires connectés Ukan uniquement
  final List<UkanAccessory> _accessories = const [
    UkanAccessory(
      id: 'gourde_connectee',
      name: 'Gourde Connectée Ukan',
      description: 'Gourde intelligente connectée à l\'application Ukan qui calcule automatiquement votre consommation d\'eau quotidienne. Synchronisation Bluetooth, suivi en temps réel et rappels d\'hydratation.',
      price: 49.90,
      materials: 'Inox 18/10, capteurs électroniques, Bluetooth 5.0',
      usage: 'Hydratation connectée, suivi automatique de la consommation d\'eau, rappels personnalisés',
      sportType: 'Tous sports, bien-être',
      imageEmoji: '💧',
      imagePath: 'assets/images/gourde_connectee_fitpro.png',
    ),
    UkanAccessory(
      id: 'assiette_connectee',
      name: 'Assiette Connectée Ukan',
      description: 'Assiette intelligente avec balance intégrée et reconnaissance IA des aliments. Calcule automatiquement le poids, les calories et identifie les aliments pour un suivi nutritionnel précis dans Ukan.',
      price: 89.90,
      materials: 'Céramique, capteurs de poids, caméra IA, Bluetooth 5.0',
      usage: 'Suivi nutritionnel automatique, calcul de calories, reconnaissance des aliments, pesée précise',
      sportType: 'Nutrition, bien-être, perte de poids',
      imageEmoji: '🍽️',
      imagePath: 'assets/images/assiette_connectee_fitpro.png',
    ),
    UkanAccessory(
      id: 'tapis_compteur_mouvements',
      name: 'Tapis Compteur de Mouvements Ukan',
      description: 'Tapis de sport connecté qui détecte et compte automatiquement vos mouvements (pompes, squats, planches, etc.). Synchronisation avec Ukan pour un suivi d\'entraînement précis et motivant.',
      price: 79.90,
      materials: 'Mousse haute densité, capteurs de pression, Bluetooth 5.0',
      usage: 'Comptage automatique des répétitions, détection des mouvements, suivi d\'entraînement connecté',
      sportType: 'Fitness, musculation, HIIT, entraînement à domicile',
      imageEmoji: '🏋️',
      imagePath: 'assets/images/tapis_compteur_mouvements_fitpro_1.png',
      imagePaths: [
        'assets/images/tapis_compteur_mouvements_fitpro_1.png',
        'assets/images/tapis_compteur_mouvements_fitpro_2.png',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: _marronFonceBusiness,
        foregroundColor: Colors.white,
        title: const Text('Boutique Accessoires Ukan (démo)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _grisClairBusiness,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _marronPrincipalBusiness, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: _marronFonceBusiness, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Accessoires vendus par l\'application, que les coachs peuvent recommander à leurs clients.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Debug: Afficher le nombre d'accessoires
            Text(
              '${_accessories.length} accessoires disponibles',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: _accessories.length,
              itemBuilder: (context, index) {
                final accessory = _accessories[index];
                return _AccessoryCard(
                  accessory: accessory,
                  onTap: () {
                    _showAccessoryDetail(accessory);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccessoryDetail(UkanAccessory accessory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_marronPrincipalBusiness, _marronFonceBusiness],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: accessory.firstImagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          accessory.firstImagePath!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Text(
                                              accessory.imageEmoji,
                                              style: const TextStyle(fontSize: 32),
                                            );
                                          },
                                        ),
                                      )
                                    : Text(
                                        accessory.imageEmoji,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  accessory.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Grande image de l'article en haut de la vue détaillée
              if (accessory.firstImagePath != null)
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.white,
                  child: Image.asset(
                    accessory.firstImagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF4F4F4),
                        child: Center(
                          child: Text(
                            accessory.imageEmoji,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge et prix
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _marronPrincipalBusiness.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _marronPrincipalBusiness),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 16, color: _marronPrincipalBusiness),
                              SizedBox(width: 6),
                              Text(
                                'Produit officiel Ukan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _marronFonceBusiness,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _grisClairBusiness,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _grisPrincipalBusiness),
                          ),
                          child: Text(
                            '${accessory.price.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: _grisFonceBusiness,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Galerie d'images si plusieurs images disponibles
                    if (accessory.allImagePaths.length > 1) ...[
                      const Text(
                        'Galerie',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: accessory.allImagePaths.length,
                          itemBuilder: (context, index) {
                            final imagePath = accessory.allImagePaths[index];
                            return Container(
                              width: 300,
                              margin: EdgeInsets.only(
                                right: index < accessory.allImagePaths.length - 1 ? 12 : 0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFF4F4F4),
                                      child: Center(
                                        child: Text(
                                          accessory.imageEmoji,
                                          style: const TextStyle(fontSize: 48),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      accessory.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Détails
                    _DetailRow(icon: Icons.build, label: 'Matériaux', value: accessory.materials),
                    const SizedBox(height: 16),
                    _DetailRow(icon: Icons.info_outline, label: 'Usage', value: accessory.usage),
                    const SizedBox(height: 16),
                    _DetailRow(icon: Icons.fitness_center, label: 'Type de sport', value: accessory.sportType),
                    const SizedBox(height: 32),
                    // Bouton ajouter au panier
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${accessory.name} ajouté au panier (mode démo, aucune commande réelle).'),
                              backgroundColor: _marronPrincipalBusiness,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'OK',
                                textColor: Colors.white,
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart, size: 20),
                        label: const Text(
                          'Ajouter au panier (démo)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _marronPrincipalBusiness,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessoryCard extends StatelessWidget {
  final UkanAccessory accessory;
  final VoidCallback onTap;

  const _AccessoryCard({
    required this.accessory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image ou emoji
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: accessory.firstImagePath != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Image.asset(
                        accessory.firstImagePath!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          // Si l'image n'existe pas, afficher l'emoji
                          return Container(
                            color: const Color(0xFFF4F4F4),
                            child: Center(
                              child: Text(
                                accessory.imageEmoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF4F4F4),
                      child: Center(
                        child: Text(
                          accessory.imageEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _marronPrincipalBusiness.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 10, color: _marronPrincipalBusiness),
                          SizedBox(width: 3),
                          Text(
                            'Ukan',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _marronFonceBusiness,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Nom
                    Text(
                      accessory.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Description courte
                    Expanded(
                      child: Text(
                        accessory.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Prix
                    Text(
                      '${accessory.price.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _grisFonceBusiness,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

