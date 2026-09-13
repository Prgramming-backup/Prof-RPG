import 'package:flutter_test/flutter_test.dart';
import 'package:prod/models/quest_type.dart';
import 'package:prod/models/recurrence_rule.dart';
import 'package:prod/models/task.dart';
import 'package:prod/services/task_repository.dart';
import 'package:prod/state/task_controller.dart';

void main() {
  test('habit completion awards XP once per day and keeps the same task id', () {
    var now = DateTime(2026, 9, 13, 10);
    final controller = TaskController(
      InMemoryTaskRepository(clock: () => now),
      clock: () => now,
    );

    final task = controller.createTask(
      title: 'Exercise',
      xpReward: 20,
      questType: QuestType.habit,
      recurrence: RecurrenceRule.daily,
    );

    controller.completeTask(task.id);
    controller.completeTask(task.id);

    expect(controller.tasks, hasLength(1));
    expect(controller.tasks.single.id, task.id);
    expect(controller.tasks.single.isCompleted, isFalse);
    expect(controller.totalXp, 20);
    expect(controller.activeTasks, isEmpty);
    expect(controller.completedTasks, hasLength(1));

    now = DateTime(2026, 9, 14, 10);
    expect(controller.activeTasks, hasLength(1));
    expect(controller.activeTasks.single.id, task.id);
    expect(controller.completedTasks, isEmpty);

    controller.completeTask(task.id);
    expect(controller.tasks, hasLength(1));
    expect(controller.totalXp, 41);
  });

  test('side quest stays permanently completed and does not return', () {
    final now = DateTime(2026, 9, 13, 10);
    final controller = TaskController(
      InMemoryTaskRepository(clock: () => now),
      clock: () => now,
    );

    final task = controller.createTask(
      title: 'Clean my room',
      xpReward: 15,
      questType: QuestType.sideQuest,
    );
    controller.completeTask(task.id);

    expect(controller.tasks.single.isCompleted, isTrue);
    expect(controller.totalXp, 15);
    expect(controller.activeTasks, isEmpty);
    expect(controller.completedTasks, hasLength(1));
  });

  test('monthly habit is completable only on the selected day', () {
    var now = DateTime(2026, 9, 13, 10);
    final controller = TaskController(
      InMemoryTaskRepository(clock: () => now),
      clock: () => now,
    );

    final task = controller.createTask(
      title: 'Pay monthly bill',
      xpReward: 25,
      questType: QuestType.habit,
      recurrence: RecurrenceRule.monthly(20),
    );

    controller.completeTask(task.id);
    expect(controller.totalXp, 0);
    expect(controller.activeTasks, hasLength(1));

    now = DateTime(2026, 9, 20, 10);
    controller.completeTask(task.id);
    expect(controller.totalXp, 25);
    expect(controller.tasks.single.id, task.id);
    expect(controller.completedTasks.single.id, task.id);
  });

  test('legacy task JSON without quest type loads as a side quest', () {
    final task = Task.fromJson({
      'id': 'task_1',
      'title': 'Gym',
      'description': null,
      'xpReward': 20,
      'dueDate': null,
      'isCompleted': false,
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      'completedAt': null,
    });

    expect(task.questType, QuestType.sideQuest);
    expect(task.recurrence, isNull);
    expect(task.completedDates, isEmpty);

    final roundTrip = Task.fromJson(task.toJson());
    expect(roundTrip.questType, QuestType.sideQuest);
  });

  test('habit recurrence and occurrence history survive JSON round-trip', () {
    final original = Task(
      id: 'task_9',
      title: 'Pay monthly bill',
      xpReward: 25,
      createdAt: DateTime(2026, 1, 1),
      questType: QuestType.habit,
      recurrence: RecurrenceRule.monthly(20),
      completedDates: [DateTime(2026, 8, 20, 9)],
      completedAt: DateTime(2026, 8, 20, 9),
    );

    final restored = Task.fromJson(original.toJson());
    expect(restored.questType, QuestType.habit);
    expect(restored.recurrence, RecurrenceRule.monthly(20));
    expect(restored.completedDates, hasLength(1));
    expect(restored.hasCompletedOn(DateTime(2026, 8, 20)), isTrue);
  });
}
