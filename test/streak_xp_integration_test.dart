import 'package:flutter_test/flutter_test.dart';
import 'package:prod/services/task_repository.dart';
import 'package:prod/state/task_controller.dart';

void main() {
  group('Streak Engine & XP Reward Integration', () {
    test('one task on first day', () {
      final day1 = DateTime.utc(2026, 9, 10, 10, 0);
      final repository = InMemoryTaskRepository(clock: () => day1);
      final controller = TaskController(repository, clock: () => day1);

      final task = controller.createTask(title: 'Quest 1', xpReward: 20);
      controller.completeTask(task.id);

      expect(controller.currentStreak, 1);
      expect(controller.currentMultiplier, 1.00);
      expect(controller.totalXp, 20);

      expect(controller.xpTransactions, hasLength(1));
      final tx = controller.xpTransactions.single;
      expect(tx.taskId, task.id);
      expect(tx.sourceTaskId, task.id);
      expect(tx.baseXp, 20);
      expect(tx.multiplier, 1.00);
      expect(tx.finalXp, 20);
      expect(tx.awardedXp, 20);
      expect(tx.timestamp, day1);
    });

    test('multiple tasks on same day do not create multiple streak days', () {
      var now = DateTime.utc(2026, 9, 10, 9, 0);
      final repository = InMemoryTaskRepository(clock: () => now);
      final controller = TaskController(repository, clock: () => now);

      final task1 = controller.createTask(title: 'Quest 1', xpReward: 20);
      final task2 = controller.createTask(title: 'Quest 2', xpReward: 30);
      final task3 = controller.createTask(title: 'Quest 3', xpReward: 15);

      controller.completeTask(task1.id);
      expect(controller.currentStreak, 1);
      expect(controller.currentMultiplier, 1.00);

      now = DateTime.utc(2026, 9, 10, 12, 30);
      controller.completeTask(task2.id);
      expect(controller.currentStreak, 1);
      expect(controller.currentMultiplier, 1.00);

      now = DateTime.utc(2026, 9, 10, 21, 15);
      controller.completeTask(task3.id);
      expect(controller.currentStreak, 1);
      expect(controller.currentMultiplier, 1.00);

      // All tasks completed on same day receive the day's applicable multiplier (1.00x)
      expect(controller.totalXp, 65);
      expect(controller.xpTransactions, hasLength(3));

      expect(controller.xpTransactions[0].multiplier, 1.00);
      expect(controller.xpTransactions[0].finalXp, 20);

      expect(controller.xpTransactions[1].multiplier, 1.00);
      expect(controller.xpTransactions[1].finalXp, 30);

      expect(controller.xpTransactions[2].multiplier, 1.00);
      expect(controller.xpTransactions[2].finalXp, 15);
    });

    test('consecutive productive days increase multiplier and final XP', () {
      var now = DateTime.utc(2026, 9, 10, 10, 0);
      final repository = InMemoryTaskRepository(clock: () => now);
      final controller = TaskController(repository, clock: () => now);

      final task1 = controller.createTask(title: 'Day 1 Quest', xpReward: 20);
      final task2 = controller.createTask(title: 'Day 2 Quest', xpReward: 20);
      final task3 = controller.createTask(title: 'Day 3 Quest', xpReward: 20);

      controller.completeTask(task1.id);
      expect(controller.xpTransactions[0].multiplier, 1.00);
      expect(controller.xpTransactions[0].finalXp, 20);
      expect(controller.currentStreak, 1);

      now = DateTime.utc(2026, 9, 11, 14, 0);
      controller.completeTask(task2.id);
      expect(controller.xpTransactions[1].multiplier, 1.05);
      // 20 * 1.05 = 21
      expect(controller.xpTransactions[1].finalXp, 21);
      expect(controller.currentStreak, 2);

      now = DateTime.utc(2026, 9, 12, 9, 30);
      controller.completeTask(task3.id);
      expect(controller.xpTransactions[2].multiplier, 1.10);
      // 20 * 1.10 = 22
      expect(controller.xpTransactions[2].finalXp, 22);
      expect(controller.currentStreak, 3);

      expect(controller.totalXp, 20 + 21 + 22);
    });

    test('all tasks completed on the same consecutive day receive the day multiplier', () {
      var now = DateTime.utc(2026, 9, 10, 10, 0);
      final repository = InMemoryTaskRepository(clock: () => now);
      final controller = TaskController(repository, clock: () => now);

      final t1 = controller.createTask(title: 'Day 1 Quest', xpReward: 40);
      final t2 = controller.createTask(title: 'Day 2 Quest A', xpReward: 40);
      final t3 = controller.createTask(title: 'Day 2 Quest B', xpReward: 60);

      controller.completeTask(t1.id);
      expect(controller.xpTransactions[0].multiplier, 1.00);
      expect(controller.xpTransactions[0].finalXp, 40);

      now = DateTime.utc(2026, 9, 11, 8, 0);
      controller.completeTask(t2.id);
      expect(controller.xpTransactions[1].multiplier, 1.05);
      // 40 * 1.05 = 42
      expect(controller.xpTransactions[1].finalXp, 42);

      now = DateTime.utc(2026, 9, 11, 20, 0);
      controller.completeTask(t3.id);
      expect(controller.xpTransactions[2].multiplier, 1.05);
      // 60 * 1.05 = 63
      expect(controller.xpTransactions[2].finalXp, 63);

      expect(controller.currentStreak, 2);
      expect(controller.totalXp, 40 + 42 + 63);
    });

    test('one missed day breaks streak but does NOT deduct XP, restart gives 1.00x', () {
      var now = DateTime.utc(2026, 9, 10, 10, 0);
      final repository = InMemoryTaskRepository(clock: () => now);
      final controller = TaskController(repository, clock: () => now);

      final t1 = controller.createTask(title: 'Quest 1', xpReward: 20);
      final t2 = controller.createTask(title: 'Quest 2', xpReward: 20);
      final t3 = controller.createTask(title: 'Quest 3', xpReward: 20);

      controller.completeTask(t1.id);
      now = DateTime.utc(2026, 9, 11, 10, 0);
      controller.completeTask(t2.id);

      final xpBeforeBreak = controller.totalXp;
      expect(xpBeforeBreak, 20 + 21); // 41
      expect(controller.currentStreak, 2);

      // Day 3 (2026-09-12) is missed! Check on Day 3:
      now = DateTime.utc(2026, 9, 12, 12, 0);
      // Streak from yesterday is still 2 pending today's completion
      expect(controller.streakInfo().streakLength, 2);
      expect(controller.streakInfo().isTodayProductive, isFalse);

      // Now it's Day 4 (2026-09-13): Day 3 was missed!
      now = DateTime.utc(2026, 9, 13, 10, 0);
      // Before completing any task on Day 4, streak is broken:
      expect(controller.currentStreak, 0);

      // Completing on Day 4 restarts streak at 1 with 1.00x
      controller.completeTask(t3.id);

      expect(controller.currentStreak, 1);
      expect(controller.xpTransactions[2].multiplier, 1.00);
      expect(controller.xpTransactions[2].finalXp, 20);

      // Past XP was NOT deducted
      expect(controller.totalXp, 41 + 20);
    });

    test('multiplier cap enforces maximum of 1.50x', () {
      var now = DateTime.utc(2026, 9, 1, 12, 0);
      final repository = InMemoryTaskRepository(clock: () => now);
      final controller = TaskController(repository, clock: () => now);

      // Complete 12 consecutive days
      for (var day = 1; day <= 12; day++) {
        now = DateTime.utc(2026, 9, day, 12, 0);
        final task = controller.createTask(
          title: 'Quest $day',
          xpReward: 100,
        );
        controller.completeTask(task.id);
      }

      expect(controller.xpTransactions, hasLength(12));

      // Day 1: 1.00
      expect(controller.xpTransactions[0].multiplier, 1.00);
      expect(controller.xpTransactions[0].finalXp, 100);

      // Day 2: 1.05
      expect(controller.xpTransactions[1].multiplier, 1.05);
      expect(controller.xpTransactions[1].finalXp, 105);

      // Day 11 reaches 1.50
      expect(controller.xpTransactions[10].multiplier, 1.50);
      expect(controller.xpTransactions[10].finalXp, 150);

      // Day 12 is capped at 1.50x
      expect(controller.xpTransactions[11].multiplier, 1.50);
      expect(controller.xpTransactions[11].finalXp, 150);
      expect(controller.currentStreak, 12);
      expect(controller.currentMultiplier, 1.50);
    });

    test('duplicate completion only rewards XP once', () {
      final day1 = DateTime.utc(2026, 9, 10, 10, 0);
      final repository = InMemoryTaskRepository(clock: () => day1);
      final controller = TaskController(repository, clock: () => day1);

      final task = controller.createTask(title: 'Quest 1', xpReward: 30);

      controller.completeTask(task.id);
      controller.completeTask(task.id);

      expect(controller.xpTransactions, hasLength(1));
      expect(controller.totalXp, 30);
    });

    test('correct final XP rounding with multipliers', () {
      var now = DateTime.utc(2026, 9, 10, 10, 0);
      final repository = InMemoryTaskRepository(clock: () => now);
      final controller = TaskController(repository, clock: () => now);

      // Day 1 (1.00x)
      final t1 = controller.createTask(title: 'Quest 1', xpReward: 25);
      controller.completeTask(t1.id);
      expect(controller.xpTransactions[0].finalXp, 25);

      // Day 2 (1.05x): 25 * 1.05 = 26.25 -> rounded to 26
      now = DateTime.utc(2026, 9, 11, 10, 0);
      final t2 = controller.createTask(title: 'Quest 2', xpReward: 25);
      controller.completeTask(t2.id);
      expect(controller.xpTransactions[1].finalXp, 26);

      // Day 3 (1.10x): 35 * 1.10 = 38.50 -> rounded to 39
      now = DateTime.utc(2026, 9, 12, 10, 0);
      final t3 = controller.createTask(title: 'Quest 3', xpReward: 35);
      controller.completeTask(t3.id);
      expect(controller.xpTransactions[2].finalXp, 39);
    });
  });
}
