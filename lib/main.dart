import 'package:convo_hub/app.dart';
import 'package:convo_hub/core/services/firebase_bootstrap.dart';
import 'package:convo_hub/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await bootstrapFirebase();
  await configureInjection();
  runApp(const ConvoHubApp());
}
