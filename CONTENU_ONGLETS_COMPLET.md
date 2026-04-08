# 📱 UKAN - CONTENU DÉTAILLÉ DE CHAQUE ONGLET
## Guide complet pour l'équipe de développement

---

> **Objectif :** Décrire exactement ce qu'il y a dans chaque onglet de l'application, chaque page, chaque bouton, chaque fonctionnalité.

---

# ═══════════════════════════════════════════════════════════════
# 🏠 ONGLET 1 : ACCUEIL
# ═══════════════════════════════════════════════════════════════

**Fichiers principaux :**
- `lib/home/home_page.dart`
- `lib/home/widgets/dashboard_tab.dart`
- `lib/home/widgets/publications_tab.dart`

---

## STRUCTURE DE L'ONGLET ACCUEIL

L'onglet Accueil contient **2 sous-onglets** accessibles via un SegmentedControl :

```
┌─────────────────────────────────────┐
│  [📊 Dashboard] [📱 Publications]   │
└─────────────────────────────────────┘
```

---

## 📊 SOUS-ONGLET 1 : DASHBOARD

### Header : Défi de la semaine
| Élément | Description |
|---------|-------------|
| **Bannière défi** | Affiche le défi hebdomadaire en cours |
| **Progression** | Barre de progression du défi |
| **Récompense** | Points/badges à gagner |

### Section 1 : Objectif Principal
| Élément | Description |
|---------|-------------|
| **Icône objectif** | Icône selon l'objectif (perte poids, muscle, etc.) |
| **Titre objectif** | Ex: "Perte de poids", "Prise de masse" |
| **Détail** | Ex: "-5 kg", "+3 kg de muscle" |

### Section 2 : Objectifs de la semaine
| Élément | Description |
|---------|-------------|
| **Tags dorés** | Liste horizontale scrollable |
| **Tag 1** | Objectif 1 de la semaine |
| **Tag 2** | Objectif 2 de la semaine |
| **Tag 3** | Objectif 3 de la semaine |

### Section 3 : Widget Progression Globale
| Élément | Description |
|---------|-------------|
| **Cercle de progression** | Pourcentage global de la semaine |
| **Score** | Note sur 100 |
| **Tendance** | Flèche haut/bas vs semaine précédente |

### Section 4 : Mes Objectifs Personnels (4 cartes)

**Disposition : 2 colonnes × 2 lignes**

| Carte | Position | Contenu |
|-------|----------|---------|
| **Objectif Séances** | Haut-gauche | X/3 séances cette semaine, barre de progression |
| **Objectif Calories** | Bas-gauche | X/2000 kcal du jour, barre de progression |
| **Hydratation** | Haut-droite | X/8 verres d'eau, icône goutte |
| **Protéines** | Bas-droite | X/150g protéines, barre de progression |

**Action au tap :** Chaque carte ouvre sa page de détail/modification.

### Section 5 : Graphique de la Semaine
| Élément | Description |
|---------|-------------|
| **Titre** | "Ma semaine" |
| **Graphique barres** | 7 barres (Lun-Dim) |
| **Couleur barre** | Or si séance faite, gris sinon |
| **Légende** | Séances faites / prévues |

### Section 6 : Distance / Pas du jour
| Élément | Description |
|---------|-------------|
| **Grand cercle** | Cercle de progression des pas |
| **Nombre de pas** | Ex: "6 542 pas" |
| **Objectif** | Ex: "/ 8 000" |
| **Distance** | Ex: "4.2 km" |
| **Calories brûlées** | Ex: "285 kcal" |

### Section 7 : Sommeil
| Élément | Description |
|---------|-------------|
| **Durée** | Ex: "7h 30min" |
| **Qualité** | Ex: "Bonne qualité" |
| **Heure coucher** | Ex: "23:15" |
| **Heure réveil** | Ex: "06:45" |
| **Graphique** | Mini graphique des 7 derniers jours |

---

## 📱 SOUS-ONGLET 2 : PUBLICATIONS

### Header : Stories
| Élément | Description |
|---------|-------------|
| **Rangée de stories** | Cercles horizontaux scrollables |
| **Ma story** | Premier cercle avec "+" pour ajouter |
| **Stories amis** | Photos de profil avec bordure dorée si non vue |

### Feed de publications
| Élément | Description |
|---------|-------------|
| **Carte publication** | Photo/vidéo + texte + interactions |
| **Header carte** | Photo profil + nom + date |
| **Contenu** | Image/vidéo + description |
| **Actions** | ❤️ Like, 💬 Commenter, ↗️ Partager, 🔖 Sauvegarder |
| **Compteurs** | Nombre de likes, commentaires |

### Types de publications
| Type | Icône | Description |
|------|-------|-------------|
| **Séance terminée** | 🏋️ | Partage d'une séance |
| **Recette** | 🍽️ | Partage d'une recette |
| **Transformation** | 📸 | Photo avant/après |
| **Motivation** | 💪 | Post de motivation |
| **Objectif atteint** | 🎯 | Badge/objectif débloqué |

### Bouton Créer Publication
| Position | Action |
|----------|--------|
| **FAB (bas droite)** | Ouvre le formulaire de création |

---

# ═══════════════════════════════════════════════════════════════
# 🥗 ONGLET 2 : NUTRITION
# ═══════════════════════════════════════════════════════════════

**Fichier principal :** `lib/nutrition/nutrition_hub_page.dart`

---

## STRUCTURE DE L'ONGLET NUTRITION

L'onglet Nutrition est un **Hub** avec plusieurs sections :

---

### Header : App Bar
| Élément | Description |
|---------|-------------|
| **Titre** | "Nutrition" |
| **Icône recherche** | 🔍 Rechercher un aliment/recette |
| **Icône paramètres** | ⚙️ Paramètres nutrition |

---

### Section 1 : FoodScan Hero (Bannière IA)
| Élément | Description |
|---------|-------------|
| **Titre** | "FoodScan IA" |
| **Sous-titre** | "Scanne ton repas" |
| **Icône** | 📸 Caméra avec effet brillant |
| **Badge** | "IA" en doré |
| **Animation** | Effet pulse/glow |

**Action au tap :** Ouvre `FoodScanHomePage`

---

### Section 2 : Résumé du Jour
| Élément | Description |
|---------|-------------|
| **Calories** | X / 2000 kcal avec barre circulaire |
| **Protéines** | Xg avec mini barre |
| **Glucides** | Xg avec mini barre |
| **Lipides** | Xg avec mini barre |

**Couleurs des barres :**
- Calories : Or
- Protéines : Rouge
- Glucides : Bleu
- Lipides : Jaune

---

### Section 3 : Accès Rapides (Grille 3×2)

| Position | Carte | Icône | Destination |
|----------|-------|-------|-------------|
| **1,1** | Repas & Courses 2.0 | 🍽️ | `RepasCoursesPage` |
| **1,2** | Planning Semaine | 📅 | `MealPlannerPage` |
| **2,1** | Liste Courses | 🛒 | `RepasCoursesPage` (onglet courses) |
| **2,2** | Calculatrice Nutrition | 🔢 | `NumericCalculatorPage` |
| **3,1** | Recettes & Fil | 🔍 | `RecipesFeedPage` |
| **3,2** | Bibliothèque Icônes | 🍕 | `FoodIconsLibraryPage` |

---

### Section 4 : Conseil du Jour
| Élément | Description |
|---------|-------------|
| **Icône** | 💡 Ampoule |
| **Titre** | "Conseil du jour" |
| **Texte** | Conseil personnalisé selon les données |
| **Exemples** | "Pense à boire plus d'eau", "Augmente tes protéines" |

---

### Section 5 : Streaks & Objectifs
| Élément | Description |
|---------|-------------|
| **Streak nutrition** | X jours consécutifs d'objectifs atteints |
| **Flamme** | 🔥 Icône animée |
| **Meilleur streak** | Record personnel |

---

## PAGES ACCESSIBLES DEPUIS NUTRITION

### 1. Repas & Courses 2.0
**Fichier :** `lib/features/nutrition/repas_courses_page.dart`

| Onglet | Contenu |
|--------|---------|
| **Repas** | Petit-déj, Déjeuner, Dîner, Collations avec suggestions |
| **Courses** | Liste de courses générée automatiquement |

### 2. Planning Semaine
**Fichier :** `lib/features/nutrition/meal_planner_page.dart`

| Élément | Description |
|---------|-------------|
| **Vue 7 jours** | Lun-Dim en colonnes |
| **Cases repas** | Petit-déj, Déj, Dîner par jour |
| **Drag & drop** | Déplacer les repas |
| **Total jour** | Calories par jour |

### 3. Calculatrice Nutrition
**Fichier :** `lib/features/nutrition/calculator/numeric_calculator_page.dart`

| Élément | Description |
|---------|-------------|
| **Écran LCD** | Affiche le calcul en cours |
| **Clavier numérique** | 0-9, +, -, ×, ÷, = |
| **Sélecteur unité** | g, kg, ml, cl, L, unité |
| **Liste aliments** | Catégories (Protéines, Glucides, etc.) |
| **Résultat** | Calories, P, G, L calculés |
| **Bouton ajouter aliment** | Créer un aliment personnalisé |

### 4. Recettes & Fil
**Fichier :** `lib/nutrition/recipes_feed_page.dart`

| Onglet | Contenu |
|--------|---------|
| **Explorer** | Recettes de la communauté |
| **Mes Recettes** | Recettes créées/sauvées |
| **Créer** | Formulaire création recette |

### 5. FoodScan IA
**Fichier :** `lib/foodscan_ia/foodscan_home_page.dart`

| Mode | Description |
|------|-------------|
| **Photo** | Prendre une photo du plat |
| **Vocal** | Dicter les aliments |
| **Résultat** | Liste des aliments détectés + macros |

### 6. Bibliothèque Icônes
**Fichier :** `lib/features/nutrition/food_icons_library_page.dart`

| Catégorie | Exemples d'icônes |
|-----------|-------------------|
| **Protéines** | 🍗🥩🍖🐟🥚 |
| **Glucides** | 🍚🍝🥔🍞🥐 |
| **Fruits** | 🍎🍊🍋🍇🍓 |
| **Légumes** | 🥕🥦🥬🍅🌽 |
| **Lipides** | 🥜🥑🧈🫒 |
| **Produits laitiers** | 🥛🧀🍦 |
| **Sucres** | 🍫🍬🍩🍪 |
| **Boissons** | ☕🍵🧃🥤 |
| **Plats préparés** | 🍕🍔🌮🍜 |
| **Charcuterie** | 🥓🌭🥪 |
| **Huiles** | 🫒🥥 |

---

# ═══════════════════════════════════════════════════════════════
# 🏋️ ONGLET 3 : SÉANCES
# ═══════════════════════════════════════════════════════════════

**Fichier principal :** `lib/main.dart` (classe `SessionsTab`)

---

## STRUCTURE DE L'ONGLET SÉANCES

L'onglet Séances contient **2 sous-onglets** :

```
┌─────────────────────────────────────────────────┐
│  [📚 Bibliothèque d'exercices] [📅 Séances]     │
└─────────────────────────────────────────────────┘
```

---

## 📚 SOUS-ONGLET 1 : BIBLIOTHÈQUE D'EXERCICES

**Fichier :** `lib/exercise_library_page.dart`

### Header
| Élément | Description |
|---------|-------------|
| **Barre de recherche** | 🔍 Rechercher un exercice |
| **Filtres** | Dropdown équipement |

### Onglets par groupe musculaire
| Onglet | Exercices |
|--------|-----------|
| **Tous** | Tous les exercices |
| **Pectoraux** | Pompes, Développé couché, etc. |
| **Dos** | Tractions, Rowing, etc. |
| **Épaules** | Élévations, Développé militaire |
| **Biceps** | Curls, etc. |
| **Triceps** | Dips, Extensions, etc. |
| **Jambes** | Squats, Fentes, etc. |
| **Abdos** | Crunchs, Planche, etc. |
| **Cardio** | Course, Burpees, etc. |

### Carte exercice
| Élément | Description |
|---------|-------------|
| **Image/GIF** | Démonstration de l'exercice |
| **Nom** | Nom de l'exercice |
| **Muscle ciblé** | Tag du muscle principal |
| **Équipement** | Icône équipement requis |
| **Difficulté** | Facile/Moyen/Difficile |
| **Favoris** | ⭐ Étoile pour sauvegarder |

### Détail exercice (au tap)
| Section | Contenu |
|---------|---------|
| **Vidéo/GIF** | Grande démonstration |
| **Instructions** | Étapes détaillées |
| **Muscles travaillés** | Liste des muscles |
| **Variantes** | Exercices similaires |
| **Boutons rapides** | Historique, Progression, Défi |

---

## 📅 SOUS-ONGLET 2 : SÉANCES DE LA SEMAINE

### Bannière "Voir mes séances"
| Élément | Description |
|---------|-------------|
| **Titre** | "Mes séances de la semaine" |
| **Sous-titre** | "X séances planifiées" |
| **Action** | Ouvre la page détaillée |

### Liste des programmes
| Carte | Contenu |
|-------|---------|
| **Image** | Illustration du programme |
| **Titre** | Ex: "Full body sans matériel" |
| **Durée** | Ex: "35 min" |
| **Difficulté** | Badge couleur |
| **Objectif** | Ex: "Tonification globale" |
| **Fréquence** | Ex: "4 séances/semaine" |

### Actions sur un programme
| Bouton | Action |
|--------|--------|
| **Commencer** | Lance la séance |
| **Détails** | Voir les exercices |
| **Planifier** | Ajouter au calendrier |

---

## PAGES ACCESSIBLES DEPUIS SÉANCES

### 1. Page Séance en cours
**Fichier :** `lib/workout_session_page.dart`

| Élément | Description |
|---------|-------------|
| **Timer global** | Durée totale de la séance |
| **Exercice actuel** | Nom + vidéo/image |
| **Séries** | X/Y séries |
| **Répétitions** | Compteur |
| **Timer repos** | Compte à rebours entre séries |
| **Bouton Terminer série** | Valider la série |
| **Bouton Passer** | Sauter l'exercice |
| **Coach vocal** | 🤖 Encouragements (si activé) |

### 2. Page Calendrier Séances
**Fichier :** `lib/workout_calendar_page.dart`

| Élément | Description |
|---------|-------------|
| **Vue mois** | Calendrier avec points |
| **Légende** | Séance (or), Objectif (vert), Aujourd'hui (bleu) |
| **Détail jour** | Séance du jour sélectionné |

### 3. Page Créer Séance
**Fichier :** `lib/create_workout_page.dart`

| Champ | Description |
|-------|-------------|
| **Nom** | Titre de la séance |
| **Exercices** | Sélection depuis la bibliothèque |
| **Séries/Reps** | Configuration par exercice |
| **Temps repos** | Secondes entre séries |
| **Sauvegarder** | Enregistrer dans "Mes séances" |

---

# ═══════════════════════════════════════════════════════════════
# ⚡ ONGLET 4 : AVANCÉ
# ═══════════════════════════════════════════════════════════════

**Fichier principal :** `lib/espace_pro_screen.dart`

---

## STRUCTURE DE L'ONGLET AVANCÉ

L'onglet Avancé est divisé en **3 catégories** accessibles via des onglets :

```
┌─────────────────────────────────────────────────┐
│  [🆓 Freemium] [💎 Premium] [🤖 IA]             │
└─────────────────────────────────────────────────┘
```

---

## 🆓 CATÉGORIE FREEMIUM (11 tuiles)

| # | Tuile | Icône | Description | Destination |
|---|-------|-------|-------------|-------------|
| 1 | **Analyse corporelle** | ⚖️ | Suivi poids, IMC, mensurations | `BodyCompositionPage` |
| 2 | **Chat communautaire** | 💬 | Discussions entre membres | `CommunityChatPage` |
| 3 | **Chat Match™** | ❤️ | Trouver des partenaires sportifs | `MatchHomePage` |
| 4 | **Visio Training** | 📹 | S'entraîner en visio avec des amis | `BuddyHomePage` |
| 5 | **Santé & Blessures** | 🏥 | Carnet de suivi médical | `HealthInjuriesPage` |
| 6 | **Annuaire** | 👥 | Recherche de coachs et utilisateurs | `CoachDirectoryPage` |
| 7 | **Personnalité Coach** | 🧠 | Personnaliser l'assistant vocal | `CoachPersonalityPage` |
| 8 | **Événements** | 📅 | Calendrier des événements sportifs | `EventsPage` |
| 9 | **Sport Gaming™** | 🎮 | Gamification avec quêtes et badges | `StoryHomePage` |
| 10 | **Mon Évolution** | 📈 | Photos avant/après avec guide de pose | `PoseGuideEvolutionPage` |

---

## 💎 CATÉGORIE PREMIUM (6 tuiles)

| # | Tuile | Icône | Description | Destination |
|---|-------|-------|-------------|-------------|
| 1 | **Coach Business™** | 🏪 | Dashboard pour coachs professionnels | `CoachBusinessDashboard` |
| 2 | **Cours Live** | 🔴 | Cours en direct style TikTok | `GroupClassLivePage` |
| 3 | **Pack Vidéos** | 📼 | Vidéos d'exercices à acheter | `VideoPacksPage` |
| 4 | **Replays** | ⏪ | Replays des cours collectifs | `GroupClassReplaysPage` |
| 5 | **Coach vs Coach** | 🏆 | Classement et duels entre coachs | `CoachRankingPage` |
| 6 | **Hard Challenge** | 🔥 | Défis intensifs 50/75/90 jours | `HardChallengePage` |

---

## 🤖 CATÉGORIE IA (4 tuiles)

| # | Tuile | Icône | Description | Destination |
|---|-------|-------|-------------|-------------|
| 1 | **Coach IA Premium** | 📡 | Analyse posture en temps réel | `CoachIAPremiumPage` |
| 2 | **FoodScan IA** | 📸 | Scanner un repas par photo | `FoodScanHomePage` |
| 3 | **Mon Alter Ego** | 🧠 | Chatbot assistant personnel | `AlterEgoScreen` |
| 4 | **Projection IA** | ✨ | Visualiser son futur corps par IA | `RAFuturePreviewPage` |

---

## DÉTAIL DES PAGES AVANCÉES

### Analyse Corporelle
| Section | Contenu |
|---------|---------|
| **Poids actuel** | Avec historique graphique |
| **IMC** | Calcul automatique |
| **Mensurations** | Tour de taille, hanches, bras, cuisses |
| **Photos** | Galerie de progression |
| **Objectif** | Poids cible |

### Chat Match™
| Étape | Description |
|-------|-------------|
| **Profil** | Créer son profil de recherche |
| **Préférences** | Objectifs, niveau, disponibilité |
| **Swipe** | Parcourir les profils compatibles |
| **Match** | Quand 2 personnes se likent |
| **Chat** | Messagerie privée |

### Visio Training
| Fonctionnalité | Description |
|----------------|-------------|
| **Créer session** | Démarrer un appel |
| **Inviter** | Partager le lien |
| **Rejoindre** | Entrer via lien |
| **Partager écran** | Montrer sa séance |

### Mon Évolution (NOUVEAU)
| Onglet | Contenu |
|--------|---------|
| **Galerie** | Photos par type de pose (Face, Profil, Dos) |
| **Comparer** | Côte à côte, Slider, Swipe |
| **Stats** | Graphique de poids, historique |
| **Guide de pose** | Silhouette fantôme pour aligner les photos |

### Sport Gaming™
| Section | Contenu |
|---------|---------|
| **Niveau/XP** | Progression gamifiée |
| **Quêtes quotidiennes** | Défis du jour |
| **Badges** | Collection de récompenses |
| **Classement** | Leaderboard |
| **Mode histoire** | Chapitres à débloquer |

---

# ═══════════════════════════════════════════════════════════════
# 🔍 ONGLET 5 : RECHERCHER (via header)
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/global_search_page.dart`

---

## STRUCTURE DE LA RECHERCHE

La recherche est accessible via l'icône 🔍 dans le header de chaque onglet.

### Barre de recherche
| Élément | Description |
|---------|-------------|
| **Champ texte** | Saisie de la recherche |
| **Icône micro** | 🎤 Recherche vocale |
| **Bouton annuler** | Fermer la recherche |

### Résultats par catégorie

| Catégorie | Icône | Exemples de résultats |
|-----------|-------|----------------------|
| **Exercices** | 🏋️ | "Pompes", "Squats" |
| **Recettes** | 🍽️ | "Poulet curry", "Salade" |
| **Utilisateurs** | 👤 | Profils de membres |
| **Coachs** | 👨‍🏫 | Profils de coachs |
| **Séances** | 📋 | "Full body", "HIIT" |
| **Événements** | 📅 | "Marathon Paris" |

### Suggestions récentes
| Élément | Description |
|---------|-------------|
| **Historique** | Dernières recherches |
| **Tendances** | Recherches populaires |
| **Bouton effacer** | Supprimer l'historique |

---

# ═══════════════════════════════════════════════════════════════
# 👤 ONGLET PROFIL (via header)
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/profile_page.dart`

---

## ACCÈS AU PROFIL

Le profil est accessible via l'icône de photo de profil dans le header.

---

## SECTIONS DU PROFIL

### Header Profil
| Élément | Description |
|---------|-------------|
| **Photo** | Photo de profil (modifiable) |
| **Nom** | Prénom Nom |
| **Badge niveau** | Débutant/Intermédiaire/Expert |
| **Bouton éditer** | ✏️ Modifier le profil |

### Section Informations
| Champ | Description |
|-------|-------------|
| **Email** | Adresse email (lecture seule) |
| **Date de naissance** | JJ/MM/AAAA |
| **Genre** | Homme/Femme/Autre |
| **Taille** | En cm |
| **Poids actuel** | En kg |
| **Poids objectif** | En kg |
| **Objectif principal** | Perte poids, Muscle, etc. |

### Section Paramètres
| Paramètre | Options |
|-----------|---------|
| **Notifications** | On/Off |
| **Thème** | Sombre (par défaut) |
| **Langue** | Français, English |
| **Unités** | kg/cm ou lbs/inches |
| **Profil public** | On/Off |

### Section Abonnement
| Élément | Description |
|---------|-------------|
| **Statut actuel** | Gratuit / Premium / IA |
| **Bouton upgrade** | "Passer Premium" |
| **Gérer** | Modifier/Annuler (si abonné) |

### Section Compte
| Bouton | Action |
|--------|--------|
| **Exporter mes données** | Télécharger en ZIP |
| **Déconnexion** | Se déconnecter |
| **Supprimer mon compte** | ⚠️ Suppression définitive |

### Section Aide
| Bouton | Destination |
|--------|-------------|
| **FAQ** | Questions fréquentes |
| **Support** | Contacter l'équipe |
| **Conditions** | CGU |
| **Confidentialité** | Politique de confidentialité |

---

# ═══════════════════════════════════════════════════════════════
# 🧩 WIDGETS GLOBAUX (présents partout)
# ═══════════════════════════════════════════════════════════════

## 1. Bulle Alter Ego (Chatbot flottant)
| Position | Bas droite de l'écran |
|----------|----------------------|
| **Icône** | Avatar animé |
| **Action tap** | Ouvre le chat |
| **Fonctionnalité** | Questions/réponses IA |

## 2. Barre de navigation (Bottom Nav)
| Onglet | Icône | Label |
|--------|-------|-------|
| 1 | 🏠 | Accueil |
| 2 | 🥗 | Nutrition |
| 3 | 🏋️ | Séances |
| 4 | ⚡ | Avancé |

## 3. Header commun
| Élément | Position | Action |
|---------|----------|--------|
| **Logo** | Gauche | Retour accueil |
| **Titre page** | Centre | - |
| **Recherche** | Droite | Ouvre recherche globale |
| **Messages** | Droite | Ouvre messagerie |
| **Profil** | Droite | Ouvre le profil |

---

# ═══════════════════════════════════════════════════════════════
# 📊 RÉCAPITULATIF VISUEL
# ═══════════════════════════════════════════════════════════════

```
┌─────────────────────────────────────────────────────────────────┐
│                         UKAN APP                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐            │
│  │ ACCUEIL │  │NUTRITION│  │ SÉANCES │  │ AVANCÉ  │            │
│  │         │  │         │  │         │  │         │            │
│  │Dashboard│  │Hub      │  │Biblio   │  │Freemium │            │
│  │  └─Obj  │  │  └─Scan │  │  └─Exos │  │  └─11   │            │
│  │  └─Prog │  │  └─Repas│  │  └─Détai│  │Premium  │            │
│  │  └─Pas  │  │  └─Calc │  │Séances  │  │  └─6    │            │
│  │  └─Somm │  │  └─Recet│  │  └─Progs│  │IA       │            │
│  │         │  │  └─Plan │  │  └─Calen│  │  └─4    │            │
│  │Publicat │  │         │  │         │  │         │            │
│  │  └─Feed │  │         │  │         │  │         │            │
│  │  └─Story│  │         │  │         │  │         │            │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘            │
│                                                                 │
│  [🏠]      [🥗]       [🏋️]       [⚡]                          │
│                                                                 │
│                    🤖 Alter Ego (flottant)                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

> **Document pour l'équipe de développement**  
> UKAN - Contenu détaillé de chaque onglet  
> © 2024 Ukan - Tous droits réservés







