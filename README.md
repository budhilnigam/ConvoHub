# Convo Hub

Convo Hub is a Slack-style Flutter chat app built with BLoC, clean layering, Firebase integration, and a responsive desktop-first layout that still adapts cleanly to tablet and mobile screens.

## Features

- Google OAuth sign-in and sign-up
- Email/password auth fallback
- Firebase Auth, Firestore, Storage, Messaging, and Crashlytics integration points
- Workspace, channel, and chat separation
- Real-time message streams
- Optimistic message send flow
- Presence indicators
- Responsive layout for desktop, tablet, and mobile
- Dark mode support

## Architecture

```text
UI -> BLoC -> UseCase -> Repository -> Data Source -> Firebase

lib/
	core/
	data/
	domain/
	presentation/
```

## Setup

1. Copy [.env.example](.env.example) to [.env](.env) and fill in your Firebase values.
2. Connect the app to a Firebase project.
3. Run `flutter pub get`.
4. Launch with `flutter run`.

## Firebase Fields

The app expects these environment variables:

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`

## Screens

- Auth screen with Google OAuth and email/password fallback
- Desktop/tablet three-pane workspace shell
- Mobile compact navigation shell

## Notes

- When Firebase env values are missing, the app falls back to seeded local data so the UI can still be explored.
- Firestore collections follow the structure described in `instructions.md`.

## Placeholder Media

- Screenshots: add exported app captures here once the Firebase project is connected.
