import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrapState {
  const FirebaseBootstrapState({required this.enabled, required this.errorMessage});

  final bool enabled;
  final String? errorMessage;
}

Future<void> bootstrapFirebase() async {
  final state = await getFirebaseBootstrapState();
  if (!state.enabled) {
    return;
  }
}

Future<FirebaseBootstrapState> getFirebaseBootstrapState() async {
  final apiKey = dotenv.env['FIREBASE_API_KEY']?.trim() ?? '';
  final appId = dotenv.env['FIREBASE_APP_ID']?.trim() ?? '';
  final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID']?.trim() ?? '';
  final projectId = dotenv.env['FIREBASE_PROJECT_ID']?.trim() ?? '';
  final storageBucket = dotenv.env['FIREBASE_STORAGE_BUCKET']?.trim() ?? '';

  if ([apiKey, appId, messagingSenderId, projectId, storageBucket].any((value) => value.isEmpty)) {
    return const FirebaseBootstrapState(
      enabled: false,
      errorMessage: 'Firebase env variables are missing. Running in local fallback mode.',
    );
  }

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      ),
    );
  }

  return const FirebaseBootstrapState(enabled: true, errorMessage: null);
}