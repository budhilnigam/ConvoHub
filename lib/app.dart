import 'package:convo_hub/presentation/screens/auth/auth_gate.dart';
import 'package:convo_hub/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ConvoHubApp extends StatelessWidget {
  const ConvoHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Convo Hub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}