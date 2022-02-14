import 'intervals.dart';
import './utils/datetime_utils.dart';

/// Defines a repetition interval.
class DateInterval {
  /// Creates an instance of the [DateInterval] class.
  DateInterval({
    /// The beginning of the interval. Determines the day-of-month (for monthly interval), day-of-week (for weekly interval).
    DateTime? startDate,

    /// The last possible day for this interval. Any dates beyond this date will not be counted.
    DateTime? endDate,

    /// The frequency at which the interval occurs, i.e. how many [interval]s between each date.
    /// Must be 1 or greater, or an [ArgumentError] will be thrown.
    this.period = 1,

    /// The interval at which this pattern occurs.
    this.interval = Intervals.once,

    /// Any specific dates within the interval to skip that might otherwise be counted.
    Iterable<DateTime>? skipDates,
  }) {
    if (period < 1) {
      throw ArgumentError.value(
          period, 'period', 'Period must be 1 or greater.');
    }

    if (skipDates != null) {
      this.skipDates.addAll(skipDates);
    }

    this.startDate = startDate == null
        ? DateTime.now().withZeroTime()
        : startDate.withZeroTime();
    this.endDate = endDate?.withZeroTime();
  }

  late final DateTime startDate;
  late final DateTime? endDate;
  final int period;
  final Intervals interval;
  final List<DateTime> skipDates = [];

  /// Returns an [Iterable<DateTime>] of all valid dates between the
  /// configured [startDate] and the earliest of the configured
  /// [endDate] (if present) or the supplied [targetEndDate].
  Iterable<DateTime> getDatesThrough(DateTime targetEndDate) {
    final List<DateTime> dates = [];
    int round = 0;
    DateTime current = startDate;

    while (
        current.isBeforeOrSameAs(targetEndDate) && !_isAfterEndDate(current)) {
      if (!_isSkipDate(current)) {
        dates.add(current);
      }

      if (interval == Intervals.once) {
        break;
      } else if (interval == Intervals.monthly) {
        current = _getNextDate(startDate, offset: period * round)!;
      } else {
        current = _getNextDate(current)!;
      }

      round++;
    }

    return dates;
  }

  /// Determines if the [targetDate] falls along the configured interval.
  bool includes(DateTime targetDate) {
    if (targetDate.isBefore(startDate) ||
        _isSkipDate(targetDate) ||
        _isAfterEndDate(targetDate)) {
      return false;
    }

    switch (interval) {
      case Intervals.once:
        return targetDate.isSameDayAs(startDate);
      case Intervals.daily:
        return targetDate.isOnDailyIntervalFrom(startDate, period);
      case Intervals.weekly:
        return targetDate.isOnWeeklyIntervalFrom(startDate, period);
      case Intervals.monthly:
        return targetDate.isOnMonthlyIntervalFrom(startDate, period);
      case Intervals.yearly:
        return targetDate.isOnYearlyIntervalFrom(startDate, period);
    }
  }

  bool _isAfterEndDate(DateTime date) =>
      endDate != null && date.isAfter(endDate!);

  bool _isSkipDate(DateTime date) =>
      skipDates.any((DateTime skipDate) => skipDate.isSameDayAs(date));

  DateTime? _getNextDate(DateTime current, {int offset = 0}) {
    switch (interval) {
      case Intervals.daily:
        return current.add(Duration(days: period));
      case Intervals.weekly:
        return current.add(Duration(days: (7 * period)));
      case Intervals.monthly:
        final int movement = period + offset;

        if (current.day > 28) {
          return DateTime(
            current.year,
            current.month + movement + 1,
            0,
          );
        }

        return DateTime(
          current.year,
          current.month + movement,
          current.day,
        );
      case Intervals.yearly:
        if (current.month == DateTime.february && current.day == 29) {
          return DateTime(
            current.year + 4,
            DateTime.february,
            29,
          );
        }

        return DateTime(
          current.year + period,
          current.month,
          current.day,
        );
      case Intervals.once:
      default:
        return null;
    }
  }
}