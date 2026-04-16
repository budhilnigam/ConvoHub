import 'package:convo_hub/core/constants/app_colors.dart';
import 'package:convo_hub/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.onGoogleSignIn});

  final VoidCallback onGoogleSignIn;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF111827)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideLayout = constraints.maxWidth >= 960;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: isWideLayout
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _BrandPanel(onGoogleSignIn: widget.onGoogleSignIn)),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _AuthCard(
                                      formKey: _formKey,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      nameController: _nameController,
                                      isSignUp: _isSignUp,
                                      onToggleMode: () => setState(() => _isSignUp = !_isSignUp),
                                      onGoogleSignIn: widget.onGoogleSignIn,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _BrandPanel(onGoogleSignIn: widget.onGoogleSignIn),
                                  const SizedBox(height: 20),
                                  _AuthCard(
                                    formKey: _formKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    nameController: _nameController,
                                    isSignUp: _isSignUp,
                                    onToggleMode: () => setState(() => _isSignUp = !_isSignUp),
                                    onGoogleSignIn: widget.onGoogleSignIn,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.onGoogleSignIn});

  final VoidCallback onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.forum_rounded, size: 54, color: AppColors.accent),
          const SizedBox(height: 24),
          Text('Convo Hub', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(
            'A Slack-style workspace for teams that need clean navigation, fast messaging, and a responsive desktop-first layout.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 28),
          const _FeatureRow(icon: Icons.lock_outline_rounded, title: 'Google OAuth', subtitle: 'Use your Google account to sign in or create a new workspace profile.'),
          const SizedBox(height: 16),
          const _FeatureRow(icon: Icons.bolt_rounded, title: 'Real-time sync', subtitle: 'Firestore streams keep channels and messages current across devices.'),
          const SizedBox(height: 16),
          const _FeatureRow(icon: Icons.devices_rounded, title: 'Responsive shell', subtitle: 'Adapts from phone to tablet to widescreen desktop without breaking the flow.'),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onGoogleSignIn,
            icon: const Icon(Icons.login_rounded),
            label: const Text('Continue with Google'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.isSignUp,
    required this.onToggleMode,
    required this.onGoogleSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final bool isSignUp;
  final VoidCallback onToggleMode;
  final VoidCallback onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isSignUp ? 'Create your account' : 'Sign in', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(
              isSignUp ? 'Use Google OAuth or email/password to join the workspace.' : 'Use Google OAuth or your existing email/password.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            if (isSignUp) ...[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) => value == null || value.length < 6 ? 'Use at least 6 characters' : null,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final bloc = context.read<AuthBloc>();
                if (isSignUp) {
                  bloc.add(AuthEmailSignUpRequested(name: nameController.text.trim(), email: emailController.text.trim(), password: passwordController.text));
                } else {
                  bloc.add(AuthEmailSignInRequested(email: emailController.text.trim(), password: passwordController.text));
                }
              },
              icon: Icon(isSignUp ? Icons.person_add_alt_1_rounded : Icons.login_rounded),
              label: Text(isSignUp ? 'Create account' : 'Sign in with email'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onGoogleSignIn,
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onToggleMode,
              child: Text(isSignUp ? 'Already have an account? Sign in' : 'Need an account? Create one'),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthFailure) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(state.message, style: const TextStyle(color: AppColors.danger)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}