@echo off
setlocal enabledelayedexpansion

echo =======================================================
echo   🎮 Picky X (Memory Match) — Automated APK Builder
echo =======================================================
echo.

:: Check if Flutter is on PATH
where flutter >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Flutter SDK found on PATH.
    goto :BUILD
)

:: Check if Flutter exists in C:\src\flutter\bin
if exist "C:\src\flutter\bin\flutter.bat" (
    echo [OK] Flutter SDK found in C:\src\flutter\bin.
    set "PATH=C:\src\flutter\bin;!PATH!"
    goto :BUILD
)

echo [INFO] Flutter SDK was not found on your system.
echo.
echo [1/3] Downloading portable Flutter SDK from Google Storage...
if not exist "C:\src" mkdir "C:\src"
curl -L -o "C:\src\flutter_windows.zip" "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.0-stable.zip"

echo [2/3] Extracting Flutter SDK to C:\src\flutter...
tar -xf "C:\src\flutter_windows.zip" -C "C:\src"
del "C:\src\flutter_windows.zip"
set "PATH=C:\src\flutter\bin;!PATH!"

:BUILD
echo.
echo [3/3] Building Release APK for Android (API 36 Baseline)...
echo.
cd /d "%~dp0"
call flutter pub get
call flutter build apk --release

echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo =======================================================
    echo   🎉 SUCCESS! APK Generated Successfully!
    echo   File Path: %~dp0build\app\outputs\flutter-apk\app-release.apk
    echo =======================================================
) else (
    echo [ERROR] Build failed. Please ensure Android SDK and Java 17 are configured.
)

pause
