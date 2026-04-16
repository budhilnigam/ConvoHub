# 📱 Flutter Slack-like Chat App — AI Coding Instructions

## 🎯 Goal

Build a **production-grade Slack-like chat application** using Flutter that demonstrates:

* Clean Architecture (MVVM + Repository pattern)
* BLoC state management (mandatory)
* Firebase integration (Auth, Firestore, FCM, Storage, Crashlytics)
* Real-time messaging
* Scalable and maintainable codebase

---

## 🧱 Tech Stack

### Frontend

* Flutter (latest stable)
* Dart
* flutter_bloc (BLoC pattern)
* provider (for DI only, not state logic)
* get_it (dependency injection)

### Backend (Firebase)

* Firebase Auth
* Cloud Firestore
* Firebase Cloud Messaging (FCM)
* Firebase Storage
* Firebase Crashlytics

---

## 📁 Project Structure (STRICT)

```
lib/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   ├── services/        # Firebase services
│   └── network/
│
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   └── usecases/
│
├── presentation/
│   ├── blocs/
│   ├── screens/
│   └── widgets/
│
├── injection_container.dart
└── main.dart
```

---

## 🔐 Environment Setup

Create `.env.example`:

```
FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
```

Use a package like `flutter_dotenv` to load env variables.

---

## 🧩 Features

### ✅ Authentication

* Email/password login & signup
* Google Sign-In (optional)
* Persistent login session

---

### 💬 Chat System (CORE)

#### Workspaces

* Create/join workspace
* List user workspaces

#### Channels

* Create public/private channels
* List channels in workspace

#### Messages

* Send/receive messages (real-time)
* Support:

  * Text
  * Image (via Firebase Storage)
* Timestamp + sender info

---

### ⚡ Real-Time Features

* Live message updates via Firestore streams
* Typing indicators
* Online/offline presence

---

### 🔔 Notifications

* Push notifications via FCM
* Notify on new messages

---

### 📦 Advanced Features (IMPORTANT)

* Pagination (load messages in chunks)
* Infinite scroll (older messages)
* Optimistic UI (instant message display)
* Read receipts (seen by users)
* Message reactions (emoji)
* Threaded replies (basic version)

---

## 🧠 State Management (MANDATORY)

Use **BLoC pattern**.

### Required BLoCs:

* AuthBloc
* WorkspaceBloc
* ChannelBloc
* ChatBloc
* PresenceBloc

Each BLoC must include:

* Events
* States
* Proper separation of concerns

---

## 🗃️ Firestore Data Model

```
users/{userId}
  name
  email
  photoUrl
  lastSeen

workspaces/{workspaceId}
  name
  members: [userIds]

channels/{channelId}
  workspaceId
  name
  isPrivate

channels/{channelId}/messages/{messageId}
  senderId
  text
  type (text/image)
  timestamp
  readBy: [userIds]
```

---

## 🔄 Data Flow

UI → BLoC → UseCase → Repository → DataSource → Firebase

No direct Firebase calls from UI.

---

## ⚙️ Key Engineering Requirements

### Performance

* Use `ListView.builder`
* Avoid unnecessary rebuilds
* Use const widgets wherever possible

### Error Handling

* Handle:

  * Network errors
  * Firebase failures
* Show proper UI states:

  * loading
  * error
  * empty

### Pagination

* Load last 20 messages initially
* Fetch older messages on scroll

### Offline Support

* Enable Firestore offline persistence

---

## 🧪 Testing

* Unit tests for BLoCs
* Basic widget tests

---

## 🔐 Firebase Rules (Basic)

* Only authenticated users can read/write
* Users can only access their workspace data
* Validate message structure

---

## 🎨 UI Requirements

* Clean, minimal UI (not fancy but professional)
* Dark mode support
* Chat UI:

  * message bubbles
  * timestamps
  * grouped messages

---

## 🔄 CI/CD (Bonus)

* GitHub Actions:

  * Run tests
  * Analyze code

---

## 📘 README.md (AUTO-GENERATE)

Include:

* Features
* Architecture diagram (ASCII ok)
* Screenshots (placeholder)
* Setup instructions
* Tech stack

---

## 🚫 Strict Rules

* ❌ No business logic inside UI
* ❌ No direct Firebase calls in widgets
* ❌ No single massive file
* ❌ No skipping BLoC

---

## ✅ Expected Output

Generate:

* Full Flutter project
* Proper folder structure
* Working authentication
* Real-time chat system
* Clean architecture implementation

---

## 🧠 Final Instruction

Focus on:

* Code quality > UI design
* Scalability > shortcuts
* Separation of concerns > speed

This project should resemble a **real production app**, not a tutorial demo.
