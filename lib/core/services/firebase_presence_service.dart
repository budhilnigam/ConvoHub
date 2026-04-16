import 'package:convo_hub/core/services/firebase_bootstrap.dart';

class FirebasePresenceService {
  FirebasePresenceService({required this.bootstrapState});

  final FirebaseBootstrapState bootstrapState;

  bool get isEnabled => bootstrapState.enabled;
}