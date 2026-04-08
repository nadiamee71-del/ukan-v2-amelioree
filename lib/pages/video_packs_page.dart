import 'package:flutter/material.dart';
import '../models/demo_purchase.dart';
import '../models/video_pack.dart';
import '../data/demo_exercises.dart';
import '../exercises/exercise_library_page.dart';
import '../pages/demo_payment_page.dart';

/// Page des packs vidéos disponibles à l'achat (démo)
class VideoPacksPage extends StatefulWidget {
  final String? highlightPackId; // Pour scroller jusqu'à un pack spécifique

  const VideoPacksPage({super.key, this.highlightPackId});

  @override
  State<VideoPacksPage> createState() => _VideoPacksPageState();
}

class _VideoPacksPageState extends State<VideoPacksPage> {
  final _purchaseNotifier = DemoPurchaseNotifier();

  @override
  void initState() {
    super.initState();
    _purchaseNotifier.addListener(_onPurchasesChanged);
  }

  @override
  void dispose() {
    _purchaseNotifier.removeListener(_onPurchasesChanged);
    super.dispose();
  }

  void _onPurchasesChanged() {
    setState(() {});
  }

  // Liste des packs vidéos disponibles (depuis DemoExercises)
  List<VideoPack> get _availablePacks => DemoExercises.videoPacks;

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2)} €';
  }

  @override
  Widget build(BuildContext context) {
    final packs = _availablePacks;
    final _scrollController = ScrollController();

    // Scroll vers le pack à mettre en évidence si spécifié
    if (widget.highlightPackId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final index = packs.indexWhere((p) => p.id == widget.highlightPackId);
        if (index != -1 && _scrollController.hasClients) {
          _scrollController.animateTo(
            index * 200.0, // Estimation de la hauteur d'un item
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Mon Espace Santé'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Bandeau Mode démo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4CC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFC300),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF111111),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode démo – paiements simulés',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Liste des packs
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: packs.length,
                itemBuilder: (context, index) {
                  final pack = packs[index];
                  final isOwned = _purchaseNotifier.hasVideoPack(pack.title);
                  final isHighlighted = pack.id == widget.highlightPackId;
                  final exerciseCount = DemoExercises.getExercisesByPackId(pack.id).length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: isHighlighted
                          ? Border.all(
                              color: const Color(0xFFFFC300),
                              width: 3,
                            )
                          : isOwned
                              ? Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                  width: 2,
                                )
                              : null,
                      boxShadow: isHighlighted
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFC300).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.video_library_outlined,
                                color: Colors.blue,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          pack.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: isOwned
                                                ? Colors.black87
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isOwned)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color: Colors.green.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Possédé',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pack.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.video_camera_back_outlined,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                  Text(
                                    '$exerciseCount exercices',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatPrice(pack.price),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isOwned
                                    ? Colors.grey.shade400
                                    : const Color(0xFF111111),
                              ),
                            ),
                            if (!isOwned)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DemoPaymentPage(
                                        purchaseType: PurchaseType.videoPack,
                                        itemTitle: pack.title,
                                        price: pack.price,
                                        onPaymentSuccess: () {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ).then((success) {
                                    if (success == true && mounted) {
                                      setState(() {});
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF111111),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Acheter (démo)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Naviguer vers la bibliothèque avec filtrage sur ce pack
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ExerciseLibraryPage(
                                            initialPackId: pack.id,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.fitness_center, size: 18),
                                    label: const Text('Voir les exercices'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF111111),
                                      side: const BorderSide(color: Color(0xFF111111)),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pack débloqué',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


