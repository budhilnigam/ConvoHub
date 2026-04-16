part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged(this.user);

  final AppUser? user;

  @override
  List<Object?> get props => [user];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthEmailSignInRequested extends AuthEvent {
  const AuthEmailSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthEmailSignUpRequested extends AuthEvent {
  const AuthEmailSignUpRequested({required this.name, required this.email, required this.password});

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}