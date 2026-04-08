# 🎤 Coach Personnalité™ - Système Vocal IA (Mode Démo)

## 📋 Vue d'ensemble

Le module **Coach Personnalité™** est un système de coach vocal IA en mode démo qui accompagne l'utilisateur pendant ses exercices avec des phrases motivantes adaptées au progrès de l'exercice.

## 🗂️ Structure des fichiers

### Modèles
- **`lib/coach_personality/coach_personality_model.dart`**
  - `CoachStyle` : Enum des 4 styles (gentle, hard, military, humor)
  - `CoachPhrases` : Phrases organisées par phase (start, middle, almostDone, end)
  - `CoachPersonality` : Modèle complet d'un coach avec nom, icône, couleur, phrases
  - `CoachPersonalityFactory` : Factory pour créer les 4 coaches disponibles

### Notifier
- **`lib/coach_personality/coach_personality_notifier.dart`**
  - Singleton `ChangeNotifier` pour gérer le coach sélectionné
  - Méthode `getPhraseForProgress(double progress)` : Retourne une phrase selon le progrès (0.0 - 1.0)
  - Gestion de l'activation/désactivation du coach

### UI
- **`lib/coach_personality/coach_personality_page.dart`**
  - Page de sélection du coach avec 4 cartes (une par style)
  - Design premium noir/jaune FitPro
  - Boutons "Prévisualiser" et "Sélectionner"

- **`lib/widgets/coach_voice_bubble.dart`**
  - Widget bulle vocale affichée pendant les exercices
  - Animations d'apparition/disparition
  - Auto-dismiss après 4 secondes

### Intégration
- **`lib/workout_session_page.dart`** (modifié)
  - Intégration complète du coach vocal
  - Bouton microphone dans l'AppBar
  - Timer pour déclencher les phrases toutes les 15 secondes
  - Calcul du progrès dynamique selon la durée de l'exercice

## 🎯 Les 4 coaches disponibles

### 1. **Coach Emma** (Gentil) 💗
- **Style** : Bienveillant et encourageant
- **Couleur** : Rose
- **Icône** : `Icons.favorite_rounded`
- **Phrases** : Douces, motivantes, positives

### 2. **Coach Max** (Dur) 🔥
- **Style** : Exigeant et motivant
- **Couleur** : Rouge
- **Icône** : `Icons.whatshot_rounded`
- **Phrases** : Directes, challengeantes, sans compromis

### 3. **Sergent Lucas** (Militaire) 🪖
- **Style** : Discipliné et structuré
- **Couleur** : Vert
- **Icône** : `Icons.military_tech_rounded`
- **Phrases** : Ordres, discipline, exécution

### 4. **Coach Tom** (Humour) 😄
- **Style** : Décontracté et drôle
- **Couleur** : Orange
- **Icône** : `Icons.sentiment_very_satisfied_rounded`
- **Phrases** : Légères, amusantes, décontractées

## 📊 Système de phases dynamiques

Chaque coach a 4 phases de phrases selon le progrès de l'exercice :

1. **phaseStart** (0% → 20%) : Phrases de début
2. **phaseMiddle** (20% → 70%) : Phrases du milieu
3. **phaseAlmostDone** (70% → 95%) : Phrases "presque fini"
4. **phaseEnd** (95% → 100%) : Phrases de félicitations

### Calcul du progrès

```dart
final elapsed = _stepInitialDuration - _remainingSeconds;
final progress = elapsed / _stepInitialDuration; // 0.0 - 1.0
```

Le système s'adapte automatiquement à la durée de l'exercice :
- Exercice de 1 minute → phrases adaptées
- Exercice de 10 minutes → phrases adaptées
- Même coach, même logique, durée flexible

## 🚀 Utilisation

### 1. Sélectionner un coach

**Depuis le profil** :
- Aller dans "Mon profil"
- Cliquer sur la carte "Coach Vocal IA"
- Choisir un coach parmi les 4 disponibles
- Cliquer sur "Sélectionner"

**Depuis une séance d'exercice** :
- Cliquer sur l'icône microphone dans l'AppBar
- Si aucun coach n'est sélectionné → redirection vers la page de sélection
- Si un coach est sélectionné → activation/désactivation

### 2. Pendant un exercice

1. Démarrer une séance d'entraînement
2. Cliquer sur l'icône microphone pour activer le coach
3. Démarrer le timer de l'exercice
4. Les phrases apparaissent automatiquement :
   - **Immédiatement** au démarrage
   - **Toutes les 15 secondes** pendant l'exercice
   - **Selon le progrès** (début → milieu → presque fini → fin)

### 3. Bulle vocale

- S'affiche en haut de l'écran pendant l'exercice
- Contient : icône du coach, nom, phrase
- Auto-dismiss après 4 secondes
- Peut être fermée manuellement

## 🎨 Design

### Couleurs FitPro
- **Fond principal** : `#050814` (noir profond)
- **Cartes** : `#0D111C` (noir bleuté)
- **Jaune primaire** : `#FFC300`
- **Accent cyan** : `#00F0FF`

### Animations
- **FadeIn** : Apparition en fondu
- **SlideUp** : Glissement depuis le bas
- **Scale** : Effet de zoom léger
- **Glow** : Effet lumineux autour des icônes

## 🔧 Intégration dans d'autres pages

Pour intégrer le coach dans une autre page avec timer :

```dart
import 'coach_personality/coach_personality_notifier.dart';
import 'widgets/coach_voice_bubble.dart';

// Dans le State
late CoachPersonalityNotifier _coachNotifier;
Timer? _coachPhraseTimer;
String? _currentCoachPhrase;
int _initialDuration = 60; // Durée en secondes
int _remainingSeconds = 60;

@override
void initState() {
  super.initState();
  _coachNotifier = CoachPersonalityNotifier();
  _coachNotifier.addListener(() => setState(() {}));
}

void _startCoachPhraseTimer() {
  if (!_coachNotifier.isEnabled) return;
  
  _coachPhraseTimer?.cancel();
  _updateCoachPhrase(); // Première phrase immédiatement
  
  _coachPhraseTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
    if (!mounted || !_coachNotifier.isEnabled) {
      timer.cancel();
      return;
    }
    _updateCoachPhrase();
  });
}

void _updateCoachPhrase() {
  if (!_coachNotifier.isEnabled) return;
  
  final elapsed = _initialDuration - _remainingSeconds;
  final progress = elapsed / _initialDuration;
  
  final phrase = _coachNotifier.getPhraseForProgress(progress);
  if (phrase != null) {
    setState(() {
      _currentCoachPhrase = phrase;
    });
  }
}

// Dans le build
Stack(
  children: [
    // Contenu principal
    YourContent(),
    
    // Bulle vocale
    if (_currentCoachPhrase != null && _coachNotifier.currentCoach != null)
      Positioned(
        top: 80,
        left: 0,
        right: 0,
        child: CoachVoiceBubble(
          phrase: _currentCoachPhrase!,
          coach: _coachNotifier.currentCoach!,
          onDismiss: () => setState(() => _currentCoachPhrase = null),
        ),
      ),
  ],
)
```

## 📝 Notes importantes

- **Mode démo** : Aucune IA réelle, aucune API, simulation pure
- **Phrases pré-définies** : Toutes les phrases sont hardcodées dans le modèle
- **Pas de voix** : Affichage texte uniquement (pas de TTS)
- **Singleton** : Le coach sélectionné est partagé dans toute l'app
- **Persistance** : Le coach reste sélectionné jusqu'à changement manuel

## ✅ Fonctionnalités

- ✅ 4 styles de coach différents
- ✅ Phrases adaptées au progrès (4 phases)
- ✅ Système dynamique (s'adapte à n'importe quelle durée)
- ✅ Bulle vocale animée
- ✅ Activation/désactivation en temps réel
- ✅ Intégration dans `workout_session_page.dart`
- ✅ Page de sélection premium
- ✅ Lien dans le profil
- ✅ Bouton microphone dans les séances

## 🎯 Prochaines étapes possibles

- [ ] Ajouter plus de phrases par coach
- [ ] Personnalisation des phrases par l'utilisateur
- [ ] Intégration TTS (Text-to-Speech) pour voix réelle
- [ ] Statistiques d'utilisation par coach
- [ ] Coaches premium supplémentaires

---

**Créé pour FitPro** 💛🖤







