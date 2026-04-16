import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_hub/core/services/firebase_bootstrap.dart';
import 'package:convo_hub/domain/repositories/presence_repository.dart';

class PresenceRepositoryImpl implements PresenceRepository {
  PresenceRepositoryImpl({required this.bootstrapState});

  final FirebaseBootstrapState bootstrapState;

  @override
  Stream<Map<String, bool>> watchPresence(String workspaceId) {
    if (!bootstrapState.enabled) {
      return Stream<Map<String, bool>>.value(const {'local-user-1': true, 'local-user-2': false});
    }

    return FirebaseFirestore.instance
        .collection('workspaces')
        .doc(workspaceId)
        .collection('presence')
        .snapshots()
        .map((snapshot) {
          final presence = <String, bool>{};
          for (final doc in snapshot.docs) {
            presence[doc.id] = doc.data()['isOnline'] as bool? ?? false;
          }
          return presence;
        });
  }

  @override
  Future<void> setOnline({required String userId, required bool isOnline}) async {
    if (!bootstrapState.enabled) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).set(
      {
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}