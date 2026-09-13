import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prod/models/avatar_tier.dart';
import 'package:prod/screens/character_screen.dart';
import 'package:prod/services/avatar_engine.dart';
import 'package:prod/services/level_engine.dart';
import 'package:prod/services/task_repository.dart';
import 'package:prod/state/task_controller.dart';
import 'package:prod/state/task_scope.dart';
import 'package:prod/widgets/player_avatar.dart';

void main() {
  const engine = AvatarEngine();

  group('Avatar Progression Tier Boundaries', () {
    const boundaryCases = <int, (AvatarTier, String)> {
      1: (AvatarTier.yoyaimo, 'Yoyaimo'),
      4: (AvatarTier.yoyaimo, 'Yoyaimo'),
      5: (AvatarTier.karen, 'Karen'),
      9: (AvatarTier.karen, 'Karen'),
      10: (AvatarTier.npc, 'NPC'),
      14: (AvatarTier.npc, 'NPC'),
      15: (AvatarTier.broIsTrying, 'Bro Is Trying'),
      19: (AvatarTier.broIsTrying, 'Bro Is Trying'),
      20: (AvatarTier.lockIn, 'Lock In'),
      24: (AvatarTier.lockIn, 'Lock In'),
      25: (AvatarTier.grinder, 'Grinder'),
      29: (AvatarTier.grinder, 'Grinder'),
      30: (AvatarTier.based, 'Based'),
      34: (AvatarTier.based, 'Based'),
      35: (AvatarTier.chadApprentice, 'Chad Apprentice'),
      39: (AvatarTier.chadApprentice, 'Chad Apprentice'),
      40: (AvatarTier.chad, 'Chad'),
      49: (AvatarTier.chad, 'Chad'),
      50: (AvatarTier.sigma, 'Sigma'),
      59: (AvatarTier.sigma, 'Sigma'),
      60: (AvatarTier.sigmaGrindset, 'Sigma Grindset'),
      69: (AvatarTier.sigmaGrindset, 'Sigma Grindset'),
      70: (AvatarTier.alpha, 'Alpha'),
      79: (AvatarTier.alpha, 'Alpha'),
      80: (AvatarTier.gigaChad, 'GigaChad'),
      99: (AvatarTier.gigaChad, 'GigaChad'),
      100: (AvatarTier.ultraChad, 'UltraChad'),
      149: (AvatarTier.ultraChad, 'UltraChad'),
      150: (AvatarTier.him, 'HIM'),
      199: (AvatarTier.him, 'HIM'),
      200: (AvatarTier.builtDifferent, 'Built Different'),
      299: (AvatarTier.builtDifferent, 'Built Different'),
      300: (AvatarTier.finalBoss, 'Final Boss'),
      499: (AvatarTier.finalBoss, 'Final Boss'),
      500: (AvatarTier.productivityDemon, 'Productivity Demon'),
      1000: (AvatarTier.productivityDemon, 'Productivity Demon'),
    };

    boundaryCases.forEach((level, expected) {
      test('level $level maps to ${expected.$2} (${expected.$1.name})', () {
        final progression = engine.progressionFor(level: level);
        expect(progression.tier, expected.$1);
        expect(progression.title, expected.$2);
      });
    });
  });

  group('Safety & Edge Cases', () {
    test('level below 1 (0, negative) is handled safely and clamps to level 1 Yoyaimo', () {
      final p0 = engine.progressionFor(level: 0);
      expect(p0.level, 1);
      expect(p0.tier, AvatarTier.yoyaimo);
      expect(p0.title, 'Yoyaimo');
      expect(p0.progress, 0.0);

      final pNeg = engine.progressionFor(level: -50);
      expect(pNeg.level, 1);
      expect(pNeg.tier, AvatarTier.yoyaimo);
      expect(pNeg.title, 'Yoyaimo');
      expect(pNeg.progress, 0.0);
    });

    test('progress is always between 0.0 and 1.0 across test levels', () {
      final sampleLevels = [-5, 0, 1, 2, 3, 4, 5, 8, 9, 10, 45, 80, 100, 350, 500, 9999];
      for (final lvl in sampleLevels) {
        final p = engine.progressionFor(level: lvl);
        expect(p.progress, greaterThanOrEqualTo(0.0));
        expect(p.progress, lessThanOrEqualTo(1.0));
      }
    });

    test('progress advances incrementally with XP through Yoyaimo (levels 1-4)', () {
      // Yoyaimo requires 813 cumulative XP to complete level 4 and reach level 5 (Karen)
      final p0 = engine.progressionFor(totalXp: 0);
      expect(p0.progress, 0.0);
      expect(p0.tier, AvatarTier.yoyaimo);

      // Completing a task for 50 XP moves the progress bar immediately
      final p50 = engine.progressionFor(totalXp: 50);
      expect(p50.progress, closeTo(50 / 813, 0.001));
      expect(p50.level, 1);

      // Reaching level 2 (100 XP) does NOT reset progress to 0%; it continues smoothly
      final p100 = engine.progressionFor(totalXp: 100);
      expect(p100.level, 2);
      expect(p100.progress, closeTo(100 / 813, 0.001));

      // Level 4 (475 XP cumulative)
      final p475 = engine.progressionFor(totalXp: 475);
      expect(p475.level, 4);
      expect(p475.progress, closeTo(475 / 813, 0.001));
    });

    test('progress resets to 0% at beginning of new tier (Karen at level 5 / 813 XP)', () {
      final l5 = engine.progressionFor(totalXp: 813);
      expect(l5.tier, AvatarTier.karen);
      expect(l5.title, 'Karen');
      expect(l5.progress, 0.0);
      expect(l5.nextTitle, 'NPC');

      // Karen spans levels 5-9; reaching level 10 completes Karen
      const levelEngine = LevelEngine();
      final karenStartXp = levelEngine.xpToReachLevel(5);
      final karenEndXp = levelEngine.xpToReachLevel(10);
      final karenSpan = karenEndXp - karenStartXp;

      final midKaren = engine.progressionFor(totalXp: karenStartXp + 200);
      expect(midKaren.tier, AvatarTier.karen);
      expect(midKaren.progress, closeTo(200 / karenSpan, 0.001));
    });

    test('final tier has no next tier and progress is 1.0', () {
      final p500 = engine.progressionFor(level: 500);
      expect(p500.tier, AvatarTier.productivityDemon);
      expect(p500.title, 'Productivity Demon');
      expect(p500.maxLevel, isNull);
      expect(p500.nextTier, isNull);
      expect(p500.nextTitle, isNull);
      expect(p500.hasNextEvolution, isFalse);
      expect(p500.progress, 1.0);

      final p1500 = engine.progressionFor(level: 1500);
      expect(p1500.tier, AvatarTier.productivityDemon);
      expect(p1500.nextTier, isNull);
      expect(p1500.hasNextEvolution, isFalse);
      expect(p1500.progress, 1.0);
    });
  });

  group('Avatar Progression UI Integration', () {
    testWidgets('PlayerAvatar renders level badge and icon without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAvatar(size: 100, level: 87),
          ),
        ),
      );

      expect(find.text('Lv 87'), findsOneWidget);
      expect(find.byType(PlayerAvatar), findsOneWidget);
    });

    testWidgets('CharacterScreen displays avatar progression title, level, and evolution progress',
        (tester) async {
      final controller = TaskController(InMemoryTaskRepository());
      await tester.pumpWidget(
        TaskScope(
          controller: controller,
          child: const MaterialApp(home: CharacterScreen()),
        ),
      );

      // Fresh player is Level 1 -> Yoyaimo
      expect(find.text('Yoyaimo'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Evolution Progress'), findsOneWidget);
      expect(find.byKey(const Key('avatar-evolution-percent')), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Next evolution: '), findsOneWidget);
      expect(find.text('Karen'), findsOneWidget);

      final bar = tester.widget<SizedBox>(
        find.byKey(const Key('avatar-evolution-bar')),
      );
      expect(bar.width, 0);
    });

    testWidgets('avatar percent and bar use the same AvatarEngine progress',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime(2026, 9, 12, 10);
      final controller = TaskController(
        InMemoryTaskRepository(clock: () => now),
        clock: () => now,
      );
      controller.createTask(title: 'Level up', xpReward: 100);
      controller.completeTask(controller.activeTasks.first.id, completedAt: now);

      await tester.pumpWidget(
        TaskScope(
          controller: controller,
          child: const MaterialApp(home: CharacterScreen()),
        ),
      );

      const engine = AvatarEngine();
      final expected = engine.progressionFor(
        totalXp: controller.totalXp,
        level: controller.levelProgress.level,
      );
      final percent = (expected.progress * 100).toStringAsFixed(0);

      expect(controller.avatarProgression, expected);
      expect(find.text('Level ${expected.level}'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('avatar-evolution-percent'))).data,
        '$percent%',
      );

      final trackWidth =
          tester.getSize(find.byKey(const Key('avatar-evolution-track'))).width;
      final bar = tester.widget<SizedBox>(
        find.byKey(const Key('avatar-evolution-bar')),
      );
      expect(bar.width, closeTo(trackWidth * expected.progress, 0.5));
    });

    testWidgets('completing a single task moves avatar bar/percentage immediately before level-up',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime(2026, 9, 12, 10);
      final controller = TaskController(
        InMemoryTaskRepository(clock: () => now),
        clock: () => now,
      );
      // Create a 50 XP task (Level 1 needs 100 XP to level up, Yoyaimo needs 813 XP to evolve)
      controller.createTask(title: 'Read chapter', xpReward: 50);

      await tester.pumpWidget(
        TaskScope(
          controller: controller,
          child: const MaterialApp(home: CharacterScreen()),
        ),
      );

      // Initially 0%
      expect(
        tester.widget<Text>(find.byKey(const Key('avatar-evolution-percent'))).data,
        '0%',
      );

      // Complete the task
      controller.completeTask(controller.activeTasks.first.id, completedAt: now);
      await tester.pump();

      // 50 / 813 = 6.15% -> displays 6% immediately while still at Level 1!
      expect(controller.levelProgress.level, 1);
      expect(
        tester.widget<Text>(find.byKey(const Key('avatar-evolution-percent'))).data,
        '6%',
      );

      final trackWidth =
          tester.getSize(find.byKey(const Key('avatar-evolution-track'))).width;
      final bar = tester.widget<SizedBox>(
        find.byKey(const Key('avatar-evolution-bar')),
      );
      expect(bar.width, closeTo(trackWidth * (50 / 813), 0.5));
    });
  });
}
