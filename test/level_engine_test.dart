import 'package:flutter_test/flutter_test.dart';
import 'package:prod/services/level_engine.dart';

void main() {
  // Default curve: baseXp = 100, growthFactor = 1.5.
  // Spans (XP width of each level), rounded:
  //   L1 = 100, L2 = 150, L3 = 225, L4 = 338, L5 = 506, L6 = 759
  // Cumulative thresholds (XP to *reach* a level):
  //   L1 = 0, L2 = 100, L3 = 250, L4 = 475, L5 = 813, L6 = 1319
  const engine = LevelEngine();

  group('XP curve (single source of truth)', () {
    test('xpSpanForLevel = baseXp * growthFactor^(level-1), rounded', () {
      expect(engine.xpSpanForLevel(1), 100);
      expect(engine.xpSpanForLevel(2), 150);
      expect(engine.xpSpanForLevel(3), 225);
      expect(engine.xpSpanForLevel(4), 338); // 337.5 rounds up
      expect(engine.xpSpanForLevel(5), 506); // 506.25 rounds down
      expect(engine.xpSpanForLevel(6), 759); // 759.375 rounds down
    });

    test('spans strictly increase — a gradual, non-linear curve', () {
      for (var level = 1; level < 40; level++) {
        expect(
          engine.xpSpanForLevel(level + 1),
          greaterThan(engine.xpSpanForLevel(level)),
          reason: 'level ${level + 1} should cost more XP than level $level',
        );
      }
    });

    test('xpToReachLevel is the cumulative sum of spans', () {
      expect(engine.xpToReachLevel(1), 0);
      expect(engine.xpToReachLevel(2), 100);
      expect(engine.xpToReachLevel(3), 250);
      expect(engine.xpToReachLevel(4), 475);
      expect(engine.xpToReachLevel(5), 813);
      expect(engine.xpToReachLevel(6), 1319);
    });
  });

  group('level 1', () {
    test('zero XP is level 1 with zero progress', () {
      final p = engine.progressFor(0);
      expect(p.level, 1);
      expect(p.totalXp, 0);
      expect(p.xpForCurrentLevel, 0);
      expect(p.xpForNextLevel, 100);
      expect(p.xpIntoCurrentLevel, 0);
      expect(p.progressToNextLevel, 0.0);
      expect(p.xpToNextLevel, 100);
      expect(p.xpSpanForCurrentLevel, 100);
    });

    test('negative XP is clamped to level 1 / zero', () {
      final p = engine.progressFor(-500);
      expect(p.level, 1);
      expect(p.totalXp, 0);
      expect(p.xpIntoCurrentLevel, 0);
      expect(p.progressToNextLevel, 0.0);
    });

    test('mid level 1 reports partial progress', () {
      final p = engine.progressFor(50);
      expect(p.level, 1);
      expect(p.xpIntoCurrentLevel, 50);
      expect(p.progressToNextLevel, 0.5);
    });
  });

  group('exact level boundaries', () {
    // Landing exactly on a cumulative threshold means the player has *just*
    // reached the new level: they map to the higher level and progress is 0.0.
    void expectBoundary(int totalXp, int level, int floor, int ceil) {
      final p = engine.progressFor(totalXp);
      expect(p.level, level, reason: '$totalXp XP should be level $level');
      expect(p.xpForCurrentLevel, floor);
      expect(p.xpForNextLevel, ceil);
      expect(p.xpIntoCurrentLevel, 0);
      expect(p.progressToNextLevel, 0.0);
    }

    test('each threshold lands exactly on the new level with 0.0 progress', () {
      expectBoundary(100, 2, 100, 250);
      expectBoundary(250, 3, 250, 475);
      expectBoundary(475, 4, 475, 813);
      expectBoundary(813, 5, 813, 1319);
    });
  });

  group('just below a level boundary', () {
    test('1 XP short of level 2 stays level 1 with near-full progress', () {
      final p = engine.progressFor(99);
      expect(p.level, 1);
      expect(p.xpForCurrentLevel, 0);
      expect(p.xpForNextLevel, 100);
      expect(p.xpIntoCurrentLevel, 99);
      expect(p.xpToNextLevel, 1);
      expect(p.progressToNextLevel, closeTo(0.99, 1e-9));
      expect(p.progressToNextLevel, lessThan(1.0));
    });

    test('1 XP short of level 3 stays level 2', () {
      final p = engine.progressFor(249);
      expect(p.level, 2);
      expect(p.xpForCurrentLevel, 100);
      expect(p.xpForNextLevel, 250);
      expect(p.xpIntoCurrentLevel, 149);
      expect(p.progressToNextLevel, closeTo(149 / 150, 1e-9));
      expect(p.progressToNextLevel, lessThan(1.0));
    });

    test('1 XP short of level 4 stays level 3', () {
      final p = engine.progressFor(474);
      expect(p.level, 3);
      expect(p.xpForNextLevel, 475);
      expect(p.xpIntoCurrentLevel, 224);
      expect(p.progressToNextLevel, closeTo(224 / 225, 1e-9));
      expect(p.progressToNextLevel, lessThan(1.0));
    });
  });

  group('just above a level boundary', () {
    test('1 XP past level 2 is level 2 with 1 XP into it', () {
      final p = engine.progressFor(101);
      expect(p.level, 2);
      expect(p.xpForCurrentLevel, 100);
      expect(p.xpForNextLevel, 250);
      expect(p.xpIntoCurrentLevel, 1);
      expect(p.progressToNextLevel, closeTo(1 / 150, 1e-9));
    });

    test('1 XP past level 3 is level 3 with 1 XP into it', () {
      final p = engine.progressFor(251);
      expect(p.level, 3);
      expect(p.xpForCurrentLevel, 250);
      expect(p.xpForNextLevel, 475);
      expect(p.xpIntoCurrentLevel, 1);
      expect(p.progressToNextLevel, closeTo(1 / 225, 1e-9));
    });
  });

  group('progress percentage', () {
    test('half way through level 1 is exactly 0.5', () {
      expect(engine.progressFor(50).progressToNextLevel, 0.5);
    });

    test('half way through level 2 is exactly 0.5', () {
      // Level 2 spans [100, 250); its midpoint is 100 + 75 = 175.
      final p = engine.progressFor(175);
      expect(p.level, 2);
      expect(p.xpIntoCurrentLevel, 75);
      expect(p.progressToNextLevel, 0.5);
    });

    test('progress stays within [0.0, 1.0) across a wide XP sweep', () {
      for (var xp = 0; xp <= 5000; xp += 7) {
        final p = engine.progressFor(xp);
        expect(p.progressToNextLevel, greaterThanOrEqualTo(0.0));
        expect(p.progressToNextLevel, lessThan(1.0));
      }
    });
  });

  group('high XP values', () {
    test('very large XP stays self-consistent inside its level band', () {
      const totalXp = 1000000;
      final p = engine.progressFor(totalXp);

      // Lands strictly inside the current level band.
      expect(p.xpForCurrentLevel, lessThanOrEqualTo(totalXp));
      expect(p.xpForNextLevel, greaterThan(totalXp));
      expect(p.xpIntoCurrentLevel, totalXp - p.xpForCurrentLevel);
      expect(p.progressToNextLevel, greaterThanOrEqualTo(0.0));
      expect(p.progressToNextLevel, lessThan(1.0));

      // Boundaries agree with the curve's own cumulative thresholds.
      expect(engine.xpToReachLevel(p.level), p.xpForCurrentLevel);
      expect(engine.xpToReachLevel(p.level + 1), p.xpForNextLevel);
    });

    test('is deterministic — same input yields an equal snapshot', () {
      expect(engine.progressFor(1000000), engine.progressFor(1000000));
    });

    test('level is monotonic non-decreasing as XP grows', () {
      var lastLevel = 0;
      for (var xp = 0; xp <= 2000000; xp += 4999) {
        final level = engine.progressFor(xp).level;
        expect(level, greaterThanOrEqualTo(lastLevel));
        lastLevel = level;
      }
    });
  });

  group('curve is tunable in one place', () {
    test('a different curve retunes thresholds without touching call sites', () {
      const gentle = LevelEngine(baseXp: 50, growthFactor: 2.0);
      expect(gentle.xpSpanForLevel(1), 50);
      expect(gentle.xpSpanForLevel(2), 100);
      expect(gentle.xpSpanForLevel(3), 200);
      expect(gentle.xpToReachLevel(3), 150); // 50 + 100

      final p = gentle.progressFor(50);
      expect(p.level, 2);
      expect(p.progressToNextLevel, 0.0);
    });
  });
}
