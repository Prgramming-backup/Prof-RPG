import '../models/player_stats.dart';
import '../models/task.dart';
import '../models/xp_transaction.dart';
import 'level_engine.dart';
import 'streak_engine.dart';

/// Dedicated service responsible for calculating all statistics, metrics,
/// and historical aggregation for QuestForge.
///
/// Keeps no mutable state of its own; all calculations are pure, deterministic,
/// and independent of UI widgets.
class StatisticsService {
  const StatisticsService({
    this.streakEngine = const StreakEngine(),
    this.levelEngine = const LevelEngine(),
  });

  final StreakEngine streakEngine;
  final LevelEngine levelEngine;

  /// Computes a complete [StatisticsData] snapshot from the current tasks and transactions.
  StatisticsData calculate({
    required List<Task> tasks,
    required List<XpTransaction> xpTransactions,
    int? totalXpOverride,
    DateTime? now,
    int historyDays = 7,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final todayDay = CalendarDay.from(effectiveNow);

    // Week boundaries: Monday (weekday 1) to Sunday (weekday 7)
    final startOfWeekDay = todayDay.subtractDays(effectiveNow.weekday - 1);
    final endOfWeekDay = startOfWeekDay.addDays(6);

    // ── Task completions extraction ──────────────────────────────────────────
    final taskIds = tasks.map((t) => t.id).toSet();
    final allCompletions = <DateTime>[];

    for (final task in tasks) {
      if (task.isHabit) {
        allCompletions.addAll(task.completedDates);
      } else if (task.isCompleted) {
        allCompletions.add(task.completedAt ?? task.createdAt);
      }
    }

    // Account for orphaned completions (tasks that awarded XP but were subsequently deleted)
    for (final tx in xpTransactions) {
      if (!tx.reversed && !taskIds.contains(tx.sourceTaskId)) {
        allCompletions.add(tx.timestamp);
      }
    }

    // Task counts
    var totalTasksCompleted = 0;
    var tasksCompletedToday = 0;
    var tasksCompletedThisWeek = 0;

    for (final date in allCompletions) {
      final day = CalendarDay.from(date);
      totalTasksCompleted++;

      if (day == todayDay) {
        tasksCompletedToday++;
      }

      if (day.compareTo(startOfWeekDay) >= 0 && day.compareTo(endOfWeekDay) <= 0) {
        tasksCompletedThisWeek++;
      }
    }

    // ── XP aggregation ───────────────────────────────────────────────────────
    var totalXpSum = 0;
    var xpEarnedToday = 0;
    var xpEarnedThisWeek = 0;

    for (final tx in xpTransactions) {
      if (tx.reversed) continue;

      final day = CalendarDay.from(tx.timestamp);
      totalXpSum += tx.awardedXp;

      if (day == todayDay) {
        xpEarnedToday += tx.awardedXp;
      }

      if (day.compareTo(startOfWeekDay) >= 0 && day.compareTo(endOfWeekDay) <= 0) {
        xpEarnedThisWeek += tx.awardedXp;
      }
    }

    final effectiveTotalXp = (totalXpOverride ?? totalXpSum).clamp(0, double.maxFinite.toInt());

    // ── Streak and Progression calculation ───────────────────────────────────
    final completionDatesForStreak = <DateTime>[];
    for (final t in tasks) {
      if (t.isHabit) {
        completionDatesForStreak.addAll(t.completedDates);
      } else if (t.isCompleted && t.completedAt != null) {
        completionDatesForStreak.add(t.completedAt!);
      }
    }
    for (final tx in xpTransactions) {
      if (!tx.reversed) {
        completionDatesForStreak.add(tx.timestamp);
      }
    }

    final streakInfo = streakEngine.calculate(
      completionDates: completionDatesForStreak,
      today: effectiveNow,
    );

    final rawLongest = streakEngine.calculateLongestStreak(completionDatesForStreak);
    final longestStreak = rawLongest < streakInfo.streakLength ? streakInfo.streakLength : rawLongest;

    final levelProgress = levelEngine.progressFor(effectiveTotalXp);

    // ── Historical daily activity window ─────────────────────────────────────
    final safeHistoryDays = historyDays < 1 ? 7 : historyDays;
    final recentDailyActivity = List.generate(safeHistoryDays, (index) {
      final day = todayDay.subtractDays((safeHistoryDays - 1) - index);
      final date = DateTime(day.year, day.month, day.day);

      var dayXp = 0;
      for (final tx in xpTransactions) {
        if (!tx.reversed && CalendarDay.from(tx.timestamp) == day) {
          dayXp += tx.awardedXp;
        }
      }

      var dayTasks = 0;
      for (final completion in allCompletions) {
        if (CalendarDay.from(completion) == day) {
          dayTasks++;
        }
      }

      return DailyActivityStat(
        day: day,
        date: date,
        xpEarned: dayXp,
        tasksCompleted: dayTasks,
        isToday: day == todayDay,
      );
    });

    return StatisticsData(
      totalTasksCompleted: totalTasksCompleted,
      tasksCompletedToday: tasksCompletedToday,
      tasksCompletedThisWeek: tasksCompletedThisWeek,
      totalXpAllTime: effectiveTotalXp,
      xpEarnedToday: xpEarnedToday,
      xpEarnedThisWeek: xpEarnedThisWeek,
      currentStreak: streakInfo.streakLength,
      longestStreak: longestStreak,
      currentMultiplier: streakInfo.currentMultiplier,
      currentLevel: levelProgress.level,
      levelProgress: levelProgress,
      recentDailyActivity: recentDailyActivity,
    );
  }
}
