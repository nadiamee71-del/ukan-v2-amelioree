Déploiement sur Vercel (locale)
================================

Pré-requis :
- Flutter installé et accessible via le PATH
- Vercel CLI installé (`npm i -g vercel` ou `pnpm add -g vercel`)
- Être connecté à Vercel (`vercel login`) et avoir lié le projet si besoin (`vercel link`)

Étapes pour déployer depuis ta machine (Windows) :

1. Ouvre un terminal à la racine du projet.
2. Lancer le script : `deploy_vercel.bat`
   - Le script construit l'application web (`flutter build web --release`)
   - Puis lance `vercel deploy --prod --confirm` pour déployer la sortie `build/web`

Remarques :
- Le fichier `vercel.json` configure la commande de build et le répertoire de sortie :

```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

- Si tu veux déployer sans confirmation interactive : le script utilise `--confirm` pour forcer le déploiement en production.
- Sur Vercel, Flutter n'est pas installé par défaut ; le CLI local exécutera le build localement puis uploadera les fichiers statiques. C'est la méthode recommandée si tu veux déployer directement depuis ta machine (sans GitHub).

Si tu veux, je peux :
- Exécuter le script de build + déploiement pour toi (si tu veux que je lance la commande ici).  
- Ou ajouter un script PowerShell équivalent.














