# 🎤 Guide : Comment utiliser le Coach Vocal IA

## ✅ Étapes pour tester le coach

### **Étape 1 : Sélectionner un coach**

1. **Clique sur l'icône profil** (personne) en haut à droite de l'app
2. **Fais défiler vers le bas** jusqu'à la carte **"Coach Vocal IA"** (noire avec microphone jaune)
3. **Clique sur la carte** → Page de sélection s'ouvre
4. **Choisis un coach** (ex: "Coach Emma")
5. **Clique sur "Sélectionner"** → Le coach est maintenant ton coach !

### **Étape 2 : Démarrer une séance**

1. **Va dans l'onglet "Séances"** (icône fitness en bas)
2. **Clique sur un programme** (ex: "Full body – Niveau intermédiaire")
3. **Clique sur "Démarrer la séance"** en bas de la page

### **Étape 3 : Activer le coach pendant l'exercice**

1. **Dans la page de séance**, regarde en haut à droite → **icône microphone** 🔴
2. **Si l'icône est grise** → Clique dessus pour activer le coach (devient jaune)
3. **Si l'icône est jaune** → Le coach est déjà activé ✅

### **Étape 4 : Voir le coach en action**

**Pendant l'exercice, tu verras :**

1. **Carte Coach IA** (juste en dessous de l'étape) :
   - Nom du coach (ex: "Coach Emma")
   - Badge "En direct" vert
   - Dernière phrase affichée en temps réel
   - Bouton volume pour activer/désactiver

2. **Bulle vocale en haut** (toutes les 15 secondes) :
   - Grande bulle noire avec bordure colorée
   - Icône du coach + nom
   - Nouvelle phrase motivante
   - Auto-dismiss après 5 secondes

3. **Point rouge** sur l'icône microphone = Coach actif + Timer en cours

4. **Icône microphone** dans le bouton "Pause" = Coach actif

### **Exemple de phrases selon le progrès :**

- **Début (0-20%)** : "On y va doucement, tu vas y arriver."
- **Milieu (20-70%)** : "Tu es en plein dedans, c'est très bien."
- **Presque fini (70-95%)** : "Tu es presque au bout, je suis avec toi."
- **Fin (95-100%)** : "Bravo ! Tu viens de te dépasser."

---

## ❓ Si tu ne vois pas le coach

### **Problème 1 : Pas d'icône microphone dans la séance**
→ **Solution** : Le fichier `workout_session_page.dart` n'est peut-être pas à jour. Vérifie que les imports sont présents.

### **Problème 2 : Le coach ne parle pas**
→ **Solution** : 
1. Assure-toi d'avoir sélectionné un coach (étape 1)
2. Clique sur l'icône microphone pour l'activer (devient jaune)
3. Clique sur "Démarrer" pour lancer le timer

### **Problème 3 : Pas de carte Coach IA visible**
→ **Solution** : 
- La carte apparaît seulement si :
  - ✅ Coach sélectionné ET activé
  - ✅ Pas en phase de repos
  - ✅ Exercice avec timer (pas d'exercice sans durée)

---

## 🔍 Vérification rapide

**Pour vérifier que tout fonctionne :**

1. ✅ Va dans Profil → Tu dois voir "Coach Vocal IA"
2. ✅ Clique dessus → Page avec 4 coaches doit s'ouvrir
3. ✅ Sélectionne un coach → Retour au profil
4. ✅ Va dans Séances → Lance une séance
5. ✅ Dans la page de séance → Icône microphone en haut à droite
6. ✅ Clique sur le microphone → Devient jaune
7. ✅ Clique sur "Démarrer" → Timer démarre
8. ✅ Tu dois voir :
   - Carte Coach IA avec nom et phrase
   - Bulle vocale en haut après ~15 secondes

---

## 📝 Fichiers créés

- ✅ `lib/coach_personality/coach_personality_model.dart`
- ✅ `lib/coach_personality/coach_personality_notifier.dart`
- ✅ `lib/coach_personality/coach_personality_page.dart`
- ✅ `lib/widgets/coach_voice_bubble.dart`
- ✅ `lib/workout_session_page.dart` (modifié)

Si tu as un problème spécifique, dis-moi lequel et je le corrige ! 🔧







