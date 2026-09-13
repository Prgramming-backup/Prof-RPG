import 'package:flutter/foundation.dart';

import '../services/calendar_day.dart';
import '../services/level_engine.dart';

/// Immutable summary snapshot of player statistics and lifetime milestones.
///
/// Serves as the foundational domain model for the Statistics feature.
@immutable
class PlayerStats {
  const PlayerStats({
    required this.totalXpEarned,
    required this.questsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.currentLevel,
    required this.memberSince,
  });

  /// Factory constructor for a brand new player account.
  factory PlayerStats.initial({DateTime? now}) {
    return PlayerStats(
      totalXpEarned: 0,
      questsCompleted: 0,
      currentStreak: 0,
      longestStreak: 0,
      currentLevel: 1,
      memberSince: now ?? DateTime.now(),
    );
  }

  /// Total cumulative XP accumulated since account creation.
  final int totalXpEarned;

  /// Total count of completed quests.
  final int questsCompleted;

  /// Current active consecutive day streak.
  final int currentStreak;

  /// Highest consecutive day streak ever achieved.
  final int longestStreak;

  /// Current character level.
  final int currentLevel;

  /// Timestamp when the player profile was initiated.
  final DateTime memberSince;

  PlayerStats copyWith({
    int? totalXpEarned,
    int? questsCompleted,
    int? currentStreak,
    int? longestStreak,
    int? currentLevel,
    DateTime? memberSince,
  }) {
    return PlayerStats(
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      questsCompleted: questsCompleted ?? this.questsCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      currentLevel: currentLevel ?? this.currentLevel,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStats &&
          totalXpEarned == other.totalXpEarned &&
          questsCompleted == other.questsCompleted &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          currentLevel == other.currentLevel &&
          memberSince == other.memberSince;

  @override
  int get hashCode => Object.hash(
        totalXpEarned,
        questsCompleted,
        currentStreak,
        longestStreak,
        currentLevel,
        memberSince,
      );

  @override
  String toString() =>
      'PlayerStats(totalXp: $totalXpEarned, questsCompleted: $questsCompleted, streak: $currentStreak, longestStreak: $longestStreak, level: $currentLevel)';
}

/// Single day snapshot for the historical activity chart.
@immutable
class DailyActivityStat {
  const DailyActivityStat({
    required this.day,
    required this.date,
    required this.xpEarned,
    required this.tasksCompleted,
    this.isToday = false,
  });

  /// The calendar day representation.
  final CalendarDay day;

  /// The underlying DateTime.
  final DateTime date;

  /// XP earned on this calendar day.
  final int xpEarned;

  /// Number of tasks completed on this calendar day.
  final int tasksCompleted;

  /// Whether this day corresponds to the user's current day.
  final bool isToday;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyActivityStat &&
          day == other.day &&
          xpEarned == other.xpEarned &&
          tasksCompleted == other.tasksCompleted &&
          isToday == other.isToday;

  @override
  int get hashCode => Object.hash(day, xpEarned, tasksCompleted, isToday);

  @override
  String toString() =>
      'DailyActivityStat(day: $day, xp: $xpEarned, tasks: $tasksCompleted, isToday: $isToday)';
}

/// Comprehensive immutable statistics snapshot for the Statistics feature.
@immutable
class StatisticsData {
  const StatisticsData({
    required this.totalTasksCompleted,
    required this.tasksCompletedToday,
    required this.tasksCompletedThisWeek,
    required this.totalXpAllTime,
    required this.xpEarnedToday,
    required this.xpEarnedThisWeek,
    required this.currentStreak,
    required this.longestStreak,
    required this.currentMultiplier,
    required this.currentLevel,
    required this.levelProgress,
    required this.recentDailyActivity,
  });

  /// Factory constructor for an empty initial state (brand new user).
  factory StatisticsData.empty({
    DateTime? now,
    LevelEngine levelEngine = const LevelEngine(),
  }) {
    final effectiveNow = now ?? DateTime.now();
    final todayDay = CalendarDay.from(effectiveNow);
    final emptyActivity = List.generate(7, (index) {
      final day = todayDay.subtractDays(6 - index);
      return DailyActivityStat(
        day: day,
        date: DateTime(day.year, day.month, day.day),
        xpEarned: 0,
        tasksCompleted: 0,
        isToday: day == todayDay,
      );
    });

    return StatisticsData(
      totalTasksCompleted: 0,
      tasksCompletedToday: 0,
      tasksCompletedThisWeek: 0,
      totalXpAllTime: 0,
      xpEarnedToday: 0,
      xpEarnedThisWeek: 0,
      currentStreak: 0,
      longestStreak: 0,
      currentMultiplier: 1.0,
      currentLevel: 1,
      levelProgress: levelEngine.progressFor(0),
      recentDailyActivity: emptyActivity,
    );
  }

  /// Total tasks completed across all time.
  final int totalTasksCompleted;

  /// Tasks completed on the current calendar day.
  final int tasksCompletedToday;

  /// Tasks completed in the current calendar week (Monday to Sunday).
  final int tasksCompletedThisWeek;

  /// Total XP earned all-time (net of reversals).
  final int totalXpAllTime;

  /// XP earned on the current calendar day.
  final int xpEarnedToday;

  /// XP earned in the current calendar week.
  final int xpEarnedThisWeek;

  /// Active consecutive productive day streak length.
  final int currentStreak;

  /// All-time maximum consecutive productive day streak length.
  final int longestStreak;

  /// Active XP multiplier based on current streak.
  final double currentMultiplier;

  /// Current character level.
  final int currentLevel;

  /// Current level progress snapshot (reused from LevelEngine).
  final LevelProgress levelProgress;

  /// Recent daily activity data points for historical charts (default 7 days).
  final List<DailyActivityStat> recentDailyActivity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticsData &&
          totalTasksCompleted == other.totalTasksCompleted &&
          tasksCompletedToday == other.tasksCompletedToday &&
          tasksCompletedThisWeek == other.tasksCompletedThisWeek &&
          totalXpAllTime == other.totalXpAllTime &&
          xpEarnedToday == other.xpEarnedToday &&
          xpEarnedThisWeek == other.xpEarnedThisWeek &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          currentMultiplier == other.currentMultiplier &&
          currentLevel == other.currentLevel &&
          levelProgress == other.levelProgress &&
          listEquals(recentDailyActivity, other.recentDailyActivity);

  @override
  int get hashCode => Object.hash(
        totalTasksCompleted,
        tasksCompletedToday,
        tasksCompletedThisWeek,
        totalXpAllTime,
        xpEarnedToday,
        xpEarnedThisWeek,
        currentStreak,
        longestStreak,
        currentMultiplier,
        currentLevel,
        levelProgress,
        Object.hashAll(recentDailyActivity),
      );
}
