import 'dart:math' as math;

/// Immutable snapshot of a player's level-progression state for a given
/// amount of total XP.
///
/// This is a pure value object: it holds only the derived numbers a UI needs
/// to render a level and a progress bar. It performs no calculation itself —
/// all values are computed by [LevelEngine] so widgets never do XP math.
class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.totalXp,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
    required this.xpIntoCurrentLevel,
    required this.progressToNextLevel,
  });

  /// The player's current level. Always `>= 1`.
  final int level;

  /// The total accumulated XP this snapshot was calculated from. Never negative.
  final int totalXp;

  /// Total XP required to have *reached* the current level — the lower
  /// boundary of the current level. For level 1 this is `0`.
  final int xpForCurrentLevel;

  /// Total XP required to reach the *next* level — the upper boundary of the
  /// current level. Always strictly greater than [xpForCurrentLevel].
  final int xpForNextLevel;

  /// XP earned since reaching the current level, i.e.
  /// `totalXp - xpForCurrentLevel`. In the range `[0, span)` where `span` is
  /// the XP width of the current level.
  final int xpIntoCurrentLevel;

  /// Progress toward the next level as a fraction in the range `[0.0, 1.0)`.
  /// It is `0.0` exactly at a level boundary and approaches (but never reaches)
  /// `1.0` just before the next level-up.
  final double progressToNextLevel;

  /// Remaining XP needed to reach the next level. Always `>= 1`.
  ///
  /// Convenience so the UI can show "N XP to go" without doing arithmetic.
  int get xpToNextLevel => xpForNextLevel - totalXp;

  /// The XP width of the current level (`xpForNextLevel - xpForCurrentLevel`).
  int get xpSpanForCurrentLevel => xpForNextLevel - xpForCurrentLevel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelProgress &&
          level == other.level &&
          totalXp == other.totalXp &&
          xpForCurrentLevel == other.xpForCurrentLevel &&
          xpForNextLevel == other.xpForNextLevel &&
          xpIntoCurrentLevel == other.xpIntoCurrentLevel &&
          progressToNextLevel == other.progressToNextLevel;

  @override
  int get hashCode => Object.hash(
    level,
    totalXp,
    xpForCurrentLevel,
    xpForNextLevel,
    xpIntoCurrentLevel,
    progressToNextLevel,
  );

  @override
  String toString() =>
      'LevelProgress('
      'level: $level, '
      'totalXp: $totalXp, '
      'xpForCurrentLevel: $xpForCurrentLevel, '
      'xpForNextLevel: $xpForNextLevel, '
      'xpIntoCurrentLevel: $xpIntoCurrentLevel, '
      'progressToNextLevel: $progressToNextLevel)';
}

/// Pure, deterministic engine that converts a total XP amount into a
/// [LevelProgress].
///
/// The engine keeps no state and reads no UI, repository, or clock: the same
/// [totalXp] always yields the same result, which makes it independently
/// testable. It is the single owner of the XP-per-level curve, so changing the
/// game's pacing means editing only this class (or constructing it with
/// different values).
///
/// The curve is intentionally non-linear: each level costs a little more XP
/// than the previous one, growing geometrically by [growthFactor]. There is no
/// level cap, so arbitrarily high levels are supported without any UI change.
class LevelEngine {
  const LevelEngine({
    this.baseXp = 100,
    this.growthFactor = 1.5,
  }) : assert(baseXp > 0, 'baseXp must be positive'),
       assert(growthFactor >= 1.0, 'growthFactor must be >= 1.0');

  /// XP width of the first level (advancing from level 1 to level 2).
  final int baseXp;

  /// Multiplicative growth applied to each successive level's XP width. A value
  /// of `1.0` would make the curve linear; values above `1.0` make each level
  /// progressively more expensive.
  final double growthFactor;

  // ---------------------------------------------------------------------------
  // THE XP CURVE — single source of truth.
  //
  // Everything else in the app derives from these two methods. To retune
  // progression, change [baseXp] / [growthFactor] or the formula below; no
  // other code needs to change.
  // ---------------------------------------------------------------------------

  /// XP required to advance *from* [level] to `level + 1` (the width of a
  /// single level). [level] must be `>= 1`.
  int xpSpanForLevel(int level) {
    assert(level >= 1, 'level must be >= 1');
    return (baseXp * math.pow(growthFactor, level - 1)).round();
  }

  /// Total (cumulative) XP required to *reach* [level]. Reaching level 1
  /// requires `0` XP. [level] must be `>= 1`.
  int xpToReachLevel(int level) {
    assert(level >= 1, 'level must be >= 1');
    var total = 0;
    for (var l = 1; l < level; l++) {
      total += xpSpanForLevel(l);
    }
    return total;
  }

  /// Computes the full [LevelProgress] for the given [totalXp].
  ///
  /// Negative input is treated as `0` defensively; XP is never negative in the
  /// rest of the app, but the engine stays total to remain deterministic.
  LevelProgress progressFor(int totalXp) {
    final xp = totalXp < 0 ? 0 : totalXp;

    // Walk up the curve until the next level boundary would exceed `xp`.
    // Level widths strictly increase, so this always terminates.
    var level = 1;
    var currentFloor = 0; // cumulative XP to reach `level`
    var span = xpSpanForLevel(level); // width of `level`

    while (xp >= currentFloor + span) {
      currentFloor += span;
      level += 1;
      span = xpSpanForLevel(level);
    }

    final nextFloor = currentFloor + span; // cumulative XP to reach level + 1
    final intoLevel = xp - currentFloor;
    final progress = intoLevel / span; // span > 0, so this is safe

    return LevelProgress(
      level: level,
      totalXp: xp,
      xpForCurrentLevel: currentFloor,
      xpForNextLevel: nextFloor,
      xpIntoCurrentLevel: intoLevel,
      progressToNextLevel: progress,
    );
  }
}
