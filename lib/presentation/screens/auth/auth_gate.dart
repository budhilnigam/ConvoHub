import 'package:convo_hub/domain/repositories/auth_repository.dart';
import 'package:convo_hub/domain/repositories/channel_repository.dart';
import 'package:convo_hub/domain/repositories/chat_repository.dart';
import 'package:convo_hub/domain/repositories/presence_repository.dart';
import 'package:convo_hub/domain/repositories/workspace_repository.dart';
import 'package:convo_hub/injection_container.dart';
import 'package:convo_hub/presentation/blocs/auth/auth_bloc.dart';
import 'package:convo_hub/presentation/blocs/channel/channel_bloc.dart';
import 'package:convo_hub/presentation/blocs/chat/chat_bloc.dart';
import 'package:convo_hub/presentation/blocs/presence/presence_bloc.dart';
import 'package:convo_hub/presentation/blocs/workspace/workspace_bloc.dart';
import 'package:convo_hub/presentation/screens/auth/sign_in_screen.dart';
import 'package:convo_hub/presentation/screens/home/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(sl<AuthRepository>()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => WorkspaceBloc(sl<WorkspaceRepository>())..add(WorkspaceSubscriptionRequested(state.user.id))),
                BlocProvider(create: (_) => ChannelBloc(sl<ChannelRepository>())),
                BlocProvider(create: (_) => ChatBloc(sl<ChatRepository>())),
                BlocProvider(create: (_) => PresenceBloc(sl<PresenceRepository>())),
              ],
              child: HomeShell(user: state.user),
            );
          }

          if (state is AuthLoading) {
            return const _LoadingScreen();
          }

          return SignInScreen(onGoogleSignIn: () => context.read<AuthBloc>().add(const AuthGoogleSignInRequested()));
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}