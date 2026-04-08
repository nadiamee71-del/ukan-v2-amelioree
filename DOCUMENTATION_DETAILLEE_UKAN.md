# 📱 DOCUMENTATION ULTRA-DÉTAILLÉE - APPLICATION UKAN

> **Document technique complet pour l'équipe de développement**  
> Chaque élément, tuile, bouton et fonctionnalité est décrit en détail.  
> Version : 2.0 | Date : Décembre 2024

---

# 🏠 ONGLET 1 : ACCUEIL

L'onglet Accueil est accessible via l'icône 🏠 dans la barre de navigation inférieure.
Il contient **2 sous-onglets** accessibles via un sélecteur en haut de page.

---

## 📊 SOUS-ONGLET 1.1 : DASHBOARD (Tableau de bord)

### 🔝 BARRE SUPÉRIEURE

| Élément | Position | Description | Action au clic |
|---------|----------|-------------|----------------|
| **Bouton "Planning"** | Gauche | Bouton pill doré avec texte "Planning" | Ouvre la page `PlanningPage` - Calendrier des séances et événements planifiés |
| **Bouton "Statistiques"** | Centre-gauche | Bouton pill avec texte "Statistiques" | Ouvre la page `StatsPage` - Graphiques et statistiques détaillées |
| **Icône Messages** | Droite | Icône enveloppe dorée dans un cercle | Ouvre la page `MessageInboxPage` - Boîte de réception des messages |

---

### 🎯 SECTION 1 : OBJECTIF PRINCIPAL

**Fichier :** `_buildMainGoalSection()`

| Élément | Description | Données affichées |
|---------|-------------|-------------------|
| **Carte gradient doré** | Conteneur principal avec bordure dorée | - |
| **Icône objectif** | Icône correspondant à l'objectif (🔥 perte de poids, 💪 prise de masse, etc.) | Dépend du profil utilisateur |
| **Titre objectif** | Texte de l'objectif principal | Ex: "Perte de poids", "Prise de masse", "Tonification" |
| **Date limite** | Deadline pour atteindre l'objectif | Ex: "Objectif : 15 Mars 2025" |
| **Barre de progression** | Progression vers l'objectif | Pourcentage de progression |

**Action au clic :** Ouvre la page de modification de l'objectif principal.

---

### 🏷️ SECTION 2 : OBJECTIFS DE LA SEMAINE

**Fichier :** `_buildWeeklyGoalsSection()`

**Description :** Barre horizontale scrollable avec des tags dorés représentant les micro-objectifs de la semaine.

| Tag | Description | Exemple |
|-----|-------------|---------|
| **Tag 1** | Objectif séances | "3 séances" |
| **Tag 2** | Objectif calories | "2000 kcal/jour" |
| **Tag 3** | Objectif hydratation | "2L d'eau/jour" |
| **Tag 4** | Objectif pas | "8000 pas/jour" |
| **Tag 5** | Objectif sommeil | "7h de sommeil" |

---

### 📈 SECTION 3 : PROGRESSION GLOBALE

**Fichier :** `_buildWeeklyProgressWidget()`

| Élément | Description | Données |
|---------|-------------|---------|
| **Score Ukan** | Score global de 0 à 100 | Calculé selon : séances (50pts max), nutrition (30pts max), hydratation (10pts), protéines (10pts), sommeil (10pts) |
| **Texte motivation** | Message selon le score | < 40 : "On pose les bases" / 40-70 : "Tu es sur une bonne dynamique" / > 70 : "Excellent rythme" |
| **Jauge circulaire** | Visualisation du score | Cercle de progression animé |

---

### 💪 SECTION 4 : MES OBJECTIFS PERSONNELS (4 cartes)

Disposition : **2 colonnes x 2 lignes**

#### 📋 Carte 1 : OBJECTIF SÉANCES (colonne gauche, haut)

**Fichier :** `_buildSessionsGoalCard()`

| Élément | Description |
|---------|-------------|
| **Icône** | 💪 Icône haltère violette |
| **Titre** | "Séances" |
| **Compteur** | "X/3 cette semaine" (X = nombre de séances effectuées) |
| **Barre de progression** | Progression violette vers l'objectif de 3 séances |
| **Texte état** | "Objectif atteint ✓" ou "Encore X séance(s)" |

**Action au clic :** Ouvre `SessionsGoalPage` - Page de détail des séances de la semaine.

---

#### 🔥 Carte 2 : OBJECTIF CALORIES (colonne gauche, bas)

**Fichier :** `_buildCaloriesGoalCard()`

| Élément | Description |
|---------|-------------|
| **Icône** | 🔥 Icône flamme orange |
| **Titre** | "Calories" |
| **Compteur** | "X / 2000 kcal" (X = calories consommées aujourd'hui) |
| **Barre de progression** | Progression orange vers l'objectif |
| **Texte état** | "Dans la bonne zone" / "En dessous" / "Au-dessus" |

**Action au clic :** Ouvre `CaloriesGoalPage` - Détail des calories par repas.

---

#### 💧 Carte 3 : HYDRATATION (colonne droite, haut)

**Fichier :** `_buildHydrationCard()`

| Élément | Description |
|---------|-------------|
| **Icône** | 💧 Icône goutte bleue |
| **Titre** | "Hydratation" |
| **Compteur** | "X.X / 2.0 L" (X = litres d'eau bus aujourd'hui) |
| **Jauge circulaire** | Cercle de progression bleu |
| **Bouton +** | Ajouter de l'eau rapidement |

**Action au clic sur la carte :** Ouvre `HydrationGoalPage` - Historique et objectifs d'hydratation.
**Action au clic sur + :** Ouvre `AddWaterPage` - Ajouter une quantité d'eau.

---

#### 🥩 Carte 4 : PROTÉINES (colonne droite, bas)

**Fichier :** `_buildProteinCard()`

| Élément | Description |
|---------|-------------|
| **Icône** | 🥩 Icône viande verte |
| **Titre** | "Protéines" |
| **Compteur** | "Xg / 120g" (X = protéines consommées aujourd'hui) |
| **Barre de progression** | Progression verte vers l'objectif |

**Action au clic :** Ouvre `ProteinGoalPage` - Détail des sources de protéines.

---

### 📊 SECTION 5 : ACTIVITÉ DE LA SEMAINE

**Fichier :** `_buildWeekGraph()`

| Élément | Description |
|---------|-------------|
| **Titre section** | "Activité de la semaine" avec icône 📈 violette |
| **Sous-titre** | "Nombre de séances par jour (L → D)" |
| **Graphique barres** | 7 barres verticales (Lun → Dim) |
| **Couleur barres** | Violet dégradé, hauteur proportionnelle au nombre de séances |
| **Labels jours** | L, M, M, J, V, S, D |

**Données :** Nombre de séances effectuées chaque jour de la semaine en cours.

---

### 🚶 SECTION 6 : DISTANCE / PAS DU JOUR

**Fichier :** `_buildStepsCard()`

| Élément | Description |
|---------|-------------|
| **Titre section** | "Distance / Pas du jour" avec icône 🚶 verte |
| **Grand cercle** | Cercle de progression animé (vert) |
| **Nombre de pas** | Grand chiffre au centre (ex: "5 432") |
| **Objectif** | "/ 8 000 pas" en dessous |
| **Distance** | "X.X km" calculée depuis les pas |
| **Calories brûlées** | "~XXX kcal" estimation |
| **Bouton +** | Ajouter des pas manuellement |

**Action au clic sur la carte :** Ouvre `StepsGoalPage` - Historique des pas.
**Action au clic sur + :** Ouvre `AddStepsPage` - Ajouter des pas manuellement.

---

### 😴 SECTION 7 : SOMMEIL

**Fichier :** `_buildSleepCard()`

| Élément | Description |
|---------|-------------|
| **Titre section** | "Sommeil" avec icône 🌙 bleue |
| **Carte sommeil** | Conteneur avec gradient bleu |
| **Heures dormies** | "Xh XXmin" (dernière nuit) |
| **Qualité** | "Excellent" / "Bon" / "Moyen" / "Insuffisant" |
| **Heure coucher** | "Couché à XXhXX" |
| **Heure réveil** | "Réveillé à XXhXX" |
| **Bouton +** | Ajouter une entrée sommeil |

**Action au clic sur la carte :** Ouvre `SleepGoalPage` - Historique du sommeil.
**Action au clic sur + :** Ouvre `AddSleepPage` - Enregistrer une nuit de sommeil.

---

## 📰 SOUS-ONGLET 1.2 : PUBLICATIONS (Feed)

**Fichier :** `lib/feed/feed_page.dart`

### 🔝 BARRE SUPÉRIEURE

| Élément | Position | Description | Action au clic |
|---------|----------|-------------|----------------|
| **Bouton "Mémo"** | Gauche | Bouton doré avec icône 📝 et texte "Mémo" | Ouvre `NotesPage` - Carnet de notes personnel |
| **Icône Livre** | Droite | Icône livre dans cercle orange | Ouvre `RecipeBookPage` - Mon livre de recettes personnel |

---

### 📝 PAGE MÉMO (Notes)

**Fichier :** `lib/pages/notes_page.dart`

| Fonctionnalité | Description |
|----------------|-------------|
| **Liste des notes** | Affiche toutes les notes créées |
| **Filtres catégorie** | Toutes, Entraînement, Nutrition, Motivation, Objectifs, Autre |
| **Créer une note** | Bouton + pour créer une nouvelle note |
| **Épingler** | Icône 📌 pour épingler une note en haut |
| **Modifier** | Tap sur une note pour la modifier |
| **Supprimer** | Swipe gauche ou icône corbeille |

**Structure d'une note :**
- Titre (obligatoire)
- Contenu (texte libre)
- Catégorie (sélection)
- Date de création (automatique)
- Épinglé (oui/non)

---

### 📸 GRILLE DE PUBLICATIONS

| Élément | Description |
|---------|-------------|
| **Grille 3 colonnes** | Affichage style Instagram |
| **Miniatures** | Images carrées des publications |
| **Icône recette** | 🍽️ si c'est une recette |
| **Icône vidéo** | ▶️ si c'est une vidéo |

**Action au clic sur une publication :** Ouvre `FeedDetail` - Détail de la publication avec commentaires et likes.

---

### ➕ BOUTON FLOTTANT (FAB)

| Élément | Description | Action |
|---------|-------------|--------|
| **FAB +** | Bouton flottant doré en bas à droite | Ouvre `CreateFeedPostPage` - Créer une nouvelle publication |

**Types de publications créables :**
- 📸 Photo simple
- 🍽️ Recette
- 💪 Transformation
- 🏋️ Séance d'entraînement
- 📝 Texte

---

# 🍎 ONGLET 2 : NUTRITION

**Fichier principal :** `lib/nutrition/nutrition_hub_page.dart`

L'onglet Nutrition est accessible via l'icône 🍎 dans la barre de navigation inférieure.

---

## 🔝 BARRE SUPÉRIEURE

| Élément | Position | Description | Action |
|---------|----------|-------------|--------|
| **Flèche retour** | Gauche | Retour à l'écran précédent | `Navigator.pop()` |
| **Titre "Nutrition"** | Centre | Titre avec icône 🍽️ | - |
| **Icône paramètres** | Droite | Roue dentée | Ouvre les paramètres nutrition (objectifs caloriques, macros) |

---

## 📊 SECTION 1 : RÉSUMÉ DU JOUR

**Fichier :** `_buildDailySummary()`

| Élément | Description | Données |
|---------|-------------|---------|
| **Calories** | Jauge circulaire principale | "1450 / 2200 kcal" |
| **Protéines** | Mini jauge | "85g / 120g" |
| **Glucides** | Mini jauge | "180g / 250g" |
| **Lipides** | Mini jauge | "45g / 70g" |
| **Streak** | Badge flamme | "🔥 5 jours" (jours consécutifs de suivi) |

---

## ⭐ SECTION 2 : FOODSCAN IA (Hero Card)

**Fichier :** `_buildFoodScanHero()`

**Description :** Grande carte premium avec animation de pulsation et glow doré.

| Élément | Description | Action |
|---------|-------------|--------|
| **Titre** | "FoodScan IA™" avec badge PREMIUM | - |
| **Sous-titre** | "Analyse nutritionnelle instantanée par IA" | - |
| **Bouton Photo** | Icône 📷 "Photo" | Ouvre `FoodScanPhotoDemoPage` - Scanner un plat par photo |
| **Bouton Voix** | Icône 🎤 "Voix" | Ouvre `FoodScanVoiceDemoPage` - Dicter un repas |
| **Bouton Analyse** | Icône 📊 "Analyse" | Ouvre `FoodScanHomePage` - Hub FoodScan complet |
| **CTA Principal** | "ESSAYER GRATUITEMENT (3 scans)" | Ouvre dialog d'essai gratuit |

---

## 🔧 SECTION 3 : ACCÈS RAPIDES (Grille 2x4)

**Fichier :** `_buildQuickAccessSection()`

### Ligne 1 :

| Tuile | Icône | Titre | Sous-titre | Action |
|-------|-------|-------|------------|--------|
| **Tuile 1** | 🍽️ | "Repas & Courses" | "2.0" | Ouvre `RepasCoursesPage` |
| **Tuile 2** | 📅 | "Planning" | "Semaine" | Ouvre `MealPlannerPage` |

### Ligne 2 :

| Tuile | Icône | Titre | Sous-titre | Action |
|-------|-------|-------|------------|--------|
| **Tuile 3** | 🛒 | "Liste" | "Courses" | Ouvre `RepasCoursesPage` (onglet Courses) |
| **Tuile 4** | 🧮 | "Calculatrice" | "Nutrition" | Ouvre `NumericCalculatorPage` |

### Ligne 3 :

| Tuile | Icône | Titre | Sous-titre | Action |
|-------|-------|-------|------------|--------|
| **Tuile 5** | 📈 | "Simulateur" | "Semaine" | Ouvre `NutritionSimulatorPage` |
| **Tuile 6** | ➕ | "Ajouter" | "Repas" | Ouvre `AddMealPage` |

### Ligne 4 :

| Tuile | Icône | Titre | Sous-titre | Action |
|-------|-------|-------|------------|--------|
| **Tuile 7** | 🔍 | "Recettes & Fil" | "Explorer" | Ouvre `RecipesFeedPage` |
| **Tuile 8** | 🍔 | "Bibliothèque" | "Icônes" | Ouvre `FoodIconsLibraryPage` |

---

## 📱 PAGE : REPAS & COURSES 2.0

**Fichier :** `lib/features/nutrition/repas_courses_page.dart`

Cette page contient **3 onglets** accessibles via une TabBar.

---

### 🍽️ ONGLET 1 : REPAS DU JOUR

| Section | Description |
|---------|-------------|
| **Résumé journée** | Total calories, protéines, glucides, lipides du jour |
| **Petit-déjeuner** | Liste des aliments du petit-déjeuner avec quantités et macros |
| **Déjeuner** | Liste des aliments du déjeuner avec quantités et macros |
| **Dîner** | Liste des aliments du dîner avec quantités et macros |
| **Collations** | Liste des collations avec quantités et macros |

**Pour chaque repas :**

| Élément | Description |
|---------|-------------|
| **Titre repas** | "Petit-déjeuner", "Déjeuner", etc. |
| **Total kcal** | Calories totales du repas |
| **Liste aliments** | Chaque aliment avec : icône, nom, quantité (g), kcal, P/G/L |
| **Bouton +** | Ajouter un aliment à ce repas |
| **Bouton modifier** | Modifier les quantités |
| **Bouton supprimer** | Supprimer un aliment |

---

### 🛒 ONGLET 2 : LISTE DE COURSES

| Section | Description |
|---------|-------------|
| **Catégories** | Légumes, Fruits, Protéines, Produits laitiers, Féculents, Épices |
| **Articles** | Liste des articles à acheter par catégorie |
| **Checkbox** | Cocher les articles achetés |
| **Bouton +** | Ajouter un article personnalisé |

**Structure d'une catégorie :**

| Élément | Description |
|---------|-------------|
| **Icône catégorie** | 🥬 Légumes, 🍎 Fruits, 🥩 Protéines, etc. |
| **Titre catégorie** | Nom de la catégorie |
| **Liste articles** | Articles avec checkbox |
| **Compteur** | "X/Y achetés" |

---

### 🧮 ONGLET 3 : CALCULATRICE

**Fichier :** `lib/features/nutrition/calculator/numeric_calculator_page.dart`

| Zone | Description |
|------|-------------|
| **Écran d'affichage** | Affiche le nombre saisi et l'historique des calculs |
| **Sélecteur d'unité** | g, kg, ml, cl, L |
| **Sélecteur d'aliment** | Liste déroulante des aliments disponibles |
| **Pavé numérique** | Touches 0-9, virgule, effacer |
| **Opérations** | +, -, ×, ÷, = |
| **Résultat** | Total kcal, protéines, glucides, lipides |

**Fonctionnalités détaillées :**

| Fonction | Description |
|----------|-------------|
| **Saisie quantité** | Taper un nombre (ex: 150) |
| **Sélection unité** | Choisir g, kg, ml, cl ou L |
| **Sélection aliment** | Choisir un aliment dans la liste |
| **Addition (+)** | Ajouter un autre aliment |
| **Soustraction (-)** | Soustraire (correction) |
| **Multiplication (×)** | Multiplier la quantité |
| **Division (÷)** | Diviser la quantité |
| **Égal (=)** | Calculer le total final |
| **Effacer (C)** | Effacer la saisie en cours |
| **Effacer tout (AC)** | Réinitialiser complètement |

**Historique visuel :**
- Affiche chaque aliment ajouté avec son icône
- Montre la quantité et l'unité
- Affiche l'opération (+, -, etc.)
- Total cumulé en bas

**Bouton "Ajouter aliment personnalisé" :**

| Champ | Description |
|-------|-------------|
| **Nom** | Nom de l'aliment |
| **Catégorie** | Protéines, Féculents, Fruits, etc. |
| **Icône** | Sélection dans la bibliothèque |
| **Calories/100g** | Valeur énergétique |
| **Protéines/100g** | Grammes de protéines |
| **Glucides/100g** | Grammes de glucides |
| **Lipides/100g** | Grammes de lipides |
| **Prix (optionnel)** | Prix au kg ou à l'unité |

---

## 📚 PAGE : BIBLIOTHÈQUE D'ICÔNES

**Fichier :** `lib/features/nutrition/food_icons_library_page.dart`

**Description :** Bibliothèque complète d'icônes/emojis alimentaires organisée par catégorie.

### Catégories disponibles (13) :

| # | Catégorie | Emoji | Nombre d'icônes | Exemples |
|---|-----------|-------|-----------------|----------|
| 1 | **Protéines** | 🍗 | 15+ | Poulet, Bœuf, Poisson, Œufs, Tofu, Tempeh |
| 2 | **Féculents** | 🍚 | 12+ | Riz, Pâtes, Pain, Pommes de terre, Quinoa |
| 3 | **Fruits** | 🍎 | 20+ | Pomme, Banane, Orange, Fraises, Mangue |
| 4 | **Légumes** | 🥬 | 20+ | Brocoli, Carotte, Tomate, Épinards, Courgette |
| 5 | **Produits laitiers** | 🥛 | 10+ | Lait, Yaourt, Fromage, Beurre, Crème |
| 6 | **Graisses** | 🥑 | 10+ | Avocat, Noix, Amandes, Huile d'olive |
| 7 | **Sucres** | 🍯 | 8+ | Miel, Sucre, Confiture, Sirop d'érable |
| 8 | **Boissons** | ☕ | 12+ | Café, Thé, Jus, Eau, Smoothie |
| 9 | **Plats préparés** | 🍕 | 15+ | Pizza, Burger, Sandwich, Sushi |
| 10 | **Épices** | 🌶️ | 10+ | Poivre, Sel, Curry, Paprika, Cumin |
| 11 | **Compléments** | 💊 | 8+ | Whey, BCAA, Créatine, Vitamines |
| 12 | **Charcuterie** | 🥓 | 12+ | Jambon, Bacon, Saucisson, Chorizo |
| 13 | **Huiles** | 🫒 | 14+ | Olive, Tournesol, Coco, Colza, Avocat |

**Fonctionnalités :**

| Action | Description |
|--------|-------------|
| **Recherche** | Barre de recherche pour trouver une icône |
| **Filtrer** | Filtrer par catégorie |
| **Sélectionner** | Tap pour sélectionner une icône |
| **Ajouter** | Ajouter une nouvelle icône personnalisée |
| **Supprimer** | Supprimer une icône personnalisée |

---

## 🍳 PAGE : CRÉATION DE RECETTE

**Fichier :** `lib/pages/add_recipe_page.dart`

### Étape 1 : Informations de base

| Champ | Type | Description |
|-------|------|-------------|
| **Nom** | Texte | Nom de la recette (obligatoire) |
| **Catégorie** | Sélection | Petit-déjeuner, Déjeuner, Dîner, Snack, Dessert, Boisson, Sauce, Accompagnement |
| **Description** | Texte long | Description de la recette |
| **Temps préparation** | Nombre | Minutes de préparation |
| **Temps cuisson** | Nombre | Minutes de cuisson |
| **Portions** | Nombre | Nombre de portions |
| **Difficulté** | Sélection | Facile, Moyen, Difficile |

### Étape 2 : Photos

| Élément | Description |
|---------|-------------|
| **Photo principale** | Image principale de la recette |
| **Photos supplémentaires** | Jusqu'à 5 photos additionnelles |
| **Bouton caméra** | Prendre une photo |
| **Bouton galerie** | Choisir depuis la galerie |

### Étape 3 : Ingrédients

| Élément | Description |
|---------|-------------|
| **Liste ingrédients** | Liste des ingrédients ajoutés |
| **Bouton + Ingrédient** | Ajouter un ingrédient |
| **Quantité** | Nombre + unité (g, kg, ml, cl, L, pièce, c.à.s., c.à.c.) |
| **Aliment** | Sélection dans la base ou création |
| **Valeurs auto** | Calcul automatique des macros |

### Étape 4 : Étapes de préparation

| Élément | Description |
|---------|-------------|
| **Liste étapes** | Étapes numérotées |
| **Bouton + Étape** | Ajouter une étape |
| **Texte étape** | Description de l'étape |
| **Photo étape** | Photo optionnelle pour l'étape |
| **Réorganiser** | Glisser-déposer pour réordonner |

### Étape 5 : Options

| Option | Description |
|--------|-------------|
| **Allergènes** | Sélection multiple : Gluten, Lactose, Œufs, Fruits à coque, Arachides, Soja, Poisson, Crustacés |
| **Partager** | Toggle pour partager avec la communauté |
| **Ajouter au planning** | Ajouter directement au planning repas |

### Résumé final

| Information | Description |
|-------------|-------------|
| **Aperçu recette** | Preview de la recette |
| **Valeurs nutritionnelles** | Par portion : kcal, protéines, glucides, lipides |
| **Temps total** | Préparation + cuisson |
| **Bouton Sauvegarder** | Enregistrer dans "Mes Recettes" |
| **Bouton Partager** | Publier dans l'Explorer |

---

# 💪 ONGLET 3 : SÉANCES

**Fichier principal :** `lib/exercises/exercise_library_page.dart`

L'onglet Séances est accessible via l'icône 💪 dans la barre de navigation inférieure.
Il contient **4 sous-onglets** accessibles via une TabBar.

---

## 📚 SOUS-ONGLET 3.1 : EXERCICES

### Barre de recherche

| Élément | Description |
|---------|-------------|
| **Input recherche** | Rechercher un exercice par nom |
| **Icône filtre** | Ouvrir les filtres avancés |

### Filtres

| Filtre | Options |
|--------|---------|
| **Catégorie** | Toutes, Jambes, Haut du corps, Abdos, Full body, Cardio, Mobilité |
| **Difficulté** | Tous, Débutant, Intermédiaire, Avancé |
| **Source** | Tous, Exercices Ukan, Mes exercices |

### Liste des exercices

**Chaque carte exercice contient :**

| Élément | Description |
|---------|-------------|
| **Image/Vidéo** | Miniature de l'exercice |
| **Nom** | Nom de l'exercice |
| **Catégorie** | Badge de catégorie |
| **Difficulté** | Badge couleur (vert/orange/rouge) |
| **Durée** | Temps estimé |
| **Muscles** | Icônes des muscles ciblés |

**Action au clic :** Ouvre `ExerciseDetailPage`

### Page détail exercice

| Section | Description |
|---------|-------------|
| **Vidéo** | Vidéo de démonstration |
| **Description** | Instructions détaillées |
| **Muscles ciblés** | Liste des muscles travaillés |
| **Équipement** | Matériel nécessaire |
| **Variantes** | Exercices similaires |
| **Bouton Historique** | Voir l'historique de cet exercice |
| **Bouton Progression** | Voir la progression |
| **Bouton Défi** | Lancer un défi sur cet exercice |

### FAB (Bouton flottant)

| Bouton | Action |
|--------|--------|
| **+ Exercice** | Ouvre `CreateExercisePage` - Créer un exercice personnalisé |

---

## 📋 SOUS-ONGLET 3.2 : PROGRAMMES

### Liste des programmes

**Chaque carte programme contient :**

| Élément | Description |
|---------|-------------|
| **Image couverture** | Image du programme |
| **Nom** | Titre du programme |
| **Durée** | "4 semaines", "8 semaines", etc. |
| **Niveau** | Débutant, Intermédiaire, Avancé |
| **Objectif** | Perte de poids, Prise de masse, Tonification |
| **Nombre séances** | "12 séances", "24 séances", etc. |
| **Badge source** | "Ukan" ou "Personnel" |

**Action au clic :** Ouvre la page de détail du programme

### Page détail programme

| Section | Description |
|---------|-------------|
| **Header** | Image, titre, durée, niveau |
| **Description** | Description complète |
| **Planning** | Calendrier des séances |
| **Liste séances** | Toutes les séances du programme |
| **Bouton Commencer** | Démarrer le programme |
| **Bouton Modifier** | Modifier le programme (si personnel) |

### FAB (Bouton flottant)

| Bouton | Action |
|--------|--------|
| **+ Programme** | Ouvre `WorkoutProgramEditPage` - Créer un programme personnalisé |

---

## 📆 SOUS-ONGLET 3.3 : CALENDRIER

| Élément | Description |
|---------|-------------|
| **Vue mensuelle** | Calendrier avec points colorés sur les jours avec séances |
| **Sélecteur mois** | Flèches pour naviguer entre les mois |
| **Jour sélectionné** | Affiche les séances du jour sélectionné |
| **Liste séances** | Séances planifiées pour le jour |
| **Bouton + Séance** | Planifier une nouvelle séance |

### Couleurs des points

| Couleur | Signification |
|---------|---------------|
| **Vert** | Séance effectuée |
| **Orange** | Séance planifiée (à venir) |
| **Rouge** | Séance manquée |
| **Gris** | Jour de repos |

---

## 📈 SOUS-ONGLET 3.4 : HISTORIQUE

| Section | Description |
|---------|-------------|
| **Statistiques globales** | Temps total, calories brûlées, séances effectuées |
| **Graphique** | Évolution du nombre de séances par semaine |
| **Liste historique** | Toutes les séances passées |
| **Filtres** | Par période, par type, par muscle |

### Carte séance historique

| Élément | Description |
|---------|-------------|
| **Date** | Date et heure de la séance |
| **Nom** | Nom de la séance/programme |
| **Durée** | Temps effectif |
| **Calories** | Calories brûlées |
| **Exercices** | Nombre d'exercices effectués |
| **Note** | Note personnelle (optionnel) |

---

# ⚡ ONGLET 4 : AVANCÉ

**Fichier principal :** `lib/espace_pro_screen.dart`

L'onglet Avancé est accessible via l'icône ⚡ dans la barre de navigation inférieure.
Il est organisé en **3 catégories** sélectionnables via des onglets.

---

## 🔝 BARRE SUPÉRIEURE

| Élément | Position | Description | Action |
|---------|----------|-------------|--------|
| **Titre** | Centre | "Mon Espace Avancé" | - |
| **Icône aide** | Droite | Point d'interrogation | Ouvre `FaqSupportPage` |
| **Barre recherche** | Sous le titre | Rechercher une fonctionnalité | Filtre les fonctionnalités |

---

## 🏷️ SÉLECTEUR DE CATÉGORIE

| Onglet | Couleur | Description |
|--------|---------|-------------|
| **Freemium** | Vert | Fonctionnalités gratuites |
| **Premium** | Or | Fonctionnalités payantes |
| **IA** | Cyan | Fonctionnalités Intelligence Artificielle |

---

## 🆓 CATÉGORIE 1 : FREEMIUM (9 fonctionnalités)

### 1. Analyse corporelle

| Élément | Description |
|---------|-------------|
| **Icône** | 📊 Balance (vert) |
| **Titre** | "Analyse corporelle" |
| **Sous-titre** | "Suivi détaillé de ta composition" |
| **Action** | Ouvre `BodyCompositionPage` |

**Page BodyCompositionPage :**
- Poids actuel et historique
- IMC (Indice de Masse Corporelle)
- Masse grasse estimée
- Masse musculaire estimée
- Graphiques d'évolution
- Objectifs de composition

---

### 2. Chat communautaire

| Élément | Description |
|---------|-------------|
| **Icône** | 💬 Forum (bleu) |
| **Titre** | "Chat communautaire" |
| **Sous-titre** | "Discussions entre membres" |
| **Action** | Ouvre `CommunityChatPage` |

**Page CommunityChatPage :**
- Salons de discussion par thème
- Messages en temps réel
- Partage de photos
- Réactions aux messages
- Mentions d'utilisateurs

---

### 3. Chat Match™

| Élément | Description |
|---------|-------------|
| **Icône** | ❤️ Cœur (rouge) |
| **Titre** | "Chat Match™" |
| **Sous-titre** | "Trouve des partenaires sportifs" |
| **Action** | Ouvre `MatchHomePage` |

**Page MatchHomePage :**
- Profils de partenaires potentiels
- Swipe gauche/droite (style Tinder)
- Score de compatibilité
- Critères : niveau, objectifs, disponibilité, ville
- Chat après match

---

### 4. Visio Training

| Élément | Description |
|---------|-------------|
| **Icône** | 📹 Caméra (cyan) |
| **Titre** | "Visio Training" |
| **Sous-titre** | "Entraîne-toi en live avec tes amis" |
| **Action** | Ouvre `BuddyHomePage` |

**Page BuddyHomePage :**
- Créer une session visio
- Inviter des amis
- Partager son écran
- Timer partagé
- Chat vocal

---

### 5. Santé & Blessures

| Élément | Description |
|---------|-------------|
| **Icône** | 🏥 Croix médicale (orange) |
| **Titre** | "Santé & Blessures" |
| **Sous-titre** | "Carnet de suivi médical" |
| **Action** | Ouvre `HealthInjuriesPage` |

**Page HealthInjuriesPage :**
- Liste des blessures passées
- Ajouter une blessure
- Suivi de guérison
- Exercices à éviter
- Rappels de rendez-vous médicaux

---

### 6. Annuaire

| Élément | Description |
|---------|-------------|
| **Icône** | 👥 Personnes (violet) |
| **Titre** | "Annuaire" |
| **Sous-titre** | "Coachs & Utilisateurs" |
| **Action** | Ouvre `CoachDirectoryPage` |

**Page CoachDirectoryPage :** (Voir section détaillée plus bas)

---

### 7. Personnalité Coach

| Élément | Description |
|---------|-------------|
| **Icône** | 🧠 Cerveau (or) |
| **Titre** | "Personnalité Coach" |
| **Sous-titre** | "Personnalise ton assistant" |
| **Action** | Ouvre `CoachPersonalityPage` |

**Page CoachPersonalityPage :**
- Choix du style de coaching : Motivant, Strict, Amical, Technique
- Choix du ton : Formel, Décontracté, Humoristique
- Choix de la fréquence des rappels
- Personnalisation de l'avatar

---

### 8. Événements

| Élément | Description |
|---------|-------------|
| **Icône** | 📅 Calendrier (rose) |
| **Titre** | "Événements" |
| **Sous-titre** | "Combats, marathons, compétitions..." |
| **Action** | Ouvre `EventsPage` |

**Page EventsPage :** (Voir section détaillée plus bas)

---

### 9. Sport Gaming™

| Élément | Description |
|---------|-------------|
| **Icône** | 🎮 Manette (rouge) |
| **Titre** | "Sport Gaming™" |
| **Sous-titre** | "Le sport comme un jeu" |
| **Action** | Ouvre `StoryHomePage` |

**Page StoryHomePage :**
- Stories interactives gamifiées
- Chapitres à débloquer
- Défis à relever
- Récompenses et badges
- Progression narrative

---

## ⭐ CATÉGORIE 2 : PREMIUM (6 fonctionnalités)

### 1. Coach Business™

| Élément | Description |
|---------|-------------|
| **Icône** | 🏪 Boutique (or) |
| **Titre** | "Coach Business™" |
| **Sous-titre** | "Vends tes programmes" |
| **Action** | Ouvre `CoachBusinessDashboard` |

**Page CoachBusinessDashboard :**
- Dashboard des ventes
- Créer un produit (programme, pack vidéo)
- Gérer les prix
- Statistiques de ventes
- Revenus et paiements

---

### 2. Cours Live

| Élément | Description |
|---------|-------------|
| **Icône** | 🎥 Caméra (rouge) |
| **Titre** | "Cours Live" |
| **Sous-titre** | "Cours en direct style TikTok" |
| **Action** | Ouvre `GroupClassLivePage` |

**Page GroupClassLivePage :** (Voir section détaillée plus bas)

---

### 3. Pack Vidéos

| Élément | Description |
|---------|-------------|
| **Icône** | 📹 Bibliothèque (bleu) |
| **Titre** | "Pack Vidéos" |
| **Sous-titre** | "Vidéos d'exercices détaillées" |
| **Action** | Ouvre `VideoPacksPage` |

**Page VideoPacksPage :**
- Liste des packs vidéo disponibles
- Aperçu gratuit
- Achat de packs
- Téléchargement hors-ligne
- Progression dans les vidéos

---

### 4. Replays

| Élément | Description |
|---------|-------------|
| **Icône** | 🔄 Replay (violet) |
| **Titre** | "Replays" |
| **Sous-titre** | "Replays des cours collectifs" |
| **Action** | Ouvre `GroupClassReplaysPage` |

**Page GroupClassReplaysPage :**
- Liste des cours passés
- Filtrer par catégorie
- Filtrer par coach
- Regarder en replay
- Télécharger

---

### 5. Coach vs Coach

| Élément | Description |
|---------|-------------|
| **Icône** | 🏆 Trophée (orange) |
| **Titre** | "Coach vs Coach" |
| **Sous-titre** | "Classement des meilleurs coachs" |
| **Action** | Ouvre `CoachRankingPage` |

**Page CoachRankingPage :**
- Classement des coachs par note
- Classement par nombre d'élèves
- Classement par revenus
- Défis entre coachs
- Badges et récompenses

---

### 6. Hard Challenge

| Élément | Description |
|---------|-------------|
| **Icône** | 🔥 Flamme (rouge) |
| **Titre** | "Hard Challenge" |
| **Sous-titre** | "Défis intensifs 30/50/75/90 jours" |
| **Action** | Ouvre `HardChallengePage` |

**Page HardChallengePage :** (Voir section détaillée plus bas)

---

## 🤖 CATÉGORIE 3 : IA (4 fonctionnalités)

### 1. Coach IA Premium

| Élément | Description |
|---------|-------------|
| **Icône** | 🎯 Cible (cyan) |
| **Titre** | "Coach IA Premium" |
| **Sous-titre** | "Analyse posture en temps réel" |
| **Action** | Ouvre `CoachIAPremiumPage` |

**Page CoachIAPremiumPage :**
- Caméra en temps réel
- Détection de posture par IA
- Corrections vocales
- Score de forme
- Historique des analyses

---

### 2. FoodScan IA

| Élément | Description |
|---------|-------------|
| **Icône** | 📸 Caméra (vert) |
| **Titre** | "FoodScan IA" |
| **Sous-titre** | "Analyse repas par IA" |
| **Action** | Ouvre `FoodScanHomePage` |

**Page FoodScanHomePage :**
- Scanner par photo
- Scanner par voix
- Historique des scans
- Analyse nutritionnelle détaillée
- Suggestions d'amélioration

---

### 3. Mon Alter Ego

| Élément | Description |
|---------|-------------|
| **Icône** | 🤖 Robot (violet) |
| **Titre** | "Mon Alter Ego" |
| **Sous-titre** | "Ton assistant personnel IA" |
| **Action** | Ouvre `AlterEgoScreen` |

**Page AlterEgoScreen :**
- Chat avec l'assistant IA
- Réponses personnalisées
- Conseils d'entraînement
- Conseils nutrition
- Motivation quotidienne

---

### 4. Transformation IA

| Élément | Description |
|---------|-------------|
| **Icône** | 🔮 Transformation (orange) |
| **Titre** | "Transformation IA" |
| **Sous-titre** | "Visualise ton futur corps" |
| **Action** | Ouvre `RAFuturePreviewPage` |

**Page RAFuturePreviewPage :**
- Upload photo actuelle
- Sélection objectif (perte de poids, prise de masse)
- Génération IA du futur corps
- Comparaison avant/après
- Partage sur les réseaux

---

# 🔍 PAGE DÉTAILLÉE : ANNUAIRE (CoachDirectoryPage)

**Fichier :** `lib/coach_directory_page.dart`

---

## 🔝 BARRE SUPÉRIEURE

| Élément | Position | Description | Action |
|---------|----------|-------------|--------|
| **Flèche retour** | Gauche | Retour | `Navigator.pop()` |
| **Titre** | Centre | "Rechercher" | - |
| **Input recherche** | Sous le titre | Rechercher par nom, spécialité, ville | Filtre en temps réel |
| **Icône filtres** | Droite de l'input | Entonnoir | Ouvre le panneau de filtres |
| **Icône carte** | Droite des filtres | Carte | Ouvre `CoachMapPage` - Vue carte |

---

## 🎛️ PANNEAU DE FILTRES

| Filtre | Options | Description |
|--------|---------|-------------|
| **Spécialité** | Perte de poids, Prise de masse, Fitness, Boxe, Yoga, Cardio, CrossFit, Nutrition, Course, Danse, MMA, Judo | Filtrer par domaine d'expertise |
| **Distance** | 5km, 10km, 25km, 50km, 100km, Illimité | Rayon de recherche |
| **Note minimum** | 3★, 3.5★, 4★, 4.5★ | Note minimale du coach |
| **Prix** | €, €€, €€€ | Gamme de prix |
| **Disponibilité** | En ligne, Présentiel, Les deux | Mode de coaching |
| **Bouton Appliquer** | - | Appliquer les filtres |
| **Bouton Réinitialiser** | - | Effacer tous les filtres |

---

## 📋 AFFICHAGE PAR CATÉGORIE (sans recherche)

Quand aucune recherche n'est effectuée, les coachs sont groupés par spécialité.

### Structure d'un groupe :

| Élément | Description |
|---------|-------------|
| **Header catégorie** | Emoji + Nom + Nombre de coachs + Note moyenne |
| **Couleur de fond** | Couleur distinctive par catégorie |
| **Liste de coachs** | Cartes des coachs de cette catégorie |

### Catégories avec leurs attributs :

| Catégorie | Emoji | Couleur |
|-----------|-------|---------|
| Perte de poids / Minceur | 🔥 | Orange `#FF9F43` |
| Prise de masse / Musculation | 💪 | Or `#FFC300` |
| Fitness / Forme | ✨ | Vert `#4ECDC4` |
| Boxe / Boxing | 🥊 | Rouge `#FF6B6B` |
| Yoga | 🧘 | Cyan `#4ECDC4` |
| Cardio | ❤️ | Rose `#EC4899` |
| CrossFit | 🏋️ | Bleu `#58A6FF` |
| Nutrition | 🥗 | Vert clair `#22C55E` |
| Bien-être / Wellness | 🌿 | Vert forêt `#10B981` |
| Course / Running | 🏃 | Bleu clair `#3B82F6` |
| Natation / Aqua | 🏊 | Bleu océan `#0EA5E9` |
| Danse | 💃 | Violet `#A855F7` |
| Pilates | 🤸 | Rose `#EC4899` |
| Stretching | 🧘‍♀️ | Lavande `#8B5CF6` |
| MMA / Combat | 🤼 | Rouge foncé `#DC2626` |
| Judo | 🥋 | Blanc/Gris `#6B7280` |
| Karaté | 🥷 | Noir `#1F2937` |

---

## 🃏 CARTE COACH

**Chaque carte coach contient :**

| Élément | Position | Description |
|---------|----------|-------------|
| **Photo** | Gauche | Photo de profil ronde |
| **Badge vérifié** | Sur la photo | ✓ bleu si profil vérifié |
| **Nom** | Droite de la photo | Nom complet du coach |
| **Spécialité** | Sous le nom | Badge coloré avec la spécialité |
| **Note** | Droite | Étoile + note (ex: ⭐ 4.8) |
| **Ville** | Sous la spécialité | Localisation du coach |
| **Prix indicatif** | Bas | €, €€ ou €€€ |
| **Disponibilité** | Badge | "En ligne" / "Présentiel" / "Les deux" |

**Action au clic :** Ouvre `CoachDetailPage` - Page de profil complet du coach.

---

## 👤 PAGE DÉTAIL COACH

**Fichier :** `lib/coach_detail_page.dart`

| Section | Description |
|---------|-------------|
| **Header** | Grande photo, nom, spécialité, note, ville |
| **Bio** | Description du coach |
| **Certifications** | Liste des diplômes et certifications |
| **Spécialités** | Tags des domaines d'expertise |
| **Tarifs** | Grille tarifaire (séance, pack, abonnement) |
| **Disponibilités** | Créneaux disponibles |
| **Avis** | Liste des avis clients avec notes |
| **Programmes** | Programmes vendus par le coach |
| **Bouton Contacter** | Ouvrir une conversation |
| **Bouton Réserver** | Réserver une séance |

---

# 📅 PAGE DÉTAILLÉE : ÉVÉNEMENTS

**Fichier :** `lib/events/events_page.dart`

---

## 🔝 BARRE SUPÉRIEURE

| Élément | Description |
|---------|-------------|
| **Titre** | "Événements" |
| **Filtres catégorie** | Barre scrollable de catégories |

---

## 🏷️ CATÉGORIES D'ÉVÉNEMENTS

| Catégorie | Emoji | Description |
|-----------|-------|-------------|
| **Tous** | 📅 | Tous les événements |
| **Boxe** | 🥊 | Combats, galas de boxe |
| **MMA** | 🤼 | Combats MMA, UFC |
| **Marathon** | 🏃 | Courses, marathons, trails |
| **CrossFit** | 🏋️ | Compétitions CrossFit |
| **Musculation** | 💪 | Compétitions bodybuilding |
| **Yoga** | 🧘 | Retraites, stages yoga |
| **Danse** | 💃 | Spectacles, compétitions |
| **Cyclisme** | 🚴 | Courses cyclistes |

---

## 🃏 CARTE ÉVÉNEMENT

| Élément | Description |
|---------|-------------|
| **Image couverture** | Photo de l'événement |
| **Badge catégorie** | Emoji + nom de la catégorie |
| **Nom** | Titre de l'événement |
| **Date/Heure** | 📅 Date et 🕐 heure |
| **Lieu** | 📍 Adresse ou ville |
| **Prix** | 💰 Tarif (ou "Gratuit") |
| **Participants** | 👥 X/Y inscrits |
| **Organisateur** | Nom de l'organisateur |
| **Bouton Participer** | S'inscrire à l'événement |

---

## ➕ CRÉATION D'ÉVÉNEMENT

**FAB + en bas à droite**

| Champ | Type | Description |
|-------|------|-------------|
| **Nom** | Texte | Titre de l'événement |
| **Catégorie** | Sélection | Type de sport |
| **Date** | Date picker | Date de l'événement |
| **Heure** | Time picker | Heure de début |
| **Lieu** | Texte + carte | Adresse complète |
| **Description** | Texte long | Détails de l'événement |
| **Prix** | Nombre | Tarif en € (0 = gratuit) |
| **Max participants** | Nombre | Limite de places |
| **Image couverture** | Image | Photo de l'événement |
| **Contact** | Texte | Email ou téléphone organisateur |
| **Bouton Créer** | - | Publier l'événement |

---

# 🎥 PAGE DÉTAILLÉE : COURS COLLECTIFS LIVE

**Fichier :** `lib/group_classes/group_class_live.dart`

---

## 🔝 BARRE SUPÉRIEURE

| Élément | Description |
|---------|-------------|
| **Titre** | "Cours Collectifs" |
| **Onglets** | Live, Planning, Replays |

---

## 📅 ONGLET PLANNING

**Fichier :** `lib/group_classes/group_class_planning_page.dart`

### Sélecteur de jour

| Élément | Description |
|---------|-------------|
| **Barre horizontale** | Lun, Mar, Mer, Jeu, Ven, Sam, Dim |
| **Jour actif** | Surligné en doré |
| **Indicateur** | Point si cours ce jour |

### Filtres catégorie

| Catégorie | Emoji | Couleur |
|-----------|-------|---------|
| **Tous** | 🎯 | Or |
| **HIIT** | 🔥 | Orange |
| **Yoga** | 🧘 | Vert |
| **Boxe** | 🥊 | Rouge |
| **Danse** | 💃 | Rose |
| **Musculation** | 💪 | Or |
| **Cardio** | ❤️ | Rouge |
| **Pilates** | 🤸 | Violet |
| **Stretching** | 🧘‍♀️ | Bleu |
| **CrossFit** | 🏋️ | Bleu foncé |
| **Zumba** | 🎉 | Rose vif |
| **Judo** | 🥋 | Blanc |
| **MMA** | 🤼 | Rouge foncé |
| **Karaté** | 🥷 | Noir |
| **Cycling** | 🚴 | Vert |

### Carte cours

| Élément | Description |
|---------|-------------|
| **Heure** | Badge avec l'heure (ex: "10:00") |
| **Nom du cours** | Titre (ex: "HIIT Brûle-Graisses") |
| **Coach** | Photo + nom du coach |
| **Niveau** | Badge Débutant/Intermédiaire/Avancé |
| **Durée** | "45 min", "60 min", etc. |
| **Prix** | "15,00 €" |
| **Participants** | Barre de progression "12/20" |
| **Bouton Démo** | "Voir démo (5 min)" - Aperçu gratuit |
| **Bouton Participer** | "Participer - 15,00 €" |

---

## ➕ CRÉATION DE COURS (Coach)

**Fichier :** `lib/group_classes/group_class_create_page.dart`

**FAB + visible uniquement pour les coachs**

| Champ | Type | Description |
|-------|------|-------------|
| **Nom** | Texte | Titre du cours |
| **Description** | Texte long | Description détaillée |
| **Catégorie** | Sélection | Type de cours |
| **Niveau** | Sélection | Débutant, Intermédiaire, Avancé |
| **Date** | Date picker | Date du cours |
| **Heure** | Time picker | Heure de début |
| **Durée totale** | Nombre | En minutes |
| **Prix** | Nombre | En € |
| **Durée démo** | Nombre | Minutes de démo gratuite |
| **Max participants** | Nombre | Limite de places |
| **Équipement requis** | Texte | Matériel nécessaire |
| **Récurrence** | Sélection | Unique, Hebdomadaire, Quotidien |
| **Preview** | Carte | Aperçu du cours |
| **Bouton Créer** | - | Publier le cours |

---

# 🔥 PAGE DÉTAILLÉE : HARD CHALLENGE

**Fichier :** `lib/hard_challenge/hard_challenge_page.dart`

---

## 📊 SECTION 1 : RÉSUMÉ DU CHALLENGE

| Élément | Description |
|---------|-------------|
| **Nom du challenge** | Titre (ex: "75 Hard Sport") |
| **Jour actuel** | "Jour 23 / 75" |
| **Barre progression** | Progression globale |
| **Streak** | 🔥 Jours consécutifs réussis |
| **Bouton Partager** | Partager la progression |

---

## ✅ SECTION 2 : HABITUDES QUOTIDIENNES

Liste des habitudes à valider chaque jour.

| Habitude | Icône | Unité | Exemple objectif |
|----------|-------|-------|------------------|
| **Hydratation** | 💧 | Litres | 3L d'eau |
| **Pas quotidiens** | 🚶 | Pas | 10 000 pas |
| **Séance sport** | 💪 | Oui/Non | 1 séance |
| **Pompes** | 🏋️ | Répétitions | 100 pompes |
| **Squats** | 🦵 | Répétitions | 100 squats |
| **Planche** | 🧘 | Secondes | 300 secondes |
| **Course** | 🏃 | Kilomètres | 5 km |
| **Corde à sauter** | ⏱️ | Minutes | 15 min |
| **Burpees** | 🔥 | Répétitions | 50 burpees |
| **Abdos** | 💪 | Répétitions | 100 abdos |

**Pour chaque habitude :**
- Checkbox pour valider
- Compteur de progression
- Bouton + pour incrémenter

---

## 📅 SECTION 3 : CALENDRIER

| Élément | Description |
|---------|-------------|
| **Vue mensuelle** | Calendrier avec couleurs |
| **Jour vert** | ✅ Toutes habitudes validées |
| **Jour orange** | ⚠️ Partiellement validé |
| **Jour rouge** | ❌ Échoué |
| **Jour gris** | Futur |

---

## ⚙️ SECTION 4 : PARAMÈTRES

| Paramètre | Description |
|-----------|-------------|
| **Durée** | 30, 50, 75 ou 90 jours |
| **Date début** | Date de démarrage |
| **Rappels** | Notifications quotidiennes |
| **Photo quotidienne** | Obligatoire ou non |

---

## 👥 SECTION 5 : PARTICIPANTS

| Élément | Description |
|---------|-------------|
| **Liste participants** | Personnes participant au même challenge |
| **Leur progression** | Jour actuel et streak |
| **Bouton Inviter** | Inviter des amis ou coachs |

---

## 🏆 SECTION 6 : CHALLENGES POPULAIRES

Carrousel horizontal de templates.

| Template | Durée | Description |
|----------|-------|-------------|
| **30 Push-ups** | 30 jours | 30 pompes/jour |
| **50 Squats** | 50 jours | 50 squats/jour |
| **Planche 5 min** | 30 jours | 5 min planche/jour |
| **10K Steps** | 75 jours | 10 000 pas/jour |
| **75 Hard Sport** | 75 jours | Challenge complet |
| **3K Run** | 30 jours | 3 km course/jour |
| **100 Burpees** | 30 jours | 100 burpees/jour |
| **Jump Rope** | 50 jours | 15 min corde/jour |

---

## ➕ CRÉATION DE CHALLENGE

**Fichier :** `lib/hard_challenge/create_challenge_page.dart`

### Étape 1 : Infos de base

| Champ | Description |
|-------|-------------|
| **Nom** | Nom personnalisé du challenge |
| **Durée** | 30, 50, 75 ou 90 jours |
| **Motivation** | Pourquoi ce challenge ? |

### Étape 2 : Objectifs quotidiens

| Champ | Description |
|-------|-------------|
| **Type exercice** | Sélection ou personnalisé |
| **Valeur cible** | Nombre (ex: 100) |
| **Unité** | Répétitions, secondes, km, L, pas |
| **Progression hebdo** | +X% par semaine (optionnel) |
| **Ajouter objectif** | Bouton pour ajouter un autre objectif |

### Étape 3 : Options

| Option | Description |
|--------|-------------|
| **Photo quotidienne** | Toggle obligatoire/optionnel |
| **Rappel** | Heure de notification |

### Étape 4 : Résumé

| Élément | Description |
|---------|-------------|
| **Preview** | Aperçu complet du challenge |
| **Bouton Créer** | Démarrer le challenge |

---

## 📤 PARTAGE

| Option | Description |
|--------|-------------|
| **Inviter participants** | Inviter des utilisateurs à rejoindre |
| **Partager progression** | Partager sans inviter |
| **Partager avec coach** | Envoyer au coach suivi |

---

# 👤 ONGLET 5 : PROFIL

**Fichier :** Intégré dans `main.dart`

---

## 🔝 HEADER PROFIL

| Élément | Description |
|---------|-------------|
| **Photo** | Photo de profil (modifiable) |
| **Nom** | Nom complet |
| **Bio** | Description courte |
| **Bouton Modifier** | Ouvre `EditProfilePage` |

---

## 📊 STATISTIQUES RAPIDES

| Stat | Description |
|------|-------------|
| **Séances** | Nombre total de séances |
| **Jours actifs** | Jours avec activité |
| **Streak max** | Plus longue série |

---

## 📋 SECTIONS DU PROFIL

### 1. Mes Objectifs

| Élément | Description |
|---------|-------------|
| **Objectif principal** | Avec progression |
| **Date limite** | Deadline |
| **Modifier** | Bouton pour changer |

### 2. Mes Achats

| Élément | Description |
|---------|-------------|
| **Programmes achetés** | Liste des programmes |
| **Packs vidéos** | Vidéos achetées |
| **Abonnements** | Abonnements actifs |

### 3. Parrainage

| Élément | Description |
|---------|-------------|
| **Code parrain** | Mon code unique |
| **Partager** | Bouton de partage |
| **Filleuls** | Nombre de filleuls |
| **Gains** | Récompenses gagnées |

### 4. Paramètres

| Paramètre | Options |
|-----------|---------|
| **Notifications** | On/Off par type |
| **Thème** | Clair/Sombre/Auto |
| **Langue** | Français, Anglais, etc. |
| **Unités** | Métrique/Impérial |
| **Confidentialité** | Profil public/privé |
| **Compte** | Email, mot de passe |
| **Déconnexion** | Se déconnecter |
| **Supprimer compte** | Supprimer définitivement |

---

# 🎨 ANNEXE : PALETTE DE COULEURS

| Variable | Hex | Usage |
|----------|-----|-------|
| `_darkBg` | `#0D1117` | Fond principal |
| `_cardBg` | `#161B22` | Fond des cartes |
| `_cardBgLight` | `#21262D` | Fond cartes secondaires |
| `_primaryGold` | `#FFC300` | Accent principal, boutons |
| `_primaryBlue` | `#58A6FF` | Liens, éléments interactifs |
| `_primaryGreen` | `#4ECDC4` | Succès, validation |
| `_primaryOrange` | `#FF9F43` | Avertissements, calories |
| `_primaryPurple` | `#A855F7` | Premium, spécial |
| `_primaryRed` | `#FF6B6B` | Erreurs, alertes |
| `_primaryCyan` | `#22D3EE` | IA, technologie |
| `_textLight` | `#F0F6FC` | Texte principal |
| `_textMuted` | `#8B949E` | Texte secondaire |
| `_borderColor` | `#30363D` | Bordures |

---

> **Document généré pour l'équipe de développement Ukan**  
> Chaque élément, tuile, bouton et fonctionnalité est décrit en détail.  
> © 2024 Ukan - Tous droits réservés








