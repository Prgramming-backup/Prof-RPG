import 'package:flutter_test/flutter_test.dart';

import 'package:prod/services/task_repository.dart';
import 'package:prod/services/xp_completion_id.dart';
import 'package:prod/services/xp_engine.dart';
import 'package:prod/services/xp_ledger.dart';

void main() {
  late InMemoryXpLedger ledger;
  final fixedTime = DateTime.utc(2026, 9, 6, 12);

  setUp(() {
    ledger = InMemoryXpLedger(
      engine: const XpEngine(),
      clock: () => fixedTime,
    );
  });

  test('records a transaction for a normal reward', () {
    final result = ledger.award(
      sourceTaskId: 'task_1',
      baseXp: 20,
      completionId: 'task_1:1',
    );

    expect(result.isAwarded, isTrue);
    expect(result.transaction, isNotNull);
    expect(result.transaction!.sourceTaskId, 'task_1');
    expect(result.transaction!.baseXp, 20);
    expect(result.transaction!.awardedXp, 20);
    expect(result.transaction!.timestamp, fixedTime);
    expect(ledger.totalXp, 20);
  });

  test('does not record a transaction for zero or invalid XP', () {
    final zero = ledger.award(
      sourceTaskId: 'task_1',
      baseXp: 0,
      completionId: 'task_1:1',
    );
    final negative = ledger.award(
      sourceTaskId: 'task_2',
      baseXp: -5,
      completionId: 'task_2:1',
    );

    expect(zero.decision.status, XpAwardStatus.invalidXp);
    expect(zero.transaction, isNull);
    expect(negative.decision.status, XpAwardStatus.invalidXp);
    expect(ledger.transactions, isEmpty);
    expect(ledger.totalXp, 0);
  });

  test('prevents duplicate rewards for the same completion', () {
    ledger.award(
      sourceTaskId: 'task_1',
      baseXp: 10,
      completionId: 'task_1:100',
    );
    final duplicate = ledger.award(
      sourceTaskId: 'task_1',
      baseXp: 10,
      completionId: 'task_1:100',
    );

    expect(duplicate.decision.status, XpAwardStatus.duplicate);
    expect(duplicate.transaction, isNull);
    expect(ledger.transactions, hasLength(1));
    expect(ledger.totalXp, 10);
  });

  test('undoing a completion reverses XP so a later completion is not a duplicate', () {
    const completionId = 'task_1:100';
    ledger.award(
      sourceTaskId: 'task_1',
      baseXp: 10,
      completionId: completionId,
    );

    final reversed = ledger.reverseForCompletion(completionId);
    expect(reversed, isNotNull);
    expect(reversed!.reversed, isTrue);
    expect(ledger.totalXp, 0);

    final again = ledger.award(
      sourceTaskId: 'task_1',
      baseXp: 10,
      completionId: 'task_1:200',
    );

    expect(again.isAwarded, isTrue);
    expect(ledger.totalXp, 10);
    expect(ledger.transactions.where((tx) => !tx.reversed), hasLength(1));
  });

  test('re-awarding the same completion after undo does not stack silently', () {
    const completionId = 'task_1:100';
    ledger.award(
      sourceTaskId: 'task_1',
      baseXp: 15,
      completionId: completionId,
    );
    ledger.reverseForCompletion(completionId);

    final sameCompletion = ledger.award(
      sourceTaskId: 'task_1',
      baseXp: 15,
      completionId: completionId,
    );

    expect(sameCompletion.isAwarded, isTrue);
    expect(ledger.totalXp, 15);
  });

  test('uses the same completion id helper as task completion timestamps', () {
    final completedAt = DateTime.utc(2026, 9, 6, 8);
    final id = xpCompletionId(taskId: 'task_4', completedAt: completedAt);

    expect(id, 'task_4:${completedAt.microsecondsSinceEpoch}');
    expect(
      xpCompletionId(taskId: 'task_4', completedAt: completedAt),
      id,
    );
  });

  test('awards through a real task completion without depending on widgets', () {
    final repository = InMemoryTaskRepository();
    final created = repository.create(title: 'Gym', xpReward: 10);
    final completed = repository.complete(created.id);
    final completionId = xpCompletionId(
      taskId: completed.id,
      completedAt: completed.completedAt!,
    );

    final first = ledger.award(
      sourceTaskId: completed.id,
      baseXp: completed.xpReward,
      completionId: completionId,
    );
    final duplicate = ledger.award(
      sourceTaskId: completed.id,
      baseXp: completed.xpReward,
      completionId: completionId,
    );

    expect(first.transaction!.awardedXp, 10);
    expect(duplicate.decision.status, XpAwardStatus.duplicate);

    repository.uncomplete(completed.id);
    ledger.reverseForCompletion(completionId);
    expect(ledger.totalXp, 0);

    final completedAgain = repository.complete(created.id);
    final secondId = xpCompletionId(
      taskId: completedAgain.id,
      completedAt: completedAgain.completedAt!,
    );
    final secondAward = ledger.award(
      sourceTaskId: completedAgain.id,
      baseXp: completedAgain.xpReward,
      completionId: secondId,
    );

    expect(secondAward.isAwarded, isTrue);
    expect(ledger.totalXp, 10);
  });
}
