@echo off
echo ========================================
echo   UKAN - Déploiement sur Vercel (locale)
echo ========================================
echo.

rem Vérifier que flutter est installé
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
  echo ERREUR: Flutter n'est pas trouvé dans le PATH. Installez Flutter ou ajoutez-le au PATH.
  pause
  exit /b 1
)

echo [1/3] Build Flutter Web en cours...
call flutter build web --release
if %errorlevel% neq 0 (
    echo ERREUR: Le build a échoue!
    pause
    exit /b 1
)

echo.
echo [2/3] Vérification de l'installation Vercel CLI...
vercel --version >nul 2>&1
if %errorlevel% neq 0 (
  echo ERREUR: Vercel CLI non trouvé. Installez-le avec "npm i -g vercel" ou "pnpm add -g vercel".
  pause
  exit /b 1
)

echo.
echo [3/3] Déploiement sur Vercel (production)...
rem Deploy avec confirmation automatique (--confirm) et en utilisant vercel.json du repo
vercel deploy --prod --confirm
if %errorlevel% neq 0 (
    echo ERREUR: Le déploiement a échoue!
    pause
    exit /b 1
)

echo.
echo Déploiement terminé avec succès.
pause














