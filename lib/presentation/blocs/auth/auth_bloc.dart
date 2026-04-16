import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:convo_hub/domain/entities/app_user.dart';
import 'package:convo_hub/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthStatusChanged>(_onStatusChanged);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthEmailSignInRequested>(_onEmailSignInRequested);
    on<AuthEmailSignUpRequested>(_onEmailSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);

    add(const AuthSubscriptionRequested());
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _repository.authStateChanges().listen((user) {
      if (user == null) {
        add(const AuthStatusChanged(null));
      } else {
        add(AuthStatusChanged(user));
      }
    });

    final currentUser = _repository.currentUser;
    if (currentUser == null) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(currentUser));
    }
  }

  void _onStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user == null) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(user));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _performSignIn(emit, () => _repository.signInWithGoogle());
  }

  Future<void> _onEmailSignInRequested(
    AuthEmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _performSignIn(
      emit,
      () => _repository.signInWithEmail(email: event.email, password: event.password),
    );
  }

  Future<void> _onEmailSignUpRequested(
    AuthEmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _performSignIn(
      emit,
      () => _repository.signUpWithEmail(name: event.name, email: event.email, password: event.password),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.signOut();
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _performSignIn(Emitter<AuthState> emit, Future<AppUser> Function() action) async {
    emit(const AuthLoading());
    try {
      final user = await action();
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}