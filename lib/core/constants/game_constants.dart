/// Centralized constants for the Productivity RPG game mechanics.
///
/// Ensures game balancing values (XP rewards, streak multipliers, level curve)
/// are defined in a single location rather than scattered as magic numbers.
abstract final class GameConstants {
  // ── Quest XP Difficulties ───────────────────────────────────────────────────
  /// XP awarded for an Easy quest (e.g. drinking water, quick stretch).
  static const int xpEasy = 10;

  /// XP awarded for a Normal quest (e.g. 30min walk, quick chore).
  static const int xpNormal = 20;

  /// XP awarded for a Hard quest (e.g. gym workout, focused study session).
  static const int xpHard = 35;

  /// XP awarded for a Major quest (e.g. exam, project milestone).
  static const int xpMajor = 50;

  /// Map of difficulty labels to their respective base XP values.
  static const Map<String, int> difficultyXpMap = {
    'Easy': xpEasy,
    'Normal': xpNormal,
    'Hard': xpHard,
    'Major': xpMajor,
  };

  // ── Streak Multipliers ─────────────────────────────────────────────────────
  /// Baseline multiplier for a fresh streak or day 1.
  static const double baseStreakMultiplier = 1.00;

  /// Incremental multiplier added for each consecutive productive day.
  static const double streakBonusPerDay = 0.05;

  /// Maximum multiplier achievable from consecutive productive days.
  static const double maxStreakMultiplier = 1.50;

  // ── Level Progression Curve ────────────────────────────────────────────────
  /// Base XP width of level 1 (XP required to reach level 2).
  static const int defaultBaseXp = 100;

  /// Geometric growth factor applied to each successive level width.
  static const double defaultGrowthFactor = 1.5;
}
