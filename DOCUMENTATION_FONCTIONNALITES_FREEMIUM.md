# 🆓 DOCUMENTATION - FONCTIONNALITÉS FREEMIUM DE UKAN

> **Toutes les fonctionnalités gratuites (hors IA)**  
> Accessibles à tous les utilisateurs sans abonnement  
> Version : 2.0 | Date : Décembre 2024

---

# 📍 LOCALISATION DANS L'APP

Les fonctionnalités Freemium sont accessibles depuis :
- **Onglet Avancé** → Catégorie "Freemium" (onglet vert)

---

# ═══════════════════════════════════════════════════════════════
# 📊 1. ANALYSE CORPORELLE
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/body_composition_page.dart`

**Accès :** Onglet Avancé → Freemium → Analyse corporelle

---

## 📝 DESCRIPTION

Outil de suivi de la composition corporelle permettant de suivre l'évolution du poids, de l'IMC, de la masse grasse et de la masse musculaire.

---

## 🎯 OBJECTIF

- Suivre l'évolution du poids dans le temps
- Comprendre sa composition corporelle
- Visualiser les progrès

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Données suivies

| Donnée | Description | Unité |
|--------|-------------|-------|
| **Poids** | Poids corporel | kg |
| **Taille** | Taille (une seule fois) | cm |
| **IMC** | Indice de Masse Corporelle | kg/m² |
| **Masse grasse** | Estimation du % de graisse | % |
| **Masse musculaire** | Estimation de la masse maigre | kg |
| **Tour de taille** | Mesure du tour de taille | cm |
| **Tour de hanches** | Mesure du tour de hanches | cm |
| **Tour de bras** | Mesure du tour de bras | cm |
| **Tour de cuisses** | Mesure du tour de cuisses | cm |

### 2. Ajouter une mesure

| Champ | Description |
|-------|-------------|
| **Date** | Date de la mesure |
| **Poids** | Poids en kg |
| **Mesures** | Tours de taille, hanches, bras, cuisses (optionnel) |
| **Photo** | Photo de progression (optionnel) |
| **Note** | Commentaire (optionnel) |

### 3. Graphiques d'évolution

| Graphique | Description |
|-----------|-------------|
| **Courbe de poids** | Évolution du poids sur 1 mois, 3 mois, 6 mois, 1 an |
| **Courbe IMC** | Évolution de l'IMC |
| **Courbe masse grasse** | Évolution du % de graisse |
| **Courbe mensurations** | Évolution des tours |

### 4. Interprétation IMC

| IMC | Catégorie | Couleur |
|-----|-----------|---------|
| < 18.5 | Insuffisance pondérale | 🔵 Bleu |
| 18.5 - 24.9 | Poids normal | 🟢 Vert |
| 25 - 29.9 | Surpoids | 🟠 Orange |
| ≥ 30 | Obésité | 🔴 Rouge |

### 5. Objectifs

| Élément | Description |
|---------|-------------|
| **Poids objectif** | Poids à atteindre |
| **Date objectif** | Deadline |
| **Progression** | % de progression vers l'objectif |
| **Rythme** | kg perdus/gagnés par semaine |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Analyse Corporelle        ➕     │
├─────────────────────────────────────┤
│                                     │
│  Poids actuel                       │
│  ┌─────────────────────────────┐    │
│  │        75.2 kg              │    │
│  │   IMC: 24.1 (Normal) 🟢    │    │
│  │   -2.3 kg depuis le début   │    │
│  └─────────────────────────────┘    │
│                                     │
│  Objectif: 72 kg                    │
│  ████████████░░░░░░  72%           │
│                                     │
│  📊 Évolution du poids              │
│  ┌─────────────────────────────┐    │
│  │    ╭─╮                      │    │
│  │   ╭╯ ╰─╮    ╭╮             │    │
│  │  ╭╯    ╰────╯╰─────        │    │
│  │  Jan  Fév  Mar  Avr  Mai   │    │
│  └─────────────────────────────┘    │
│                                     │
│  Mensurations                       │
│  Tour de taille: 82 cm (-3 cm)     │
│  Tour de hanches: 95 cm (-2 cm)    │
│  Tour de bras: 32 cm (+1 cm)       │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 💬 2. CHAT COMMUNAUTAIRE
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/community_chat_page.dart`

**Accès :** Onglet Avancé → Freemium → Chat communautaire

---

## 📝 DESCRIPTION

Espace de discussion entre tous les membres de la communauté Ukan, organisé par salons thématiques.

---

## 🎯 OBJECTIF

- Créer du lien entre les membres
- Partager des conseils et expériences
- Trouver de la motivation collective

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Salons de discussion

| Salon | Description |
|-------|-------------|
| **💪 Motivation** | Encouragements et motivation |
| **🏋️ Entraînement** | Questions et conseils d'entraînement |
| **🥗 Nutrition** | Recettes et conseils nutrition |
| **🎯 Objectifs** | Partage d'objectifs et progrès |
| **❓ Aide** | Questions générales |
| **🎉 Célébrations** | Partager ses victoires |
| **🌍 Général** | Discussions libres |

### 2. Fonctionnalités du chat

| Fonctionnalité | Description |
|----------------|-------------|
| **Envoyer un message** | Texte jusqu'à 500 caractères |
| **Envoyer une photo** | Partager une image |
| **Répondre** | Répondre à un message spécifique |
| **Réagir** | Ajouter une réaction (❤️ 🔥 💪 👏 😂) |
| **Mentionner** | @pseudo pour notifier quelqu'un |
| **Signaler** | Signaler un message inapproprié |

### 3. Profil dans le chat

| Élément | Description |
|---------|-------------|
| **Photo** | Photo de profil |
| **Pseudo** | Nom d'utilisateur |
| **Badge** | Niveau ou statut (Nouveau, Actif, VIP, Coach) |
| **Voir profil** | Accéder au profil complet |

### 4. Notifications

| Type | Description |
|------|-------------|
| **Mention** | Quand quelqu'un vous mentionne |
| **Réponse** | Quand quelqu'un répond à votre message |
| **Réaction** | Quand quelqu'un réagit à votre message |

### 5. Modération

| Règle | Description |
|-------|-------------|
| **Respect** | Pas d'insultes ni de harcèlement |
| **Spam** | Pas de publicité ni de spam |
| **Contenu** | Pas de contenu inapproprié |
| **Signalement** | Les messages signalés sont examinés |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Chat Communautaire               │
├─────────────────────────────────────┤
│  Salons:                            │
│  [💪 Motivation] [🏋️ Entraînement] │
│  [🥗 Nutrition] [🎯 Objectifs]      │
├─────────────────────────────────────┤
│                                     │
│  👤 Marie  •  il y a 5 min          │
│  ┌─────────────────────────────┐    │
│  │ Salut ! Quelqu'un a des     │    │
│  │ conseils pour les abdos ?   │    │
│  │ ❤️ 3  💪 2                  │    │
│  └─────────────────────────────┘    │
│                                     │
│  👤 Thomas  •  il y a 3 min         │
│  ┌─────────────────────────────┐    │
│  │ @Marie Essaie les planches  │    │
│  │ latérales, c'est top !      │    │
│  │ ❤️ 5                        │    │
│  └─────────────────────────────┘    │
│                                     │
│  👤 Sophie  •  il y a 1 min         │
│  ┌─────────────────────────────┐    │
│  │ 📷 [Photo de transformation]│    │
│  │ 3 mois de travail ! 💪      │    │
│  │ ❤️ 24  🔥 15  👏 8          │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Écris ton message...    📤 │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# ❤️ 3. CHAT MATCH™
# ═══════════════════════════════════════════════════════════════

**Fichiers :**
- `lib/chat_match/match_home_page.dart`
- `lib/chat_match/match_results_page.dart`
- `lib/chat_match/match_engine.dart`
- `lib/chat_match/match_profile.dart`

**Accès :** Onglet Avancé → Freemium → Chat Match™

---

## 📝 DESCRIPTION

Système de matching pour trouver des partenaires d'entraînement compatibles, inspiré des applications de rencontre.

---

## 🎯 OBJECTIF

- Trouver des partenaires sportifs motivés
- S'entraîner à plusieurs pour plus de motivation
- Créer des liens avec des personnes partageant les mêmes objectifs

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Création du profil de matching

| Champ | Description |
|-------|-------------|
| **Photo** | Photo de profil |
| **Prénom** | Prénom uniquement |
| **Âge** | Âge |
| **Ville** | Localisation |
| **Niveau** | Débutant, Intermédiaire, Avancé |
| **Objectifs** | Perte de poids, Prise de masse, Tonification, etc. |
| **Disponibilités** | Matin, Midi, Soir, Week-end |
| **Sports pratiqués** | Musculation, Cardio, Yoga, etc. |
| **Type de partenaire** | Même niveau, Plus expérimenté, Peu importe |

### 2. Critères de compatibilité

| Critère | Poids |
|---------|-------|
| **Objectifs similaires** | 30% |
| **Niveau proche** | 25% |
| **Disponibilités communes** | 20% |
| **Sports en commun** | 15% |
| **Proximité géographique** | 10% |

### 3. Interface de matching (style Tinder)

| Action | Description |
|--------|-------------|
| **Swipe droite** | Like - Intéressé |
| **Swipe gauche** | Passer - Pas intéressé |
| **Super Like** | Très intéressé (limité à 3/jour) |
| **Voir profil** | Détails du profil |

### 4. Profil affiché

| Élément | Description |
|---------|-------------|
| **Photo** | Grande photo |
| **Prénom, Âge** | "Marie, 28 ans" |
| **Ville** | "Paris, 5 km" |
| **Score compatibilité** | "87% compatible" |
| **Niveau** | Badge de niveau |
| **Objectifs** | Tags des objectifs |
| **Bio** | Description courte |

### 5. Match mutuel

Quand deux personnes se likent mutuellement :
- Notification "C'est un match ! 🎉"
- Possibilité de démarrer une conversation
- Accès au profil complet

### 6. Conversation après match

| Fonctionnalité | Description |
|----------------|-------------|
| **Chat privé** | Messagerie 1-to-1 |
| **Planifier une séance** | Proposer un RDV |
| **Partager sa position** | Pour se retrouver |
| **Bloquer** | Bloquer un utilisateur |
| **Signaler** | Signaler un comportement |

---

## 📱 INTERFACE - MATCHING

```
┌─────────────────────────────────────┐
│  ← Chat Match™              ⚙️      │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │         📷                  │    │
│  │      [Photo Marie]          │    │
│  │                             │    │
│  │  Marie, 28 ans              │    │
│  │  📍 Paris, 5 km             │    │
│  │                             │    │
│  │  💚 87% compatible          │    │
│  │                             │    │
│  │  🏋️ Intermédiaire          │    │
│  │  🎯 Perte de poids          │    │
│  │  ⏰ Soir, Week-end          │    │
│  │                             │    │
│  │  "Motivée pour progresser   │    │
│  │   ensemble !"               │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│     ❌              ⭐           ❤️  │
│    Passer      Super Like      Like │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 📹 4. VISIO TRAINING
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/buddy_training/buddy_home_page.dart`

**Accès :** Onglet Avancé → Freemium → Visio Training

---

## 📝 DESCRIPTION

Plateforme de visioconférence pour s'entraîner en live avec ses amis, ses partenaires de match ou son coach.

---

## 🎯 OBJECTIF

- S'entraîner ensemble malgré la distance
- Se motiver mutuellement en temps réel
- Partager des moments sportifs

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Créer une session

| Champ | Description |
|-------|-------------|
| **Nom de la session** | "Séance du soir" |
| **Type** | Libre, Séance guidée, Challenge |
| **Durée prévue** | 30 min, 45 min, 60 min |
| **Participants max** | 2 à 6 personnes |
| **Privé/Public** | Session privée ou ouverte |

### 2. Inviter des participants

| Méthode | Description |
|---------|-------------|
| **Par pseudo** | Rechercher un utilisateur |
| **Par lien** | Partager un lien d'invitation |
| **Contacts récents** | Inviter des contacts précédents |
| **Match** | Inviter un match |

### 3. Pendant la session

| Fonctionnalité | Description |
|----------------|-------------|
| **Vidéo** | Voir tous les participants |
| **Micro** | Parler avec les autres |
| **Timer partagé** | Chrono synchronisé |
| **Chat textuel** | Messages écrits |
| **Réactions** | Envoyer des emojis |
| **Partager écran** | Montrer un exercice |
| **Musique** | Écouter de la musique ensemble |

### 4. Timer partagé

| Fonctionnalité | Description |
|----------------|-------------|
| **Démarrer** | Lancer le chrono pour tous |
| **Pause** | Mettre en pause |
| **Reset** | Réinitialiser |
| **Mode Tabata** | Intervalles configurables |
| **Mode AMRAP** | Temps total |

### 5. Fin de session

| Élément | Description |
|---------|-------------|
| **Durée totale** | Temps de la session |
| **Calories estimées** | Estimation collective |
| **Photo de groupe** | Capture d'écran |
| **Planifier la prochaine** | Proposer un nouveau RDV |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  Visio Training              🔴 REC │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────┐  ┌─────────┐          │
│  │   👤    │  │   👤    │          │
│  │  Marie  │  │ Thomas  │          │
│  └─────────┘  └─────────┘          │
│                                     │
│  ┌─────────┐  ┌─────────┐          │
│  │   👤    │  │   👤    │          │
│  │  Moi    │  │ Sophie  │          │
│  └─────────┘  └─────────┘          │
│                                     │
│  ┌─────────────────────────────┐    │
│  │         ⏱️ 12:34            │    │
│  │    Série 3/5  •  Repos     │    │
│  └─────────────────────────────┘    │
│                                     │
│  💬 Marie: "Allez on lâche rien!"  │
│                                     │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐    │
│  │🎤 │ │📷 │ │⏱️ │ │💬 │ │🚪 │    │
│  │On │ │On │ │   │ │   │ │   │    │
│  └───┘ └───┘ └───┘ └───┘ └───┘    │
│  Micro Caméra Timer Chat  Quitter  │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 🏥 5. SANTÉ & BLESSURES
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/pages/health_injuries_page.dart`

**Accès :** Onglet Avancé → Freemium → Santé & Blessures

---

## 📝 DESCRIPTION

Carnet de suivi médical et des blessures, permettant de tracker les problèmes de santé et d'adapter l'entraînement en conséquence.

---

## 🎯 OBJECTIF

- Suivre l'historique des blessures
- Adapter les entraînements aux limitations
- Garder une trace pour les professionnels de santé

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Ajouter une blessure

| Champ | Description |
|-------|-------------|
| **Zone** | Épaule, Genou, Dos, Cheville, Poignet, etc. |
| **Type** | Tendinite, Entorse, Fracture, Douleur musculaire, etc. |
| **Date** | Date de la blessure |
| **Gravité** | Légère, Modérée, Grave |
| **Cause** | Comment c'est arrivé |
| **Diagnostic** | Diagnostic médical (optionnel) |
| **Traitement** | Traitement prescrit |
| **Durée estimée** | Temps de guérison prévu |

### 2. Suivi de guérison

| Élément | Description |
|---------|-------------|
| **Statut** | En cours, En guérison, Guéri |
| **Progression** | Barre de progression |
| **Journal** | Notes quotidiennes sur l'évolution |
| **Douleur** | Échelle de douleur 1-10 |
| **Photos** | Photos de l'évolution |

### 3. Exercices à éviter

| Fonctionnalité | Description |
|----------------|-------------|
| **Liste automatique** | Exercices déconseillés selon la blessure |
| **Alertes** | Avertissement si exercice risqué planifié |
| **Alternatives** | Suggestions d'exercices de remplacement |

### 4. Rendez-vous médicaux

| Champ | Description |
|-------|-------------|
| **Date** | Date du RDV |
| **Heure** | Heure du RDV |
| **Praticien** | Médecin, Kiné, Ostéo, etc. |
| **Lieu** | Adresse |
| **Notes** | Ce qui a été dit |
| **Rappel** | Notification de rappel |

### 5. Historique

| Élément | Description |
|---------|-------------|
| **Blessures passées** | Liste des anciennes blessures |
| **Récurrence** | Blessures qui reviennent |
| **Statistiques** | Zones les plus touchées |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Santé & Blessures         ➕     │
├─────────────────────────────────────┤
│                                     │
│  🔴 Blessures en cours (1)          │
│  ┌─────────────────────────────┐    │
│  │ 🦵 Tendinite genou droit    │    │
│  │ Depuis: 15 Nov 2024         │    │
│  │ Gravité: Modérée 🟠         │    │
│  │ Progression: ████████░░ 80% │    │
│  │ Douleur aujourd'hui: 3/10   │    │
│  │                             │    │
│  │ [Mettre à jour] [Détails]   │    │
│  └─────────────────────────────┘    │
│                                     │
│  📅 Prochain RDV                    │
│  ┌─────────────────────────────┐    │
│  │ 🏥 Kiné - Dr. Martin        │    │
│  │ 5 Déc 2024 à 14h30          │    │
│  └─────────────────────────────┘    │
│                                     │
│  ⚠️ Exercices à éviter              │
│  • Squats profonds                  │
│  • Course à pied                    │
│  • Sauts                            │
│                                     │
│  ✅ Blessures guéries (3)           │
│  └ Voir l'historique                │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 👥 6. ANNUAIRE (Coachs & Utilisateurs)
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/coach_directory_page.dart`

**Accès :** Onglet Avancé → Freemium → Annuaire

---

## 📝 DESCRIPTION

Annuaire complet des coachs et utilisateurs de l'application, avec recherche, filtres et classement par spécialité.

---

## 🎯 OBJECTIF

- Trouver un coach adapté à ses besoins
- Découvrir d'autres utilisateurs
- Créer des connexions

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Recherche

| Fonctionnalité | Description |
|----------------|-------------|
| **Par nom** | Rechercher par nom ou pseudo |
| **Par spécialité** | Filtrer par domaine |
| **Par ville** | Filtrer par localisation |

### 2. Filtres avancés

| Filtre | Options |
|--------|---------|
| **Type** | Coachs, Utilisateurs, Tous |
| **Spécialité** | Perte de poids, Prise de masse, Fitness, Boxe, Yoga, etc. |
| **Distance** | 5km, 10km, 25km, 50km, 100km |
| **Note minimum** | 3★, 3.5★, 4★, 4.5★ |
| **Prix** | €, €€, €€€ |
| **Disponibilité** | En ligne, Présentiel, Les deux |

### 3. Affichage par catégorie

Quand aucune recherche n'est active, les coachs sont groupés par spécialité :

| Spécialité | Emoji | Couleur | Description |
|------------|-------|---------|-------------|
| **Perte de poids** | 🔥 | Orange | Spécialistes minceur |
| **Prise de masse** | 💪 | Or | Spécialistes musculation |
| **Fitness** | ✨ | Vert | Remise en forme générale |
| **Boxe** | 🥊 | Rouge | Boxe et sports de combat |
| **Yoga** | 🧘 | Cyan | Yoga et méditation |
| **Cardio** | ❤️ | Rose | Endurance et cardio |
| **CrossFit** | 🏋️ | Bleu | Entraînement fonctionnel |
| **Nutrition** | 🥗 | Vert clair | Conseils alimentaires |
| **Course** | 🏃 | Bleu clair | Running et trail |
| **Danse** | 💃 | Violet | Danse fitness |
| **MMA** | 🤼 | Rouge foncé | Arts martiaux mixtes |
| **Judo** | 🥋 | Gris | Arts martiaux |

### 4. Carte coach/utilisateur

| Élément | Description |
|---------|-------------|
| **Photo** | Photo de profil |
| **Nom** | Nom complet |
| **Badge vérifié** | ✓ si profil vérifié |
| **Spécialité** | Badge coloré |
| **Note** | ⭐ 4.8 (pour les coachs) |
| **Ville** | Localisation |
| **Prix** | €, €€, €€€ (pour les coachs) |

### 5. Vue carte

| Fonctionnalité | Description |
|----------------|-------------|
| **Carte géographique** | Voir les coachs sur une carte |
| **Marqueurs** | Position de chaque coach |
| **Clusters** | Regroupement si beaucoup de coachs |
| **Détail au clic** | Voir le profil du coach |

### 6. Profil détaillé (coach)

| Section | Description |
|---------|-------------|
| **Header** | Photo, nom, spécialité, note |
| **Bio** | Description du coach |
| **Certifications** | Diplômes et formations |
| **Spécialités** | Domaines d'expertise |
| **Tarifs** | Grille tarifaire |
| **Disponibilités** | Créneaux libres |
| **Avis** | Commentaires des clients |
| **Programmes** | Produits vendus |
| **Bouton Contacter** | Envoyer un message |
| **Bouton Réserver** | Réserver une séance |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Rechercher           🗺️  ⚙️      │
├─────────────────────────────────────┤
│                                     │
│  🔍 Rechercher un coach...          │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🔥 Perte de poids (12 coachs)      │
│  ⭐ 4.7 moyenne                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Coach Marie    ⭐ 4.9    │    │
│  │ Paris  •  €€               │    │
│  ├─────────────────────────────┤    │
│  │ 👤 Coach Thomas   ⭐ 4.8    │    │
│  │ Lyon  •  €                 │    │
│  └─────────────────────────────┘    │
│                                     │
│  💪 Prise de masse (8 coachs)       │
│  ⭐ 4.6 moyenne                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Coach Lucas    ⭐ 4.7    │    │
│  │ Marseille  •  €€€          │    │
│  └─────────────────────────────┘    │
│                                     │
│  🥊 Boxe (5 coachs)                 │
│  ...                               │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 🧠 7. PERSONNALITÉ COACH
# ═══════════════════════════════════════════════════════════════

**Fichiers :**
- `lib/coach_personality/coach_personality_page.dart`
- `lib/coach_personality/coach_personality_notifier.dart`
- `lib/coach_personality/coach_style_picker.dart`

**Accès :** Onglet Avancé → Freemium → Personnalité Coach

---

## 📝 DESCRIPTION

Personnalisation du comportement de l'assistant IA (Alter Ego) selon les préférences de l'utilisateur.

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Style de coaching

| Style | Description | Exemple de message |
|-------|-------------|-------------------|
| **🔥 Motivant** | Encouragements constants, énergie positive | "Tu vas tout déchirer aujourd'hui ! 💪" |
| **💪 Strict** | Exigence, discipline, pas d'excuses | "Pas d'excuses. C'est l'heure de bosser." |
| **😊 Amical** | Ton décontracté, bienveillant | "Hey ! Prêt pour une petite séance ?" |
| **📚 Technique** | Explications détaillées, scientifique | "Aujourd'hui, focus sur les quadriceps avec..." |

### 2. Ton de communication

| Ton | Description |
|-----|-------------|
| **Formel** | Vouvoiement, messages professionnels |
| **Décontracté** | Tutoiement, messages amicaux |
| **Humoristique** | Blagues, messages légers |

### 3. Fréquence des rappels

| Fréquence | Comportement |
|-----------|--------------|
| **Faible** | 1-2 messages par jour |
| **Moyenne** | 3-5 messages par jour |
| **Élevée** | Message à chaque événement |

### 4. Avatar personnalisé

| Option | Description |
|--------|-------------|
| **Apparence** | Choisir l'apparence de l'avatar |
| **Couleur** | Couleur principale de l'avatar |
| **Accessoires** | Ajouter des accessoires |

---

# ═══════════════════════════════════════════════════════════════
# 📅 8. ÉVÉNEMENTS
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/events/events_page.dart`

**Accès :** Onglet Avancé → Freemium → Événements

---

## 📝 DESCRIPTION

Calendrier des événements sportifs (compétitions, marathons, combats, etc.) avec possibilité de participer et de créer ses propres événements.

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Catégories d'événements

| Catégorie | Emoji | Exemples |
|-----------|-------|----------|
| **Boxe** | 🥊 | Galas, combats |
| **MMA** | 🤼 | Combats UFC, compétitions |
| **Marathon** | 🏃 | Courses, trails, 10km |
| **CrossFit** | 🏋️ | Compétitions CrossFit |
| **Musculation** | 💪 | Compétitions bodybuilding |
| **Yoga** | 🧘 | Retraites, stages |
| **Danse** | 💃 | Spectacles, compétitions |
| **Cyclisme** | 🚴 | Courses cyclistes |

### 2. Carte événement

| Élément | Description |
|---------|-------------|
| **Image** | Photo de couverture |
| **Catégorie** | Badge avec emoji |
| **Nom** | Titre de l'événement |
| **Date/Heure** | Quand ça a lieu |
| **Lieu** | Où ça a lieu |
| **Prix** | Tarif d'inscription |
| **Participants** | Nombre d'inscrits |
| **Organisateur** | Qui organise |
| **Bouton Participer** | S'inscrire |

### 3. Créer un événement

| Champ | Description |
|-------|-------------|
| **Nom** | Titre |
| **Catégorie** | Type de sport |
| **Date/Heure** | Quand |
| **Lieu** | Adresse |
| **Description** | Détails |
| **Prix** | Tarif (0 = gratuit) |
| **Max participants** | Limite |
| **Image** | Photo de couverture |
| **Contact** | Email/téléphone |

### 4. Mes événements

| Section | Description |
|---------|-------------|
| **Inscrits** | Événements où je suis inscrit |
| **Créés** | Événements que j'ai créés |
| **Passés** | Historique |

---

# ═══════════════════════════════════════════════════════════════
# 🎮 9. SPORT GAMING™
# ═══════════════════════════════════════════════════════════════

**Fichiers :**
- `lib/game_story/story_home.dart`
- `lib/game_story/story_chapter_page.dart`

**Accès :** Onglet Avancé → Freemium → Sport Gaming™

---

## 📝 DESCRIPTION

Gamification du sport avec des stories interactives où l'utilisateur progresse en faisant du sport dans la vraie vie.

---

## 🎯 OBJECTIF

- Rendre le sport ludique
- Motiver par le jeu
- Débloquer du contenu en s'entraînant

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Stories disponibles

| Story | Thème | Chapitres |
|-------|-------|-----------|
| **L'Ascension** | Gravir une montagne mythique | 12 chapitres |
| **Le Guerrier** | Devenir un combattant légendaire | 10 chapitres |
| **La Transformation** | Métamorphose physique | 8 chapitres |
| **Le Marathon** | Préparer un marathon | 15 chapitres |

### 2. Progression

| Élément | Description |
|---------|-------------|
| **Chapitres** | Débloquer le chapitre suivant |
| **Condition** | Faire X séances, X pas, X calories |
| **Récompenses** | Badges, XP, contenu exclusif |
| **Classement** | Position parmi les joueurs |

### 3. Contenu d'un chapitre

| Élément | Description |
|---------|-------------|
| **Histoire** | Texte narratif |
| **Illustrations** | Images de l'histoire |
| **Défi** | Objectif à atteindre |
| **Récompense** | Ce qu'on gagne |

### 4. Badges et récompenses

| Badge | Condition |
|-------|-----------|
| **🏔️ Alpiniste** | Terminer "L'Ascension" |
| **⚔️ Guerrier** | Terminer "Le Guerrier" |
| **🦋 Transformé** | Terminer "La Transformation" |
| **🏃 Marathonien** | Terminer "Le Marathon" |
| **⭐ Complétiste** | Terminer toutes les stories |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Sport Gaming™                    │
├─────────────────────────────────────┤
│                                     │
│  🏔️ L'Ascension                     │
│  ┌─────────────────────────────┐    │
│  │ [Image montagne]            │    │
│  │                             │    │
│  │ Chapitre 5/12               │    │
│  │ ████████████░░░░░░  42%     │    │
│  │                             │    │
│  │ Prochain défi:              │    │
│  │ "Faire 3 séances cette      │    │
│  │  semaine"                   │    │
│  │                             │    │
│  │ [Continuer l'aventure]      │    │
│  └─────────────────────────────┘    │
│                                     │
│  ⚔️ Le Guerrier                     │
│  ┌─────────────────────────────┐    │
│  │ [Image guerrier]            │    │
│  │ Chapitre 1/10  •  🔒        │    │
│  │ Débloque après L'Ascension  │    │
│  └─────────────────────────────┘    │
│                                     │
│  Mes badges: 🏅 3/12               │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 📝 10. MÉMO / NOTES (Carnet de Notes)
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/pages/notes_page.dart`

**Accès :** Onglet Accueil → Publications → Bouton "Mémo"

---

## 📝 DESCRIPTION

Carnet de notes personnel permettant de prendre des notes rapides, créer des pense-bêtes et organiser ses idées liées au sport et à la nutrition.

---

## 🎯 OBJECTIF

- Prendre des notes rapides
- Créer des pense-bêtes et rappels
- Organiser ses idées par catégorie
- Garder une trace de ses réflexions

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Créer une note

| Champ | Description |
|-------|-------------|
| **Titre** | Titre de la note |
| **Contenu** | Corps de la note (texte libre) |
| **Catégorie** | Sport, Nutrition, Objectifs, Idées, Autre |
| **Épingler** | Mettre en avant la note |

### 2. Catégories disponibles

| Catégorie | Emoji | Couleur | Description |
|-----------|-------|---------|-------------|
| **Sport** | 💪 | Or | Notes sur l'entraînement |
| **Nutrition** | 🥗 | Vert | Notes sur l'alimentation |
| **Objectifs** | 🎯 | Bleu | Objectifs à atteindre |
| **Idées** | 💡 | Jaune | Idées diverses |
| **Autre** | 📝 | Gris | Notes générales |

### 3. Actions sur une note

| Action | Description |
|--------|-------------|
| **Modifier** | Éditer le contenu |
| **Supprimer** | Supprimer la note |
| **Épingler/Désépingler** | Mettre en avant |
| **Changer catégorie** | Modifier la catégorie |

### 4. Filtres et recherche

| Fonctionnalité | Description |
|----------------|-------------|
| **Filtrer par catégorie** | Voir uniquement une catégorie |
| **Rechercher** | Recherche dans titres et contenus |
| **Tri** | Par date, par titre |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Mémo                       ➕     │
├─────────────────────────────────────┤
│                                     │
│  Filtres:                           │
│  [Tous] [💪Sport] [🥗Nutrition]     │
│  [🎯Objectifs] [💡Idées]            │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📌 Notes épinglées                 │
│  ┌─────────────────────────────┐    │
│  │ 💪 Programme de la semaine  │    │
│  │ Lundi: Pecs, Mardi: Dos...  │    │
│  │ il y a 2 heures             │    │
│  └─────────────────────────────┘    │
│                                     │
│  📝 Toutes les notes                │
│  ┌─────────────────────────────┐    │
│  │ 🥗 Idées de repas           │    │
│  │ Poulet grillé, riz complet..│    │
│  │ hier                        │    │
│  ├─────────────────────────────┤    │
│  │ 🎯 Objectif du mois         │    │
│  │ Perdre 2kg, 10k pas/jour    │    │
│  │ il y a 3 jours              │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 🎁 11. PARRAINER ET GAGNER
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/referral/referral_page.dart`

**Accès :** Onglet Profil → Parrainer et Gagner

---

## 📝 DESCRIPTION

Système de parrainage permettant aux utilisateurs d'inviter leurs amis et de gagner des récompenses (réductions, mois gratuits, fonctionnalités Premium).

---

## 🎯 OBJECTIF

- Développer la communauté Ukan
- Récompenser les utilisateurs fidèles
- Créer un effet viral

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Mon code de parrainage

| Élément | Description |
|---------|-------------|
| **Code unique** | Code personnel (ex: "MARIE2024") |
| **Lien de parrainage** | URL à partager |
| **QR Code** | QR code scannable |
| **Bouton Copier** | Copier le lien |
| **Bouton Partager** | Partager sur réseaux sociaux |

### 2. Récompenses

| Action | Récompense Parrain | Récompense Filleul |
|--------|-------------------|-------------------|
| **Inscription** | 50 points | 50 points |
| **1ère séance** | 100 points | 100 points |
| **Abonnement Premium** | 1 mois gratuit | -20% sur l'abonnement |
| **5 filleuls** | Badge "Ambassadeur" | - |
| **10 filleuls** | 3 mois Premium gratuits | - |

### 3. Mes filleuls

| Élément | Description |
|---------|-------------|
| **Liste des filleuls** | Personnes parrainées |
| **Statut** | Inscrit, Actif, Premium |
| **Date d'inscription** | Quand ils ont rejoint |
| **Points gagnés** | Points obtenus grâce à eux |

### 4. Mes récompenses

| Élément | Description |
|---------|-------------|
| **Points totaux** | Nombre de points accumulés |
| **Récompenses disponibles** | Ce qu'on peut échanger |
| **Historique** | Récompenses déjà utilisées |

### 5. Boutique de récompenses

| Récompense | Points nécessaires |
|------------|-------------------|
| **1 semaine Premium** | 200 points |
| **1 mois Premium** | 500 points |
| **-20% sur un produit coach** | 300 points |
| **Badge exclusif** | 100 points |
| **Accès anticipé nouveautés** | 150 points |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Parrainer et Gagner       🎁     │
├─────────────────────────────────────┤
│                                     │
│  🎉 Mon code de parrainage          │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │      MARIE2024              │    │
│  │                             │    │
│  │   [Copier]    [Partager]    │    │
│  │                             │    │
│  │      [QR CODE]              │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  💰 Mes points: 450                 │
│                                     │
│  👥 Mes filleuls (3)                │
│  ┌─────────────────────────────┐    │
│  │ 👤 Thomas    •  Actif       │    │
│  │ 👤 Sophie    •  Premium ⭐  │    │
│  │ 👤 Lucas     •  Inscrit     │    │
│  └─────────────────────────────┘    │
│                                     │
│  🛒 Échanger mes points             │
│  ┌─────────────────────────────┐    │
│  │ 1 semaine Premium  200pts   │    │
│  │ 1 mois Premium     500pts   │    │
│  │ Badge exclusif     100pts   │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 📱 12. PUBLICATIONS / FEED SOCIAL
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/feed/feed_page.dart`

**Accès :** Onglet Accueil → Publications

---

## 📝 DESCRIPTION

Fil d'actualité social permettant de partager ses progrès, photos de transformation, séances et recettes avec la communauté.

---

## 🎯 OBJECTIF

- Partager ses progrès avec la communauté
- Trouver de l'inspiration
- Se motiver mutuellement
- Créer du lien social

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Types de publications

| Type | Description | Icône |
|------|-------------|-------|
| **Photo de progression** | Avant/Après, transformation | 📸 |
| **Séance terminée** | Partager une séance | 💪 |
| **Recette** | Partager une recette | 🍽️ |
| **Objectif atteint** | Célébrer une victoire | 🎯 |
| **Citation/Motivation** | Texte inspirant | 💬 |
| **Question** | Demander des conseils | ❓ |

### 2. Créer une publication

| Champ | Description |
|-------|-------------|
| **Texte** | Description (jusqu'à 500 caractères) |
| **Photos** | 1 à 4 photos |
| **Type** | Catégorie de la publication |
| **Tags** | Hashtags (#transformation, #musculation) |
| **Lieu** | Localisation (optionnel) |
| **Visibilité** | Public, Amis uniquement, Privé |

### 3. Interactions

| Action | Description |
|--------|-------------|
| **❤️ Liker** | Aimer la publication |
| **💬 Commenter** | Ajouter un commentaire |
| **📤 Partager** | Partager la publication |
| **🔖 Sauvegarder** | Sauvegarder pour plus tard |
| **🚨 Signaler** | Signaler un contenu inapproprié |

### 4. Onglets du feed

| Onglet | Description |
|--------|-------------|
| **Pour toi** | Publications recommandées par l'algorithme |
| **Suivis** | Publications des personnes suivies |
| **Populaire** | Publications les plus likées |
| **Récent** | Publications les plus récentes |

### 5. Explorer

| Fonctionnalité | Description |
|----------------|-------------|
| **Recherche** | Rechercher par hashtag, utilisateur |
| **Catégories** | Filtrer par type de contenu |
| **Tendances** | Hashtags populaires |
| **Suggestions** | Comptes à suivre |

---

## 📱 INTERFACE - FEED

```
┌─────────────────────────────────────┐
│  Publications            [Mémo] ➕  │
├─────────────────────────────────────┤
│  [Pour toi] [Suivis] [Populaire]   │
├─────────────────────────────────────┤
│                                     │
│  👤 Marie  •  il y a 2h            │
│  ┌─────────────────────────────┐    │
│  │ 📸 [Photo transformation]   │    │
│  │                             │    │
│  │ 3 mois de travail ! 💪      │    │
│  │ #transformation #fitness    │    │
│  │                             │    │
│  │ ❤️ 234  💬 45  📤 12        │    │
│  └─────────────────────────────┘    │
│                                     │
│  👤 Thomas  •  il y a 4h           │
│  ┌─────────────────────────────┐    │
│  │ 💪 Séance terminée !        │    │
│  │ Pecs/Triceps - 1h15         │    │
│  │ 450 kcal brûlées            │    │
│  │                             │    │
│  │ ❤️ 89  💬 12  📤 3          │    │
│  └─────────────────────────────┘    │
│                                     │
│  👤 Sophie  •  il y a 6h           │
│  ┌─────────────────────────────┐    │
│  │ 🍽️ Ma recette healthy !     │    │
│  │ [Photo du plat]             │    │
│  │ Bowl protéiné au poulet     │    │
│  │ 450 kcal - P:35g G:40g L:15g│    │
│  │                             │    │
│  │ ❤️ 156  💬 28  📤 45        │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

## 📱 INTERFACE - EXPLORER

```
┌─────────────────────────────────────┐
│  ← Explorer                         │
├─────────────────────────────────────┤
│                                     │
│  🔍 Rechercher...                   │
│                                     │
│  🔥 Tendances                       │
│  #transformation  #musculation      │
│  #pertedepoids  #fitness  #healthy  │
│                                     │
├─────────────────────────────────────┤
│  Catégories                         │
│  [📸 Transformations] [💪 Séances] │
│  [🍽️ Recettes] [🎯 Objectifs]      │
│                                     │
├─────────────────────────────────────┤
│  📸 Transformations populaires      │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 📷  │ │ 📷  │ │ 📷  │ │ 📷  │   │
│  │❤️234│ │❤️189│ │❤️156│ │❤️134│   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│                                     │
│  💪 Séances du jour                 │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 📷  │ │ 📷  │ │ 📷  │ │ 📷  │   │
│  │❤️ 89│ │❤️ 76│ │❤️ 65│ │❤️ 54│   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 👥 13. MES SUIVIS
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/feed/following_page.dart`

**Accès :** Onglet Accueil → Publications → Onglet "Suivis"

---

## 📝 DESCRIPTION

Gestion des comptes suivis et de ses abonnés, permettant de construire son réseau social sportif.

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Mes abonnements

| Élément | Description |
|---------|-------------|
| **Liste des suivis** | Personnes que je suis |
| **Nombre** | Total d'abonnements |
| **Recherche** | Rechercher dans mes suivis |
| **Se désabonner** | Arrêter de suivre |

### 2. Mes abonnés

| Élément | Description |
|---------|-------------|
| **Liste des abonnés** | Personnes qui me suivent |
| **Nombre** | Total d'abonnés |
| **Suivre en retour** | Suivre un abonné |
| **Bloquer** | Bloquer un abonné |

### 3. Suggestions

| Élément | Description |
|---------|-------------|
| **Comptes suggérés** | Personnes à suivre |
| **Basé sur** | Intérêts similaires, amis communs |
| **Coachs populaires** | Coachs recommandés |

### 4. Profil d'un utilisateur

| Élément | Description |
|---------|-------------|
| **Photo** | Photo de profil |
| **Nom** | Nom/Pseudo |
| **Bio** | Description courte |
| **Stats** | Abonnés, Abonnements, Publications |
| **Publications** | Grille de ses publications |
| **Bouton Suivre** | S'abonner |
| **Bouton Message** | Envoyer un message |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Mes Suivis                       │
├─────────────────────────────────────┤
│  [Abonnements (45)] [Abonnés (128)]│
├─────────────────────────────────────┤
│                                     │
│  🔍 Rechercher...                   │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Coach Marie     [Suivre] │    │
│  │    @coachMarie  •  2.3k 👥  │    │
│  ├─────────────────────────────┤    │
│  │ 👤 Thomas Fit      [Suivi ✓]│    │
│  │    @thomasfit  •  890 👥    │    │
│  ├─────────────────────────────┤    │
│  │ 👤 Sophie Healthy  [Suivi ✓]│    │
│  │    @sophiehealthy  •  1.2k 👥│   │
│  └─────────────────────────────┘    │
│                                     │
│  💡 Suggestions pour toi            │
│  ┌─────────────────────────────┐    │
│  │ 👤 FitLucas        [Suivre] │    │
│  │    12 amis en commun        │    │
│  ├─────────────────────────────┤    │
│  │ 👤 CoachEmma       [Suivre] │    │
│  │    Spécialiste HIIT         │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 🗺️ 14. CARTE INTERACTIVE
# ═══════════════════════════════════════════════════════════════

**Fichier :** `lib/coach_directory_page.dart` (intégré dans l'annuaire)

**Accès :** Onglet Avancé → Freemium → Annuaire → Icône carte 🗺️

---

## 📝 DESCRIPTION

Carte interactive permettant de visualiser géographiquement les coachs, salles de sport et événements autour de soi.

---

## 🎯 OBJECTIF

- Trouver un coach proche de chez soi
- Visualiser les salles de sport à proximité
- Découvrir les événements sportifs locaux

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES

### 1. Vue carte

| Élément | Description |
|---------|-------------|
| **Carte Google Maps** | Vue cartographique interactive |
| **Position actuelle** | Marqueur bleu "Vous êtes ici" |
| **Zoom** | Zoom +/- et pinch to zoom |
| **Déplacement** | Faire glisser pour explorer |
| **Recentrer** | Bouton pour revenir à sa position |

### 2. Marqueurs sur la carte

| Type | Icône | Couleur | Description |
|------|-------|---------|-------------|
| **Coach** | 👤 | Or | Position du coach |
| **Salle de sport** | 🏋️ | Bleu | Salle de fitness |
| **Événement** | 📅 | Rouge | Événement sportif |
| **Ma position** | 📍 | Bleu | Position actuelle |

### 3. Filtres de la carte

| Filtre | Description |
|--------|-------------|
| **Coachs uniquement** | Afficher seulement les coachs |
| **Salles uniquement** | Afficher seulement les salles |
| **Événements** | Afficher les événements à venir |
| **Tous** | Afficher tous les marqueurs |
| **Rayon** | 5km, 10km, 25km, 50km |

### 4. Interaction avec un marqueur

| Action | Description |
|--------|-------------|
| **Tap sur marqueur** | Affiche une info-bulle |
| **Info-bulle** | Nom, photo, note, distance |
| **Voir le profil** | Accéder au profil complet |
| **Itinéraire** | Ouvrir dans Google Maps |

### 5. Clusters

| Élément | Description |
|---------|-------------|
| **Regroupement** | Si beaucoup de marqueurs proches |
| **Nombre** | Affiche le nombre dans le cluster |
| **Zoom auto** | Clic sur cluster = zoom |

### 6. Liste à proximité

| Élément | Description |
|---------|-------------|
| **Panel glissant** | Liste en bas de l'écran |
| **Tri par distance** | Du plus proche au plus loin |
| **Aperçu rapide** | Photo, nom, distance, note |

---

## 📱 INTERFACE

```
┌─────────────────────────────────────┐
│  ← Carte                     🔍 ⚙️  │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │    🗺️ CARTE GOOGLE MAPS    │    │
│  │                             │    │
│  │        👤        👤        │    │
│  │           🏋️              │    │
│  │     👤         📅          │    │
│  │                             │    │
│  │        📍 (Moi)            │    │
│  │                             │    │
│  │     👤    🏋️    👤        │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  Filtres:                           │
│  [Tous] [👤Coachs] [🏋️Salles]      │
│                                     │
│  ─────────────────────────────────  │
│  À proximité (12)                   │
│  ┌─────────────────────────────┐    │
│  │ 👤 Coach Marie    0.8 km    │    │
│  │    ⭐ 4.9  •  HIIT          │    │
│  ├─────────────────────────────┤    │
│  │ 🏋️ FitGym Paris  1.2 km    │    │
│  │    ⭐ 4.5  •  24h/24        │    │
│  ├─────────────────────────────┤    │
│  │ 👤 Coach Thomas   1.5 km    │    │
│  │    ⭐ 4.8  •  Musculation   │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════
# 📊 RÉCAPITULATIF FREEMIUM
# ═══════════════════════════════════════════════════════════════

| # | Fonctionnalité | Description courte |
|---|----------------|-------------------|
| 1 | **Analyse corporelle** | Suivi poids, IMC, mensurations |
| 2 | **Chat communautaire** | Discussions entre membres |
| 3 | **Chat Match™** | Trouver des partenaires sportifs |
| 4 | **Visio Training** | S'entraîner en visio avec des amis |
| 5 | **Santé & Blessures** | Carnet de suivi médical |
| 6 | **Annuaire** | Recherche de coachs et utilisateurs |
| 7 | **Personnalité Coach** | Personnaliser l'assistant IA |
| 8 | **Événements** | Calendrier des événements sportifs |
| 9 | **Sport Gaming™** | Gamification avec stories |
| 10 | **Mémo / Notes** | Carnet de notes personnel |
| 11 | **Parrainer et Gagner** | Système de parrainage |
| 12 | **Publications / Feed** | Réseau social sportif |
| 13 | **Mes Suivis** | Gestion des abonnements sociaux |
| 14 | **Carte Interactive** | Géolocalisation des coachs |

---

## 💡 POURQUOI CES FONCTIONNALITÉS SONT GRATUITES ?

1. **Acquisition d'utilisateurs** - Attirer de nouveaux utilisateurs
2. **Engagement** - Garder les utilisateurs actifs
3. **Communauté** - Créer une communauté forte
4. **Conversion** - Montrer la valeur pour convertir en Premium

---

> **Document Freemium - Ukan**  
> Fonctionnalités gratuites (hors IA pure)  
> © 2024 Ukan - Tous droits réservés

