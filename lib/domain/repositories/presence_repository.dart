abstract class PresenceRepository {
  Stream<Map<String, bool>> watchPresence(String workspaceId);
  Future<void> setOnline({required String userId, required bool isOnline});
}