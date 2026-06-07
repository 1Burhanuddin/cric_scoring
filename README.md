# CricHeros

**CricHeros** is a cricket scoring and tournament management app built with **Flutter** and **Firebase**. Score matches ball-by-ball, run tournaments end to end, track player and team statistics, and share live scorecards with anyone.

CricHeros is built on the open-source [Khelo](https://github.com/canopas/khelo) codebase and is being extended into a full CricHeroes-style platform.

---

## Features

- **Ball-by-ball live scoring** — record every delivery with runs, extras, wickets and commentary.
- **Match management** — create matches, set up teams, manage squads, toss, and powerplays.
- **Tournament management** — organize tournaments with fixtures, groups, points tables and standings.
- **Team & player profiles** — build teams, invite players, and maintain rosters.
- **Statistics** — batting, bowling and fielding stats aggregated across matches.
- **Shareable scorecards** — share live and completed match scorecards via deep links.
- **Public match feed** — discover and follow ongoing public matches.
- **Authentication** — phone/OTP and social sign-in powered by Firebase Auth.
- **Push notifications** — match and tournament updates via Firebase Cloud Messaging.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State management | Riverpod / Hooks Riverpod |
| Navigation | go_router |
| Backend | Firebase (Auth, Cloud Firestore, Storage, Cloud Functions) |
| Messaging | Firebase Cloud Messaging |
| Monitoring | Firebase Crashlytics |
| Codegen | freezed, json_serializable, build_runner |

---

## Project Structure

This is a multi-package Flutter workspace:

| Package | Pub name | Description |
|---------|----------|-------------|
| `khelo/` | `cricheros` | The main Flutter application (UI, features, routing). |
| `data/` | `cricheros_data` | Data layer — models, repositories and Firebase services. |
| `style/` | `cricheros_style` | Shared design system — theme, colors, typography and assets. |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `>=3.2.3 <4.0.0`)
- A configured [Firebase](https://firebase.google.com/) project
- Android Studio / Xcode for device or emulator builds

### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd cricheros-app
   ```

2. **Install dependencies**
   ```bash
   cd khelo
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project and register an Android app with application id `com.cricheros.app`.
   - Add `google-services.json` to `khelo/android/app/`.
   - Add `GoogleService-Info.plist` to `khelo/ios/Runner/` for iOS.
   - Or run `flutterfire configure` to generate `firebase_options.dart`.

4. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## Build

```bash
# Android (release APK)
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

- Application id: `com.cricheros.app`
- Version: see `version:` in [khelo/pubspec.yaml](khelo/pubspec.yaml)

---

## Roadmap

See [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) for the Phase 1–3 roadmap.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Bug reports and feature requests can be filed using the [issue templates](.github/ISSUE_TEMPLATE/).

## Credits

CricHeros is built on top of the open-source [Khelo](https://github.com/canopas/khelo) project by [Canopas](https://canopas.com). Many thanks to the original authors.
