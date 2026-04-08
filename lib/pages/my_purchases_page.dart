import 'package:flutter/material.dart';
import '../models/demo_purchase.dart';
import '../models/subscription.dart';

/// Page "Mes achats (démo)" - Liste tous les achats simulés
class MyPurchasesPage extends StatefulWidget {
  const MyPurchasesPage({super.key});

  @override
  State<MyPurchasesPage> createState() => _MyPurchasesPageState();
}

class _MyPurchasesPageState extends State<MyPurchasesPage> {
  final _purchaseNotifier = DemoPurchaseNotifier();
  final _subscriptionNotifier = SubscriptionNotifier();

  @override
  void initState() {
    super.initState();
    _purchaseNotifier.addListener(_onPurchasesChanged);
    _subscriptionNotifier.addListener(_onPurchasesChanged);
  }

  @override
  void dispose() {
    _purchaseNotifier.removeListener(_onPurchasesChanged);
    _subscriptionNotifier.removeListener(_onPurchasesChanged);
    super.dispose();
  }

  void _onPurchasesChanged() {
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2)} €';
  }

  IconData _getPurchaseIcon(PurchaseType type) {
    switch (type) {
      case PurchaseType.premium:
        return Icons.workspace_premium;
      case PurchaseType.businessPack:
        return Icons.store_mall_directory_outlined;
      case PurchaseType.videoPack:
        return Icons.video_library_outlined;
      case PurchaseType.coachProgram:
        return Icons.fitness_center;
      case PurchaseType.coachVocalIA:
        return Icons.mic_rounded;
    }
  }

  Color _getPurchaseColor(PurchaseType type) {
    switch (type) {
      case PurchaseType.premium:
        return const Color(0xFF111111);
      case PurchaseType.businessPack:
        return const Color(0xFFFFC300);
      case PurchaseType.videoPack:
        return Colors.blue;
      case PurchaseType.coachProgram:
        return const Color(0xFFFFC300);
      case PurchaseType.coachVocalIA:
        return const Color(0xFFFFC300);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchases = _purchaseNotifier.purchaseHistory;
    final hasPremium = _purchaseNotifier.hasPremium;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Mes achats Ukan (démo)'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Color(0xFF111111),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode démo – paiements simulés',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tous les achats affichés ici sont simulés pour la démonstration. Aucune transaction réelle n\'a été effectuée.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Liste des achats
            Expanded(
              child: purchases.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun achat pour l\'instant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tes achats simulés apparaîtront ici',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = purchases[index];
                        final iconColor = _getPurchaseColor(purchase.type);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: purchase.isActive
                                ? Border.all(
                                    color: iconColor.withOpacity(0.3),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Icône
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getPurchaseIcon(purchase.type),
                                  color: iconColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Informations
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            purchase.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: purchase.isActive
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        if (purchase.isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Actif',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatPrice(purchase.price)} • ${_formatDate(purchase.purchaseDate)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Prix
                              Text(
                                _formatPrice(purchase.price),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: purchase.isActive
                                      ? Colors.black87
                                      : Colors.grey.shade400,
                                ),
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




