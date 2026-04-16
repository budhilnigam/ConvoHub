import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_hub/core/services/firebase_bootstrap.dart';
import 'package:convo_hub/data/models/app_user_model.dart';
import 'package:convo_hub/data/repositories/local_seed_data.dart';
import 'package:convo_hub/domain/entities/app_user.dart';
import 'package:convo_hub/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.bootstrapState}) {
    if (bootstrapState.enabled) {
      _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(_syncFirebaseUser);
    } else {
      _currentUser = AppUserModel(
        id: LocalSeedData.userId,
        name: 'Alex Morgan',
        email: 'alex@convohub.dev',
        photoUrl: null,
        lastSeen: null,
        isOnline: true,
      );
      _stateController.add(_currentUser);
    }
  }

  final FirebaseBootstrapState bootstrapState;
  final StreamController<AppUser?> _stateController = StreamController<AppUser?>.broadcast();
  StreamSubscription<User?>? _authStateSubscription;
  AppUser? _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _stateController.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signInWithGoogle() async {
    if (!bootstrapState.enabled) {
      return _setCurrentUser(
        AppUserModel(
          id: LocalSeedData.userId,
          name: 'Alex Morgan',
          email: 'alex@convohub.dev',
          photoUrl: null,
          lastSeen: null,
          isOnline: true,
        ),
      );
    }

    if (!_supportsGoogleSignIn) {
      throw UnsupportedError(
        'Google sign-in is supported on mobile, web, and macOS in this build. Use email/password on this desktop platform.',
      );
    }

    final googleSignIn = _buildGoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'canceled', message: 'Google sign-in was cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'No Firebase user returned.');
    }

    final user = _mapFirebaseUser(firebaseUser);
    await _upsertUserProfile(user, userCredential.user);
    return _setCurrentUser(user);
  }

  @override
  Future<AppUser> signInWithEmail({required String email, required String password}) async {
    if (!bootstrapState.enabled) {
      return _setCurrentUser(
        AppUserModel(
          id: LocalSeedData.userId,
          name: 'Alex Morgan',
          email: email,
          photoUrl: null,
          lastSeen: null,
          isOnline: true,
        ),
      );
    }

    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'No user returned.');
    }
    return _setCurrentUser(_mapFirebaseUser(user));
  }

  @override
  Future<AppUser> signUpWithEmail({required String name, required String email, required String password}) async {
    if (!bootstrapState.enabled) {
      return _setCurrentUser(
        AppUserModel(
          id: LocalSeedData.userId,
          name: name,
          email: email,
          photoUrl: null,
          lastSeen: null,
          isOnline: true,
        ),
      );
    }

    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'No user returned.');
    }

    await user.updateDisplayName(name);
    final mapped = _mapFirebaseUser(user, fallbackName: name);
    await _upsertUserProfile(mapped, user);
    return _setCurrentUser(mapped);
  }

  @override
  Future<void> signOut() async {
    if (!bootstrapState.enabled) {
      _currentUser = null;
      _stateController.add(null);
      return;
    }

    if (_supportsGoogleSignIn) {
      await GoogleSignIn().signOut();
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _syncFirebaseUser(User? user) async {
    if (user == null) {
      _currentUser = null;
      _stateController.add(null);
      return;
    }

    final mapped = _mapFirebaseUser(user);
    _currentUser = mapped;
    _stateController.add(mapped);
  }

  Future<void> _upsertUserProfile(AppUser user, User? firebaseUser) async {
    if (!bootstrapState.enabled || firebaseUser == null) {
      return;
    }

    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(firebaseUser.uid).set({
      'name': user.name,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
    }, SetOptions(merge: true));
  }

  AppUserModel _mapFirebaseUser(User user, {String? fallbackName}) {
    return AppUserModel(
      id: user.uid,
      name: user.displayName?.trim().isNotEmpty == true ? user.displayName! : fallbackName ?? 'Workspace member',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      lastSeen: DateTime.now(),
      isOnline: true,
    );
  }

  Future<AppUser> _setCurrentUser(AppUser user) async {
    _currentUser = user;
    _stateController.add(user);
    return user;
  }

  bool get _supportsGoogleSignIn {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  GoogleSignIn _buildGoogleSignIn() {
    if (!kIsWeb) {
      return GoogleSignIn();
    }

    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim() ?? '';
    if (webClientId.isEmpty) {
      throw StateError(
        'Missing GOOGLE_WEB_CLIENT_ID in .env. Set it to your Web OAuth client ID from Google Cloud Console Credentials.',
      );
    }

    return GoogleSignIn(clientId: webClientId);
  }

  void dispose() {
    _authStateSubscription?.cancel();
    _stateController.close();
  }
}