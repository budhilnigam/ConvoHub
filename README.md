# Convo Hub

Convo Hub is a Flutter chat application for team communication. It supports workspace-based collaboration, channel discussions, and direct messaging, with a responsive experience across desktop, tablet, and mobile.

## Features

- Authentication with Google Sign-In and email/password
- Workspace creation and switching
- Channel creation (public/private)
- Direct messaging
- Real-time chat updates
- Presence indicators
- Optimistic message sending for smoother UX
- Responsive UI for web and mobile form factors

## Tech Stack

- Flutter
- Dart
- BLoC state management
- Firebase Auth
- Cloud Firestore
- flutter_dotenv

## Demo User Flow

1. Sign in (Google or email/password).
2. Create a workspace.
3. Create channels for topics.
4. Start direct chats for private conversations.
5. Send and receive messages in real time.

1. Launch the app.
2. Create an account or sign in with Google.
3. Create or join a workspace.
4. Inside a workspace, create a channel for topics or start a direct chat with someone.
5. Send messages; new messages appear in real time and the UI updates optimistically.

### Prerequisites

- Flutter SDK installed
- Dart SDK (bundled with Flutter)
- Optional: Firebase project for cloud-backed auth and data

### Installation

```bash
flutter pub get
```

### Configuration

Copy `.env.example` to `.env` and fill required values for Firebase-enabled runs.

Required environment variables:

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`
- `GOOGLE_WEB_CLIENT_ID`

If Firebase is not configured, the app can still run in local seeded-data mode for UI exploration.

### Run

```bash
flutter run -d chrome
```

For mobile targets, run on a connected device or emulator:

```bash
flutter run
```

### Test

```bash
flutter test
```

## Project Structure

- `lib/presentation` - Screens, widgets, and BLoCs
- `lib/domain` - Entities, repository contracts, and use cases
- `lib/data` - Models and repository implementations
- `lib/core` - Shared services, constants, and utilities
