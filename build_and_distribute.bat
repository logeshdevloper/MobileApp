@echo off

:: Build APK
flutter build apk --release

:: Upload to Firebase
firebase appdistribution:distribute build\app\outputs\flutter-apk\app-release.apk ^
  --app 1:1047644619235:android:0c4b73e5d35815954d60d6 ^
  --testers "logeshrewq@gmail.com"
