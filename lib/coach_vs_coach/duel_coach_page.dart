import 'package:flutter/material.dart';
import '../models/coach_vs_coach.dart';
import 'duel_coach_engine.dart';
import 'duel_challenge_types.dart';
import 'duel_en_cours_screen.dart';
import 'duel_history_page.dart';

class DuelCoachPage extends StatefulWidget {
  const DuelCoachPage({super.key});

  @override
  State<DuelCoachPage> createState() => _DuelCoachPageState();
}

class _DuelCoachPageState extends State<DuelCoachPage> {
  final _rankingNotifier = CoachRankingNotifier();
  final _studentNameController = TextEditingController(); // Pour Coach vs Élève
  final _studentNameAController = TextEditingController(); // Pour Élèves vs Élèves (Élève A)
  final _studentNameBController = TextEditingController(); // Pour Élèves vs Élèves (Élève B)
  
  DuelType _duelType = DuelType.coachVsCoach;
  CoachRanking? _selectedCoachA;
  CoachRanking? _selectedCoachB;
  String? _selectedChallengeType;
  final Duration _defaultDuration = const Duration(seconds: 45);

  List<CoachRanking> _availableCoachesB = [];
  List<String> _availableChallengeTypes = [];

  @override
  void initState() {
    super.initState();
    _rankingNotifier.addListener(_onRankingChanged);
    _updateAvailableCoachesB();
    _updateAvailableChallengeTypes();
  }

  @override
  void dispose() {
    _rankingNotifier.removeListener(_onRankingChanged);
    _studentNameController.dispose();
    _studentNameAController.dispose();
    _studentNameBController.dispose();
    super.dispose();
  }

  void _onRankingChanged() {
    if (mounted) {
      setState(() {
        _updateAvailableCoachesB();
        _updateAvailableChallengeTypes();
        _validateSelections();
      });
    }
  }

  /// Met à jour la liste des coachs B disponibles selon la spécialité de Coach A
  void _updateAvailableCoachesB() {
    if (_selectedCoachA == null) {
      _availableCoachesB = _rankingNotifier.coaches;
      return;
    }

    // Filtrer les coachs avec la même spécialité que Coach A, sauf Coach A lui-même
    _availableCoachesB = _rankingNotifier.coaches
        .where((coach) =>
            coach.specialty == _selectedCoachA!.specialty &&
            coach.id != _selectedCoachA!.id)
        .toList();

    // Si Coach B sélectionné n'est plus disponible, le réinitialiser
    if (_selectedCoachB != null) {
      final isStillAvailable = _availableCoachesB.any(
          (coach) => coach.id == _selectedCoachB!.id);
      if (!isStillAvailable) {
        _selectedCoachB = null;
      }
    }
  }

  /// Met à jour les types de défis disponibles selon la spécialité de Coach A
  void _updateAvailableChallengeTypes() {
    if (_selectedCoachA == null) {
      _availableChallengeTypes = DuelChallengeTypes.allChallengeTypes;
      return;
    }

    _availableChallengeTypes = DuelChallengeTypes.getChallengesForSpecialty(
        _selectedCoachA!.specialty);

    // Si le type de défi sélectionné n'est plus compatible, le réinitialiser
    if (_selectedChallengeType != null) {
      final isStillCompatible = _availableChallengeTypes
          .contains(_selectedChallengeType);
      if (!isStillCompatible) {
        _selectedChallengeType = null;
      }
    }
  }

  /// Valide les sélections et réinitialise si nécessaire
  void _validateSelections() {
    // Vérifier que Coach A est toujours dans la liste
    if (_selectedCoachA != null) {
      final coachAExists = _rankingNotifier.coaches
          .any((coach) => coach.id == _selectedCoachA!.id);
      if (!coachAExists) {
        _selectedCoachA = null;
        _selectedCoachB = null;
        _selectedChallengeType = null;
        _updateAvailableCoachesB();
        _updateAvailableChallengeTypes();
      }
    }

    // Vérifier que Coach B est dans la liste disponible
    if (_selectedCoachB != null && _selectedCoachA != null) {
      final coachBExists = _availableCoachesB
          .any((coach) => coach.id == _selectedCoachB!.id);
      if (!coachBExists) {
        _selectedCoachB = null;
      }
    }
  }

  /// Vérifie si le formulaire est valide pour lancer le duel
  bool get _isFormValid {
    if (_selectedChallengeType == null) {
      return false;
    }

    if (_duelType == DuelType.coachVsCoach) {
      return _selectedCoachA != null &&
          _selectedCoachB != null &&
          _selectedCoachA!.id != _selectedCoachB!.id &&
          _availableCoachesB.isNotEmpty;
    } else if (_duelType == DuelType.coachVsStudent) {
      // Coach vs Élève : vérifier que Coach A et le nom de l'élève ne sont pas vides
      return _selectedCoachA != null && _studentNameController.text.trim().isNotEmpty;
    } else {
      // Élèves vs Élèves : vérifier que les deux noms d'élèves ne sont pas vides
      return _studentNameAController.text.trim().isNotEmpty &&
          _studentNameBController.text.trim().isNotEmpty;
    }
  }

  void _launchDuel() {
    if (!_isFormValid) {
      return;
    }

    // Créer le coach A et l'opposant selon le type de duel
    CoachRanking finalCoachA;
    DuelOpponent opponent;

    if (_duelType == DuelType.coachVsCoach) {
      finalCoachA = _selectedCoachA!;
      opponent = DuelOpponent.coach(_selectedCoachB!);
    } else if (_duelType == DuelType.coachVsStudent) {
      finalCoachA = _selectedCoachA!;
      opponent = DuelOpponent.student(_studentNameController.text.trim());
    } else {
      // Élèves vs Élèves : créer un coach fictif pour coachA
      finalCoachA = CoachRanking(
        id: 'student_a',
        name: _studentNameAController.text.trim(),
        specialty: 'Élève',
        score: 0,
        wins: 0,
        losses: 0,
      );
      opponent = DuelOpponent.student(_studentNameBController.text.trim());
    }

    // Naviguer vers l'écran de duel en cours
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DuelEnCoursScreen(
          coachA: finalCoachA,
          opponent: opponent,
          challengeType: _selectedChallengeType!,
          duration: _defaultDuration,
          duelType: _duelType, // Passer le type de duel
        ),
      ),
    );
  }

  /// Affiche le dialog de résultat moderne
  void _showResultDialog(DuelResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFFC300),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result.winner.name} gagne !',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Défi : ${result.challengeType}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Carte gagnant (verte)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.winner.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${result.winnerScoreChange} points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Carte perdant (rouge)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.shade200,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.loserName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${result.loserScoreChange} points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          // Réinitialiser Coach B et Challenge Type, garder Coach A
                          _selectedCoachB = null;
                          _selectedChallengeType = null;
                          _updateAvailableCoachesB();
                          _updateAvailableChallengeTypes();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111111),
                        side: const BorderSide(
                          color: Color(0xFF111111),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Nouveau duel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coaches = _rankingNotifier.coaches;

    // Palette noir/or
    const darkBg = Color(0xFF0D1117);
    const cardBg = Color(0xFF161B22);
    const cardBgLight = Color(0xFF21262D);
    const primaryGold = Color(0xFFFFC300);
    const textLight = Color(0xFFF0F6FC);
    const textMuted = Color(0xFF8B949E);
    const borderColor = Color(0xFF30363D);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        foregroundColor: textLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Coach vs Coach',
          style: TextStyle(fontWeight: FontWeight.w700, color: textLight),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: primaryGold),
            tooltip: 'Historique',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DuelHistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events, color: primaryGold),
            tooltip: 'Classement',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Classement bientôt disponible'),
                  backgroundColor: cardBgLight,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Créer un duel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sélectionne deux coachs de la même spécialité et un type de défi.',
                    style: TextStyle(fontSize: 13, color: textMuted),
                  ),
                  const SizedBox(height: 24),

                  // Type de duel
                  const Text(
                    'Type de duel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<DuelType>(
                    segments: const [
                      ButtonSegment<DuelType>(
                        value: DuelType.coachVsCoach,
                        label: Text('Coach vs Coach'),
                        icon: Icon(Icons.people, size: 18),
                      ),
                      ButtonSegment<DuelType>(
                        value: DuelType.coachVsStudent,
                        label: Text('Coach vs Élève'),
                        icon: Icon(Icons.person, size: 18),
                      ),
                      ButtonSegment<DuelType>(
                        value: DuelType.studentVsStudent,
                        label: Text('Élèves vs Élèves'),
                        icon: Icon(Icons.people_outline, size: 18),
                      ),
                    ],
                    selected: {_duelType},
                    onSelectionChanged: (Set<DuelType> newSelection) {
                      setState(() {
                        _duelType = newSelection.first;
                        _selectedCoachA = null;
                        _selectedCoachB = null;
                        _studentNameController.clear();
                        _studentNameAController.clear();
                        _studentNameBController.clear();
                        _selectedChallengeType = null;
                        _updateAvailableCoachesB();
                        _updateAvailableChallengeTypes();
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: cardBgLight,
                      selectedBackgroundColor: primaryGold,
                      selectedForegroundColor: darkBg,
                      foregroundColor: textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Coach A
                  const Text(
                    'Coach A',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<CoachRanking>(
                    value: _selectedCoachA != null
                        ? coaches.firstWhere(
                            (c) => c.id == _selectedCoachA!.id,
                            orElse: () => _selectedCoachA!,
                          )
                        : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      hintText: 'Sélectionner un coach',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      errorText: null,
                      errorStyle: const TextStyle(height: 0),
                    ),
                    items: coaches.map((coach) {
                      return DropdownMenuItem<CoachRanking>(
                        value: coach,
                        child: Text('${coach.name} (${coach.specialty})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCoachA = value;
                        _selectedCoachB = null;
                        _selectedChallengeType = null;
                        _updateAvailableCoachesB();
                        _updateAvailableChallengeTypes();
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Coach B ou Élève (selon le type de duel)
                  if (_duelType == DuelType.coachVsCoach) ...[
                    const Text(
                      'Coach B',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CoachRanking>(
                      value: _availableCoachesB.isEmpty
                          ? null
                          : (_selectedCoachB != null && _availableCoachesB.any((c) => c.id == _selectedCoachB!.id))
                              ? _availableCoachesB.firstWhere((c) => c.id == _selectedCoachB!.id)
                              : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: _selectedCoachA != null && _availableCoachesB.isNotEmpty
                            ? const Color(0xFFF7F7F7)
                            : Colors.grey.shade100,
                        hintText: _selectedCoachA == null
                            ? 'Sélectionne d\'abord Coach A'
                            : _availableCoachesB.isEmpty
                                ? 'Aucun coach disponible'
                                : 'Sélectionner un coach',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        errorText: null,
                        errorStyle: const TextStyle(height: 0),
                      ),
                      items: _availableCoachesB.isEmpty
                          ? []
                          : _availableCoachesB.map((coach) {
                              return DropdownMenuItem<CoachRanking>(
                                value: coach,
                                child: Text('${coach.name} (${coach.specialty})'),
                              );
                            }).toList(),
                      onChanged: _selectedCoachA != null && _availableCoachesB.isNotEmpty
                          ? (value) {
                              setState(() {
                                _selectedCoachB = value;
                              });
                            }
                          : null,
                    ),
                    // Message si aucun coach B disponible
                    if (_selectedCoachA != null && _availableCoachesB.isEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Aucun autre coach disponible pour cette spécialité pour le moment.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else if (_duelType == DuelType.coachVsStudent) ...[
                    // Champ Élève (Coach vs Élève)
                    const Text(
                      'Élève',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _studentNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                        filled: true,
                        fillColor: _selectedCoachA != null
                            ? const Color(0xFFF7F7F7)
                            : Colors.grey.shade100,
                        hintText: _selectedCoachA == null
                            ? 'Sélectionne d\'abord Coach A'
                            : 'Entrez le nom de l\'élève (ex: Nadia, Sarah)',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      errorText: null,
                      errorStyle: const TextStyle(height: 0),
                      ),
                      enabled: _selectedCoachA != null,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ] else ...[
                    // Champs Élèves (Élèves vs Élèves)
                    const Text(
                      'Élève A',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _studentNameAController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        hintText: 'Entrez le nom de l\'élève A (ex: Nadia)',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        errorText: null,
                        errorStyle: const TextStyle(height: 0),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Élève B',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _studentNameBController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        hintText: 'Entrez le nom de l\'élève B (ex: Sarah)',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        errorText: null,
                        errorStyle: const TextStyle(height: 0),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Type de défi
                  const Text(
                    'Type de défi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _availableChallengeTypes.isEmpty
                        ? null
                        : (_selectedChallengeType != null && _availableChallengeTypes.contains(_selectedChallengeType))
                            ? _availableChallengeTypes.firstWhere((t) => t == _selectedChallengeType)
                            : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: _selectedCoachA != null && _availableChallengeTypes.isNotEmpty
                          ? const Color(0xFFF7F7F7)
                          : Colors.grey.shade100,
                      hintText: _selectedCoachA == null
                          ? 'Sélectionne d\'abord Coach A'
                          : 'Sélectionner un type de défi',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      errorText: null,
                      errorStyle: const TextStyle(height: 0),
                    ),
                    items: _availableChallengeTypes.isEmpty
                        ? []
                        : _availableChallengeTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                    onChanged: _selectedCoachA != null && _availableChallengeTypes.isNotEmpty
                        ? (value) {
                            setState(() {
                              _selectedChallengeType = value;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Bouton Lancer le défi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isFormValid ? _launchDuel : null,
                      icon: const Icon(Icons.sports_mma),
                      label: const Text('Lancer le défi (démo)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}
