import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'alter_ego_context_service.dart';

/// Énumération pour définir les positions possibles du Bitmoji
enum AlterEgoPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

/// Énumération pour les poses de l'Alter Ego
enum AlterEgoPose {
  neutre,
  salut,
  felicite,
  encourage,
  reflechit,
  alerte,
  repose,
  applaudit,
  clindoeil,
}

/// Service global pour gérer l'état de l'Alter Ego flottant
/// Singleton pattern avec ChangeNotifier
class AlterEgoService extends ChangeNotifier {
  static final AlterEgoService _instance = AlterEgoService._internal();
  factory AlterEgoService() => _instance;
  AlterEgoService._internal() {
    _initTts();
  }

  // TTS instance
  final FlutterTts _tts = FlutterTts();
  bool _ttsInitialized = false;

  // État de l'Alter Ego
  AlterEgoPose _currentPose = AlterEgoPose.neutre;
  String _currentMessage = '';
  AlterEgoPosition _currentPosition = AlterEgoPosition.bottomRight;
  bool _isVisible = false; // Désactivé par défaut pour éviter les erreurs au démarrage
  bool _isMessageVisible = false;
  
  // État du chatbot
  bool _isChatActive = false;
  List<ChatMessage> _conversationHistory = [];
  bool _showChatInterface = false;
  
  // Service de contexte
  final AlterEgoContextService _contextService = AlterEgoContextService();
  
  // Image contextuelle actuelle
  String? _currentContextImage;
  
  // Pattern de réponses du chatbot (mode démo) - MEGA ENRICHI
  static final Map<String, ChatResponse> _responsePatterns = {
    // ═══════════════════════════════════════
    // SALUTATIONS
    // ═══════════════════════════════════════
    'salut': ChatResponse('Salut ! Comment puis-je t\'aider aujourd\'hui ? 💪', AlterEgoPose.salut),
    'bonjour': ChatResponse('Bonjour ! Je suis là pour t\'accompagner dans tes objectifs fitness ! 🎯', AlterEgoPose.salut),
    'bonsoir': ChatResponse('Bonsoir ! J\'espère que ta journée s\'est bien passée ! 🌙', AlterEgoPose.repose),
    'coucou': ChatResponse('Coucou ! Prêt à te dépasser aujourd\'hui ? 💪', AlterEgoPose.clindoeil),
    'hello': ChatResponse('Hello ! Je suis ton guide Ukan. Pose-moi n\'importe quelle question ! 🎯', AlterEgoPose.salut),
    'hey': ChatResponse('Hey ! Content de te voir ! Qu\'est-ce que je peux faire pour toi ? 💪', AlterEgoPose.clindoeil),
    'yo': ChatResponse('Yo ! Prêt pour une séance de folie ? 🔥', AlterEgoPose.encourage),
    'ça va': ChatResponse('Super bien, merci ! Et toi, prêt à bouger ? 💪', AlterEgoPose.felicite),
    
    // ═══════════════════════════════════════
    // NAVIGATION DANS L'APP
    // ═══════════════════════════════════════
    'accueil': ChatResponse('L\'accueil te montre ton dashboard avec tes stats, défis de la semaine et progression. C\'est ton point de départ ! 🏠', AlterEgoPose.reflechit),
    'dashboard': ChatResponse('Le dashboard affiche tes calories, pas, séances de la semaine et ton défi actuel. Tu peux tout suivre d\'un coup d\'œil ! 📊', AlterEgoPose.reflechit),
    'séance': ChatResponse('Va dans l\'onglet Séances pour voir ta bibliothèque d\'exercices, créer des séances et suivre tes entraînements ! 🏋️', AlterEgoPose.encourage),
    'nutrition': ChatResponse('L\'onglet Nutrition te permet de gérer tes repas, scanner des aliments avec FoodScan IA et planifier ta semaine ! 🥗', AlterEgoPose.reflechit),
    'avancé': ChatResponse('L\'Espace Avancé contient toutes les fonctionnalités premium : Coach IA, Sport Gaming, Chat Match, et plus ! ⭐', AlterEgoPose.felicite),
    'rechercher': ChatResponse('L\'onglet Rechercher te permet de trouver des coachs, des programmes et des exercices adaptés à tes besoins ! 🔍', AlterEgoPose.reflechit),
    'menu': ChatResponse('Le menu du bas te donne accès à : Accueil, Séances, Nutrition, Avancé et Rechercher. Navigue facilement ! 📱', AlterEgoPose.reflechit),
    'paramètre': ChatResponse('Les paramètres sont accessibles via la roue crantée en haut à gauche. Tu peux y modifier ton compte, notifications, thème... ⚙️', AlterEgoPose.reflechit),
    'notification': ChatResponse('Gère tes notifications dans Paramètres > Notifications. Active les rappels d\'entraînement, repas, hydratation... 🔔', AlterEgoPose.reflechit),
    
    // ═══════════════════════════════════════
    // EXERCICES & SÉANCES (ENRICHI)
    // ═══════════════════════════════════════
    'ajouter exercice': ChatResponse('Pour ajouter un exercice : va dans Séances > Bibliothèque d\'exercices > bouton + en bas à droite. Tu peux créer ton propre exercice avec vidéo ! 📝', AlterEgoPose.reflechit),
    'créer séance': ChatResponse('Pour créer une séance : Séances > Nouvelle séance. Ajoute tes exercices, définis les séries/répétitions et c\'est parti ! 💪', AlterEgoPose.encourage),
    'démarrer séance': ChatResponse('Clique sur une séance programmée et appuie sur Démarrer. Le chrono et les instructions te guideront ! ⏱️', AlterEgoPose.felicite),
    'chrono': ChatResponse('Le chrono s\'affiche pendant ta séance. Tu peux le mettre en pause, passer à l\'exercice suivant ou arrêter quand tu veux ! ⏱️', AlterEgoPose.reflechit),
    'bibliothèque': ChatResponse('La bibliothèque d\'exercices contient tous les exercices disponibles, classés par groupe musculaire. Tu peux aussi créer les tiens ! 📚', AlterEgoPose.reflechit),
    'pompe': ChatResponse('Les pompes travaillent les pectoraux, triceps et épaules. Garde le dos droit et descends jusqu\'à ce que ta poitrine frôle le sol ! 💪', AlterEgoPose.encourage),
    'squat': ChatResponse('Le squat est le roi des exercices ! Pieds largeur d\'épaules, descends comme si tu t\'asseyais, garde le dos droit. Tes cuisses te remercieront ! 🏋️', AlterEgoPose.felicite),
    'abdominaux': ChatResponse('Pour les abdos, varie les exercices : crunch, planche, relevé de jambes. 3-4 séries de 15-20 reps, 3x par semaine ! 🔥', AlterEgoPose.encourage),
    'abdo': ChatResponse('Les abdos se travaillent avec régularité ! Crunch, gainage, mountain climbers... 15-20 min par jour suffisent ! 🔥', AlterEgoPose.encourage),
    'musculation': ChatResponse('La musculation développe ta masse musculaire. Commence par les exercices de base (squat, développé, tirage) avant d\'isoler ! 🏋️', AlterEgoPose.felicite),
    'cardio': ChatResponse('Le cardio améliore ton endurance et brûle des calories. Course, vélo, corde à sauter... 20-30 min, 3x par semaine ! 🏃', AlterEgoPose.encourage),
    'étirement': ChatResponse('Les étirements sont essentiels ! 10-15 min après chaque séance pour améliorer ta souplesse et éviter les blessures. 🧘', AlterEgoPose.repose),
    'planche': ChatResponse('La planche renforce tout le core ! Tiens 30 sec à 1 min, dos droit, fessiers serrés. Augmente progressivement la durée ! 💪', AlterEgoPose.encourage),
    'burpee': ChatResponse('Le burpee est l\'exercice complet par excellence ! Cardio + force. Commence par 10, puis augmente. Tu vas transpirer ! 🔥', AlterEgoPose.felicite),
    'fente': ChatResponse('Les fentes sculptent les jambes et fessiers ! Garde le genou avant à 90°, ne dépasse pas les orteils. Alterne les jambes ! 🦵', AlterEgoPose.encourage),
    'tirage': ChatResponse('Le tirage travaille le dos et les biceps. Tire les coudes vers l\'arrière, serre les omoplates. Essentiel pour une bonne posture ! 💪', AlterEgoPose.reflechit),
    'développé': ChatResponse('Le développé couché travaille les pectoraux. Garde les pieds au sol, descends la barre jusqu\'à la poitrine, pousse ! 🏋️', AlterEgoPose.encourage),
    'biceps': ChatResponse('Pour les biceps : curl haltères, curl barre, curl marteau. 3-4 séries de 10-12 reps. Ne balance pas le corps ! 💪', AlterEgoPose.encourage),
    'triceps': ChatResponse('Les triceps représentent 2/3 du bras ! Dips, extensions, kickbacks... 3-4 séries de 10-12 reps pour des bras toniques ! 💪', AlterEgoPose.encourage),
    'épaule': ChatResponse('Pour des épaules larges : développé militaire, élévations latérales, face pull. 3-4 séries de 10-15 reps ! 🏋️', AlterEgoPose.encourage),
    'dos': ChatResponse('Un dos fort = une bonne posture ! Tirage, rowing, soulevé de terre, tractions... Travaille-le 2x par semaine minimum ! 💪', AlterEgoPose.encourage),
    'jambe': ChatResponse('Les jambes sont la base ! Squat, fentes, presse, leg curl... Ne saute jamais le leg day ! 🦵', AlterEgoPose.felicite),
    'fessier': ChatResponse('Pour des fessiers en béton : hip thrust, squat profond, fentes, kickback. 3-4x par semaine pour des résultats ! 🍑', AlterEgoPose.clindoeil),
    'pectoraux': ChatResponse('Les pectoraux se travaillent avec : développé couché, pompes, écarté, dips. Varie les angles pour un développement complet ! 💪', AlterEgoPose.encourage),
    'traction': ChatResponse('La traction est l\'exercice roi du dos ! Prise large pour le grand dorsal, serrée pour les biceps. Commence par des tractions assistées si besoin ! 💪', AlterEgoPose.felicite),
    'gainage': ChatResponse('Le gainage renforce ta ceinture abdominale ! Planche, planche latérale, hollow hold... 3x30 sec à 1 min par jour ! 🔥', AlterEgoPose.encourage),
    'hiit': ChatResponse('Le HIIT brûle un max de calories en peu de temps ! 20-30 sec d\'effort intense, 10-15 sec de repos. 15-20 min suffisent ! 🔥', AlterEgoPose.felicite),
    'échauffement': ChatResponse('L\'échauffement est crucial ! 5-10 min de cardio léger + mouvements articulaires avant chaque séance. Évite les blessures ! 🏃', AlterEgoPose.alerte),
    'récupération': ChatResponse('La récupération est aussi importante que l\'entraînement ! Dors 7-8h, mange bien, étire-toi. Tes muscles grandissent au repos ! 😴', AlterEgoPose.repose),
    'courbature': ChatResponse('Les courbatures sont normales après un effort ! Elles disparaissent en 2-3 jours. Étire-toi, hydrate-toi et bouge légèrement ! 💪', AlterEgoPose.encourage),
    'blessure': ChatResponse('En cas de blessure, arrête l\'exercice ! Applique de la glace, repose-toi et consulte un médecin si la douleur persiste. ⚠️', AlterEgoPose.alerte),
    'programme': ChatResponse('Un bon programme alterne les groupes musculaires. Exemple : Lundi pecs/triceps, Mardi dos/biceps, Jeudi jambes, Vendredi épaules ! 📋', AlterEgoPose.reflechit),
    'série': ChatResponse('Le nombre de séries dépend de ton objectif : 3-4 séries pour la force, 4-5 pour l\'hypertrophie, 2-3 pour l\'endurance ! 📊', AlterEgoPose.reflechit),
    'répétition': ChatResponse('Les répétitions varient selon l\'objectif : 1-5 reps pour la force, 8-12 pour le muscle, 15-20+ pour l\'endurance ! 📊', AlterEgoPose.reflechit),
    'tempo': ChatResponse('Le tempo contrôle la vitesse du mouvement. Exemple 3-1-2 : 3 sec descente, 1 sec pause, 2 sec montée. Plus de tension musculaire ! 💪', AlterEgoPose.reflechit),
    'superset': ChatResponse('Un superset enchaîne 2 exercices sans repos. Gain de temps et intensité maximale ! Exemple : pompes + tirage ! 🔥', AlterEgoPose.felicite),
    'dropset': ChatResponse('Le dropset : fais ton exercice jusqu\'à l\'échec, réduis le poids de 20-30%, continue jusqu\'à l\'échec. Brûlure garantie ! 🔥', AlterEgoPose.encourage),
    
    // ═══════════════════════════════════════
    // PERTE DE POIDS (NOUVEAU)
    // ═══════════════════════════════════════
    'perdre poids': ChatResponse('Pour perdre du poids : déficit calorique de 300-500 kcal/jour + cardio + musculation. Patience et régularité sont les clés ! ⚖️', AlterEgoPose.reflechit),
    'maigrir': ChatResponse('Pour maigrir sainement : mange moins que tu ne dépenses, privilégie les protéines, fais du sport 3-4x/semaine. Pas de régime extrême ! ⚖️', AlterEgoPose.encourage),
    'perte de poids': ChatResponse('La perte de poids idéale : 0.5 à 1 kg par semaine. Plus rapide = perte de muscle. Sois patient, les résultats viendront ! 📉', AlterEgoPose.reflechit),
    'brûler graisse': ChatResponse('Pour brûler la graisse : déficit calorique + cardio (HIIT ou modéré) + musculation pour préserver le muscle. C\'est la combo gagnante ! 🔥', AlterEgoPose.felicite),
    'ventre plat': ChatResponse('Le ventre plat = alimentation + cardio + gainage. Tu ne peux pas cibler la graisse, mais tu peux renforcer les abdos ! 🔥', AlterEgoPose.encourage),
    'régime': ChatResponse('Évite les régimes restrictifs ! Privilégie un rééquilibrage alimentaire durable. Mange de tout, en quantité adaptée. 🥗', AlterEgoPose.alerte),
    'mincir': ChatResponse('Pour mincir : réduis les sucres raffinés, augmente les protéines et légumes, bois beaucoup d\'eau et bouge ! 💪', AlterEgoPose.encourage),
    'cellulite': ChatResponse('Contre la cellulite : cardio, musculation des jambes/fessiers, massage, hydratation et alimentation équilibrée ! 🦵', AlterEgoPose.reflechit),
    'métabolisme': ChatResponse('Booste ton métabolisme : mange des protéines, fais de la musculation, dors bien et reste actif dans la journée ! 🔥', AlterEgoPose.felicite),
    'déficit calorique': ChatResponse('Le déficit calorique = manger moins que tes besoins. Calcule ton métabolisme de base et retire 300-500 kcal. C\'est la clé ! 📊', AlterEgoPose.reflechit),
    
    // ═══════════════════════════════════════
    // PRISE DE MASSE (NOUVEAU)
    // ═══════════════════════════════════════
    'prise de masse': ChatResponse('Pour prendre de la masse : surplus calorique de 200-300 kcal + 2g protéines/kg + musculation intense. Les gains arrivent ! 💪', AlterEgoPose.felicite),
    'prendre muscle': ChatResponse('Pour prendre du muscle : mange plus que tes besoins, privilégie les protéines, entraîne-toi lourd et repose-toi bien ! 🏋️', AlterEgoPose.encourage),
    'bulk': ChatResponse('En phase de bulk, mange en surplus calorique propre. Protéines à chaque repas, glucides complexes, bonnes graisses. Pas de junk food ! 🍗', AlterEgoPose.reflechit),
    'sèche': ChatResponse('La sèche = déficit calorique pour révéler les muscles. Garde les protéines hautes, réduis les glucides progressivement. Cardio modéré ! ⚖️', AlterEgoPose.reflechit),
    'masse musculaire': ChatResponse('La masse musculaire se construit avec : entraînement progressif, surplus calorique, protéines et repos. Patience, ça prend du temps ! 💪', AlterEgoPose.encourage),
    
    // ═══════════════════════════════════════
    // HYDRATATION (NOUVEAU)
    // ═══════════════════════════════════════
    'eau': ChatResponse('L\'eau est essentielle ! Bois 2-3L par jour, plus si tu t\'entraînes. Ton corps est composé de 60% d\'eau ! 💧', AlterEgoPose.encourage),
    'hydratation': ChatResponse('Reste hydraté ! 2-3L d\'eau par jour minimum. Bois avant, pendant et après l\'entraînement. Ton corps te remerciera ! 💧', AlterEgoPose.felicite),
    'boire': ChatResponse('Boire suffisamment améliore tes performances, ta récupération et ta santé. Vise 30-40ml par kg de poids de corps ! 💧', AlterEgoPose.reflechit),
    'déshydratation': ChatResponse('La déshydratation réduit tes performances de 20% ! Bois régulièrement, même sans soif. Urine claire = bien hydraté ! 💧', AlterEgoPose.alerte),
    'soif': ChatResponse('Si tu as soif, tu es déjà légèrement déshydraté ! Bois régulièrement tout au long de la journée, pas seulement quand tu as soif ! 💧', AlterEgoPose.reflechit),
    
    // ═══════════════════════════════════════
    // NUTRITION (ENRICHI)
    // ═══════════════════════════════════════
    'calorie': ChatResponse('Les calories sont ton carburant ! Pour perdre du poids : déficit de 300-500 kcal. Pour prendre du muscle : surplus de 200-300 kcal. 📊', AlterEgoPose.reflechit),
    'protéine': ChatResponse('Les protéines construisent le muscle ! Vise 1.6-2g par kg de poids de corps. Viande, poisson, œufs, légumineuses... 🍗', AlterEgoPose.reflechit),
    'repas': ChatResponse('Pour ajouter un repas : Nutrition > Repas & Courses > bouton +. Tu peux scanner les aliments ou les ajouter manuellement ! 🍽️', AlterEgoPose.reflechit),
    'scanner': ChatResponse('FoodScan IA analyse tes plats en photo ! Va dans Nutrition > FoodScan IA, prends une photo et obtiens les calories et macros automatiquement ! 📸', AlterEgoPose.felicite),
    'foodscan': ChatResponse('FoodScan IA est notre outil de reconnaissance alimentaire. Prends une photo de ton assiette et je t\'analyse tout ! 🤖📸', AlterEgoPose.felicite),
    'meal planner': ChatResponse('Le Meal Planner te permet de planifier tes repas pour la semaine. Glisse-dépose les recettes sur les jours ! 📅', AlterEgoPose.reflechit),
    'liste courses': ChatResponse('La liste de courses se génère automatiquement depuis tes repas planifiés. Tu peux aussi l\'éditer manuellement ! 🛒', AlterEgoPose.reflechit),
    'recette': ChatResponse('Découvre des recettes dans Nutrition > Recettes & Communauté. Tu peux aussi partager les tiennes avec la communauté ! 👨‍🍳', AlterEgoPose.clindoeil),
    'glucide': ChatResponse('Les glucides sont ton énergie ! Privilégie les complexes (riz, pâtes, patate douce) aux simples (sucre, bonbons). 🍚', AlterEgoPose.reflechit),
    'lipide': ChatResponse('Les lipides sont essentiels ! Privilégie les bonnes graisses : huile d\'olive, avocat, noix, poisson gras. 30% de tes calories ! 🥑', AlterEgoPose.reflechit),
    'fibre': ChatResponse('Les fibres aident la digestion et la satiété ! Légumes, fruits, céréales complètes... Vise 25-30g par jour ! 🥦', AlterEgoPose.reflechit),
    'petit déjeuner': ChatResponse('Le petit déj\' lance ta journée ! Protéines (œufs, yaourt), glucides (avoine, pain complet), fruits. Évite les céréales sucrées ! 🍳', AlterEgoPose.felicite),
    'déjeuner': ChatResponse('Le déjeuner doit être équilibré : protéines (viande/poisson), glucides (riz/pâtes), légumes. Évite les fast-foods ! 🍽️', AlterEgoPose.reflechit),
    'dîner': ChatResponse('Le dîner doit être léger : protéines maigres, légumes, peu de glucides. Mange 2-3h avant de dormir ! 🌙', AlterEgoPose.repose),
    'collation': ChatResponse('Les collations maintiennent l\'énergie ! Fruits, yaourt, noix, fromage blanc... Évite les gâteaux et chips ! 🍎', AlterEgoPose.reflechit),
    'snack': ChatResponse('Pour un snack sain : fruits, noix, yaourt grec, œuf dur, légumes crus. Évite les snacks industriels ! 🥜', AlterEgoPose.reflechit),
    'sucre': ChatResponse('Limite le sucre ajouté ! Max 25g par jour. Lis les étiquettes, le sucre se cache partout. Préfère les fruits ! 🍬', AlterEgoPose.alerte),
    'sel': ChatResponse('Limite le sel ! Max 5g par jour. Trop de sel = rétention d\'eau et hypertension. Assaisonne avec des herbes ! 🧂', AlterEgoPose.alerte),
    'alcool': ChatResponse('L\'alcool = calories vides + mauvaise récupération. Limite ta consommation, surtout les jours d\'entraînement ! 🍺', AlterEgoPose.alerte),
    'junk food': ChatResponse('La junk food occasionnelle, c\'est OK ! Mais pas tous les jours. 80% clean, 20% plaisir. L\'équilibre est la clé ! 🍔', AlterEgoPose.clindoeil),
    'macro': ChatResponse('Les macros = protéines, glucides, lipides. Un ratio classique : 30% protéines, 40% glucides, 30% lipides. Adapte selon tes objectifs ! 📊', AlterEgoPose.reflechit),
    'calculatrice': ChatResponse('La calculatrice nutrition est dans Nutrition > Repas & Courses > icône calculatrice. Calcule tes macros et calories ! 🧮', AlterEgoPose.reflechit),
    'calculer calorie': ChatResponse('Pour calculer tes calories : Nutrition > Calculatrice. Entre tes aliments et obtiens le total automatiquement ! 🧮', AlterEgoPose.reflechit),
    'compter calorie': ChatResponse('Compter les calories aide à atteindre tes objectifs ! Utilise FoodScan ou la calculatrice dans l\'onglet Nutrition. 📊', AlterEgoPose.reflechit),
    'whey': ChatResponse('La whey est une protéine rapide, idéale après l\'entraînement ! 20-30g dans un shaker. Pas obligatoire si tu manges assez de protéines ! 🥛', AlterEgoPose.reflechit),
    'complément': ChatResponse('Les compléments ne remplacent pas une bonne alimentation ! Whey, créatine, vitamines... Utiles, mais pas magiques ! 💊', AlterEgoPose.reflechit),
    'créatine': ChatResponse('La créatine améliore la force et l\'endurance ! 3-5g par jour, tous les jours. Bois beaucoup d\'eau avec ! 💪', AlterEgoPose.reflechit),
    'vitamine': ChatResponse('Les vitamines sont dans ton alimentation ! Mange varié : fruits, légumes, viande, poisson. Un complément en hiver peut aider (vitamine D) ! 🍊', AlterEgoPose.reflechit),
    
    // ═══════════════════════════════════════
    // RECETTES (NOUVEAU)
    // ═══════════════════════════════════════
    'recette poulet': ChatResponse('Poulet grillé : marinade citron/herbes, 180°C pendant 25 min. Simple, protéiné et délicieux ! 🍗', AlterEgoPose.felicite),
    'recette saumon': ChatResponse('Saumon au four : filet + citron + aneth, 180°C 15-20 min. Riche en oméga-3 et protéines ! 🐟', AlterEgoPose.felicite),
    'recette salade': ChatResponse('Salade protéinée : poulet/thon + œuf + avocat + légumes + vinaigrette maison. Frais et nutritif ! 🥗', AlterEgoPose.felicite),
    'recette smoothie': ChatResponse('Smoothie post-workout : banane + lait + whey + beurre de cacahuète + flocons d\'avoine. Énergie et protéines ! 🥤', AlterEgoPose.felicite),
    'recette bowl': ChatResponse('Buddha bowl : riz/quinoa + poulet + avocat + légumes grillés + sauce tahini. Complet et équilibré ! 🥗', AlterEgoPose.felicite),
    'recette œuf': ChatResponse('Œufs brouillés protéinés : 3 œufs + fromage + épinards. 5 min à la poêle. Parfait pour le petit déj\' ! 🍳', AlterEgoPose.felicite),
    'recette avoine': ChatResponse('Overnight oats : flocons d\'avoine + lait + yaourt + fruits + miel. Prépare le soir, mange le matin ! 🥣', AlterEgoPose.felicite),
    'idée repas': ChatResponse('Idées repas sains : poulet/riz/légumes, saumon/patate douce, salade protéinée, bowl quinoa... Varie les plaisirs ! 🍽️', AlterEgoPose.reflechit),
    'quoi manger': ChatResponse('Mange équilibré : protéines à chaque repas, légumes, glucides complexes, bonnes graisses. Évite les produits transformés ! 🥗', AlterEgoPose.reflechit),
    
    // ═══════════════════════════════════════
    // SOCIAL & BUDDIES
    // ═══════════════════════════════════════
    'buddy': ChatResponse('Trouve un partenaire d\'entraînement dans Chat Match ou Buddy Workout ! Filtre par niveau, objectifs et localisation. 👥', AlterEgoPose.salut),
    'partenaire': ChatResponse('Un partenaire de sport, c\'est la clé de la motivation ! Va dans Chat Match, swipe les profils et trouve ton buddy idéal ! 💪👥', AlterEgoPose.encourage),
    'chat match': ChatResponse('Chat Match te permet de matcher avec des sportifs compatibles. Swipe à droite si le profil te plaît ! C\'est comme Tinder, mais pour le sport ! 🏋️❤️', AlterEgoPose.clindoeil),
    'room': ChatResponse('Crée une Room Visio pour t\'entraîner avec tes amis en direct ! S\'entraîner avec des amis > Créer une Room. Invite tes buddies ! 📹', AlterEgoPose.felicite),
    'visio': ChatResponse('Les séances en visio permettent de s\'entraîner ensemble à distance. Chrono synchronisé, exercices partagés, motivation collective ! 📹💪', AlterEgoPose.encourage),
    'communauté': ChatResponse('La communauté Ukan c\'est des milliers de sportifs motivés ! Partage tes progrès, découvre des recettes et trouve des buddies ! 🌍', AlterEgoPose.felicite),
    'ami': ChatResponse('Invite tes amis sur Ukan ! Parrainage dans Accueil > Parrainer & Gagner. Vous gagnez tous les deux des récompenses ! 🎁', AlterEgoPose.felicite),
    'parrainage': ChatResponse('Le parrainage te rapporte des récompenses ! Accueil > Parrainer & Gagner. Partage ton code et gagne des mois premium ! 🎁', AlterEgoPose.felicite),
    'match': ChatResponse('Pour matcher : Chat Match > Swipe les profils. À droite si compatible, à gauche sinon. Un match = une discussion ! 💬', AlterEgoPose.clindoeil),
    'swipe': ChatResponse('Swipe à droite pour liker un profil, à gauche pour passer. Si vous likez mutuellement, c\'est un match ! 💕', AlterEgoPose.clindoeil),
    
    // ═══════════════════════════════════════
    // COMPTE & PROFIL
    // ═══════════════════════════════════════
    'profil': ChatResponse('Ton profil contient tes infos, objectifs et préférences. Clique sur l\'avatar en haut à droite pour le modifier ! 👤', AlterEgoPose.reflechit),
    'modifier profil': ChatResponse('Pour modifier ton profil : clique sur ton avatar > Modifier le profil. Tu peux changer ta photo, tes objectifs, ta bio... 📝', AlterEgoPose.reflechit),
    'mot de passe': ChatResponse('Pour changer ton mot de passe : Avancé > Paramètres > Sécurité > Changer le mot de passe. Choisis un mot de passe fort ! 🔐', AlterEgoPose.alerte),
    'supprimer compte': ChatResponse('Pour supprimer ton compte : Avancé > Paramètres > Mon compte > Supprimer le compte. Attention, c\'est irréversible ! ⚠️', AlterEgoPose.alerte),
    'déconnexion': ChatResponse('Pour te déconnecter : Avancé > Paramètres > Déconnexion. Tu pourras te reconnecter quand tu veux ! 👋', AlterEgoPose.salut),
    'photo': ChatResponse('Pour changer ta photo de profil : clique sur ton avatar > Modifier > Photo. Tu peux prendre une photo ou en choisir une ! 📸', AlterEgoPose.reflechit),
    'bio': ChatResponse('Ta bio apparaît sur ton profil public. Décris-toi en quelques mots : objectifs, sports préférés, motivation ! ✍️', AlterEgoPose.reflechit),
    'email': ChatResponse('Pour changer ton email : Avancé > Paramètres > Mon compte > Modifier l\'email. Tu recevras un email de confirmation ! 📧', AlterEgoPose.reflechit),
    
    // ═══════════════════════════════════════
    // PREMIUM & ABONNEMENT
    // ═══════════════════════════════════════
    'premium': ChatResponse('Premium te donne accès à tout : Coach IA illimité, Sport Gaming, FoodScan IA, séances visio, et plus ! Va dans Avancé > Premium. ⭐', AlterEgoPose.felicite),
    'abonnement': ChatResponse('Gère ton abonnement dans Avancé > Mes achats > Gérer l\'abonnement. Tu peux upgrader, downgrader ou annuler. 💳', AlterEgoPose.reflechit),
    'prix': ChatResponse('Les prix varient selon l\'offre : mensuel, trimestriel ou annuel. L\'annuel est le plus avantageux ! Vérifie dans Premium. 💰', AlterEgoPose.reflechit),
    'annuler abonnement': ChatResponse('Pour annuler : Avancé > Mes achats > Gérer l\'abonnement > Annuler. Tu gardes l\'accès jusqu\'à la fin de la période payée. 📅', AlterEgoPose.reflechit),
    'gratuit': ChatResponse('La version gratuite te donne accès aux exercices de base, au suivi des calories et à la communauté. Premium débloque tout ! 🆓', AlterEgoPose.reflechit),
    'payer': ChatResponse('Le paiement est sécurisé par Stripe/Apple Pay/Google Pay. Tes données bancaires sont protégées ! 💳', AlterEgoPose.reflechit),
    'remboursement': ChatResponse('Pour un remboursement, contacte le support dans les 14 jours suivant l\'achat. Avancé > FAQ & Support > Contact ! 💰', AlterEgoPose.reflechit),
    'essai gratuit': ChatResponse('L\'essai gratuit Premium dure 7 jours ! Toutes les fonctionnalités débloquées. Annule avant la fin si tu ne veux pas payer. 🆓', AlterEgoPose.felicite),
    
    // ═══════════════════════════════════════
    // SPORT GAMING
    // ═══════════════════════════════════════
    'gaming': ChatResponse('Sport Gaming transforme ton entraînement en aventure ! Complète des quêtes, bats des boss et gagne des badges. C\'est du fitness gamifié ! 🎮', AlterEgoPose.felicite),
    'xp': ChatResponse('Tu gagnes de l\'XP à chaque exercice, séance ou objectif atteint. Plus tu t\'entraînes, plus tu montes de niveau ! 📈', AlterEgoPose.encourage),
    'niveau': ChatResponse('Ton niveau reflète ta progression. Chaque niveau débloque des récompenses et de nouveaux défis. Continue à t\'entraîner ! 🏆', AlterEgoPose.felicite),
    'badge': ChatResponse('Les badges récompensent tes accomplissements : premier entraînement, série de 7 jours, boss battu... Collectionne-les tous ! 🏅', AlterEgoPose.applaudit),
    'boss': ChatResponse('Les boss sont des défis spéciaux ! Complète un certain nombre de répétitions d\'un exercice pour les vaincre. Bonne chance ! 👊', AlterEgoPose.encourage),
    'quête': ChatResponse('Les quêtes quotidiennes te donnent des objectifs à atteindre chaque jour. Complète-les pour gagner de l\'XP bonus ! 📜', AlterEgoPose.reflechit),
    'défi': ChatResponse('Les défis de la semaine sont affichés sur ton dashboard. Relève-les pour gagner des récompenses spéciales ! 🎯', AlterEgoPose.encourage),
    'récompense': ChatResponse('Les récompenses s\'obtiennent en complétant des quêtes, en battant des boss et en montant de niveau. Collectionne-les ! 🎁', AlterEgoPose.felicite),
    'classement': ChatResponse('Le classement te compare aux autres utilisateurs. Grimpe les échelons en gagnant de l\'XP et en complétant des défis ! 🏆', AlterEgoPose.encourage),
    'avatar gaming': ChatResponse('Ton avatar gaming évolue avec ton niveau ! Débloque des équipements, accessoires et looks en progressant ! 🎮', AlterEgoPose.felicite),
    'mission': ChatResponse('Les missions sont des objectifs à long terme. Complète-les pour débloquer des récompenses exclusives ! 🎯', AlterEgoPose.encourage),
    'chapitre': ChatResponse('Les chapitres racontent ton aventure fitness ! Chaque chapitre a des missions et un boss final à battre ! 📖', AlterEgoPose.felicite),
    
    // ═══════════════════════════════════════
    // COACH & COACHS
    // ═══════════════════════════════════════
    'coach': ChatResponse('Trouve un coach dans l\'onglet Rechercher. Filtre par spécialité, prix et disponibilité. Réserve une séance en quelques clics ! 👨‍🏫', AlterEgoPose.reflechit),
    'réserver séance': ChatResponse('Pour réserver : Rechercher > Coachs > Choisir un coach > Réserver. Sélectionne la date et l\'heure qui te conviennent ! 📅', AlterEgoPose.reflechit),
    'coach ia': ChatResponse('Le Coach IA t\'accompagne avec des conseils personnalisés, des programmes adaptés et de la motivation. C\'est moi, en version pro ! 🤖', AlterEgoPose.clindoeil),
    'personnalité coach': ChatResponse('Tu peux choisir la personnalité de ton coach IA : motivant, strict, humoristique... Va dans Avancé > Personnalité du Coach ! 🎭', AlterEgoPose.clindoeil),
    'devenir coach': ChatResponse('Tu veux devenir coach sur Ukan ? Postule dans Avancé > Devenir Coach. On vérifie tes certifications et c\'est parti ! 🎓', AlterEgoPose.felicite),
    
    // ═══════════════════════════════════════
    // STATISTIQUES & PROGRESSION
    // ═══════════════════════════════════════
    'statistiques': ChatResponse('Tes stats sont sur le dashboard : calories, pas, séances, progression... Clique sur "Voir mes statistiques" pour plus de détails ! 📊', AlterEgoPose.reflechit),
    'progression': ChatResponse('Ta progression est mesurée par tes séances complétées, tes objectifs atteints et ton niveau de Sport Gaming. Tu progresses chaque jour ! 📈', AlterEgoPose.felicite),
    'historique': ChatResponse('Ton historique de séances est dans Séances > Historique. Tu peux voir toutes tes séances passées et tes performances ! 📋', AlterEgoPose.reflechit),
    'objectif': ChatResponse('Définis tes objectifs dans ton profil. Perte de poids, prise de muscle, endurance... L\'app s\'adapte à toi ! 🎯', AlterEgoPose.reflechit),
    'pas': ChatResponse('Tes pas sont comptés automatiquement ! Vise 10 000 pas par jour pour rester actif. Regarde ton dashboard ! 👣', AlterEgoPose.encourage),
    'podomètre': ChatResponse('Le podomètre compte tes pas en arrière-plan. Active-le dans Paramètres > Activité > Compteur de pas ! 👣', AlterEgoPose.reflechit),
    'streak': ChatResponse('Ta streak compte tes jours consécutifs d\'entraînement. Ne la casse pas ! Chaque jour compte ! 🔥', AlterEgoPose.encourage),
    'record': ChatResponse('Tes records personnels sont enregistrés ! Poids max, temps, répétitions... Bats-les pour progresser ! 🏆', AlterEgoPose.felicite),
    
    // ═══════════════════════════════════════
    // AIDE & SUPPORT (ENRICHI)
    // ═══════════════════════════════════════
    'aide': ChatResponse('Je suis là pour t\'aider ! Pose-moi n\'importe quelle question sur Ukan. Tu peux aussi aller dans Avancé > FAQ & Support. 🆘', AlterEgoPose.salut),
    'problème': ChatResponse('Un problème ? Décris-le moi et je t\'aide ! Sinon, va dans Avancé > FAQ & Support > Formulaire de contact. On répond sous 24h ! 📩', AlterEgoPose.reflechit),
    'bug': ChatResponse('Tu as trouvé un bug ? Signale-le dans Avancé > FAQ & Support > Signaler un bug. Merci de nous aider à améliorer l\'app ! 🐛', AlterEgoPose.alerte),
    'contact': ChatResponse('Pour nous contacter : Avancé > FAQ & Support > Formulaire de contact. Email, chat ou téléphone, on est là pour toi ! 📞', AlterEgoPose.salut),
    'faq': ChatResponse('La FAQ répond aux questions fréquentes. Va dans Avancé > FAQ & Support ou pose-moi directement ta question ! ❓', AlterEgoPose.reflechit),
    'support': ChatResponse('Le support est disponible 7j/7 ! Avancé > FAQ & Support > Contact. On répond généralement sous 24h ! 📩', AlterEgoPose.salut),
    'question': ChatResponse('Pose-moi ta question ! Je connais Ukan par cœur et je suis là pour t\'aider ! 💬', AlterEgoPose.salut),
    'comment': ChatResponse('Dis-moi ce que tu veux faire et je t\'explique comment ! Navigation, exercices, nutrition... Je sais tout ! 💡', AlterEgoPose.reflechit),
    'où': ChatResponse('Dis-moi ce que tu cherches et je te guide ! Je connais chaque recoin de l\'application ! 🗺️', AlterEgoPose.reflechit),
    'pourquoi': ChatResponse('Bonne question ! Explique-moi le contexte et je t\'éclaire ! 💡', AlterEgoPose.reflechit),
    'marche pas': ChatResponse('Quelque chose ne marche pas ? Décris-moi le problème : quelle page, quel bouton, quel message d\'erreur ? 🔧', AlterEgoPose.alerte),
    'erreur': ChatResponse('Une erreur ? Note le message exact et contacte le support : Avancé > FAQ & Support > Signaler un bug ! 🐛', AlterEgoPose.alerte),
    'bloqué': ChatResponse('Tu es bloqué ? Dis-moi où exactement et je te débloquerai ! Je suis là pour ça ! 🔓', AlterEgoPose.encourage),
    'tutoriel': ChatResponse('Les tutoriels sont dans Avancé > Tutoriels. Tu peux aussi me demander directement comment faire quelque chose ! 📚', AlterEgoPose.reflechit),
    'guide': ChatResponse('Je suis ton guide ! Pose-moi n\'importe quelle question sur l\'app, les exercices, la nutrition... 📖', AlterEgoPose.salut),
    
    // ═══════════════════════════════════════
    // MOTIVATION & BIEN-ÊTRE (ENRICHI)
    // ═══════════════════════════════════════
    'motivation': ChatResponse('La motivation vient de l\'action ! Chaque petit pas compte. Tu es plus fort que tu ne le penses ! 💪✨', AlterEgoPose.encourage),
    'motiver': ChatResponse('Rappelle-toi pourquoi tu as commencé ! Tu as déjà fait le plus dur : commencer. Continue ! 💪', AlterEgoPose.applaudit),
    'difficile': ChatResponse('Je comprends, ce n\'est pas facile. Mais chaque jour tu deviens plus fort. Ne lâche pas ! 💪', AlterEgoPose.encourage),
    'fatigué': ChatResponse('C\'est normal d\'être fatigué parfois. Écoute ton corps, repose-toi si besoin. Demain tu seras plus fort ! 😴', AlterEgoPose.repose),
    'repos': ChatResponse('Le repos fait partie de l\'entraînement ! Tes muscles se construisent pendant le repos. Accorde-toi 1-2 jours off par semaine. 😴', AlterEgoPose.repose),
    'stress': ChatResponse('Le sport réduit le stress ! Une bonne séance libère des endorphines. Tu te sentiras mieux après, promis ! 🧘', AlterEgoPose.encourage),
    'abandon': ChatResponse('Ne lâche pas ! Les résultats prennent du temps. Chaque séance compte, même les plus difficiles. Tu peux le faire ! 💪', AlterEgoPose.encourage),
    'décourager': ChatResponse('Ne te décourage pas ! Les progrès sont parfois invisibles mais réels. Fais confiance au processus ! 💪', AlterEgoPose.encourage),
    'pas envie': ChatResponse('Pas envie aujourd\'hui ? Fais juste 10 minutes. Souvent, une fois lancé, tu continues ! Et sinon, repose-toi ! 😊', AlterEgoPose.clindoeil),
    'flemme': ChatResponse('La flemme, ça arrive ! Rappelle-toi comment tu te sens APRÈS une séance. Ça vaut le coup ! 💪', AlterEgoPose.encourage),
    'dormir': ChatResponse('Le sommeil est crucial ! 7-8h par nuit pour une bonne récupération. Tes muscles se reconstruisent pendant que tu dors ! 😴', AlterEgoPose.repose),
    'sommeil': ChatResponse('Un bon sommeil = meilleure récupération, plus d\'énergie, moins de stress. Couche-toi à heures régulières ! 😴', AlterEgoPose.repose),
    'bien joué': ChatResponse('Merci ! Mais c\'est toi qui fais tout le travail ! Continue comme ça, tu es sur la bonne voie ! 🏆', AlterEgoPose.applaudit),
    'fier': ChatResponse('Tu peux être fier de toi ! Chaque effort compte. Continue à te dépasser ! 💪✨', AlterEgoPose.felicite),
    'content': ChatResponse('Super ! Ta bonne humeur est contagieuse ! Profite de cette énergie pour t\'entraîner ! 😄', AlterEgoPose.felicite),
    'triste': ChatResponse('Le sport peut aider quand ça ne va pas. Les endorphines améliorent l\'humeur. Essaie une petite séance ! 💙', AlterEgoPose.encourage),
    'anxieux': ChatResponse('L\'exercice réduit l\'anxiété ! Respire profondément, fais une séance légère. Tu vas te sentir mieux ! 🧘', AlterEgoPose.repose),
    
    // ═══════════════════════════════════════
    // FÉLICITATIONS & FIN
    // ═══════════════════════════════════════
    'merci': ChatResponse('De rien ! Je suis toujours là pour t\'aider. Continue comme ça ! 💪✨', AlterEgoPose.felicite),
    'réussi': ChatResponse('Bravo ! Tu es incroyable ! Chaque réussite te rapproche de tes objectifs. Continue ! 🎉', AlterEgoPose.applaudit),
    'bravo': ChatResponse('Merci ! Mais c\'est toi le champion ! Continue sur cette lancée ! 🏆', AlterEgoPose.applaudit),
    'au revoir': ChatResponse('À bientôt ! N\'oublie pas : chaque jour compte ! 💪', AlterEgoPose.salut),
    'bye': ChatResponse('Bye ! Reviens quand tu veux, je suis toujours là ! 👋', AlterEgoPose.salut),
    'fin': ChatResponse('D\'accord ! N\'hésite pas si tu as besoin de moi. Bon courage ! 💪', AlterEgoPose.neutre),
    'super': ChatResponse('Super ! Content que tu sois motivé ! On continue ensemble ! 💪🔥', AlterEgoPose.felicite),
    'génial': ChatResponse('Génial ! Ton enthousiasme fait plaisir à voir ! Garde cette énergie ! 🔥', AlterEgoPose.applaudit),
    'cool': ChatResponse('Cool ! Tu gères ! Continue comme ça ! 😎', AlterEgoPose.clindoeil),
    'ok': ChatResponse('OK ! Si tu as d\'autres questions, je suis là ! 👍', AlterEgoPose.neutre),
    'oui': ChatResponse('Parfait ! On continue alors ! 💪', AlterEgoPose.felicite),
    'non': ChatResponse('Pas de souci ! Dis-moi ce dont tu as besoin ! 👍', AlterEgoPose.neutre),
    'd\'accord': ChatResponse('Super ! N\'hésite pas si tu as besoin d\'autre chose ! 👍', AlterEgoPose.salut),
    
    // ═══════════════════════════════════════
    // EXPRESSIONS COURANTES
    // ═══════════════════════════════════════
    'quoi de neuf': ChatResponse('Plein de nouveautés sur Ukan ! Nouveaux exercices, fonctionnalités, défis... Explore l\'app ! 🆕', AlterEgoPose.felicite),
    'ça va': ChatResponse('Super bien, merci ! Et toi, prêt à te dépasser ? 💪', AlterEgoPose.salut),
    'comment ça va': ChatResponse('Je vais très bien ! Je suis là pour t\'aider à atteindre tes objectifs ! 💪', AlterEgoPose.felicite),
    'tu fais quoi': ChatResponse('Je t\'accompagne dans ton parcours fitness ! Pose-moi n\'importe quelle question ! 🎯', AlterEgoPose.salut),
    'c\'est quoi': ChatResponse('Dis-moi de quoi tu parles et je t\'explique tout ! 💡', AlterEgoPose.reflechit),
    'comment faire': ChatResponse('Dis-moi ce que tu veux faire et je te guide étape par étape ! 📝', AlterEgoPose.reflechit),
    'je comprends pas': ChatResponse('Pas de souci, je t\'explique ! Dis-moi ce qui n\'est pas clair ! 💡', AlterEgoPose.reflechit),
    'j\'ai besoin': ChatResponse('Je t\'écoute ! De quoi as-tu besoin ? 👂', AlterEgoPose.reflechit),
    'je veux': ChatResponse('OK ! Dis-moi ce que tu veux et je t\'aide à l\'obtenir ! 🎯', AlterEgoPose.encourage),
    'je cherche': ChatResponse('Je t\'aide à trouver ! Qu\'est-ce que tu cherches exactement ? 🔍', AlterEgoPose.reflechit),
  };

  // Getters
  AlterEgoPose get currentPose => _currentPose;
  String get currentMessage => _currentMessage;
  AlterEgoPosition get currentPosition => _currentPosition;
  bool get isVisible => _isVisible;
  bool get isMessageVisible => _isMessageVisible;
  bool get isChatActive => _isChatActive;
  bool get showChatInterface => _showChatInterface;
  List<ChatMessage> get conversationHistory => List.unmodifiable(_conversationHistory);
  String? get currentContextImage => _currentContextImage;
  
  /// Définit la page actuelle pour le contexte
  void setCurrentPage(UkanPage? page) {
    _contextService.setCurrentPage(page);
    _updateContextImage();
  }
  
  /// Démarre une conversation avec le message guide de la page actuelle
  /// Cette méthode est appelée automatiquement quand on change de page
  void startConversationWithGuideMessage() {
    // Si le chat est déjà actif, on ne fait rien (pour ne pas interrompre l'utilisateur)
    if (_isChatActive) {
      return;
    }
    
    // Sinon, on démarre la conversation avec le message guide
    startConversation();
  }
  
  /// Met à jour l'image contextuelle
  void _updateContextImage() {
    _currentContextImage = _contextService.getCurrentImage();
    notifyListeners();
  }
  
  // Couleurs pour la bulle iMessage
  Color get backgroundColor => const Color(0xFF0B1020); // Fond de la bulle
  Color get textColor => Colors.white; // Couleur du texte

  /// Retourne le chemin de l'image pour une pose donnée (Mascotte Kangourou Ukan)
  static String getImagePath(AlterEgoPose pose) {
    // Mapping des poses vers les images de la mascotte kangourou
    switch (pose) {
      case AlterEgoPose.neutre:
        return 'assets/images/mascotte_neutre.png';
      case AlterEgoPose.salut:
        return 'assets/images/mascotte_salut.png';
      case AlterEgoPose.felicite:
        return 'assets/images/mascotte_victoire.png';
      case AlterEgoPose.encourage:
        return 'assets/images/mascotte_motivation.png';
      case AlterEgoPose.reflechit:
        return 'assets/images/mascotte_reflexion.png';
      case AlterEgoPose.alerte:
        return 'assets/images/mascotte_energie.png';
      case AlterEgoPose.repose:
        return 'assets/images/mascotte_conseil.png';
      case AlterEgoPose.applaudit:
        return 'assets/images/mascotte_sport.png';
      case AlterEgoPose.clindoeil:
        return 'assets/images/mascotte_exercice.png';
    }
  }

  /// Initialise le TTS
  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(0.8);
      _ttsInitialized = true;
    } catch (e) {
      debugPrint('Erreur initialisation TTS: $e');
      // Continuer même si TTS échoue
      _ttsInitialized = false;
    }
  }

  /// Met à jour la pose de l'Alter Ego
  void setPose(AlterEgoPose pose) {
    if (_currentPose != pose) {
      _currentPose = pose;
      notifyListeners();
    }
  }

  /// Affiche un message et le lit avec TTS
  Future<void> showMessage(String message, {AlterEgoPose? pose}) async {
    if (pose != null) {
      setPose(pose);
    }
    _currentMessage = message;
    _isMessageVisible = true;
    notifyListeners();

    // Lire le message avec TTS
    if (_ttsInitialized && message.isNotEmpty) {
      try {
        await _tts.stop(); // Arrêter tout message en cours
        await _tts.speak(message);
      } catch (e) {
        debugPrint('Erreur TTS: $e');
        // Continuer même si TTS échoue
      }
    }
  }

  /// Masque le message (mais garde le Bitmoji visible)
  void hideMessage() {
    if (_isMessageVisible) {
      _isMessageVisible = false;
      _currentMessage = '';
      notifyListeners();
    }
  }

  /// Change la position de l'Alter Ego
  void setPosition(AlterEgoPosition position) {
    if (_currentPosition != position) {
      _currentPosition = position;
      notifyListeners();
    }
  }

  /// Affiche ou masque complètement l'Alter Ego
  void setVisible(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      if (!visible) {
        _isMessageVisible = false;
        _currentMessage = '';
      }
      notifyListeners();
    }
  }

  /// Méthode de commodité pour déplacer l'Alter Ego vers une position avec un message
  Future<void> moveToPosition(
    AlterEgoPosition position, {
    String? message,
    AlterEgoPose? pose,
  }) async {
    setPosition(position);
    if (message != null) {
      await showMessage(message, pose: pose);
    }
  }

  /// Démarre une conversation (affiche le Bitmoji dans le chat)
  void startConversation() {
    if (!_isChatActive) {
      _isChatActive = true;
      _showChatInterface = true;
      _conversationHistory.clear();
      setVisible(true);
      setPose(AlterEgoPose.salut);
      
      // Notifier immédiatement pour afficher l'interface rapidement
      notifyListeners();
      
      // Afficher le message GUIDE si disponible (après le premier notifyListeners pour réactivité)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final guideMessage = _contextService.getGuideMessage();
        if (guideMessage != null) {
          _conversationHistory.add(ChatMessage(
            text: guideMessage,
            isUser: false,
            timestamp: DateTime.now(),
            intent: AlterEgoIntent.system,
            imageAsset: _contextService.getContextImage(),
          ));
        } else {
          // Message par défaut
          _conversationHistory.add(ChatMessage(
            text: 'Salut ! Je suis ton Alter Ego.\nComment puis-je t\'aider ? 💪',
            isUser: false,
            timestamp: DateTime.now(),
            intent: AlterEgoIntent.system,
            imageAsset: _contextService.getCurrentImage(),
          ));
        }
        
        _updateContextImage();
        notifyListeners();
      });
    }
  }
  
  /// Affiche ou masque l'interface de chat
  void toggleChatInterface() {
    if (_isChatActive) {
      _showChatInterface = !_showChatInterface;
      notifyListeners();
    }
  }
  
  /// Force l'affichage de l'interface de chat
  void forceShowChatInterface() {
    if (_isChatActive && !_showChatInterface) {
      _showChatInterface = true;
      notifyListeners();
    }
  }
  
  /// Force le masquage de l'interface de chat
  void hideChatInterface() {
    if (_showChatInterface) {
      _showChatInterface = false;
      notifyListeners();
    }
  }

  /// Envoie un message au chatbot et obtient une réponse
  Future<void> sendMessage(String userMessage) async {
    if (!_isChatActive) {
      startConversation();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Ajouter le message de l'utilisateur à l'historique
    _conversationHistory.add(ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    notifyListeners();

    // Activer l'indicateur "en train d'écrire"
    _isMessageVisible = true;
    setPose(AlterEgoPose.reflechit);
    notifyListeners();
    
    // Attendre un peu pour l'effet de réflexion
    await Future.delayed(const Duration(milliseconds: 1200));

    // Trouver une réponse appropriée
    final response = _findResponse(userMessage);

    // Détecter l'intent du message
    final intent = _contextService.detectIntent(userMessage);
    _updateContextImage();
    
    // Ajouter la réponse à l'historique avec l'intent et l'image
    _conversationHistory.add(ChatMessage(
      text: response.message,
      isUser: false,
      timestamp: DateTime.now(),
      intent: intent,
      imageAsset: _contextService.getCurrentImage(),
    ));

    // Changer la pose et notifier (le message est dans l'historique du chat)
    setPose(response.pose);
    _isMessageVisible = false; // Arrêter l'animation "en train d'écrire"
    notifyListeners();

    // Lire le message avec TTS
    if (_ttsInitialized && response.message.isNotEmpty) {
      try {
        await _tts.stop();
        await _tts.speak(response.message);
      } catch (e) {
        debugPrint('Erreur TTS: $e');
      }
    }

    // Vérifier si la conversation doit se terminer
    if (_shouldEndConversation(userMessage)) {
      await Future.delayed(const Duration(seconds: 3));
      endConversation();
    }
  }

  /// Trouve une réponse appropriée pour un message utilisateur
  ChatResponse _findResponse(String message) {
    final lowerMessage = message.toLowerCase().trim();
    
    // Détecter l'intent
    final intent = _contextService.detectIntent(message);
    
    // Réponses contextuelles selon l'intent
    final intentResponse = _getIntentResponse(intent, lowerMessage);
    if (intentResponse != null) {
      return intentResponse;
    }

    // Rechercher un pattern correspondant dans les réponses de base
    for (final entry in _responsePatterns.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    // Réponses génériques par défaut
    if (lowerMessage.length < 3) {
      return ChatResponse(
        'Peux-tu être plus précis ? Je peux t\'aider avec tes objectifs, la nutrition, les exercices... 🤔',
        AlterEgoPose.reflechit,
      );
    }

    // Réponses aléatoires pour les messages non reconnus
    final defaultResponses = [
      ChatResponse(
        'Intéressant ! Peux-tu me donner plus de détails ? Je suis là pour t\'aider ! 💪',
        AlterEgoPose.reflechit,
      ),
      ChatResponse(
        'Je comprends. Comment puis-je t\'aider avec ça ? 🤔',
        AlterEgoPose.reflechit,
      ),
      ChatResponse(
        'D\'accord ! Parle-moi de tes objectifs fitness, je peux t\'accompagner ! 🎯',
        AlterEgoPose.encourage,
      ),
      ChatResponse(
        'Je suis là pour toi ! Que veux-tu travailler aujourd\'hui ? 💪',
        AlterEgoPose.salut,
      ),
    ];

    return defaultResponses[lowerMessage.hashCode % defaultResponses.length];
  }
  
  /// Récupère une réponse selon l'intent détecté
  ChatResponse? _getIntentResponse(AlterEgoIntent intent, String lowerMessage) {
    switch (intent) {
      case AlterEgoIntent.motivation:
        return _getMotivationResponse(lowerMessage);
      case AlterEgoIntent.entrainement:
        return _getEntrainementResponse(lowerMessage);
      case AlterEgoIntent.nutrition:
        return _getNutritionResponse(lowerMessage);
      case AlterEgoIntent.sommeil:
        return _getSommeilResponse(lowerMessage);
      case AlterEgoIntent.hydratation:
        return _getHydratationResponse(lowerMessage);
      case AlterEgoIntent.blessure:
        return _getBlessureResponse(lowerMessage);
      case AlterEgoIntent.system:
        // Mode guide - utiliser les données fictives si demandé
        if (lowerMessage.contains('stat') || lowerMessage.contains('donnée') || lowerMessage.contains('progression')) {
          return _getAssistantDataResponse();
        }
        return null; // Utiliser les réponses par défaut
    }
  }
  
  /// Réponses pour l'intent motivation
  ChatResponse _getMotivationResponse(String lowerMessage) {
    if (lowerMessage.contains('pas envie') || lowerMessage.contains('découragé')) {
      return ChatResponse(
        'Je comprends, c\'est normal d\'avoir des moments difficiles. Mais rappelle-toi : chaque jour où tu agis, tu progresses. Même un petit pas compte ! 💪✨',
        AlterEgoPose.encourage,
      );
    }
    if (lowerMessage.contains('maigrir') || lowerMessage.contains('perdre')) {
      return ChatResponse(
        'Super objectif ! La clé c\'est la régularité. Combine une alimentation équilibrée avec de l\'exercice régulier. Tu peux y arriver ! 🎯',
        AlterEgoPose.felicite,
      );
    }
    return ChatResponse(
      'La motivation vient de l\'action ! Chaque petit pas compte. Tu es plus fort que tu ne le penses ! 💪✨',
      AlterEgoPose.encourage,
    );
  }
  
  /// Réponses pour l'intent entrainement
  ChatResponse _getEntrainementResponse(String lowerMessage) {
    if (lowerMessage.contains('squat') || lowerMessage.contains('pompe')) {
      return ChatResponse(
        'Excellent choix ! Les exercices au poids du corps sont parfaits pour commencer. Veux-tu que je te guide pour bien les exécuter ? 🏋️',
        AlterEgoPose.encourage,
      );
    }
    if (lowerMessage.contains('room') || lowerMessage.contains('groupe')) {
      return ChatResponse(
        'S\'entraîner en groupe, c\'est motivant ! Tu peux créer une room et inviter tes amis. C\'est plus fun ensemble ! 👥',
        AlterEgoPose.felicite,
      );
    }
    return ChatResponse(
      'Super ! Un bon entraînement régulier fait la différence. Prêt à commencer ? 💪',
      AlterEgoPose.encourage,
    );
  }
  
  /// Réponses pour l'intent nutrition
  ChatResponse _getNutritionResponse(String lowerMessage) {
    if (lowerMessage.contains('recette')) {
      return ChatResponse(
        'Tu veux une recette perte de poids, prise de masse ou équilibrée ? Je peux te proposer des idées adaptées à tes objectifs ! 👨‍🍳',
        AlterEgoPose.reflechit,
      );
    }
    if (lowerMessage.contains('calories') || lowerMessage.contains('protéines')) {
      return ChatResponse(
        'La nutrition, c\'est 70% du succès ! Suis tes macros et reste dans tes objectifs caloriques. Je peux t\'aider à équilibrer tes repas ! 🥗',
        AlterEgoPose.reflechit,
      );
    }
    return ChatResponse(
      'La nutrition, c\'est essentiel ! Veux-tu que je t\'aide avec ton alimentation ? 🥗',
      AlterEgoPose.reflechit,
    );
  }
  
  /// Réponses pour l'intent sommeil
  ChatResponse _getSommeilResponse(String lowerMessage) {
    return ChatResponse(
      'Un bon sommeil est crucial pour la récupération ! Essaie de dormir 7-9h par nuit. Évite les écrans avant de te coucher. 😴',
      AlterEgoPose.repose,
    );
  }
  
  /// Réponses pour l'intent hydratation
  ChatResponse _getHydratationResponse(String lowerMessage) {
    // Utiliser les données fictives
    final waterLiters = 1.4;
    final waterGoal = 2.0;
    final remaining = waterGoal - waterLiters;
    
    if (remaining > 0) {
      return ChatResponse(
        'Ton hydratation est basse aujourd\'hui ! Tu as bu ${waterLiters}L sur ${waterGoal}L. Il te reste ${remaining.toStringAsFixed(1)}L à boire. Bois un peu d\'eau ! 💧',
        AlterEgoPose.alerte,
      );
    }
    return ChatResponse(
      'Super ! Tu es bien hydraté. Continue comme ça ! 💧',
      AlterEgoPose.felicite,
    );
  }
  
  /// Réponses pour l'intent blessure
  ChatResponse _getBlessureResponse(String lowerMessage) {
    return ChatResponse(
      'Je ne peux pas te donner de diagnostic médical. Si tu as une douleur, je te recommande de consulter un professionnel de santé. Tu peux enregistrer ta blessure dans le Carnet Santé & Blessures pour suivre son évolution. Prends soin de toi ! 🏥',
      AlterEgoPose.alerte,
    );
  }
  
  /// Réponses pour l'assistant data (mode démo avec données fictives)
  ChatResponse _getAssistantDataResponse() {
    // Données fictives en démo
    final steps = 6245;
    final stepsGoal = 8000;
    final stepsRemaining = stepsGoal - steps;
    final calories = 1850;
    final caloriesGoal = 1800;
    final waterLiters = 1.4;
    final waterGoal = 2.0;
    final workoutsDone = 2;
    
    String message = 'Voici ton état du jour :\n\n';
    
    if (stepsRemaining > 0) {
      message += '👟 Pas : $steps / $stepsGoal (il manque $stepsRemaining pas)\n';
    } else {
      message += '👟 Pas : $steps / $stepsGoal ✅\n';
    }
    
    if (calories > caloriesGoal) {
      message += '🍽️ Calories : $calories / $caloriesGoal (dépassement de ${calories - caloriesGoal} kcal)\n';
    } else {
      message += '🍽️ Calories : $calories / $caloriesGoal ✅\n';
    }
    
    if (waterLiters < waterGoal) {
      final remaining = waterGoal - waterLiters;
      message += '💧 Eau : ${waterLiters}L / ${waterGoal}L (il reste ${remaining.toStringAsFixed(1)}L)\n';
    } else {
      message += '💧 Eau : ${waterLiters}L / ${waterGoal}L ✅\n';
    }
    
    message += '💪 Séances : $workoutsDone réalisées aujourd\'hui\n\n';
    message += 'Continue comme ça ! 💪';
    
    return ChatResponse(message, AlterEgoPose.reflechit);
  }

  /// Détermine si la conversation doit se terminer
  bool _shouldEndConversation(String message) {
    final lowerMessage = message.toLowerCase().trim();
    final endKeywords = ['au revoir', 'bye', 'à bientôt', 'fin', 'terminer', 'merci'];

    return endKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Termine la conversation (cache le Bitmoji)
  Future<void> endConversation() async {
    if (_isChatActive) {
      _isChatActive = false;
      _showChatInterface = false;
      _isMessageVisible = false;
      _currentMessage = '';
      await Future.delayed(const Duration(milliseconds: 500));
      setVisible(false);
      _conversationHistory.clear();
      setPose(AlterEgoPose.neutre);
      notifyListeners();
    }
  }

  /// Dispose les ressources
  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

/// Modèle pour un message de chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AlterEgoIntent? intent;
  final String? imageAsset;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.imageAsset,
  });
}

/// Modèle pour une réponse du chatbot
class ChatResponse {
  final String message;
  final AlterEgoPose pose;

  ChatResponse(this.message, this.pose);
}
