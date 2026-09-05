import 'package:flutter_test/flutter_test.dart';

import 'package:prod/app.dart';

void main() {
  testWidgets('shows home and can open other destinations', (tester) async {
    await tester.pumpWidget(const ProRpgApp());

    expect(find.text('Pro-RPG'), findsOneWidget);
    expect(find.text('Adventure board'), findsOneWidget);

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
}
