import 'package:flutter_test/flutter_test.dart';
import 'package:prod/models/quest_type.dart';
import 'package:prod/models/recurrence_rule.dart';
import 'package:prod/models/task.dart';
import 'package:prod/services/recurrence_engine.dart';

void main() {
  const engine = RecurrenceEngine();

  Task habit({
    RecurrenceRule? recurrence,
    DateTime? createdAt,
    List<DateTime> completedDates = const [],
  }) {
    return Task(
      id: 'task_1',
      title: 'Pay monthly bill',
      xpReward: 20,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
      questType: QuestType.habit,
      recurrence: recurrence,
      completedDates: completedDates,
    );
  }

  test('daily habit is due every day after creation', () {
    final task = habit(recurrence: RecurrenceRule.daily);
    expect(engine.isDueOn(task, DateTime(2026, 9, 13)), isTrue);
    expect(engine.canComplete(task, DateTime(2026, 9, 13)), isTrue);
  });

  test('monthly habit is due on the configured day of each month', () {
    final task = habit(recurrence: RecurrenceRule.monthly(20));
    expect(engine.isDueOn(task, DateTime(2026, 9, 20)), isTrue);
    expect(engine.isDueOn(task, DateTime(2026, 10, 20)), isTrue);
    expect(engine.isDueOn(task, DateTime(2026, 9, 19)), isFalse);
    expect(engine.canComplete(task, DateTime(2026, 9, 20)), isTrue);
    expect(engine.canComplete(task, DateTime(2026, 9, 13)), isFalse);
  });

  test('monthly habit on the 31st uses the last day of shorter months', () {
    final task = habit(recurrence: RecurrenceRule.monthly(31));
    expect(engine.isDueOn(task, DateTime(2026, 2, 28)), isTrue);
    expect(engine.isDueOn(task, DateTime(2026, 2, 27)), isFalse);
    expect(engine.isDueOn(task, DateTime(2026, 3, 31)), isTrue);
  });

  test('weekly habit is due only on selected weekdays', () {
    final task = habit(
      recurrence: RecurrenceRule.weekly([DateTime.monday, DateTime.wednesday]),
    );
    expect(engine.isDueOn(task, DateTime(2026, 9, 14)), isTrue); // Monday
    expect(engine.isDueOn(task, DateTime(2026, 9, 16)), isTrue); // Wednesday
    expect(engine.isDueOn(task, DateTime(2026, 9, 15)), isFalse); // Tuesday
  });

  test('custom day-of-month recurrence matches that date each month', () {
    final task = habit(recurrence: RecurrenceRule.custom(dayOfMonth: 20));
    expect(engine.isDueOn(task, DateTime(2026, 9, 20)), isTrue);
    expect(engine.isDueOn(task, DateTime(2026, 9, 21)), isFalse);
  });

  test('habit cannot be completed twice on the same day', () {
    final today = DateTime(2026, 9, 13, 8);
    final task = habit(
      recurrence: RecurrenceRule.daily,
      completedDates: [today],
    );
    expect(engine.canComplete(task, DateTime(2026, 9, 13, 21)), isFalse);
    expect(engine.canComplete(task, DateTime(2026, 9, 14)), isTrue);
  });

  test('side quests are completable until permanently finished', () {
    const task = Task(
      id: 'task_2',
      title: 'Clean my room',
      xpReward: 15,
      createdAt: DateTime(2026, 9, 1),
    );
    expect(engine.canComplete(task, DateTime(2026, 9, 13)), isTrue);
    expect(
      engine.canComplete(
        task.copyWith(isCompleted: true, completedAt: DateTime(2026, 9, 13)),
        DateTime(2026, 9, 14),
      ),
      isFalse,
    );
  });
}
