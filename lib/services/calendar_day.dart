/// Pure calendar day value object representing a date (year, month, day)
/// independent of timezones or time of day.
class CalendarDay implements Comparable<CalendarDay> {
  const CalendarDay(this.year, this.month, this.day);

  factory CalendarDay.from(DateTime dateTime) {
    return CalendarDay(dateTime.year, dateTime.month, dateTime.day);
  }

  final int year;
  final int month;
  final int day;

  CalendarDay addDays(int days) {
    final dt = DateTime.utc(year, month, day + days);
    return CalendarDay(dt.year, dt.month, dt.day);
  }

  CalendarDay subtractDays(int days) => addDays(-days);

  CalendarDay get nextDay => addDays(1);

  CalendarDay get previousDay => subtractDays(1);

  bool isSameDay(CalendarDay other) => this == other;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDay &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  int compareTo(CalendarDay other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
