# 🎨 Aezakmi Mini Drawing App

A Flutter mini application for **authentication, drawing, and personal image gallery management**, built with **MobX** and **Firebase**.

## Features
- Email & password authentication (Firebase Auth)
- Personal gallery per user
- Create and edit drawings
- Realtime updates with Cloud Firestore
- Safe logout handling
- Error messages for auth failures
- Feature-based clean architecture
- Reusable UI via custom **design_system**

## Tech Stack
- Flutter
- Firebase Authentication
- Cloud Firestore
- MobX
- AutoRoute
- Easy Localization

## Getting Started

```bash
dart run easy_localization:generate -f keys -O lib/gen -o locale_keys.g.dart -S assets/translations -s en-US.json -u true
flutter pub run build_runner build --delete-conflicting-outputs