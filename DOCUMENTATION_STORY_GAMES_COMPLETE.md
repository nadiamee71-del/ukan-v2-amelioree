# 📚 Documentation Complète : Sport Gaming Story™

## 🎯 Vue d'ensemble

Le système **Sport Gaming Story™** est un système de gamification qui transforme les séances d'entraînement en aventure narrative. Chaque story est un chapitre avec des missions, des objectifs, et des récompenses (badges).

---

## 📖 Liste Complète des Stories

### **STORY 1 : La Salle d'Entraînement Oubliée**
- **Chapitre** : 1
- **ID** : `story1`
- **Sous-titre** : "Le Départ de ton Aventure"
- **Description** : Tu découvres une salle abandonnée, poussiéreuse. Une lourde porte bloque l'accès à la salle principale. Pour l'ouvrir, tu dois prouver ta détermination.
- **Image** : `assets/images/story_1_salle_entrainement.png`
- **Boss** : "La Porte Verrouillée"
- **Objectif** : 5 squats
- **Mission** :
  - 🚪 Fais 5 squats pour ouvrir la porte
  - Status initial : `inProgress`
  - Target : 5 squats
- **Badge débloqué** : 🎯 **Starter** (`starter`)
  - Description : "Tu entres dans la voie."
  - Image : `assets/images/badge_starter.png`
  - Condition : "Faire 5 squats (Story 1)"
- **XP gagné** : Variable selon la progression

---

### **STORY 2 : Le Couloir de l'Énergie**
- **Chapitre** : 2
- **ID** : `story2`
- **Sous-titre** : "Recharge ton énergie intérieure"
- **Description** : Le couloir s'éclaire lorsque tu avances. Une voix numérique te dit : "Pour continuer, recharge ton énergie intérieure."
- **Image** : `assets/images/story_2_couloir_energie.png`
- **Boss** : "Le Couloir de l'Énergie"
- **Objectif** : 10 secondes de gainage
- **Mission** :
  - ⚡ Fais 10 secondes de gainage
  - Status initial : `locked` (débloqué après Story 1)
  - Target : 10 secondes
- **Badge débloqué** : 💪 **Endurant** (`endurant`)
  - Description : "Ton mental est solide."
  - Image : `assets/images/badge_endurant.png`
  - Condition : "Faire 10 secondes de gainage (Story 2)"
- **XP gagné** : Variable selon la progression

---

### **STORY 3 : L'Autel de l'Hydratation**
- **Chapitre** : 3
- **ID** : `story3`
- **Sous-titre** : "Aucune évolution sans hydratation"
- **Description** : Tu arrives devant un autel digital. Une inscription s'affiche : "Aucune évolution sans hydratation."
- **Image** : `assets/images/story_3_autel_hydratation.png`
- **Boss** : "L'Autel de l'Hydratation"
- **Objectif** : 200 ml d'eau
- **Mission** :
  - 💧 Bois 200 ml d'eau
  - Status initial : `locked` (débloqué après Story 2)
  - Target : 200 ml
- **Badge débloqué** : 💧 **Hydro Boost** (`hydro_boost`)
  - Description : "Hydraté = prêt à avancer."
  - Image : `assets/images/badge_hydro_boost.png`
  - Condition : "Boire 200 ml d'eau (Story 3)"
- **XP gagné** : Variable selon la progression

---

### **STORY 4 : Le Pont des 5000 Pas**
- **Chapitre** : 4
- **ID** : `story4`
- **Sous-titre** : "Prouve ta constance"
- **Description** : Un pont immense se déploie devant toi. Il ne se stabilisera que si tu prouves ta constance.
- **Image** : `assets/images/story_4_pont_5000_pas.png`
- **Boss** : "Le Pont des 5000 Pas"
- **Objectif** : 5000 pas
- **Mission** :
  - 🌉 Marche 5000 pas
  - Status initial : `locked` (débloqué après Story 3)
  - Target : 5000 pas
- **Badge débloqué** : 🚶 **En Marche** (`en_marche`)
  - Description : "La route t'appartient."
  - Image : `assets/images/badge_en_marche.png`
  - Condition : "Marcher 5000 pas (Story 4)"
- **XP gagné** : Variable selon la progression

---

### **STORY 5 : La Porte du Sommeil Sacré**
- **Chapitre** : 5
- **ID** : `story5`
- **Sous-titre** : "Le corps progresse aussi pendant la nuit"
- **Description** : Une porte biométrique bloque le passage. Elle détecte la qualité de ton repos. "Le corps progresse aussi pendant la nuit."
- **Image** : `assets/images/story_5_porte_sommeil.png`
- **Boss** : "La Porte du Sommeil Sacré"
- **Objectif** : 7 heures de sommeil
- **Mission** :
  - 🌙 Dors 7 heures
  - Status initial : `locked` (débloqué après Story 4)
  - Target : 7 heures
- **Badge débloqué** : 🌙 **Repos du Guerrier** (`repos_guerrier`)
  - Description : "La récupération fait partie du pouvoir."
  - Image : `assets/images/badge_repos_guerrier.png`
  - Condition : "Dormir 7 heures (Story 5)"
- **XP gagné** : Variable selon la progression

---

### **BOSS JAMBES : Le Gardien du Niveau 2**
- **Chapitre** : 6
- **ID** : `boss_legs`
- **Sous-titre** : "Le Gardien du Niveau 2"
- **Description** : Tu passes une dernière porte. Le sol tremble. Le Boss Jambes apparaît, gardien du Niveau 2. Il teste ta force, ton courage, et ta discipline.
- **Image** : `assets/images/boss_jambes.png`
- **Boss** : "Boss Jambes"
- **Objectif** : 100 squats
- **Missions** (progression dynamique) :
  1. 👁️ **0/100 → Le Boss te jauge**
     - Description : "Commence à l'impressionner"
     - Status initial : `inProgress`
     - Target : 30 squats
  2. 💪 **30/100 → Tu commences à l'impressionner**
     - Description : "Continue, tu le domines"
     - Status initial : `locked` (débloqué à 30 squats)
     - Target : 60 squats
  3. ⚔️ **60/100 → Il recule… tu le domines**
     - Description : "La victoire approche"
     - Status initial : `locked` (débloqué à 60 squats)
     - Target : 100 squats
  4. 👑 **100/100 → Victoire ! Le passage s'ouvre**
     - Description : "Tu es officiellement un conquérant"
     - Status initial : `locked` (débloqué à 100 squats)
     - Target : 100 squats
- **Badge débloqué** : 👑 **Boss Slayer** (`boss_slayer`)
  - Description : "Tu écrases les obstacles."
  - Image : `assets/images/badge_boss_slayer.png`
  - Condition : "Vaincre le Boss Jambes (100 squats)"
- **XP gagné** : 50 XP (bonus pour vaincre un boss)

---

### **🧪 STORY TEST : L'Aventure du Testeur**
- **Chapitre** : 7
- **ID** : `story_test`
- **Sous-titre** : "TEST - Débloque les exercices un par un"
- **Description** : 🧪 TEST - Une histoire spéciale pour tester le système de déblocage progressif. Complète chaque exercice pour débloquer le suivant et obtenir le badge final.
- **Image** : `assets/images/ChatGPT Image 25 nov. 2025, 18_45_34.png`
- **Boss** : "🧪 TEST - Le Défi Final"
- **Objectif** : 3 exercices complétés
- **Missions** (déblocage progressif) :
  1. 🎯 **🧪 TEST - Exercice 1 : Les Fondations**
     - Description : "TEST - Complète le premier exercice pour débloquer le suivant"
     - Status initial : `inProgress`
     - Target : 1 exercice
     - **Exercice** : `test_story_exercise_1` - "🎯 Exercice Test Story - Niveau 1"
       - Durée : 20 secondes
       - Image : `assets/images/ChatGPT Image 25 nov. 2025, 18_27_24.png`
       - **Coach Vocal IA activé automatiquement** ✅
  2. ⚡ **🧪 TEST - Exercice 2 : L'Ascension**
     - Description : "TEST - Débloqué après l'exercice 1. Continue ton aventure"
     - Status initial : `locked` (débloqué après exercice 1)
     - Target : 2 exercices
     - **Exercice** : `test_story_exercise_2` - "⚡ Exercice Test Story - Niveau 2"
       - Durée : 30 secondes
       - Image : `assets/images/ChatGPT Image 25 nov. 2025, 18_32_27.png`
       - **Coach Vocal IA activé automatiquement** ✅
  3. 👑 **🧪 TEST - Exercice 3 : La Victoire**
     - Description : "TEST - Débloqué après l'exercice 2. Obtiens le badge final !"
     - Status initial : `locked` (débloqué après exercice 2)
     - Target : 3 exercices
     - **Exercice** : `test_story_exercise_3` - "👑 Exercice Test Story - Niveau 3"
       - Durée : 40 secondes
       - Image : `assets/images/ChatGPT Image 25 nov. 2025, 18_35_02.png`
       - **Coach Vocal IA activé automatiquement** ✅
- **Badge débloqué** : 🎯 **🧪 TEST - Maître du Test** (`test_story_badge`)
  - Description : "🧪 TEST - Tu as complété la Story Test avec succès !"
  - Image : `assets/images/badge_starter.png`
  - Condition : "🧪 TEST - Compléter les 3 exercices de la Story Test"
- **XP gagné** : Variable selon la progression

---

## 🏆 Système de Badges (Récompenses)

### Badges des Stories
1. **🎯 Starter** (`starter`)
   - Débloqué : Story 1 complétée
   - Image : `assets/images/badge_starter.png`
   - Status initial : `isUnlocked: true` (débloqué par défaut en démo)

2. **💪 Endurant** (`endurant`)
   - Débloqué : Story 2 complétée
   - Image : `assets/images/badge_endurant.png`

3. **💧 Hydro Boost** (`hydro_boost`)
   - Débloqué : Story 3 complétée
   - Image : `assets/images/badge_hydro_boost.png`

4. **🚶 En Marche** (`en_marche`)
   - Débloqué : Story 4 complétée
   - Image : `assets/images/badge_en_marche.png`

5. **🌙 Repos du Guerrier** (`repos_guerrier`)
   - Débloqué : Story 5 complétée
   - Image : `assets/images/badge_repos_guerrier.png`

6. **👑 Boss Slayer** (`boss_slayer`)
   - Débloqué : Boss Jambes vaincu (100 squats)
   - Image : `assets/images/badge_boss_slayer.png`

7. **⭐ Légende** (`legend`)
   - Débloqué : Avoir 6 badges
   - Image : `assets/images/badge_legende.png`

8. **🎯 🧪 TEST - Maître du Test** (`test_story_badge`)
   - Débloqué : Story Test complétée (3 exercices)
   - Image : `assets/images/badge_starter.png`

---

## 📊 Système de Progression

### Niveaux et XP
- **Niveau initial** : 1
- **XP initial** : 0
- **XP pour niveau suivant** : `100 * niveau_actuel`
  - Niveau 1 → 2 : 100 XP
  - Niveau 2 → 3 : 200 XP
  - Niveau 3 → 4 : 300 XP
  - etc.

### Quêtes Journalières
5 quêtes disponibles :
1. **Faire une séance** (15 XP) - Tag: Story
2. **Boire de l'eau** (5 XP) - Tag: Santé
3. **Faire 30 squats** (10 XP) - Tag: Story
4. **Dormir 7 heures** (5 XP) - Tag: Santé
5. **Marcher 5000 pas** (10 XP) - Tag: Habitude

**Total XP disponible par jour** : 45 XP

---

## 🔧 Architecture Technique

### Fichiers Principaux

#### `lib/models/game_story.dart`
- **Classe principale** : `GameStoryNotifier` (extends `ChangeNotifier`)
- **Modèles** :
  - `StoryChapter` : Représente un chapitre de story
  - `ChapterMission` : Représente une mission dans un chapitre
  - `GameBoss` : Représente un boss/objectif
  - `GameReward` : Représente un badge/récompense
  - `DailyQuest` : Représente une quête journalière
  - `GameLevel` : Représente un niveau de jeu
- **Méthodes principales** :
  - `currentChapter` : Retourne le premier chapitre non complété
  - `updateChapterMission(chapterId, missionId, status)` : Met à jour le statut d'une mission
  - `unlockReward(rewardId)` : Débloque un badge
  - `defeatBoss(bossId)` : Marque un boss comme vaincu
  - `addXP(xp)` : Ajoute de l'XP et gère le level up

#### `lib/game_story/story_home.dart`
- **Page d'accueil** du Sport Gaming Story™
- Affiche :
  - Le chapitre actuel
  - La progression XP/Niveau
  - Les quêtes du jour
  - Les badges
  - L'avatar et le classement
  - **La Story Test** (toujours visible)

#### `lib/game_story/story_chapter_page.dart`
- **Page détaillée d'un chapitre**
- Fonctionnalités :
  - Affichage de l'illustration
  - Description narrative
  - Liste des missions
  - Zone d'exercice avec chronomètre
  - Boutons d'action adaptés selon le type de chapitre
  - **Pour Story Test** : Boutons pour lancer les exercices avec Coach Vocal IA
- **Logique de progression** :
  - `_checkMissionProgress()` : Vérifie la progression et débloque les missions suivantes
  - `_checkBossDefeat()` : Vérifie si le boss est vaincu et débloque le badge
  - `_addRep()` : Incrémente la progression (simulation)
  - `_launchExercise()` : Lance un exercice réel avec Coach Vocal IA (Story Test uniquement)

#### `lib/data/demo_exercises.dart`
- **Exercices de la Story Test** :
  - `test_story_exercise_1` : Exercice 1 (20 secondes)
  - `test_story_exercise_2` : Exercice 2 (30 secondes)
  - `test_story_exercise_3` : Exercice 3 (40 secondes)

---

## 🎮 Logique de Déblocage

### Stories 1-5
- **Déblocage séquentiel** : Chaque story est débloquée après avoir complété la précédente
- **Mission unique** : Une seule mission principale par story
- **Badge** : Débloqué automatiquement quand la mission est complétée

### Boss Jambes
- **Progression dynamique** : 4 missions qui se débloquent progressivement
  - Mission 1 : Débloquée à 30 squats
  - Mission 2 : Débloquée à 60 squats
  - Mission 3 : Débloquée à 100 squats
  - Mission 4 : Complétée à 100 squats
- **Badge** : Débloqué automatiquement à 100 squats

### Story Test
- **Déblocage progressif** : 3 exercices qui se débloquent un par un
  - Exercice 1 : Débloqué dès le départ
  - Exercice 2 : Débloqué après avoir complété l'exercice 1
  - Exercice 3 : Débloqué après avoir complété l'exercice 2
- **Lancement réel** : Les exercices sont lancés via `WorkoutSessionPage` avec Coach Vocal IA
- **Badge** : Débloqué automatiquement après avoir complété les 3 exercices

---

## 🎤 Coach Vocal IA dans Story Test

### Activation Automatique
- **Détection** : Les exercices de la Story Test contiennent "Test" dans leur nom
- **Code** : `lib/workout_session_page.dart` ligne 80-84
  ```dart
  final isTestExercise = widget.workoutTitle.contains('Test') || widget.workoutTitle.contains('🧪');
  if (isTestExercise && _coachNotifier.currentCoach == null) {
    _coachNotifier.selectCoach(CoachStyle.humor);
    _coachNotifier.setEnabled(true);
  }
  ```
- **Coach par défaut** : Coach Drôle (Humor)
- **Audio** : Activé automatiquement pour les exercices de test

### Boutons dans Story Test
- **Exercice 1** : "🎤 Lancer l'Exercice 1 (avec Coach Vocal IA)"
- **Exercice 2** : "🎤 Lancer l'Exercice 2 (avec Coach Vocal IA)"
- **Exercice 3** : "🎤 Lancer l'Exercice 3 (avec Coach Vocal IA)"
- **Simulation** : "+1 Exercice complété (simulation)" (optionnel)

---

## 📱 Interface Utilisateur

### Couleurs
- **Fond principal** : `Color(0xFFFFF9E6)` (beige clair)
- **AppBar** : `Color(0xFF5D4037)` (marron foncé)
- **Texte** : `Colors.black` / `Colors.black87` (noir pour lisibilité)
- **Vert principal** : `Color(0xFF4CAF50)`
- **Marron clair** : `Color(0xFFD4A574)`
- **Marron foncé** : `Color(0xFF8B6F47)`

### Pages
1. **Story Home** (`story_home.dart`)
   - Vue d'ensemble
   - Chapitre actuel
   - Quêtes et badges
   
2. **Story Chapter** (`story_chapter_page.dart`)
   - Détails du chapitre
   - Missions
   - Zone d'exercice
   
3. **Story Rewards** (`story_rewards.dart`)
   - Liste de tous les badges
   
4. **Daily Quests** (`daily_quests_page.dart`)
   - Liste des quêtes journalières

---

## 🔄 Flux de Progression

### Pour une Story normale (1-5)
1. Utilisateur ouvre la Story
2. Clique sur "+X" (simulation) pour progresser
3. Quand l'objectif est atteint :
   - Mission marquée comme `completed`
   - Badge débloqué automatiquement
   - XP ajouté
   - Story suivante débloquée

### Pour le Boss Jambes
1. Utilisateur ouvre le Boss
2. Clique sur "+1 Squat" pour progresser
3. À 30 squats : Mission 1 complétée, Mission 2 débloquée
4. À 60 squats : Mission 2 complétée, Mission 3 débloquée
5. À 100 squats : Toutes les missions complétées, badge débloqué

### Pour la Story Test
1. Utilisateur ouvre la Story Test
2. Clique sur "🎤 Lancer l'Exercice 1"
3. Exercice lancé dans `WorkoutSessionPage` avec Coach Vocal IA
4. Après complétion : Retour à la Story, progression incrémentée
5. Exercice 2 débloqué automatiquement
6. Répète pour exercices 2 et 3
7. Badge débloqué après les 3 exercices

---

## 🛠️ Pour les Développeurs

### Ajouter une Nouvelle Story

1. **Dans `lib/models/game_story.dart`** :
   ```dart
   StoryChapter(
     id: 'story_X',
     chapterNumber: X,
     title: 'STORY X : Titre',
     subtitle: 'Sous-titre',
     description: 'Description narrative',
     imagePath: 'assets/images/story_X.png',
     boss: GameBoss(
       id: 'boss_X',
       name: 'Nom du Boss',
       description: 'Description',
       challenge: 'Objectif',
       targetValue: X,
       targetUnit: 'unité',
     ),
     missions: [
       ChapterMission(
         id: 'story_X_mission1',
         title: 'Titre mission',
         description: 'Description',
         icon: '🎯',
         status: MissionStatus.inProgress, // ou locked
         targetValue: X,
       ),
     ],
   ),
   ```

2. **Ajouter le badge correspondant** :
   ```dart
   GameReward(
     id: 'badge_X',
     name: 'Nom Badge',
     description: 'Description',
     icon: '🎯',
     imagePath: 'assets/images/badge_X.png',
     unlockCondition: 'Condition de déblocage',
   ),
   ```

3. **Dans `story_chapter_page.dart`** :
   - Ajouter le cas dans `_getProgressLabel()`
   - Ajouter le cas dans `_buildActionButtons()` si nécessaire
   - Ajouter le cas dans `_checkMissionProgress()` si logique spéciale

### Modifier la Logique de Déblocage

- **Fichier** : `lib/game_story/story_chapter_page.dart`
- **Méthode** : `_checkMissionProgress()`
- **Exemple pour Story Test** :
  ```dart
  else if (chapter.id == 'story_test') {
    if (_currentProgress >= 1 && missions[0].status != MissionStatus.completed) {
      _gameNotifier.updateChapterMission(chapter.id, missions[0].id, MissionStatus.completed);
      // Débloquer mission suivante
      if (missions[1].status == MissionStatus.locked) {
        _gameNotifier.updateChapterMission(chapter.id, missions[1].id, MissionStatus.inProgress);
      }
    }
    // Répéter pour missions suivantes
  }
  ```

### Ajouter un Exercice à la Story Test

1. **Dans `lib/data/demo_exercises.dart`** :
   ```dart
   ExerciseLibraryItem(
     id: 'test_story_exercise_X',
     name: '🎯 Exercice Test Story - Niveau X',
     // ... autres propriétés
   ),
   ```

2. **Dans `lib/game_story/story_chapter_page.dart`** :
   - Ajouter le bouton dans `_buildActionButtons()` pour `story_test`
   - Ajouter la mission correspondante dans `game_story.dart`

---

## 📝 Notes Importantes

1. **Story Test** : Toujours visible dans `story_home.dart` grâce à `_buildTestStoryCard()`
2. **Coach Vocal IA** : Activé automatiquement pour tous les exercices contenant "Test" dans le titre
3. **Progression** : Les missions se débloquent automatiquement selon la logique dans `_checkMissionProgress()`
4. **Badges** : Débloqués automatiquement via `unlockReward()` dans `_checkBossDefeat()`
5. **XP** : Ajouté automatiquement lors de la complétion des missions

---

## 🎯 Points Clés pour les Développeurs

- ✅ **Toujours utiliser `GameStoryNotifier`** pour modifier l'état
- ✅ **Appeler `notifyListeners()`** après chaque modification (fait automatiquement)
- ✅ **Vérifier `chapter.id`** pour la logique spécifique à chaque story
- ✅ **Utiliser `MissionStatus`** : `locked`, `inProgress`, `completed`
- ✅ **Story Test** : Utilise `WorkoutSessionPage` pour les vrais exercices
- ✅ **Autres Stories** : Utilisent la simulation avec `_addRep()`

---

**Dernière mise à jour** : Après ajout de la Story Test avec Coach Vocal IA
**Version** : 1.0.0














