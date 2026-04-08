import 'package:flutter/material.dart';

import '../../pages/parrainage_page.dart';

/// Header du Dashboard - Rangée de bulle uniquement (alignée avec StoriesHeaderRow)
class WeeklyChallengeHeader extends StatelessWidget {
  const WeeklyChallengeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const Color marronPrincipal = Color(0xFF5D4037);
    
    // Rangée de bulle alignée EXACTEMENT comme StoriesHeaderRow
    return SizedBox(
      height: 110,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bulle kangourou - même style que bulle "+" de Publications
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ParrainagePage()),
              ),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC93C), Color(0xFFFF9F1C)],
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/fitpro_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.card_giftcard,
                            color: Color(0xFFFFC300),
                            size: 28,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Texte "Parrainer & Gagner" à droite de la bulle
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ParrainagePage()),
              ),
              child: Text(
                'Parrainer & Gagner',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: marronPrincipal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
