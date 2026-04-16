import 'package:convo_hub/domain/entities/app_user.dart';
import 'package:convo_hub/domain/repositories/auth_repository.dart';

class WatchAuthState {
  WatchAuthState(this.repository);

  final AuthRepository repository;

  Stream<AppUser?> call() => repository.authStateChanges();
}