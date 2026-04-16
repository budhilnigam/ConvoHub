import 'package:convo_hub/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithEmail({required String email, required String password});
  Future<AppUser> signUpWithEmail({required String name, required String email, required String password});
  Future<void> signOut();
  AppUser? get currentUser;
}