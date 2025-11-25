import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poliz/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> loginAndGoToSecureChat(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('usernameField')), 'Nine');
    await tester.enterText(find.byKey(const ValueKey('passwordField')), 'Nine');
    await tester.tap(find.byKey(const ValueKey('loginButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('secureChatCard')));
    await tester.pumpAndSettle();

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const ValueKey('searchBox')).evaluate().isNotEmpty) break;
    }
    expect(find.byKey(const ValueKey('searchBox')), findsOneWidget);
  }

  group('User List & Search', () {
    testWidgets('TC_USER_SEARCH_01: Happy Path – found Ploy', (tester) async {
      await loginAndGoToSecureChat(tester);
      await tester.enterText(find.byKey(const ValueKey('searchBox')), 'Ploy');
      await tester.pumpAndSettle();
expect(
  find.descendant(
    of: find.byType(ListView), 
    matching: find.text('Ploy'),
  ),
  findsOneWidget,
);
    });

testWidgets('TC_USER_SEARCH_02: Unhappy Path – not found', (tester) async {
  await loginAndGoToSecureChat(tester);
  await tester.enterText(find.byKey(const ValueKey('searchBox')), 'eiei');
  await tester.pumpAndSettle();

expect(
  find.descendant(
    of: find.byType(ListView),
    matching: find.text('eiei'),
  ),
  findsNothing,
);
  expect(find.text('Not Found'), findsOneWidget); 
});

  });
}
