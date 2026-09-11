String xpCompletionId({
  required String taskId,
  required DateTime completedAt,
}) {
  return '$taskId:${completedAt.microsecondsSinceEpoch}';
}
