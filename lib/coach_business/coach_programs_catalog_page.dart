import 'package:flutter/material.dart';

// Couleurs professionnelles : Marron et Gris clair pour Coach Business
const Color _marronPrincipalBusiness = Color(0xFF8D6E63); // Material Brown 400
const Color _marronFonceBusiness = Color(0xFF5D4037); // Material Brown 700
const Color _marronClairBusiness = Color(0xFFA1887F); // Material Brown 300
const Color _grisClairBusiness = Color(0xFFE0E0E0); // Material Grey 300
const Color _grisPrincipalBusiness = Color(0xFF9E9E9E); // Material Grey 500
const Color _grisFonceBusiness = Color(0xFF616161); // Material Grey 700

/// Modèle pour un programme de coach
class CoachProgram {
  final String id;
  final String coachName;
  final String coachSpecialty;
  final String title;
  final String objective;
  final String level;
  final int durationWeeks;
  final String format;
  final double price;
  final String description;
  final List<String> weeks;
  final String? equipment;

  const CoachProgram({
    required this.id,
    required this.coachName,
    required this.coachSpecialty,
    required this.title,
    required this.objective,
    required this.level,
    required this.durationWeeks,
    required this.format,
    required this.price,
    required this.description,
    required this.weeks,
    this.equipment,
  });
}

/// Page catalogue de programmes par coach (mode démo)
class CoachProgramsCatalogPage extends StatefulWidget {
  const CoachProgramsCatalogPage({super.key});

  @override
  State<CoachProgramsCatalogPage> createState() => _CoachProgramsCatalogPageState();
}

class _CoachProgramsCatalogPageState extends State<CoachProgramsCatalogPage> {
  // Programmes statiques pour la démo
  final List<CoachProgram> _allPrograms = [
    const CoachProgram(
      id: 'sarah_mass_8',
      coachName: 'Sarah Lopez',
      coachSpecialty: 'Prise de masse',
      title: 'Pack Prise de masse 8 semaines',
      objective: 'Prise de masse',
      level: 'Intermédiaire',
      durationWeeks: 8,
      format: '4 séances/semaine',
      price: 59.90,
      description: 'Programme complet pour gagner en masse musculaire avec suivi nutritionnel personnalisé.',
      weeks: ['Semaine 1 : Fondations', 'Semaine 2-3 : Intensification', 'Semaine 4-6 : Volume', 'Semaine 7-8 : Pic'],
      equipment: 'Matériel de base (barre, poids, banc)',
    ),
    const CoachProgram(
      id: 'sarah_home',
      coachName: 'Sarah Lopez',
      coachSpecialty: 'Prise de masse',
      title: 'Musculation à la maison – sans matériel',
      objective: 'Prise de masse',
      level: 'Débutant',
      durationWeeks: 6,
      format: '3 séances/semaine',
      price: 39.90,
      description: 'Programme de musculation au poids du corps pour gagner en masse sans matériel.',
      weeks: ['Semaine 1-2 : Base', 'Semaine 3-4 : Progression', 'Semaine 5-6 : Intensification'],
      equipment: 'Aucun matériel nécessaire',
    ),
    const CoachProgram(
      id: 'karim_crossfit_4',
      coachName: 'Karim Ben',
      coachSpecialty: 'CrossFit',
      title: 'CrossFit Débutant – 4 semaines',
      objective: 'Endurance, Force',
      level: 'Débutant',
      durationWeeks: 4,
      format: '5 séances/semaine',
      price: 34.90,
      description: 'Introduction au CrossFit avec WOD adaptés pour débutants.',
      weeks: ['Semaine 1 : Découverte', 'Semaine 2 : Fondations', 'Semaine 3 : Intensité modérée', 'Semaine 4 : Autonomie'],
      equipment: 'Matériel CrossFit de base',
    ),
    const CoachProgram(
      id: 'karim_wod_6',
      coachName: 'Karim Ben',
      coachSpecialty: 'CrossFit',
      title: 'WOD Intenses – 6 semaines',
      objective: 'Endurance, Force',
      level: 'Avancé',
      durationWeeks: 6,
      format: '5 séances/semaine',
      price: 49.90,
      description: 'WOD intensifs pour athlètes expérimentés souhaitant repousser leurs limites.',
      weeks: ['Semaine 1-2 : Conditionnement', 'Semaine 3-4 : Intensité max', 'Semaine 5-6 : Performance'],
      equipment: 'Matériel CrossFit complet',
    ),
    const CoachProgram(
      id: 'emma_postpartum',
      coachName: 'Emma Dubois',
      coachSpecialty: 'Post-partum',
      title: 'Reprise en douceur post-partum',
      objective: 'Remise en forme',
      level: 'Débutant',
      durationWeeks: 8,
      format: '3 séances/semaine',
      price: 44.90,
      description: 'Programme adapté pour les jeunes mamans, avec exercices doux et progressifs.',
      weeks: ['Semaine 1-2 : Réveil musculaire', 'Semaine 3-4 : Renforcement core', 'Semaine 5-6 : Cardio doux', 'Semaine 7-8 : Retour progressif'],
      equipment: 'Yoga mat, élastiques légers',
    ),
    const CoachProgram(
      id: 'emma_core',
      coachName: 'Emma Dubois',
      coachSpecialty: 'Post-partum',
      title: 'Core & posture jeune maman',
      objective: 'Renforcement',
      level: 'Débutant',
      durationWeeks: 6,
      format: '4 séances/semaine',
      price: 29.90,
      description: 'Focus sur le renforcement du core et l\'amélioration de la posture après la grossesse.',
      weeks: ['Semaine 1-2 : Base', 'Semaine 3-4 : Progression', 'Semaine 5-6 : Autonomie'],
      equipment: 'Yoga mat',
    ),
    const CoachProgram(
      id: 'alex_weight_loss',
      coachName: 'Alex Martin',
      coachSpecialty: 'Perte de poids',
      title: 'Perte de poids progressive – 12 semaines',
      objective: 'Perte de poids',
      level: 'Intermédiaire',
      durationWeeks: 12,
      format: '4 séances/semaine',
      price: 69.90,
      description: 'Programme complet sur 12 semaines avec plan nutritionnel et entraînements progressifs.',
      weeks: ['Semaine 1-3 : Fondations', 'Semaine 4-6 : Intensification', 'Semaine 7-9 : Optimisation', 'Semaine 10-12 : Consolidation'],
      equipment: 'Matériel de base',
    ),
    const CoachProgram(
      id: 'alex_walking',
      coachName: 'Alex Martin',
      coachSpecialty: 'Perte de poids',
      title: 'Marche active & cardio doux',
      objective: 'Perte de poids',
      level: 'Débutant',
      durationWeeks: 8,
      format: '5 séances/semaine',
      price: 24.90,
      description: 'Programme accessible pour débuter la perte de poids avec marche active et cardio doux.',
      weeks: ['Semaine 1-2 : Initiation', 'Semaine 3-4 : Progression', 'Semaine 5-6 : Intensification', 'Semaine 7-8 : Autonomie'],
      equipment: 'Chaussures de marche',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Grouper par coach
    final coachesMap = <String, List<CoachProgram>>{};
    for (var program in _allPrograms) {
      final key = '${program.coachName} - ${program.coachSpecialty}';
      coachesMap.putIfAbsent(key, () => []).add(program);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: _marronFonceBusiness,
        foregroundColor: Colors.white,
        title: const Text('Programmes Coach (démo)'),
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
                      'Exemples de programmes vendables par coach – données fictives.',
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
            ...coachesMap.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...entry.value.map((program) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProgramCard(
                              program: program,
                              onTap: () {
                                _showProgramDetail(program);
                              },
                            ),
                          )),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showProgramDetail(CoachProgram program) {
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
                          Text(
                            program.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Par ${program.coachName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _grisClairBusiness,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _grisPrincipalBusiness),
                          ),
                          child: Text(
                            '${program.price.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: _grisFonceBusiness,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Mode démo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Infos du programme
                    _DetailRow(label: 'Objectif', value: program.objective),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Niveau', value: program.level),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Durée', value: '${program.durationWeeks} semaines'),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Format', value: program.format),
                    const SizedBox(height: 24),
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
                      program.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Contenu
                    const Text(
                      'Contenu du programme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...program.weeks.map((week) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _grisClairBusiness,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.check, size: 16, color: _grisFonceBusiness),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  week,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (program.equipment != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Matériel nécessaire',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.fitness_center, color: Colors.grey.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                program.equipment!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // Bouton ajouter à la vitrine
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Programme "${program.title}" ajouté à ta vitrine (mode démo)'),
                              backgroundColor: _marronPrincipalBusiness,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        label: const Text(
                          'Ajouter à ma vitrine (démo)',
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

class _ProgramCard extends StatelessWidget {
  final CoachProgram program;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.program,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Par ${program.coachName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _grisClairBusiness,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${program.price.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _grisFonceBusiness,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Badge(text: program.objective, color: _marronPrincipalBusiness),
                const SizedBox(width: 8),
                _Badge(text: program.level, color: _grisPrincipalBusiness),
                const SizedBox(width: 8),
                _Badge(text: '${program.durationWeeks} sem.', color: _marronClairBusiness),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              program.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Format : ${program.format}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

