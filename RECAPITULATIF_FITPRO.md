# 📋 RÉCAPITULATIF COMPLET FITPRO
## Documentation Technique pour l'Équipe de Développement

**Version:** 1.0.0  
**Date:** 2025-01-XX  
**Technologie:** Flutter (Dart 3.9.2)

---

## 📁 STRUCTURE DU PROJET

### Architecture
- **Framework:** Flutter (Material Design 3)
- **State Management:** ChangeNotifier (Pattern Singleton)
- **Navigation:** MaterialPageRoute (Navigation impérative)
- **Stockage:** En mémoire (Notifiers) - Pas de persistance base de données pour l'instant

### Dossiers Principaux
```
lib/
├── main.dart                    # Point d'entrée + Login + Shell principal
├── home_page.dart              # (Non utilisé actuellement)
├── models/                     # 20 modèles de données
├── game_story/                 # Module Sport Gaming Story™
├── chat_match/                 # Module Chat Match™
├── coach_business/             # Module Coach Business Pack™
├── coach_personality/          # Module Coach Personnalité™
├── coach_vs_coach/             # Module Coach VS Coach™
├── transformation_ra/          # Module Transformation Projection™ (en attente)
└── pages/                      # Pages de profil
```

---

## 🔐 AUTHENTIFICATION

### Pages d'Authentification

#### 1. **LoginPage** (`lib/main.dart`)
- **Fichier:** `lib/main.dart` (lignes 72-238)
- **État:** ✅ FONCTIONNE
- **Fonctionnalités:**
  - Formulaire email/password (valeurs pré-remplies: `toi@mail.com` / `••••••••`)
  - Bouton "Se connecter" → Navigation vers `FitProHomeShell`
  - Lien "Mot de passe oublié ?" → Page `ForgotPasswordPage`
  - Lien "Créer un compte" → ❌ **ACTION VIDÉ** (`onPressed: () {}`)

#### 2. **RegisterPage** (`lib/register_page.dart`)
- **État:** ✅ EXISTE mais ❌ **PAS INTÉGRÉE** dans le flux de connexion
- **Navigation:** Non accessible depuis LoginPage

#### 3. **ForgotPasswordPage** (`lib/forgot_password_page.dart`)
- **État:** ✅ EXISTE
- **Navigation:** Accessible depuis LoginPage

---

## 🏠 NAVIGATION PRINCIPALE

### **FitProHomeShell** (`lib/main.dart` lignes 298-402)
- **Type:** Shell avec Bottom Navigation Bar
- **État:** ✅ FONCTIONNE
- **Onglets principaux:** 4 onglets

#### Onglet 1: **Accueil** (DashboardTab)
- **Icône:** `Icons.grid_view_rounded`
- **Label:** "Accueil"
- **Fichier:** `lib/main.dart` (lignes 408-1634)

#### Onglet 2: **Séances** (SessionsTab)
- **Icône:** `Icons.fitness_center`
- **Label:** "Séances"
- **Fichier:** `lib/main.dart` (lignes 1635-1776)

#### Onglet 3: **Nutrition** (NutritionTab)
- **Icône:** `Icons.restaurant_outlined`
- **Label:** "Nutrition"
- **Fichier:** `lib/main.dart` (lignes 1777-2222)

#### Onglet 4: **Coachs** (CoachDirectoryPage)
- **Icône:** `Icons.person_search`
- **Label:** "Coachs"
- **Fichier:** `lib/coach_directory_page.dart`

---

## 📱 PAGES PRINCIPALES PAR ONGLET

### 🔵 ONGLET 1 : ACCUEIL (DashboardTab)

**Fichier:** `lib/main.dart` lignes 408-1634

#### Fonctionnalités Principales:
- ✅ **Statistiques de la semaine**
  - Compteur de séances / objectif
  - Calories du jour / objectif
  - FitPro Score (calcul automatique)
  - Dernière activité affichée

- ✅ **Graphique d'activité hebdomadaire**
  - Graphique en barres (L → D)
  - Navigation vers `StatsPage` pour voir toutes les statistiques

- ✅ **Cartes Hydratation, Protéines, Sommeil**
  - Progression visuelle
  - Liens vers pages d'ajout (`AddWaterPage`, `AddSleepPage`)

- ✅ **Carte Pas (Steps)**
  - Compteur automatique via `sensors_plus`
  - Affichage depuis `StepsNotifier`
  - Lien vers `PedometerPage`

- ✅ **Résumé nutrition du jour**
  - Liste des repas
  - Bouton "+" pour ajouter un repas → `AddMealPage`

- ✅ **Section "Nouveaux Modules"**
  - Cartes cliquables vers les 6 nouveaux modules
  - Voir section "MODULES" ci-dessous

#### Actions Naviguées:
- ✅ `StatsPage` (statistiques détaillées)
- ✅ `AddWaterPage` (ajouter eau)
- ✅ `AddSleepPage` (ajouter sommeil)
- ✅ `AddMealPage` (ajouter repas)
- ✅ `PedometerPage` (compteur de pas)
- ✅ `WorkoutDetailPage` (détails séance) → `WorkoutSessionPage`
- ✅ Tous les nouveaux modules (voir section MODULES)

---

### 🟢 ONGLET 2 : SÉANCES (SessionsTab)

**Fichier:** `lib/main.dart` lignes 1635-1776

#### Fonctionnalités:
- ✅ Liste des programmes d'entraînement
- ✅ Affichage des séances disponibles
- ✅ Navigation vers `WorkoutDetailPage` au clic
- ✅ Filtrage par niveau (Débutant, Intermédiaire, Avancé)
- ✅ Affichage des infos (durée, difficulté, calories)

#### Modèle de données:
- `Workout` (depuis `lib/models/workout_session.dart`)
- `WorkoutHistoryNotifier` pour l'historique

#### Pages liées:
- ✅ `WorkoutDetailPage` → `WorkoutSessionPage` → `WorkoutFinishedPage`
- ✅ `ExerciseDetailPage` (détails d'un exercice)
- ✅ `ExerciseVideoPage` (vidéo d'un exercice)

---

### 🟡 ONGLET 3 : NUTRITION (NutritionTab)

**Fichier:** `lib/main.dart` lignes 1777-2222

#### Fonctionnalités:
- ✅ Liste des repas du jour
- ✅ Affichage calories, protéines, glucides, lipides
- ✅ Bouton "+" pour ajouter un repas → `AddMealPage`
- ✅ Résumé nutritionnel (total du jour)

#### Modèle de données:
- `Nutrition` (depuis `lib/models/nutrition.dart`)
- `NutritionNotifier` pour gérer les repas

#### Pages liées:
- ✅ `AddMealPage` (ajouter un repas)

---

### 🔴 ONGLET 4 : COACHS (CoachDirectoryPage)

**Fichier:** `lib/coach_directory_page.dart`

#### Fonctionnalités:
- ✅ Liste des coachs disponibles
- ✅ Filtres (spécialité, niveau)
- ✅ Navigation vers `CoachDetailPage`
- ✅ Affichage des programmes de chaque coach

#### Modèle de données:
- `Coach` (depuis `lib/models/coach_directory.dart`)
- `CoachDirectoryNotifier`

#### Pages liées:
- ✅ `CoachDetailPage` → `CoachProgramDetailPage`

---

## 👤 PAGE PROFIL (ProfilePage)

**Fichier:** `lib/main.dart` lignes 2228-2660

### Accès:
- Bouton icône personne dans l'AppBar du `FitProHomeShell`

### Sections:

#### 1. **Mon Profil**
- ✅ Avatar avec initiales
- ✅ Nom, email, objectif principal
- ✅ Informations physiques (taille, poids, mensurations)
- ✅ Objectifs (principal, secondaires, échéance)
- ✅ Bouton "Modifier mon profil" → `EditProfilePage`

#### 2. **Évolution**
- ⚠️ **PLACEHOLDER** - "À venir" (courbes de progression, photos avant/après)

#### 3. **Outils Personnels & Coach**
- ✅ Section `PersonalToolsSection` (widget dans `main.dart` lignes 3176-3250)
  - **Coach Alter Ego Futur (démo)** → `FutureSelfAdvancedPage` (Projection de ton moi futur)
  - **Mon Alter Ego (v1)** → `AlterEgoScreen` (Version futuriste simple - démo)
  - **Chat d'entraide communautaire** → `CommunityChatPage` (Discussions entre membres)
  - **Trouver un coach** → `CoachDirectoryPage` (Découvrir des coachs adaptés)
  - **Analyse corporelle avancée** → `BodyCompositionPage` (Suivi détaillé - à venir)

#### 4. **Nouveaux Modules**
- ✅ Section `NewModulesSection` (widget dans `main.dart` lignes 3256-3387)
  - **Chat Match™** (badge BÊTA) → `MatchSwipePage` - Initialise le profil utilisateur pour le matching
  - **Coach Business Pack™** (badge BÊTA) → `CoachBusinessDashboard` - Vendre ses programmes
  - **Sport Gaming Story™** (badge BÊTA) → `StoryHomePage` - Le sport comme un jeu
  - **Coach VS Coach™** (badge BÊTA) → `CoachRankingPage` - Classement des coachs
  - **Transformation Projection™** (badge PREMIUM) → `RAFuturePreviewPage` - Toi en version future
  - **Coach Personnalité™** (badge BÊTA) → `CoachStylePickerPage` - Coach gentil/dur/fun

#### 5. **Mon Offre**
- ✅ Affichage plan actuel (Gratuit / Premium)
- ✅ Bouton "Découvrir FitPro Premium" → `PremiumPage`
- ✅ Modèle: `SubscriptionNotifier`

#### 6. **Mode Coach**
- ✅ Carte "Tu es coach sportif ?"
- ✅ Bouton "Passer en mode coach" → `CoachDashboardPage`

#### 7. **Déconnexion**
- ✅ Bouton "Se déconnecter" → Retour à `LoginPage`

---

## 🎮 MODULES NOUVEAUX (6 modules)

### MODULE 1 : CHAT MATCH™
**Statut:** ✅ v1 FONCTIONNELLE

#### Fichiers:
- `lib/chat_match/match_swipe_page.dart` - Page de swipe
- `lib/chat_match/match_results_page.dart` - Résultats de matching
- `lib/chat_match/match_chat_page.dart` - Chat avec match
- `lib/chat_match/match_engine.dart` - Moteur de matching
- `lib/chat_match/match_profile.dart` - Profil de match
- `lib/chat_match/match_filters.dart` - Filtres

#### Fonctionnalités:
- ✅ Swipe gauche/droite sur profils
- ✅ Algorithme de matching (objectifs, niveau, fréquence)
- ✅ Page de résultats avec matches
- ✅ Chat avec matches (simulé)
- ✅ Filtres (niveau, objectif, fréquence)

#### Navigation:
- Depuis DashboardTab → Carte "Chat Match™"
- Depuis ProfilePage → Section "Nouveaux Modules"

---

### MODULE 2 : COACH BUSINESS PACK™
**Statut:** ✅ v1 FONCTIONNELLE

#### Fichiers:
- `lib/coach_business/business_dashboard.dart` - Tableau de bord coach
- `lib/coach_business/coach_branding_page.dart` - Branding personnalisé
- `lib/coach_business/coach_products_page.dart` - Produits/Programmes vendables

#### Fonctionnalités:
- ✅ Dashboard pour coachs (statistiques clients, revenus)
- ✅ Page de branding (logo, couleurs, présentation)
- ✅ Page de produits (programmes à vendre)
- ✅ Gestion clients → `CoachClientsPage` → `CoachClientDetailPage`
- ✅ Ajout de suivi client → `AddClientProgressPage`
- ✅ Notes client → `EditClientNotesPage`

#### Navigation:
- Depuis CoachDashboardPage → Menu "Business Pack"
- Depuis ProfilePage → Section "Nouveaux Modules"

---

### MODULE 3 : SPORT GAMING STORY™
**Statut:** ✅ v1 FONCTIONNELLE (Boss games implémentés)

#### Fichiers:
- `lib/game_story/story_home.dart` - Accueil du module
- `lib/game_story/story_levels.dart` - Page des niveaux
- `lib/game_story/story_boss.dart` - Page des bosses
- `lib/game_story/story_avatar.dart` - Personnalisation avatar
- `lib/game_story/story_rewards.dart` - Récompenses
- `lib/game_story/boss_squat_game.dart` - **Jeu Squats interactif** ✅
- `lib/game_story/boss_hiit_game.dart` - **Jeu HIIT interactif** ✅
- `lib/game_story/boss_plank_game.dart` - **Jeu Plank interactif** ✅

#### Fonctionnalités:
- ✅ Système de niveaux (Level 1, 2, 3...)
- ✅ **3 Boss Games interactifs:**
  - **Boss Squats:** Compteur en temps réel, objectif 100 squats, vibration
  - **Boss HIIT:** Timer work/rest cycles, objectif 20 minutes, vibration
  - **Boss Plank:** Sessions multiples, timer par session, objectif 3 séances, vibration
- ✅ Système XP/Level (affiché, calculé via `GameStoryNotifier`)
- ✅ Avatar personnalisable
- ✅ Récompenses
- ⚠️ **Quêtes journalières:** Modèle existe mais pas d'interface dédiée
- ⚠️ **Scénarios animés:** Non implémentés

#### Modèle de données:
- `GameStory` (depuis `lib/models/game_story.dart`)
- `GameStoryNotifier` (singleton)
- `GameBoss` avec `targetValue` et `targetUnit`

#### Navigation:
- Depuis DashboardTab → Carte "Sport Gaming Story™"
- Depuis ProfilePage → Section "Nouveaux Modules"
- Navigation interne: Home → Levels → Boss → Jeu

---

### MODULE 4 : COACH VS COACH™
**Statut:** ✅ v1 FONCTIONNELLE

#### Fichiers:
- `lib/coach_vs_coach/coach_ranking_page.dart` - Classement des coachs
- `lib/coach_vs_coach/duel_coach_page.dart` - Page de duel
- `lib/coach_vs_coach/duel_coach_engine.dart` - Moteur de duel

#### Fonctionnalités:
- ✅ Classement des coachs (top coachs)
- ✅ Système de duel entre coachs
- ✅ Comparaison de statistiques
- ✅ Points/réputation coach

#### Navigation:
- Depuis ProfilePage → Section "Nouveaux Modules"
- Depuis CoachDashboardPage → Menu "Coach VS Coach"

---

### MODULE 5 : COACH PERSONNALITÉ™
**Statut:** ✅ v1 FONCTIONNELLE

#### Fichiers:
- `lib/coach_personality/coach_style_picker.dart` - Page de sélection style
- `lib/coach_personality/coach_voice_engine.dart` - Moteur de synthèse vocale
- `lib/coach_personality/coach_messages.dart` - Messages de motivation

#### Fonctionnalités:
- ✅ 4 styles de coach:
  - **Gentil** (voix douce, bienveillante)
  - **Dur** (voix forte, exigeante)
  - **Militaire** (voix autoritaire, disciplinée)
  - **Humour** (voix décontractée, fun)
- ✅ **Synthèse vocale** (flutter_tts):
  - Configuration voix par style (rate, pitch, volume)
  - Messages de motivation personnalisés
  - Bouton écouter/arrêter la voix
- ✅ Message du jour selon style sélectionné
- ✅ Persistance du style choisi (via `CoachPersonalityNotifier`)

#### Packages utilisés:
- `flutter_tts: ^4.1.0` - Synthèse vocale
- ⚠️ **Correction récente:** Remplacement de `isSpeaking` (inexistant) par booléen local `_isCurrentlySpeaking`

#### Navigation:
- Depuis ProfilePage → Section "Nouveaux Modules"

---

### MODULE 6 : TRANSFORMATION PROJECTION™
**Statut:** ⚠️ **EN ATTENTE** (Page simple avec slider seulement)

#### Fichiers:
- `lib/transformation_ra/ra_future_preview.dart` - Page de prévisualisation

#### Fonctionnalités:
- ⚠️ **v1 Simple:** Page avec slider pour voir transformation
- ⚠️ **v2 Future:** AR avec caméra (non implémenté)
- ⚠️ **Badge:** PREMIUM (nécessite abonnement)

#### Navigation:
- Depuis ProfilePage → Section "Nouveaux Modules"

---

## 📊 PAGES SECONDAIRES

### Statistiques & Suivi

#### **StatsPage** (`lib/stats_page.dart`)
- ✅ Statistiques détaillées
- ✅ Graphiques de progression
- ✅ Historique des séances
- Navigation: Depuis DashboardTab → "Voir toutes mes statistiques"

#### **BodyCompositionPage** (`lib/body_composition_page.dart`)
- ✅ Suivi composition corporelle
- ✅ Historique poids, taille, mensurations
- ✅ Graphiques de progression
- Navigation: Depuis ProfilePage → "Composition corporelle"

#### **PlanningPage** (`lib/planning_page.dart`)
- ✅ Planning d'entraînement
- ✅ Calendrier des séances
- Navigation: Depuis ProfilePage → "Planning"

#### **PedometerPage** (`lib/pedometer_page.dart`)
- ✅ Page dédiée au compteur de pas
- ✅ Historique des pas
- ✅ Utilise `sensors_plus` pour comptage automatique
- Navigation: Depuis DashboardTab → Carte "Pas"

---

### Entraînements

#### **WorkoutDetailPage** (`lib/main.dart` lignes 2881-3100)
- ✅ Détails d'un programme d'entraînement
- ✅ Liste des exercices
- ✅ Bouton "Commencer la séance" → `WorkoutSessionPage`

#### **WorkoutSessionPage** (`lib/workout_session_page.dart`)
- ✅ Séance en cours
- ✅ Timer par exercice
- ✅ Navigation entre exercices
- ✅ Bouton "Terminer" → `WorkoutFinishedPage`

#### **WorkoutFinishedPage** (`lib/workout_finished_page.dart`)
- ✅ Page de fin de séance
- ✅ Résumé (calories, durée)
- ✅ Enregistrement dans l'historique

#### **ExerciseDetailPage** (`lib/exercise_detail_page.dart`)
- ✅ Détails d'un exercice
- ✅ Instructions, muscles sollicités
- ✅ Lien vers vidéo → `ExerciseVideoPage`

#### **ExerciseVideoPage** (`lib/exercise_video_page.dart`)
- ⚠️ Placeholder pour vidéo d'exercice

---

### Nutrition & Objectifs

#### **AddMealPage** (`lib/add_meal_page.dart`)
- ✅ Formulaire pour ajouter un repas
- ✅ Champs: nom, calories, protéines, glucides, lipides
- ✅ Enregistrement via `NutritionNotifier`

#### **AddWaterPage** (`lib/add_water_page.dart`)
- ✅ Ajouter de l'eau consommée
- ✅ Progression vers objectif quotidien
- ✅ Utilise `DailyGoalsNotifier`

#### **AddSleepPage** (`lib/add_sleep_page.dart`)
- ✅ Enregistrer une nuit de sommeil
- ✅ Durée, qualité du sommeil
- ✅ Utilise `DailyGoalsNotifier`

#### **AddStepsPage** (`lib/add_steps_page.dart`)
- ✅ Ajouter des pas manuellement (si nécessaire)
- ⚠️ Normalement géré automatiquement par `StepsNotifier`

---

### Coach & Clients

#### **CoachDashboardPage** (`lib/coach_dashboard_page.dart`)
- ✅ Dashboard principal pour coachs
- ✅ Statistiques clients
- ✅ Accès aux modules coach (Business Pack, VS Coach)
- Navigation: Depuis ProfilePage → "Passer en mode coach"

#### **CoachClientsPage** (`lib/coach_clients_page.dart`)
- ✅ Liste des clients
- ✅ Navigation vers détail client

#### **CoachClientDetailPage** (`lib/coach_client_detail_page.dart`)
- ✅ Détails d'un client
- ✅ Historique de progression
- ✅ Notes client → `EditClientNotesPage`
- ✅ Ajouter progression → `AddClientProgressPage`

#### **CoachDetailPage** (`lib/coach_detail_page.dart`)
- ✅ Profil d'un coach (vue client)
- ✅ Programmes proposés → `CoachProgramDetailPage`

#### **CoachProgramDetailPage** (`lib/coach_program_detail_page.dart`)
- ✅ Détails d'un programme de coach
- ✅ Possibilité de s'abonner/acheter

---

### Premium & Abonnement

#### **PremiumPage** (`lib/premium_page.dart`)
- ✅ Page d'abonnement FitPro Premium
- ✅ Avantages Premium
- ✅ Boutons d'achat (simulés)
- Navigation: Depuis ProfilePage → "Découvrir FitPro Premium"

---

### Autres Outils

#### **FutureSelfAdvancedPage** (`lib/future_self_advanced_page.dart`)
- ✅ Visualisation "Coach Alter Ego Futur"
- ✅ Projection de ton moi futur (démo)
- Navigation: Depuis ProfilePage → "Coach Alter Ego Futur (démo)"

#### **AlterEgoScreen** (`lib/alter_ego.dart`)
- ✅ Création d'alter ego
- ⚠️ Version futuriste simple (démo)
- Navigation: Depuis ProfilePage → "Mon Alter Ego (v1)"

#### **AlterEgoDuel** (`lib/alter_ego_duel.dart`)
- ⚠️ Duel d'alter ego (non implémenté)

#### **CommunityChatPage** (`lib/community_chat_page.dart`)
- ✅ Chat d'entraide communautaire
- ✅ Discussions entre membres sur nutrition et entraînement
- Navigation: Depuis ProfilePage → "Chat d'entraide communautaire"

#### **ChatPage** (`lib/chat_page.dart`)
- ✅ Chat individuel (utilisé dans Chat Match™)

---

## 🗄️ MODÈLES DE DONNÉES (20 modèles)

**Dossier:** `lib/models/`

1. ✅ **user_profile.dart** - Profil utilisateur
2. ✅ **workout_session.dart** - Séances d'entraînement
3. ✅ **workout_history.dart** - Historique des séances
4. ✅ **nutrition.dart** - Données nutritionnelles
5. ✅ **goals.dart** - Objectifs quotidiens (eau, protéines, sommeil)
6. ✅ **steps.dart** - Compteur de pas
7. ✅ **coach_directory.dart** - Annuaire des coachs
8. ✅ **coach_programs.dart** - Programmes de coachs
9. ✅ **subscription.dart** - Abonnements
10. ✅ **body_composition.dart** - Composition corporelle
11. ✅ **planning.dart** - Planning d'entraînement
12. ✅ **rooms.dart** - Salles d'entraînement
13. ✅ **chat.dart** - Messages de chat
14. ✅ **community_chat.dart** - Chat communautaire
15. ✅ **client_tracking.dart** - Suivi clients (coach)
16. ✅ **game_story.dart** - Sport Gaming Story (niveaux, bosses, XP)
17. ✅ **coach_personality.dart** - Styles de coach
18. ✅ **coach_vs_coach.dart** - Système de duel coachs
19. ✅ **coach_business.dart** - Business coach (branding, produits)
20. ✅ **future_self_advanced.dart** - Futur moi

**Pattern:** Chaque modèle a son `Notifier` (ChangeNotifier) en singleton pour la gestion d'état.

---

## 📦 DEPENDANCES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  pedometer: ^4.0.0              # Compteur de pas
  sensors_plus: ^4.0.0           # Accéléromètre (pour comptage automatique)
  flutter_tts: ^4.1.0            # Synthèse vocale (Coach Personnalité™)
  vibration: ^1.8.4              # Vibration (Boss Games)
```

---

## ✅ FONCTIONNALITÉS OPÉRATIONNELLES

### Entièrement Fonctionnelles:
- ✅ Authentification (login)
- ✅ Navigation principale (4 onglets)
- ✅ Dashboard avec statistiques
- ✅ Gestion des séances d'entraînement
- ✅ Gestion nutrition
- ✅ Compteur de pas (automatique via sensors_plus)
- ✅ Suivi hydratation, protéines, sommeil
- ✅ Profil utilisateur
- ✅ Annuaire coachs
- ✅ Statistiques détaillées
- ✅ Composition corporelle
- ✅ Planning
- ✅ Chat Match™ (v1)
- ✅ Coach Business Pack™ (v1)
- ✅ Sport Gaming Story™ (v1 - Boss games fonctionnels)
- ✅ Coach VS Coach™ (v1)
- ✅ Coach Personnalité™ (v1 - synthèse vocale)
- ✅ Transformation Projection™ (v1 simple - slider seulement)
- ✅ Mode Coach (dashboard coach)
- ✅ Gestion clients (coach)
- ✅ Premium (page d'abonnement)

---

## ❌ FONCTIONNALITÉS NON FONCTIONNELLES / INCOMPLÈTES

### Actions manquantes:
1. ❌ **Créer un compte** - Bouton dans LoginPage mais `onPressed: () {}` vide
2. ⚠️ **Persistance des données** - Tout est en mémoire (Notifiers), pas de base de données
3. ⚠️ **Vidéos d'exercices** - `ExerciseVideoPage` existe mais placeholder seulement
4. ⚠️ **Quêtes journalières** - Modèle existe dans `GameStory` mais pas d'interface dédiée
5. ⚠️ **Scénarios animés** - Non implémentés dans Sport Gaming Story™
6. ⚠️ **AR avec caméra** - Non implémenté dans Transformation Projection™ (v2 future)
7. ⚠️ **Alter Ego Duel** - Page existe mais fonctionnalité limitée
8. ⚠️ **Évolution (photos avant/après)** - Placeholder dans ProfilePage

### Bugs Connus:
- ⚠️ **fluter_tts.isSpeaking** - Corrigé récemment (remplacé par booléen local `_isCurrentlySpeaking`)

---

## 🔧 ARCHITECTURE TECHNIQUE

### State Management:
- **Pattern:** ChangeNotifier (Provider-like mais sans package Provider)
- **Singletons:** Tous les Notifiers sont des singletons (factory pattern)
- **Exemples:**
  - `UserProfileNotifier()` - Profil utilisateur
  - `WorkoutHistoryNotifier()` - Historique séances
  - `NutritionNotifier()` - Nutrition
  - `DailyGoalsNotifier()` - Objectifs quotidiens
  - `StepsNotifier()` - Compteur de pas
  - `GameStoryNotifier()` - Sport Gaming Story
  - `CoachPersonalityNotifier()` - Style de coach
  - Etc.

### Navigation:
- **Type:** Navigation impérative (pas de routes nommées)
- **Pattern:** `Navigator.of(context).push(MaterialPageRoute(...))`
- **Retour:** `Navigator.pop(context)`

### Thème:
- **Couleurs principales:**
  - Primaire: `Color(0xFF111111)` (noir)
  - Secondaire: `Color(0xFFFFC300)` (jaune)
  - Background: `Color(0xFFF4F4F4)` (gris clair)
- **Police:** Roboto (par défaut Material)

---

## 🎯 POINTS D'ATTENTION POUR L'ÉQUIPE

### À Développer:
1. **Persistance des données:**
   - Intégrer une base de données (SQLite/Hive) ou backend
   - Sauvegarder les données des Notifiers

2. **Authentification réelle:**
   - Intégrer Firebase Auth ou backend
   - Implémenter le flux "Créer un compte"

3. **Vidéos d'exercices:**
   - Intégrer un lecteur vidéo
   - Stocker/charger les vidéos

4. **Quêtes journalières:**
   - Créer une interface dédiée dans Sport Gaming Story™
   - Intégrer avec le système XP

5. **Transformation Projection™ v2:**
   - Intégrer AR (camera + overlays)
   - Utiliser package AR (ex: `ar_flutter_plugin`)

### À Optimiser:
1. **Performance:**
   - Optimiser les listeners (éviter rebuilds inutiles)
   - Pagination des listes longues

2. **UX:**
   - Ajouter des animations de transition
   - Feedback utilisateur (snackbars, dialogs)

3. **Code:**
   - Extraire `main.dart` (très long: 3390 lignes)
   - Créer des fichiers séparés pour chaque tab/page
   - Utiliser des routes nommées pour la navigation

---

## 📝 NOTES IMPORTANTES

### Fichiers Volumineux:
- `lib/main.dart` - **3390 lignes** (à refactoriser)
  - Contient: LoginPage, FitProHomeShell, DashboardTab, SessionsTab, NutritionTab, ProfilePage, WorkoutDetailPage, widgets réutilisables

### Fichiers Non Utilisés:
- `lib/home_page.dart` - Existe mais n'est pas utilisé (DashboardTab est utilisé à la place)

### Structure de Projet:
- Pas de séparation claire entre "pages" et "widgets"
- Certains widgets sont dans `main.dart` au lieu de fichiers séparés

---

## 🚀 COMMANDES UTILES

### Lancer l'application:
```bash
flutter run -d chrome    # Web
flutter run              # Dernier device utilisé
```

### Vérifier les dépendances:
```bash
flutter pub get
flutter pub outdated
```

### Analyser le code:
```bash
flutter analyze
```

---

## 📞 CONTACTS & SUPPORT

**Documentation créée pour:** Équipe de développement FitPro  
**Date de dernière mise à jour:** 2025-01-XX  
**Version de Flutter:** Dernière stable (voir `flutter --version`)

---

**FIN DU RÉCAPITULATIF**

