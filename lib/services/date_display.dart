String formatTaskDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

bool isDueDateOverdue(DateTime dueDate, DateTime now) {
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final today = DateTime(now.year, now.month, now.day);
  return due.isBefore(today);
}
