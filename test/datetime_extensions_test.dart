import 'package:flutter_date_interval/src/utils/datetime_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTime extensions', () {
    group('The \'withZeroTime\' function', () {
      final DateTime date = DateTime(2020, 01, 01, 12, 30, 30, 500, 500);
      final DateTime withZeroTime = date.withZeroTime();

      test(
          'should return a DateTime object with the same year, month, and date',
          () {
        expect(withZeroTime.year, equals(date.year),
            reason: 'Years are different');
        expect(withZeroTime.month, equals(date.month),
            reason: 'Months are different');
        expect(withZeroTime.day, equals(date.day),
            reason: 'Days are different');
      });

      test('should return a DateTime object with zero time values', () {
        expect(withZeroTime.hour, isZero, reason: 'Hour is not zero');
        expect(withZeroTime.minute, isZero, reason: 'Minute is not zero');
        expect(withZeroTime.second, isZero, reason: 'Second in not zero');
        expect(withZeroTime.millisecond, isZero,
            reason: 'Millisecond is not zero');
        expect(withZeroTime.microsecond, isZero,
            reason: 'Microsecond is not zero');
      });
    });

    group('The \'isSameDayAs\' function', () {
      final DateTime date = DateTime(2020, 01, 30, 12, 30, 30, 500, 500);

      test(
          'should return true for a DateTime with the same year, month, and day',
          () {
        final DateTime sameDay = DateTime(date.year, date.month, date.day);
        final bool isSameDay = date.isSameDayAs(sameDay);
        expect(isSameDay, isTrue);
      });

      test(
          'should return true for the same date, even if the time is different',
          () {
        final DateTime sameDay =
            DateTime(date.year, date.month, date.day, 1, 2, 3, 4, 5);
        final bool isSameDay = date.isSameDayAs(sameDay);
        expect(isSameDay, isTrue);
      });

      test('should return false if the year is different', () {
        final DateTime differentYear =
            DateTime(date.year + 1, date.month, date.day);
        final bool isSameDay = date.isSameDayAs(differentYear);
        expect(isSameDay, isFalse);
      });

      test('should return false if the month is different', () {
        final DateTime differentMonth =
            DateTime(date.year, date.month + 1, date.day);
        final bool isSameDay = date.isSameDayAs(differentMonth);
        expect(isSameDay, isFalse);
      });

      test('should return false if the day is different', () {
        final DateTime differentDay =
            DateTime(date.year, date.month, date.day + 1);
        final bool isSameDay = date.isSameDayAs(differentDay);
        expect(isSameDay, isFalse);
      });
    });

    group('The \'isOnDailyIntervalFrom\' function', () {
      final DateTime date = DateTime(2020, 01, 01);

      void testInterval(int interval) {
        for (var i = 0; i < 1000; i++) {
          final DateTime other = date.add(Duration(days: interval * i));
          final bool isMatch = other.isOnDailyIntervalFrom(date, interval);
          expect(isMatch, isTrue);
        }
      }

      test('should match next 100 intervals', () {
        for (int i = 1; i < 100; i++) {
          testInterval(i);
        }
      });

      test('should match the same date, regardless of interval', () {
        final DateTime other = DateTime(date.year, date.month, date.day);

        for (int i = 0; i < 1000; i++) {
          final int interval = i + 1;
          final bool isMatch = other.isOnDailyIntervalFrom(date, interval);
          expect(isMatch, isTrue);
        }
      });

      test('should not match on next 1000 invalid interval dates', () {
        DateTime offsetDate = date.add(const Duration(days: 1));

        for (int i = 0; i < 1000; i++) {
          final bool isMatch = offsetDate.isOnDailyIntervalFrom(date, 2);
          expect(isMatch, isFalse);

          offsetDate = offsetDate.add(const Duration(days: 2));
        }
      });
    });

    group('The \'isOnWeeklyIntervalFrom\' function', () {
      final DateTime date = DateTime(2020, 01, 01);

      test('should match on same date, regardless of interval', () {
        final DateTime other = DateTime(date.year, date.month, date.day);

        for (int i = 0; i < 1000; i++) {
          final bool isMatch = other.isOnWeeklyIntervalFrom(date, i + 1);
          expect(isMatch, isTrue);
        }
      });

      test('should match on next 100 valid interval', () {
        for (int interval = 1; interval <= 100; interval++) {
          for (int i = 0; i < 1000; i++) {
            final DateTime other = date.add(Duration(days: (i * 7) * interval));
            final bool isMatch = other.isOnWeeklyIntervalFrom(date, interval);
            expect(isMatch, isTrue);
          }
        }
      });

      test('should not match on next 100 invalid intervals', () {
        for (int interval = 1; interval <= 100; interval++) {
          for (int i = 0; i < 1000; i++) {
            final List<DateTime> invalidDates = [
              date.add(Duration(days: ((i * 7) * interval) + 1)),
              date.add(Duration(days: ((i * 7) * interval) + 2)),
              date.add(Duration(days: ((i * 7) * interval) + 3)),
              date.add(Duration(days: ((i * 7) * interval) + 4)),
              date.add(Duration(days: ((i * 7) * interval) + 5)),
              date.add(Duration(days: ((i * 7) * interval) + 6)),
            ];

            for (final DateTime day in invalidDates) {
              expect(day.isOnWeeklyIntervalFrom(date, interval), isFalse);
            }
          }
        }
      });
    });

    group('The \'isOnMonthlyIntervalFrom\' function', () {
      final DateTime date = DateTime(2020, 01, 01);

      test('should match the same day, regardless of the interval', () {
        final DateTime other = DateTime(date.year, date.month, date.day);

        for (int i = 0; i < 100; i++) {
          final bool isMatch = other.isOnMonthlyIntervalFrom(date, i + 1);
          expect(isMatch, isTrue);
        }
      });

      test('should match next 100 intervals for all days before the 29th', () {
        for (int day = 1; day < 29; day++) {
          final DateTime startDate = DateTime(2020, 01, day);

          for (int interval = 1; interval <= 100; interval++) {
            final DateTime other = DateTime(
              startDate.year,
              startDate.month + interval,
              startDate.day,
            );
            final bool isMatch = other.isOnMonthlyIntervalFrom(
              startDate,
              interval,
            );
            expect(
              isMatch,
              isTrue,
              reason:
                  'Failed to match $other to $startDate with interval $interval',
            );
          }
        }
      });

      group('when the start date is later than the 28th', () {
        test('should match the closest possible end date', () {
          DateTime january29th = DateTime(2022, 01, 29);
          DateTime january30th = DateTime(2022, 01, 30);
          DateTime january31st = DateTime(2022, 01, 31);

          final DateTime endOfFebruary = DateTime(2022, 02, 28);
          final DateTime endOfApril = DateTime(2022, 04, 30);

          bool isMatch = endOfFebruary.isOnMonthlyIntervalFrom(january29th, 1);
          expect(isMatch, isTrue);

          isMatch = endOfFebruary.isOnMonthlyIntervalFrom(january30th, 1);
          expect(isMatch, isTrue);
          isMatch = endOfApril.isOnMonthlyIntervalFrom(january30th, 1);
          expect(isMatch, isTrue);

          isMatch = endOfFebruary.isOnMonthlyIntervalFrom(january31st, 1);
          expect(isMatch, isTrue);
          isMatch = endOfApril.isOnMonthlyIntervalFrom(january31st, 1);
          expect(isMatch, isTrue);
        });

        test('should only occur on the closest possible date', () {
          final DateTime targetDate = DateTime(2022, 01, 31);

          // test all dates before the 28th
          for (int i = 1; i < 28; i++) {
            DateTime testDate = DateTime(2022, 02, i);
            bool isMatch = testDate.isOnMonthlyIntervalFrom(targetDate, 1);
            expect(isMatch, isFalse);
          }

          // test the closest possible date
          expect(DateTime(2022, 02, 28).isOnMonthlyIntervalFrom(targetDate, 1),
              isTrue);
        });
      });

      test('should not match next 100 invalid interval dates', () {
        List<DateTime> _makeInvalidDates(int month, int day) {
          final List<DateTime> invalidDates = [];

          for (int i = 1; i < 28; i++) {
            if (i == day) {
              continue;
            }

            invalidDates.add(DateTime(2020, month, i));
          }

          return invalidDates;
        }

        for (int day = 1; day < 28; day++) {
          final DateTime startDate = DateTime(2020, 01, day);

          for (int i = 1; i <= 100; i++) {
            final List<DateTime> invalidDates = _makeInvalidDates(
              startDate.month + i,
              day,
            );
            for (final DateTime date in invalidDates) {
              final bool isMatch = date.isOnMonthlyIntervalFrom(startDate, 1);
              expect(isMatch, isFalse);
            }
          }
        }
      });
    });

    group('the \isOnYearlyIntervalFrom\' function', () {
      final DateTime date = DateTime(2020, 01, 01);

      test('should match the same day, regardless of the interval', () {
        final DateTime other = DateTime(date.year, date.month, date.day);

        for (int i = 0; i < 1000; i++) {
          final bool isMatch = other.isOnYearlyIntervalFrom(date, i);
          expect(isMatch, isTrue);
        }
      });

      test('should match the next 100 intervals', () {
        for (int i = 1; i <= 100; i++) {
          for (int interval = 1; interval <= 1000; interval++) {
            final DateTime other =
                DateTime(date.year + (interval * i), date.month, date.day);
            final bool isMatch = other.isOnYearlyIntervalFrom(date, interval);
            expect(isMatch, isTrue);
          }
        }
      });

      test('should not match the next 100 invalid intervals', () {
        for (int i = 0; i < 1000; i++) {
          final DateTime other =
              DateTime(date.year + 1 + (i * 2), date.month, date.day);
          final bool isMatch = other.isOnYearlyIntervalFrom(date, 2);
          expect(isMatch, isFalse);
        }
      });

      test('should not match if the day of the month is different', () {
        for (int i = 0; i < 100; i++) {
          final List<DateTime> invalidDates = [
            for (int i = 2; i <= 31; i++)
              DateTime(date.year + i, date.month, i),
          ];
          for (final DateTime d in invalidDates) {
            final bool isMatch = d.isOnYearlyIntervalFrom(date, 1);
            expect(isMatch, isFalse);
          }
        }
      });

      test('should not match if the month is different', () {
        for (int i = 0; i < 100; i++) {
          final List<DateTime> invalidDates = [
            for (int i = 2; i <= 12; i++) DateTime(date.year + i, i, date.day),
          ];
          for (final DateTime d in invalidDates) {
            final bool isMatch = d.isOnYearlyIntervalFrom(date, 1);
            expect(isMatch, isFalse);
          }
        }
      });
    });

    group('the \'monthsApartFrom\' function', () {
      final DateTime startDate = DateTime(2020, 03, 01);

      test('should work for dates within the same year', () {
        final DateTime testDate = DateTime(2020, 09, 01);
        final int monthsApart = testDate.monthsApartFrom(startDate);
        expect(monthsApart, equals(6));
      });

      test('should work dates within one year apart', () {
        final DateTime testDate = DateTime(2021, 01, 01);
        final int monthsApart = testDate.monthsApartFrom(startDate);
        expect(monthsApart, equals(10));
      });

      test('should work for dates just over one year apart', () {
        final DateTime testDate = DateTime(2021, 07, 01);
        final int monthsApart = testDate.monthsApartFrom(startDate);
        expect(monthsApart, equals(16));
      });

      test('should work for dates that are two or more years apart', () {
        for (int i = 2; i <= 1000; i++) {
          final DateTime testDate =
              DateTime(2020 + i, startDate.month, startDate.day);
          final int monthsApart = testDate.monthsApartFrom(startDate);
          expect(monthsApart, equals(12 * i));
        }
      });
    });

    group('the \'daysApartFrom\' function', () {
      final DateTime today = DateTime.now().withZeroTime();

      test('should work for dates that are zero days apart', () {
        final DateTime testDate = DateTime(today.year, today.month, today.day);
        final int daysApart = testDate.daysAheadOf(today);
        expect(daysApart, equals(0));
      });

      test('should work for dates that are one day apart', () {
        final DateTime testDate =
            DateTime(today.year, today.month, today.day + 1);
        final int daysApart = testDate.daysAheadOf(today);
        expect(daysApart, equals(1));
      });

      test('should work for dates that are two or more days apart', () {
        for (int i = 2; i <= 1000; i++) {
          final DateTime testDate =
              DateTime(today.year, today.month, today.day + i);
          final int daysApart = testDate.daysAheadOf(today);
          expect(daysApart, equals(i));
        }
      });
    });

    group('the \'through\' function', () {
      test('should capture dates in the correct order', () {
        final DateTime startDate = DateTime(2020, 01, 01);
        final DateTime endDate = DateTime(2020, 01, 31);
        final List<int> expectedDates = [];
        for (int i = 1; i <= 31; i++) {
          expectedDates.add(i);
        }
        final Iterable<DateTime> datesBetween = startDate.through(endDate);

        expect(datesBetween.length, equals(31));
        expect(datesBetween.map((DateTime d) => d.day),
            containsAllInOrder(expectedDates));
      });

      test(
          'should not return the start and end date when the "inclusive" flag is false',
          () {
        final DateTime startDate = DateTime(2020, 01, 01);
        final DateTime endDate = DateTime(2020, 01, 31);
        final List<int> expectedDates = [];
        for (int i = 2; i < 31; i++) {
          expectedDates.add(i);
        }
        final Iterable<DateTime> dates =
            startDate.through(endDate, inclusive: false);

        expect(dates.length, equals(29));
        expect(dates.map((DateTime d) => d.day),
            containsAllInOrder(expectedDates));
      });

      test(
          'should return one date if the start and end dates are the same and inclusive is true',
          () {
        final DateTime startDate = DateTime(2020, 01, 01);
        final DateTime endDate = DateTime(2020, 01, 01);
        final List<int> expectedDates = [1];
        final Iterable<DateTime> dates = startDate.through(endDate);

        expect(dates.length, equals(1));
        expect(dates.map((DateTime d) => d.day),
            containsAllInOrder(expectedDates));
      });

      test(
          'should return an empty list if the start date and end date are the same date and inclusive is false',
          () {
        final DateTime startDate = DateTime(2020, 01, 01);
        final DateTime endDate = DateTime(2020, 01, 01);
        final Iterable<DateTime> dates =
            startDate.through(endDate, inclusive: false);

        expect(dates, isEmpty);
      });

      test(
          'should properly order dates if the start and end dates are backward',
          () {
        final DateTime startDate = DateTime(2020, 01, 31);
        final DateTime endDate = DateTime(2020, 01, 01);
        final List<int> expectedDates = [];
        for (int i = 1; i <= 31; i++) {
          expectedDates.add(i);
        }
        final Iterable<DateTime> dates = startDate.through(endDate);

        expect(dates.length, equals(31));
        expect(dates.map((DateTime d) => d.day),
            containsAllInOrder(expectedDates));
      });
    });

    group('the \'isBeforeOrSameAs\' function', () {
      test('should return true when the current date is before the target date',
          () {
        final DateTime date = DateTime(2019, 12, 31);
        final DateTime other = DateTime(2020, 01, 01);
        final bool result = date.isBeforeOrSameAs(other);
        expect(result, isTrue);
      });

      test(
          'should return true when the current date is the same as the target date',
          () {
        final DateTime date = DateTime(2020, 01, 01);
        final DateTime other = DateTime(2020, 01, 01);
        final bool result = date.isBeforeOrSameAs(other);
        expect(result, isTrue);
      });

      test('should return false when the current date is after the target date',
          () {
        final DateTime date = DateTime(2020, 01, 02);
        final DateTime other = DateTime(2020, 01, 01);
        final bool result = date.isBeforeOrSameAs(other);
        expect(result, isFalse);
      });
    });

    group('the \'isAfterOrSameAs\' function', () {
      test(
          'should return false when the current date is before the target date',
          () {
        final DateTime date = DateTime(2020, 01, 01);
        final DateTime other = DateTime(2020, 01, 02);
        final bool result = date.isAfterOrSameAs(other);
        expect(result, isFalse);
      });

      test(
          'should return true when the current date is the same as the target date',
          () {
        final DateTime date = DateTime(2020, 01, 01);
        final DateTime other = DateTime(2020, 01, 01);
        final bool result = date.isAfterOrSameAs(other);
        expect(result, isTrue);
      });

      test('should return true when the current date is after the target date',
          () {
        final DateTime date = DateTime(2020, 01, 02);
        final DateTime other = DateTime(2020, 01, 01);
        final bool result = date.isAfterOrSameAs(other);
        expect(result, isTrue);
      });
    });
  });
}
