import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prod/app.dart';

void main() {
  testWidgets('shows home and can open other destinations', (tester) async {
    await tester.pumpWidget(const ProRpgApp());

    expect(find.text('Pro-RPG'), findsOneWidget);
    expect(find.text('No quests yet'), findsOneWidget);

    await tester.tap(find.text('Character'));
    await tester.pumpAndSettle();
    expect(find.text('Hero sheet'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Campaign log'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Guild options'), findsOneWidget);
  });

  testWidgets('creates, completes, edits, and deletes a task', (tester) async {
    await tester.pumpWidget(const ProRpgApp());

    await tester.tap(find.text('New quest'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save-task')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a task title.'), findsOneWidget);
    expect(find.text('Enter a whole number for the XP reward.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('task-title-field')), 'Gym');
    await tester.enterText(
      find.byKey(const Key('task-description-field')),
      'Leg day',
    );
    await tester.enterText(find.byKey(const Key('task-xp-field')), '20');
    await tester.tap(find.byKey(const Key('save-task')));
    await tester.pumpAndSettle();

    expect(find.text('Gym'), findsOneWidget);
    expect(find.text('Leg day'), findsOneWidget);
    expect(find.text('20 XP'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark complete'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsWidgets);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Gym session',
    );
    await tester.tap(find.byKey(const Key('save-task')));
    await tester.pumpAndSettle();
    expect(find.text('Gym session'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No quests yet'), findsOneWidget);
  });
}
