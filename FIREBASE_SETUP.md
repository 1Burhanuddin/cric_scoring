# Firebase Setup — CricHeros

CricHeros uses Firebase for authentication, Cloud Firestore, Storage, Cloud
Functions, Crashlytics, and Cloud Messaging. This guide covers connecting the
app to the Firebase project.

## Project details

| Field | Value |
|-------|-------|
| Project name | CricHeros |
| Project ID | `cric-scoring` |
| Project number | `842029024914` |
| Storage bucket | `cric-scoring.appspot.com` |

### Registered apps

| Platform | Package / Bundle | App ID |
|----------|------------------|--------|
| Android | `com.cricheros.app` | `1:842029024914:android:81b61a6152af2b1259084b` |
| iOS | _not yet registered_ | — |

## Android

The Android config file lives at:

```
khelo/android/app/google-services.json
```

It is wired up via the `com.google.gms.google-services` Gradle plugin in
[khelo/android/app/build.gradle](khelo/android/app/build.gradle). No further
code changes are needed — the plugin reads this file at build time.

> **Note on version control:** `android/app/google-services.json` is listed in
> `khelo/.gitignore` by default. This repo commits it intentionally so the team
> shares one config. The Android API key it contains is restricted to the app's
> package name (and SHA-1, once configured), so committing it is standard
> practice. If your security policy differs, remove it from version control and
> distribute it out of band.

### Getting / refreshing the file

Download the authoritative file from the Firebase Console whenever the app
config changes (e.g. after adding Google Sign-In, which populates
`oauth_client`):

1. Open https://console.firebase.google.com/project/cric-scoring/settings/general
2. Under **Your apps → CricHeros (com.cricheros.app)**, click
   **Download google-services.json**.
3. Replace `khelo/android/app/google-services.json`.

Or via the Firebase CLI:

```bash
firebase login
firebase apps:sdkconfig android 1:842029024914:android:81b61a6152af2b1259084b \
  --project cric-scoring > khelo/android/app/google-services.json
```

### SHA-1 / SHA-256 (required for phone auth & Google Sign-In)

Add your debug and release signing certificate fingerprints to the Firebase
Android app:

```bash
# Debug keystore fingerprint
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore -storepass android -keypass android
```

Add the resulting SHA-1 and SHA-256 under
*Project settings → Your apps → Add fingerprint*, then re-download
`google-services.json`.

## iOS (not yet configured)

1. Register an iOS app in the `cric-scoring` Firebase project with the iOS
   bundle id (currently `com.canopas.khelo` in
   `khelo/ios/Runner.xcodeproj` — rebrand to `com.cricheros.app` first).
2. Download `GoogleService-Info.plist` into `khelo/ios/Runner/`.
3. Add it to the Runner target in Xcode.

## FlutterFire / `firebase_options.dart` (optional)

If the app initializes Firebase via `DefaultFirebaseOptions`, regenerate it
after platform/config changes:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=cric-scoring
```

## Verify the connection

```bash
cd khelo
flutter pub get
flutter run
```

On launch the app should initialize Firebase without errors. Check the
[Firebase Console](https://console.firebase.google.com/project/cric-scoring)
(Authentication / Firestore) to confirm traffic from the app.

## Troubleshooting

- **`No matching client found for package name 'com.cricheros.app'`** — the
  `applicationId` in `build.gradle` does not match any client in
  `google-services.json`. Both must be `com.cricheros.app`.
- **`API key not valid`** — the `current_key` is wrong or restricted to a
  different package/SHA. Re-download the file from the console.
- **Phone auth / Google Sign-In fails** — missing SHA-1/SHA-256 fingerprints;
  add them and re-download the config.
