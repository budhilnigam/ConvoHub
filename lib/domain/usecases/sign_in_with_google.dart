import 'package:convo_hub/domain/entities/app_user.dart';
import 'package:convo_hub/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  SignInWithGoogle(this.repository);

  final AuthRepository repository;

  Future<AppUser> call() => repository.signInWithGoogle();
}