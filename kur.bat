@echo off
chcp 65001 >nul
echo NABIZ - Proje hazirlik
cd /d "%~dp0"

where flutter >nul 2>&1
if errorlevel 1 (
    echo [HATA] Flutter bulunamadi.
    echo KURULUM.md dosyasindaki Flutter kurulum adimlarini yapin.
    pause
    exit /b 1
)

echo Flutter create (platform klasorleri)...
flutter create . --project-name nabiz

echo Bagimliliklar...
flutter pub get

echo.
echo Hazir. Test icin:
echo   flutter run -d windows
echo   flutter run -d chrome
echo   flutter run   (bagli telefon veya emulator)
pause
