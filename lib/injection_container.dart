import 'package:convo_hub/core/services/firebase_bootstrap.dart';
import 'package:convo_hub/core/services/firebase_presence_service.dart';
import 'package:convo_hub/data/repositories/auth_repository_impl.dart';
import 'package:convo_hub/data/repositories/channel_repository_impl.dart';
import 'package:convo_hub/data/repositories/chat_repository_impl.dart';
import 'package:convo_hub/data/repositories/presence_repository_impl.dart';
import 'package:convo_hub/data/repositories/workspace_repository_impl.dart';
import 'package:convo_hub/domain/repositories/auth_repository.dart';
import 'package:convo_hub/domain/repositories/channel_repository.dart';
import 'package:convo_hub/domain/repositories/chat_repository.dart';
import 'package:convo_hub/domain/repositories/presence_repository.dart';
import 'package:convo_hub/domain/repositories/workspace_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> configureInjection() async {
  if (sl.isRegistered<FirebaseBootstrapState>()) {
    return;
  }

  final bootstrapState = await getFirebaseBootstrapState();
  sl.registerSingleton<FirebaseBootstrapState>(bootstrapState);

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(bootstrapState: bootstrapState),
  );
  sl.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(bootstrapState: bootstrapState),
  );
  sl.registerLazySingleton<ChannelRepository>(
    () => ChannelRepositoryImpl(bootstrapState: bootstrapState),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(bootstrapState: bootstrapState),
  );
  sl.registerLazySingleton<PresenceRepository>(
    () => PresenceRepositoryImpl(bootstrapState: bootstrapState),
  );
  sl.registerLazySingleton<FirebasePresenceService>(
    () => FirebasePresenceService(bootstrapState: bootstrapState),
  );
}