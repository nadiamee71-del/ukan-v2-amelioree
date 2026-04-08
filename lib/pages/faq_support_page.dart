import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../alter_ego_floating/alter_ego_floating_widget.dart';
import '../alter_ego_floating/alter_ego_page_detector.dart';

// Palette moderne et immersive
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryPurple = Color(0xFFA855F7);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);

class FaqSupportPage extends StatefulWidget {
  const FaqSupportPage({super.key});

  @override
  State<FaqSupportPage> createState() => _FaqSupportPageState();
}

class _FaqSupportPageState extends State<FaqSupportPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  String _selectedSubject = 'Problème technique';
  String? _selectedImagePath;
  String _searchQuery = '';
  int? _expandedCategoryIndex;

  final ImagePicker _imagePicker = ImagePicker();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: _primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_circle, color: _primaryGreen, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Envoyé !', style: TextStyle(color: _textLight)),
            ],
          ),
          content: const Text(
            'Votre demande a été transmise à l\'équipe Ukan. Nous vous répondrons rapidement !',
            style: TextStyle(color: _textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _nameController.clear();
                _emailController.clear();
                _messageController.clear();
                setState(() => _selectedImagePath = null);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_primaryGreen, _primaryGreen.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@ukan.app',
      query: 'subject=Demande d\'aide Ukan',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      // Silently fail
    }
  }

  List<_FaqCategory> get _faqCategories => [
    _FaqCategory(
      title: 'Compte & Connexion',
      icon: Icons.person_outline,
      color: _primaryBlue,
      questions: [
        _FaqQuestion('Je n\'arrive plus à me connecter', 'Vérifiez que votre email et mot de passe sont corrects. Si le problème persiste, utilisez "Mot de passe oublié" ou contactez le support.'),
        _FaqQuestion('Je veux supprimer mon compte', 'Allez dans Paramètres > Mon profil > Supprimer mon compte. Cette action est irréversible.'),
        _FaqQuestion('Je veux changer mon email', 'Allez dans Paramètres > Mon profil > Modifier l\'email. Un email de confirmation sera envoyé.'),
        _FaqQuestion('Problème avec mon mot de passe', 'Utilisez "Mot de passe oublié" sur l\'écran de connexion pour recevoir un lien de réinitialisation.'),
      ],
    ),
    _FaqCategory(
      title: 'Paiements & Abonnement',
      icon: Icons.credit_card,
      color: _primaryGold,
      questions: [
        _FaqQuestion('Comment fonctionne l\'abonnement Premium ?', 'L\'abonnement Premium donne accès à toutes les fonctionnalités avancées. Il se renouvelle automatiquement chaque mois.'),
        _FaqQuestion('Je vois un paiement que je ne comprends pas', 'Vérifiez vos achats dans Espace Avancé > Mes achats. Contactez le support avec le numéro de transaction si besoin.'),
        _FaqQuestion('Comment changer ma carte bancaire ?', 'Allez dans Espace Avancé > Abonnements > Gérer l\'abonnement pour modifier votre moyen de paiement.'),
        _FaqQuestion('Comment annuler mon abonnement ?', 'Allez dans Espace Avancé > Abonnements > Annuler. L\'annulation prend effet à la fin de la période payée.'),
      ],
    ),
    _FaqCategory(
      title: 'Coachs & Séances Visio',
      icon: Icons.videocam_outlined,
      color: _primaryPurple,
      questions: [
        _FaqQuestion('Comment réserver une séance ?', 'Allez dans l\'onglet Coachs, choisissez un coach et sélectionnez "Réserver une séance".'),
        _FaqQuestion('Comment annuler une séance ?', 'Allez dans Mes séances, sélectionnez la séance et cliquez sur "Annuler" (jusqu\'à 24h avant).'),
        _FaqQuestion('Comment rejoindre une séance en visio ?', 'Vous recevrez un lien par email quelques minutes avant. Cliquez dessus pour rejoindre.'),
      ],
    ),
    _FaqCategory(
      title: 'Nutrition & Recettes',
      icon: Icons.restaurant_outlined,
      color: _primaryGreen,
      questions: [
        _FaqQuestion('Comment ajouter un repas ?', 'Allez dans Nutrition, cliquez sur "+" et remplissez les informations du repas.'),
        _FaqQuestion('Comment ajouter une recette ?', 'Allez dans Recettes & Communauté > Ajouter une recette et suivez les étapes.'),
        _FaqQuestion('Comment enregistrer les calories ?', 'Les calories sont automatiquement enregistrées quand vous ajoutez un repas.'),
      ],
    ),
    _FaqCategory(
      title: 'Santé & Blessures',
      icon: Icons.health_and_safety_outlined,
      color: _primaryRed,
      questions: [
        _FaqQuestion('Où ajouter mon groupe sanguin ?', 'Allez dans Santé & Blessures > Carnet Santé pour ajouter vos informations médicales.'),
        _FaqQuestion('Comment enregistrer une blessure ?', 'Allez dans Santé & Blessures > Blessures > Ajouter une blessure.'),
        _FaqQuestion('Comment ajouter un document médical ?', 'Dans Santé & Blessures > Documents, cliquez sur "Ajouter un document".'),
      ],
    ),
    _FaqCategory(
      title: 'Rooms & Entraînements',
      icon: Icons.groups_outlined,
      color: _primaryOrange,
      questions: [
        _FaqQuestion('Comment créer une room ?', 'Allez dans Visio Training > Créer une room et invitez vos amis avec le code.'),
        _FaqQuestion('Comment rejoindre une room ?', 'Entrez le code de la room dans Visio Training > Rejoindre une room.'),
        _FaqQuestion('Comment mettre en pause une séance ?', 'Pendant une séance, cliquez sur le bouton Pause en bas de l\'écran.'),
      ],
    ),
    _FaqCategory(
      title: 'Alter Ego & IA',
      icon: Icons.psychology_outlined,
      color: _primaryBlue,
      questions: [
        _FaqQuestion('Qu\'est-ce que l\'Alter Ego ?', 'L\'Alter Ego est votre coach virtuel intelligent qui vous guide et répond à vos questions.'),
        _FaqQuestion('Comment utiliser l\'Alter Ego ?', 'Cliquez sur la bulle de pensée en haut à droite pour ouvrir le chat avec votre Alter Ego.'),
        _FaqQuestion('L\'Alter Ego est-il disponible partout ?', 'Oui, il s\'adapte automatiquement au contexte de chaque page.'),
      ],
    ),
    _FaqCategory(
      title: 'Données personnelles',
      icon: Icons.security_outlined,
      color: _primaryPurple,
      questions: [
        _FaqQuestion('Comment exporter mes données ?', 'Allez dans Paramètres > Données personnelles > Exporter mes données.'),
        _FaqQuestion('Comment supprimer mes données ?', 'La suppression du compte entraîne la suppression de toutes vos données.'),
        _FaqQuestion('Mes données sont-elles sécurisées ?', 'Oui, toutes vos données sont chiffrées et nous respectons le RGPD.'),
      ],
    ),
  ];

  List<_FaqCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _faqCategories;
    
    return _faqCategories.map((category) {
      final filteredQuestions = category.questions.where((q) =>
        q.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        q.answer.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
      
      return _FaqCategory(
        title: category.title,
        icon: category.icon,
        color: category.color,
        questions: filteredQuestions,
      );
    }).where((c) => c.questions.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    AlterEgoPageDetector.setupPageContext(UkanPage.faqSupport);

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Fond avec gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _primaryGold.withOpacity(0.1),
                  _darkBg,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar moderne
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: _darkBg,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _textLight),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primaryGold, _primaryGold.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryGold.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.help_outline, color: Colors.black, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'FAQ & Support',
                                style: TextStyle(
                                  color: _textLight,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Comment pouvons-nous t\'aider ?',
                                style: TextStyle(color: _textMuted, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // TabBar
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: _primaryGold,
                    indicatorWeight: 3,
                    labelColor: _primaryGold,
                    unselectedLabelColor: _textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.quiz_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('FAQ'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.support_agent, size: 20),
                            SizedBox(width: 8),
                            Text('Support'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFaqTab(),
                    _buildSupportTab(),
                  ],
                ),
              ),
            ],
          ),
          const AlterEgoFloatingWidget(showFloatingButton: true),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    final categories = _filteredCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBgLight),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _textLight),
              decoration: InputDecoration(
                hintText: 'Rechercher une question...',
                hintStyle: TextStyle(color: _textMuted.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: _textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: _textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 20),

          // Catégories FAQ
          if (categories.isEmpty)
            _buildEmptySearch()
          else
            ...categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return _buildFaqCategoryCard(category, index);
            }),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: _textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat',
            style: TextStyle(color: _textMuted, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Essaie avec d\'autres mots-clés',
            style: TextStyle(color: _textMuted.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCategoryCard(_FaqCategory category, int index) {
    final isExpanded = _expandedCategoryIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? category.color.withOpacity(0.5) : _cardBgLight,
        ),
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _expandedCategoryIndex = isExpanded ? null : index;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category.icon, color: category.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: const TextStyle(
                              color: _textLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${category.questions.length} questions',
                            style: TextStyle(color: _textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Questions
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: category.questions.map((q) => _buildQuestionTile(q, category.color)).toList(),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(_FaqQuestion faq, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFaqAnswer(faq, color),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: _cardBgLight, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.help_outline, size: 18, color: _textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  faq.question,
                  style: const TextStyle(color: _textLight, fontSize: 14),
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showFaqAnswer(_FaqQuestion faq, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Question
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.quiz, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    faq.question,
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Réponse
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                faq.answer,
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Bouton fermer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Compris !',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          Row(
            children: [
              Expanded(child: _buildQuickAction(Icons.email, 'Email', _primaryBlue, _openEmail)),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickAction(Icons.chat, 'Chat', _primaryGreen, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Utilise l\'Alter Ego pour discuter !'),
                    backgroundColor: _cardBg,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              })),
            ],
          ),
          const SizedBox(height: 24),

          // Formulaire
          const Text(
            'Envoyer une demande',
            style: TextStyle(
              color: _textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _cardBgLight),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Nom', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(_messageController, 'Message', Icons.message_outlined, maxLines: 4),
                  const SizedBox(height: 16),
                  _buildAttachmentButton(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: _textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: _textLight),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textMuted),
        prefixIcon: Icon(icon, color: _textMuted, size: 20),
        filled: true,
        fillColor: _cardBgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primaryGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primaryRed, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Champ requis';
        }
        if (label == 'Email' && !value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSubject,
      dropdownColor: _cardBgLight,
      style: const TextStyle(color: _textLight),
      decoration: InputDecoration(
        labelText: 'Sujet',
        labelStyle: TextStyle(color: _textMuted),
        prefixIcon: Icon(Icons.category_outlined, color: _textMuted, size: 20),
        filled: true,
        fillColor: _cardBgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Problème technique', child: Text('Problème technique')),
        DropdownMenuItem(value: 'Paiement / abonnement', child: Text('Paiement / abonnement')),
        DropdownMenuItem(value: 'Compte / données', child: Text('Compte / données')),
        DropdownMenuItem(value: 'Coach / séance', child: Text('Coach / séance')),
        DropdownMenuItem(value: 'Nutrition', child: Text('Nutrition')),
        DropdownMenuItem(value: 'Autre', child: Text('Autre')),
      ],
      onChanged: (value) => setState(() => _selectedSubject = value!),
    );
  }

  Widget _buildAttachmentButton() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBgLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedImagePath != null ? _primaryGreen : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _selectedImagePath != null ? Icons.check_circle : Icons.attach_file,
              color: _selectedImagePath != null ? _primaryGreen : _textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedImagePath != null ? 'Image ajoutée' : 'Ajouter une pièce jointe',
                style: TextStyle(
                  color: _selectedImagePath != null ? _primaryGreen : _textMuted,
                ),
              ),
            ),
            if (_selectedImagePath != null)
              IconButton(
                icon: Icon(Icons.close, color: _textMuted, size: 20),
                onPressed: () => setState(() => _selectedImagePath = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryGold, _primaryGold.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _primaryGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _submitForm,
        icon: const Icon(Icons.send, color: Colors.black),
        label: const Text(
          'Envoyer',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _darkBg,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _FaqCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<_FaqQuestion> questions;

  _FaqCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

class _FaqQuestion {
  final String question;
  final String answer;

  _FaqQuestion(this.question, this.answer);
}
