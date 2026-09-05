class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.xpReward,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final String? description;
  final int xpReward;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    int? xpReward,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      xpReward: xpReward ?? this.xpReward,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: clearCompletedAt
          ? null
          : (completedAt ?? this.completedAt),
    );
  }
}
