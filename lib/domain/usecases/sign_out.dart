import 'package:convo_hub/domain/repositories/auth_repository.dart';

class SignOut {
  SignOut(this.repository);

  final AuthRepository repository;

  Future<void> call() => repository.signOut();
}