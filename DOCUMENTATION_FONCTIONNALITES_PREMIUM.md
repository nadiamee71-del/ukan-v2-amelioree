# ⭐ DOCUMENTATION - FONCTIONNALITÉS PREMIUM DE UKAN

> **Toutes les fonctionnalités payantes (hors IA pure)**  
> Nécessitent un abonnement Premium pour être accessibles  
> Version : 2.0 | Date : Décembre 2024

---

# 📍 LOCALISATION DANS L'APP

Les fonctionnalités Premium sont accessibles depuis :
- **Onglet Avancé** → Catégorie "Premium" (onglet doré)

---

# ═══════════════════════════════════════════════════════════════
# 🏪 1. COACH BUSINESS™
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/coach_business/business_dashboard.dart`

**Accès :** Onglet Avancé → Premium → Coach Business™

**Pour qui :** Les coachs qui veulent vendre leurs services

---

## 📝 DESCRIPTION

Coach Business™ est une plateforme complète permettant aux coachs de créer, vendre et gérer leurs produits (programmes, vidéos, coaching) directement dans l'application.

---

## 🎯 OBJECTIF

- Permettre aux coachs de monétiser leur expertise
- Gérer les ventes et les clients
- Suivre les revenus et les performances

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Dashboard principal

| Élément | Description |
|---------|-------------|
| **Revenus du mois** | Montant total généré ce mois |
| **Revenus de la semaine** | Montant de la semaine en cours |
| **Nombre de ventes** | Ventes totales du mois |
| **Nouveaux clients** | Clients acquis ce mois |
| **Graphique évolution** | Courbe des revenus sur 12 mois |

### 2. Mes Produits

| Type de produit | Description |
|-----------------|-------------|
| **Programme d'entraînement** | Programme complet sur X semaines avec séances |
| **Pack vidéos** | Collection de vidéos d'exercices |
| **Coaching individuel** | Séances de coaching 1-to-1 |
| **Abonnement mensuel** | Accès à tout le contenu du coach |
| **E-book / Guide** | Document PDF téléchargeable |

### 3. Créer un produit

| Champ | Description |
|-------|-------------|
| **Type** | Programme, Pack vidéos, Coaching, Abonnement, E-book |
| **Nom** | Titre du produit |
| **Description** | Description détaillée |
| **Prix** | Prix en euros |
| **Prix barré** | Ancien prix (pour promotions) |
| **Image couverture** | Photo du produit |
| **Contenu** | Ajouter les éléments (séances, vidéos, etc.) |
| **Durée d'accès** | Illimité, 3 mois, 6 mois, 1 an |
| **Visibilité** | Public, Privé (lien uniquement) |

### 4. Gestion des clients

| Fonctionnalité | Description |
|----------------|-------------|
| **Liste des clients** | Tous les acheteurs |
| **Détail client** | Historique d'achats, progression |
| **Messagerie** | Communiquer avec les clients |
| **Notes** | Ajouter des notes sur un client |
| **Suivi** | Voir la progression du client |

### 5. Statistiques avancées

| Statistique | Description |
|-------------|-------------|
| **Produit le plus vendu** | Classement des produits |
| **Taux de conversion** | Visiteurs → Acheteurs |
| **Panier moyen** | Montant moyen par achat |
| **Taux de rétention** | Clients qui rachètent |
| **Avis clients** | Notes et commentaires |

### 6. Paiements et virements

| Élément | Description |
|---------|-------------|
| **Solde disponible** | Montant prêt à être viré |
| **Historique** | Liste des virements passés |
| **Demander un virement** | Transférer vers compte bancaire |
| **Factures** | Générer des factures |
| **Commission** | 15% prélevé par Ukan |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Coach Business™           ⚙️     │
├─────────────────────────────────────┤
│                                     │
│  💰 Revenus du mois                 │
│  ┌─────────────────────────────┐    │
│  │        2 450,00 €           │    │
│  │        +23% vs mois dernier │    │
│  └─────────────────────────────┘    │
│                                     │
│  📊 Cette semaine                   │
│  ┌───────┐ ┌───────┐ ┌───────┐     │
│  │ 580€  │ │ 12    │ │ 5     │     │
│  │Revenus│ │Ventes │ │Clients│     │
│  └───────┘ └───────┘ └───────┘     │
│                                     │
│  📦 Mes Produits                    │
│  ┌─────────────────────────────┐    │
│  │ 🏋️ Programme Prise de Masse │    │
│  │    49,99€  •  23 ventes     │    │
│  ├─────────────────────────────┤    │
│  │ 📹 Pack Vidéos Abdos        │    │
│  │    19,99€  •  45 ventes     │    │
│  ├─────────────────────────────┤    │
│  │ 👤 Coaching Individuel      │    │
│  │    80€/h   •  8 clients     │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  ➕ CRÉER UN PRODUIT        │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 🎥 2. COURS LIVE (Cours Collectifs en Direct)
# ═══════════════════════════════════════════════════════════════

**Fichiers :**
- `lib/group_classes/group_class_live.dart`
- `lib/group_classes/group_class_planning_page.dart`
- `lib/group_classes/group_class_create_page.dart`

**Accès :** Onglet Avancé → Premium → Cours Live

---

## 📝 DESCRIPTION

Plateforme de cours collectifs en direct style TikTok Live, permettant aux coachs de donner des cours et aux utilisateurs d'y participer en temps réel.

---

## 🎯 OBJECTIF

- Proposer des cours collectifs accessibles partout
- Créer une communauté autour des cours
- Permettre aux coachs de toucher plus de monde

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### POUR LES UTILISATEURS

#### 1. Planning des cours

| Élément | Description |
|---------|-------------|
| **Sélecteur de jour** | Lun, Mar, Mer, Jeu, Ven, Sam, Dim |
| **Filtres catégorie** | HIIT, Yoga, Boxe, Danse, Musculation, etc. |
| **Liste des cours** | Cours du jour sélectionné |

#### 2. Carte d'un cours

| Élément | Description |
|---------|-------------|
| **Heure** | Badge avec l'heure (ex: "10:00") |
| **Nom du cours** | Titre (ex: "HIIT Brûle-Graisses") |
| **Photo coach** | Miniature du coach |
| **Nom coach** | Nom du coach |
| **Niveau** | Badge Débutant/Intermédiaire/Avancé |
| **Durée** | "45 min", "60 min" |
| **Prix** | "15,00 €" |
| **Participants** | "12/20" avec barre de progression |
| **Bouton Démo** | Voir 5 min gratuitement |
| **Bouton Participer** | S'inscrire et payer |

#### 3. Pendant le cours live

| Élément | Description |
|---------|-------------|
| **Vidéo du coach** | Plein écran |
| **Timer** | Temps restant |
| **Chat en direct** | Messages des participants |
| **Réactions** | Envoyer des emojis (❤️ 🔥 💪) |
| **Participants** | Liste des personnes présentes |
| **Quitter** | Bouton pour quitter le cours |

#### 4. Catégories disponibles

| Catégorie | Emoji | Description |
|-----------|-------|-------------|
| **HIIT** | 🔥 | Entraînement fractionné haute intensité |
| **Yoga** | 🧘 | Yoga et relaxation |
| **Boxe** | 🥊 | Boxe fitness et cardio boxing |
| **Danse** | 💃 | Zumba, danse fitness |
| **Musculation** | 💪 | Renforcement musculaire |
| **Cardio** | ❤️ | Cardio training |
| **Pilates** | 🤸 | Pilates et gainage |
| **Stretching** | 🧘‍♀️ | Étirements et souplesse |
| **CrossFit** | 🏋️ | Entraînement fonctionnel |
| **Zumba** | 🎉 | Danse latino fitness |
| **Judo** | 🥋 | Arts martiaux |
| **MMA** | 🤼 | Mixed Martial Arts |
| **Karaté** | 🥷 | Arts martiaux |
| **Cycling** | 🚴 | Vélo indoor |

---

### POUR LES COACHS

#### 1. Créer un cours

| Champ | Description |
|-------|-------------|
| **Nom** | Titre du cours |
| **Description** | Description détaillée |
| **Catégorie** | Type de cours |
| **Niveau** | Débutant, Intermédiaire, Avancé |
| **Date** | Date du cours |
| **Heure** | Heure de début |
| **Durée totale** | En minutes |
| **Prix** | En euros |
| **Durée démo** | Minutes de démo gratuite (0-10 min) |
| **Max participants** | Limite de places |
| **Équipement requis** | Matériel nécessaire |
| **Récurrence** | Unique, Hebdomadaire, Quotidien |

#### 2. Pendant le cours (côté coach)

| Élément | Description |
|---------|-------------|
| **Caméra** | Vue de sa caméra |
| **Micro** | Contrôle du son |
| **Timer** | Gérer le temps |
| **Participants** | Voir qui est connecté |
| **Chat** | Lire et répondre aux messages |
| **Partager écran** | Montrer un exercice |
| **Terminer** | Fin du cours |

#### 3. Statistiques du cours

| Stat | Description |
|------|-------------|
| **Participants** | Nombre de personnes ayant participé |
| **Revenus** | Montant généré |
| **Durée moyenne** | Temps moyen de participation |
| **Notes** | Avis des participants |
| **Replay** | Nombre de vues du replay |

---

## 📱 INTERFACE - PLANNING

```
┌─────────────────────────────────────┐
│  ← Cours Live                       │
├─────────────────────────────────────┤
│                                     │
│  Lun  Mar  Mer  Jeu  Ven  Sam  Dim │
│   ○    ●    ○    ○    ○    ○    ○  │
│                                     │
│  Filtres:                           │
│  [Tous] [🔥HIIT] [🧘Yoga] [🥊Boxe] │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  10:00  HIIT Brûle-Graisses        │
│  ┌─────────────────────────────┐    │
│  │ 👤 Coach Marie  •  45 min   │    │
│  │ 🏷️ Intermédiaire           │    │
│  │ 💰 15,00€  •  👥 12/20      │    │
│  │ ████████████░░░░░░          │    │
│  │                             │    │
│  │ [Démo 5min]  [Participer]   │    │
│  └─────────────────────────────┘    │
│                                     │
│  14:00  Yoga Détente               │
│  ┌─────────────────────────────┐    │
│  │ 👤 Coach Sophie  •  60 min  │    │
│  │ 🏷️ Débutant                │    │
│  │ 💰 12,00€  •  👥 8/15       │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 📹 3. PACK VIDÉOS
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/pages/video_packs_page.dart`

**Accès :** Onglet Avancé → Premium → Pack Vidéos

---

## 📝 DESCRIPTION

Bibliothèque de packs vidéos d'exercices premium, créés par des coachs professionnels, avec des explications détaillées et un suivi de progression.

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Catalogue de packs

| Élément | Description |
|---------|-------------|
| **Filtres** | Par catégorie, niveau, coach, prix |
| **Recherche** | Rechercher un pack |
| **Tri** | Popularité, Prix, Nouveautés |

### 2. Carte d'un pack

| Élément | Description |
|---------|-------------|
| **Image couverture** | Aperçu du pack |
| **Titre** | Nom du pack |
| **Coach** | Créateur du pack |
| **Nombre de vidéos** | "12 vidéos" |
| **Durée totale** | "2h30 de contenu" |
| **Niveau** | Débutant, Intermédiaire, Avancé |
| **Prix** | Prix du pack |
| **Note** | Étoiles et nombre d'avis |
| **Bouton Aperçu** | Voir une vidéo gratuite |
| **Bouton Acheter** | Acheter le pack |

### 3. Détail d'un pack

| Section | Description |
|---------|-------------|
| **Description** | Description complète |
| **Ce que tu vas apprendre** | Liste des compétences |
| **Liste des vidéos** | Toutes les vidéos du pack |
| **Avis** | Commentaires des acheteurs |
| **Coach** | Profil du coach |

### 4. Lecteur vidéo

| Fonctionnalité | Description |
|----------------|-------------|
| **Lecture/Pause** | Contrôle de lecture |
| **Barre de progression** | Naviguer dans la vidéo |
| **Vitesse** | 0.5x, 1x, 1.25x, 1.5x, 2x |
| **Plein écran** | Mode plein écran |
| **Télécharger** | Télécharger pour hors-ligne |
| **Marquer comme vu** | Progression automatique |

### 5. Mes packs achetés

| Élément | Description |
|---------|-------------|
| **Liste des packs** | Packs achetés |
| **Progression** | "8/12 vidéos vues" |
| **Reprendre** | Continuer où on s'est arrêté |
| **Téléchargements** | Vidéos disponibles hors-ligne |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Pack Vidéos                      │
├─────────────────────────────────────┤
│                                     │
│  🔍 Rechercher...                   │
│                                     │
│  Catégories:                        │
│  [Tous] [Abdos] [Bras] [Jambes]    │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 📹 Abdos en Béton           │    │
│  │ Coach Mike  •  12 vidéos    │    │
│  │ 2h30  •  Intermédiaire      │    │
│  │ ⭐ 4.8 (234 avis)           │    │
│  │ 💰 24,99€                   │    │
│  │                             │    │
│  │ [Aperçu]     [Acheter]      │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 📹 Bras Sculptés            │    │
│  │ Coach Sarah  •  8 vidéos    │    │
│  │ 1h45  •  Débutant           │    │
│  │ ⭐ 4.6 (156 avis)           │    │
│  │ 💰 19,99€                   │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 🔄 4. REPLAYS
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/group_classes/group_class_replays.dart`

**Accès :** Onglet Avancé → Premium → Replays

---

## 📝 DESCRIPTION

Accès aux enregistrements des cours collectifs passés, permettant de suivre les cours à son rythme.

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Catalogue des replays

| Élément | Description |
|---------|-------------|
| **Filtres** | Par catégorie, coach, date, durée |
| **Recherche** | Rechercher un cours |
| **Tri** | Date, Popularité, Durée |

### 2. Carte d'un replay

| Élément | Description |
|---------|-------------|
| **Miniature** | Aperçu du cours |
| **Titre** | Nom du cours |
| **Coach** | Nom du coach |
| **Date** | Date du cours original |
| **Durée** | Durée du replay |
| **Catégorie** | Type de cours |
| **Vues** | Nombre de vues |
| **Bouton Regarder** | Lancer le replay |
| **Bouton Télécharger** | Télécharger pour hors-ligne |

### 3. Lecteur de replay

| Fonctionnalité | Description |
|----------------|-------------|
| **Lecture/Pause** | Contrôle de lecture |
| **Avance/Recul** | +10s / -10s |
| **Barre de progression** | Naviguer dans la vidéo |
| **Vitesse** | 0.5x, 1x, 1.25x, 1.5x, 2x |
| **Plein écran** | Mode plein écran |
| **Chapitres** | Sauter aux différentes parties |

### 4. Mes replays

| Élément | Description |
|---------|-------------|
| **Historique** | Replays déjà regardés |
| **En cours** | Reprendre où on s'est arrêté |
| **Favoris** | Replays sauvegardés |
| **Téléchargés** | Disponibles hors-ligne |

---

# ═══════════════════════════════════════════════════════════════
# 🏆 5. COACH VS COACH
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/coach_vs_coach/coach_ranking_page.dart`

**Accès :** Onglet Avancé → Premium → Coach vs Coach

---

## 📝 DESCRIPTION

Système de classement et de compétition entre coachs, basé sur différents critères de performance.

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Classements

| Classement | Critère |
|------------|---------|
| **Top Notes** | Meilleure note moyenne |
| **Top Élèves** | Plus grand nombre d'élèves |
| **Top Revenus** | Revenus générés |
| **Top Cours Live** | Nombre de cours donnés |
| **Top Engagement** | Taux d'engagement des élèves |

### 2. Profil dans le classement

| Élément | Description |
|---------|-------------|
| **Position** | #1, #2, #3... |
| **Photo** | Photo du coach |
| **Nom** | Nom du coach |
| **Spécialité** | Domaine d'expertise |
| **Score** | Valeur du critère |
| **Évolution** | ↑ +3 ou ↓ -2 vs semaine dernière |

### 3. Badges et récompenses

| Badge | Condition |
|-------|-----------|
| **🥇 Top 1** | Premier du classement |
| **🥈 Top 3** | Dans le top 3 |
| **🥉 Top 10** | Dans le top 10 |
| **⭐ 5 étoiles** | Note moyenne de 5 |
| **🔥 Streak** | 10 cours consécutifs |
| **💯 100 élèves** | 100 élèves atteints |
| **🎯 Expert** | Spécialisation reconnue |

### 4. Défis entre coachs

| Type de défi | Description |
|--------------|-------------|
| **Défi hebdomadaire** | Plus de cours donnés cette semaine |
| **Défi mensuel** | Meilleure progression |
| **Défi communautaire** | Objectif collectif |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Coach vs Coach            🏆     │
├─────────────────────────────────────┤
│                                     │
│  [Notes] [Élèves] [Revenus] [Live] │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🥇 #1  Coach Marie                │
│  ┌─────────────────────────────┐    │
│  │ 👤 ⭐ 4.98  •  HIIT         │    │
│  │ 156 élèves  •  ↑ +2        │    │
│  └─────────────────────────────┘    │
│                                     │
│  🥈 #2  Coach Thomas               │
│  ┌─────────────────────────────┐    │
│  │ 👤 ⭐ 4.95  •  Musculation   │    │
│  │ 142 élèves  •  ↑ +5        │    │
│  └─────────────────────────────┘    │
│                                     │
│  🥉 #3  Coach Sophie               │
│  ┌─────────────────────────────┐    │
│  │ 👤 ⭐ 4.92  •  Yoga          │    │
│  │ 128 élèves  •  ↓ -1        │    │
│  └─────────────────────────────┘    │
│                                     │
│  #4  Coach Lucas                   │
│  #5  Coach Emma                    │
│  ...                               │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 🔥 6. HARD CHALLENGE
# ═══════════════════════════════════════════════════════════════

**Fichiers :**
- `lib/hard_challenge/hard_challenge_page.dart`
- `lib/hard_challenge/hard_challenge_model.dart`
- `lib/hard_challenge/create_challenge_page.dart`

**Accès :** Onglet Avancé → Premium → Hard Challenge

---

## 📝 DESCRIPTION

Système de défis intensifs sur 30, 50, 75 ou 90 jours avec des habitudes quotidiennes à valider, inspiré du "75 Hard Challenge" populaire sur TikTok.

---

## 🎯 OBJECTIF

- Créer une discipline quotidienne
- Atteindre des objectifs ambitieux
- Construire des habitudes durables
- Se challenger avec d'autres participants

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Page principale du challenge

| Section | Description |
|---------|-------------|
| **Résumé** | Nom, jour actuel, progression globale, streak |
| **Habitudes du jour** | Liste des habitudes à valider |
| **Calendrier** | Vue mensuelle avec couleurs |
| **Participants** | Autres personnes sur le même challenge |
| **Paramètres** | Configuration du challenge |

### 2. Habitudes sportives disponibles

| Habitude | Icône | Unité | Exemples d'objectifs |
|----------|-------|-------|---------------------|
| **Hydratation** | 💧 | Litres | 2L, 3L, 4L |
| **Pas quotidiens** | 🚶 | Pas | 5000, 8000, 10000 |
| **Séance sport** | 💪 | Oui/Non | 1 séance minimum |
| **Pompes** | 🏋️ | Répétitions | 30, 50, 100 |
| **Squats** | 🦵 | Répétitions | 50, 100, 200 |
| **Planche** | 🧘 | Secondes | 60, 120, 300 |
| **Course** | 🏃 | Kilomètres | 3, 5, 10 |
| **Corde à sauter** | ⏱️ | Minutes | 10, 15, 30 |
| **Burpees** | 🔥 | Répétitions | 20, 50, 100 |
| **Abdos** | 💪 | Répétitions | 50, 100, 200 |

### 3. Validation quotidienne

| Élément | Description |
|---------|-------------|
| **Checkbox** | Cocher quand l'habitude est faite |
| **Compteur** | Incrémenter la valeur (ex: +1L d'eau) |
| **Photo preuve** | Prendre une photo (optionnel) |
| **Heure** | Horodatage automatique |
| **Note** | Ajouter un commentaire |

### 4. Calendrier du challenge

| Couleur | Signification |
|---------|---------------|
| 🟢 **Vert** | Jour réussi (toutes habitudes validées) |
| 🟠 **Orange** | Jour partiel (certaines habitudes manquées) |
| 🔴 **Rouge** | Jour échoué (pas de validation) |
| ⚪ **Gris** | Jour futur |
| 🔵 **Bleu** | Jour actuel |

### 5. Création de challenge personnalisé

#### Étape 1 : Informations de base

| Champ | Description |
|-------|-------------|
| **Nom** | Nom personnalisé (ex: "Mon 75 Hard") |
| **Durée** | 30, 50, 75 ou 90 jours |
| **Motivation** | Pourquoi ce challenge ? |
| **Date de début** | Quand commencer |

#### Étape 2 : Objectifs quotidiens

| Champ | Description |
|-------|-------------|
| **Type d'exercice** | Sélection ou personnalisé |
| **Valeur cible** | Nombre à atteindre |
| **Unité** | Répétitions, secondes, km, L, pas |
| **Progression hebdo** | +X% par semaine (optionnel) |
| **Ajouter +** | Ajouter un autre objectif |

#### Étape 3 : Options

| Option | Description |
|--------|-------------|
| **Photo quotidienne** | Obligatoire ou optionnel |
| **Rappel** | Heure de notification |
| **Jour de repos** | Autoriser 1 jour off par semaine |

#### Étape 4 : Résumé

| Élément | Description |
|---------|-------------|
| **Aperçu** | Récapitulatif du challenge |
| **Bouton Créer** | Démarrer le challenge |

### 6. Challenges populaires (Templates)

| Template | Durée | Habitudes incluses |
|----------|-------|-------------------|
| **30 Push-ups** | 30 jours | 30 pompes/jour |
| **50 Squats** | 50 jours | 50 squats/jour |
| **Planche 5 min** | 30 jours | 5 min planche/jour |
| **10K Steps** | 75 jours | 10 000 pas/jour |
| **75 Hard Sport** | 75 jours | 2 séances + 3L eau + photo |
| **3K Run** | 30 jours | 3 km course/jour |
| **100 Burpees** | 30 jours | 100 burpees/jour |
| **Jump Rope** | 50 jours | 15 min corde/jour |

### 7. Participants et social

| Fonctionnalité | Description |
|----------------|-------------|
| **Inviter** | Inviter des amis ou coachs |
| **Voir les participants** | Liste avec leur progression |
| **Classement** | Qui a le plus long streak |
| **Partager** | Partager sa progression |
| **Encourager** | Envoyer des encouragements |

### 8. Partage

| Option | Description |
|--------|-------------|
| **Partager avec coach** | Envoyer au coach pour suivi |
| **Partager progression** | Image récapitulative |
| **Réseaux sociaux** | Partager sur Instagram, Facebook |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Hard Challenge            ⚙️ 📤  │
├─────────────────────────────────────┤
│                                     │
│  🔥 75 Hard Sport                   │
│  Jour 23 / 75                       │
│  ████████████░░░░░░░░░░  31%       │
│  🔥 Streak: 23 jours                │
│                                     │
├─────────────────────────────────────┤
│  Habitudes du jour                  │
│                                     │
│  ☑️ 💧 Hydratation     3/3 L       │
│  ☑️ 💪 Séance sport    ✓           │
│  ☐ 🚶 10 000 pas      6 432/10000  │
│  ☑️ 📸 Photo du jour   ✓           │
│                                     │
├─────────────────────────────────────┤
│  Calendrier                         │
│                                     │
│     L   M   M   J   V   S   D      │
│    🟢  🟢  🟢  🟢  🟢  🟢  🟢      │
│    🟢  🟢  🟢  🟢  🟢  🟢  🟢      │
│    🟢  🟢  🟢  🟢  🟢  🔵  ⚪      │
│    ⚪  ⚪  ⚪  ⚪  ⚪  ⚪  ⚪      │
│                                     │
├─────────────────────────────────────┤
│  👥 Participants (5)                │
│  Marie 🔥23 | Thomas 🔥21 | ...    │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 👥 7. SUIVI COACH / CLIENT
# ═══════════════════════════════════════════════════════════════

**Fichiers :**
- `lib/models/client_tracking.dart`
- `lib/models/chat.dart`
- `lib/chat_page.dart`
- `lib/coach_client_tracking_page.dart`

**Accès :** 
- **Pour le coach :** Onglet Profil → Mes Clients → Sélectionner un client
- **Pour le client :** Onglet Profil → Mon Coach

---

## 📝 DESCRIPTION

Système complet de suivi entre un coach et ses clients, incluant la messagerie, le suivi des progrès, les rendez-vous et les notes privées.

---

## 🎯 OBJECTIF

- Permettre un suivi personnalisé des clients
- Faciliter la communication coach/client
- Suivre les progrès et l'évolution
- Gérer les rendez-vous et les séances

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### CÔTÉ COACH

#### 1. Liste des clients

| Élément | Description |
|---------|-------------|
| **Photo** | Photo du client |
| **Nom** | Nom complet |
| **Objectif** | Objectif principal |
| **Dernière activité** | Date de dernière séance |
| **Progression** | Indicateur de progression |
| **Statut** | Actif, Inactif, Nouveau |

#### 2. Fiche client détaillée

| Section | Description |
|---------|-------------|
| **Profil** | Infos personnelles, objectifs |
| **Historique** | Séances effectuées |
| **Progression** | Graphiques d'évolution |
| **Mensurations** | Poids, tour de taille, etc. |
| **Photos** | Photos de progression |
| **Notes privées** | Notes du coach (non visibles par le client) |

#### 3. Suivi des progrès

| Donnée | Description |
|--------|-------------|
| **Poids** | Évolution du poids |
| **Tour de taille** | Évolution des mensurations |
| **Tour de hanches** | Évolution des mensurations |
| **Tour de poitrine** | Évolution des mensurations |
| **Séances faites** | Nombre de séances effectuées |
| **Assiduité** | % de séances respectées |

#### 4. Ajouter un point de suivi

| Champ | Description |
|-------|-------------|
| **Date** | Date de la mesure |
| **Poids** | Poids en kg |
| **Mensurations** | Tour de taille, hanches, etc. |
| **Séances** | Séances faites / prévues |
| **Notes** | Commentaires |
| **Photo** | Photo de progression |

#### 5. Notes privées du coach

| Fonctionnalité | Description |
|----------------|-------------|
| **Éditeur** | Zone de texte libre |
| **Confidentialité** | Non visible par le client |
| **Historique** | Sauvegarde automatique |
| **Rappels** | Points à aborder |

### CÔTÉ CLIENT

#### 1. Mon coach

| Élément | Description |
|---------|-------------|
| **Photo** | Photo du coach |
| **Nom** | Nom du coach |
| **Spécialité** | Domaine d'expertise |
| **Contact** | Bouton messagerie |
| **Prochaine séance** | Date et heure |

#### 2. Ma progression

| Élément | Description |
|---------|-------------|
| **Graphique poids** | Évolution dans le temps |
| **Graphique mensurations** | Évolution des tours |
| **Photos avant/après** | Comparaison visuelle |
| **Objectifs** | Progrès vers l'objectif |

#### 3. Mes séances avec le coach

| Élément | Description |
|---------|-------------|
| **Calendrier** | Séances passées et à venir |
| **Détail séance** | Exercices effectués |
| **Notes du coach** | Commentaires de la séance |

### MESSAGERIE COACH/CLIENT

| Fonctionnalité | Description |
|----------------|-------------|
| **Chat en temps réel** | Messages instantanés |
| **Photos** | Envoyer des photos |
| **Fichiers** | Partager des documents |
| **Vocal** | Messages vocaux |
| **Notifications** | Alertes de nouveaux messages |
| **Historique** | Conversation sauvegardée |

---

## 📱 INTERFACE - CÔTÉ COACH

```
┌─────────────────────────────────────┐
│  ← Sarah Martin              💬     │
├─────────────────────────────────────┤
│                                     │
│  👤 Sarah Martin                    │
│  Objectif: Perte de poids (-5kg)   │
│  Depuis: 15 Jan 2024               │
│  Dernière séance: Hier             │
│                                     │
├─────────────────────────────────────┤
│  📊 Progression                     │
│                                     │
│  Poids: 72.5 kg → 71.8 kg (-0.7)  │
│  ┌─────────────────────────────┐    │
│  │    ╭──╮                     │    │
│  │   ╭╯  ╰──╮                  │    │
│  │  ╭╯      ╰──────            │    │
│  │  Jan    Fév    Mar          │    │
│  └─────────────────────────────┘    │
│                                     │
│  Tour de taille: 78 cm → 76.5 cm  │
│  Séances: 6/6 (100% assiduité)    │
│                                     │
├─────────────────────────────────────┤
│  📝 Notes privées                   │
│  ┌─────────────────────────────┐    │
│  │ Bonne progression. Attention │    │
│  │ au genou droit, adapter les  │    │
│  │ squats. Prochaine séance:    │    │
│  │ focus cardio.                │    │
│  └─────────────────────────────┘    │
│                                     │
│  [➕ Ajouter un point de suivi]    │
│                                     │
└─────────────────────────────────────┘
```

---

## 📱 INTERFACE - MESSAGERIE

```
┌─────────────────────────────────────┐
│  ← Chat avec Sarah                  │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Salut Sarah, prêt(e)     │    │
│  │    pour la séance ?         │    │
│  │                   9:30 ✓✓   │    │
│  └─────────────────────────────┘    │
│                                     │
│         ┌─────────────────────────┐ │
│         │ Oui, je suis motivée ! │ │
│         │ 💪              9:45   │ │
│         └─────────────────────────┘ │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Parfait ! On se retrouve │    │
│  │    à 18h30 pour le full     │    │
│  │    body.           10:00 ✓✓ │    │
│  └─────────────────────────────┘    │
│                                     │
│         ┌─────────────────────────┐ │
│         │ Super, à tout à       │ │
│         │ l'heure ! 👍   10:05  │ │
│         └─────────────────────────┘ │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Écris ton message...    📤 │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 📅 8. PLANNING & RENDEZ-VOUS COACH
# ═══════════════════════════════════════════════════════════════

**Fichiers :**
- `lib/coach_planning_page.dart`
- `lib/coach_appointment_page.dart`
- `lib/models/planning.dart`

**Accès :** Onglet Profil (Coach) → Mon Planning

---

## 📝 DESCRIPTION

Système de gestion des rendez-vous et du planning pour les coachs, permettant de gérer les créneaux disponibles et les réservations des clients.

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Vue du planning

| Vue | Description |
|-----|-------------|
| **Jour** | Créneaux de la journée |
| **Semaine** | Vue hebdomadaire |
| **Mois** | Vue mensuelle |

### 2. Créneaux disponibles

| Élément | Description |
|---------|-------------|
| **Ajouter un créneau** | Définir une disponibilité |
| **Heure début** | Heure de début |
| **Heure fin** | Heure de fin |
| **Récurrence** | Unique, Hebdomadaire |
| **Type** | Présentiel, Visio, Les deux |

### 3. Rendez-vous

| Élément | Description |
|---------|-------------|
| **Client** | Nom du client |
| **Date/Heure** | Quand |
| **Durée** | Durée de la séance |
| **Type** | Présentiel ou Visio |
| **Lieu** | Adresse ou lien visio |
| **Notes** | Détails de la séance |

### 4. Actions sur un RDV

| Action | Description |
|--------|-------------|
| **Confirmer** | Valider le RDV |
| **Reporter** | Changer la date |
| **Annuler** | Annuler le RDV |
| **Rappel** | Envoyer un rappel au client |

### 5. Notifications

| Type | Description |
|------|-------------|
| **Nouvelle réservation** | Client a réservé |
| **Rappel 24h** | RDV demain |
| **Rappel 1h** | RDV dans 1 heure |
| **Annulation** | Client a annulé |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Mon Planning              ➕     │
├─────────────────────────────────────┤
│  [Jour] [Semaine] [Mois]           │
├─────────────────────────────────────┤
│                                     │
│  📅 Mardi 5 Décembre 2024          │
│                                     │
│  09:00 ░░░░░░░░░░░░░░░░░░░ Libre   │
│  10:00 ████████████████████ Sarah  │
│         Full body - Présentiel      │
│  11:00 ░░░░░░░░░░░░░░░░░░░ Libre   │
│  12:00 ░░░░░░░░░░░░░░░░░░░ Pause   │
│  13:00 ░░░░░░░░░░░░░░░░░░░ Pause   │
│  14:00 ████████████████████ Mehdi  │
│         Cardio - Visio 📹          │
│  15:00 ████████████████████ Mehdi  │
│  16:00 ░░░░░░░░░░░░░░░░░░░ Libre   │
│  17:00 ████████████████████ Lucas  │
│         Musculation - Présentiel    │
│  18:00 ████████████████████ Lucas  │
│  19:00 ░░░░░░░░░░░░░░░░░░░ Libre   │
│                                     │
│  Résumé: 3 RDV • 4h de coaching    │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 📊 RÉCAPITULATIF PREMIUM
# ═══════════════════════════════════════════════════════════════

| Fonctionnalité | Pour qui | Prix indicatif |
|----------------|----------|----------------|
| **Coach Business™** | Coachs | Inclus Premium Coach |
| **Cours Live** | Tous | Par cours (5-30€) |
| **Pack Vidéos** | Tous | Par pack (10-50€) |
| **Replays** | Tous | Inclus abonnement |
| **Coach vs Coach** | Coachs | Inclus Premium Coach |
| **Hard Challenge** | Tous | Inclus abonnement |
| **Suivi Coach/Client** | Coachs | Inclus Premium Coach |
| **Planning & RDV** | Coachs | Inclus Premium Coach |

---

## 💰 MODÈLE ÉCONOMIQUE

| Abonnement | Prix | Inclus |
|------------|------|--------|
| **Gratuit** | 0€ | Fonctionnalités Freemium |
| **Premium** | 9,99€/mois | Toutes les fonctionnalités Premium |
| **Premium Coach** | 29,99€/mois | Premium + Coach Business + Coach vs Coach |

---

> **Document Premium - Ukan**  
> Fonctionnalités payantes (hors IA pure)  
> © 2024 Ukan - Tous droits réservés

