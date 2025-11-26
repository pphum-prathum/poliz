import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poliz/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> loginAndGoToIncidentImportantRanking(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('usernameField')), 'Earn');
    await tester.enterText(find.byKey(const ValueKey('passwordField')), 'Earn');
    await tester.tap(find.byKey(const ValueKey('loginButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('AIRankingCard')));
    await tester.pumpAndSettle();
  }

  testWidgets('TC_INCIDENT_ADD_01', (WidgetTester tester) async {
    await loginAndGoToIncidentImportantRanking(tester);

    // Select Incident Type
    await tester.tap(find.byKey(const ValueKey('typeDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fire').last);
    await tester.pumpAndSettle();

    // Enter Place
    await tester.enterText(find.byKey(const ValueKey('placeField')), 'ICT, Mahidol University');
    await tester.enterText(find.byKey(const ValueKey('latitudeField')), '13.7563');
    await tester.enterText(find.byKey(const ValueKey('longtitudeField')), '100.5018');

    // open picker
    await tester.tap(find.byKey(const ValueKey('datetimePicker')));
    await tester.pumpAndSettle();

    // --- DATE PICKER ---
    await tester.tap(find.text(6.toString()));
    await tester.tap(find.text('OK'));  // close date picker
    await tester.pumpAndSettle(Duration(seconds: 2));

    // --- TIME PICKER ---
    await tester.tap(find.byTooltip('Switch to text input mode'));
    await tester.pumpAndSettle();

    // The hour and minute inputs don't have a key or tooltip so we find them
    // by type and then use the index to enter the value.
    final inputs = find.byType(TextFormField);

    await tester.enterText(inputs.at(0), 10.toString());
    await tester.enterText(inputs.at(1), 30.toString());

    await tester.tap(find.text('AM'));  // toggle PM
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Enter Notes
    await tester.enterText(find.byKey(const ValueKey('notesField')), 'Smoke coming from 3rd floor, possible fire.');
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.byKey(const ValueKey('submitIncident')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.descendant(
    of: find.byType(ListView), 
    matching: find.text('Fire @ ICT, Mahidol University'),
    ),
    findsOneWidget,);
    
  
    // expect(find.text('Fire @ ICT, Mahidol University'), findsOne);

  });

  testWidgets('TC_INCIDENT_ADD_02', (WidgetTester tester) async {

    await loginAndGoToIncidentImportantRanking(tester);
  
      // Select Incident Type
    await tester.tap(find.byKey(const ValueKey('typeDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fire').last);
    await tester.pumpAndSettle();

    // open picker
    await tester.tap(find.byKey(const ValueKey('datetimePicker')));
    await tester.pumpAndSettle();

    // --- DATE PICKER ---
    await tester.tap(find.text(6.toString()));
    await tester.tap(find.text('OK'));  // close date picker
    await tester.pumpAndSettle(Duration(seconds: 2));

    // --- TIME PICKER ---
    await tester.tap(find.byTooltip('Switch to text input mode'));
    await tester.pumpAndSettle();

    // The hour and minute inputs don't have a key or tooltip so we find them
    // by type and then use the index to enter the value.
    final inputs = find.byType(TextFormField);

    await tester.enterText(inputs.at(0), 10.toString());
    await tester.enterText(inputs.at(1), 30.toString());

    await tester.tap(find.text('AM'));  // toggle PM
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Enter Notes
    await tester.enterText(find.byKey(const ValueKey('notesField')), 'Smoke coming from 3rd floor, possible fire.');
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.byKey(const ValueKey('submitIncident')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.descendant(
    of: find.byType(SnackBar), 
    matching: find.text('Place is required'),
    ),
    findsOneWidget);

    // expect(find.text('Place is required'), findsOne);
  });
}
