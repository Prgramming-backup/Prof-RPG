import 'package:flutter_test/flutter_test.dart';

import 'package:prod/services/task_repository.dart';
import 'package:prod/state/task_controller.dart';

void main() {
  test('completing a task awards its base XP once', () {
    final controller = TaskController(InMemoryTaskRepository());
    final task = controller.createTask(title: 'Gym', xpReward: 20);

    controller.completeTask(task.id);
    controller.completeTask(task.id);

    expect(controller.totalXp, 20);
    expect(controller.xpTransactions, hasLength(1));
    expect(controller.xpTransactions.single.sourceTaskId, task.id);
    expect(controller.xpTransactions.single.awardedXp, 20);
  });

  test('undoing completion reverses XP before a new completion can award again', () {
    final controller = TaskController(InMemoryTaskRepository());
    final task = controller.createTask(title: 'Read', xpReward: 10);

    controller.completeTask(task.id);
    controller.uncompleteTask(task.id);
    expect(controller.totalXp, 0);

    controller.completeTask(task.id);
    expect(controller.totalXp, 10);
  });
}
