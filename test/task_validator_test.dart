import 'package:flutter_test/flutter_test.dart';

import 'package:prod/services/date_display.dart';
import 'package:prod/services/task_validator.dart';

void main() {
  const validator = TaskValidator();

  test('rejects a blank title and non-positive XP', () {
    final result = validator.validate(title: '   ', xpText: '0');

    expect(result.isValid, isFalse);
    expect(result.titleError, isNotNull);
    expect(result.xpError, isNotNull);
  });

  test('accepts a trimmed title and positive XP', () {
    final result = validator.validate(title: ' Coding ', xpText: '20');

    expect(result.isValid, isTrue);
    expect(validator.parseXp('20'), 20);
    expect(validator.normalizeDescription('  notes  '), 'notes');
    expect(validator.normalizeDescription('   '), isNull);
  });

  test('detects overdue due dates by calendar day', () {
    expect(
      isDueDateOverdue(DateTime(2026, 9, 4), DateTime(2026, 9, 5)),
      isTrue,
    );
    expect(
      isDueDateOverdue(DateTime(2026, 9, 5), DateTime(2026, 9, 5)),
      isFalse,
    );
  });
}
