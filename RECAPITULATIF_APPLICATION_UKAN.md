# 📱 RÉCAPITULATIF COMPLET - APPLICATION UKAN (FitPro)

> **Document destiné à l'équipe de développement**  
> Version : 2.0 | Date : Décembre 2024

---

## 🏠 BARRE DE NAVIGATION PRINCIPALE

L'application possède **5 onglets principaux** dans la barre de navigation inférieure :

| Onglet | Icône | Description |
|--------|-------|-------------|
| **Accueil** | 🏠 | Dashboard principal avec tableau de bord et publications |
| **Nutrition** | 🍎 | Hub nutrition complet |
| **Séances** | 💪 | Bibliothèque d'exercices et programmes |
| **Avancé** | ⚡ | Fonctionnalités avancées (Freemium, Premium, IA) |
| **Profil** | 👤 | Profil utilisateur et paramètres |

---

# 🏠 ONGLET ACCUEIL

## Structure de l'onglet Accueil

L'onglet Accueil contient **2 sous-onglets** :

### 📊 1. Dashboard (Tableau de bord)

Le Dashboard affiche un résumé complet de la journée de l'utilisateur.

#### Composants du Dashboard :

| Composant | Description | Fonctionnalité |
|-----------|-------------|----------------|
| **Stories Header** | Barre horizontale de stories | Affiche les stories des coachs et utilisateurs suivis |
| **Défi Hebdomadaire** | Bannière de challenge | Affiche le défi de la semaine en cours |
| **Objectif Principal** | Carte de progression | Affiche l'objectif principal (perte de poids, prise de masse, etc.) avec progression |
| **Séances de la semaine** | Compteur de séances | X/3 séances effectuées cette semaine |
| **Calories du jour** | Jauge circulaire | Calories consommées vs objectif |
| **Pas quotidiens** | Compteur de pas | Nombre de pas vs objectif (8000 par défaut) |
| **Hydratation** | Jauge d'eau | Litres d'eau consommés aujourd'hui |
| **Sommeil** | Carte sommeil | Heures de sommeil de la nuit dernière |

#### Actions disponibles :
- ➕ Ajouter un repas
- ➕ Ajouter de l'eau
- ➕ Ajouter des pas
- ➕ Ajouter du sommeil
- 📊 Voir les statistiques détaillées

---

### 📰 2. Publications (Feed)

Le feed affiche les publications de la communauté dans un style Instagram.

#### Composants du Feed :

| Composant | Description | Fonctionnalité |
|-----------|-------------|----------------|
| **Bouton Mémo** | Accès rapide aux notes | Ouvre la page de notes/pense-bête personnel |
| **Bouton Recettes** | Livre de recettes | Accès au livre de recettes personnel |
| **Grille de posts** | Publications 3 colonnes | Affiche les publications de la communauté |
| **FAB +** | Bouton flottant | Créer une nouvelle publication |

#### Types de publications :
- 🍽️ **Recettes** - Publications de recettes avec photos
- 💪 **Transformations** - Photos avant/après
- 🏋️ **Entraînements** - Partage de séances
- 📸 **Photos générales** - Publications classiques

#### Fonctionnalité Mémo (Notes) :
- 📝 Créer des notes personnelles
- 📌 Épingler des notes importantes
- 🏷️ Catégoriser (Entraînement, Nutrition, Motivation, Objectifs, Autre)
- ✏️ Modifier et supprimer des notes

---

# 🍎 ONGLET NUTRITION

## Hub Nutrition Principal

Le Hub Nutrition est le point d'entrée vers toutes les fonctionnalités nutrition.

### 📊 Résumé du jour

| Élément | Description |
|---------|-------------|
| **Calories** | Progression vers l'objectif calorique (ex: 1450/2200 kcal) |
| **Protéines** | Grammes de protéines consommées |
| **Glucides** | Grammes de glucides consommés |
| **Lipides** | Grammes de lipides consommés |
| **Streak** | Nombre de jours consécutifs de suivi |

---

### 🔧 Accès Rapides (Grille de fonctionnalités)

| Bouton | Description | Page cible |
|--------|-------------|------------|
| **🍽️ Repas & Courses 2.0** | Gestion des repas et liste de courses | `RepasCoursesPage` |
| **📅 Planning Semaine** | Planification des repas hebdomadaires | `MealPlannerPage` |
| **🛒 Liste Courses** | Liste de courses automatique | `RepasCoursesPage` (onglet Courses) |
| **🧮 Calculatrice Nutrition** | Calculatrice nutritionnelle avancée | `NumericCalculatorPage` |
| **📈 Simulateur Semaine** | Simulation de la semaine nutritionnelle | `NutritionSimulatorPage` |
| **➕ Ajouter Repas** | Ajout rapide d'un repas | `AddMealPage` |
| **🍳 Recettes & Fil** | Explorer les recettes de la communauté | `RecipesFeedPage` |
| **🍔 Bibliothèque Icônes** | Bibliothèque d'icônes alimentaires | `FoodIconsLibraryPage` |

---

### 📱 Page Repas & Courses 2.0

Cette page contient **3 onglets** :

#### Onglet 1 : Repas du jour
- Liste des repas (Petit-déjeuner, Déjeuner, Dîner, Collations)
- Détail des aliments avec calories et macros
- Bouton pour ajouter un aliment

#### Onglet 2 : Courses
- Liste de courses automatique générée depuis les repas
- Catégories : Légumes, Fruits, Protéines, Produits laitiers, Féculents, Épices
- Possibilité de cocher les articles achetés
- Ajout d'articles personnalisés

#### Onglet 3 : Calculatrice
- Pavé numérique pour saisir les quantités
- Opérations : +, -, ×, ÷
- Unités : g, kg, ml, cl, L
- Affichage des macros en temps réel
- Historique des calculs avec icônes des aliments
- Ajout d'aliments personnalisés

---

### 🧮 Calculatrice Nutrition Détaillée

| Fonctionnalité | Description |
|----------------|-------------|
| **Saisie numérique** | Pavé numérique complet (0-9, virgule, effacer) |
| **Opérations** | Addition, soustraction, multiplication, division |
| **Unités** | Grammes (g), kilogrammes (kg), millilitres (ml), centilitres (cl), litres (L) |
| **Base d'aliments** | 50+ aliments prédéfinis avec valeurs nutritionnelles |
| **Aliments personnalisés** | Ajout de nouveaux aliments avec nom, catégorie, kcal, protéines, glucides, lipides |
| **Historique visuel** | Affichage des aliments ajoutés avec icônes et quantités |
| **Total automatique** | Calcul automatique des totaux (kcal, protéines, glucides, lipides) |

---

### 📚 Bibliothèque d'Icônes Alimentaires

**13 catégories** avec 150+ icônes :

| Catégorie | Emoji | Exemples |
|-----------|-------|----------|
| **Protéines** | 🍗 | Poulet, Bœuf, Poisson, Œufs, Tofu |
| **Féculents** | 🍚 | Riz, Pâtes, Pain, Pommes de terre |
| **Fruits** | 🍎 | Pomme, Banane, Orange, Fraises |
| **Légumes** | 🥬 | Brocoli, Carotte, Tomate, Salade |
| **Produits laitiers** | 🥛 | Lait, Yaourt, Fromage, Beurre |
| **Graisses** | 🥑 | Avocat, Noix, Huile d'olive |
| **Sucres** | 🍯 | Miel, Sucre, Confiture |
| **Boissons** | ☕ | Café, Thé, Jus, Eau |
| **Plats préparés** | 🍕 | Pizza, Burger, Sandwich |
| **Épices** | 🌶️ | Poivre, Sel, Curry, Paprika |
| **Compléments** | 💊 | Whey, BCAA, Créatine |
| **Charcuterie** | 🥓 | Jambon, Saucisson, Bacon |
| **Huiles** | 🫒 | Huile d'olive, Huile de coco, Huile de tournesol |

---

### 🍳 Création de Recettes

| Champ | Description |
|-------|-------------|
| **Nom** | Nom de la recette |
| **Catégorie** | Petit-déjeuner, Déjeuner, Dîner, Snack, Dessert, Boisson |
| **Description** | Description de la recette |
| **Temps de préparation** | En minutes |
| **Temps de cuisson** | En minutes |
| **Portions** | Nombre de portions |
| **Difficulté** | Facile, Moyen, Difficile |
| **Photos** | Une ou plusieurs photos |
| **Ingrédients** | Liste avec quantités |
| **Étapes** | Instructions pas à pas |
| **Allergènes** | Gluten, Lactose, Œufs, Fruits à coque, etc. |
| **Valeurs nutritionnelles** | Calculées automatiquement |

#### Actions sur les recettes :
- 💾 Sauvegarder dans "Mes Recettes"
- 🌍 Partager dans l'Explorer
- 🍽️ Ajouter à un repas
- 📅 Ajouter au planning repas

---

# 💪 ONGLET SÉANCES

## Bibliothèque d'Exercices

L'onglet Séances contient **4 sous-onglets** :

### 📚 1. Exercices

| Fonctionnalité | Description |
|----------------|-------------|
| **Recherche** | Rechercher un exercice par nom |
| **Filtres par catégorie** | Jambes, Haut du corps, Abdos, Full body, Cardio, Mobilité |
| **Filtres par difficulté** | Débutant, Intermédiaire, Avancé |
| **Filtres par source** | Exercices Ukan, Mes exercices |
| **Carte exercice** | Image, nom, catégorie, difficulté, durée |

#### Détail d'un exercice :
- 🎥 Vidéo de démonstration
- 📝 Description et instructions
- 💪 Muscles ciblés
- ⚙️ Équipement nécessaire
- 📊 Historique de progression
- 🏆 Défis associés

---

### 📋 2. Programmes

| Fonctionnalité | Description |
|----------------|-------------|
| **Programmes Ukan** | Programmes créés par l'équipe Ukan |
| **Mes programmes** | Programmes personnels de l'utilisateur |
| **Création de programme** | Nom, description, durée, niveau, exercices |

#### Structure d'un programme :
- 📅 Durée (4, 8, 12 semaines)
- 🎯 Objectif (Perte de poids, Prise de masse, Tonification)
- 📊 Niveau (Débutant, Intermédiaire, Avancé)
- 💪 Liste des séances

---

### 📆 3. Calendrier

| Fonctionnalité | Description |
|----------------|-------------|
| **Vue mensuelle** | Calendrier avec séances planifiées |
| **Vue hebdomadaire** | Détail de la semaine |
| **Séances passées** | Historique des séances effectuées |
| **Séances à venir** | Prochaines séances planifiées |

---

### 📈 4. Historique

| Fonctionnalité | Description |
|----------------|-------------|
| **Historique des séances** | Liste de toutes les séances effectuées |
| **Statistiques** | Temps total, calories brûlées, exercices favoris |
| **Progression** | Évolution des performances |

---

### ➕ Création d'exercice personnalisé

| Champ | Description |
|-------|-------------|
| **Nom** | Nom de l'exercice |
| **Catégorie** | Jambes, Haut du corps, Abdos, etc. |
| **Difficulté** | Débutant, Intermédiaire, Avancé |
| **Description** | Instructions détaillées |
| **Muscles ciblés** | Liste des muscles |
| **Équipement** | Matériel nécessaire |
| **Vidéo** | URL de démonstration (optionnel) |

---

# ⚡ ONGLET AVANCÉ

L'onglet Avancé est organisé en **3 catégories** :

## 🆓 FREEMIUM (Gratuit)

| Fonctionnalité | Description | Icône |
|----------------|-------------|-------|
| **Analyse corporelle** | Suivi de la composition corporelle (poids, IMC, masse grasse, masse musculaire) | 📊 |
| **Chat communautaire** | Discussions entre membres de la communauté | 💬 |
| **Chat Match™** | Trouver des partenaires sportifs compatibles | ❤️ |
| **Visio Training** | S'entraîner en live avec des amis | 📹 |
| **Santé & Blessures** | Carnet de suivi médical et blessures | 🏥 |
| **Annuaire** | Recherche de coachs et utilisateurs | 👥 |
| **Personnalité Coach** | Personnaliser l'assistant IA | 🧠 |
| **Événements** | Calendrier des événements sportifs | 📅 |
| **Sport Gaming™** | Gamification du sport avec stories interactives | 🎮 |

---

## ⭐ PREMIUM (Payant)

| Fonctionnalité | Description | Icône |
|----------------|-------------|-------|
| **Coach Business™** | Vendre ses programmes (pour les coachs) | 🏪 |
| **Cours Live** | Cours collectifs en direct style TikTok | 🎥 |
| **Pack Vidéos** | Vidéos d'exercices détaillées | 📹 |
| **Replays** | Replays des cours collectifs | 🔄 |
| **Coach vs Coach** | Classement des meilleurs coachs | 🏆 |
| **Hard Challenge** | Défis intensifs 30/50/75/90 jours | 🔥 |

---

## 🤖 IA (Intelligence Artificielle)

| Fonctionnalité | Description | Icône |
|----------------|-------------|-------|
| **Coach IA Premium** | Analyse de posture en temps réel | 🎯 |
| **FoodScan IA** | Analyse des repas par photo | 📸 |
| **Mon Alter Ego** | Assistant personnel IA | 🤖 |
| **Transformation IA** | Visualisation du futur corps | 🔮 |

---

## 🔍 PAGE RECHERCHER (Annuaire Coachs & Utilisateurs)

### Structure de la page

| Élément | Description |
|---------|-------------|
| **Barre de recherche** | Recherche par nom, spécialité, ville |
| **Icône filtres** | Ouvre les filtres avancés |
| **Icône carte** | Affiche les coachs sur une carte |
| **Liste/Grille** | Affichage des résultats |

### Filtres disponibles

| Filtre | Options |
|--------|---------|
| **Spécialité** | Perte de poids, Prise de masse, Fitness, Boxe, Yoga, etc. |
| **Distance** | 5km, 10km, 25km, 50km, 100km |
| **Note minimum** | 3★, 4★, 4.5★ |
| **Prix** | €, €€, €€€ |
| **Disponibilité** | En ligne, Présentiel, Les deux |

### Affichage par catégorie (sans recherche active)

Quand aucune recherche n'est effectuée, les coachs sont groupés par spécialité :

| Catégorie | Emoji | Couleur |
|-----------|-------|---------|
| **Perte de poids** | 🔥 | Orange |
| **Prise de masse** | 💪 | Or |
| **Fitness** | ✨ | Vert |
| **Boxe** | 🥊 | Rouge |
| **Yoga** | 🧘 | Cyan |
| **Cardio** | ❤️ | Rose |
| **CrossFit** | 🏋️ | Bleu |
| **Nutrition** | 🥗 | Vert clair |
| **Course/Running** | 🏃 | Bleu clair |
| **Danse** | 💃 | Violet |
| **MMA/Combat** | 🤼 | Rouge foncé |
| **Judo** | 🥋 | Blanc |

### Carte Coach

| Élément | Description |
|---------|-------------|
| **Photo** | Photo de profil du coach |
| **Nom** | Nom complet |
| **Spécialité** | Domaine d'expertise |
| **Note** | Étoiles (ex: ⭐ 4.8) |
| **Ville** | Localisation |
| **Prix** | Tarif indicatif |
| **Badge vérifié** | ✓ si profil vérifié |

---

## 📅 PAGE ÉVÉNEMENTS

### Structure

| Élément | Description |
|---------|-------------|
| **Filtres par catégorie** | Boxe, MMA, Marathon, CrossFit, Yoga, Danse, Cyclisme |
| **Liste des événements** | Événements à venir |
| **FAB +** | Créer un nouvel événement |

### Carte Événement

| Champ | Description |
|-------|-------------|
| **Nom** | Titre de l'événement |
| **Date/Heure** | Date et heure de l'événement |
| **Lieu** | Adresse ou lieu |
| **Catégorie** | Type de sport |
| **Description** | Détails de l'événement |
| **Prix** | Tarif d'inscription |
| **Participants** | Nombre de participants / max |
| **Organisateur** | Nom de l'organisateur |
| **Bouton Participer** | S'inscrire à l'événement |

### Création d'événement

| Champ | Description |
|-------|-------------|
| **Nom** | Titre de l'événement |
| **Catégorie** | Type de sport |
| **Date/Heure** | Date et heure |
| **Lieu** | Adresse |
| **Description** | Détails |
| **Prix** | Tarif (0 = gratuit) |
| **Max participants** | Limite de places |
| **Image de couverture** | Photo de l'événement |
| **Contact organisateur** | Email ou téléphone |

---

## 🎥 COURS COLLECTIFS LIVE

### Planning des cours

| Élément | Description |
|---------|-------------|
| **Sélecteur de jour** | Lun, Mar, Mer, Jeu, Ven, Sam, Dim |
| **Filtres catégorie** | HIIT, Yoga, Boxe, Danse, Musculation, etc. |
| **Cartes de cours** | Liste des cours du jour |

### Carte de cours

| Champ | Description |
|-------|-------------|
| **Heure** | Horaire du cours |
| **Nom** | Titre du cours |
| **Coach** | Nom du coach |
| **Niveau** | Débutant, Intermédiaire, Avancé |
| **Durée** | En minutes |
| **Prix** | Tarif du cours |
| **Participants** | X/Y inscrits |
| **Bouton Démo** | Voir la démo gratuite (5 min) |
| **Bouton Participer** | S'inscrire au cours payant |

### Création de cours (Coach)

| Champ | Description |
|-------|-------------|
| **Nom** | Titre du cours |
| **Description** | Description détaillée |
| **Catégorie** | Type de cours |
| **Niveau** | Débutant, Intermédiaire, Avancé |
| **Date/Heure** | Programmation |
| **Durée totale** | En minutes |
| **Prix** | Tarif |
| **Durée démo** | Durée de la démo gratuite |
| **Max participants** | Limite de places |
| **Équipement requis** | Matériel nécessaire |
| **Récurrence** | Unique, Hebdomadaire, Quotidien |

### Catégories de cours

| Catégorie | Emoji | Couleur |
|-----------|-------|---------|
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

---

## 🔥 HARD CHALLENGE

### Structure du challenge

| Section | Description |
|---------|-------------|
| **Résumé** | Jour actuel, progression globale |
| **Habitudes quotidiennes** | Liste des habitudes à valider |
| **Statistiques** | Calendrier et graphiques |
| **Paramètres** | Configuration du challenge |
| **Participants** | Liste des participants |
| **Challenges populaires** | Templates de challenges |

### Habitudes sportives disponibles

| Habitude | Description | Unité |
|----------|-------------|-------|
| **Hydratation** | Boire X litres d'eau | Litres |
| **Pas quotidiens** | Marcher X pas | Pas |
| **Séance sport** | Faire une séance | Oui/Non |
| **Pompes** | Faire X pompes | Répétitions |
| **Squats** | Faire X squats | Répétitions |
| **Planche** | Tenir X secondes | Secondes |
| **Course** | Courir X km | Kilomètres |
| **Corde à sauter** | Sauter X minutes | Minutes |
| **Burpees** | Faire X burpees | Répétitions |
| **Abdos** | Faire X abdos | Répétitions |

### Création de challenge

| Étape | Champs |
|-------|--------|
| **1. Infos de base** | Nom, durée (30/50/75/90 jours), motivation |
| **2. Objectifs quotidiens** | Type d'exercice, valeur cible, unité, progression hebdo |
| **3. Options** | Photo quotidienne obligatoire, rappel |
| **4. Résumé** | Aperçu avant création |

### Challenges populaires (Templates)

| Challenge | Durée | Description |
|-----------|-------|-------------|
| **30 Push-ups** | 30 jours | 30 pompes par jour pendant 30 jours |
| **50 Squats** | 50 jours | 50 squats par jour pendant 50 jours |
| **Planche 5 min** | 30 jours | Tenir la planche 5 min/jour |
| **10K Steps** | 75 jours | 10 000 pas par jour |
| **75 Hard Sport** | 75 jours | Challenge complet multi-objectifs |
| **3K Run** | 30 jours | Courir 3 km par jour |
| **100 Burpees** | 30 jours | 100 burpees par jour |
| **Jump Rope** | 50 jours | 15 min de corde à sauter/jour |

### Partage et invitation

| Action | Description |
|--------|-------------|
| **Inviter des participants** | Inviter des utilisateurs ou coachs à rejoindre le challenge |
| **Partager la progression** | Partager ses stats sans inviter |
| **Partager avec le coach** | Envoyer la progression à son coach |

---

# 👤 ONGLET PROFIL

## Informations du profil

| Champ | Description |
|-------|-------------|
| **Photo** | Photo de profil |
| **Nom** | Nom complet |
| **Bio** | Description courte |
| **Objectif principal** | Perte de poids, Prise de masse, etc. |
| **Date limite** | Deadline pour atteindre l'objectif |
| **Niveau** | Débutant, Intermédiaire, Avancé |

## Sections du profil

| Section | Description |
|---------|-------------|
| **Mes objectifs** | Objectifs personnalisés avec progression |
| **Mes statistiques** | Résumé des performances |
| **Mes achats** | Programmes et packs achetés |
| **Parrainage** | Inviter des amis et gagner des récompenses |
| **Paramètres** | Configuration de l'application |

## Paramètres

| Paramètre | Description |
|-----------|-------------|
| **Notifications** | Activer/désactiver les notifications |
| **Thème** | Mode clair/sombre |
| **Langue** | Français, Anglais, etc. |
| **Unités** | Métrique/Impérial |
| **Confidentialité** | Profil public/privé |
| **Compte** | Modifier email, mot de passe |
| **Déconnexion** | Se déconnecter |

---

# 🎨 PALETTE DE COULEURS

| Couleur | Code Hex | Usage |
|---------|----------|-------|
| **Fond sombre** | `#0D1117` | Background principal |
| **Carte** | `#161B22` | Fond des cartes |
| **Carte claire** | `#21262D` | Fond des cartes secondaires |
| **Or principal** | `#FFC300` | Accent principal, boutons |
| **Bleu** | `#58A6FF` | Liens, éléments interactifs |
| **Vert** | `#4ECDC4` | Succès, validation |
| **Orange** | `#FF9F43` | Avertissements, calories |
| **Violet** | `#A855F7` | Premium, spécial |
| **Rouge** | `#FF6B6B` | Erreurs, alertes |
| **Cyan** | `#22D3EE` | IA, technologie |
| **Texte clair** | `#F0F6FC` | Texte principal |
| **Texte muet** | `#8B949E` | Texte secondaire |

---

# 📁 STRUCTURE DES FICHIERS PRINCIPAUX

```
lib/
├── main.dart                          # Point d'entrée
├── home/
│   └── widgets/
│       ├── dashboard_tab.dart         # Dashboard principal
│       └── publications_tab.dart      # Feed publications
├── nutrition/
│   └── nutrition_hub_page.dart        # Hub nutrition
├── features/
│   └── nutrition/
│       ├── repas_courses_page.dart    # Repas & Courses 2.0
│       ├── meal_planner_page.dart     # Planning repas
│       ├── food_icons_library_page.dart # Bibliothèque icônes
│       └── calculator/
│           ├── numeric_calculator_page.dart # Calculatrice
│           └── models_demo.dart       # Modèles aliments
├── exercises/
│   └── exercise_library_page.dart     # Bibliothèque exercices
├── espace_pro_screen.dart             # Onglet Avancé
├── coach_directory_page.dart          # Annuaire coachs/users
├── events/
│   └── events_page.dart               # Événements
├── group_classes/
│   ├── group_class_live.dart          # Cours live
│   ├── group_class_planning_page.dart # Planning cours
│   └── group_class_create_page.dart   # Création cours
├── hard_challenge/
│   ├── hard_challenge_page.dart       # Page Hard Challenge
│   ├── hard_challenge_model.dart      # Modèles
│   └── create_challenge_page.dart     # Création challenge
├── pages/
│   ├── notes_page.dart                # Notes/Mémo
│   ├── add_recipe_page.dart           # Création recette
│   └── user_profile_page.dart         # Profil utilisateur
└── models/
    ├── recipe.dart                    # Modèle recette
    ├── note_model.dart                # Modèle notes
    ├── event_model.dart               # Modèle événements
    └── group_class.dart               # Modèle cours
```

---

# ✅ RÉSUMÉ DES FONCTIONNALITÉS

| Catégorie | Nombre de fonctionnalités |
|-----------|---------------------------|
| **Dashboard** | 8 widgets principaux |
| **Nutrition** | 10 fonctionnalités |
| **Séances** | 4 onglets, 50+ exercices |
| **Avancé Freemium** | 9 fonctionnalités |
| **Avancé Premium** | 6 fonctionnalités |
| **Avancé IA** | 4 fonctionnalités |
| **Profil** | 6 sections |

**Total : 40+ fonctionnalités majeures**

---

> Document généré automatiquement pour l'équipe de développement Ukan
> © 2024 Ukan - Tous droits réservés








