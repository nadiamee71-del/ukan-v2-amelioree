import 'package:flutter/material.dart';
import '../models/demo_purchase.dart';
import '../models/subscription.dart';

/// Page de paiement simulé pour la démo
/// Aucun vrai paiement n'est effectué, tout est simulé localement
class DemoPaymentPage extends StatefulWidget {
  final PurchaseType purchaseType;
  final String itemTitle;
  final double price;
  final VoidCallback? onPaymentSuccess;

  const DemoPaymentPage({
    super.key,
    required this.purchaseType,
    required this.itemTitle,
    required this.price,
    this.onPaymentSuccess,
  });

  @override
  State<DemoPaymentPage> createState() => _DemoPaymentPageState();
}

class _DemoPaymentPageState extends State<DemoPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController(text: '4532 1234 5678 9010');
  final _expiryController = TextEditingController(text: '12/25');
  final _cvcController = TextEditingController(text: '123');
  final _cardholderController = TextEditingController(text: 'NOM PRÉNOM (démo)');

  @override
  void initState() {
    super.initState();
    // Désactiver les champs pour indiquer qu'ils sont factices
    _cardNumberController.addListener(() {});
    _expiryController.addListener(() {});
    _cvcController.addListener(() {});
    _cardholderController.addListener(() {});
  }

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Simuler un délai de traitement du paiement
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    // Enregistrer l'achat simulé
    final purchaseNotifier = DemoPurchaseNotifier();
    
    switch (widget.purchaseType) {
      case PurchaseType.premium:
        purchaseNotifier.purchasePremium();
        // Synchroniser avec SubscriptionNotifier pour cohérence
        SubscriptionNotifier().activatePremiumDemo();
        break;
      case PurchaseType.businessPack:
        purchaseNotifier.purchaseBusinessPack();
        break;
      case PurchaseType.videoPack:
        purchaseNotifier.purchaseVideoPack(widget.itemTitle, widget.price);
        break;
      case PurchaseType.coachProgram:
        // L'achat de programme coach se fait depuis CoachProgramDetailPage
        // Cette page est utilisée pour les autres types d'achats
        break;
      case PurchaseType.coachVocalIA:
        purchaseNotifier.purchaseCoachVocalIA();
        break;
    }

    // Callback de succès
    if (widget.onPaymentSuccess != null) {
      widget.onPaymentSuccess!();
    }

    // Afficher écran de succès
    if (mounted) {
      _showSuccessDialog();
    }
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2)} €';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF111111),
                Colors.grey.shade900,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône de succès
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC300),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC300).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF111111),
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pack activé en démo ✅',
                style: TextStyle(
                  color: Color(0xFFFFC300),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.purchaseType == PurchaseType.businessPack
                    ? 'Coach Business Pack™ est maintenant débloqué en mode démonstration.\n\nExplore tes programmes, tes analytics, tes clients et la boutique accessoires.'
                    : 'Tu as débloqué ce contenu en mode démonstration.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (widget.purchaseType == PurchaseType.businessPack) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // Fermer le dialog
                      Navigator.of(context).pop(true); // Retourner au hub
                      if (widget.onPaymentSuccess != null) {
                        widget.onPaymentSuccess!();
                      }
                    },
                    icon: const Icon(Icons.store_mall_directory_outlined),
                    label: const Text('Voir le pack'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: const Color(0xFF111111),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialog
                    Navigator.of(context).pop(true); // Retourner à l'accueil
                    if (widget.onPaymentSuccess != null) {
                      widget.onPaymentSuccess!();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Retour à l\'accueil'),
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
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Paiement (démo)'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bandeau Mode démo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4CC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFC300),
                    width: 1.5,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 22,
                      color: Color(0xFF111111),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mode démo – paiement simulé (aucune transaction réelle).',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Carte récap améliorée
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.itemTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Licence démo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatPrice(widget.price),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.purchaseType == PurchaseType.businessPack
                            ? 'Tu es sur le point de débloquer toutes les fonctionnalités business en mode démo.'
                            : 'Tu es sur le point de débloquer ce contenu en mode démo.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Formulaire de paiement
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Numéro de carte (factice, prérempli)
                    _LabeledField(
                      label: 'Numéro de carte',
                      child: TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                        decoration: _inputDecoration('4532 1234 5678 9010').copyWith(
                          fillColor: Colors.grey.shade100,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Entre le numéro de carte';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date d'expiration et CVC (factices, préremplis)
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Date d\'expiration',
                            child: TextFormField(
                              controller: _expiryController,
                              keyboardType: TextInputType.text,
                              readOnly: true,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                              decoration: _inputDecoration('12/25').copyWith(
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entre la date';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'CVC',
                            child: TextFormField(
                              controller: _cvcController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              readOnly: true,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                              decoration: _inputDecoration('123').copyWith(
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entre le CVC';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nom sur la carte (factice, prérempli)
                    _LabeledField(
                      label: 'Nom sur la carte',
                      child: TextFormField(
                        controller: _cardholderController,
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                        decoration: _inputDecoration('NOM PRÉNOM (démo)').copyWith(
                          fillColor: Colors.grey.shade100,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Entre le nom';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Note sur les informations factices
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ces informations sont fictives – aucune transaction réelle ne sera effectuée.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton de paiement
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Payer maintenant (mode démo) – ${_formatPrice(widget.price)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Note de sécurité
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ce paiement est simulé pour la démo. Aucune transaction réelle ne sera effectuée.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF4F4F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF111111),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

