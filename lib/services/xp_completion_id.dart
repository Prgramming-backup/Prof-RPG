import 'calendar_day.dart';

String xpCompletionId({
  required String taskId,
  required DateTime completedAt,
}) {
  return '$taskId:${completedAt.microsecondsSinceEpoch}';
}

/// Stable per-calendar-day id so a habit occurrence cannot award XP twice.
String xpOccurrenceCompletionId({
  required String taskId,
  required DateTime completedAt,
}) {
  return '$taskId:${CalendarDay.from(completedAt)}';
}
