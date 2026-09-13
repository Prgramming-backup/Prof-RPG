import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prod/models/avatar_tier.dart';
import 'package:prod/screens/character_screen.dart';
import 'package:prod/services/avatar_engine.dart';
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
        final progression = engine.progressionFor(level);
        expect(progression.tier, expected.$1);
        expect(progression.title, expected.$2);
      });
    });
  });

  group('Safety & Edge Cases', () {
    test('level below 1 (0, negative) is handled safely and clamps to level 1 Yoyaimo', () {
      final p0 = engine.progressionFor(0);
      expect(p0.level, 1);
      expect(p0.tier, AvatarTier.yoyaimo);
      expect(p0.title, 'Yoyaimo');
      expect(p0.progress, 0.0);

      final pNeg = engine.progressionFor(-50);
      expect(pNeg.level, 1);
      expect(pNeg.tier, AvatarTier.yoyaimo);
      expect(pNeg.title, 'Yoyaimo');
      expect(pNeg.progress, 0.0);
    });

    test('progress is always between 0.0 and 1.0 across test levels', () {
      final sampleLevels = [-5, 0, 1, 2, 3, 4, 5, 8, 9, 10, 45, 80, 100, 350, 500, 9999];
      for (final lvl in sampleLevels) {
        final p = engine.progressionFor(lvl);
        expect(p.progress, greaterThanOrEqualTo(0.0));
        expect(p.progress, lessThanOrEqualTo(1.0));
      }
    });

    test('progress matches example progression within Yoyaimo (1-4)', () {
      final l1 = engine.progressionFor(1);
      expect(l1.progress, 0.0);

      final l2 = engine.progressionFor(2);
      expect(l2.progress, closeTo(1 / 3, 0.001));

      final l3 = engine.progressionFor(3);
      expect(l3.progress, closeTo(2 / 3, 0.001));

      final l4 = engine.progressionFor(4);
      expect(l4.progress, 1.0);
    });

    test('progress resets at beginning of new tier (Karen at level 5)', () {
      final l5 = engine.progressionFor(5);
      expect(l5.tier, AvatarTier.karen);
      expect(l5.title, 'Karen');
      expect(l5.progress, 0.0);
      expect(l5.nextTitle, 'NPC');

      final l9 = engine.progressionFor(9);
      expect(l9.tier, AvatarTier.karen);
      expect(l9.progress, 1.0);
    });

    test('final tier has no next tier and progress is 1.0', () {
      final p500 = engine.progressionFor(500);
      expect(p500.tier, AvatarTier.productivityDemon);
      expect(p500.title, 'Productivity Demon');
      expect(p500.maxLevel, isNull);
      expect(p500.nextTier, isNull);
      expect(p500.nextTitle, isNull);
      expect(p500.hasNextEvolution, isFalse);
      expect(p500.progress, 1.0);

      final p1500 = engine.progressionFor(1500);
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
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Next evolution: '), findsOneWidget);
      expect(find.text('Karen'), findsOneWidget);
    });
  });
}
