# 🚀 UKAN - GUIDE COMPLET POUR L'ÉQUIPE CURSOR
## Explication détaillée de chaque élément avec statut GRATUIT / PAYANT

---

> **Document destiné à l'équipe de développement**  
> Objectif : Comprendre chaque fonctionnalité et intégrer les paywalls correctement  
> Les prix ne sont pas définis - seul le statut gratuit/payant est indiqué

---

# ═══════════════════════════════════════════════════════════════
# 📋 TABLE DES MATIÈRES
# ═══════════════════════════════════════════════════════════════

1. [LÉGENDE DES STATUTS](#légende)
2. [ONGLET ACCUEIL](#accueil)
3. [ONGLET NUTRITION](#nutrition)
4. [ONGLET SÉANCES](#seances)
5. [ONGLET AVANCÉ](#avance)
6. [ONGLET PROFIL](#profil)
7. [BARRE DE RECHERCHE](#recherche)
8. [WIDGETS GLOBAUX](#widgets)
9. [TABLEAU RÉCAPITULATIF](#recap)

---

<a name="légende"></a>
# ═══════════════════════════════════════════════════════════════
# 🏷️ LÉGENDE DES STATUTS
# ═══════════════════════════════════════════════════════════════

| Icône | Statut | Description |
|-------|--------|-------------|
| 🆓 | **GRATUIT** | Accès libre, aucune restriction |
| 💎 | **PREMIUM** | Nécessite un abonnement Premium |
| 🤖 | **IA PREMIUM** | Fonctionnalité IA, nécessite abonnement IA |
| 👨‍🏫 | **COACH PRO** | Réservé aux coachs avec abonnement Pro |
| 💰 | **ACHAT UNIQUE** | Paiement ponctuel (cours, pack, etc.) |
| 🔒 | **LIMITE GRATUIT** | Gratuit avec limitations, Premium pour illimité |

---

<a name="accueil"></a>
# ═══════════════════════════════════════════════════════════════
# 🏠 ONGLET ACCUEIL (Dashboard)
# ═══════════════════════════════════════════════════════════════

**Fichier principal :** `lib/home/widgets/dashboard_tab.dart`

---

## 1. HEADER UTILISATEUR

| Élément | Statut | Ce que ça fait | Pourquoi c'est utile |
|---------|--------|----------------|---------------------|
| Photo de profil | 🆓 | Affiche la photo de l'utilisateur | Personnalisation |
| Nom et prénom | 🆓 | Affiche le nom | Identification |
| Message de bienvenue | 🆓 | "Bonjour [Prénom]" dynamique selon l'heure | Expérience personnalisée |
| Badge niveau | 🆓 | Affiche le niveau actuel (Débutant, Intermédiaire, Expert) | Gamification |

**Paywall :** Aucun

---

## 2. CARTE RÉSUMÉ DU JOUR

| Élément | Statut | Ce que ça fait | Pourquoi c'est utile |
|---------|--------|----------------|---------------------|
| Calories consommées | 🆓 | Affiche kcal du jour vs objectif | Suivi nutritionnel |
| Protéines | 🆓 | Affiche g de protéines vs objectif | Suivi macros |
| Eau | 🆓 | Affiche verres d'eau vs objectif | Hydratation |
| Séance du jour | 🆓 | Affiche la séance planifiée | Rappel entraînement |

**Paywall :** Aucun

---

## 3. ACCÈS RAPIDES (Quick Actions)

| Bouton | Statut | Ce que ça fait | Destination |
|--------|--------|----------------|-------------|
| ➕ Ajouter repas | 🆓 | Ouvre le sélecteur de repas | `MealSelectionPage` |
| 🏋️ Commencer séance | 🆓 | Lance une séance rapide | `WorkoutSessionPage` |
| 📊 Mes stats | 🆓 | Affiche les statistiques | `StatsPage` |
| 🎯 Objectifs | 🆓 | Gestion des objectifs | `GoalsPage` |

**Paywall :** Aucun

---

## 4. CARTE PROGRESSION HEBDOMADAIRE

| Élément | Statut | Ce que ça fait | Pourquoi c'est utile |
|---------|--------|----------------|---------------------|
| Graphique 7 jours | 🆓 | Barres des séances de la semaine | Visualisation rapide |
| Streak actuel | 🆓 | Nombre de jours consécutifs | Motivation |
| Objectif hebdo | 🆓 | X séances sur Y prévues | Suivi objectif |

**Paywall :** Aucun

---

## 5. CARTE SÉANCE SUGGÉRÉE

| Élément | Statut | Ce que ça fait | Pourquoi c'est utile |
|---------|--------|----------------|---------------------|
| Suggestion basique | 🆓 | Propose une séance selon le jour | Aide à la décision |
| Suggestion IA personnalisée | 🤖 | Analyse l'historique et propose la séance optimale | Personnalisation avancée |

**Paywall :** 
- Version basique : 🆓 GRATUIT
- Version IA : 🤖 PREMIUM IA (afficher badge "IA" et bloquer si non abonné)

---

## 6. NOTIFICATIONS / ALERTES

| Élément | Statut | Ce que ça fait | Pourquoi c'est utile |
|---------|--------|----------------|---------------------|
| Rappel hydratation | 🆓 | Notification "Bois de l'eau" | Santé |
| Rappel séance | 🆓 | Notification séance planifiée | Ne pas oublier |
| Alertes coach | 👨‍🏫 | Messages du coach | Communication coach/client |

**Paywall :** Alertes coach réservées aux clients ayant un coach

---

## 7. WIDGET COMPTEUR DE PAS

| Élément | Statut | Ce que ça fait | Pourquoi c'est utile |
|---------|--------|----------------|---------------------|
| Pas du jour | 🆓 | Affiche le nombre de pas | Suivi activité |
| Objectif pas | 🆓 | Barre de progression vers 10000 pas | Motivation |
| Historique pas | 🔒 | Graphique sur 30 jours | Analyse tendance |

**Paywall :** 
- Compteur du jour : 🆓 GRATUIT
- Historique 30 jours : 💎 PREMIUM

---

<a name="nutrition"></a>
# ═══════════════════════════════════════════════════════════════
# 🥗 ONGLET NUTRITION
# ═══════════════════════════════════════════════════════════════

**Fichier principal :** `lib/nutrition/nutrition_hub_page.dart`

---

## 1. HUB NUTRITION (Page principale)

| Carte | Statut | Ce que ça fait | Destination |
|-------|--------|----------------|-------------|
| Journal alimentaire | 🆓 | Accès au suivi des repas | `FoodJournalPage` |
| Calculatrice nutrition | 🆓 | Calcul des macros | `NumericCalculatorPage` |
| Mes recettes | 🆓 | Liste des recettes sauvées | `MyRecipesPage` |
| Explorer recettes | 🆓 | Découvrir des recettes | `RecipeExplorerPage` |
| Planning repas | 🔒 | Planifier les repas de la semaine | `MealPlannerPage` |
| Liste de courses | 🔒 | Générer liste auto | `ShoppingListPage` |
| FoodScan IA | 🤖 | Scanner un aliment | `FoodScanPage` |
| Objectifs nutrition | 🆓 | Définir macros cibles | `NutritionGoalsPage` |

**Paywall :**
- Journal, Calculatrice, Recettes, Explorer, Objectifs : 🆓 GRATUIT
- Planning repas : 🔒 3 jours gratuits, 7 jours = 💎 PREMIUM
- Liste de courses : 🔒 Manuelle gratuite, Auto-générée = 💎 PREMIUM
- FoodScan IA : 🤖 3 scans/jour gratuits, illimité = PREMIUM IA

---

## 2. JOURNAL ALIMENTAIRE

**Fichier :** `lib/features/nutrition/food_journal_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Ajouter petit-déjeuner | 🆓 | Enregistrer le repas du matin | Recherche + quantité |
| Ajouter déjeuner | 🆓 | Enregistrer le repas du midi | Recherche + quantité |
| Ajouter dîner | 🆓 | Enregistrer le repas du soir | Recherche + quantité |
| Ajouter collation | 🆓 | Enregistrer un snack | Recherche + quantité |
| Voir historique | 🔒 | Consulter les jours précédents | Calendrier |
| Exporter données | 💎 | Télécharger en PDF/CSV | Export |

**Paywall :**
- Ajout repas du jour : 🆓 GRATUIT
- Historique 7 jours : 🆓 GRATUIT
- Historique illimité : 💎 PREMIUM
- Export : 💎 PREMIUM

---

## 3. CALCULATRICE NUTRITIONNELLE

**Fichier :** `lib/features/nutrition/calculator/numeric_calculator_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Sélectionner aliment | 🆓 | Choisir dans la base | 500+ aliments |
| Entrer quantité | 🆓 | Grammes, ml, unités | Clavier numérique |
| Opérations +/-/×/÷ | 🆓 | Additionner/soustraire aliments | Calcul combiné |
| Voir macros | 🆓 | Affiche P/G/L/kcal | Résultat instantané |
| Créer aliment perso | 🆓 | Ajouter un aliment custom | Nom + macros |
| Ajouter au repas | 🆓 | Enregistrer dans le journal | Bouton "Ajouter" |
| Historique calculs | 💎 | Revoir les anciens calculs | Liste sauvegardée |

**Paywall :**
- Toutes les fonctions de base : 🆓 GRATUIT
- Historique des calculs : 💎 PREMIUM

---

## 4. MES RECETTES

**Fichier :** `lib/pages/my_recipes_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir mes recettes | 🆓 | Liste des recettes créées | Grille avec photos |
| Créer une recette | 🆓 | Formulaire complet | Nom, ingrédients, étapes |
| Modifier recette | 🆓 | Éditer une recette | Tous les champs |
| Supprimer recette | 🆓 | Effacer une recette | Confirmation |
| Partager recette | 🆓 | Publier dans l'Explorer | Visible par tous |
| Nombre de recettes | 🔒 | Limite de stockage | 10 gratuites |

**Paywall :**
- 10 recettes : 🆓 GRATUIT
- Recettes illimitées : 💎 PREMIUM

---

## 5. EXPLORER RECETTES

**Fichier :** `lib/pages/recipe_explorer_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Parcourir recettes | 🆓 | Voir les recettes de la communauté | Scroll infini |
| Filtrer par catégorie | 🆓 | Petit-déj, Déjeuner, etc. | Onglets |
| Rechercher | 🆓 | Recherche par nom | Barre de recherche |
| Voir détail recette | 🆓 | Ingrédients, étapes, macros | Page complète |
| Sauvegarder recette | 🆓 | Ajouter à "Mes recettes" | Bouton cœur |
| Liker / Commenter | 🆓 | Interaction sociale | Engagement |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

## 6. PLANNING REPAS

**Fichier :** `lib/pages/meal_planner_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir planning semaine | 🔒 | Calendrier 7 jours | Vue hebdo |
| Ajouter repas planifié | 🔒 | Assigner recette à un jour | Drag & drop |
| Suggestions IA | 🤖 | Génère un planning équilibré | Basé sur objectifs |
| Copier semaine | 💎 | Dupliquer le planning | Gain de temps |
| Générer liste courses | 💎 | Liste auto depuis planning | Ingrédients agrégés |

**Paywall :**
- Planning 3 jours : 🆓 GRATUIT
- Planning 7 jours : 💎 PREMIUM
- Suggestions IA : 🤖 PREMIUM IA
- Copier semaine : 💎 PREMIUM
- Liste courses auto : 💎 PREMIUM

---

## 7. FOODSCAN IA

**Fichier :** `lib/features/nutrition/food_scan/food_scan_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Prendre photo | 🤖 | Photographier un plat | Caméra |
| Analyse IA | 🤖 | Détecte les aliments | Vision par ordinateur |
| Estimation macros | 🤖 | Calcule les macros | Approximation |
| Ajouter au journal | 🤖 | Enregistrer le résultat | Bouton |
| Corriger résultat | 🤖 | Modifier si erreur | Édition manuelle |

**Paywall :**
- 3 scans/jour : 🆓 GRATUIT (découverte)
- Scans illimités : 🤖 PREMIUM IA

---

## 8. BIBLIOTHÈQUE ICÔNES ALIMENTS

**Fichier :** `lib/features/nutrition/food_icons_library_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir toutes les icônes | 🆓 | Parcourir par catégorie | Protéines, Glucides, etc. |
| Sélectionner icône | 🆓 | Choisir pour aliment perso | Tap pour sélectionner |
| Catégories | 🆓 | 12 catégories d'aliments | Navigation facile |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

<a name="seances"></a>
# ═══════════════════════════════════════════════════════════════
# 🏋️ ONGLET SÉANCES
# ═══════════════════════════════════════════════════════════════

**Fichier principal :** `lib/home/widgets/workout_tab.dart`

---

## 1. BIBLIOTHÈQUE D'EXERCICES

**Fichier :** `lib/exercise_library_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Parcourir exercices | 🆓 | Liste de 200+ exercices | Par groupe musculaire |
| Filtrer par muscle | 🆓 | Pectoraux, Dos, Jambes, etc. | Onglets |
| Filtrer par équipement | 🆓 | Haltères, Machine, Poids du corps | Dropdown |
| Voir vidéo démo | 🆓 | Animation de l'exercice | GIF/Vidéo |
| Voir instructions | 🆓 | Texte explicatif | Étapes |
| Ajouter aux favoris | 🆓 | Sauvegarder l'exercice | Bouton étoile |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

## 2. CRÉER UNE SÉANCE

**Fichier :** `lib/create_workout_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Nouvelle séance | 🆓 | Créer une séance vide | Formulaire |
| Ajouter exercices | 🆓 | Sélectionner depuis la bibliothèque | Multi-sélection |
| Définir séries/reps | 🆓 | Configurer chaque exercice | Champs numériques |
| Définir repos | 🆓 | Temps de repos entre séries | Secondes |
| Nommer la séance | 🆓 | Titre personnalisé | Texte libre |
| Sauvegarder | 🆓 | Enregistrer dans "Mes séances" | Bouton |
| Nombre de séances | 🔒 | Limite de stockage | 5 gratuites |

**Paywall :**
- 5 séances custom : 🆓 GRATUIT
- Séances illimitées : 💎 PREMIUM

---

## 3. MES SÉANCES

**Fichier :** `lib/my_workouts_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir mes séances | 🆓 | Liste des séances créées | Grille |
| Lancer une séance | 🆓 | Démarrer l'entraînement | Bouton play |
| Modifier séance | 🆓 | Éditer les exercices | Formulaire |
| Dupliquer séance | 🆓 | Créer une copie | Bouton copie |
| Supprimer séance | 🆓 | Effacer | Confirmation |
| Partager séance | 🆓 | Publier dans Explorer | Visible par tous |

**Paywall :** Voir limite création ci-dessus

---

## 4. PROGRAMMES D'ENTRAÎNEMENT

**Fichier :** `lib/programs_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Programmes gratuits | 🆓 | 5 programmes de base | Débutant |
| Programmes premium | 💎 | 50+ programmes avancés | Tous niveaux |
| Programmes IA | 🤖 | Programme personnalisé généré | Basé sur objectifs |
| Suivre un programme | 🆓/💎 | S'inscrire à un programme | Selon le programme |
| Voir progression | 🆓 | % d'avancement | Barre de progression |

**Paywall :**
- 5 programmes basiques : 🆓 GRATUIT
- Programmes avancés : 💎 PREMIUM
- Programme IA personnalisé : 🤖 PREMIUM IA

---

## 5. SESSION D'ENTRAÎNEMENT

**Fichier :** `lib/workout_session_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Timer exercice | 🆓 | Chronomètre automatique | Compte à rebours |
| Timer repos | 🆓 | Pause entre séries | Configurable |
| Marquer série faite | 🆓 | Valider une série | Bouton check |
| Modifier poids/reps | 🆓 | Ajuster en temps réel | Champs éditables |
| Passer exercice | 🆓 | Sauter un exercice | Bouton skip |
| Coach vocal IA | 🤖 | Encouragements audio | Voix synthétique |
| Correction posture IA | 🤖 | Analyse caméra temps réel | Détection pose |
| Résumé fin séance | 🆓 | Stats de la séance | Durée, volume, etc. |

**Paywall :**
- Session complète : 🆓 GRATUIT
- Coach vocal IA : 🤖 PREMIUM IA
- Correction posture IA : 🤖 PREMIUM IA

---

## 6. CALENDRIER SÉANCES

**Fichier :** `lib/workout_calendar_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Vue mois | 🆓 | Calendrier mensuel | Points sur les jours |
| Voir séance d'un jour | 🆓 | Détail de la séance passée | Tap sur un jour |
| Planifier séance | 🆓 | Assigner séance à un jour futur | Drag & drop |
| Légende (Séance/Objectif/Aujourd'hui) | 🆓 | Filtrer l'affichage | Boutons toggle |
| Historique complet | 🔒 | Voir au-delà de 30 jours | Scroll infini |

**Paywall :**
- 30 derniers jours : 🆓 GRATUIT
- Historique illimité : 💎 PREMIUM

---

## 7. STATISTIQUES SÉANCES

**Fichier :** `lib/workout_stats_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Séances cette semaine | 🆓 | Compteur | Nombre |
| Volume total | 🆓 | Kg soulevés | Calcul auto |
| Temps total | 🆓 | Heures d'entraînement | Cumul |
| Graphiques basiques | 🆓 | Évolution sur 7 jours | Barres |
| Graphiques avancés | 💎 | Évolution sur 1 an | Lignes, tendances |
| Records personnels | 🆓 | Meilleurs performances | Par exercice |
| Comparaison périodes | 💎 | Comparer 2 périodes | Analyse |

**Paywall :**
- Stats basiques : 🆓 GRATUIT
- Stats avancées + comparaison : 💎 PREMIUM

---

<a name="avance"></a>
# ═══════════════════════════════════════════════════════════════
# ⚡ ONGLET AVANCÉ
# ═══════════════════════════════════════════════════════════════

**Fichier principal :** `lib/espace_pro_screen.dart`

L'onglet Avancé est divisé en 3 catégories : **Freemium**, **Premium**, **IA**

---

## CATÉGORIE FREEMIUM (Gratuit)

### 1. ANALYSE CORPORELLE

**Fichier :** `lib/body_analysis_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Entrer poids | 🆓 | Enregistrer son poids | Champ numérique |
| Calcul IMC | 🆓 | Indice de masse corporelle | Automatique |
| Entrer mensurations | 🆓 | Tour de taille, hanches, etc. | Formulaire |
| Graphique évolution | 🆓 | Courbe du poids | 30 derniers jours |
| Photos avant/après | 🆓 | Comparer visuellement | Galerie |
| Historique complet | 🔒 | Au-delà de 30 jours | Scroll |

**Paywall :**
- 30 jours : 🆓 GRATUIT
- Historique illimité : 💎 PREMIUM

---

### 2. CHAT COMMUNAUTAIRE

**Fichier :** `lib/community_chat_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Salons publics | 🆓 | Discussions par thème | Musculation, Cardio, etc. |
| Envoyer message | 🆓 | Participer aux discussions | Texte |
| Envoyer photo | 🆓 | Partager une image | Galerie/Caméra |
| Réagir aux messages | 🆓 | Emojis | Tap long |
| Créer salon privé | 💎 | Groupe privé | Invitations |

**Paywall :**
- Salons publics : 🆓 GRATUIT
- Salons privés : 💎 PREMIUM

---

### 3. CHAT MATCH™

**Fichier :** `lib/chat_match/chat_match_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Créer profil buddy | 🆓 | Définir ses préférences | Questionnaire |
| Voir suggestions | 🆓 | Partenaires compatibles | Swipe |
| Matcher | 🆓 | Accepter un partenaire | Bouton |
| Discuter avec match | 🆓 | Chat privé | Messagerie |
| Nombre de matchs | 🔒 | Limite quotidienne | 3/jour gratuit |

**Paywall :**
- 3 matchs/jour : 🆓 GRATUIT
- Matchs illimités : 💎 PREMIUM

---

### 4. VISIO TRAINING

**Fichier :** `lib/visio_training_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Créer session visio | 🆓 | Démarrer un appel | Bouton |
| Inviter amis | 🆓 | Partager lien | Copier/Partager |
| Rejoindre session | 🆓 | Entrer dans un appel | Via lien |
| Partager écran | 🆓 | Montrer sa séance | Bouton |
| Durée session | 🔒 | Limite de temps | 30 min gratuit |

**Paywall :**
- Sessions de 30 min : 🆓 GRATUIT
- Sessions illimitées : 💎 PREMIUM

---

### 5. SANTÉ & BLESSURES

**Fichier :** `lib/health_injuries_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Ajouter blessure | 🆓 | Enregistrer une blessure | Formulaire |
| Historique médical | 🆓 | Liste des blessures | Timeline |
| Exercices à éviter | 🆓 | Suggestions selon blessures | Automatique |
| Rappel RDV médecin | 🆓 | Notification | Date configurable |
| Export PDF | 💎 | Télécharger le carnet | Document |

**Paywall :**
- Carnet complet : 🆓 GRATUIT
- Export PDF : 💎 PREMIUM

---

### 6. ANNUAIRE

**Fichier :** `lib/coach_directory_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Rechercher coach | 🆓 | Trouver un coach | Barre recherche |
| Filtrer par spécialité | 🆓 | Musculation, Yoga, etc. | Dropdown |
| Voir profil coach | 🆓 | Détails du coach | Page profil |
| Voir avis | 🆓 | Notes et commentaires | Liste |
| Contacter coach | 🆓 | Envoyer message | Bouton |
| Carte interactive | 🆓 | Voir sur la carte | Vue map |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

### 7. PERSONNALITÉ COACH

**Fichier :** `lib/coach_personality/coach_personality_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir les personnalités | 🆓 | Liste des coachs virtuels | Grille |
| Écouter aperçu | 🆓 | Entendre la voix | Bouton play |
| Sélectionner coach | 🆓 | Choisir sa personnalité | Tap |
| Personnalités basiques | 🆓 | 3 personnalités | Motivant, Calme, Strict |
| Personnalités premium | 💎 | 10+ personnalités | Variées |

**Paywall :**
- 3 personnalités : 🆓 GRATUIT
- Toutes les personnalités : 💎 PREMIUM

---

### 8. ÉVÉNEMENTS

**Fichier :** `lib/events/events_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir événements | 🆓 | Liste des événements | Carousel |
| Filtrer par type | 🆓 | Marathon, Combat, etc. | Onglets |
| Détail événement | 🆓 | Infos complètes | Page |
| S'inscrire | 🆓 | Participer | Bouton |
| Créer événement | 🆓 | Organiser un event | Formulaire |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

### 9. SPORT GAMING™

**Fichier :** `lib/game_story/story_home.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir niveau/XP | 🆓 | Progression gamifiée | Header |
| Quêtes quotidiennes | 🆓 | Défis du jour | Liste |
| Gagner badges | 🆓 | Récompenses | Collection |
| Classement | 🆓 | Leaderboard | Top 100 |
| Chapitres histoire | 🔒 | Mode aventure | Story |

**Paywall :**
- Quêtes et badges : 🆓 GRATUIT
- Mode histoire complet : 💎 PREMIUM

---

### 10. MÉMO / NOTES

**Fichier :** `lib/memo_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Créer note | 🆓 | Écrire une note | Éditeur |
| Catégoriser | 🆓 | Sport, Nutrition, etc. | Tags |
| Modifier note | 🆓 | Éditer | Bouton |
| Supprimer note | 🆓 | Effacer | Bouton |
| Nombre de notes | 🔒 | Limite | 20 gratuites |

**Paywall :**
- 20 notes : 🆓 GRATUIT
- Notes illimitées : 💎 PREMIUM

---

### 11. PARRAINER ET GAGNER

**Fichier :** `lib/referral_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Code parrainage | 🆓 | Code unique à partager | Copier |
| Partager code | 🆓 | Envoyer par SMS/WhatsApp | Bouton |
| Voir filleuls | 🆓 | Liste des parrainés | Compteur |
| Gagner points | 🆓 | Récompenses | Automatique |
| Boutique points | 🆓 | Échanger les points | Catalogue |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

### 12. PUBLICATIONS / FEED

**Fichier :** `lib/social_feed_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir le feed | 🆓 | Publications de la communauté | Scroll infini |
| Publier | 🆓 | Créer un post | Photo + texte |
| Liker | 🆓 | Aimer un post | Bouton cœur |
| Commenter | 🆓 | Répondre | Zone texte |
| Partager | 🆓 | Republier | Bouton |
| Suivre utilisateur | 🆓 | S'abonner | Bouton follow |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

### 13. MES SUIVIS

**Fichier :** `lib/my_follows_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir abonnements | 🆓 | Liste des suivis | Grille |
| Voir abonnés | 🆓 | Liste des followers | Grille |
| Se désabonner | 🆓 | Arrêter de suivre | Bouton |
| Bloquer utilisateur | 🆓 | Bloquer quelqu'un | Bouton |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

### 14. CARTE INTERACTIVE

**Fichier :** `lib/map_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir carte | 🆓 | Google Maps | Vue carte |
| Voir coachs | 🆓 | Marqueurs coachs | Icônes |
| Voir salles | 🆓 | Marqueurs salles | Icônes |
| Voir événements | 🆓 | Marqueurs events | Icônes |
| Filtrer | 🆓 | Par type | Boutons |
| Itinéraire | 🆓 | Ouvrir dans Maps | Lien externe |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

## CATÉGORIE PREMIUM (Payant)

### 1. COACH BUSINESS™

**Fichier :** `lib/coach_business_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Dashboard coach | 👨‍🏫 | Vue d'ensemble business | Stats |
| Gérer clients | 👨‍🏫 | Liste des clients | CRUD |
| Suivi client | 👨‍🏫 | Progression de chaque client | Graphiques |
| Messagerie clients | 👨‍🏫 | Chat avec clients | Messagerie |
| Planning RDV | 👨‍🏫 | Gérer les créneaux | Calendrier |
| Facturation | 👨‍🏫 | Créer factures | PDF |
| Statistiques revenus | 👨‍🏫 | Suivi financier | Graphiques |

**Paywall :** 👨‍🏫 COACH PRO - Abonnement mensuel obligatoire

---

### 2. COURS LIVE

**Fichier :** `lib/live_courses_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir cours à venir | 🆓 | Liste des cours live | Calendrier |
| Détail cours | 🆓 | Infos sur le cours | Page |
| S'inscrire au cours | 💰 | Réserver sa place | Paiement |
| Rejoindre le live | 💰 | Participer en direct | Après paiement |
| Poser question | 💰 | Interagir avec le coach | Chat |

**Paywall :** 💰 ACHAT UNIQUE - Prix par cours (défini par le coach)

---

### 3. PACK VIDÉOS

**Fichier :** `lib/video_packs_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir les packs | 🆓 | Liste des packs dispo | Grille |
| Aperçu pack | 🆓 | Trailer/description | Vidéo courte |
| Acheter pack | 💰 | Débloquer le contenu | Paiement |
| Regarder vidéos | 💰 | Accès aux vidéos | Après achat |
| Télécharger | 💰 | Hors ligne | Bouton |

**Paywall :** 💰 ACHAT UNIQUE - Prix par pack (défini par le créateur)

---

### 4. REPLAYS

**Fichier :** `lib/replays_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir replays | 💎 | Cours passés enregistrés | Liste |
| Regarder replay | 💎 | Visionner | Lecteur vidéo |
| Filtrer par coach | 💎 | Rechercher | Dropdown |
| Filtrer par type | 💎 | Yoga, HIIT, etc. | Onglets |

**Paywall :** 💎 PREMIUM - Inclus dans l'abonnement

---

### 5. COACH VS COACH

**Fichier :** `lib/coach_vs_coach_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir les duels | 👨‍🏫 | Compétitions entre coachs | Liste |
| Participer | 👨‍🏫 | S'inscrire à un duel | Bouton |
| Voter | 🆓 | Voter pour un coach | Bouton |
| Classement | 🆓 | Voir les résultats | Leaderboard |

**Paywall :**
- Voter : 🆓 GRATUIT
- Participer : 👨‍🏫 COACH PRO

---

### 6. HARD CHALLENGE

**Fichier :** `lib/hard_challenge_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Voir challenges | 💎 | Défis extrêmes | Liste |
| S'inscrire | 💎 | Participer | Bouton |
| Soumettre preuve | 💎 | Vidéo/photo | Upload |
| Classement | 💎 | Voir les résultats | Leaderboard |
| Récompenses | 💎 | Badges spéciaux | Collection |

**Paywall :** 💎 PREMIUM - Inclus dans l'abonnement

---

### 7. SUIVI COACH/CLIENT

**Fichier :** `lib/coach_client_tracking_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Fiche client | 👨‍🏫 | Profil complet du client | Page |
| Ajouter mesures | 👨‍🏫 | Poids, mensurations | Formulaire |
| Notes privées | 👨‍🏫 | Notes non visibles par client | Éditeur |
| Graphiques progression | 👨‍🏫 | Évolution visuelle | Charts |
| Messagerie | 👨‍🏫 | Chat avec le client | Messagerie |

**Paywall :** 👨‍🏫 COACH PRO - Inclus dans l'abonnement coach

---

## CATÉGORIE IA (Payant)

### 1. COACH IA PREMIUM

**Fichier :** `lib/coach_ia_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Analyse posture | 🤖 | Détection via caméra | Temps réel |
| Correction vocale | 🤖 | Feedback audio | Voix synthétique |
| Comptage reps | 🤖 | Compte automatiquement | IA |
| Suggestions tempo | 🤖 | Rythme optimal | Audio |
| Rapport post-séance | 🤖 | Analyse complète | PDF |

**Paywall :** 🤖 PREMIUM IA - Abonnement IA obligatoire

---

### 2. FOODSCAN IA

**Fichier :** `lib/features/nutrition/food_scan/food_scan_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Scanner aliment | 🤖 | Photo → identification | Vision IA |
| Estimation macros | 🤖 | Calcul automatique | Approximation |
| Historique scans | 🤖 | Voir les anciens scans | Liste |

**Paywall :**
- 3 scans/jour : 🆓 GRATUIT (découverte)
- Illimité : 🤖 PREMIUM IA

---

### 3. MON ALTER EGO

**Fichier :** `lib/alter_ego.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Chat IA | 🤖 | Conversation avec l'assistant | Texte |
| Conseils personnalisés | 🤖 | Basés sur les données | Contextuels |
| Motivation | 🤖 | Encouragements | Messages |
| Questions illimitées | 🤖 | Pas de limite | Chat |

**Paywall :**
- 5 messages/jour : 🆓 GRATUIT (découverte)
- Illimité : 🤖 PREMIUM IA

---

### 4. TRANSFORMATION IA

**Fichier :** `lib/transformation_ia_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Upload photo | 🤖 | Envoyer sa photo | Galerie |
| Choisir objectif | 🤖 | Perte poids, muscle, etc. | Sélection |
| Générer résultat | 🤖 | Voir le "après" simulé | IA générative |
| Télécharger | 🤖 | Sauvegarder l'image | Bouton |

**Paywall :**
- 1 transformation/mois : 🆓 GRATUIT (découverte)
- Illimité : 🤖 PREMIUM IA

---

<a name="profil"></a>
# ═══════════════════════════════════════════════════════════════
# 👤 ONGLET PROFIL
# ═══════════════════════════════════════════════════════════════

**Fichier principal :** `lib/profile_page.dart`

---

## 1. INFORMATIONS PERSONNELLES

| Élément | Statut | Ce que ça fait | Détail |
|---------|--------|----------------|--------|
| Photo de profil | 🆓 | Modifier sa photo | Galerie/Caméra |
| Nom, prénom | 🆓 | Modifier | Champs texte |
| Email | 🆓 | Affichage (non modifiable) | Lecture seule |
| Date de naissance | 🆓 | Modifier | Date picker |
| Genre | 🆓 | Modifier | Dropdown |
| Taille | 🆓 | Modifier | Champ numérique |
| Poids objectif | 🆓 | Modifier | Champ numérique |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

## 2. PARAMÈTRES

| Paramètre | Statut | Ce que ça fait | Détail |
|-----------|--------|----------------|--------|
| Notifications | 🆓 | Activer/désactiver | Toggle |
| Thème sombre | 🆓 | Mode dark | Toggle |
| Langue | 🆓 | Changer la langue | Dropdown |
| Unités | 🆓 | kg/lbs, cm/inches | Dropdown |
| Confidentialité | 🆓 | Profil public/privé | Toggle |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

## 3. ABONNEMENT

| Élément | Statut | Ce que ça fait | Détail |
|---------|--------|----------------|--------|
| Voir mon abonnement | 🆓 | Statut actuel | Affichage |
| Passer Premium | 🆓 | Page d'achat | Bouton |
| Gérer abonnement | 💎 | Modifier/annuler | Page |
| Historique paiements | 💎 | Factures | Liste |

**Paywall :** Gestion réservée aux abonnés

---

## 4. DONNÉES & EXPORT

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Exporter mes données | 💎 | Télécharger tout | ZIP |
| Supprimer mon compte | 🆓 | Effacer définitivement | Bouton danger |

**Paywall :**
- Suppression compte : 🆓 GRATUIT
- Export données : 💎 PREMIUM

---

<a name="recherche"></a>
# ═══════════════════════════════════════════════════════════════
# 🔍 BARRE DE RECHERCHE GLOBALE
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/global_search_page.dart`

| Fonctionnalité | Statut | Ce que ça fait | Détail |
|----------------|--------|----------------|--------|
| Recherche exercices | 🆓 | Trouver un exercice | Résultats |
| Recherche recettes | 🆓 | Trouver une recette | Résultats |
| Recherche utilisateurs | 🆓 | Trouver un membre | Résultats |
| Recherche coachs | 🆓 | Trouver un coach | Résultats |
| Recherche séances | 🆓 | Trouver une séance | Résultats |
| Suggestions récentes | 🆓 | Historique recherche | Liste |

**Paywall :** Aucun - 🆓 TOUT GRATUIT

---

<a name="widgets"></a>
# ═══════════════════════════════════════════════════════════════
# 🧩 WIDGETS GLOBAUX
# ═══════════════════════════════════════════════════════════════

## 1. BULLE ALTER EGO (Flottante)

**Fichier :** `lib/alter_ego_floating/alter_ego_floating_widget.dart`

| Élément | Statut | Ce que ça fait | Détail |
|---------|--------|----------------|--------|
| Bulle visible | 🆓 | Icône en bas à droite | Toutes pages |
| Ouvrir chat | 🆓 | Tap pour ouvrir | Overlay |
| Messages gratuits | 🆓 | 5 messages/jour | Limite |
| Messages illimités | 🤖 | Pas de limite | Premium IA |

**Paywall :**
- 5 messages/jour : 🆓 GRATUIT
- Illimité : 🤖 PREMIUM IA

---

## 2. BARRE DE NAVIGATION

| Onglet | Statut | Icône | Destination |
|--------|--------|-------|-------------|
| Accueil | 🆓 | 🏠 | Dashboard |
| Nutrition | 🆓 | 🥗 | Hub Nutrition |
| Séances | 🆓 | 🏋️ | Workouts |
| Avancé | 🆓 | ⚡ | Espace Pro |
| Profil | 🆓 | 👤 | Profil |

**Paywall :** Aucun - Navigation toujours accessible

---

<a name="recap"></a>
# ═══════════════════════════════════════════════════════════════
# 📊 TABLEAU RÉCAPITULATIF COMPLET
# ═══════════════════════════════════════════════════════════════

## FONCTIONNALITÉS 100% GRATUITES 🆓

| Catégorie | Fonctionnalités |
|-----------|-----------------|
| **Dashboard** | Résumé du jour, Accès rapides, Progression hebdo |
| **Nutrition** | Journal (7j), Calculatrice, Recettes (10), Explorer, Objectifs |
| **Séances** | Bibliothèque, Créer séance (5), Mes séances, Session, Calendrier (30j), Stats basiques |
| **Social** | Feed, Publications, Likes, Commentaires, Suivis, Annuaire |
| **Communauté** | Chat public, Chat Match (3/j), Visio (30min), Événements |
| **Outils** | Analyse corpo (30j), Santé, Mémo (20), Parrainage, Carte |
| **Gamification** | Quêtes, Badges, Classement |
| **Profil** | Infos perso, Paramètres, Suppression compte |

---

## FONCTIONNALITÉS PREMIUM 💎

| Fonctionnalité | Ce qui est limité en gratuit | Ce qui est débloqué |
|----------------|------------------------------|---------------------|
| **Historique nutrition** | 7 jours | Illimité |
| **Planning repas** | 3 jours | 7 jours + copie |
| **Liste courses** | Manuelle | Auto-générée |
| **Recettes perso** | 10 max | Illimitées |
| **Séances custom** | 5 max | Illimitées |
| **Historique séances** | 30 jours | Illimité |
| **Stats avancées** | Basiques | Graphiques complets |
| **Historique corpo** | 30 jours | Illimité |
| **Chat Match** | 3/jour | Illimité |
| **Visio Training** | 30 min | Illimité |
| **Salons privés** | Non | Oui |
| **Personnalités coach** | 3 | 10+ |
| **Mode histoire** | Limité | Complet |
| **Notes** | 20 max | Illimitées |
| **Replays** | Non | Oui |
| **Hard Challenge** | Non | Oui |
| **Export données** | Non | Oui |

---

## FONCTIONNALITÉS IA PREMIUM 🤖

| Fonctionnalité | Ce qui est limité en gratuit | Ce qui est débloqué |
|----------------|------------------------------|---------------------|
| **FoodScan** | 3 scans/jour | Illimité |
| **Alter Ego Chat** | 5 messages/jour | Illimité |
| **Transformation IA** | 1/mois | Illimité |
| **Coach IA posture** | Non | Oui |
| **Coach IA vocal** | Non | Oui |
| **Suggestions IA** | Non | Oui |
| **Programme IA** | Non | Oui |

---

## FONCTIONNALITÉS COACH PRO 👨‍🏫

| Fonctionnalité | Description |
|----------------|-------------|
| **Dashboard Business** | Vue d'ensemble des revenus et clients |
| **Gestion clients** | CRUD complet des clients |
| **Suivi client** | Progression, mensurations, notes |
| **Messagerie clients** | Chat intégré |
| **Planning RDV** | Gestion des créneaux |
| **Facturation** | Création de factures |
| **Cours Live** | Créer et vendre des cours |
| **Packs Vidéos** | Créer et vendre des packs |
| **Coach vs Coach** | Participer aux duels |

---

## ACHATS UNIQUES 💰

| Produit | Vendeur | Description |
|---------|---------|-------------|
| **Cours Live** | Coach | Participation à un cours en direct |
| **Pack Vidéos** | Coach/Créateur | Accès à un ensemble de vidéos |

---

# ═══════════════════════════════════════════════════════════════
# 🔒 IMPLÉMENTATION DES PAYWALLS
# ═══════════════════════════════════════════════════════════════

## COMMENT BLOQUER UNE FONCTIONNALITÉ

### 1. Vérifier l'abonnement

```dart
// Fichier: lib/models/subscription_status.dart
class SubscriptionStatus {
  final bool isPremium;
  final bool hasAI;
  final bool isCoachPro;
  
  bool canAccess(FeatureType feature) {
    switch (feature) {
      case FeatureType.unlimited_recipes:
        return isPremium;
      case FeatureType.food_scan_unlimited:
        return hasAI;
      case FeatureType.client_management:
        return isCoachPro;
      // ...
    }
  }
}
```

### 2. Afficher le paywall

```dart
// Quand l'utilisateur tente d'accéder à une fonctionnalité bloquée
void _onFeatureTap(FeatureType feature) {
  if (!subscriptionStatus.canAccess(feature)) {
    showPaywallDialog(context, feature);
    return;
  }
  // Accès autorisé, continuer...
}
```

### 3. Design du paywall

```dart
// Fichier: lib/widgets/paywall_dialog.dart
class PaywallDialog extends StatelessWidget {
  final FeatureType feature;
  
  // Afficher:
  // - Icône de la fonctionnalité
  // - Titre "Fonctionnalité Premium"
  // - Description de ce qui est débloqué
  // - Bouton "Voir les offres"
  // - Bouton "Plus tard"
}
```

---

## INDICATEURS VISUELS

| Situation | Indicateur visuel |
|-----------|-------------------|
| Fonctionnalité Premium | Badge 💎 ou 🔒 sur l'icône |
| Fonctionnalité IA | Badge 🤖 sur l'icône |
| Limite atteinte | Message "X/Y utilisés" |
| Fonctionnalité bloquée | Overlay grisé + cadenas |

---

## MESSAGES D'UPSELL

| Moment | Message suggéré |
|--------|-----------------|
| Limite recettes atteinte | "Tu as atteint la limite de 10 recettes. Passe Premium pour en créer plus !" |
| Limite scans atteinte | "Tu as utilisé tes 3 scans du jour. Passe Premium IA pour scanner sans limite !" |
| Accès historique | "Ton historique de 30 jours est complet. Passe Premium pour voir toute ton évolution !" |
| Fonctionnalité IA | "Cette fonctionnalité utilise l'intelligence artificielle. Découvre Premium IA !" |

---

> **Document pour l'équipe Cursor**  
> UKAN - Application Fitness Complète  
> © 2024 Ukan - Tous droits réservés  
> 
> **Dernière mise à jour :** Décembre 2024







