import 'package:flutter/material.dart';

extension DateTimeExtensions on DateTime {
  String get dayOfWeek {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String get dayOfMonth {
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

  DateTime withZeroTime() {
    return DateTime(year, month, day, 0, 0, 0, 0, 0);
  }

  bool isSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isOnDailyIntervalFrom(DateTime startDate, int interval) {
    final int numDaysApart = difference(startDate).inDays;
    return numDaysApart % interval == 0;
  }

  bool isOnWeeklyIntervalFrom(DateTime startDate, int interval) {
    final bool areSameWeekday = startDate.weekday == weekday;
    final int weeksApart = (difference(startDate).inDays / 7).floor();
    return areSameWeekday && weeksApart % interval == 0;
  }

  bool isOnMonthlyIntervalFrom(
    DateTime startDate,
    int interval, [
    Iterable<int>? additionalDates,
  ]) {
    final bool isOnMonthlyInterval = monthsApartFrom(startDate) % interval == 0;

    if (!isOnMonthlyInterval) {
      return false;
    }

    final int lastDayOfThisMonth = DateTime(year, month + 1, 0).day;
    if (lastDayOfThisMonth < startDate.day) {
      return day == lastDayOfThisMonth;
    }

    if (additionalDates?.isNotEmpty == true) {
      return [startDate.day, ...additionalDates!].contains(day);
    }

    return startDate.day == day;
  }

  bool isOnYearlyIntervalFrom(DateTime startDate, int interval) {
    if (startDate.isSameDayAs(this)) {
      return true;
    }

    if (isBefore(startDate)) {
      return false;
    }

    return startDate.day == day &&
        startDate.month == month &&
        (year - startDate.year) % interval == 0;
  }

  int monthsApartFrom(DateTime other) {
    final DateTime first = other.isBefore(this) ? other : this;
    final DateTime last = other.isBefore(this) ? this : other;

    final int fromYear = first.year;
    final int toYear = last.year;
    final int fromMonth = first.month;
    final int toMonth = last.month;
    final int yearsApart = toYear - fromYear;

    if (yearsApart == 0) {
      return toMonth - fromMonth;
    }

    final int monthsRemainingInFirstYear = 12 - fromMonth;
    final int monthsInBetween = monthsRemainingInFirstYear + toMonth;

    if (yearsApart == 1) {
      return monthsInBetween;
    }

    return monthsInBetween + ((yearsApart - 1) * 12);
  }

  Iterable<DateTime> through(DateTime endDate, {bool inclusive = true}) {
    final List<DateTime> days = [];
    final DateTimeRange dateRange = _getOrderedDateRange(this, endDate);
    DateTime currentDate = DateTime(
      dateRange.start.year,
      dateRange.start.month,
      dateRange.start.day + 1,
    );

    if (inclusive) {
      days.add(dateRange.start);
    }

    if (!dateRange.start.isSameDayAs(dateRange.end)) {
      while (currentDate.isBefore(dateRange.end)) {
        days.add(currentDate);

        currentDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day + 1,
        );
      }

      if (inclusive) {
        days.add(currentDate);
      }
    }

    return days;
  }

  bool isBeforeOrSameAs(DateTime other) {
    return other.withZeroTime().isAfter(withZeroTime()) ||
        other.withZeroTime().isSameDayAs(withZeroTime());
  }

  bool isAfterOrSameAs(DateTime other) {
    return other.withZeroTime().isBefore(withZeroTime()) ||
        other.withZeroTime().isSameDayAs(withZeroTime());
  }

  DateTimeRange _getOrderedDateRange(DateTime dateOne, DateTime dateTwo) {
    final DateTime startDate = dateOne.isBefore(dateTwo) ? dateOne : dateTwo;
    final DateTime endDate = dateOne.isBefore(dateTwo) ? dateTwo : dateOne;

    final DateTimeRange dateRange = DateTimeRange(
      start: startDate.withZeroTime(),
      end: endDate.withZeroTime(),
    );

    return dateRange;
  }
}
