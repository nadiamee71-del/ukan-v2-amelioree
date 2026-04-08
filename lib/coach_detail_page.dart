import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'models/coach_directory.dart';
import 'models/coach_reviews.dart';
import 'models/user_profile.dart';
import 'models/coach_content.dart';
import 'pages/create_coach_content_page.dart';
import 'chat_page.dart';
import 'coach_appointment_page.dart';
import 'coach_program_detail_page.dart';
import 'features/appointments/client_booking_view.dart';

/// Page détaillée stylisée du profil du coach avec onglets
class CoachDetailPage extends StatefulWidget {
  final String coachId;

  const CoachDetailPage({
    super.key,
    required this.coachId,
  });

  @override
  State<CoachDetailPage> createState() => _CoachDetailPageState();
}

class _CoachDetailPageState extends State<CoachDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _feedTabController; // Nouveau TabController pour le feed
  late PageController _programsPageController;
  int _currentProgramIndex = 0;
  String? _selectedProgramLevel; // Pour filtrer les programmes par niveau
  bool _isCoachView = false; // Mode coach (démo)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 onglets : Avant/Après et Avis
    _feedTabController = TabController(length: 3, vsync: this); // 3 onglets : Publications, Recettes, Coaching
    _programsPageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedTabController.dispose();
    _programsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final directoryNotifier = CoachDirectoryNotifier();
    final coach = directoryNotifier.getCoachById(widget.coachId);

    // Thème noir/or uniforme
    const Color darkBg = Color(0xFF0D1117);
    const Color cardBg = Color(0xFF161B22);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    
    if (coach == null) {
      return Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: cardBg,
          foregroundColor: textLight,
          title: const Text('Coach'),
        ),
        body: const Center(
          child: Text('Coach non trouvé', style: TextStyle(color: textMuted)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        foregroundColor: textLight,
        elevation: 0,
        title: Row(
          children: [
            // Avatar du coach en haut dans l'AppBar
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF21262D),
                  backgroundImage: coach.photoUrl != null
                      ? AssetImage(coach.photoUrl!)
                      : null,
                  child: coach.photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 20,
                          color: textMuted,
                        )
                      : null,
                ),
                // Badge statut "En direct"
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: coach.isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                coach.name,
                style: const TextStyle(
                  color: textLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _openCameraForContent(context, coach.id),
            icon: const Icon(
              Icons.add_box_outlined,
              color: primaryGold,
              size: 28,
            ),
            tooltip: 'Créer du contenu',
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // Info principales et boutons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(coach),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, coach),
                    const SizedBox(height: 24),
                    _buildExpandableSections(coach),
                    const SizedBox(height: 32),
                    // Feed du coach
                    _buildCoachFeed(coach),
                  ],
                ),
              ),
            ),

            // TabBar fixe - Thème noir/or
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: primaryGold,
                  unselectedLabelColor: textMuted,
                  indicatorColor: primaryGold,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Avant/Après'),
                    Tab(text: 'Avis'),
                  ],
                ),
                cardBg,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBeforeAfterTab(coach),
            _buildReviewsTab(coach),
          ],
        ),
      ),
      floatingActionButton: _isCoachView
          ? FloatingActionButton(
              onPressed: () => _showCreateContentDialog(context, coach),
              backgroundColor: const Color(0xFFFFC300),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  Widget _buildDefaultPhoto(CoachProfile coach) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Icon(
          Icons.person,
          size: 120,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(CoachProfile coach) {
    final reviewsNotifier = CoachReviewsNotifier();
    final averageRating = reviewsNotifier.getAverageRating(coach.id);
    
    // Thème noir/or uniforme
    const Color cardBg = Color(0xFF161B22);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color borderColor = Color(0xFF30363D);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations du coach (sans avatar, il est dans l'AppBar)
          Row(
            children: [
              // Spécialité, localisation, certification (nom supprimé car il est dans l'AppBar)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spécialité
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        coach.specialty,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Localisation
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: textMuted),
                        const SizedBox(width: 4),
                        Text(
                          coach.city,
                          style: const TextStyle(
                            fontSize: 14,
                            color: textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Certification
                    if (coach.isCertified)
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: primaryGold,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Coach Certifié',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textLight,
                            ),
                    ),
                  ],
                ),
                    // Bio "À propos" juste en dessous de la certification (version compacte)
                    const SizedBox(height: 12),
                    Text(
                      coach.bio,
                      style: const TextStyle(
                        fontSize: 13,
                        color: textMuted,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryGold.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: primaryGold,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          averageRating > 0 ? averageRating.toStringAsFixed(1) : coach.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CoachProfile coach) {
    // Thème noir/or uniforme
    const Color cardBg = Color(0xFF161B22);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color borderColor = Color(0xFF30363D);
    
    return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        clientName: coach.name,
                        clientId: coach.id,
                      ),
                    ),
                  );
                },
            icon: const Icon(Icons.message, size: 18),
                label: const Text('Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appel vidéo instantané (à implémenter)'),
                      backgroundColor: Color(0xFFFFC300),
                    ),
                  );
                },
            icon: const Icon(Icons.videocam, size: 18),
            label: const Text('Visio'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textLight,
                  side: BorderSide(color: borderColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClientBookingView(
                    coachId: coach.id,
                    coachName: coach.name,
                    coachPhotoUrl: coach.photoUrl,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: const Text('Réserver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSections(CoachProfile coach) {
    // Thème noir/or uniforme
    const Color cardBg = Color(0xFF161B22);
    const Color primaryGold = Color(0xFFFFC300);
    const Color textLight = Color(0xFFF0F6FC);
    const Color textMuted = Color(0xFF8B949E);
    const Color borderColor = Color(0xFF30363D);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Première ligne : Spécialités et Certifications
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spécialités
            if (coach.detailedSpecialties.isNotEmpty)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    iconColor: primaryGold,
                    collapsedIconColor: textMuted,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fitness_center, color: primaryGold, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Spécialités',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: coach.detailedSpecialties.map((spec) {
    return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC300).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFC300).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                spec,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (coach.detailedSpecialties.isNotEmpty && coach.certifications.isNotEmpty)
              const SizedBox(width: 12),
            // Certifications
            if (coach.certifications.isNotEmpty)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: ExpansionTile(
                    title: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Color(0xFFFFC300), size: 18),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Certifications',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: coach.certifications.map((cert) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFC300).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFFFC300),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cert,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        // Deuxième ligne : Programmes (pleine largeur)
        if (coach.programs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // Titre "Programmes"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
            children: [
                      Icon(Icons.list_alt, color: Color(0xFFFFC300), size: 18),
              SizedBox(width: 8),
              Text(
                        'Programmes',
                style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Swipe horizontal des programmes
                SizedBox(
                  height: 280, // Hauteur fixe pour éviter l'overflow
                  child: PageView.builder(
                    controller: _programsPageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentProgramIndex = index;
                      });
                    },
                    itemCount: coach.programs.length,
                    itemBuilder: (context, index) {
                      final program = coach.programs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFC300).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      program.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFC300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${program.price.toStringAsFixed(0)}€',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                ),
              ),
            ],
          ),
                              const SizedBox(height: 8),
          Text(
                                program.description,
            style: TextStyle(
                                  fontSize: 14,
              color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${program.durationWeeks} semaines',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
            ),
          ),
        ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      program.level,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CoachProgramDetailPage(
                                          program: program,
                                          coachId: coach.id,
                                          coachName: coach.name,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC300),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Choisir ce programme',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Indicateur de page (points)
                if (coach.programs.length > 1)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          coach.programs.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentProgramIndex
                                  ? const Color(0xFFFFC300)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedSpecialties(CoachProfile coach) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fitness_center, color: Color(0xFFFFC300), size: 22),
              SizedBox(width: 8),
              Text(
                'Spécialités',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coach.detailedSpecialties.map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC300).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFC300).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  spec,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCertifications(CoachProfile coach) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFFFFC300), size: 22),
              SizedBox(width: 8),
              Text(
                'Certifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...coach.certifications.map((cert) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFFFFC300),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cert,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Onglet Programmes avec filtres par niveau
  Widget _buildProgramsTab(CoachProfile coach) {
    final levels = ['Tous', 'Débutant', 'Intermédiaire', 'Avancé', 'Tous niveaux'];
    final filteredPrograms = _selectedProgramLevel == null || _selectedProgramLevel == 'Tous'
        ? coach.programs
        : coach.programs.where((p) => p.level == _selectedProgramLevel).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Onglets de niveau
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final isSelected = _selectedProgramLevel == level || 
                    (_selectedProgramLevel == null && level == 'Tous');
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(level),
                    onSelected: (selected) {
                      setState(() {
                        _selectedProgramLevel = selected ? level : null;
                      });
                    },
                    selectedColor: const Color(0xFFFFC300),
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          if (filteredPrograms.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'Aucun programme disponible pour ce niveau',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            ...filteredPrograms.map((program) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFC300).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            program.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${program.price.toStringAsFixed(0)}€',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      program.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade700),
                              const SizedBox(width: 4),
                              Text(
                                '${program.durationWeeks} semaines',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            program.level,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CoachProgramDetailPage(
                                program: program,
                                coachId: coach.id,
                                coachName: coach.name,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC300),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Choisir ce programme',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // Onglet Avant/Après
  Widget _buildBeforeAfterTab(CoachProfile coach) {
    if (coach.beforeAfterPhotos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Aucune transformation disponible',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: coach.beforeAfterPhotos.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Image.asset(
                    coach.beforeAfterPhotos[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.compare_arrows, size: 60, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Avant/Après',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'AVANT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16,
                            color: Colors.white,
                          ),
                          Text(
                            'APRÈS',
                            style: TextStyle(
                              color: const Color(0xFFFFC300),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
        },
      ),
    );
  }

  // Onglet Avis
  Widget _buildReviewsTab(CoachProfile coach) {
    final reviewsNotifier = CoachReviewsNotifier();
    final reviews = reviewsNotifier.getReviewsForCoach(coach.id);
    final userProfileNotifier = UserProfileNotifier();
    final currentUserId = userProfileNotifier.profile.email;
    final hasReviewed = reviewsNotifier.hasClientReviewed(coach.id, currentUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bouton ajouter avis
          if (!hasReviewed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddReviewDialog(coach),
                icon: const Icon(Icons.star_outline),
                label: const Text('Ajouter un avis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          if (!hasReviewed) const SizedBox(height: 24),

          // Liste des avis
          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.star_outline, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun avis pour le moment',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...reviews.map((review) => _ReviewCard(review: review)).toList(),
        ],
      ),
    );
  }

  void _showAddReviewDialog(CoachProfile coach) {
    final ratingController = ValueNotifier<double>(5.0);
    final commentController = TextEditingController();
    final userProfileNotifier = UserProfileNotifier();
    final currentProfile = userProfileNotifier.profile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Ajouter un avis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating avec étoiles
                ValueListenableBuilder<double>(
                  valueListenable: ratingController,
                  builder: (context, rating, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            ratingController.value = (index + 1).toDouble();
                          },
                          child: Icon(
                            index < rating ? Icons.star : Icons.star_outline,
                            color: const Color(0xFFFFC300),
                            size: 40,
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ValueListenableBuilder<double>(
                    valueListenable: ratingController,
                    builder: (context, rating, child) {
                      return Text(
                        '${rating.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Commentaire
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Votre avis',
                    hintText: 'Partagez votre expérience...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez saisir un commentaire'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final reviewsNotifier = CoachReviewsNotifier();
                final currentUserId = currentProfile.email;
                final currentUserName = currentProfile.name;

                final review = CoachReview(
                  id: 'rev_${DateTime.now().microsecondsSinceEpoch}',
                  coachId: coach.id,
                  clientId: currentUserId,
                  clientName: currentUserName,
                  rating: ratingController.value,
                  comment: commentController.text.trim(),
                  createdAt: DateTime.now(),
                  isVerified: false,
                );

                reviewsNotifier.addReview(review);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avis ajouté avec succès !'),
                    backgroundColor: Color(0xFFFFC300),
                  ),
                );
                
                setState(() {}); // Refresh pour afficher le nouvel avis
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Publier',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────
  /// Widgets pour le feed du coach
  /// ─────────────────────────────────────────────

  /// Construit le feed du coach avec ses 3 onglets
  Widget _buildCoachFeed(CoachProfile coach) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre du feed
        const Text(
          'Feed du coach',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        // TabBar pour les 3 onglets du feed
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _feedTabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFFFFC300),
            indicatorWeight: 3,
            indicator: BoxDecoration(
              color: const Color(0xFFFFC300),
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Publications'),
              Tab(text: 'Recettes'),
              Tab(text: 'Coaching'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Contenu des onglets du feed
        SizedBox(
          height: 600, // Hauteur fixe pour le TabBarView
          child: TabBarView(
            controller: _feedTabController,
            children: [
              _buildPublicationsTab(coach),
              _buildRecipesTab(coach),
              _buildCoachingTab(coach),
            ],
          ),
        ),
      ],
    );
  }

  /// Onglet Publications
  Widget _buildPublicationsTab(CoachProfile coach) {
    final contentNotifier = CoachContentNotifier();
    final posts = contentNotifier.getPosts(coach.id);

    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Aucune publication pour le moment',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(post);
      },
    );
  }

  /// Carte de publication
  Widget _buildPostCard(CoachContent post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (toujours affichée grâce à displayImage)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Image.asset(
                post.displayImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Date
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(post.createdAt),
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
    );
  }

  /// Onglet Recettes
  Widget _buildRecipesTab(CoachProfile coach) {
    final contentNotifier = CoachContentNotifier();
    final recipes = contentNotifier.getRecipes(coach.id);

    if (recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Aucune recette pour le moment',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return _buildRecipeCard(recipes[index]);
      },
    );
  }

  /// Carte de recette
  Widget _buildRecipeCard(CoachContent recipe) {
    return GestureDetector(
      onTap: () => _handleRecipeTap(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Image.asset(
                        recipe.displayImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Badge d'accès
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: recipe.isPaid
                            ? const Color(0xFFFFC300)
                            : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (recipe.isPaid)
                            const Icon(Icons.lock, size: 12, color: Colors.black),
                          if (recipe.isPaid) const SizedBox(width: 4),
                          Text(
                            recipe.isPaid ? 'Premium' : 'Gratuit',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenu
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Tags
                    if (recipe.tags != null && recipe.tags!.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: recipe.tags!.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const Spacer(),
                    // Calories
                    if (recipe.calories != null)
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, size: 12, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.calories} kcal',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  /// Onglet Coaching
  Widget _buildCoachingTab(CoachProfile coach) {
    final contentNotifier = CoachContentNotifier();
    final coachingContents = contentNotifier.getCoachingContents(coach.id);

    if (coachingContents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Aucun contenu de coaching pour le moment',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: coachingContents.length,
      itemBuilder: (context, index) {
        return _buildCoachingCard(coachingContents[index]);
      },
    );
  }

  /// Carte de coaching
  Widget _buildCoachingCard(CoachContent coaching) {
    return GestureDetector(
      onTap: () => _handleCoachingTap(coaching),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade200,
                child: Image.asset(
                  coaching.displayImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            coaching.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (coaching.isPaid)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Catégorie et niveau
                    Row(
                      children: [
                        if (coaching.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              coaching.category!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (coaching.category != null && coaching.level != null)
                          const SizedBox(width: 8),
                        if (coaching.level != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              coaching.level!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Durée et badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (coaching.duration != null)
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${coaching.duration!.inMinutes} min',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: coaching.isPaid
                                ? const Color(0xFFFFC300).withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            coaching.isPaid ? 'Premium' : 'Gratuit',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: coaching.isPaid ? Colors.black : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
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

  /// Gère le tap sur une recette
  void _handleRecipeTap(CoachContent recipe) {
    if (recipe.isPaid) {
      _showPremiumContentDialog(recipe);
    } else {
      // Afficher les détails de la recette (démo)
      _showRecipeDetails(recipe);
    }
  }

  /// Gère le tap sur un contenu de coaching
  void _handleCoachingTap(CoachContent coaching) {
    if (coaching.isPaid) {
      _showPremiumContentDialog(coaching);
    } else {
      // Afficher les détails du coaching (démo)
      _showCoachingDetails(coaching);
    }
  }

  /// Affiche la dialog pour le contenu premium
  void _showPremiumContentDialog(CoachContent content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFFFFC300)),
            const SizedBox(width: 8),
            const Text('Contenu réservé'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ce contenu est réservé aux abonnés ou disponible en achat unique.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Color(0xFFFFC300)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      content.accessBadge,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '(Mode démo - Aucun paiement réel)',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Ici, on pourrait ouvrir la page d'abonnement ou d'achat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC300),
              foregroundColor: Colors.black,
            ),
            child: const Text('Voir les options'),
          ),
        ],
      ),
    );
  }

  /// Affiche les détails d'une recette (démo)
  void _showRecipeDetails(CoachContent recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.imagePath != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      recipe.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.restaurant, size: 60, color: Colors.grey.shade400),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(recipe.description),
              if (recipe.calories != null) ...[
                const SizedBox(height: 16),
                Text('Calories: ${recipe.calories} kcal'),
              ],
              if (recipe.macros != null) ...[
                const SizedBox(height: 8),
                Text('Protéines: ${recipe.macros!['proteins']?.toStringAsFixed(1)}g'),
                Text('Glucides: ${recipe.macros!['carbs']?.toStringAsFixed(1)}g'),
                Text('Lipides: ${recipe.macros!['fats']?.toStringAsFixed(1)}g'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Affiche les détails d'un contenu de coaching (démo)
  void _showCoachingDetails(CoachContent coaching) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(coaching.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coaching.imagePath != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      coaching.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.fitness_center, size: 60, color: Colors.grey.shade400),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(coaching.description),
              if (coaching.duration != null) ...[
                const SizedBox(height: 16),
                Text('Durée: ${coaching.duration!.inMinutes} minutes'),
              ],
              if (coaching.category != null) ...[
                const SizedBox(height: 8),
                Text('Catégorie: ${coaching.category}'),
              ],
              if (coaching.level != null) ...[
                const SizedBox(height: 8),
                Text('Niveau: ${coaching.level}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Ici, on pourrait lancer la vidéo
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC300),
              foregroundColor: Colors.black,
            ),
            child: const Text('Lancer la séance'),
          ),
        ],
      ),
    );
  }

  /// Affiche le dialog pour créer un nouveau contenu (mode coach)
  void _showCreateContentDialog(BuildContext context, CoachProfile coach) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un nouveau contenu'),
        content: const Text(
          'Fonctionnalité à venir.\n\nVous pourrez créer des publications, recettes ou contenus de coaching.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a $weeks semaine${weeks > 1 ? 's' : ''}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  Future<void> _openCameraForContent(BuildContext context, String coachId) async {
    final imagePicker = ImagePicker();
    
    // Afficher un menu pour choisir entre photo, vidéo ou galerie
    final choice = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFFC300)),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, 'camera_photo'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFFFFC300)),
              title: const Text('Prendre une vidéo'),
              onTap: () => Navigator.pop(context, 'camera_video'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFFC300)),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    try {
      if (choice == 'camera_photo') {
        // Ouvrir directement l'appareil photo pour prendre une photo
        final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
        if (image != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateCoachContentPage(
                coachId: coachId,
                initialImage: File(image.path),
              ),
            ),
          );
        }
      } else if (choice == 'camera_video') {
        // Ouvrir directement l'appareil vidéo pour prendre une vidéo
        final XFile? video = await imagePicker.pickVideo(source: ImageSource.camera);
        if (video != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateCoachContentPage(
                coachId: coachId,
                initialVideo: File(video.path),
              ),
            ),
          );
        }
      } else if (choice == 'gallery') {
        // Galerie - proposer image ou vidéo
        final mediaType = await showModalBottomSheet<String?>(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo, color: Color(0xFFFFC300)),
                  title: const Text('Image'),
                  onTap: () => Navigator.pop(context, 'image'),
                ),
                ListTile(
                  leading: const Icon(Icons.video_library, color: Color(0xFFFFC300)),
                  title: const Text('Vidéo'),
                  onTap: () => Navigator.pop(context, 'video'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ),
        );

        if (mediaType == 'image') {
          final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
          if (image != null && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateCoachContentPage(
                  coachId: coachId,
                  initialImage: File(image.path),
                ),
              ),
            );
          }
        } else if (mediaType == 'video') {
          final XFile? video = await imagePicker.pickVideo(source: ImageSource.gallery);
          if (video != null && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateCoachContentPage(
                  coachId: coachId,
                  initialVideo: File(video.path),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Widget pour afficher un avis
class _ReviewCard extends StatelessWidget {
  final CoachReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  review.clientName.isNotEmpty ? review.clientName[0].toUpperCase() : 'C',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            review.clientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (review.isVerified)
                          const Icon(
                            Icons.verified,
                            color: Color(0xFFFFC300),
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_outline,
                            color: const Color(0xFFFFC300),
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(review.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a $weeks semaine${weeks > 1 ? 's' : ''}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}

// Delegate pour le TabBar fixe
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;

  _SliverAppBarDelegate(this._tabBar, [this._backgroundColor = const Color(0xFF161B22)]);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
