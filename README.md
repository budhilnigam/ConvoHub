# Convo Hub

Convo Hub is a Flutter-based, Slack-style chat application with a responsive layout and real-time messaging support. The project uses a layered architecture (presentation, domain, data) and integrates with Firebase services when configured.

## Key Features

- Google Sign-In and email/password authentication
- Workspaces, channels, and direct messages
- Real-time messaging with optimistic UI updates
- Presence indicators and message streams
- Responsive UI for desktop, tablet, and mobile

## Architecture Overview

UI → BLoC → Use Cases → Repositories → Data Sources (Firebase / local seed)

Repository layout (under `lib/`):
- `core/`, `data/`, `domain/`, `presentation/`

## Getting Started

Prerequisites:

- Flutter SDK (stable) installed
- A Firebase project (optional; the app includes a local seeded data fallback)

Quick start:

1. Copy `.env.example` to `.env` and provide Firebase values if using Firebase.
2. Install dependencies:

```bash
flutter pub get
```

3. Run the app (example: Chrome):

```bash
flutter run -d chrome
```

4. Run widget tests:

```bash
flutter test
```

## Environment Variables

When Firebase integration is required, populate the following variables in the `.env` file (see `.env.example`):

- FIREBASE_API_KEY
- FIREBASE_APP_ID
- FIREBASE_MESSAGING_SENDER_ID
- FIREBASE_PROJECT_ID
- FIREBASE_STORAGE_BUCKET
- GOOGLE_WEB_CLIENT_ID

If these values are not present, the app will run against seeded local data to enable UI exploration without Firebase.

## Project Structure

- `lib/presentation` — UI and BLoC layers
- `lib/domain` — entities and use cases
- `lib/data` — repository implementations and models
- `lib/core` — shared utilities and Firebase bootstrap logic

## Contribution

Contributions are welcome. Open issues and pull requests should include a description of the change, motivation, and any manual testing steps.

## License

This repository does not include a license file. Add a license (for example, MIT) if the project will be published.

## Further Notes

- See [instructions.md](instructions.md) for detailed Firebase setup and collection structure.
- Sensitive files (for example service account JSON files or the final `.env`) should not be committed to the repository.
