# 🔍 Vérification étape par étape : Coach Vocal IA

## ✅ **CHECKLIST RAPIDE**

### **1. Dans le Profil**
- [ ] Va dans **Profil** (icône personne en haut à droite)
- [ ] Fais défiler vers le bas
- [ ] **Vois-tu une carte noire avec "Coach Vocal IA" et un microphone jaune ?**
  - ❌ **NON** → Le code n'est peut-être pas à jour. Continue ci-dessous.
  - ✅ **OUI** → Passe à l'étape 2

### **2. Sélection du coach**
- [ ] Clique sur la carte "Coach Vocal IA"
- [ ] **La page s'ouvre avec 4 coaches ?**
  - ❌ **NON** → Erreur de navigation
  - ✅ **OUI** → Sélectionne un coach (ex: "Coach Emma") et clique "Sélectionner"
- [ ] **Tu reviens au profil et vois un badge jaune avec le nom du coach ?**
  - ❌ **NON** → Le notifier ne fonctionne pas
  - ✅ **OUI** → Passe à l'étape 3

### **3. Dans une séance d'exercice**
- [ ] Va dans **"Séances"** (onglet du bas)
- [ ] Clique sur un programme (ex: "Full body")
- [ ] Clique sur **"Démarrer la séance"**
- [ ] **Dans la page de séance, regarde en haut à droite de l'AppBar**
- [ ] **Vois-tu une icône microphone à côté du bouton "X" ?**
  - ❌ **NON** → L'intégration dans `workout_session_page.dart` n'est pas complète
  - ✅ **OUI** → Clique dessus (devient jaune)
- [ ] Clique sur **"Démarrer"** en bas
- [ ] **Après 15 secondes, vois-tu :**
  - Une bulle noire en haut avec une phrase ? ✅ / ❌
  - Une carte "Coach IA" sous le titre de l'étape ? ✅ / ❌
  - Une icône microphone dans le bouton "Pause" ? ✅ / ❌

---

## 🐛 **DIAGNOSTIC**

### **Si tu ne vois PAS la carte "Coach Vocal IA" dans le profil :**

**Fichier à vérifier :** `lib/main.dart` ligne ~3606

```dart
// Doit contenir :
import 'coach_personality/coach_personality_page.dart';
import 'coach_personality/coach_personality_notifier.dart';

// Et vers la ligne 3606 :
// Bloc Coach Vocal IA
InkWell(
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CoachPersonalityPage(),
      ),
    );
  },
  // ... carte noire avec microphone jaune
)
```

### **Si tu ne vois PAS l'icône microphone dans la séance :**

**Fichier à vérifier :** `lib/workout_session_page.dart` ligne ~406

```dart
// Dans l'AppBar, actions: [
Stack(
  children: [
    IconButton(
      icon: Icon(
        _coachNotifier.isEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
        color: _coachNotifier.isEnabled ? const Color(0xFFFFC300) : Colors.white70,
        size: 28,
      ),
      onPressed: _toggleCoach,
    ),
    // Point rouge si actif
  ],
),
```

### **Si le coach ne parle pas :**

**Vérifications :**
1. ✅ As-tu sélectionné un coach dans le profil ?
2. ✅ As-tu activé le microphone (icône jaune) ?
3. ✅ As-tu cliqué sur "Démarrer" ?
4. ✅ L'exercice a-t-il une durée (`durationSeconds != null`) ?

**Le coach parle uniquement :**
- Si l'exercice a un timer (pas les étapes sans durée)
- Si le coach est activé ET sélectionné
- Toutes les 15 secondes pendant l'exercice

---

## 🔧 **COMMANDES DE DÉPANNAGE**

```bash
# 1. Nettoyer le cache
flutter clean

# 2. Réinstaller les dépendances
flutter pub get

# 3. Vérifier les erreurs
flutter analyze

# 4. Lancer l'app
flutter run -d chrome --web-port=8080
```

---

## 📸 **CE QUE TU DOIS VOIR**

### **Dans le Profil :**
```
┌─────────────────────────────────────┐
│ [🎤] Coach Vocal IA    [Coach Emma] │
│ Choisis ton coach pour t'accompagner│
│                              [→]    │
└─────────────────────────────────────┘
```

### **Dans la séance (AppBar en haut) :**
```
[←] Full body – Niveau intermédiaire  [🎤] [X]
                                        ↑
                                   Microphone ici
```

### **Pendant l'exercice :**
```
┌─────────────────────────────────────┐
│ [💗] Coach Emma  [•] En direct      │
│ "Tu es en plein dedans, c'est très  │
│  bien."                      [🔊]   │
└─────────────────────────────────────┘
```

---

## 🚨 **Si rien ne fonctionne**

**Envoie-moi :**
1. Une capture d'écran de ta page **Profil** (partie basse)
2. Une capture d'écran de ta page **Séance** (avec l'AppBar visible)
3. Le résultat de `flutter analyze` dans le terminal

Je pourrai identifier précisément le problème ! 🔍







