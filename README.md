# fitpro

Application Flutter principale - FitPro

## ⚠️ IMPORTANT - Projet Principal

**Ce dossier (`c:\fitpro`) est le projet principal à utiliser.**

Il existe également un sous-dossier `fitpro_app` qui est un projet séparé et ne doit **PAS** être utilisé pour le développement principal.

## 🚀 Lancer l'application

**Toujours depuis le dossier racine `c:\fitpro` :**

```bash
# Vérifier les appareils disponibles
flutter devices

# Lancer sur l'émulateur Android
flutter run -d emulator-5554

# Ou simplement (si un seul appareil est connecté)
flutter run
```

## 📁 Structure du projet

- `lib/` - Code source principal de l'application
- `android/` - Configuration Android (package: `com.example.fitpro`)
- `ios/` - Configuration iOS
- `assets/` - Images et vidéos
- `fitpro_app/` - **Projet séparé, ne pas utiliser**

## 🔧 Configuration

- **Package Android:** `com.example.fitpro`
- **Application ID:** `com.example.fitpro`
- **Version:** 1.0.0+1

## 📚 Documentation

Voir les fichiers markdown dans la racine du projet pour plus de détails sur les fonctionnalités.
