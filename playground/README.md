# ThunderID Flutter Playground

A development app for exercising every `thunderid_flutter` capability against the SDK source in this
repository. It depends on the plugin with `path: ..`, so changes to `lib/`, `android/` or `ios/` at the
repository root show up the next time you run it.

Looking for a minimal integration example instead? See the
[Flutter quickstart](https://github.com/thunder-id/samples/tree/main/quickstarts/flutter) in the samples
repository.

## What's inside

| Tab | What it does |
|---|---|
| **Checks** | Runs capability checks through the real SDK (system browser sign-in URL, app-native flow, passkey bridge, sign out, redirect callback, token refresh, secure storage, user info, theming, translations). Run one or run all, with pass/fail and the reason, a summary ring, and the server's health. Capabilities the SDK has no API for (biometric unlock, organizations) are listed as unavailable. |
| **Components** | Storybook-style explorer for the SDK widgets (`SignInButton`, `SignOutButton`, `SignUpButton`, `SignIn`, `SignUp`, `UserAvatar`, `UserObject`, `UserDropdown`, `UserProfile`, `ChangeCredential`, `LanguageSwitcher`, `ThunderIDLogo`, `SignedIn` / `SignedOut` / `Loading`). Pick a story, edit props in Controls, copy the generated Flutter snippet from Code, and watch callbacks in Actions. Toggle the preview between light and dark. |
| **Session** | Signed-in user, access token countdown, refresh and sign out, the access token (reveal or copy), decoded claims, and recent events. When signed out, it opens the SDK's `SignIn` and `SignUp` widgets. |
| **Logs** | Every SDK call the playground makes and every session change it observes, filterable by outcome. |

## Prerequisites

- Flutter 3.24 or later
- Android Studio with an emulator (API 26+), or Xcode with an iOS 16+ simulator
- A running ThunderID server. See [Get started](https://thunderid.dev/docs/next/getting-started/) to
  download and start one; by default it listens on `https://localhost:8090`.

## Set up ThunderID

1. Sign in to the ThunderID Console and create a **Mobile** application.
2. Copy its application ID.
3. Simulators and emulators cannot pass platform attestation (Apple App Attest or Play Integrity), so
   enable attestation **dev mode** on the application while you test locally. Never enable it on a real
   tenant.
4. Optional: to run the system browser and redirect callback checks, give the application an OAuth
   client ID and register the redirect URI from `.env` (`dev.thunderid.playground://callback` by
   default). These checks build the authorize URL and confirm forged callbacks are rejected; the app
   does not register the URL scheme, so it does not complete a full browser round trip.

## Configure

```bash
cp .env.example .env
```

| Variable | Description |
|---|---|
| `THUNDERID_BASE_URL` | ThunderID server URL. Use `https://localhost:8090` for the iOS simulator and `https://10.0.2.2:8090` for the Android emulator. |
| `THUNDERID_APP_ID` | Application ID for app-native sign-in and sign-up. |
| `THUNDERID_CLIENT_ID` | Optional OAuth client ID for redirect-based sign-in. |
| `THUNDERID_AFTER_SIGN_IN_URL` / `THUNDERID_AFTER_SIGN_OUT_URL` | Redirect URIs used with `THUNDERID_CLIENT_ID`. |
| `THUNDERID_ATTESTATION_ENABLED` | `true` to send an attestation token. Keep `false` on simulators and emulators. |
| `THUNDERID_CLOUD_PROJECT_NUMBER` | Google Cloud project number, required by Play Integrity when attestation is on. |

`.env` is gitignored. Debug builds accept the local server's self-signed certificate (Android through
`allowInsecureConnections`, iOS through an App Transport Security exemption); release builds do not.

## Run

```bash
cd playground
flutter pub get
flutter run
```

Without a reachable server, checks that need one fail with the reason, and the health indicator on the
Checks tab reports the server as unreachable.

## Develop

```bash
flutter analyze
flutter build apk --debug
```

The repository's PR builder runs the same commands, so keep the playground building when you change
the SDK's public API.
