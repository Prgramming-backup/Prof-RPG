import 'package:flutter/foundation.dart';

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
