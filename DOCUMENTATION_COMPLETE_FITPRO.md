# 📚 DOCUMENTATION COMPLÈTE FITPRO
## Guide Exhaustif pour l'Équipe de Développement

**Version:** 1.0.0  
**Date:** 2025-01-XX  
**Technologie:** Flutter (Dart 3.9.2)  
**Objectif:** Documenter chaque page, chaque bouton, chaque fonctionnalité de l'application FitPro

---

## 📋 TABLE DES MATIÈRES

1. [Écran de Démarrage](#1-écran-de-démarrage)
2. [Authentification](#2-authentification)
3. [Navigation Principale](#3-navigation-principale)
4. [Onglet Accueil (Dashboard)](#4-onglet-accueil-dashboard)
5. [Onglet Séances](#5-onglet-séances)
6. [Onglet Nutrition](#6-onglet-nutrition)
7. [Onglet Avancé (Espace Pro)](#7-onglet-avancé-espace-pro)
8. [Onglet Coachs](#8-onglet-coachs)
9. [Page Profil](#9-page-profil)
10. [Modules Premium](#10-modules-premium)
11. [Fonctionnalités Avancées](#11-fonctionnalités-avancées)
12. [Architecture Technique](#12-architecture-technique)

---

## 1. ÉCRAN DE DÉMARrage

### **SplashScreen** (`lib/splash_screen.dart`)

**Objectif:** Écran d'accueil animé au lancement de l'application

**Fonctionnalités:**
- Animation du logo FitPro (kangourou boxeur)
  - Position repliée (0-1.5s) → Coup de poing droit (1.5-3s)
  - Effets de fade in, scale et translation
- Affichage du texte "FITPRO" avec animation
- Redirection automatique vers `LoginPage` après 3 secondes

**Boutons/Actions:**
- Aucun bouton interactif (écran automatique)

**Navigation:**
- Automatique vers `LoginPage` après l'animation

---

## 2. AUTHENTIFICATION

### **LoginPage** (`lib/main.dart` lignes 158-525)

**Objectif:** Page de connexion à l'application

**Éléments de l'interface:**

1. **Logo FitPro**
   - Image du logo centré en haut
   - Taille: 100x100 pixels
   - Ombre portée avec effet de profondeur

2. **Titre "FitPro"**
   - Style: gras, 36px
   - Badge: "Coaching sportif personnalisé"

3. **Carte de connexion (fond blanc)**
   - **Champ Email**
     - Label: "Email"
     - Icône: `Icons.mail_outline`
     - Valeur pré-remplie: `toi@mail.com` (démo)
     - Type clavier: email
   
   - **Champ Mot de passe**
     - Label: "Mot de passe"
     - Icône: `Icons.lock_outline`
     - Valeur pré-remplie: `••••••••` (démo)
     - Type: texte masqué
   
   - **Lien "Mot de passe oublié ?"**
     - Position: aligné à droite sous le champ mot de passe
     - Action: Navigation vers `ForgotPasswordPage`
   
   - **Bouton "Se connecter"**
     - Style: fond jaune (`Color(0xFFFFC300)`), texte noir
     - Largeur: pleine largeur
     - Hauteur: 54px
     - État de chargement: affiche un `CircularProgressIndicator` pendant la connexion
     - Action: Connexion (simulée) puis navigation vers `FitProHomeShell`

4. **Lien "Créer un compte"**
   - Position: sous la carte de connexion
   - Action: Navigation vers `SignupRolePage`

**Navigation:**
- `ForgotPasswordPage` (lien mot de passe oublié)
- `SignupRolePage` (lien créer un compte)
- `FitProHomeShell` (après connexion réussie)

---

### **SignupRolePage** (`lib/auth/signup_role_page.dart`)

**Objectif:** Choix du type de compte (Client ou Coach)

**Éléments:**

1. **Logo FitPro** (icône fitness_center dans un carré jaune)

2. **Titre:** "Bienvenue sur FitPro"

3. **Sous-titre:** "Choisissez votre profil pour commencer"

4. **Bouton "Je suis Client"**
   - Icône: `Icons.person_outline`
   - Description: "Suivre mes entraînements"
   - Action: Navigation vers `SignupClientPage`

5. **Bouton "Je suis Coach"**
   - Icône: `Icons.sports_martial_arts`
   - Description: "Proposer mes services"
   - Action: Navigation vers `SignupCoachPage`

6. **Lien "Se connecter"**
   - Retour vers `LoginPage`

**Navigation:**
- `SignupClientPage` (bouton client)
- `SignupCoachPage` (bouton coach)
- `LoginPage` (lien retour)

---

### **SignupClientPage** (`lib/auth/signup_client_page.dart`)

**Objectif:** Formulaire d'inscription pour un client

**Fonctionnalités:**
- Formulaire complet avec champs:
  - Nom, prénom
  - Email, mot de passe
  - Date de naissance
  - Objectifs sportifs
  - Niveau actuel
- Validation des champs
- Bouton "Créer mon compte" → Navigation vers `FitProHomeShell`

---

### **SignupCoachPage** (`lib/auth/signup_coach_page.dart`)

**Objectif:** Formulaire d'inscription pour un coach

**Fonctionnalités:**
- Formulaire avec:
  - Informations personnelles
  - Diplômes/certifications
  - Spécialités
  - Tarifs
- Bouton "Créer mon compte coach" → Navigation vers `CoachDashboardPage`

---

### **ForgotPasswordPage** (`lib/forgot_password_page.dart`)

**Objectif:** Réinitialisation du mot de passe

**Fonctionnalités:**
- Champ email
- Bouton "Envoyer le lien de réinitialisation"
- Message: "Si un compte existe pour cet email, un lien a été envoyé (fictif)"

---

## 3. NAVIGATION PRINCIPALE

### **FitProHomeShell** (`lib/main.dart` lignes 531-658)

**Objectif:** Shell principal avec navigation par onglets en bas

**Structure:**

1. **AppBar (Barre supérieure)**
   - Fond: Marron foncé (`_marronFonce`)
   - Titre: "FitPro" (centré)
   - **Bouton Chat** (à droite): `ChatBubbleHeaderButton`
     - Icône bulle de chat
     - Action: Ouvre le chat Alter Ego
   - **Bouton Profil** (à droite): `Icons.person_outline`
     - Action: Navigation vers `ProfilePage`

2. **Body (Corps principal)**
   - `IndexedStack` contenant les 5 onglets:
     1. `DashboardTab` (Accueil)
     2. `SessionsTab` (Séances)
     3. `NutritionTab` (Nutrition)
     4. `EspaceProScreen` (Avancé)
     5. `CoachDirectoryPage` (Coachs)
   - **Alter Ego Flottant** (`AlterEgoFloatingWidget`)
     - Widget flottant persistant sur tous les écrans
     - Position: configurable (topRight par défaut sur Dashboard)

3. **BottomNavigationBar (Barre de navigation inférieure)**
   - 5 onglets:
     - **Accueil** (`Icons.grid_view_rounded`)
     - **Séances** (`Icons.fitness_center`)
     - **Nutrition** (`Icons.restaurant_outlined`)
     - **Avancé** (`Icons.settings_applications_rounded`)
     - **Coachs** (`Icons.person_search`)
   - Couleur sélectionnée: Violet (`_violetPrincipal`)
   - Couleur non sélectionnée: Gris

**Navigation:**
- Changement d'onglet via `setState` (pas de navigation, juste changement d'index)
- `ProfilePage` (bouton profil)

---

## 4. ONGLET ACCUEIL (DASHBOARD)

### **DashboardTab** (`lib/main.dart` lignes 664-2346)

**Objectif:** Tableau de bord principal avec toutes les statistiques et objectifs

**Sections (de haut en bas):**

#### **4.1. En-tête**
- **Titre:** "Ton Défi de la Semaine"
- **Sous-titre:** "Mes Objectifs Personnels"
- **Bouton Parrainage** (à droite): `ParrainageButton`
  - Icône kangourou avec gants de boxe
  - Texte: "Parrainer & Gagner"
  - Action: Navigation vers `ParrainagePage`

#### **4.2. Grille 2x2 d'Objectifs**

**Carte 1: Objectif Séances** (Haut-Gauche)
- **Fond:** Dégradé violet (`_violetPrincipal` → `_violetClair`)
- **Icône:** Deux haltères croisées
- **Titre:** "Objectif séances"
- **Valeur:** "X/3" (séances de la semaine / objectif)
- **Sous-titre:** "cette semaine"
- **Barre de progression:** Horizontale, violette
- **Message:** "Bien joué, continue !" ou message selon progression
- **Action:** Clic → Navigation vers `StatsPage`

**Carte 2: Hydratation** (Haut-Droite)
- **Fond:** Dégradé marron clair
- **Icône:** Goutte d'eau (`Icons.water_drop_rounded`)
- **Titre:** "Hydratation"
- **Valeur:** "X.X / 2.0 litres"
- **Barre de progression:** Horizontale, marron
- **Message:** "Hydrate-toi encore 💧" ou "Objectif atteint 👌"
- **Action:** Clic → Navigation vers `AddWaterPage`

**Carte 3: Objectif Calories** (Bas-Gauche)
- **Fond:** Dégradé marron
- **Icône:** Flamme (`Icons.local_fire_department_rounded`)
- **Titre:** "Objectif calories"
- **Valeur:** "0 / 2000 kcal"
- **Barre de progression:** Horizontale, marron
- **Message:** "Pas encore de repas enregistrés." ou statut selon calories
- **Action:** Clic → Navigation vers `SimpleNutritionPage`

**Carte 4: Nutrition** (Bas-Droite)
- **Fond:** Dégradé rose/violet
- **Icône:** `Icons.restaurant_menu_rounded` (représentant nutrition)
- **Titre:** "Nutrition"
- **Valeur:** "X / 116 grammes" (protéines) ou résumé nutritionnel
- **Barre de progression:** Horizontale, couleur selon statut
- **Message:** "En dessous", "Presque là 💪" ou "Objectif atteint ✅"
- **Action:** Clic → Navigation vers `SimpleNutritionPage`

#### **4.3. Section "Activité de la semaine"**
- **Titre:** "Activité de la semaine"
- **Icône:** `Icons.trending_up_rounded` (violet)
- **Bouton "Voir toutes mes statistiques"** (à droite)
  - Icône: `Icons.insights`
  - Action: Navigation vers `StatsPage`
- **Graphique hebdomadaire:**
  - 7 barres verticales (L, M, M, J, V, S, D)
  - Hauteur proportionnelle au nombre de séances par jour
  - Couleur: Violet si séances, gris si aucune
- **Label:** "Nombre de séances par jour (L → D)"

#### **4.4. Section "Distance / Pas du jour"**
- **Titre:** "Distance / Pas du jour"
- **Icône:** `Icons.directions_walk_rounded` (marron)
- **Carte Pas:**
  - **Cercle de progression:** 80x80 pixels
    - Progression circulaire animée
    - Valeur au centre: nombre de pas
    - Objectif: 8000 pas
  - **Message:** "On se met en mouvement 🚶‍♀️", "Tu es en bonne voie 👌" ou "Objectif atteint 🎉"
  - **Action:** Clic → Navigation vers `PedometerPage`

#### **4.5. Section "Sommeil"**
- **Titre:** "Sommeil"
- **Icône:** `Icons.bedtime_rounded` (violet)
- **Carte Sommeil:**
  - **Titre:** "Sommeil – Dernière nuit"
  - **Valeur:** "XhXX / 7.0h" (durée / objectif)
  - **Barre de progression:** Horizontale, violette
  - **Bouton "Ajouter mon sommeil"**
    - Icône: `Icons.bedtime_outlined`
    - Action: Navigation vers `AddSleepPage`
  - **État vide:** "Aucun sommeil renseigné" + "Objectif : 7.0h"

#### **4.6. Section "Nutrition aujourd'hui"**
- **Titre:** "Nutrition aujourd'hui"
- **Icône:** `Icons.restaurant_menu_rounded` (marron)
- **Carte Nutrition:**
  - **Icône flamme** (marron)
  - **Titre:** "Calories du jour"
  - **Valeur:** "X kcal"
  - **Sous-section "Derniers repas":**
    - Liste des 3 derniers repas (ou "Aucun repas ajouté pour aujourd'hui.")
    - Format: "Type : Nom – X kcal"
  - **Bouton "+"** (flottant en bas à droite)
    - Action: Navigation vers `AddMealPage`
  - **Action:** Clic sur la carte → Navigation vers `SimpleNutritionPage`

#### **4.7. Section "Nouveaux Modules"** (si présente)
- Cartes cliquables vers les modules premium/bêta
- Voir section [Modules Premium](#10-modules-premium)

**Données affichées:**
- `WorkoutHistoryNotifier`: Historique des séances
- `NutritionNotifier`: Repas du jour
- `DailyGoalsNotifier`: Objectifs eau, protéines, sommeil
- `StepsNotifier`: Compteur de pas (automatique via `sensors_plus`)

**Calculs automatiques:**
- **FitPro Score:** Calculé selon:
  - Séances (50 points max)
  - Nutrition (30 points max)
  - Bonus hydratation (+10 si objectif atteint)
  - Bonus protéines (+10 si objectif atteint)
  - Bonus sommeil (+10 si dernière nuit dans l'objectif)
  - Total: 0-100 points

---

## 5. ONGLET SÉANCES

### **SessionsTab** (`lib/main.dart` lignes 2578-3100)

**Objectif:** Liste des programmes d'entraînement disponibles

**Palette de couleurs:** Marron et Vert (polices noires)

**Sections:**

#### **5.1. Bannière "Séances de la semaine"**
- **Fond:** Marron clair (`_marronClairSeances`)
- **Icône:** Calendrier vert (`Icons.calendar_today`)
- **Titre:** "Séances de la semaine"
- **Description:** "Voir toutes tes séances (passées et à venir)"
- **Icône chevron:** Flèche droite (noire)
- **Action:** Clic → Navigation vers `WeeklySessionsPage`

#### **5.2. Liste des Programmes**

**Carte Programme** (`_WorkoutListCard`)
- **Fond:** Marron clair (`_marronClairSeances`)
- **Image placeholder:** Carré gris avec icône play (blanc)
- **Titre:** Nom du programme (ex: "Programme débutant - 3 séances")
- **Sous-titre:** "Entraînement guidé • X-Y min"
- **Badge "Vidéo":**
  - Fond: Vert foncé (`_vertFonceSeances`)
  - Texte: "Vidéo" (noir)
  - Icône: `Icons.videocam`
- **Lien "Voir":**
  - Texte: "Voir" (vert foncé)
  - Action: Navigation vers `WorkoutDetailPage`

**Filtres disponibles:**
- **Niveau:** Débutant, Intermédiaire, Avancé
- **Objectif:** Perte de poids, Prise de masse, Cardio, etc.
- **Matériel:** Avec/sans matériel

**Programmes par défaut:**
1. "Programme débutant - 3 séances" (40-45 min)
2. "Full body sans matériel" (35-45 min)
3. "Bas du corps - Renfo" (45-45 min)

**Navigation:**
- `WorkoutDetailPage` (clic sur "Voir")
- `WeeklySessionsPage` (clic sur bannière)

---

### **WorkoutDetailPage** (`lib/main.dart` lignes 2881-3100)

**Objectif:** Détails d'un programme d'entraînement

**Éléments:**

1. **Image/Placeholder** du programme

2. **Informations:**
   - Titre
   - Durée
   - Difficulté
   - Objectif
   - Matériel requis
   - Calories estimées
   - Pas estimés

3. **Liste des exercices:**
   - Nom de l'exercice
   - Durée/séries
   - Icône play

4. **Bouton "Commencer la séance"**
   - Style: Grand bouton vert
   - Action: Navigation vers `WorkoutSessionPage`

**Navigation:**
- `WorkoutSessionPage` (bouton commencer)

---

### **WorkoutSessionPage** (`lib/workout_session_page.dart`)

**Objectif:** Séance d'entraînement en cours

**Fonctionnalités:**
- **Timer par exercice:** Compte à rebours
- **Exercice actuel:** Affichage nom, instructions
- **Navigation:** Boutons précédent/suivant
- **Pause:** Bouton pause/reprendre
- **Terminer:** Bouton pour terminer la séance

**Navigation:**
- `WorkoutFinishedPage` (après séance terminée)

---

### **WorkoutFinishedPage** (`lib/workout_finished_page.dart`)

**Objectif:** Résumé de la séance terminée

**Éléments:**
- **Résumé:**
  - Durée totale
  - Calories brûlées
  - Pas effectués
- **Message de félicitations**
- **Bouton "Retour à l'accueil"**
- **Enregistrement:** La séance est enregistrée dans `WorkoutHistoryNotifier`

---

## 6. ONGLET NUTRITION

### **NutritionTab** (`lib/main.dart` lignes 1777-2222)

**Objectif:** Suivi nutritionnel quotidien

**Palette de couleurs:** Marron et Jaune

**Sections:**

#### **6.1. Résumé du jour**
- **Calories totales:** "X / 2000 kcal"
- **Macronutriments:**
  - Protéines: "X g"
  - Glucides: "X g"
  - Lipides: "X g"
- **Barres de progression** pour chaque macro

#### **6.2. Liste des repas**
- **Repas du jour** triés par heure
- **Carte Repas** (`_MealCard`):
  - **Icône:** Fond marron foncé, icône jaune
  - **Type:** Petit-déjeuner, Déjeuner, Dîner, Collation
  - **Nom:** Nom du repas
  - **Calories:** "X kcal"
  - **Macros:** Protéines, Glucides, Lipides
  - **Action:** Clic pour voir détails (si implémenté)

#### **6.3. Bouton "+"**
- **Position:** Flottant en bas à droite
- **Style:** Cercle jaune avec icône plus
- **Action:** Navigation vers `AddMealPage`

**Navigation:**
- `AddMealPage` (bouton +)
- `SimpleNutritionPage` (clic sur résumé)

---

### **AddMealPage** (`lib/add_meal_page.dart`)

**Objectif:** Ajouter un repas

**Formulaire:**
- **Type de repas:** Dropdown (Petit-déjeuner, Déjeuner, Dîner, Collation)
- **Nom du repas:** Champ texte
- **Calories:** Champ numérique
- **Protéines:** Champ numérique (grammes)
- **Glucides:** Champ numérique (grammes)
- **Lipides:** Champ numérique (grammes)

**Boutons:**
- **"Annuler":** Retour à la page précédente
- **"Enregistrer":** Enregistre le repas via `NutritionNotifier` et retour

---

### **SimpleNutritionPage** (`lib/pages/simple_nutrition_page.dart`)

**Objectif:** Vue détaillée de la nutrition

**Fonctionnalités:**
- Graphiques de progression
- Historique des repas
- Statistiques hebdomadaires
- Objectifs personnalisés

---

## 7. ONGLET AVANCÉ (ESPACE PRO)

### **EspaceProScreen** (`lib/espace_pro_screen.dart`)

**Objectif:** Hub centralisé pour toutes les fonctionnalités avancées/premium

**Palette de couleurs:** Marron et Bleu

**Sections (de haut en bas):**

#### **7.1. BLOC 1 : IA PREMIUM**

**En-tête de catégorie:**
- **Titre:** "IA Premium"
- **Icône:** `Icons.auto_awesome_rounded` (bleu)
- **Description:** "Fonctionnalités avancées avec Intelligence Artificielle"

**Tiles disponibles:**

1. **Coach IA Premium**
   - **Description:** Coach virtuel avec IA avancée
   - **Badge:** PREMIUM
   - **Action:** Navigation vers `CoachIAPremiumPage`

2. **Transformation Projection (IA)**
   - **Description:** Visualisation de ton futur moi
   - **Badge:** PREMIUM
   - **Action:** Navigation vers `RAFuturePreviewPage`

3. **Coach Vocal IA**
   - **Description:** Coach avec synthèse vocale
   - **Badge:** BÊTA
   - **Action:** Navigation vers `CoachPersonalityPage`

4. **FoodScan IA**
   - **Description:** Analyse nutritionnelle par photo
   - **Badge:** BÊTA
   - **Action:** Navigation vers `FoodScanHomePage`

---

#### **7.2. BLOC 2 : Abonnements & Achats**

**En-tête:**
- **Titre:** "Abonnements & Achats"
- **Icône:** `Icons.payment_rounded` (marron clair)

**Tiles:**

1. **Les offres**
   - **Description:** Voir les offres Premium
   - **Action:** Navigation vers `PremiumPage`

2. **Mes achats FitPro**
   - **Description:** Historique des achats
   - **Action:** Navigation vers `MyPurchasesPage`

---

#### **7.3. BLOC 3 : Séances & Vidéos**

**En-tête:**
- **Titre:** "Séances & Vidéos"
- **Icône:** `Icons.fitness_center_rounded` (bleu)

**Tiles:**

1. **Cours Collectifs Live**
   - **Description:** Rejoindre des cours en direct
   - **Action:** Navigation vers `GroupClassLive`

2. **Replays de cours**
   - **Description:** Voir les cours enregistrés
   - **Action:** Navigation vers `GroupClassReplays`

3. **Pack Vidéos**
   - **Description:** Bibliothèque de vidéos d'entraînement
   - **Action:** Navigation vers `VideoPacksPage`

4. **Full Body**
   - **Description:** Séances complètes
   - **Action:** Navigation vers séance Full Body

---

#### **7.4. BLOC 4 : Freemium**

**En-tête:**
- **Titre:** "Freemium"
- **Icône:** `Icons.workspace_premium_outlined` (marron)

**Tiles:**

1. **Coach Alter Ego Futur**
   - **Description:** Projection de ton moi futur
   - **Action:** Navigation vers `FutureSelfAdvancedPage`

2. **Mon Alter Ego (v1)**
   - **Description:** Version simple de l'Alter Ego
   - **Action:** Navigation vers `AlterEgoScreen`

3. **Chat d'entraide communautaire**
   - **Description:** Discussions entre membres
   - **Action:** Navigation vers `CommunityChatPage`

4. **Trouver un coach**
   - **Description:** Annuaire des coachs
   - **Action:** Navigation vers `CoachDirectoryPage`

5. **Analyse corporelle avancée**
   - **Description:** Suivi détaillé de la composition corporelle
   - **Action:** Navigation vers `BodyCompositionPage`

---

#### **7.5. BLOC 5 : Nouveaux Modules (Bêta)**

**En-tête:**
- **Titre:** "Nouveaux Modules"
- **Icône:** `Icons.new_releases_rounded` (bleu clair)
- **Description:** "Fonctionnalités en version bêta"

**Tiles:**

1. **Chat Match™**
   - **Badge:** BÊTA
   - **Description:** Trouve des partenaires d'entraînement
   - **Action:** Navigation vers `MatchHomePage`

2. **Coach Business Pack™**
   - **Badge:** BÊTA
   - **Description:** Vendre ses programmes
   - **Action:** Navigation vers `CoachBusinessDashboard`

3. **Sport Gaming Story™**
   - **Badge:** BÊTA
   - **Description:** Le sport comme un jeu
   - **Action:** Navigation vers `StoryHomePage`

4. **Coach VS Coach™**
   - **Badge:** BÊTA
   - **Description:** Classement des coachs
   - **Action:** Navigation vers `CoachRankingPage`

5. **Transformation Projection™**
   - **Badge:** PREMIUM
   - **Description:** Toi en version future
   - **Action:** Navigation vers `RAFuturePreviewPage`

6. **Coach Personnalité™**
   - **Badge:** BÊTA
   - **Description:** Coach gentil/dur/fun
   - **Action:** Navigation vers `CoachStylePickerPage`

---

## 8. ONGLET COACHS

### **CoachDirectoryPage** (`lib/coach_directory_page.dart`)

**Objectif:** Annuaire des coachs sportifs disponibles

**Palette de couleurs:** Marron (différentes nuances)

**Sections:**

#### **8.1. Barre de recherche**
- **Champ de recherche:**
  - Placeholder: "Rechercher par nom ou spécialité..."
  - Icône: `Icons.search`
  - Filtre en temps réel

#### **8.2. Filtres**
- **Ville:** Dropdown avec toutes les villes disponibles
- **Spécialité:** Dropdown avec toutes les spécialités
- **Niveau:** Dropdown (Débutant, Intermédiaire, Avancé)

#### **8.3. Liste des coachs**

**Carte Coach:**
- **Photo de profil:** Avatar du coach
- **Nom:** Nom complet
- **Spécialité:** Liste des spécialités
- **Ville:** Ville du coach
- **Note:** Étoiles (ex: ★★★★☆ 4.5)
- **Prix:** "À partir de X€/séance"
- **Badge "Disponible":** Si le coach est disponible maintenant
- **Action:** Clic → Navigation vers `CoachDetailPage`

**Navigation:**
- `CoachDetailPage` (clic sur une carte coach)

---

### **CoachDetailPage** (`lib/coach_detail_page.dart`)

**Objectif:** Profil détaillé d'un coach

**Sections:**

1. **En-tête:**
   - Photo de profil (grande)
   - Nom
   - Spécialités
   - Note et nombre d'avis

2. **Description:**
   - Bio du coach
   - Expérience
   - Diplômes/certifications

3. **Programmes disponibles:**
   - Liste des programmes proposés
   - Prix, durée, objectif
   - **Action:** Clic → Navigation vers `CoachProgramDetailPage`

4. **Avis clients:**
   - Liste des avis avec notes
   - Photos (si disponibles)

5. **Boutons d'action:**
   - **"Contacter":** Ouvre le chat (`ChatPage`)
   - **"Réserver une séance":** Navigation vers `CoachAppointmentPage`
   - **"Voir tous les programmes":** Navigation vers liste complète

**Navigation:**
- `CoachProgramDetailPage` (programme)
- `ChatPage` (contacter)
- `CoachAppointmentPage` (réserver)

---

### **CoachProgramDetailPage** (`lib/coach_program_detail_page.dart`)

**Objectif:** Détails d'un programme de coach

**Éléments:**
- Description complète
- Durée, fréquence
- Objectifs
- Prix
- **Bouton "Acheter":** Navigation vers page de paiement

---

## 9. PAGE PROFIL

### **ProfilePage** (`lib/main.dart` lignes 2228-2660)

**Objectif:** Profil utilisateur et paramètres

**Accès:** Bouton icône personne dans l'AppBar du `FitProHomeShell`

**Sections:**

#### **9.1. Mon Profil**

**En-tête:**
- **Avatar:** Cercle avec initiales (ou photo si uploadée)
- **Nom:** Nom complet
- **Email:** Adresse email

**Informations:**
- **Objectif principal:** Ex: "Perte de poids"
- **Objectifs secondaires:** Liste
- **Échéance:** Date objectif

**Informations physiques:**
- **Taille:** X cm
- **Poids:** X kg
- **Mensurations:** (si renseignées)

**Bouton "Modifier mon profil":**
- Action: Navigation vers `EditProfilePage`

---

#### **9.2. Évolution**

**État actuel:** ⚠️ **PLACEHOLDER**
- Texte: "À venir"
- Description: "Courbes de progression, photos avant/après"

**Fonctionnalités prévues:**
- Graphiques de progression (poids, mensurations, IMC)
- Photos avant/après avec timeline
- Comparaison de périodes

---

#### **9.3. Outils Personnels & Coach**

**Tiles:**

1. **Coach Alter Ego Futur (démo)**
   - Action: `FutureSelfAdvancedPage`

2. **Mon Alter Ego (v1)**
   - Action: `AlterEgoScreen`

3. **Chat d'entraide communautaire**
   - Action: `CommunityChatPage`

4. **Trouver un coach**
   - Action: `CoachDirectoryPage`

5. **Analyse corporelle avancée**
   - Action: `BodyCompositionPage`

---

#### **9.4. Nouveaux Modules**

**Tiles identiques à EspaceProScreen (section 7.5)**

---

#### **9.5. Mon Offre**

**Affichage:**
- **Plan actuel:** "Gratuit" ou "Premium"
- **Date d'expiration:** (si Premium)
- **Bouton "Découvrir FitPro Premium":**
  - Action: Navigation vers `PremiumPage`

---

#### **9.6. Mode Coach**

**Carte:**
- **Titre:** "Tu es coach sportif ?"
- **Description:** "Passe en mode coach pour gérer tes clients"
- **Bouton "Passer en mode coach":**
  - Action: Navigation vers `CoachDashboardPage`

---

#### **9.7. Déconnexion**

**Bouton "Se déconnecter":**
- Style: Rouge
- Action: Retour à `LoginPage` (avec confirmation)

---

### **EditProfilePage** (`lib/pages/edit_profile_page.dart`)

**Objectif:** Modifier les informations du profil

**Formulaire:**
- Nom, prénom
- Email
- Date de naissance
- Taille, poids
- Mensurations
- Objectifs
- Photo de profil (upload)

**Boutons:**
- **"Annuler":** Retour
- **"Enregistrer":** Sauvegarde via `UserProfileNotifier`

---

## 10. MODULES PREMIUM

### **10.1. Chat Match™**

#### **MatchHomePage** (`lib/chat_match/match_home_page.dart`)

**Objectif:** Trouver des partenaires d'entraînement compatibles

**Palette de couleurs:** Marron et Rose

**Sections:**

1. **Header explicatif:**
   - **Titre:** "Trouve ton partenaire d'entraînement"
   - **Description:** "Swipe pour liker, match si vous vous plaisez mutuellement, puis chattez pour organiser vos séances ensemble !"
   - **Icône:** Cœur rose dans un cercle

2. **Section "Comment ça marche ?":**
   - **4 étapes détaillées:**
     1. **"Découvre des profils"** - Parcours les profils de sportifs près de chez toi
        - Icône: `Icons.explore` (marron)
     2. **"Swipe pour liker"** - Glisse à droite si tu veux t'entraîner avec cette personne
        - Icône: `Icons.swipe_right` (rose)
     3. **"Match si c'est réciproque"** - Si vous vous plaisez mutuellement, vous pouvez chatter !
        - Icône: `Icons.favorite` (rose)
     4. **"Organisez vos séances"** - Discutez et planifiez vos entraînements ensemble
        - Icône: `Icons.chat_bubble` (marron clair)

3. **Section "Je cherche un partenaire pour…"** (Filtres visibles directement sur la page):
   - **Tags d'activité:** Chips sélectionnables multiples
     - Running, Perte de poids, Piscine, Musculation, Yoga, Cardio, Remise en forme
   - **Distance maximale:** Chips sélectionnables (un seul choix)
     - 0-5 km, 5-10 km, 10+ km
   - **Disponibilité:** Chips sélectionnables multiples
     - Matin, Midi, Soir, Week-end

4. **Menu Filtres (Burger):** (Ouvre un panneau latéral avec effet "waou")
   - **Filtres détaillés disponibles:**
     - **Âge:** Champs numériques min/max (ex: 18-65 ans)
       - Icône: `Icons.cake`
     - **Ville:** Chips sélectionnables (un seul choix)
       - Options: Paris, Lyon, Marseille, Toulouse, Nice, Nantes, Strasbourg, Montpellier
       - Icône: `Icons.location_city`
     - **Genre:** Chips sélectionnables (un seul choix)
       - Options: Homme, Femme, Autre, Tous
       - Icône: `Icons.people`
     - **Niveau:** Chips sélectionnables (un seul choix)
       - Options: Débutant, Intermédiaire, Avancé, Tous
       - Icône: `Icons.trending_up`
     - **Centres d'intérêt sportifs:** Chips sélectionnables multiples
       - Options: Running, Musculation, Yoga, Natation, Cyclisme, CrossFit, Pilates, Boxe
       - Icône: `Icons.sports`
     - **Score de compatibilité maximal:** Slider avec affichage du pourcentage
       - Plage: 50-100% (divisions: 10)
       - Affichage: Pourcentage en grand (ex: "85%")
       - Icône: `Icons.favorite`
     - **Accessoires possédés:** Chips sélectionnables multiples
       - Options: Haltères, Tapis, Élastiques, Corde à sauter, Kettlebell, TRX
       - Icône: `Icons.fitness_center`
     - **Difficultés visées:** Chips sélectionnables multiples
       - Options: Facile, Moyen, Difficile, Très difficile
       - Icône: `Icons.speed`
   - **Boutons d'action:**
     - **"Réinitialiser":** Remet tous les filtres à zéro
     - **"Appliquer les filtres":** Ferme le menu et applique les filtres
   - **Badge indicateur:** Point rose sur l'icône filtre si des filtres sont actifs

3. **Bouton Burger (Filtres):**
   - **Icône:** `Icons.filter_list` (dans AppBar)
   - **Badge:** Point rose si filtres actifs
   - **Action:** Ouvre/ferme le menu burger avec effet "waou"
     - Animation: SlideTransition + FadeTransition
     - Durée: 400ms
     - Courbe: `Curves.easeInOutCubic`

4. **Statistiques:**
   - Nombre de matches disponibles
   - Nombre de matches compatibles

5. **Bouton "Commencer à swiper":**
   - **Texte dynamique:** "Commencer à swiper (X)" où X est le nombre de profils filtrés
   - **État désactivé:** "Aucun profil disponible" si aucun profil ne correspond
   - **Style:** Bouton marron foncé avec icône swipe
   - **Action:** Navigation vers `MatchSwipePage`

6. **Boutons d'action:**
   - **Carte "Profils compatibles":** Clic → Navigation vers `MatchProfilesListPage`
   - **Carte "Partenaires d'entraînement trouvés":** Clic → Navigation vers `MatchResultsPage` (si matches > 0)
   - **Bouton "Voir mes matches":** Visible si matches > 0, navigation vers `MatchResultsPage`

**Navigation:**
- `MatchProfilesListPage` (liste)
- `MatchSwipePage` (swipe)

---

#### **MatchSwipePage** (`lib/chat_match/match_swipe_page.dart`)

**Objectif:** Swiper les profils (comme Tinder)

**Fonctionnalités:**
- **Carte profil:**
  - Photo
  - Nom, âge
  - Ville
  - Niveau
  - Centres d'intérêt
  - Score de compatibilité
- **Actions:**
  - **Swipe gauche:** Rejeter
  - **Swipe droite:** Like
  - **Boutons:** ❌ (rejeter) et ❤️ (like)
- **Animation:** Carte qui glisse avec rotation

**Navigation:**
- `MatchResultsPage` (après match)
- `MatchChatPage` (si match mutuel)

---

#### **MatchProfilesListPage** (`lib/chat_match/match_profiles_list_page.dart`)

**Objectif:** Liste de tous les profils compatibles

**Fonctionnalités:**
- Liste scrollable
- Filtres appliqués
- **Carte profil:**
  - Photo miniature
  - Nom, âge, ville
  - Score de compatibilité
  - **Action:** Clic → Navigation vers détails ou chat

---

#### **MatchChatPage** (`lib/chat_match/match_chat_page.dart`)

**Objectif:** Chat avec un match

**Fonctionnalités:**
- Interface de chat classique
- Messages texte
- Envoi de messages
- Historique des messages

---

#### **MatchResultsPage** (`lib/chat_match/match_results_page.dart`)

**Objectif:** Résultats des matches

**Fonctionnalités:**
- Liste des matches mutuels
- Score de compatibilité
- Actions: Contacter, Voir profil

---

### **10.2. Sport Gaming Story™**

#### **StoryHomePage** (`lib/game_story/story_home.dart`)

**Objectif:** Gamification de l'entraînement

**Palette de couleurs:** Marron et Jaune (polices noires)

**Sections:**

1. **Header:**
   - Titre: "Sport Gaming Story™"
   - Description: "Transforme chaque séance en mission."

2. **Barre de progression Story:**
   - **Niveau actuel:** Badge jaune "Niveau X"
   - **Chapitre actuel:** Titre du chapitre
   - **Progression:** Texte de progression (ex: "Chapitre 2/5 - Mission 3/8")

3. **Bloc progression niveau/XP:**
   - **XP actuel:** "XP : X / Y"
   - **Barre de progression:** Circulaire ou linéaire
   - **XP restant:** "Encore X XP pour le niveau suivant"

4. **Quêtes journalières:**
   - **Titre:** "Quêtes du jour"
   - **Progression:** "X/Y quêtes complétées"
   - **XP disponible:** "X XP à gagner"
   - **Liste des quêtes:**
     - Nom de la quête
     - Description
     - Récompense XP
     - État: Complétée / En cours
     - **Action:** Clic → Détails de la quête

5. **Badges et récompenses:**
   - **Titre:** "Badges débloqués"
   - **Progression:** "X/Y badges"
   - **Liste des badges:**
     - Icône du badge
     - Nom
     - État: Débloqué / Verrouillé

6. **Boss Games:**
   - **Titre:** "Défis Boss"
   - **Liste des boss:**
     - Boss Plank
     - Boss HIIT
     - Boss Squat
   - **Action:** Clic → Navigation vers le jeu du boss

7. **Boutons d'action:**
   - **"Voir mes quêtes":** Navigation vers `DailyQuestsPage`
   - **"Voir mes récompenses":** Navigation vers `StoryRewards`
   - **"Voir mon avatar":** Navigation vers `StoryAvatar`

**Navigation:**
- `DailyQuestsPage` (quêtes)
- `StoryRewards` (récompenses)
- `StoryAvatar` (avatar)
- `StoryChapterPage` (chapitre)
- Jeux boss (BossPlankGame, BossHIITGame, BossSquatGame)

---

### **10.3. Coach Business Pack™**

#### **CoachBusinessDashboard** (`lib/coach_business/business_dashboard.dart`)

**Objectif:** Dashboard pour coachs qui veulent vendre leurs programmes

**Palette de couleurs:** Marron et Gris clair

**Sections:**

1. **Statistiques:**
   - Nombre de clients
   - Revenus du mois
   - Programmes vendus
   - Taux de conversion

2. **Tiles d'action:**

   **a. Mon Branding:**
   - **Description:** Personnaliser son identité de marque
   - **Action:** Navigation vers `CoachBrandingPage`
   - **Démo:** Affiche un modal avec aperçu du branding

   **b. Mes Programmes:**
   - **Description:** Gérer ses programmes
   - **Action:** Navigation vers `CoachProgramsCatalogPage`
   - **Démo:** Affiche la liste des programmes

   **c. Mes Produits:**
   - **Description:** Gérer ses produits (accessoires, etc.)
   - **Action:** Navigation vers `CoachProductsPage`

   **d. Boutique FitPro Accessoires:**
   - **Description:** Vendre des accessoires FitPro
   - **Action:** Navigation vers `FitProAccessoriesShopPage`

   **e. Mes Séances Aujourd'hui:**
   - **Description:** Voir les séances prévues
   - **Action:** Navigation vers `CoachSessionsTodayPage`

   **f. Mes Clients:**
   - **Description:** Gérer ses clients
   - **Action:** Navigation vers `CoachClientsPage`

3. **Analytics:**
   - Graphiques de ventes
   - Évolution des revenus
   - Top programmes

**Navigation:**
- `CoachBrandingPage` (branding)
- `CoachProgramsCatalogPage` (programmes)
- `CoachProductsPage` (produits)
- `FitProAccessoriesShopPage` (boutique)
- `CoachSessionsTodayPage` (séances)
- `CoachClientsPage` (clients)

---

#### **CoachBrandingPage** (`lib/coach_business/coach_branding_page.dart`)

**Objectif:** Personnaliser son identité de marque

**Fonctionnalités:**
- **Nom de marque:** Champ texte
- **Palette de couleurs:** Sélecteur de couleurs
- **Logo:** Upload de logo
- **Description:** Texte de présentation
- **Aperçu:** Prévisualisation en temps réel

**Boutons:**
- **"Enregistrer":** Sauvegarde via `CoachBrandingNotifier`
- **"Annuler":** Retour

---

#### **CoachProgramsCatalogPage** (`lib/coach_business/coach_programs_catalog_page.dart`)

**Objectif:** Catalogue des programmes du coach

**Fonctionnalités:**
- Liste de tous les programmes
- **Bouton "+":** Créer un nouveau programme
- **Carte programme:**
  - Titre, description
  - Prix
  - Nombre de ventes
  - **Actions:** Modifier, Supprimer, Voir détails

**Navigation:**
- `CoachProgramCreatePage` (créer)
- `CoachProgramDetailPage` (détails)

---

### **10.4. Coach VS Coach™**

#### **CoachRankingPage** (`lib/coach_vs_coach/coach_ranking_page.dart`)

**Objectif:** Classement des coachs

**Fonctionnalités:**
- **Classement général:**
  - Top 10 coachs
  - Score total
  - Nombre de victoires
- **Catégories:**
  - Par spécialité
  - Par ville
  - Par niveau
- **Défis:**
  - Liste des défis en cours
  - **Bouton "Créer un défi":** Navigation vers `DuelCoachPage`

**Navigation:**
- `DuelCoachPage` (créer défi)
- `DuelHistoryPage` (historique)
- `DuelEnCoursScreen` (défi en cours)

---

### **10.5. Transformation Projection™**

#### **RAFuturePreviewPage** (`lib/transformation_ra/ra_future_preview.dart`)

**Objectif:** Visualiser son futur soi

**Fonctionnalités:**
- **Slider de projection:**
  - Aujourd'hui → 1 mois → 3 mois → 6 mois → 1 an
- **Visualisation:**
  - Avatar transformé selon la projection
  - Métriques projetées (poids, IMC, etc.)
- **Paramètres:**
  - Objectif (perte de poids, prise de masse, etc.)
  - Intensité d'entraînement
  - Régime alimentaire

**Boutons:**
- **"Enregistrer cette projection":** Sauvegarde
- **"Partager":** Partage de l'image

---

### **10.6. Coach Personnalité™**

#### **CoachStylePickerPage** (`lib/coach_personality/coach_style_picker.dart`)

**Objectif:** Choisir le style de son coach virtuel

**Styles disponibles:**

1. **Coach Gentil:**
   - Description: "Encourageant et bienveillant"
   - Voix: Douce

2. **Coach Dur:**
   - Description: "Motivant et exigeant"
   - Voix: Autoritaire

3. **Coach Militaire:**
   - Description: "Strict et discipliné"
   - Voix: Militaire

4. **Coach Humour:**
   - Description: "Décontracté et drôle"
   - Voix: Enjouée

**Action:** Sélection → Navigation vers `CoachPersonalityPage`

---

#### **CoachPersonalityPage** (`lib/coach_personality/coach_personality_page.dart`)

**Objectif:** Interface avec le coach personnalisé

**Fonctionnalités:**
- **Messages du coach:**
  - Bulles de chat
  - Synthèse vocale (selon style choisi)
- **Réponses utilisateur:**
  - Boutons de réponse rapide
  - Champ texte libre
- **Paramètres:**
  - Volume
  - Fréquence des messages
  - Horaires

**Technologie:**
- `flutter_tts` pour la synthèse vocale
- `CoachPersonalityNotifier` pour la gestion d'état

---

## 11. FONCTIONNALITÉS AVANCÉES

### **11.1. FoodScan IA**

#### **FoodScanHomePage** (`lib/foodscan_ia/foodscan_home_page.dart`)

**Objectif:** Analyser un repas depuis une photo

**Fonctionnalités:**
- **Prise de photo:**
  - Bouton "Prendre une photo"
  - Ou "Choisir depuis la galerie"
- **Analyse:**
  - Détection des aliments
  - Calcul automatique des calories
  - Macronutriments estimés
- **Résultat:**
  - Liste des aliments détectés
  - Calories totales
  - Macros
  - **Bouton "Ajouter à mon journal":** Enregistre dans `NutritionNotifier`

**Modes:**
- **Photo:** `FoodScanPhotoDemoPage`
- **Voix:** `FoodScanVoiceDemoPage`

---

### **11.2. Alter Ego**

#### **AlterEgoFloatingWidget** (`lib/alter_ego_floating/alter_ego_floating_widget.dart`)

**Objectif:** Widget flottant persistant de l'Alter Ego

**Fonctionnalités:**
- **Position:** Configurable (topRight par défaut)
- **Apparence:** Bulle de chat avec avatar
- **Messages contextuels:**
  - Réactions aux progrès
  - Encouragements
  - Rappels
- **Interaction:**
  - Clic → Ouvre le chat complet
  - Animation d'apparition/disparition

**Service:** `AlterEgoService` pour la gestion globale

---

#### **AlterEgoScreen** (`lib/alter_ego.dart`)

**Objectif:** Interface complète avec l'Alter Ego

**Fonctionnalités:**
- Chat complet
- Historique des conversations
- Paramètres de l'Alter Ego

---

### **11.3. Cours Collectifs**

#### **GroupClassLive** (`lib/group_classes/group_class_live.dart`)

**Objectif:** Rejoindre un cours en direct

**Fonctionnalités:**
- Liste des cours en cours
- **Carte cours:**
  - Nom du cours
  - Coach
  - Heure de début
  - Nombre de participants
  - **Bouton "Rejoindre":** Ouvre le cours en direct

---

#### **GroupClassReplays** (`lib/group_classes/group_class_replays.dart`)

**Objectif:** Voir les cours enregistrés

**Fonctionnalités:**
- Liste des replays disponibles
- Filtres (date, coach, type)
- **Carte replay:**
  - Miniature vidéo
  - Titre, durée
  - **Bouton "Regarder":** Ouvre la vidéo

---

### **11.4. Bibliothèque d'Exercices**

#### **ExerciseLibraryPage** (`lib/exercises/exercise_library_page.dart`)

**Objectif:** Bibliothèque complète d'exercices

**Fonctionnalités:**
- **Recherche:** Champ de recherche
- **Filtres:**
  - Catégorie (Jambes, Haut du corps, etc.)
  - Difficulté (Débutant, Intermédiaire, Avancé)
  - Source (FitPro, Mes exercices)
- **Liste d'exercices:**
  - Image/placeholder
  - Nom
  - Catégorie, difficulté
  - **Action:** Clic → Navigation vers `ExerciseDetailPage`
- **Bouton "+":** Créer un exercice personnalisé

**Navigation:**
- `ExerciseDetailPage` (détails)
- `CreateExercisePage` (créer)

---

#### **ExerciseDetailPage** (`lib/exercises/exercise_detail_page.dart`)

**Objectif:** Détails d'un exercice

**Éléments:**
- Image/vidéo
- Nom
- Instructions détaillées
- Muscles sollicités
- Difficulté
- Matériel requis
- **Bouton "Voir la vidéo":** Navigation vers `ExerciseVideoPage`

---

### **11.5. Statistiques**

#### **StatsPage** (`lib/stats_page.dart`)

**Objectif:** Statistiques détaillées

**Sections:**
- **Graphiques:**
  - Évolution poids
  - Calories quotidiennes
  - Séances par semaine
  - Pas quotidiens
- **Périodes:**
  - 7 jours, 30 jours, 3 mois, 1 an
- **Export:** Bouton pour exporter les données

---

### **11.6. Planning**

#### **PlanningPage** (`lib/planning_page.dart`)

**Objectif:** Planning d'entraînement

**Fonctionnalités:**
- **Calendrier:**
  - Vue mensuelle/hebdomadaire
  - Séances planifiées affichées
- **Création:**
  - **Bouton "+":** Ajouter une séance planifiée
  - Formulaire: Date, heure, type de séance
- **Modification:**
  - Clic sur une séance → Modifier/Supprimer

---

### **11.7. Compteur de Pas**

#### **PedometerPage** (`lib/pedometer_page.dart`)

**Objectif:** Page dédiée au compteur de pas

**Fonctionnalités:**
- **Compteur principal:**
  - Nombre de pas du jour (grand affichage)
  - Objectif: 8000 pas
  - Barre de progression circulaire
- **Historique:**
  - Graphique des 7 derniers jours
  - Moyenne hebdomadaire
- **Statistiques:**
  - Distance parcourue
  - Calories brûlées (estimées)
  - Temps actif

**Technologie:**
- `sensors_plus` pour le comptage automatique
- `StepsNotifier` pour la gestion d'état

---

### **11.8. Composition Corporelle**

#### **BodyCompositionPage** (`lib/body_composition_page.dart`)

**Objectif:** Suivi détaillé de la composition corporelle

**Fonctionnalités:**
- **Métriques:**
  - Poids
  - Masse grasse (%)
  - Masse musculaire
  - IMC
  - Tour de taille, hanches, etc.
- **Graphiques:**
  - Évolution du poids
  - Évolution masse grasse
  - Comparaison de périodes
- **Ajout de mesure:**
  - **Bouton "+":** Ajouter une nouvelle mesure
  - Formulaire avec toutes les métriques

---

### **11.9. Chat Communautaire**

#### **CommunityChatPage** (`lib/community_chat_page.dart`)

**Objectif:** Discussions entre membres FitPro

**Fonctionnalités:**
- **Liste des discussions:**
  - Sujets populaires
  - Discussions récentes
- **Création:**
  - **Bouton "+":** Créer une nouvelle discussion
- **Discussion:**
  - Messages des membres
  - Réactions (like, etc.)
  - Partage

---

### **11.10. Parrainage**

#### **ParrainagePage** (`lib/pages/parrainage_page.dart`)

**Objectif:** Système de parrainage

**Fonctionnalités:**
- **Code de parrainage:**
  - Code unique de l'utilisateur
  - **Bouton "Copier":** Copie le code
- **Statistiques:**
  - Nombre de filleuls
  - Récompenses gagnées
- **Récompenses:**
  - Liste des récompenses disponibles
  - Conditions d'obtention

---

## 12. ARCHITECTURE TECHNIQUE

### **12.1. Gestion d'État**

**Pattern:** ChangeNotifier (Singleton)

**Notifiers principaux:**
- `WorkoutHistoryNotifier`: Historique des séances
- `NutritionNotifier`: Repas et nutrition
- `DailyGoalsNotifier`: Objectifs quotidiens (eau, protéines, sommeil)
- `StepsNotifier`: Compteur de pas
- `UserProfileNotifier`: Profil utilisateur
- `SubscriptionNotifier`: Abonnements
- `CoachDirectoryNotifier`: Annuaire coachs
- `GameStoryNotifier`: Sport Gaming Story
- `MatchEngine`: Chat Match
- `CoachBrandingNotifier`: Branding coach
- `CoachProductsNotifier`: Produits coach
- `ThemeNotifier`: Thème (jour/nuit)

**Utilisation:**
```dart
final notifier = WorkoutHistoryNotifier();
notifier.addListener(() => setState(() {}));
```

---

### **12.2. Navigation**

**Pattern:** MaterialPageRoute (Navigation impérative)

**Exemple:**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => TargetPage(),
  ),
);
```

---

### **12.3. Modèles de Données**

**Dossier:** `lib/models/`

**Liste complète:**
1. `user_profile.dart` - Profil utilisateur
2. `workout_session.dart` - Séances
3. `workout_history.dart` - Historique
4. `nutrition.dart` - Nutrition
5. `goals.dart` - Objectifs
6. `steps.dart` - Pas
7. `coach_directory.dart` - Coachs
8. `coach_programs.dart` - Programmes coachs
9. `subscription.dart` - Abonnements
10. `body_composition.dart` - Composition corporelle
11. `planning.dart` - Planning
12. `rooms.dart` - Salles
13. `chat.dart` - Chat
14. `community_chat.dart` - Chat communautaire
15. `client_tracking.dart` - Suivi clients
16. `game_story.dart` - Gaming Story
17. `coach_personality.dart` - Coach personnalité
18. `coach_vs_coach.dart` - Duel coachs
19. `coach_business.dart` - Business coach
20. `future_self_advanced.dart` - Futur moi
21. `exercise.dart` - Exercices
22. `exercise_library_item.dart` - Bibliothèque exercices
23. `demo_purchase.dart` - Achats démo
24. `video_pack.dart` - Packs vidéos
25. `group_class.dart` - Cours collectifs
26. `transformation_projection.dart` - Projection
27. `match_profile.dart` - Profils Chat Match
28. `match_filters.dart` - Filtres Chat Match
29. `match_compatibility.dart` - Compatibilité
30. `coach_reviews.dart` - Avis coachs
31. `coach_diploma.dart` - Diplômes
32. `client_profile.dart` - Profil client
33. `advanced_body_data.dart` - Données corporelles avancées
34. `theme_notifier.dart` - Thème
35. Et plus...

---

### **12.4. Dépendances Principales**

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  pedometer: ^4.0.0              # Compteur de pas
  sensors_plus: ^4.0.0           # Accéléromètre
  flutter_tts: ^4.1.0            # Synthèse vocale
  vibration: ^1.8.4              # Vibration
  intl: ^0.19.0                   # Formatage dates
  flutter_localizations:         # Localisation FR
```

---

### **12.5. Palettes de Couleurs par Page**

**DashboardTab:** Violet et Marron
- `_violetPrincipal`, `_violetClair`
- `_marronPrincipal`, `_marronFonce`, `_marronClair`

**SessionsTab:** Marron et Vert
- `_marronPrincipalSeances`, `_marronFonceSeances`, `_marronClairSeances`
- `_vertPrincipalSeances`, `_vertFonceSeances`

**NutritionTab:** Marron et Jaune
- `_marronPrincipalNutrition`, `_marronFonceNutrition`, `_marronClairNutrition`
- `_jaunePrincipalNutrition`, `_jauneClairNutrition`, `_jauneFonceNutrition`

**EspaceProScreen:** Marron et Bleu
- `_marronPrincipalAvance`, `_marronFonceAvance`, `_marronClairAvance`
- `_bleuPrincipalAvance`, `_bleuClairAvance`, `_bleuFonceAvance`

**Chat Match:** Marron et Rose
- `_marronPrincipalChatMatch`, `_marronFonceChatMatch`, `_marronClairChatMatch`
- `_rosePrincipalChatMatch`, `_roseClairChatMatch`, `_roseFonceChatMatch`

**Sport Gaming Story:** Marron et Jaune (polices noires)
- `_marronPrincipalGaming`, `_marronFonceGaming`, `_marronClairGaming`
- `_jaunePrincipalGaming`, `_jauneClairGaming`, `_jauneFonceGaming`

**Coach Business:** Marron et Gris clair
- `_marronPrincipalBusiness`, `_marronFonceBusiness`, `_marronClairBusiness`
- `_grisClairBusiness`, `_grisPrincipalBusiness`, `_grisFonceBusiness`

---

## 📝 NOTES IMPORTANTES

### **États des Fonctionnalités:**

✅ **Fonctionnel:** Implémenté et opérationnel
⚠️ **Partiel:** Partiellement implémenté ou placeholder
❌ **Manquant:** Non implémenté

### **Persistance des Données:**

⚠️ **Actuellement:** Toutes les données sont en mémoire (Notifiers)
- Les données sont perdues au redémarrage de l'application
- Pas de base de données locale (SQLite/Hive)
- Pas de synchronisation cloud

### **Authentification:**

⚠️ **Actuellement:** Simulée
- Pas de vraie authentification
- Pas de backend
- Valeurs pré-remplies pour la démo

### **Paiements:**

⚠️ **Actuellement:** Démo uniquement
- Pas de vraie intégration de paiement
- Messages "fictif pour l'instant"

---

## 🎯 CONCLUSION

Cette documentation couvre **toutes les pages, tous les boutons et toutes les fonctionnalités** de l'application FitPro. Chaque section détaille:

- L'objectif de la page
- Les éléments de l'interface
- Les actions possibles
- La navigation
- Les données utilisées
- Les technologies impliquées

**Pour toute question ou clarification, référez-vous à cette documentation complète.**

---

**Document généré le:** 2025-01-XX  
**Version de l'application:** 1.0.0  
**Dernière mise à jour:** 2025-01-XX

