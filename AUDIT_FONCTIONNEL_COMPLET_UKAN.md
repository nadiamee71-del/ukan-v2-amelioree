# 🔍 Audit fonctionnel complet — Application Ukan (Flutter/Dart)

Analyse réalisée en **lecture seule**. Aucun fichier n'a été modifié, aucune fonctionnalité créée. Analyse des 283 fichiers Dart de `lib/`, du `pubspec.yaml`, de l'authentification, de la navigation, des modèles/état global et de tous les modules.

> ⚠️ **Constat technique fondateur (valable pour tout le rapport) :** Ukan n'est **pas** une application web ni une app connectée. C'est une **application Flutter 100 % hors-ligne, mono-appareil, de type maquette/démo**. Le `pubspec.yaml` ne contient **aucune** dépendance réseau (pas de `http`, `dio`, `firebase`, `supabase`). Il n'existe **aucun backend, aucune API, aucune base de données**. Toutes les « données » sont soit **codées en dur**, soit **en mémoire vive** (singletons `ChangeNotifier`), soit — pour une minorité — **persistées localement** via `SharedPreferences`.

---

## PARTIE A — Résumé général

### Objectif actuel de l'application
Ukan se présente comme une plateforme de **coaching sportif personnalisé** (entraînement, nutrition, coaching, communauté, gamification, IA). Dans les faits, l'état actuel est une **vitrine interactive / prototype de démonstration** très riche visuellement, mais dont la logique métier repose massivement sur des données fictives et de l'état volatil.

### Point d'entrée réel
`lib/main.dart` → `main()` → `runApp(UkanApp)` → `home: SplashScreen` → au bout de ~3 s → `LoginPage` (`lib/auth/login_page.dart`) → login **factice** (délai 800 ms, aucune vérification) → `UkanHomeShell` (le même pour tout le monde).

### Rôles disponibles
- Deux rôles sont **saisis à l'inscription** (`client` / `coach`) et écrits dans `SharedPreferences` (`fitpro_role`)…
- …mais cette clé **n'est jamais relue nulle part** dans le code. **Le rôle n'a donc AUCUN effet fonctionnel.** Tous les utilisateurs (client, coach, ou simple connexion) arrivent sur le même shell et peuvent accéder à tout, y compris à l'espace coach.

### Principales fonctionnalités présentes
Suivi quotidien (eau, sommeil, pas, poids, calories, protéines), séances & programmes d'entraînement, bibliothèque d'exercices (~111), nutrition + recettes + FoodScan « IA », annuaire de coachs, dashboard/business coach, messagerie, communauté (feed, stories, chat match, community chat), cours collectifs, jeux (Sport Gaming Story, boss games), Coach vs Coach, buddy/rooms visio, Hard Challenge, Alter Ego IA, coach vocal (TTS réel), premium/paiements démo, santé/blessures.

### Niveau global d'avancement
- **Persistance réelle (survit au redémarrage)** : uniquement le **thème** (`theme_mode`), les **séances/programmes d'entraînement** (`WorkoutSessionStorage`), le **compteur de parrainage**, et le **profil d'inscription** (mais ignoré ensuite). Tout le reste est **perdu au redémarrage**.
- Estimation : ~ **beaucoup d'interfaces (90 %+) présentes et navigables**, mais **fonctionnalités réellement complètes et durables : très minoritaires**. La majorité est en « démo interactive en RAM » ou « données simulées ».

### Architecture fonctionnelle générale
```
main() → UkanApp (MaterialApp, thème clair/sombre)
   → SplashScreen (animation logo, 3s)
      → LoginPage (auth factice)   [inscription: SignupRolePage → SignupClient/Coach]
         → UkanHomeShell (BottomNav 5 onglets, IDENTIQUE pour tous)
            1. Accueil   → HomePage (Dashboard + Publications)
            2. Séances   → SessionsTab
            3. Nutrition → NutritionTab
            4. Avancé    → EspaceProScreen (hub ~20 modules + "Passer en mode Coach")
            5. Rechercher→ CoachDirectoryPage
         + AppBar : Réglages (gauche), Avatar→ProfilePage & bulle Alter Ego (droite)

État global = singletons ChangeNotifier (lib/models/*) en RAM
Persistance = SharedPreferences (partielle) : thème, séances, parrainage, profil signup
```

---

## PARTIE B — Tableau des rôles

| Rôle | Nom exact dans le code | Attribution / reconnaissance | Pages accessibles | Fonctionnalités | Restrictions | Niveau de fonctionnement |
|------|------------------------|------------------------------|-------------------|-----------------|--------------|--------------------------|
| **Client / Élève** | `'client'` (`fitpro_role`, `lib/auth/signup_client_page.dart:254`) | Écrit à l'inscription, **jamais relu** | **Tout** (même shell) | Tout | **Aucune** technique | **Simulé** (le rôle n'a aucun effet) |
| **Coach** | `'coach'` (`lib/auth/signup_coach_page.dart:293`) | Écrit à l'inscription, **jamais relu**. Espace coach atteint par le bouton « Passer en mode Coach » (`EspaceProScreen`), accessible à **tous** | **Tout** + `CoachDashboardPage` | Dashboard, clients, programmes, business, planning | **Aucune** (aucune vérif diplôme/SIRET) | **Simulé** (pas de séparation réelle) |
| **Utilisateur autonome (sans coach)** | ❌ n'existe pas comme rôle | — | — | — | — | **Absent** : tout le monde a un « coach » démo `coach_1` (Sophie Martin) codé en dur |
| **Premium / Gratuit** | `SubscriptionPlan` (`lib/models/subscription.dart`) | `activatePremiumDemo()` en RAM | idem | Débloque partiellement les vidéos `isPremium` et le Coach IA posture | Gating **très partiel** | **Simulé** (perdu au redémarrage) |
| **Administrateur** | ❌ | — | — | — | — | **Absent** |
| **Modérateur** | ❌ | — | — | — | — | **Absent** |

**Changement de rôle :** aucun mécanisme réel — on « devient coach » simplement en tapant un bouton. **Multi-rôles :** non géré (mais sans conséquence puisque le rôle est ignoré).

---

## PARTIE C — Tableau complet des fonctionnalités

Légende statut : **✅Fonctionnelle** · **🟢Fonctionnelle avec limitations** · **🟡Partiellement développée** · **🟠Interface sans logique** · **🔵Données simulées** · **⛔Bouton inactif** · **⬜Page vide** · **👻Masquée/désactivée** · **💀Code non utilisé** · **❌Absente**

### Authentification & compte
| Fonctionnalité | Statut | Rôle | Données | Fichier principal | Problèmes |
|---|---|---|---|---|---|
| Inscription client | 🟢 | client | SharedPrefs (écriture) | `auth/signup_client_page.dart` | Champs pré-remplis « A/B/test@test.com » ; profil jamais relu |
| Inscription coach | 🟢 | coach | SharedPrefs (écriture) | `auth/signup_coach_page.dart` | Aucune vérif diplôme/SIRET ; upload « simulé (mode démo) » |
| Connexion | 🔵 | tous | aucune | `auth/login_page.dart` | Accepte tout ; délai 800 ms ; pré-rempli `toi@mail.com`/`••••••••` |
| Mot de passe oublié | ⛔ | tous | — | `auth/login_page.dart:481` | `onPressed` → `// TODO` (rien) ; page `forgot_password_page.dart` **jamais reliée** |
| Validation e-mail / OTP | ❌ | — | — | — | Inexistant |
| Connexion sociale (Apple/Play) | ⛔ | tous | — | `auth/login_page.dart:576-585` | `onTap: () {}` vides |
| Persistance de session | ❌ | — | — | `splash_screen.dart` | Le splash va toujours au login ; `fitpro_is_logged_in` jamais relu |
| Déconnexion | ✅ | tous | — | `pages/settings_page.dart` | Retour `LoginPage` |
| Suppression de compte | ❌/🟠 | — | — | `settings_page.dart` | Options confidentialité → SnackBar « à venir » |
| Photo de profil | ❌ | tous | — | `main.dart` ProfilePage | Initiales uniquement ; section évolution « bientôt » |

### Accueil & Dashboard
| Fonctionnalité | Statut | Données | Persist. | Fichier | Problèmes |
|---|---|---|---|---|---|
| Dashboard (cartes suivi) | 🟢 | RAM | ❌ | `home/widgets/dashboard_tab.dart` | Objectifs **incohérents** (constantes 3 séances/2000 kcal/8000 pas vs profil 4/2200/10000) |
| Hydratation | ✅(session) | RAM | ❌ | `models/goals.dart` | Perdu au redémarrage |
| Sommeil | ✅(session) | RAM | ❌ | `add_sleep_page.dart` | idem |
| Pas | 🟢 | capteur + RAM | ❌ | `models/steps.dart` | podomètre réel + saisie manuelle ; non persisté |
| Calories / Protéines | 🟢 | RAM | ❌ | `models/nutrition.dart` | Alimenté par la nutrition ; volatile |
| Poids / composition corporelle | 🟡 | RAM + démo | ❌ | `body_composition_page.dart` | Historique **simulé** |
| Objectifs (pages détail) | 🟢 | RAM | ❌ | `pages/*_goal_page.dart` | 3 sources d'objectifs non synchronisées |
| Statistiques | 🟢 | RAM | ❌ | `stats_page.dart` | Graphiques custom, pas d'interactivité, inclut 2 séances démo |
| Résumé quotidien | 🟢 | RAM | ❌ | `dashboard_tab.dart` | — |
| Notes / mémo | 🟢 | RAM + 4 mocks | ❌ | `pages/notes_page.dart` | CRUD OK mais perdu au redémarrage |
| Parrainage | 🔵 | SharedPrefs (compteur) | ✅(compteur) | `pages/parrainage_page.dart` | Aucun envoi/lien réel ; récompenses fictives |
| Publications (feed accueil) | 🔵 | codé en dur | ❌ | `feed/feed_page.dart` | Grille statique ; like/commentaire boutons vides |
| Stories | 🟠 | codé en dur | ❌ | `home/widgets/stories_header_row.dart` | Seul « Ajouter » agit ; bulles sans `onTap` |

### Séances & entraînement
| Fonctionnalité | Statut | Données | Persist. | Fichier | Problèmes |
|---|---|---|---|---|---|
| Bibliothèque d'exercices + recherche/filtres | ✅ | codé en dur (~111) | N/A | `data/default_exercises_library.dart`, `exercises/exercise_library_page.dart` | Bandeau « Données fictives pour maquette » |
| Créer/éditer un **programme** | ✅ | SharedPrefs | ✅ | `workout/workout_program_edit_page.dart`, `models/workout_session_storage.dart` | **Réellement persistant** |
| Programmes par défaut (seed) | ✅ | codé en dur→SharedPrefs | ✅ | `services/default_program_seeder.dart` | 5 programmes semés si vide |
| Enregistrer une **séance** (séries/reps) | ✅ | SharedPrefs | ✅ | `workout/workout_session_recording_page.dart` | **Réellement persistant** |
| Exécution guidée (timer/repos) | 🟢 | programme | ❌(résultat) | `workout/workout_execution_page.dart` | **N'enregistre PAS** la séance dans l'historique |
| Séance « coach vocal » (capteurs) | 🟢 | param | ❌ | `workout_session_page.dart` | Fin → `WorkoutHistoryNotifier` (RAM, ≠ storage) |
| Historique / stats séances | 🟢/🔵 | RAM + 2 démos | ❌ | `models/workout_history.dart` | **3 systèmes d'historique déconnectés** |
| Vidéos d'exercices | 🟢 | assets locaux | N/A | `exercises/exercise_video_page.dart` | ~15 avec vidéo réelle ; les ~100 autres → placeholder |
| Créer un exercice perso | 🟠 | — | ❌ | `exercises/create_exercise_page.dart` | `Navigator.pop()` sans sauvegarde ; filtre « Mes exercices » inopérant |
| Chronomètre / repos | ✅/💀 | — | — | `widgets/workout_timer.dart` | `ActiveRestTimer`, `RestTimerWidget`… définis mais **jamais importés** |
| Difficulté (évaluation) | 🟡 | RAM | ❌ | `services/difficulty_service.dart` | Commentaire « sera remplacé par une BDD » |

### Nutrition
| Fonctionnalité | Statut | Données | Persist. | Fichier | Problèmes |
|---|---|---|---|---|---|
| Ajouter un repas / journal | 🟢 | RAM | ❌ | `add_meal_page.dart`, `models/nutrition.dart` | Macros saisies à la main ; perdu au redémarrage |
| Calories/macros du jour | 🟢 | RAM | ❌ | `nutrition/nutrition_hub_page.dart` | Hub n'affiche pas la liste des repas |
| Recettes | 🔵/🟢 | 8 démos + création RAM | ❌ | `models/recipe.dart`, `pages/add_recipe_page.dart` | Création OK mais volatile ; « ajouter au planning » = TODO |
| Favoris / livre de recettes | 🟢 | RAM | ❌ | `pages/recipe_book_page.dart` | — |
| FoodScan IA (photo) | 🔵 | liste prédéfinie | ❌ | `foodscan_ia/foodscan_photo_demo_page.dart` | **Pas de caméra** ; choix parmi 5 plats ; titre « (démo) » |
| FoodScan voix | 🟢 | STT réel + règles | ❌ | `foodscan_ia/foodscan_voice_demo_page.dart` | Dictée réelle (`speech_to_text`), analyse simulée |
| Scan **code-barres** | ❌ | — | — | — | **0 occurrence** dans tout le code |
| Liste de courses | 🟢 | codé en dur + RAM | ❌ | `features/nutrition/widgets/shopping_list_tab.dart` | Non liée aux recettes/planning |
| Planning repas | 🟢 | démo RAM | ❌ | `features/nutrition/meal_planner_page.dart` | Bouton calendrier `onPressed: () {}` |
| Calculatrice macros | 🟢 | démo | ❌ | `features/nutrition/calculator/` | Non exporté vers le journal |

### Coach & élèves
| Fonctionnalité | Statut | Données | Persist. | Fichier | Problèmes |
|---|---|---|---|---|---|
| Dashboard coach | 🟢 | codé en dur + RAM | ❌ | `coach_dashboard_page.dart` | Stats `4`/`12` en dur ; `coach_1` en dur |
| Liste des clients | 🔵 | 5 clients codés en dur | ❌ | `coach_clients_page.dart` | Pas de `coachId` ; tout le monde voit les mêmes |
| Fiche client + notes | 🟢(session) | RAM | ❌ | `coach_client_detail_page.dart`, `models/client_tracking.dart` | Notes/progression volatiles |
| Créer programme coach | 🟡 | RAM | ❌ | `coach/programs/coach_program_create_page.dart` | Créé avec `exercises: []` |
| Assigner programme → élève | 🟢(coach only) | RAM | ❌ | `models/coach_programs.dart` | Élève réel (`current_user`) **ne le voit jamais** (IDs disjoints) |
| Annuaire coachs | 🔵 | 2 sources incohérentes | ❌ | `coach_directory_page.dart`, `coach_directory/mock_coaches_data.dart` | `coach_1` = « perte de poids » vs « Yoga » selon la source |
| Contacter coach (chat) | 🔵 | RAM scripté | ❌ | `chat_page.dart` | Réponse auto après 1 s |
| Visio coach | ⛔ | — | — | `coach_detail_page.dart` | SnackBar « à implémenter » |
| Réserver un RDV | 🟢(session) | RAM | ❌ | `features/appointments/client_booking_view.dart` | `clientName` codé « Thomas Martin » |
| Disponibilités coach | 🟢(session) | RAM | ❌ | `features/appointments/coach_availability_editor.dart` | **Découplées** des dispos saisies à l'inscription |
| RDV visible coach ET élève | 🟡 | RAM partagée | ❌ | `features/appointments/appointments_repository.dart` | IDs incohérents ; vue planning coach cassée |
| Business (ventes/branding/produits) | 🔵 | codé en dur + RAM | ❌ | `coach_business/*` | « Mode démo » ; revenus = `produits × 49 €` |

### Messagerie
| Fonctionnalité | Statut | Données | Fichier | Problèmes |
|---|---|---|---|---|
| Conversations / boîte de réception | 🔵 | 3 threads démo RAM | `pages/message_inbox_page.dart` | Pas de création de conversation |
| Envoi de message | 🟢(session) | RAM | `pages/message_thread_page.dart` | Local uniquement (mono-appareil) |
| Filtres / recherche | ✅ | RAM | `message_inbox_page.dart` | OK |
| Pièces jointes / photos | ❌ | — | — | Absent |
| Blocage / signalement | ❌ | — | — | Absent |
| Notifications | ❌ | — | — | Pas de push (aucune dépendance FCM) |

### Santé & blessures
| Fonctionnalité | Statut | Données | Fichier | Problèmes |
|---|---|---|---|---|
| Ajout blessure (zone/intensité/douleur) | 🟢(session) | RAM | `pages/health_injuries_page.dart`, `models/injury.dart` | `toJson` existe mais **jamais persisté** |
| Historique douleur | 🟢(session) | RAM | idem | Volatile |
| Partage avec le coach | ❌ | — | — | Aucun lien |
| Restrictions → entraînement | 🟠 | — | ProfilePage | Affiché « exercices à éviter » mais ignoré par les modules workout |
| `injury_log_screen.dart` | 💀 | — | `lib/injury_log_screen.dart` | Écran séparé, **jamais navigué** |

### Communauté
| Fonctionnalité | Statut | Données | Fichier | Problèmes |
|---|---|---|---|---|
| Feed / publications | 🔵/🟠 | codé en dur | `feed/feed_page.dart` | Grille statique ; **non branché** sur `ProfileFeedNotifier` |
| Création de post | 🟢(session) | RAM | `pages/create_feed_post_page.dart` | Post invisible dans l'onglet Publications (2 systèmes séparés) |
| Abonnés / abonnements | 🔵 | démo | `models/profile_feed.dart` | Compteurs fictifs |
| Likes / commentaires / partage | 🟠 | — | `pages/profile_feed_page.dart` | Boutons `onPressed: () {}` |
| Chat Match (swipe) | ✅(session) | 8 profils démo | `chat_match/match_swipe_page.dart` | Match si compat. ≥ 60 % (pas de réciprocité) |
| Chat Match (chat) | 🔵 | scripté | `chat_match/match_chat_page.dart` | Réponses auto après 2 s |
| Community chat | 🟢(session) | 6 msgs démo + RAM | `community_chat_page.dart` | Post/réactions locaux |
| Buddy / Rooms visio | 🔵 | RAM + assets | `buddy_training/`, `rooms_page.dart` | **Pas de WebRTC** ; participants simulés |
| Défis (Hard Challenge) | 🟡 | RAM partielle | `hard_challenge/` | Création `// TODO: sauvegarder` |
| Sport Gaming Story (XP/bosses/quêtes) | ✅(session) | RAM | `game_story/` | Fonctionnel mais **non persisté** |
| Coach vs Coach | 🔵 | ~18 coachs + Random | `coach_vs_coach/` | Résultats aléatoires |
| Cours collectifs / live / replay | 🔵 | mock RAM | `group_classes/` | Pas de vrai stream |
| Événements | 🔵 | 14 mocks | `events/events_page.dart` | Inscription/création = SnackBar, non enregistrées |

### Paiements & abonnements
| Fonctionnalité | Statut | Données | Fichier | Problèmes |
|---|---|---|---|---|
| Gratuit / Premium | 🔵 | RAM | `models/subscription.dart` | Perdu au redémarrage |
| Page Premium | 🔵 | UI | `premium_page.dart` | « Mode démo – paiements simulés » ; promet Rooms/silhouette/chat prioritaire (non tenus) |
| Paiement | 🔵 | RAM | `pages/demo_payment_page.dart` | CB pré-remplie factice |
| Mes achats / factures | 🔵 | RAM | `pages/my_purchases_page.dart` | « Mes achats Ukan (démo) » |
| Programmes/recettes/prestations payantes | 🔵 | démo | `coach_business/`, catalogue | Aucune transaction réelle |

### Paramètres & support
| Fonctionnalité | Statut | Persist. | Fichier | Problèmes |
|---|---|---|---|---|
| Thème clair/sombre | ✅ | ✅ SharedPrefs | `models/theme_notifier.dart` | **Persistant** |
| Unités de mesure | 🟢 | ❌ | `models/units_notifier.dart` | Non persisté |
| Langue | 🟠 | — | `settings_page.dart` | SnackBar « à venir » (locale figée FR) |
| Notifications | 🟠 | — | `settings_page.dart` | Toggles sans effet |
| Confidentialité / export / suppression données | 🟠 | — | `settings_page.dart` | « à venir » |
| FAQ / Support | 🟠 | — | `pages/faq_support_page.dart` | Formulaire → dialog local, aucun envoi |
| CGU/CGV/Mentions légales | ❌ | — | — | Dialog « disponibles dans la version finale » |

### IA
| Fonctionnalité | Statut | Fichier | Problèmes |
|---|---|---|---|
| Alter Ego (chat) | 🔵 | `alter_ego_floating/alter_ego_service.dart` | ~100 réponses scriptées + TTS réel ; **pas de LLM** |
| Coach vocal (4 styles) | ✅(session) | `coach_personality/` | `flutter_tts` + `audioplayers` réels ; style non persisté |
| Coach IA posture | 🟢 | `coach_ia_premium/` | Analyse simulée si pas de capteur |
| Projection IA (Transformation RA) | 🔵 | `transformation_ra/ra_future_preview.dart` | Galerie de phases démo (pas une page vide) |

---

## PARTIE D — Parcours par rôle

### 1. Utilisateur autonome (sans coach) → **N'existe pas**
Il n'y a pas de parcours « sans coach » : dès l'accueil et le profil, un coach démo `coach_1` (Sophie Martin) est affiché en dur pour tout le monde (`main.dart`, section « Mon Coach »).

### 2. Élève / Client (avec coach)
```
Splash → Login (factice) → [Créer un compte → SignupRolePage → SignupClientPage
   (5 sections : identité, corps+IMC, objectifs, préférences coaching, santé)
   → SharedPrefs(role=client) → UkanHomeShell]
→ Accueil (Dashboard): objectifs, eau, sommeil, pas, calories, protéines, stats
→ Séances: bibliothèque, programmes (persistés), lancer/enregistrer une séance (persistée)
   ⚠️ mais l'exécution guidée n'alimente pas l'historique persistant
→ Nutrition: ajouter repas (RAM), recettes, FoodScan démo, courses
→ Avancé (EspaceProScreen): ~20 modules (communauté, IA, jeux, santé…)
→ Rechercher: annuaire coachs (mock) → fiche coach → chat (scripté) / réserver RDV (RAM)
→ Profil (avatar): mensurations, objectifs, "Évolution" (vide "bientôt"),
   Mon Coach (coach_1 codé en dur), blessures, feed perso
→ Réglages: thème (persistant), déconnexion
```
**Rupture clé :** l'élève réel a l'ID `current_user` ; les programmes/RDV/clients démo utilisent `sarah`, `marc`, `client_demo_1`… → l'élève **ne voit jamais** un programme réellement assigné par un coach.

### 3. Coach
```
Login → [SignupCoachPage: identité, profil pro, diplômes (upload simulé),
   types de séances, modalités/prix, consentements RGPD → SharedPrefs(role=coach)]
   ⚠️ Aucune validation/vérification. Profil jamais relu ensuite.
→ Même UkanHomeShell que le client
→ Avancé → "Passer en mode Coach" (accessible à TOUS) → CoachDashboardPage
   → Clients (5 fictifs) → fiche client → notes/progression (RAM), assigner programme (RAM)
   → Coach Business™ (dashboard/ventes/branding/produits = démo)
   → Planning / disponibilités / RDV (RAM, IDs incohérents)
```
**Il n'y a pas de séparation réelle coach/élève.** Un coach voit les mêmes 5 clients fictifs que n'importe qui.

### 4. Autres rôles (admin, modérateur, premium)
- **Admin / modérateur** : absents.
- **Premium** : activable en démo (RAM), débloque partiellement quelques vidéos et le coach IA posture ; perdu au redémarrage.

---

## PARTIE E — Relations entre les modules

| Relation attendue | Réellement connectée ? | Preuve |
|---|---|---|
| Programme coach → assigné à un élève | ⚠️ Coach-side seulement | `assignProgramToClient()` en RAM, IDs `sarah`… |
| L'élève voit ce programme | ❌ Non | `programsForClient('current_user')` toujours vide (`main.dart:2200`) |
| Séance effectuée → met à jour les stats | 🟡 Partiel | Seul `WorkoutSessionRecordingPage` persiste ; exécution guidée non |
| Stats propres à chaque utilisateur | ❌ Non | Singletons globaux partagés ; mono-appareil |
| Coach voit uniquement ses élèves | ❌ Non | Clients codés en dur, sans `coachId` |
| Élève voit uniquement son coach | ❌ Non | `coach_1` codé en dur pour tous |
| Message envoyé → apparaît chez l'autre | ❌ Non (impossible) | Un seul appareil, singleton RAM |
| Blessure de l'élève → visible par le coach | ❌ Non | `InjuryNotifier` non partagé |
| Nutrition visible par le coach | ❌ Non | `SimpleNutritionPage()` ouvert **sans** `clientId` |
| Disponibilités coach → utilisées dans les RDV | ❌ Non | Deux systèmes indépendants (signup vs `AppointmentsRepository`) |
| RDV créé → chez coach ET élève | 🟡 Partiel | Même RAM mais IDs incohérents |
| Notifications reliées aux actions | ❌ Non | Pas de système de notifications |
| Post créé → visible dans le feed | ❌ Non | `ProfileFeedNotifier` ≠ `FeedPage` (2 systèmes) |

**Modules « visuellement présents mais non reliés au reste » :** feed principal (statique), stories, événements (inscription factice), création d'exercice, restrictions blessures→entraînement, disponibilités inscription→RDV, nutrition côté coach.

---

## PARTIE F — Fonctionnalités incomplètes ou trompeuses (interface OK mais ne fonctionne pas réellement)

1. **Connexion / inscription** : aucun compte réel, aucune session persistée.
2. **Mot de passe oublié / connexion sociale** : boutons vides.
3. **FoodScan IA (photo) & code-barres** : pas de caméra, pas de scan — choix dans une liste ; code-barres inexistant.
4. **Messagerie** : conversations démo, envoi local seulement, pas de pièces jointes/blocage/signalement.
5. **Chat coach & Chat Match** : réponses automatiques scriptées.
6. **Assignation de programme coach→élève** : invisible pour l'élève réel.
7. **RDV / disponibilités** : IDs incohérents, vue planning coach cassée, dispos d'inscription ignorées.
8. **Premium / paiements / achats / factures** : entièrement simulés, non persistés, avantages promis non tenus.
9. **Coach Business (ventes, revenus, branding)** : chiffres fictifs, branding non persisté.
10. **Buddy/Rooms/Cours live** : pas de temps réel, participants simulés.
11. **Événements** : inscription et création n'enregistrent rien.
12. **Hard Challenge (création)** : `// TODO`, non sauvegardé.
13. **Blessures** : non partagées au coach, sans impact sur les entraînements.
14. **Likes/commentaires/partage** du feed profil : boutons vides.
15. **Section « Évolution » du profil** : « courbes et photos avant/après bientôt » (vide).
16. **Alter Ego / Projection IA / Coach IA** : présentés comme « IA » mais scriptés/simulés.
17. **Paramètres** (langue, notifications, export, confidentialité) : « à venir ».

---

## PARTIE G — Fonctionnalités absentes (mentionnées/affichées/promises mais inexistantes dans le code)

- **Backend, API, base de données, synchronisation cloud** — totalement absents.
- **Authentification réelle**, vérification e-mail, **OTP**, réinitialisation mot de passe.
- **Notifications push** (aucune dépendance FCM).
- **Scan de code-barres** ; **analyse calories réelle par IA** (photo).
- **Photos de repas** (champ `photoUrl` existe, upload absent).
- **Photos avant/après + courbes de progression** (promis dans le profil et Premium).
- **Vraie messagerie** multi-utilisateur ; pièces jointes ; blocage ; signalement.
- **Temps réel** (Rooms/Buddy/Cours live synchronisés — pas de WebRTC).
- **Paiements réels** (Stripe/IAP) ; factures.
- **Persistance globale** des données (nutrition, blessures, notes, jeux, coach, messages… tout en RAM).
- **Vraie séparation des rôles / permissions** ; admin ; modération.
- **CGU / CGV / mentions légales / politique de confidentialité** (dialog « version finale »).
- **Onboarding** au premier lancement (`onboarding_page.dart` existe mais n'est pas relié au flux).

---

## PARTIE H — Pages et composants inutilisés (code mort / doublons)

**Pages jamais reliées (code mort) :**
- `lib/register_page.dart`, `lib/forgot_password_page.dart` (anciennes pages auth, remplacées).
- `lib/home_page.dart` (ancien accueil — le vrai est `lib/home/home_page.dart`).
- `lib/exercise_detail_page.dart` et `lib/exercise_video_page.dart` (doublons des versions `lib/exercises/…`).
- `lib/injury_log_screen.dart`, `lib/pages/about_demo_page.dart`, `lib/pages/simple_nutrition_tab.dart`.
- `lib/workout/workout_history_calendar_page.dart`, `lib/coach_appointment_page.dart` (importé mais non appelé).
- `lib/add_water_page.dart`, `lib/pedometer_page.dart`, `lib/add_body_entry_page.dart`.

**Composants/données jamais importés :**
- `components/active_rest_timer.dart`, `rest_timer_widget.dart`, `rest_timer_selector.dart`, `muscle_autocomplete_field.dart`, `parrainage_button.dart`.
- `pages/planning/difficulty_section_widget.dart`.
- `home/models/demo_feed_data.dart` (`demoPosts`/`demoStories`), `home/widgets/stories_row.dart`, `publication_card.dart`.
- Sections mortes **dans `main.dart`** : `PersonalToolsSection`, `NewModulesSection`, `_buildSubscriptionSection()`, `_buildMyPurchasesSection()`, `_MealCard`/`_MacroItem`, ~500 lignes repas/courses dans `dashboard_tab.dart`, `LoginPage` (doublon).

**Doublons fonctionnels notables :**
- 2 `LoginPage` (main.dart vs auth) · 2 systèmes de feed · 2 UIs nutrition (hub vs `SimpleNutritionPage`) · 2 modèles `CoachProgram` · 2 `CoachPersonalityNotifier` · 2 systèmes de planning (`PlanningNotifier` vs `AppointmentsRepository`) · `VisioSessionPage` ≈ `RoomsSessionPage` · `FeedPage` ≈ `ExplorerFeedWidget`.

---

## PARTIE I — Problèmes prioritaires

### 🔴 Bloquants (empêchent un usage normal / réel)
1. **Aucune persistance globale** : nutrition, blessures, notes, jeux, coach, messages, premium… perdus à chaque redémarrage.
2. **Authentification factice** + **pas de session** : le splash renvoie toujours au login.
3. **Rôle sans effet** : `fitpro_role` jamais relu → pas de séparation client/coach.
4. **Aucune donnée réelle multi-utilisateur** (pas de backend) : coach↔élève, messagerie, RDV impossibles réellement.
5. **Ruptures d'IDs** (`current_user` vs `sarah` vs `client_demo_1`) : l'élève ne voit pas ses programmes/RDV.

### 🟠 Importants (fonctionnalité incomplète/incohérente)
6. Objectifs incohérents entre 3 sources (constantes / profil / `DailyGoalsNotifier`).
7. Historique de séances éclaté en 3 systèmes non synchronisés ; exécution guidée qui n'enregistre rien.
8. Premium promet des fonctionnalités inexistantes ; gating quasi absent.
9. Création (exercice, événement, défi, recette→planning) sans sauvegarde réelle.
10. Annuaire coachs incohérent (2 sources, mêmes IDs, données différentes).
11. Nombreux **doublons** et **code mort** (voir Partie H) → confusion et risque de bugs.
12. `main.dart` monolithique (~5 000 lignes) contenant login, shell, onglets, profil géant.

### 🟡 Secondaires (visuel / traduction / organisation)
13. Textes « démo / fictif / à venir » visibles dans l'UI (login, premium, achats, FoodScan…).
14. Champs de connexion pré-remplis (`toi@mail.com`, `••••••••`).
15. Textes en anglais résiduels (« Dashboard », « Publications », filtres recettes).
16. Placeholders d'images (coachs, match, duels) ; pas d'upload photo de profil.
17. Pas d'animations de transition ; graphiques sans interactivité ; responsive perfectible.

---

## PARTIE J — Recommandation pour un premier lancement

### À conserver (suffisamment solide, persistant ou proprement local)
- **Séances/programmes d'entraînement** (persistés via `WorkoutSessionStorage`) + **bibliothèque d'exercices** (~111).
- **Suivi quotidien** (eau, sommeil, pas via podomètre réel, calories/protéines) + **statistiques** — à condition d'ajouter la persistance.
- **Thème clair/sombre** (déjà persistant).
- **Coach vocal** (TTS/audio réels) et **Sport Gaming Story** (XP/bosses/quêtes) comme éléments d'engagement, en assumant leur nature locale.

### À terminer avant lancement (priorité)
- **Persistance locale** (Hive/SQLite ou SharedPreferences généralisé) pour nutrition, blessures, notes, objectifs, jeux, premium.
- **Session** (rester connecté) + **lecture réelle du rôle** pour séparer les vues client/coach.
- Unifier les **objectifs**, l'**historique de séances** et les **IDs utilisateur**.
- Nettoyer les **textes « démo/à venir »** de l'UI visible.

### À masquer pour la V1 (présent mais trompeur)
- Coach Business, Coach vs Coach, Cours Live/Replays, Buddy/Rooms visio, Événements, Chat Match, Projection IA, FoodScan photo, Premium/paiements — tant qu'il n'y a pas de backend.
- Boutons vides : mot de passe oublié, connexion sociale, likes/commentaires feed.

### À reporter (nécessite un backend)
- Messagerie réelle, contact/réservation coach, temps réel (rooms/live), paiements, notifications push, synchronisation multi-appareils.

### À supprimer (inutile / redondant)
- Tout le code mort et les doublons de la Partie H (dont les 2ᵉ `LoginPage`, `home_page.dart` racine, pages exercice/vidéo dupliquées, sections mortes de `main.dart`).

### Navigation simplifiée proposée pour une V1 honnête (mono-appareil, offline)
```
Connexion locale (persistée)
→ Accueil (Dashboard: objectifs, eau, sommeil, pas, calories — persistés)
→ Séances (bibliothèque + programmes + lancer/enregistrer → historique + stats)
→ Nutrition (journal repas + recettes, en local persisté)
→ Profil / Réglages (thème, unités, objectifs, blessures — en local)
   (+ Coach vocal & Sport Gaming en bonus assumé local)
```

---

## ✅ Ce que l'application possède réellement aujourd'hui

**Ce que peut réellement faire un « utilisateur » (en mots simples) :**
- Créer un compte **local** (rien n'est envoyé nulle part), se « connecter » (ça marche toujours).
- Suivre son eau, son sommeil, ses pas (**vrai podomètre**), ses calories/protéines et voir des **statistiques** — **mais tout s'efface au redémarrage** (sauf l'entraînement).
- Parcourir une **vraie bibliothèque d'exercices**, **créer un programme et enregistrer ses séances** : c'est **la seule partie qui reste sauvegardée**.
- Ajouter des repas et des recettes, jouer aux mini-jeux (XP/boss), discuter avec un « coach IA » qui **parle vraiment** (synthèse vocale) mais répond avec des phrases pré-écrites.

**Ce que peut réellement faire un « élève avec coach » :**
- Rien de spécifique : il voit un **coach fictif imposé** (Sophie Martin). Il ne reçoit pas de vrai programme, ne peut pas vraiment discuter, et un rendez-vous « réservé » n'apparaît pas correctement chez le coach.

**Ce que peut réellement faire un « coach » :**
- Ouvrir un **espace coach de démonstration** (accessible à tout le monde), voir **5 clients fictifs**, prendre des notes et assigner des programmes… **qui restent en mémoire et disparaissent au redémarrage**, et que l'élève réel **ne voit jamais**. Le business (ventes, revenus) est **entièrement simulé**.

**Ce qui fonctionne entièrement (et dure) :**
- Le **thème clair/sombre**, et la **gestion des programmes/séances d'entraînement** (bibliothèque + création + enregistrement + historique persisté).

**Ce qui fonctionne seulement en apparence :**
- Connexion/inscription, messagerie, chat coach, Chat Match, réservation de RDV, Premium/paiements, Coach Business, FoodScan photo, cours live, buddy/rooms visio, événements, likes/commentaires, notifications, « IA ».

**Ce qui manque encore :**
- Un **backend** (comptes réels, synchronisation, temps réel, paiements, notifications), une **persistance générale** des données, une **vraie séparation des rôles**, le **partage des données entre coach et élève**, les photos, le scan réel, et les mentions légales.

**Ce qui devrait être gardé ou masqué pour le premier lancement :**
- **Garder** : entraînement, suivi quotidien, statistiques, thème, coach vocal, gaming (avec persistance ajoutée).
- **Masquer** : coach/business, messagerie, paiements/premium, temps réel (rooms/live), Chat Match, événements, FoodScan photo, projection IA — tout ce qui suppose un serveur ou trompe l'utilisateur.

---

*Audit réalisé en lecture seule. Aucun fichier du projet n'a été modifié.*
