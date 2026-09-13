import '../models/quest_type.dart';
import '../models/recurrence_rule.dart';
import '../models/task.dart';
import 'calendar_day.dart';

/// Pure due-date checks for habits. Does not award XP or mutate tasks.
class RecurrenceEngine {
  const RecurrenceEngine();

  /// Whether [task] should be completable on [date].
  ///
  /// Side quests are never "due" via recurrence; they stay active until
  /// permanently completed.
  bool isDueOn(Task task, DateTime date) {
    if (task.questType != QuestType.habit) {
      return false;
    }
    final created = CalendarDay.from(task.createdAt);
    final day = CalendarDay.from(date);
    if (day.compareTo(created) < 0) {
      return false;
    }
    final rule = task.recurrence ?? RecurrenceRule.daily;
    return rule.matches(date);
  }

  bool canComplete(Task task, DateTime date) {
    if (task.questType == QuestType.habit) {
      return isDueOn(task, date) && !task.hasCompletedOn(date);
    }
    return !task.isCompleted;
  }
}
