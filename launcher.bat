@echo off
echo ========================================
echo   UKAN - Lanceur Serveur Web Local
echo ========================================
echo.

echo [1/3] Build Flutter Web en cours...
call flutter build web --release
if %errorlevel% neq 0 (
    echo ERREUR: Le build a echoue!
    pause
    exit /b 1
)

echo.
echo [2/3] Arret du serveur existant sur le port 8080...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo [3/3] Demarrage du serveur web...
echo.
dart lib/tools/web_server.dart

pause


