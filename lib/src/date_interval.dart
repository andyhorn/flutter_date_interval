import 'intervals.dart';
import './utils/datetime_utils.dart';

/// Defines a repetition interval.
class DateInterval {
  /// Creates an instance of the [DateInterval] class.
  /// [period] must be greater than 0 or it will throw an [ArgumentError].
  DateInterval({
    DateTime? startDate,
    DateTime? endDate,
    this.period = 1,
    this.interval = Intervals.once,
    Iterable<DateTime>? skipDates,
    Iterable<int>? additionalDaysOfTheMonth,
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

    additionalDaysOfTheMonth?.forEach((day) {
      final date = DateTime(
        this.startDate.year,
        this.startDate.month,
        day,
      );

      if (date.month == this.startDate.month) {
        additionalDates.add(day);
      }
    });
  }

  /// The beginning of the interval. Determines the day-of-month (for monthly interval), day-of-week (for weekly interval).
  late final DateTime startDate;

  /// The last possible day for this interval. Any dates beyond this date will not be counted.
  late final DateTime? endDate;

  /// The frequency at which the interval occurs, i.e. how many [interval]s between each date.
  final int period;

  /// The interval at which this pattern occurs.
  final Intervals interval;

  /// Any specific dates within the interval to skip that might otherwise be counted.
  final List<DateTime> skipDates = [];

  /// Any additional "days of the month" that work alongside the start date.
  final List<int> additionalDates = [];

  /// Returns an [Iterable<DateTime>] of all valid dates between the
  /// configured [startDate] and the earliest of the configured
  /// [endDate] (if present) or the supplied [targetEndDate].
  Iterable<DateTime> getDatesThrough(DateTime targetEndDate) {
    final List<DateTime> dates = [];
    DateTime current = startDate;

    while (
        current.isBeforeOrSameAs(targetEndDate) && !_isAfterEndDate(current)) {
      if (!_isSkipDate(current)) {
        dates.add(current);
      }

      if (interval == Intervals.once) {
        break;
      }

      current = _getNextDate(current)!;
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
        final possibleDates = [
          startDate,
          ...additionalDates.map(
            (day) => DateTime(
              startDate.year,
              startDate.month,
              day,
            ),
          ),
        ];
        return possibleDates.any(
          (date) => targetDate.isOnMonthlyIntervalFrom(date, period),
        );
      case Intervals.yearly:
        return targetDate.isOnYearlyIntervalFrom(startDate, period);
    }
  }

  bool _isAfterEndDate(DateTime date) =>
      endDate != null && date.isAfter(endDate!);

  bool _isSkipDate(DateTime date) =>
      skipDates.any((DateTime skipDate) => skipDate.isSameDayAs(date));

  DateTime? _getNextDate(DateTime current) {
    switch (interval) {
      case Intervals.daily:
        return current.add(Duration(days: period));
      case Intervals.weekly:
        return current.add(Duration(days: (7 * period)));
      case Intervals.monthly:
        final additionalDateIndex = additionalDates.indexWhere(
          (date) => date > current.day,
        );

        if (additionalDateIndex > -1) {
          final date = DateTime(
            current.year,
            current.month,
            additionalDates[additionalDateIndex],
          );

          if (date.month == current.month) {
            return date;
          }
        }

        var newDate = DateTime(
          current.year,
          current.month + period,
          startDate.day,
        );

        if (current.day >= 28 && newDate.month != current.month + period) {
          return DateTime(
            current.year,
            current.month + period + 1,
            0,
          );
        }

        return newDate;
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
