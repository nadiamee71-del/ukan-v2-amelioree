# Animation Mascotte FitPro - Coup de Poing

## 📁 Noms des fichiers d'animation

Pour créer l'animation de boxe de la mascotte, vous devez renommer ou créer 3 images :

1. **`fitpro_logo_boxeur_replie.png`** 
   - Position de départ : mascotte avec les poings repliés (position de garde)

2. **`fitpro_logo_boxeur_droit.png`**
   - Coup de poing droit : mascotte avec le poing droit tendu

3. **`fitpro_logo_boxeur_gauche.png`**
   - Coup de poing gauche : mascotte avec le poing gauche tendu

## 🎬 Séquence d'animation

L'animation se déroule dans cet ordre :
1. **Position repliée** (0.0s - 0.5s) : Fade in + scale
2. **Coup de poing droit** (0.5s - 1.0s) : Transition vers le poing droit
3. **Coup de poing gauche** (1.0s - 1.5s) : Transition vers le poing gauche
4. **Retour position repliée** (1.5s - 2.0s) : Retour à la position de garde
5. **Fin** (2.0s - 2.5s) : Fade out et redirection

## 📝 Instructions

1. Placez les 3 fichiers dans `assets/images/`
2. L'animation sera automatiquement intégrée dans `splash_screen.dart`
3. Durée totale : 2.5 secondes


