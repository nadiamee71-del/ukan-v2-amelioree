import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParrainageReward {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color color;

  const ParrainageReward({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });
}

class ParrainagePage extends StatefulWidget {
  const ParrainagePage({super.key});

  @override
  State<ParrainagePage> createState() => _ParrainagePageState();
}

class _ParrainagePageState extends State<ParrainagePage> {
  int _parrainageCount = 0;
  bool _surpriseUnlocked = false;

  @override
  void initState() {
    super.initState();
    _loadParrainageCount();
  }

  Future<void> _loadParrainageCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('parrainage_count') ?? 0;
      final surpriseUnlocked = prefs.getBool('surprise_reward_unlocked') ?? false;
      setState(() {
        _parrainageCount = count;
        _surpriseUnlocked = surpriseUnlocked;
      });
    } catch (e) {
      debugPrint('Erreur chargement parrainage: $e');
    }
  }

  Future<void> _incrementParrainageCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newCount = _parrainageCount + 1;
      await prefs.setInt('parrainage_count', newCount);
      
      // Débloquer la récompense surprise après 3 parrainages
      if (newCount >= 3 && !_surpriseUnlocked) {
        await prefs.setBool('surprise_reward_unlocked', true);
        setState(() {
          _surpriseUnlocked = true;
        });
      }
      
      setState(() {
        _parrainageCount = newCount;
      });
    } catch (e) {
      debugPrint('Erreur sauvegarde parrainage: $e');
    }
  }

  List<ParrainageReward> _getRewardsForType(String type) {
    final List<ParrainageReward> rewards = [
      const ParrainageReward(
        id: 'premium_1mois',
        title: '1 mois Premium gratuit',
        description: 'Accès à toutes les fonctionnalités Premium',
        emoji: '⭐',
        color: Color(0xFFFFC300),
      ),
      const ParrainageReward(
        id: 'module_coach_vocal',
        title: 'Coach Vocal IA',
        description: 'Accès au module de coaching vocal personnalisé',
        emoji: '🎤',
        color: Color(0xFF2196F3),
      ),
      const ParrainageReward(
        id: 'module_transformation',
        title: 'Transformation Projection™',
        description: 'Visualise ta transformation future',
        emoji: '🔮',
        color: Color(0xFF9C27B0),
      ),
    ];
    
    if (_surpriseUnlocked) {
      rewards.add(
        const ParrainageReward(
          id: 'recompense_surprise',
          title: '🎁 Récompense Surprise',
          description: 'Débloquée après plusieurs parrainages !',
          emoji: '🎁',
          color: Color(0xFFFF6B6B),
        ),
      );
    }
    
    switch (type) {
      case 'Ami':
        return rewards;
      case 'Coach':
        return const [
          ParrainageReward(
            id: 'premium_3mois',
            title: '3 mois Premium gratuit',
            description: 'Accès Premium prolongé pour toi et ton coach',
            emoji: '⭐',
            color: Color(0xFFFFC300),
          ),
          ParrainageReward(
            id: 'module_business',
            title: 'Coach Business Pack™',
            description: 'Module complet pour vendre tes programmes',
            emoji: '💼',
            color: Color(0xFF4CAF50),
          ),
          ParrainageReward(
            id: 'coaching_personnalise',
            title: 'Séances personnalisées',
            description: '5 séances personnalisées avec ton coach',
            emoji: '🎯',
            color: Color(0xFF2196F3),
          ),
        ];
      case 'Salle':
        return const [
          ParrainageReward(
            id: 'premium_6mois',
            title: '6 mois Premium gratuit',
            description: 'Accès Premium longue durée',
            emoji: '⭐',
            color: Color(0xFFFFC300),
          ),
          ParrainageReward(
            id: 'acces_salle_illimite',
            title: 'Accès salle illimité',
            description: 'Accès à toutes les salles partenaires',
            emoji: '🏋️',
            color: Color(0xFF4CAF50),
          ),
          ParrainageReward(
            id: 'programme_exclusif',
            title: 'Programme exclusif',
            description: 'Programme d\'entraînement exclusif Ukan',
            emoji: '📋',
            color: Color(0xFF9C27B0),
          ),
        ];
      default:
        return [];
    }
  }

  void _showRewardSelection(BuildContext context, String type) {
    final rewards = _getRewardsForType(type);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RewardSelectionModal(
        type: type,
        rewards: rewards,
        onRewardSelected: (reward) {
          Navigator.of(context).pop();
          _handleParrainageConfirmed(context, type, reward);
        },
      ),
    );
  }

  Future<void> _handleParrainageConfirmed(
    BuildContext context,
    String type,
    ParrainageReward reward,
  ) async {
    debugPrint('Parrainage confirmé: $type - Récompense: ${reward.id}');
    
    // Incrémenter le compteur de parrainages
    await _incrementParrainageCount();
    
    // Récupérer le nouveau compteur après incrémentation
    final newCount = _parrainageCount;
    
    // Vérifier si la récompense surprise vient d'être débloquée
    final isSurprise = reward.id == 'recompense_surprise';
    final message = isSurprise
        ? '🎁 Récompense Surprise débloquée ! Félicitations pour tes $newCount parrainages !'
        : '🎉 ${reward.emoji} ${reward.title} débloqué !';
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSurprise
              ? const Color(0xFFFF6B6B)
              : const Color(0xFFF7D351),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Si c'est la récompense surprise, afficher un dialog spécial
      if (isSurprise) {
        _showSurpriseDialog(context);
      }
    }
  }

  void _showSurpriseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎁',
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(width: 8),
            Text(
              'Récompense Surprise !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Félicitations !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tu as effectué $_parrainageCount parrainages !\n\n'
              'Tu débloques une récompense exclusive :',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC300), Color(0xFFFFD700)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    '⭐',
                    style: TextStyle(fontSize: 40),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Premium à vie',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Accès illimité à toutes les fonctionnalités Premium',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Génial !',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFC300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Parrainage',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFF7D351).withOpacity(0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo mascotte
              Center(
                child: Image.asset(
                  'assets/images/fitpro_logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7D351).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        size: 60,
                        color: Color(0xFFF7D351),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Titre
              const Center(
                child: Text(
                  '👉 Parraine & Gagne !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Phrase d'accroche
              Center(
                child: Text(
                  'Invite un ami, une salle ou un coach et débloque des récompenses Ukan.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Compteur de parrainages
              if (_parrainageCount > 0) ...[
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFC300),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Parrainages effectués: $_parrainageCount${_surpriseUnlocked ? ' ✅' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                if (!_surpriseUnlocked && _parrainageCount >= 2) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Plus que ${3 - _parrainageCount} parrainage${3 - _parrainageCount > 1 ? 's' : ''} pour débloquer la récompense surprise ! 🎁',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 40),
              // Bouton 1: Inviter un Ami
              _buildParrainageCard(
                context: context,
                emoji: '🧍‍♂️',
                title: 'Inviter un Ami',
                description: 'Reçois un bonus en parrainant un nouvel utilisateur.',
                onTap: () => _showRewardSelection(context, 'Ami'),
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 16),
              // Bouton 2: Recommander un Coach
              _buildParrainageCard(
                context: context,
                emoji: '🏋️',
                title: 'Recommander un Coach',
                description: 'Aide un coach à rejoindre Ukan et gagne une option gratuite.',
                onTap: () => _showRewardSelection(context, 'Coach'),
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(height: 16),
              // Bouton 3: Ajouter une Salle de Sport
              _buildParrainageCard(
                context: context,
                emoji: '🏢',
                title: 'Ajouter une Salle de Sport',
                description: 'Ajoute ta salle à Ukan et deviens son parrain officiel.',
                onTap: () => _showRewardSelection(context, 'Salle'),
                color: const Color(0xFFFF9800),
              ),
              const SizedBox(height: 40),
              // Conditions de parrainage
              _buildConditionsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              const Text(
                'Conditions de parrainage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildConditionItem(
            '• Le parrainé doit créer un compte Ukan valide',
          ),
          const SizedBox(height: 8),
          _buildConditionItem(
            '• Le parrainé doit compléter son profil (informations personnelles)',
          ),
          const SizedBox(height: 8),
          _buildConditionItem(
            '• La récompense est attribuée uniquement après validation du parrainage',
          ),
          const SizedBox(height: 8),
          _buildConditionItem(
            '• Un utilisateur ne peut être parrainé qu\'une seule fois',
          ),
          const SizedBox(height: 8),
          _buildConditionItem(
            '• Les récompenses sont cumulables (plusieurs parrainages = plusieurs récompenses)',
          ),
          const SizedBox(height: 8),
          _buildConditionItem(
            '• La récompense surprise se débloque après 3 parrainages validés',
          ),
          const SizedBox(height: 8),
          _buildConditionItem(
            '• Les récompenses Premium sont valables pour un compte existant uniquement',
          ),
          const SizedBox(height: 8),
          _buildConditionItem(
            '• La récompense n\'est attribuée qu\'après le premier prélèvement bancaire du parrainé',
          ),
          const SizedBox(height: 8),
          _buildConditionItem(
            '• Le parrainé doit rester inscrit et actif pendant au moins 3 mois pour valider le parrainage',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC300).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'En cas de fraude ou d\'abus détecté, Ukan se réserve le droit d\'annuler les récompenses attribuées.',
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
    );
  }

  Widget _buildConditionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParrainageCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
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
            // Emoji
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Flèche
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardSelectionModal extends StatefulWidget {
  final String type;
  final List<ParrainageReward> rewards;
  final Function(ParrainageReward) onRewardSelected;

  const _RewardSelectionModal({
    required this.type,
    required this.rewards,
    required this.onRewardSelected,
  });

  @override
  State<_RewardSelectionModal> createState() => _RewardSelectionModalState();
}

class _RewardSelectionModalState extends State<_RewardSelectionModal> {
  ParrainageReward? _selectedReward;

  String _getTypeTitle() {
    switch (widget.type) {
      case 'Ami':
        return 'Inviter un Ami';
      case 'Coach':
        return 'Recommander un Coach';
      case 'Salle':
        return 'Ajouter une Salle de Sport';
      default:
        return 'Parrainage';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Titre
          Text(
            'Choisis ta récompense',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pour ${_getTypeTitle().toLowerCase()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          // Liste des récompenses
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: widget.rewards.length,
              itemBuilder: (context, index) {
                final reward = widget.rewards[index];
                final isSelected = _selectedReward?.id == reward.id;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedReward = reward;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? reward.color.withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? reward.color
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Emoji
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: reward.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                reward.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Texte
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reward.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reward.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Checkbox
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? reward.color
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? reward.color
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Bouton de validation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedReward != null
                    ? () {
                        widget.onRewardSelected(_selectedReward!);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Valider ma récompense',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

