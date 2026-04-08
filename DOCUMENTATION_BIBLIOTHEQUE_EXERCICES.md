# 📚 Documentation Complète - Bibliothèque d'Exercices FitPro

## 🎯 Vue d'ensemble

La **Bibliothèque d'exercices** est le module central de suivi d'entraînement de FitPro. Elle permet aux utilisateurs de gérer leurs exercices, créer des programmes d'entraînement, enregistrer des séances, et suivre leur progression avec des statistiques détaillées.

**Accès** : Via l'onglet "Avancé" → "Bibliothèque d'exercices" (mode Freemium/Premium)

---

## 📱 Structure de la Page Principale

### Architecture
- **Fichier principal** : `lib/exercises/exercise_library_page.dart`
- **Design** : Thème sombre iOS/Apple Fitness (`#121212` background, `#1A1A1A` AppBar)
- **Navigation** : 4 onglets avec `TabBar` et `TabBarView` (swipeable)

### Les 4 Onglets

#### 1️⃣ **Onglet "Exercices"**
- **Widget** : `ExercisesTabWidget` (`lib/exercises/exercises_tab_widget.dart`)
- **Fonctionnalités** :
  - ✅ Liste de **111 exercices prédéfinis** (depuis `default_exercises_library.dart`)
  - ✅ **Exercices personnalisés** créés par l'utilisateur
  - ✅ **Recherche en temps réel** (nom, description, muscles)
  - ✅ **Groupement par catégories musculaires** :
    - Abdominaux
    - Biceps
    - Triceps
    - Pectoraux
    - Épaules / Deltoïdes
    - Dos
    - Jambes
    - Fessiers
    - Mollets
    - Autres / Cardio / Gainage
  - ✅ **Affichage adaptatif** :
    - Mobile : Liste verticale
    - Tablette/Desktop : Grille 2-3 colonnes (responsive)
  - ✅ **Cartes compactes** avec :
    - Avatar circulaire de l'exercice (icône stylisée)
    - Nom abrégé (initiales pour noms longs)
    - Groupe musculaire
    - Statistiques rapides (poids max, reps max, dernière performance)
    - Badge de difficulté ressentie moyenne (1-10)
    - Indicateur Premium (cadenas si non acheté)
  - ✅ **FAB** : Bouton "+ Ajouter un exercice" (jaune FitPro)

#### 2️⃣ **Onglet "Mes Programmes"**
- **Widget** : `MyWorkoutProgramsPage` (`lib/workout/my_workout_programs_page.dart`)
- **Fonctionnalités** :
  - ✅ Liste de tous les programmes créés
  - ✅ **Carte de programme** avec :
    - Badge coloré circulaire (lettre initiale)
    - Nom du programme (ex: "Fullbody - 3 jours")
    - Objectif (ex: "Prise de volume sur 3 séances par semaine")
    - Icônes d'édition et réorganisation
  - ✅ **État vide** : Message + FAB "Nouveau programme"
  - ✅ **Actions** :
    - Créer un nouveau programme (FAB)
    - Voir les détails (tap sur carte)
    - Éditer (icône crayon)
    - Supprimer (swipe ou menu)
  - ✅ **FAB** : Bouton "Nouveau programme" (noir)

#### 3️⃣ **Onglet "Mes Séances"**
- **Widget** : `MyWorkoutSessionsPage` (`lib/workout/my_workout_sessions_page.dart`)
- **Fonctionnalités** :
  - ✅ Liste chronologique de toutes les séances enregistrées
  - ✅ **Barre de recherche** : "Rechercher une séance…"
  - ✅ **Carte de séance** avec :
    - Date formatée (ex: "Lundi 27 novembre 2025")
    - Nom/type de séance
    - Programme associé (si applicable)
    - Indicateur de difficulté (flamme ou jauge)
    - Durée totale
    - Nombre d'exercices
  - ✅ **État vide** : Message + FAB "Nouvelle séance"
  - ✅ **Actions** :
    - Créer une nouvelle séance (FAB)
    - Voir les détails (tap sur carte)
    - Supprimer (swipe ou menu)
  - ✅ **FAB** : Bouton "Nouvelle séance" (noir)

#### 4️⃣ **Onglet "Photothèque" / "Historique"**
- **Widget** : `WorkoutHistoryCalendarPage` (`lib/workout/workout_history_calendar_page.dart`)
- **Fonctionnalités** :
  - ✅ **Calendrier mensuel** personnalisé (fond sombre)
  - ✅ **Filtres temporels** : "Années" | "Mois" | "Toutes"
  - ✅ **Jour sélectionné** : Surligné en bleu
  - ✅ **Section "Carnet du JJ/MM/AAAA"** :
    - Liste des exercices effectués ce jour
    - Récapitulatif rapide (ex: "Tractions pronation : 12x10kg, 12x10kg, 12x10kg, 12x8kg")
    - Dernière difficulté ressentie pour chaque exercice (badge 1-10)
  - ✅ **Bouton "Partager"** : Partage de la séance du jour
  - ✅ **Navigation** : Mois précédent/suivant

---

## 🏋️ Page "Détail d'un Exercice"

### Accès
- Tap sur un exercice dans l'onglet "Exercices"
- Tap sur un exercice dans une séance détaillée

### Fichier
- `lib/exercises/exercise_detail_pro_page.dart`

### Structure

#### **En-tête**
- ✅ Icône circulaire de l'exercice (grand format)
- ✅ Nom de l'exercice (grand, gras, blanc)
- ✅ Objectif de l'exercice (ex: "Objectif 4 x max reps - repos 1'30"")

#### **Section Résumé** (si séries existantes)
- ✅ Bloc résumé avec :
  - Date (ex: "27/11 2025")
  - Total répétitions
  - Total volume (kg)
  - Nombre de séries

#### **Liste des Séries**
- ✅ **Carte de série** (`_SetCard`) avec :
  - Numéro de série (ex: "Série 1")
  - Détails :
    - Mode Répétitions : "12 reps x 10 kg"
    - Mode Temps : "01:30" (durée)
  - Badge "⭐" si série marquée comme "meilleure"
  - Temps de repos associé (si défini)

#### **Section Difficulté Ressentie**
- ✅ Slider ou sélecteur 1-10
- ✅ Titre : "Difficulté ressentie pour cette séance"
- ✅ Sauvegarde automatique dans l'historique

#### **Barre d'Action Inférieure (Bottom Bar)**
- ✅ **Chronomètres de repos actifs** :
  - Liste horizontale de `WorkoutTimer` (un par série avec repos)
  - Affichage : "01:30" avec Play/Pause/Reset
  - Lancement automatique après validation d'une série
- ✅ **Sélecteur de temps de repos** :
  - Boutons rapides : 00:30, 01:00, 01:30, 02:00, etc.
  - Icône paramètres (roue dentée) pour modifier les presets
- ✅ **Bouton "+ Ajouter une série"** (grand, bleu)

#### **Actions Disponibles**
- ✅ **Icône paramètres** (engrenage) :
  - Modifier le temps de repos
  - Modifier le type d'exercice
  - Modifier l'objectif (réps cibles, max reps, etc.)
- ✅ **Icône statistiques** (graphique) :
  - Ouvre `ExerciseStatsPage` avec stats et graphiques

---

## ➕ Modal "Ajouter une Série"

### Fichier
- `lib/exercises/exercise_series_dialog.dart`

### Fonctionnalités

#### **Toggle Mode**
- ✅ **Mode "Répétitions / Charge"** (par défaut) :
  - Clavier numérique 1-9 + 0
  - Boutons de charge : 2.5, 5, 10, 15, 20, 25, 30, 40, 50 kg
  - Bouton "PDC" (Poids du Corps)
  - Affichage : "12 reps" + "10 kg"
- ✅ **Mode "Temps (chrono)"** :
  - Grand chronomètre (00:00)
  - Boutons Start/Pause/Reset
  - Enregistrement de la durée en secondes
  - Bouton "Enregistrer la série" (désactivé si durée = 0)

#### **Fonctionnalités Communes**
- ✅ **Bouton étoile** : Marquer comme "meilleure série"
- ✅ **Section "Temps de repos"** :
  - Sélecteur de presets (30s, 45s, 60s, 90s, 120s)
  - Sélection multiple possible
- ✅ **Bouton "Valider la série"** :
  - Désactivé si reps = 0 (mode répétitions) ou durée = 0 (mode temps)
  - Arrête le chrono automatiquement en mode temps
  - Sauvegarde dans la base de données

#### **Copie Automatique**
- ✅ Les valeurs de la série précédente sont pré-remplies :
  - Répétitions précédentes
  - Charge précédente
  - Durée précédente (mode temps)

---

## 📊 Page "Statistiques d'un Exercice"

### Accès
- Icône graphique dans `ExerciseDetailProPage`

### Fichier
- `lib/exercises/exercise_stats_page.dart`

### Structure

#### **Onglets**
- ✅ **Onglet "Statistiques"** (texte)
- ✅ **Onglet "Graphiques"** (visualisation)

#### **Onglet Statistiques**
- ✅ **Carte principale** :
  - Nom de l'exercice (grand, gras)
  - Icône de l'exercice (grand format)
- ✅ **Cartes de statistiques** :
  - **Moyenne** : Répétitions moyennes, Poids moyen
  - **Meilleure performance (poids)** : Charge max + date
  - **Meilleure performance (réps)** : Répétitions max + date
  - **Meilleure performance (temps)** : Durée max (si mode temps utilisé)
  - **Temps moyen** : Durée moyenne (si mode temps utilisé)
  - **Dernière séance** : Date + détails

#### **Onglet Graphiques**
- ✅ **Graphique en ligne** (`CustomPainter`) :
  - **Axe Y** : Poids (kg) ou Répétitions
  - **Axe X** : Dates (jours du mois)
  - **Lignes** :
    - Ligne bleue : Évolution du poids
    - Ligne orange : Évolution des répétitions
  - **Points** : Marqueurs pour chaque séance
  - **Légende** : Couleurs et labels

---

## 📝 Création d'un Exercice Personnalisé

### Accès
- FAB "+ Ajouter un exercice" dans l'onglet "Exercices"

### Fichier
- `lib/exercises/create_exercise_page.dart`

### Formulaire

#### **Section "Informations de base"**
- ✅ Nom de l'exercice* (obligatoire, min 3 caractères)
- ✅ Catégorie* (dropdown) :
  - Pectoraux, Dos, Épaules, Biceps, Triceps, Jambes, Fessiers, Mollets, Abdominaux, Cardio, Full body, Autre
- ✅ Niveau* (dropdown) :
  - Débutant, Intermédiaire, Avancé

#### **Section "Muscles sollicités"**
- ✅ **Muscles principaux*** (multi-sélection) :
  - Widget `MuscleMultiSelectField`
  - Liste prédéfinie de 20 muscles
  - Dialog avec checkboxes
  - Affichage en chips avec suppression
- ✅ **Muscles secondaires** (multi-sélection) :
  - Même système que muscles principaux

#### **Section "Description"**
- ✅ Description courte* (obligatoire)
- ✅ Étapes d'exécution (multi-lignes)

#### **Section "Matériel & options"**
- ✅ Matériel utilisé (texte libre)
- ✅ Switch "Exercice unilatéral" (un côté à la fois)
- ✅ Conseils / sécurité (multi-lignes)

#### **Sauvegarde**
- ✅ Validation du formulaire
- ✅ Enregistrement dans `UserExercisesNotifier`
- ✅ Badge "Perso" visible dans la liste

---

## 🏋️ Création d'un Programme d'Entraînement

### Accès
- FAB "Nouveau programme" dans l'onglet "Mes Programmes"

### Fichier
- `lib/workout/workout_program_edit_page.dart`

### Formulaire

#### **Informations Générales**
- ✅ Nom du programme* (ex: "Fullbody - 3 jours")
- ✅ Objectif* (ex: "Prise de volume sur 3 séances par semaine")
- ✅ Nombre de séances par semaine* (nombre)
- ✅ Couleur du programme* :
  - Ligne de "pills" colorées (rouge, bleu, vert, orange, violet, etc.)
  - Sélection d'une couleur pour le badge

#### **Jours d'Entraînement**
- ✅ Liste des jours (ex: "Jour 1 - Pectoraux/Biceps")
- ✅ **Ajouter un jour** :
  - Dialog moderne (fond sombre iOS)
  - Nom du jour* (ex: "Jour 1")
  - Description (ex: "Pectoraux/Biceps")
- ✅ **Éditer un jour** : Même dialog
- ✅ **Supprimer un jour** : Swipe ou menu

#### **Exercices d'un Jour**
- ✅ Liste des exercices du jour
- ✅ **Ajouter un exercice** :
  - Ouvre `ExerciseLibraryPage` en mode sélection
  - Retourne l'exercice sélectionné
- ✅ **Objectif de l'exercice** (tap sur exercice) :
  - Dialog moderne (fond sombre iOS)
  - Nombre de séries* (ex: 4)
  - Nombre de répétitions* (ex: 12) ou "Max reps" (checkbox)
  - Temps de repos* (secondes, ex: 90)
  - Indicateur visuel (cercle coloré) selon l'objectif

#### **Sauvegarde**
- ✅ Validation du formulaire
- ✅ Enregistrement dans `WorkoutSessionStorage`
- ✅ Retour à la liste des programmes

---

## 🎬 Enregistrement d'une Séance

### Accès
- FAB "Nouvelle séance" dans l'onglet "Mes Séances"
- Depuis un programme : "Démarrer le jour X"

### Fichier
- `lib/workout/workout_session_recording_page.dart`

### Fonctionnalités

#### **En-tête**
- ✅ **Chronomètre global de séance** :
  - Affichage : "00:00:00" (heures:minutes:secondes)
  - Démarre automatiquement au début
  - Continue pendant toute la séance

#### **Liste des Exercices**
- ✅ **Ajouter un exercice** :
  - Ouvre `ExerciseLibraryPage` en mode sélection
  - Retourne l'exercice sélectionné
- ✅ **Carte d'exercice** avec :
  - Nom de l'exercice
  - Icône de l'exercice
  - Liste des séries enregistrées
  - Bouton "+ Ajouter une série"
  - Bouton "Voir détails" (ouvre `ExerciseDetailProPage`)

#### **Ajout de Série**
- ✅ Ouvre `ExerciseSeriesDialog`
- ✅ Mode Répétitions ou Temps
- ✅ Validation → Série ajoutée à l'exercice

#### **Barre d'Action Inférieure**
- ✅ **Bouton "Terminer la séance"** :
  - Dialog de confirmation moderne (fond clair, boutons stylisés)
  - Options : "Annuler" (outline) / "Terminer" (rouge, rempli)
- ✅ **Bouton "Quitter la séance"** :
  - Dialog de confirmation moderne
  - Options : "Annuler" / "Quitter" (rouge)

#### **Sauvegarde**
- ✅ Création d'un `WorkoutSession` avec :
  - `id` unique
  - `startTime` (début)
  - `completedAt` (fin, si terminée)
  - `exercises` (liste de `ExercisePerformance`)
  - `programId` (si issue d'un programme)
- ✅ Enregistrement dans `WorkoutSessionStorage`
- ✅ Retour à la liste avec rafraîchissement

---

## 📄 Détail d'une Séance

### Accès
- Tap sur une carte dans "Mes Séances"

### Fichier
- `lib/workout/workout_session_detail_page.dart`

### Structure

#### **En-tête (SliverAppBar)**
- ✅ **Titre** : "Séance du DD MMM" (ex: "Séance du 27 nov")
- ✅ **Fond dégradé** : Bleu → Violet
- ✅ **Chips d'information** :
  - 🕐 Heure début - fin
  - ⏱️ Durée totale
  - 🏋️ Nombre d'exercices

#### **Liste des Exercices**
- ✅ **Carte d'exercice** (`_ExercisePerformanceCard`) :
  - **Bandeau coloré** en haut (couleur selon groupe musculaire)
  - **En-tête** :
    - Icône de l'exercice (avatar circulaire)
    - Nom de l'exercice (grand, gras)
    - Badge de difficulté (ex: "7/10") si disponible
  - **Liste des séries** :
    - Format : "Série 1 : 12 reps x 10 kg"
    - Format temps : "Série 1 : 01:30"
    - Badge étoile ⭐ si meilleure série
  - **Chips de statistiques** :
    - Volume total (kg)
    - Poids max (kg)
    - Meilleur temps (si applicable)
    - Temps moyen (si applicable)
  - ✅ **Tap sur carte** : Ouvre `ExerciseDetailProPage` pour cet exercice

---

## 🗄️ Modèles de Données

### `ExerciseLibraryItem`
```dart
- id: String
- name: String
- category: String
- muscleGroup: String
- equipment: String
- isBodyweight: bool
- muscles: List<String>
- secondaryMuscles: List<String>?
- difficulty: ExerciseDifficulty
- description: String
- steps: List<String>?
- isPremium: bool
- packId: String?
- isUserCreated: bool
- isShared: bool
```

### `WorkoutProgram`
```dart
- id: String
- name: String
- objective: String
- sessionsPerWeek: int
- color: Color
- days: List<ProgramDay>
```

### `ProgramDay`
```dart
- id: String
- name: String
- description: String?
- exercises: List<ProgramExercise>
```

### `ProgramExercise`
```dart
- exerciseId: String
- targetSets: int
- targetReps: int?
- isMaxReps: bool
- restSeconds: int
```

### `WorkoutSession`
```dart
- id: String
- startTime: DateTime
- completedAt: DateTime?
- programId: String?
- exercises: List<ExercisePerformance>
```

### `ExercisePerformance`
```dart
- exerciseId: String
- sets: List<ExerciseSet>
- difficulty: int? (1-10)
- startedAt: DateTime?
- completedAt: DateTime?
```

### `ExerciseSet`
```dart
- id: String
- reps: int?
- weight: double?
- isBodyweight: bool
- type: SetType (reps, time, mixed)
- durationSeconds: int?
- restSeconds: int?
- isBestSet: bool
- completedAt: DateTime?
```

### `SetType` (enum)
```dart
enum SetType {
  reps,    // Mode répétitions/charge
  time,    // Mode temps (gainage, etc.)
  mixed,   // Mixte (futur)
}
```

### `DifficultyEntry`
```dart
- exerciseId: String
- date: DateTime
- level: int (1-10)
- sessionId: String?
```

---

## 💾 Persistance des Données

### Stockage
- **Fichier** : `lib/models/workout_session_storage.dart`
- **Méthode** : `shared_preferences` (JSON)

### Méthodes Disponibles

#### **Sessions**
- ✅ `saveSession(WorkoutSession)` : Enregistre une séance
- ✅ `getAllSessions()` : Récupère toutes les séances
- ✅ `getSession(String id)` : Récupère une séance par ID
- ✅ `deleteSession(String id)` : Supprime une séance
- ✅ `getExercisePerformances(String exerciseId)` : Récupère toutes les performances d'un exercice
- ✅ `getExerciseHistory(String exerciseId)` : Historique complet d'un exercice

#### **Programmes**
- ✅ `saveProgram(WorkoutProgram)` : Enregistre un programme
- ✅ `getAllPrograms()` : Récupère tous les programmes
- ✅ `getProgram(String id)` : Récupère un programme par ID
- ✅ `deleteProgram(String id)` : Supprime un programme

#### **Difficultés**
- ✅ `DifficultyService().save(DifficultyEntry)` : Enregistre une difficulté
- ✅ `DifficultyService().getByExercise(String exerciseId)` : Récupère les difficultés d'un exercice

---

## ⏱️ Système de Chronomètres

### Types de Chronomètres

#### 1. **Chronomètre Global de Séance**
- **Emplacement** : `WorkoutSessionRecordingPage` (en-tête)
- **Fonction** : Compte le temps total de la séance
- **Format** : "00:00:00" (heures:minutes:secondes)
- **Comportement** : Démarre automatiquement, continue jusqu'à la fin

#### 2. **Chronomètres de Repos**
- **Emplacement** : `ExerciseDetailProPage` (bottom bar)
- **Fonction** : Compte à rebours pour le repos entre séries
- **Format** : "01:30" (minutes:secondes)
- **Presets** : 30s, 45s, 60s, 90s, 120s, 150s, 180s, 240s, 300s
- **Comportement** :
  - Lancement automatique après validation d'une série
  - Plusieurs chronos simultanés possibles (un par série)
  - Notification + vibration à 0
  - Message : "Prêt pour la prochaine série 💪"

#### 3. **Chronomètre de Série (Mode Temps)**
- **Emplacement** : `ExerciseSeriesDialog` (mode temps)
- **Fonction** : Mesure la durée d'une série (gainage, etc.)
- **Format** : "00:00" (minutes:secondes)
- **Comportement** :
  - Mode stopwatch (compte à la hausse)
  - Boutons Start/Pause/Reset
  - Enregistrement de la durée en secondes

### Widget Réutilisable
- **Fichier** : `lib/widgets/workout_timer.dart`
- **Modes** :
  - `TimerMode.stopwatch` : Compte à la hausse
  - `TimerMode.countdown` : Compte à rebours
- **Paramètres** :
  - `initialDuration` : Durée initiale
  - `onFinish` : Callback à la fin
  - `label` : Label optionnel ("repos", "effort", etc.)
  - `showControls` : Afficher/masquer les boutons Play/Pause/Reset

---

## 🎨 Design & Thème

### Couleurs
- **Fond principal** : `#121212` (noir iOS)
- **AppBar** : `#1A1A1A` (gris très foncé)
- **Accent** : `#FFC300` (jaune FitPro)
- **Texte principal** : `Colors.white`
- **Texte secondaire** : `Colors.white.withOpacity(0.6)`

### Typographie
- **Titres** : `FontWeight.w700`, `fontSize: 20-24`
- **Sous-titres** : `FontWeight.w600`, `fontSize: 16-18`
- **Corps** : `FontWeight.w500`, `fontSize: 14-16`
- **Labels** : `FontWeight.w500`, `fontSize: 12-13`

### Composants UI
- **Cartes** : `BorderRadius.circular(16-20)`, ombre légère
- **Boutons** : `BorderRadius.circular(12-14)`, padding généreux
- **Dialogs** : Fond sombre, coins arrondis, boutons stylisés
- **Avatars** : Cercles avec icônes colorées selon groupe musculaire

---

## 🔧 Composants Réutilisables

### `ExerciseIconHelper`
- **Fichier** : `lib/components/exercise_icon_helper.dart`
- **Fonctions** :
  - `getColorForMuscleGroup(String)` : Couleur selon groupe
  - `getIconForMuscleGroup(String)` : Icône selon groupe
  - `buildMuscleGroupAvatar(String, {size})` : Avatar de groupe
  - `buildExerciseAvatar(String, String, {size})` : Avatar d'exercice

### `RestTimerWidget`
- **Fichier** : `lib/components/rest_timer_widget.dart`
- **Fonction** : Sélecteur de temps de repos avec presets
- **Paramètres** :
  - `selectedRestTimes` : Liste des temps sélectionnés
  - `onRestTimeSelected` : Callback de sélection
  - `onSettingsPressed` : Callback pour paramètres

### `DifficultyForm`
- **Fichier** : `lib/components/difficulty_form.dart`
- **Fonction** : Formulaire d'évaluation de difficulté (1-10)
- **Intégration** : Dans `ExerciseDetailProPage`

### `MuscleMultiSelectField`
- **Fichier** : `lib/components/muscle_multi_select_field.dart`
- **Fonction** : Sélection multiple de muscles depuis liste prédéfinie
- **Intégration** : Dans `CreateExercisePage`

---

## 📦 Bibliothèque d'Exercices Prédéfinis

### Fichier
- `lib/data/default_exercises_library.dart`

### Contenu
- ✅ **111 exercices** organisés par groupe musculaire
- ✅ **Champs pour chaque exercice** :
  - `id` : Identifiant unique
  - `name` : Nom de l'exercice
  - `muscleGroup` : Groupe musculaire principal
  - `equipment` : Matériel nécessaire
  - `isBodyweight` : Exercice au poids du corps
  - `isPremium` : Exercice premium (verrouillé)
  - `category` : Catégorie (Pectoraux, Dos, etc.)
  - `difficulty` : Niveau (Débutant, Intermédiaire, Avancé)
  - `description` : Description courte
  - `steps` : Étapes d'exécution
  - `muscles` : Liste des muscles travaillés

### Groupes Musculaires
1. Abdominaux (7 exercices)
2. Biceps (8 exercices)
3. Triceps (7 exercices)
4. Pectoraux (12 exercices)
5. Épaules (10 exercices)
6. Dos (15 exercices)
7. Jambes (18 exercices)
8. Fessiers (8 exercices)
9. Mollets (6 exercices)
10. Autres / Cardio / Gainage (20 exercices)

---

## 🚀 Flux Utilisateur Typiques

### 1. Créer un Programme
1. Onglet "Mes Programmes" → FAB "Nouveau programme"
2. Remplir nom, objectif, séances/semaine, couleur
3. Ajouter des jours (ex: "Jour 1 - Pectoraux/Biceps")
4. Pour chaque jour, ajouter des exercices (sélection depuis bibliothèque)
5. Définir objectifs pour chaque exercice (séries, réps, repos)
6. Sauvegarder

### 2. Démarrer une Séance depuis un Programme
1. Onglet "Mes Programmes" → Tap sur programme
2. Tap sur "Démarrer le Jour 1"
3. Séance démarre avec exercices pré-remplis
4. Pour chaque exercice :
   - Ajouter des séries (modal)
   - Choisir mode Répétitions ou Temps
   - Valider → Chrono de repos démarre automatiquement
5. Terminer la séance → Sauvegarde automatique

### 3. Créer une Séance Libre
1. Onglet "Mes Séances" → FAB "Nouvelle séance"
2. Ajouter des exercices manuellement (sélection depuis bibliothèque)
3. Enregistrer des séries pour chaque exercice
4. Terminer la séance

### 4. Consulter les Statistiques
1. Onglet "Exercices" → Tap sur un exercice
2. Page détail → Icône statistiques (graphique)
3. Onglet "Statistiques" : Voir moyennes, meilleures performances
4. Onglet "Graphiques" : Voir évolution poids/réps sur graphique

### 5. Consulter l'Historique
1. Onglet "Photothèque"
2. Sélectionner une date dans le calendrier
3. Voir "Carnet du JJ/MM/AAAA" avec tous les exercices du jour
4. Tap sur un exercice → Page détail avec séries du jour

---

## ✅ Fonctionnalités Implémentées

### ✅ Core
- [x] Bibliothèque de 111 exercices prédéfinis
- [x] Création d'exercices personnalisés
- [x] Recherche et filtrage d'exercices
- [x] Groupement par catégories musculaires
- [x] Affichage responsive (mobile/tablette/desktop)

### ✅ Programmes
- [x] Création de programmes d'entraînement
- [x] Jours d'entraînement avec exercices
- [x] Objectifs par exercice (séries, réps, repos)
- [x] Couleurs personnalisables
- [x] Édition et suppression

### ✅ Séances
- [x] Enregistrement de séances
- [x] Séries avec répétitions/charge
- [x] Séries avec temps (chrono)
- [x] Chronomètre global de séance
- [x] Chronomètres de repos multiples
- [x] Difficulté ressentie (1-10)
- [x] Marquage de "meilleure série"

### ✅ Statistiques
- [x] Statistiques par exercice (moyennes, max)
- [x] Graphiques d'évolution (poids, réps, temps)
- [x] Historique complet
- [x] Calendrier avec séances par date

### ✅ UI/UX
- [x] Design sombre iOS/Apple Fitness
- [x] Navigation par onglets swipeable
- [x] Cartes compactes et lisibles
- [x] Dialogs modernes et stylisés
- [x] Feedback visuel (badges, couleurs)
- [x] États vides avec messages clairs

---

## 🔮 Fonctionnalités Futures (Non Implémentées)

### ⏳ À Prévoir
- [ ] Partage de programmes entre utilisateurs
- [ ] Export/Import de données (JSON, CSV)
- [ ] Notifications de repos (push notifications)
- [ ] Synchronisation cloud (Supabase/Firestore)
- [ ] Photos de progression par exercice
- [ ] Vidéos d'exécution intégrées
- [ ] Suggestions d'exercices basées sur l'historique
- [ ] Détection de "séries anormales" (difficulté trop élevée)
- [ ] Mode "Chrono libre" (page dédiée)
- [ ] Mode HIIT avec intervalles

---

## 📝 Notes Techniques

### Dépendances
- `shared_preferences` : Persistance locale
- `intl` : Formatage de dates
- `provider` : Gestion d'état (pour `UserExercisesNotifier`)

### Architecture
- **Modèles** : `lib/models/`
- **Pages** : `lib/exercises/`, `lib/workout/`
- **Composants** : `lib/components/`
- **Services** : `lib/services/`
- **Données** : `lib/data/`

### Performance
- Chargement asynchrone des données
- `FutureBuilder` pour les stats en temps réel
- `ListView.builder` pour les listes longues
- Mise en cache des exercices prédéfinis

---

## 🎯 Points Clés pour l'Équipe

1. **Toujours utiliser la bibliothèque prédéfinie** : Les utilisateurs ne doivent jamais saisir librement le nom d'un exercice. Toujours sélectionner depuis `DefaultExercisesLibrary.allExercises` ou `UserExercisesNotifier.userExercises`.

2. **Persistance** : Toutes les données sont sauvegardées localement via `WorkoutSessionStorage` et `DifficultyService`. Pas de backend pour l'instant.

3. **Design cohérent** : Respecter le thème sombre iOS (`#121212`, `#1A1A1A`, jaune `#FFC300`).

4. **Chronomètres multiples** : Le système supporte plusieurs chronos de repos simultanés (un par série). Gérer avec `Map<int, int>` (setNumber → restTimeSeconds).

5. **Modes de série** : Toujours proposer les deux modes (Répétitions et Temps) dans `ExerciseSeriesDialog`.

6. **Responsive** : Tester sur mobile, tablette et desktop. Utiliser `LayoutBuilder` pour adapter l'affichage.

---

**Documentation générée le** : 2025-01-XX  
**Version** : 1.0  
**Auteur** : Équipe FitPro











