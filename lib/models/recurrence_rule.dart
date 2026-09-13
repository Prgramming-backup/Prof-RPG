/// How often a habit repeats.
enum RecurrenceKind {
  daily,
  weekly,
  monthly,
  custom,
}

/// Recurrence configuration for a habit. Side quests do not use this.
class RecurrenceRule {
  const RecurrenceRule({
    required this.kind,
    this.weekdays = const [],
    this.dayOfMonth,
  });

  static const RecurrenceRule daily = RecurrenceRule(kind: RecurrenceKind.daily);

  factory RecurrenceRule.weekly(List<int> weekdays) {
    return RecurrenceRule(
      kind: RecurrenceKind.weekly,
      weekdays: _normalizedWeekdays(weekdays),
    );
  }

  factory RecurrenceRule.monthly(int dayOfMonth) {
    return RecurrenceRule(
      kind: RecurrenceKind.monthly,
      dayOfMonth: _clampDayOfMonth(dayOfMonth),
    );
  }

  factory RecurrenceRule.custom({
    List<int> weekdays = const [],
    int? dayOfMonth,
  }) {
    return RecurrenceRule(
      kind: RecurrenceKind.custom,
      weekdays: _normalizedWeekdays(weekdays),
      dayOfMonth: dayOfMonth == null ? null : _clampDayOfMonth(dayOfMonth),
    );
  }

  /// Daily / weekly / monthly / custom.
  final RecurrenceKind kind;

  /// ISO weekdays (`DateTime.monday` = 1 … `DateTime.sunday` = 7).
  final List<int> weekdays;

  /// Day of month in `1..31` for monthly or custom date recurrence.
  final int? dayOfMonth;

  bool matches(DateTime date) {
    switch (kind) {
      case RecurrenceKind.daily:
        return true;
      case RecurrenceKind.weekly:
        return _matchesWeekday(date);
      case RecurrenceKind.monthly:
        return _matchesDayOfMonth(date, dayOfMonth ?? date.day);
      case RecurrenceKind.custom:
        final hasWeekdays = weekdays.isNotEmpty;
        final hasMonthDay = dayOfMonth != null;
        if (hasWeekdays && hasMonthDay) {
          return _matchesWeekday(date) || _matchesDayOfMonth(date, dayOfMonth!);
        }
        if (hasWeekdays) {
          return _matchesWeekday(date);
        }
        if (hasMonthDay) {
          return _matchesDayOfMonth(date, dayOfMonth!);
        }
        return true;
    }
  }

  String get displayLabel {
    switch (kind) {
      case RecurrenceKind.daily:
        return 'Daily';
      case RecurrenceKind.weekly:
        if (weekdays.isEmpty) {
          return 'Weekly';
        }
        return 'Weekly · ${_weekdayNames(weekdays)}';
      case RecurrenceKind.monthly:
        return 'Monthly · ${_ordinal(dayOfMonth ?? 1)}';
      case RecurrenceKind.custom:
        if (dayOfMonth != null && weekdays.isEmpty) {
          return 'Custom · ${_ordinal(dayOfMonth!)}';
        }
        if (weekdays.isNotEmpty && dayOfMonth == null) {
          return 'Custom · ${_weekdayNames(weekdays)}';
        }
        if (weekdays.isNotEmpty && dayOfMonth != null) {
          return 'Custom · ${_weekdayNames(weekdays)} · ${_ordinal(dayOfMonth!)}';
        }
        return 'Custom';
    }
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'weekdays': weekdays,
        'dayOfMonth': dayOfMonth,
      };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    final kind = _parseKind(json['kind']);
    final weekdays = <int>[];
    final rawWeekdays = json['weekdays'];
    if (rawWeekdays is List) {
      for (final item in rawWeekdays) {
        if (item is num) {
          weekdays.add(item.toInt());
        }
      }
    }
    int? dayOfMonth;
    final rawDay = json['dayOfMonth'];
    if (rawDay is num) {
      dayOfMonth = rawDay.toInt();
    }
    return RecurrenceRule(
      kind: kind,
      weekdays: _normalizedWeekdays(weekdays),
      dayOfMonth: dayOfMonth == null ? null : _clampDayOfMonth(dayOfMonth),
    );
  }

  bool _matchesWeekday(DateTime date) {
    if (weekdays.isEmpty) {
      return true;
    }
    return weekdays.contains(date.weekday);
  }

  bool _matchesDayOfMonth(DateTime date, int requestedDay) {
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    final target = requestedDay > lastDay ? lastDay : requestedDay;
    return date.day == target;
  }

  static RecurrenceKind _parseKind(Object? raw) {
    if (raw is String) {
      for (final value in RecurrenceKind.values) {
        if (value.name == raw) {
          return value;
        }
      }
    }
    return RecurrenceKind.daily;
  }

  static List<int> _normalizedWeekdays(List<int> days) {
    final unique = <int>{};
    for (final day in days) {
      if (day >= DateTime.monday && day <= DateTime.sunday) {
        unique.add(day);
      }
    }
    final sorted = unique.toList()..sort();
    return List<int>.unmodifiable(sorted);
  }

  static int _clampDayOfMonth(int day) {
    if (day < 1) {
      return 1;
    }
    if (day > 31) {
      return 31;
    }
    return day;
  }

  static String _ordinal(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  static String _weekdayNames(List<int> days) {
    const names = {
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    return days.map((day) => names[day] ?? '$day').join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceRule &&
          kind == other.kind &&
          dayOfMonth == other.dayOfMonth &&
          _listEquals(weekdays, other.weekdays);

  @override
  int get hashCode => Object.hash(kind, dayOfMonth, Object.hashAll(weekdays));
}

bool _listEquals(List<int> a, List<int> b) {
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
