import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:convo_hub/app.dart';
import 'package:convo_hub/core/services/firebase_bootstrap.dart';
import 'package:convo_hub/injection_container.dart';

void main() {
  testWidgets('renders the app shell', (WidgetTester tester) async {
    await dotenv.load(fileName: '.env');
    await bootstrapFirebase();
    await configureInjection();

    await tester.pumpWidget(const ConvoHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Convo Hub'), findsWidgets);
    expect(find.text('Workspaces'), findsOneWidget);
  });
}
