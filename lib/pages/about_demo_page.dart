import 'package:flutter/material.dart';

/// Page "À propos / Version démo" expliquant que c'est une version démo
class AboutDemoPage extends StatelessWidget {
  const AboutDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('À propos'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo ou icône
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 50,
                    color: Color(0xFFFFC300),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Ukan',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Version démo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Texte explicatif
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                      'À propos de cette démo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ceci est une version démo de Ukan, avec données fictives. '
                      'Aucune donnée personnelle n\'est sauvegardée.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _InfoRow(
                      icon: Icons.info_outline,
                      text: 'Toutes les données sont stockées localement en mémoire',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.lock_outline,
                      text: 'Aucune information n\'est envoyée à un serveur',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.refresh,
                      text: 'Les données sont réinitialisées à chaque redémarrage',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.shopping_cart_outlined,
                      text: 'Les paiements sont simulés (aucun vrai paiement)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Section fonctionnalités
              Text(
                'Fonctionnalités en démo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _FeatureDemoCard(
                title: 'Sport Gaming Story™',
                description: 'Gamification avec quêtes, XP et niveaux',
              ),
              const SizedBox(height: 12),
              _FeatureDemoCard(
                title: 'Coach Business Pack™',
                description: 'Outils pour gérer son activité de coach',
              ),
              const SizedBox(height: 12),
              _FeatureDemoCard(
                title: 'Bibliothèque d\'exercices',
                description: 'Packs vidéos et exercices premium',
              ),
              const SizedBox(height: 12),
              _FeatureDemoCard(
                title: 'Suivi nutritionnel',
                description: 'Journal alimentaire et suivi des calories',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFFFC300),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureDemoCard extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureDemoCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFFFFC300),
              size: 20,
            ),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








