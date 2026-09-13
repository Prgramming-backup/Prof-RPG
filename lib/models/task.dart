import 'quest_type.dart';
import 'recurrence_rule.dart';

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
    this.questType = QuestType.sideQuest,
    this.recurrence,
    this.completedDates = const [],
  });

  final String id;
  final String title;
  final String? description;
  final int xpReward;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final QuestType questType;
  final RecurrenceRule? recurrence;
  final List<DateTime> completedDates;

  bool get isHabit => questType == QuestType.habit;

  bool hasCompletedOn(DateTime date) {
    for (final completed in completedDates) {
      if (_sameCalendarDay(completed, date)) {
        return true;
      }
    }
    if (isCompleted && completedAt != null) {
      return _sameCalendarDay(completedAt!, date);
    }
    return false;
  }

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
    QuestType? questType,
    RecurrenceRule? recurrence,
    bool clearRecurrence = false,
    List<DateTime>? completedDates,
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
      questType: questType ?? this.questType,
      recurrence: clearRecurrence ? null : (recurrence ?? this.recurrence),
      completedDates: completedDates ?? this.completedDates,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xpReward': xpReward,
        'dueDate': dueDate?.toIso8601String(),
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'questType': questType.name,
        'recurrence': recurrence?.toJson(),
        'completedDates':
            completedDates.map((date) => date.toIso8601String()).toList(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      xpReward: (json['xpReward'] as num).toInt(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      questType: _parseQuestType(json['questType']),
      recurrence: _parseRecurrence(json['recurrence']),
      completedDates: _parseDates(json['completedDates']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          xpReward == other.xpReward &&
          dueDate == other.dueDate &&
          isCompleted == other.isCompleted &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt &&
          questType == other.questType &&
          recurrence == other.recurrence &&
          _datesEqual(completedDates, other.completedDates);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        xpReward,
        dueDate,
        isCompleted,
        createdAt,
        completedAt,
        questType,
        recurrence,
        Object.hashAll(completedDates),
      );
}

QuestType _parseQuestType(Object? raw) {
  if (raw is String) {
    for (final value in QuestType.values) {
      if (value.name == raw) {
        return value;
      }
    }
  }
  return QuestType.sideQuest;
}

RecurrenceRule? _parseRecurrence(Object? raw) {
  if (raw is Map<String, dynamic>) {
    return RecurrenceRule.fromJson(raw);
  }
  if (raw is Map) {
    return RecurrenceRule.fromJson(Map<String, dynamic>.from(raw));
  }
  return null;
}

List<DateTime> _parseDates(Object? raw) {
  if (raw is! List) {
    return const [];
  }
  final dates = <DateTime>[];
  for (final item in raw) {
    if (item is String) {
      try {
        dates.add(DateTime.parse(item));
      } catch (_) {
        // Skip malformed dates from older or partial backups.
      }
    }
  }
  return List<DateTime>.unmodifiable(dates);
}

bool _sameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _datesEqual(List<DateTime> a, List<DateTime> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
