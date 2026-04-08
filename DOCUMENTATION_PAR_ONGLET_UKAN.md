# 📱 DOCUMENTATION UKAN - PAR ONGLET DE LA BARRE DE MENU

> **Document technique pour l'équipe de développement**  
> Organisation : Par onglet de la barre de navigation inférieure  
> Version : 2.0 | Date : Décembre 2024

---

# 🔽 BARRE DE NAVIGATION INFÉRIEURE

La barre de navigation contient **5 onglets** :

| Position | Icône | Nom | Fichier principal |
|----------|-------|-----|-------------------|
| 1 | 🏠 | Accueil | `main.dart` → `DashboardTab` |
| 2 | 🍎 | Nutrition | `nutrition_hub_page.dart` |
| 3 | 💪 | Séances | `exercise_library_page.dart` |
| 4 | ⚡ | Avancé | `espace_pro_screen.dart` |
| 5 | 👤 | Profil | `main.dart` → Section Profil |

---

# ═══════════════════════════════════════════════════════════════
# 🏠 ONGLET 1 : ACCUEIL
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/home/widgets/dashboard_tab.dart`

L'onglet Accueil affiche le tableau de bord principal de l'utilisateur.

---

## 🔝 EN-TÊTE DE L'ONGLET ACCUEIL

### Boutons de navigation (style pill)

| Bouton | Position | Ce qu'il fait |
|--------|----------|---------------|
| **Planning** | Gauche | Ouvre la page `PlanningPage` - Affiche le calendrier des séances planifiées, les événements à venir et permet de planifier de nouvelles séances |
| **Statistiques** | Centre | Ouvre la page `StatsPage` - Affiche les graphiques détaillés : évolution du poids, calories, séances par semaine, progression des objectifs |
| **Icône Messages** | Droite | Ouvre la page `MessageInboxPage` - Boîte de réception avec les conversations avec les coachs et autres utilisateurs |

---

## 📊 CONTENU DU DASHBOARD

### 1️⃣ CARTE OBJECTIF PRINCIPAL

**Ce que c'est :** Grande carte en haut avec bordure dorée

**Ce qu'elle affiche :**
- L'objectif principal de l'utilisateur (ex: "Perte de poids", "Prise de masse", "Tonification")
- La date limite pour atteindre l'objectif
- Une barre de progression vers l'objectif
- Une icône correspondant à l'objectif (🔥 perte, 💪 masse, ✨ tonification)

**Ce qu'elle fait au clic :** Ouvre la page de modification de l'objectif principal

---

### 2️⃣ TAGS OBJECTIFS DE LA SEMAINE

**Ce que c'est :** Barre horizontale scrollable avec des tags dorés

**Ce qu'elle affiche :**
- Tag "3 séances" - Objectif de séances hebdomadaires
- Tag "2000 kcal/jour" - Objectif calorique quotidien
- Tag "2L d'eau/jour" - Objectif d'hydratation
- Tag "8000 pas/jour" - Objectif de pas
- Tag "7h de sommeil" - Objectif de sommeil

**Ce qu'elle fait :** Rappel visuel des micro-objectifs de la semaine

---

### 3️⃣ WIDGET SCORE UKAN

**Ce que c'est :** Carte avec jauge circulaire

**Ce qu'elle affiche :**
- Score Ukan de 0 à 100 (score global de performance)
- Message de motivation selon le score :
  - < 40 : "On pose les bases."
  - 40-70 : "Tu es sur une bonne dynamique."
  - > 70 : "Excellent rythme, continue comme ça."

**Comment le score est calculé :**
- Séances effectuées : jusqu'à 50 points
- Nutrition respectée : jusqu'à 30 points
- Hydratation atteinte : +10 points
- Protéines atteintes : +10 points
- Sommeil respecté : +10 points

---

### 4️⃣ GRILLE "MES OBJECTIFS PERSONNELS" (4 cartes)

#### Carte SÉANCES (haut gauche)

**Ce qu'elle affiche :**
- Icône 💪 violette
- Titre "Séances"
- Compteur "X/3 cette semaine"
- Barre de progression violette
- État : "Objectif atteint ✓" ou "Encore X séance(s)"

**Ce qu'elle fait au clic :** Ouvre `SessionsGoalPage` qui affiche :
- Liste des séances de la semaine
- Détail de chaque séance (durée, calories, exercices)
- Bouton pour ajouter une séance

---

#### Carte CALORIES (bas gauche)

**Ce qu'elle affiche :**
- Icône 🔥 orange
- Titre "Calories"
- Compteur "X / 2000 kcal"
- Barre de progression orange
- État selon les calories :
  - 0 kcal : "Pas encore de repas enregistrés"
  - 1600-2400 : "Dans la bonne zone" (vert)
  - < 1600 : "Très en dessous" (orange)
  - > 2400 : "Au-dessus de l'objectif" (rouge)

**Ce qu'elle fait au clic :** Ouvre `CaloriesGoalPage` qui affiche :
- Répartition des calories par repas
- Graphique de la journée
- Historique des derniers jours

---

#### Carte HYDRATATION (haut droite)

**Ce qu'elle affiche :**
- Icône 💧 bleue
- Titre "Hydratation"
- Compteur "X.X / 2.0 L"
- Jauge circulaire bleue
- Bouton + pour ajouter de l'eau rapidement

**Ce qu'elle fait au clic :** Ouvre `HydrationGoalPage` qui affiche :
- Historique d'hydratation
- Graphique hebdomadaire
- Modifier l'objectif

**Ce que fait le bouton + :** Ouvre `AddWaterPage` pour ajouter une quantité d'eau (verre, bouteille, etc.)

---

#### Carte PROTÉINES (bas droite)

**Ce qu'elle affiche :**
- Icône 🥩 verte
- Titre "Protéines"
- Compteur "Xg / 120g"
- Barre de progression verte

**Ce qu'elle fait au clic :** Ouvre `ProteinGoalPage` qui affiche :
- Sources de protéines du jour
- Répartition par repas
- Suggestions d'aliments riches en protéines

---

### 5️⃣ SECTION "ACTIVITÉ DE LA SEMAINE"

**Ce que c'est :** Graphique à barres

**Ce qu'elle affiche :**
- Titre "Activité de la semaine" avec icône 📈 violette
- Sous-titre "Nombre de séances par jour (L → D)"
- 7 barres verticales (Lundi à Dimanche)
- Hauteur proportionnelle au nombre de séances

**Ce qu'elle fait :** Visualisation rapide de l'activité de la semaine

---

### 6️⃣ SECTION "DISTANCE / PAS DU JOUR"

**Ce que c'est :** Grande carte avec cercle de progression

**Ce qu'elle affiche :**
- Titre "Distance / Pas du jour" avec icône 🚶 verte
- Grand cercle de progression animé
- Nombre de pas au centre (ex: "5 432")
- Objectif en dessous ("/ 8 000 pas")
- Distance calculée ("X.X km")
- Calories estimées ("~XXX kcal")
- Bouton + pour ajouter des pas manuellement

**Ce qu'elle fait au clic :** Ouvre `StepsGoalPage` qui affiche :
- Historique des pas
- Graphique hebdomadaire
- Modifier l'objectif

**Ce que fait le bouton + :** Ouvre `AddStepsPage` pour ajouter des pas manuellement

---

### 7️⃣ SECTION "SOMMEIL"

**Ce que c'est :** Carte avec informations sur le sommeil

**Ce qu'elle affiche :**
- Titre "Sommeil" avec icône 🌙 bleue
- Heures dormies "Xh XXmin"
- Qualité du sommeil ("Excellent", "Bon", "Moyen", "Insuffisant")
- Heure de coucher
- Heure de réveil
- Bouton + pour ajouter une entrée

**Ce qu'elle fait au clic :** Ouvre `SleepGoalPage` qui affiche :
- Historique du sommeil
- Graphique hebdomadaire
- Conseils pour améliorer le sommeil

**Ce que fait le bouton + :** Ouvre `AddSleepPage` pour enregistrer une nuit de sommeil

---

## 📰 SOUS-SECTION : PUBLICATIONS (Feed)

**Fichier :** `lib/feed/feed_page.dart`

Accessible via le sélecteur d'onglet en haut (si implémenté) ou via la navigation.

### En-tête du Feed

| Élément | Position | Ce qu'il fait |
|---------|----------|---------------|
| **Bouton "Mémo"** | Gauche | Ouvre `NotesPage` - Carnet de notes personnel pour noter ses idées, objectifs, rappels |
| **Icône Livre** | Droite | Ouvre `RecipeBookPage` - Mon livre de recettes personnelles sauvegardées |

### Page MÉMO (Notes)

**Ce que c'est :** Carnet de notes personnel

**Ce qu'elle permet :**
- Créer une note avec titre et contenu
- Catégoriser : Entraînement, Nutrition, Motivation, Objectifs, Autre
- Épingler une note importante en haut
- Modifier une note existante
- Supprimer une note

### Grille de Publications

**Ce que c'est :** Grille 3 colonnes style Instagram

**Ce qu'elle affiche :**
- Miniatures des publications de la communauté
- Icône 🍽️ si c'est une recette
- Icône ▶️ si c'est une vidéo

**Ce qu'elle fait au clic :** Ouvre `FeedDetail` avec :
- Photo/vidéo en grand
- Likes et commentaires
- Profil de l'auteur
- Bouton sauvegarder

### Bouton + (FAB)

**Ce qu'il fait :** Ouvre `CreateFeedPostPage` pour créer :
- Publication photo
- Publication recette
- Publication transformation
- Publication séance

---

# ═══════════════════════════════════════════════════════════════
# 🍎 ONGLET 2 : NUTRITION
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/nutrition/nutrition_hub_page.dart`

L'onglet Nutrition est le hub central pour tout ce qui concerne l'alimentation.

---

## 🔝 EN-TÊTE DE L'ONGLET NUTRITION

| Élément | Position | Ce qu'il fait |
|---------|----------|---------------|
| **Flèche retour** | Gauche | Retourne à l'écran précédent |
| **Titre "Nutrition"** | Centre | Affichage du titre avec icône 🍽️ |
| **Icône paramètres** | Droite | Ouvre les paramètres nutrition (objectifs caloriques, macros personnalisés) |

---

## 📊 SECTION 1 : RÉSUMÉ DU JOUR

**Ce que c'est :** Carte récapitulative en haut

**Ce qu'elle affiche :**
- **Jauge circulaire principale** : Calories consommées vs objectif (ex: "1450 / 2200 kcal")
- **Mini jauge Protéines** : "85g / 120g"
- **Mini jauge Glucides** : "180g / 250g"
- **Mini jauge Lipides** : "45g / 70g"
- **Badge Streak** : 🔥 Nombre de jours consécutifs de suivi

---

## ⭐ SECTION 2 : FOODSCAN IA (Grande carte premium)

**Ce que c'est :** Carte animée avec effet de pulsation dorée

**Ce qu'elle affiche :**
- Titre "FoodScan IA™" avec badge PREMIUM
- Sous-titre "Analyse nutritionnelle instantanée par IA"
- 3 boutons d'action
- Bouton principal d'essai

### Les 3 boutons d'action :

| Bouton | Icône | Ce qu'il fait |
|--------|-------|---------------|
| **Photo** | 📷 | Ouvre `FoodScanPhotoDemoPage` - Prendre une photo d'un plat pour analyse IA automatique des calories et macros |
| **Voix** | 🎤 | Ouvre `FoodScanVoiceDemoPage` - Dicter vocalement ce qu'on a mangé pour analyse IA |
| **Analyse** | 📊 | Ouvre `FoodScanHomePage` - Hub complet FoodScan avec historique et statistiques |

### Bouton principal :

**Ce qu'il affiche :** "ESSAYER GRATUITEMENT (3 scans)" ou "S'ABONNER POUR ILLIMITÉ"

**Ce qu'il fait :** Ouvre un dialogue pour essayer gratuitement ou s'abonner

---

## 🔧 SECTION 3 : ACCÈS RAPIDES (Grille de tuiles)

### Tuile 1 : REPAS & COURSES 2.0

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🍽️ |
| **Titre** | "Repas & Courses" |
| **Sous-titre** | "2.0" |
| **Action** | Ouvre `RepasCoursesPage` |

**Page RepasCoursesPage - 3 onglets :**

#### Onglet REPAS :
- Liste des repas du jour (Petit-déjeuner, Déjeuner, Dîner, Collations)
- Pour chaque repas : liste des aliments avec quantité, calories, macros
- Bouton + pour ajouter un aliment
- Total des calories et macros du jour

#### Onglet COURSES :
- Liste de courses générée automatiquement depuis les repas
- Catégories : 🥬 Légumes, 🍎 Fruits, 🥩 Protéines, 🥛 Produits laitiers, 🍞 Féculents, 🍫 Divers
- Checkbox pour cocher les articles achetés
- Bouton + pour ajouter un article personnalisé

#### Onglet CALCULATRICE :
- Pavé numérique (0-9, virgule, effacer)
- Sélecteur d'unité (g, kg, ml, cl, L)
- Sélecteur d'aliment (liste déroulante)
- Opérations (+, -, ×, ÷, =)
- Affichage du total (kcal, protéines, glucides, lipides)
- Historique visuel des aliments ajoutés avec leurs icônes
- Bouton pour créer un aliment personnalisé

---

### Tuile 2 : PLANNING SEMAINE

| Attribut | Valeur |
|----------|--------|
| **Icône** | 📅 |
| **Titre** | "Planning" |
| **Sous-titre** | "Semaine" |
| **Action** | Ouvre `MealPlannerPage` |

**Page MealPlannerPage :**
- Vue hebdomadaire (Lun → Dim)
- Pour chaque jour : cases Petit-déjeuner, Déjeuner, Dîner
- Glisser-déposer des recettes sur les jours
- Total calorique par jour
- Liste de courses automatique générée

---

### Tuile 3 : LISTE COURSES

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🛒 |
| **Titre** | "Liste" |
| **Sous-titre** | "Courses" |
| **Action** | Ouvre `RepasCoursesPage` directement sur l'onglet Courses |

---

### Tuile 4 : CALCULATRICE NUTRITION

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🧮 |
| **Titre** | "Calculatrice" |
| **Sous-titre** | "Nutrition" |
| **Action** | Ouvre `NumericCalculatorPage` |

**Page NumericCalculatorPage :**

**Fonctionnalités détaillées :**
1. **Saisir une quantité** : Taper 150 par exemple
2. **Choisir l'unité** : g, kg, ml, cl, L
3. **Sélectionner un aliment** : Poulet, Riz, Banane, etc.
4. **Ajouter (+)** : Ajoute l'aliment au calcul
5. **Soustraire (-)** : Pour corriger
6. **Multiplier (×)** : Pour les portions
7. **Diviser (÷)** : Pour les portions
8. **Égal (=)** : Affiche le total final
9. **Effacer (C)** : Efface la saisie en cours
10. **Tout effacer (AC)** : Réinitialise tout

**Affichage :**
- Historique des aliments avec icônes (🍗 Poulet 150g + 🍚 Riz 200g)
- Total cumulé : kcal, protéines, glucides, lipides

**Créer un aliment personnalisé :**
- Nom de l'aliment
- Catégorie (Protéines, Féculents, Fruits, etc.)
- Icône (sélection dans la bibliothèque)
- Valeurs pour 100g : kcal, protéines, glucides, lipides
- Prix optionnel

---

### Tuile 5 : SIMULATEUR SEMAINE

| Attribut | Valeur |
|----------|--------|
| **Icône** | 📈 |
| **Titre** | "Simulateur" |
| **Sous-titre** | "Semaine" |
| **Action** | Ouvre `NutritionSimulatorPage` |

**Page NutritionSimulatorPage :**
- Simuler une semaine de repas
- Voir l'impact sur le poids
- Ajuster les portions
- Prévisualiser les résultats

---

### Tuile 6 : AJOUTER REPAS

| Attribut | Valeur |
|----------|--------|
| **Icône** | ➕ |
| **Titre** | "Ajouter" |
| **Sous-titre** | "Repas" |
| **Action** | Ouvre `AddMealPage` |

**Page AddMealPage :**
- Sélectionner le type de repas (Petit-déjeuner, Déjeuner, Dîner, Collation)
- Ajouter des aliments depuis la base de données
- Spécifier les quantités
- Voir le total nutritionnel
- Sauvegarder le repas

---

### Tuile 7 : RECETTES & FIL

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🔍 |
| **Titre** | "Recettes & Fil" |
| **Sous-titre** | "Explorer" |
| **Action** | Ouvre `RecipesFeedPage` |

**Page RecipesFeedPage :**
- Feed de recettes partagées par la communauté
- Filtrer par catégorie (Petit-déjeuner, Déjeuner, etc.)
- Filtrer par régime (Végétarien, Sans gluten, etc.)
- Sauvegarder une recette dans son livre
- Partager une recette

---

### Tuile 8 : BIBLIOTHÈQUE ICÔNES

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🍔 |
| **Titre** | "Bibliothèque" |
| **Sous-titre** | "Icônes" |
| **Action** | Ouvre `FoodIconsLibraryPage` |

**Page FoodIconsLibraryPage :**

**13 catégories d'icônes :**

| Catégorie | Icônes disponibles |
|-----------|-------------------|
| **🍗 Protéines** | Poulet, Bœuf, Poisson, Œufs, Tofu, Tempeh, Crevettes, Saumon, Thon, Dinde... |
| **🍚 Féculents** | Riz, Pâtes, Pain, Pommes de terre, Quinoa, Boulgour, Semoule, Avoine... |
| **🍎 Fruits** | Pomme, Banane, Orange, Fraises, Mangue, Ananas, Kiwi, Raisin, Pêche... |
| **🥬 Légumes** | Brocoli, Carotte, Tomate, Épinards, Courgette, Poivron, Haricots, Salade... |
| **🥛 Produits laitiers** | Lait, Yaourt, Fromage, Beurre, Crème, Skyr, Cottage cheese... |
| **🥑 Graisses** | Avocat, Noix, Amandes, Huile d'olive, Cacahuètes, Noisettes... |
| **🍯 Sucres** | Miel, Sucre, Confiture, Sirop d'érable, Chocolat... |
| **☕ Boissons** | Café, Thé, Jus, Eau, Smoothie, Lait végétal... |
| **🍕 Plats préparés** | Pizza, Burger, Sandwich, Sushi, Tacos, Wrap... |
| **🌶️ Épices** | Poivre, Sel, Curry, Paprika, Cumin, Cannelle, Gingembre... |
| **💊 Compléments** | Whey, BCAA, Créatine, Vitamines, Oméga-3... |
| **🥓 Charcuterie** | Jambon, Bacon, Saucisson, Chorizo, Mortadelle, Pancetta... |
| **🫒 Huiles** | Olive, Tournesol, Coco, Colza, Avocat, Sésame, Lin... |

---

## 🍳 CRÉATION DE RECETTE

**Accessible via :** Bouton + dans RecipesFeedPage ou RecipeBookPage

**Fichier :** `lib/pages/add_recipe_page.dart`

### Étape 1 : Informations de base

| Champ | Description |
|-------|-------------|
| **Nom** | Nom de la recette (obligatoire) |
| **Catégorie** | Petit-déjeuner, Déjeuner, Dîner, Snack, Dessert, Boisson, Sauce, Accompagnement |
| **Description** | Description de la recette |
| **Temps préparation** | En minutes |
| **Temps cuisson** | En minutes |
| **Portions** | Nombre de portions |
| **Difficulté** | Facile, Moyen, Difficile |

### Étape 2 : Photos

- Photo principale (obligatoire)
- Jusqu'à 5 photos supplémentaires
- Prendre une photo ou choisir dans la galerie

### Étape 3 : Ingrédients

- Ajouter des ingrédients avec quantité et unité
- Calcul automatique des valeurs nutritionnelles
- Réorganiser par glisser-déposer

### Étape 4 : Étapes de préparation

- Ajouter des étapes numérotées
- Photo optionnelle par étape
- Réorganiser par glisser-déposer

### Étape 5 : Options

- Sélection des allergènes (Gluten, Lactose, Œufs, etc.)
- Toggle "Partager avec la communauté"
- Ajouter au planning repas

### Résumé final

- Aperçu complet de la recette
- Valeurs nutritionnelles par portion
- Bouton Sauvegarder
- Bouton Partager

---

# ═══════════════════════════════════════════════════════════════
# 💪 ONGLET 3 : SÉANCES
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/exercises/exercise_library_page.dart`

L'onglet Séances contient la bibliothèque d'exercices et les programmes d'entraînement.

---

## 🔝 EN-TÊTE DE L'ONGLET SÉANCES

| Élément | Description |
|---------|-------------|
| **Titre** | "Bibliothèque" |
| **Barre de recherche** | Rechercher un exercice par nom |
| **Icône filtres** | Ouvrir le panneau de filtres |

---

## 📑 4 SOUS-ONGLETS (TabBar)

### ONGLET 1 : EXERCICES

**Ce que c'est :** Liste de tous les exercices disponibles

**Filtres disponibles :**
| Filtre | Options |
|--------|---------|
| **Catégorie** | Toutes, Jambes, Haut du corps, Abdos, Full body, Cardio, Mobilité |
| **Difficulté** | Tous, Débutant, Intermédiaire, Avancé |
| **Source** | Tous, Exercices Ukan, Mes exercices |

**Chaque carte exercice affiche :**
- Image/GIF de l'exercice
- Nom de l'exercice
- Badge catégorie (couleur)
- Badge difficulté (vert/orange/rouge)
- Durée estimée
- Icônes des muscles ciblés

**Au clic sur un exercice :** Ouvre `ExerciseDetailPage` avec :
- Vidéo de démonstration
- Description et instructions détaillées
- Muscles ciblés (avec schéma)
- Équipement nécessaire
- Variantes de l'exercice
- Bouton "Historique" : voir l'historique de cet exercice
- Bouton "Progression" : voir la progression
- Bouton "Défi" : lancer un défi sur cet exercice

**Bouton + (FAB) :** Ouvre `CreateExercisePage` pour créer un exercice personnalisé avec :
- Nom
- Catégorie
- Difficulté
- Description et instructions
- Muscles ciblés
- Équipement
- Vidéo (URL optionnelle)

---

### ONGLET 2 : PROGRAMMES

**Ce que c'est :** Liste des programmes d'entraînement

**Chaque carte programme affiche :**
- Image de couverture
- Nom du programme
- Durée (4, 8, 12 semaines)
- Niveau (Débutant, Intermédiaire, Avancé)
- Objectif (Perte de poids, Prise de masse, Tonification)
- Nombre de séances
- Badge "Ukan" ou "Personnel"

**Au clic sur un programme :** Ouvre la page de détail avec :
- Description complète
- Planning des séances (calendrier)
- Liste de toutes les séances
- Bouton "Commencer" pour démarrer le programme
- Bouton "Modifier" (si programme personnel)

**Bouton + (FAB) :** Ouvre `WorkoutProgramEditPage` pour créer un programme avec :
- Nom et description
- Durée (nombre de semaines)
- Niveau
- Objectif
- Ajouter des séances
- Planifier les jours

---

### ONGLET 3 : CALENDRIER

**Ce que c'est :** Vue calendrier des séances

**Ce qu'il affiche :**
- Calendrier mensuel
- Points colorés sur les jours avec séances :
  - 🟢 Vert : Séance effectuée
  - 🟠 Orange : Séance planifiée (à venir)
  - 🔴 Rouge : Séance manquée
  - ⚪ Gris : Jour de repos

**Au clic sur un jour :** Affiche les séances de ce jour avec :
- Liste des séances
- Détail de chaque séance
- Bouton pour ajouter une séance

---

### ONGLET 4 : HISTORIQUE

**Ce que c'est :** Historique de toutes les séances passées

**Ce qu'il affiche :**
- Statistiques globales : temps total, calories brûlées, nombre de séances
- Graphique d'évolution (séances par semaine)
- Liste chronologique des séances

**Chaque séance dans l'historique affiche :**
- Date et heure
- Nom de la séance/programme
- Durée effective
- Calories brûlées
- Nombre d'exercices
- Note personnelle (si ajoutée)

**Filtres disponibles :**
- Par période (semaine, mois, année)
- Par type de séance
- Par muscle travaillé

---

# ═══════════════════════════════════════════════════════════════
# ⚡ ONGLET 4 : AVANCÉ
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/espace_pro_screen.dart`

L'onglet Avancé regroupe toutes les fonctionnalités avancées, premium et IA.

---

## 🔝 EN-TÊTE DE L'ONGLET AVANCÉ

| Élément | Position | Ce qu'il fait |
|---------|----------|---------------|
| **Titre** | Centre | "Mon Espace Avancé" |
| **Icône aide** | Droite | Ouvre `FaqSupportPage` - FAQ et support |
| **Barre recherche** | Sous le titre | Rechercher une fonctionnalité |

---

## 🏷️ SÉLECTEUR DE CATÉGORIE (3 onglets)

| Onglet | Couleur | Description |
|--------|---------|-------------|
| **Freemium** | Vert | Fonctionnalités gratuites pour tous |
| **Premium** | Or | Fonctionnalités payantes (abonnement) |
| **IA** | Cyan | Fonctionnalités Intelligence Artificielle |

---

## 🆓 CATÉGORIE FREEMIUM (9 fonctionnalités)

### 1. ANALYSE CORPORELLE

| Attribut | Valeur |
|----------|--------|
| **Icône** | 📊 (vert) |
| **Titre** | "Analyse corporelle" |
| **Sous-titre** | "Suivi détaillé de ta composition" |
| **Action** | Ouvre `BodyCompositionPage` |

**Page BodyCompositionPage :**
- Poids actuel et objectif
- Graphique d'évolution du poids
- IMC (Indice de Masse Corporelle) avec interprétation
- Estimation masse grasse (%)
- Estimation masse musculaire (%)
- Historique des mesures
- Ajouter une nouvelle mesure

---

### 2. CHAT COMMUNAUTAIRE

| Attribut | Valeur |
|----------|--------|
| **Icône** | 💬 (bleu) |
| **Titre** | "Chat communautaire" |
| **Sous-titre** | "Discussions entre membres" |
| **Action** | Ouvre `CommunityChatPage` |

**Page CommunityChatPage :**
- Salons de discussion par thème (Motivation, Nutrition, Entraînement, etc.)
- Messages en temps réel
- Envoyer des photos
- Réagir aux messages (likes, emojis)
- Mentionner des utilisateurs (@pseudo)
- Signaler un message inapproprié

---

### 3. CHAT MATCH™

| Attribut | Valeur |
|----------|--------|
| **Icône** | ❤️ (rouge) |
| **Titre** | "Chat Match™" |
| **Sous-titre** | "Trouve des partenaires sportifs" |
| **Action** | Ouvre `MatchHomePage` |

**Page MatchHomePage :**
- Profils de partenaires potentiels (style Tinder)
- Swipe droite = Like, Swipe gauche = Passer
- Score de compatibilité basé sur :
  - Niveau sportif
  - Objectifs similaires
  - Disponibilités communes
  - Proximité géographique
- Chat après match mutuel
- Planifier une séance ensemble

---

### 4. VISIO TRAINING

| Attribut | Valeur |
|----------|--------|
| **Icône** | 📹 (cyan) |
| **Titre** | "Visio Training" |
| **Sous-titre** | "Entraîne-toi en live avec tes amis" |
| **Action** | Ouvre `BuddyHomePage` |

**Page BuddyHomePage :**
- Créer une session visio
- Inviter des amis par lien ou pseudo
- Caméra et micro activables
- Timer partagé pour les exercices
- Chat textuel pendant la session
- Partager son écran (pour montrer un exercice)

---

### 5. SANTÉ & BLESSURES

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🏥 (orange) |
| **Titre** | "Santé & Blessures" |
| **Sous-titre** | "Carnet de suivi médical" |
| **Action** | Ouvre `HealthInjuriesPage` |

**Page HealthInjuriesPage :**
- Liste des blessures passées et actuelles
- Ajouter une blessure (zone, date, gravité, cause)
- Suivi de guérison (progression)
- Exercices à éviter selon les blessures
- Rappels de rendez-vous médicaux
- Notes du médecin/kiné

---

### 6. ANNUAIRE (Coachs & Utilisateurs)

| Attribut | Valeur |
|----------|--------|
| **Icône** | 👥 (violet) |
| **Titre** | "Annuaire" |
| **Sous-titre** | "Coachs & Utilisateurs" |
| **Action** | Ouvre `CoachDirectoryPage` |

**Page CoachDirectoryPage :** (Voir section détaillée ci-dessous)

---

### 7. PERSONNALITÉ COACH

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🧠 (or) |
| **Titre** | "Personnalité Coach" |
| **Sous-titre** | "Personnalise ton assistant" |
| **Action** | Ouvre `CoachPersonalityPage` |

**Page CoachPersonalityPage :**
- Choisir le style de coaching :
  - 🔥 Motivant : Encouragements constants
  - 💪 Strict : Exigence et discipline
  - 😊 Amical : Ton décontracté
  - 📚 Technique : Explications détaillées
- Choisir le ton : Formel, Décontracté, Humoristique
- Fréquence des rappels : Faible, Moyenne, Élevée
- Personnaliser l'avatar de l'assistant

---

### 8. ÉVÉNEMENTS

| Attribut | Valeur |
|----------|--------|
| **Icône** | 📅 (rose) |
| **Titre** | "Événements" |
| **Sous-titre** | "Combats, marathons, compétitions..." |
| **Action** | Ouvre `EventsPage` |

**Page EventsPage :** (Voir section détaillée ci-dessous)

---

### 9. SPORT GAMING™

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🎮 (rouge) |
| **Titre** | "Sport Gaming™" |
| **Sous-titre** | "Le sport comme un jeu" |
| **Action** | Ouvre `StoryHomePage` |

**Page StoryHomePage :**
- Stories interactives gamifiées
- Chapitres à débloquer en faisant du sport
- Défis à relever pour progresser dans l'histoire
- Récompenses et badges à collecter
- Classement entre joueurs

---

## ⭐ CATÉGORIE PREMIUM (6 fonctionnalités)

### 1. COACH BUSINESS™

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🏪 (or) |
| **Titre** | "Coach Business™" |
| **Sous-titre** | "Vends tes programmes" |
| **Action** | Ouvre `CoachBusinessDashboard` |

**Page CoachBusinessDashboard (pour les coachs) :**
- Dashboard des ventes (revenus, clients, conversions)
- Créer un produit (programme, pack vidéo, coaching)
- Gérer les prix et promotions
- Statistiques détaillées
- Gestion des paiements et virements

---

### 2. COURS LIVE

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🎥 (rouge) |
| **Titre** | "Cours Live" |
| **Sous-titre** | "Cours en direct style TikTok" |
| **Action** | Ouvre `GroupClassLivePage` |

**Page GroupClassLivePage :** (Voir section détaillée ci-dessous)

---

### 3. PACK VIDÉOS

| Attribut | Valeur |
|----------|--------|
| **Icône** | 📹 (bleu) |
| **Titre** | "Pack Vidéos" |
| **Sous-titre** | "Vidéos d'exercices détaillées" |
| **Action** | Ouvre `VideoPacksPage` |

**Page VideoPacksPage :**
- Liste des packs vidéo disponibles à l'achat
- Aperçu gratuit de chaque pack
- Acheter un pack
- Télécharger pour regarder hors-ligne
- Suivre sa progression dans les vidéos

---

### 4. REPLAYS

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🔄 (violet) |
| **Titre** | "Replays" |
| **Sous-titre** | "Replays des cours collectifs" |
| **Action** | Ouvre `GroupClassReplaysPage` |

**Page GroupClassReplaysPage :**
- Liste des cours passés disponibles en replay
- Filtrer par catégorie (HIIT, Yoga, Boxe, etc.)
- Filtrer par coach
- Regarder un replay
- Télécharger pour regarder hors-ligne

---

### 5. COACH VS COACH

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🏆 (orange) |
| **Titre** | "Coach vs Coach" |
| **Sous-titre** | "Classement des meilleurs coachs" |
| **Action** | Ouvre `CoachRankingPage` |

**Page CoachRankingPage :**
- Classement des coachs par note moyenne
- Classement par nombre d'élèves
- Classement par revenus générés
- Défis entre coachs
- Badges et récompenses pour les meilleurs

---

### 6. HARD CHALLENGE

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🔥 (rouge) |
| **Titre** | "Hard Challenge" |
| **Sous-titre** | "Défis intensifs 30/50/75/90 jours" |
| **Action** | Ouvre `HardChallengePage` |

**Page HardChallengePage :** (Voir section détaillée ci-dessous)

---

## 🤖 CATÉGORIE IA (4 fonctionnalités)

### 1. COACH IA PREMIUM

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🎯 (cyan) |
| **Titre** | "Coach IA Premium" |
| **Sous-titre** | "Analyse posture en temps réel" |
| **Action** | Ouvre `CoachIAPremiumPage` |

**Page CoachIAPremiumPage :**
- Activer la caméra en temps réel
- L'IA analyse la posture pendant les exercices
- Corrections vocales en temps réel ("Redresse le dos", "Plie plus les genoux")
- Score de forme pour chaque répétition
- Historique des analyses avec progression

---

### 2. FOODSCAN IA

| Attribut | Valeur |
|----------|--------|
| **Icône** | 📸 (vert) |
| **Titre** | "FoodScan IA" |
| **Sous-titre** | "Analyse repas par IA" |
| **Action** | Ouvre `FoodScanHomePage` |

**Page FoodScanHomePage :**
- Scanner un plat par photo
- Scanner par description vocale
- L'IA identifie les aliments et estime les quantités
- Calcul automatique des calories et macros
- Historique des scans
- Suggestions pour améliorer l'équilibre nutritionnel

---

### 3. MON ALTER EGO

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🤖 (violet) |
| **Titre** | "Mon Alter Ego" |
| **Sous-titre** | "Ton assistant personnel IA" |
| **Action** | Ouvre `AlterEgoScreen` |

**Page AlterEgoScreen :**
- Chat avec l'assistant IA personnalisé
- Poser des questions sur l'entraînement
- Demander des conseils nutrition
- Recevoir de la motivation personnalisée
- L'IA connaît ton historique et tes objectifs

---

### 4. TRANSFORMATION IA

| Attribut | Valeur |
|----------|--------|
| **Icône** | 🔮 (orange) |
| **Titre** | "Transformation IA" |
| **Sous-titre** | "Visualise ton futur corps" |
| **Action** | Ouvre `RAFuturePreviewPage` |

**Page RAFuturePreviewPage :**
- Uploader une photo actuelle de son corps
- Sélectionner un objectif (perte de poids, prise de masse)
- L'IA génère une image du futur corps possible
- Comparaison avant/après
- Partager sur les réseaux sociaux

---

# 📍 PAGE DÉTAILLÉE : ANNUAIRE (CoachDirectoryPage)

**Fichier :** `lib/coach_directory_page.dart`

## Structure de la page

### En-tête

| Élément | Ce qu'il fait |
|---------|---------------|
| **Flèche retour** | Retourne à l'onglet Avancé |
| **Titre "Rechercher"** | - |
| **Barre de recherche** | Rechercher par nom, spécialité ou ville |
| **Icône filtres** | Ouvre le panneau de filtres |
| **Icône carte** | Ouvre `CoachMapPage` - Vue carte avec les coachs géolocalisés |

### Panneau de filtres

| Filtre | Options disponibles |
|--------|---------------------|
| **Spécialité** | Perte de poids, Prise de masse, Fitness, Boxe, Yoga, Cardio, CrossFit, Nutrition, Course, Danse, MMA, Judo |
| **Distance** | 5km, 10km, 25km, 50km, 100km, Illimité |
| **Note minimum** | 3★, 3.5★, 4★, 4.5★ |
| **Prix** | € (économique), €€ (moyen), €€€ (premium) |
| **Disponibilité** | En ligne, Présentiel, Les deux |

### Affichage par catégorie (quand pas de recherche)

Les coachs sont groupés par spécialité avec un header coloré :

| Spécialité | Emoji | Couleur |
|------------|-------|---------|
| Perte de poids | 🔥 | Orange |
| Prise de masse | 💪 | Or |
| Fitness | ✨ | Vert |
| Boxe | 🥊 | Rouge |
| Yoga | 🧘 | Cyan |
| Cardio | ❤️ | Rose |
| CrossFit | 🏋️ | Bleu |
| Nutrition | 🥗 | Vert clair |
| Course | 🏃 | Bleu clair |
| Danse | 💃 | Violet |
| MMA | 🤼 | Rouge foncé |
| Judo | 🥋 | Gris |

### Carte coach

Chaque coach est affiché dans une carte avec :
- Photo de profil (ronde)
- Badge ✓ si vérifié
- Nom complet
- Spécialité (badge coloré)
- Note (⭐ 4.8)
- Ville
- Prix indicatif (€, €€, €€€)
- Disponibilité (En ligne / Présentiel)

**Au clic :** Ouvre `CoachDetailPage` avec le profil complet du coach

---

# 📅 PAGE DÉTAILLÉE : ÉVÉNEMENTS (EventsPage)

**Fichier :** `lib/events/events_page.dart`

## Structure de la page

### Filtres par catégorie (barre scrollable)

| Catégorie | Emoji |
|-----------|-------|
| Tous | 📅 |
| Boxe | 🥊 |
| MMA | 🤼 |
| Marathon | 🏃 |
| CrossFit | 🏋️ |
| Musculation | 💪 |
| Yoga | 🧘 |
| Danse | 💃 |
| Cyclisme | 🚴 |

### Carte événement

Chaque événement affiche :
- Image de couverture
- Badge catégorie
- Nom de l'événement
- 📅 Date et 🕐 heure
- 📍 Lieu
- 💰 Prix (ou "Gratuit")
- 👥 Participants (X/Y inscrits)
- Organisateur
- Bouton "Participer" / "S'inscrire"

### Création d'événement (FAB +)

| Champ | Description |
|-------|-------------|
| Nom | Titre de l'événement |
| Catégorie | Type de sport |
| Date | Sélecteur de date |
| Heure | Sélecteur d'heure |
| Lieu | Adresse avec carte |
| Description | Détails de l'événement |
| Prix | En € (0 = gratuit) |
| Max participants | Limite de places |
| Image | Photo de couverture |
| Contact | Email/téléphone organisateur |

---

# 🎥 PAGE DÉTAILLÉE : COURS COLLECTIFS LIVE

**Fichier :** `lib/group_classes/group_class_live.dart`

## Onglet PLANNING

**Fichier :** `lib/group_classes/group_class_planning_page.dart`

### Sélecteur de jour

Barre horizontale : Lun, Mar, Mer, Jeu, Ven, Sam, Dim
- Jour actif surligné en doré
- Point indicateur si cours ce jour

### Filtres catégorie

| Catégorie | Emoji | Couleur |
|-----------|-------|---------|
| Tous | 🎯 | Or |
| HIIT | 🔥 | Orange |
| Yoga | 🧘 | Vert |
| Boxe | 🥊 | Rouge |
| Danse | 💃 | Rose |
| Musculation | 💪 | Or |
| Cardio | ❤️ | Rouge |
| Pilates | 🤸 | Violet |
| Stretching | 🧘‍♀️ | Bleu |
| CrossFit | 🏋️ | Bleu foncé |
| Zumba | 🎉 | Rose vif |
| Judo | 🥋 | Blanc |
| MMA | 🤼 | Rouge foncé |
| Karaté | 🥷 | Noir |
| Cycling | 🚴 | Vert |

### Carte cours

| Élément | Description |
|---------|-------------|
| Heure | Badge "10:00" |
| Nom | "HIIT Brûle-Graisses" |
| Coach | Photo + nom |
| Niveau | Débutant/Intermédiaire/Avancé |
| Durée | "45 min" |
| Prix | "15,00 €" |
| Participants | Barre de progression "12/20" |
| Bouton Démo | "Voir démo (5 min)" - Gratuit |
| Bouton Participer | "Participer - 15,00 €" |

### Création de cours (pour les coachs)

**Fichier :** `lib/group_classes/group_class_create_page.dart`

| Champ | Description |
|-------|-------------|
| Nom | Titre du cours |
| Description | Description détaillée |
| Catégorie | Type de cours |
| Niveau | Débutant/Intermédiaire/Avancé |
| Date | Sélecteur de date |
| Heure | Sélecteur d'heure |
| Durée totale | En minutes |
| Prix | En € |
| Durée démo | Minutes de démo gratuite |
| Max participants | Limite de places |
| Équipement | Matériel nécessaire |
| Récurrence | Unique/Hebdomadaire/Quotidien |

---

# 🔥 PAGE DÉTAILLÉE : HARD CHALLENGE

**Fichier :** `lib/hard_challenge/hard_challenge_page.dart`

## Section 1 : Résumé

- Nom du challenge
- Jour actuel "Jour 23 / 75"
- Barre de progression globale
- 🔥 Streak (jours consécutifs réussis)
- Bouton Partager

## Section 2 : Habitudes quotidiennes

| Habitude | Icône | Unité | Exemple |
|----------|-------|-------|---------|
| Hydratation | 💧 | Litres | 3L |
| Pas | 🚶 | Pas | 10 000 |
| Séance | 💪 | Oui/Non | 1 |
| Pompes | 🏋️ | Répétitions | 100 |
| Squats | 🦵 | Répétitions | 100 |
| Planche | 🧘 | Secondes | 300 |
| Course | 🏃 | Kilomètres | 5 |
| Corde | ⏱️ | Minutes | 15 |
| Burpees | 🔥 | Répétitions | 50 |
| Abdos | 💪 | Répétitions | 100 |

## Section 3 : Calendrier

- Vue mensuelle
- 🟢 Vert = Réussi
- 🟠 Orange = Partiel
- 🔴 Rouge = Échoué
- ⚪ Gris = Futur

## Section 4 : Participants

- Liste des participants au challenge
- Leur progression
- Bouton Inviter

## Section 5 : Challenges populaires (carrousel)

| Template | Durée |
|----------|-------|
| 30 Push-ups | 30 jours |
| 50 Squats | 50 jours |
| Planche 5 min | 30 jours |
| 10K Steps | 75 jours |
| 75 Hard Sport | 75 jours |
| 3K Run | 30 jours |
| 100 Burpees | 30 jours |
| Jump Rope | 50 jours |

## Création de challenge

**Fichier :** `lib/hard_challenge/create_challenge_page.dart`

### Étape 1 : Nom, durée (30/50/75/90 jours), motivation
### Étape 2 : Objectifs quotidiens (type, valeur, unité, progression)
### Étape 3 : Options (photo obligatoire, rappel)
### Étape 4 : Résumé et création

---

# ═══════════════════════════════════════════════════════════════
# 👤 ONGLET 5 : PROFIL
# ═══════════════════════════════════════════════════════════════

**Fichier :** Intégré dans `main.dart`

---

## 🔝 EN-TÊTE DU PROFIL

| Élément | Description |
|---------|-------------|
| **Photo de profil** | Photo ronde, modifiable |
| **Nom** | Nom complet de l'utilisateur |
| **Bio** | Description courte |
| **Bouton Modifier** | Ouvre `EditProfilePage` |

---

## 📊 STATISTIQUES RAPIDES

| Stat | Description |
|------|-------------|
| **Séances** | Nombre total de séances effectuées |
| **Jours actifs** | Nombre de jours avec activité |
| **Streak max** | Plus longue série de jours consécutifs |

---

## 📋 SECTIONS DU PROFIL

### Section 1 : MES OBJECTIFS

| Élément | Description |
|---------|-------------|
| Objectif principal | Avec barre de progression |
| Date limite | Deadline pour atteindre l'objectif |
| Bouton Modifier | Changer l'objectif |

---

### Section 2 : MES ACHATS

| Élément | Description |
|---------|-------------|
| Programmes achetés | Liste des programmes payants acquis |
| Packs vidéos | Vidéos achetées |
| Abonnements | Abonnements actifs (Premium, etc.) |

---

### Section 3 : PARRAINAGE

| Élément | Description |
|---------|-------------|
| Code parrain | Mon code unique à partager |
| Bouton Partager | Partager le code par SMS, email, réseaux |
| Filleuls | Nombre de personnes parrainées |
| Gains | Récompenses gagnées grâce au parrainage |

---

### Section 4 : PARAMÈTRES

| Paramètre | Options |
|-----------|---------|
| **Notifications** | On/Off par type (rappels, messages, etc.) |
| **Thème** | Clair / Sombre / Automatique |
| **Langue** | Français, Anglais, Espagnol, etc. |
| **Unités** | Métrique (kg, km) / Impérial (lbs, miles) |
| **Confidentialité** | Profil public / privé |
| **Compte** | Modifier email, mot de passe |
| **Déconnexion** | Se déconnecter de l'application |
| **Supprimer compte** | Supprimer définitivement le compte |

---

# 🎨 ANNEXE : CODES COULEURS

| Variable | Hex | Utilisation |
|----------|-----|-------------|
| `_darkBg` | `#0D1117` | Fond principal de l'app |
| `_cardBg` | `#161B22` | Fond des cartes |
| `_cardBgLight` | `#21262D` | Fond des cartes secondaires |
| `_primaryGold` | `#FFC300` | Couleur principale (boutons, accents) |
| `_primaryBlue` | `#58A6FF` | Liens, éléments interactifs |
| `_primaryGreen` | `#4ECDC4` | Succès, validation, hydratation |
| `_primaryOrange` | `#FF9F43` | Avertissements, calories |
| `_primaryPurple` | `#A855F7` | Premium, séances |
| `_primaryRed` | `#FF6B6B` | Erreurs, alertes |
| `_primaryCyan` | `#22D3EE` | IA, technologie |
| `_textLight` | `#F0F6FC` | Texte principal (blanc) |
| `_textMuted` | `#8B949E` | Texte secondaire (gris) |
| `_borderColor` | `#30363D` | Bordures des cartes |

---

> **Document généré pour l'équipe de développement Ukan**  
> Organisation par onglet de la barre de navigation  
> © 2024 Ukan - Tous droits réservés








