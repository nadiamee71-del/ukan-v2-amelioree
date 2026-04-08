# 🔧 Dépannage : Coach Vocal IA ne s'affiche pas

## ✅ Vérification rapide

### **1. As-tu sélectionné un coach ?**

**Dans le Profil :**
1. Va dans **Profil** (icône personne en haut à droite)
2. Fais défiler jusqu'à **"Coach Vocal IA"** (carte noire avec microphone jaune)
3. Clique dessus → Page avec 4 coaches s'ouvre
4. Choisis un coach (ex: "Coach Emma")
5. Clique sur **"Sélectionner"** → Une notification verte apparaît : "Coach Emma est maintenant ton coach!"

**Si tu ne vois pas la carte "Coach Vocal IA" dans le profil :**
- Le fichier `lib/main.dart` n'est peut-être pas à jour
- Fais un **hot reload** (Ctrl+Shift+F5) ou **redémarre l'app** (flutter run)

---

### **2. As-tu lancé une séance d'exercice ?**

**Pour voir le coach en action :**

1. **Va dans "Séances"** (onglet du bas, icône fitness)
2. **Clique sur un programme** (ex: "Full body – Niveau intermédiaire")
3. **Clique sur "Démarrer la séance"** (bouton noir en bas)
4. **Dans la page de séance** → Regarde en **haut à droite** :
   - Tu dois voir une **icône microphone** 🎤
   - **Grise** = Coach désactivé
   - **Jaune** = Coach activé

---

### **3. As-tu activé le coach pendant la séance ?**

**Actions à faire :**

1. **Clique sur l'icône microphone** en haut à droite (devient jaune ✅)
2. **Clique sur "Démarrer"** en bas pour lancer le timer
3. **Tu dois maintenant voir :**
   - ✅ **Carte Coach IA** (sous le titre de l'étape) :
     - Nom du coach (ex: "Coach Emma")
     - Badge "En direct" vert
     - Dernière phrase affichée
   - ✅ **Bulle vocale en haut** (toutes les 15 secondes) :
     - Grande bulle noire avec phrase motivante
     - Apparaît automatiquement et disparaît après 5 secondes
   - ✅ **Point rouge** sur l'icône microphone = Coach actif + timer en cours

---

## ❌ Problèmes courants

### **Problème 1 : Pas d'icône microphone dans la séance**

**Solution :**
- Vérifie que `lib/workout_session_page.dart` contient bien le code du coach (lignes 365-397)
- Fais un **hot restart** (Ctrl+Shift+F5 dans le terminal ou redémarre flutter run)

### **Problème 2 : Le coach ne parle pas**

**Vérifications :**
1. ✅ As-tu sélectionné un coach dans le profil ? (étape 1)
2. ✅ As-tu activé le coach (icône microphone jaune) ?
3. ✅ As-tu cliqué sur "Démarrer" pour lancer le timer ?

**Si oui à tout :**
- Le coach parle toutes les **15 secondes**
- Les phrases changent selon le **progrès** de l'exercice :
  - **Début (0-20%)** : "On y va doucement, tu vas y arriver."
  - **Milieu (20-70%)** : "Tu es en plein dedans, c'est très bien."
  - **Presque fini (70-95%)** : "Tu es presque au bout, je suis avec toi."
  - **Fin (95-100%)** : "Bravo ! Tu viens de te dépasser."

### **Problème 3 : Pas de carte Coach IA visible**

**La carte apparaît seulement si :**
- ✅ Coach sélectionné ET activé
- ✅ Pas en phase de repos
- ✅ Exercice avec timer (pas d'exercice sans durée)

**Si tu es en repos :**
- La carte disparaît (normal)
- Elle réapparaît à l'exercice suivant

---

## 🔄 Redémarrage complet

**Si rien ne fonctionne :**

1. **Arrête l'app** (Ctrl+C dans le terminal)
2. **Relance** : `flutter run -d chrome --web-port=8080`
3. **Ou fais un hot restart** : Appuie sur `R` majuscule dans le terminal où flutter run tourne

---

## 📍 Où trouver quoi

| Élément | Où le trouver |
|---------|---------------|
| **Sélection du coach** | Profil → "Coach Vocal IA" → Choisir un coach |
| **Icône microphone** | Séance d'exercice → En haut à droite (AppBar) |
| **Carte Coach IA** | Séance d'exercice → Sous le titre de l'étape (pendant l'exercice) |
| **Bulle vocale** | Séance d'exercice → En haut de l'écran (toutes les 15 sec) |

---

## 🐛 Si ça ne marche toujours pas

**Envoie-moi :**
1. Une capture d'écran de la page de séance (avec l'AppBar visible)
2. Une capture d'écran de la page Profil (pour voir si "Coach Vocal IA" est visible)
3. Le message d'erreur dans la console (si il y en a)

Je pourrai identifier précisément le problème ! 🔧







