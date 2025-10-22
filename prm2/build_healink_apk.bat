@echo off
echo Building Healink APK...
echo.

echo Cleaning previous build...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building release APK...
flutter build apk --release

echo.
echo APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo App Name: Healink
echo Icon: Custom logo from assets/images/logo.png
echo.

pause
