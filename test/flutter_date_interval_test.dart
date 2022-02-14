import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_date_interval/flutter_date_interval.dart';

void main() {
  group('DateInterval', () {
    test('should not be able to set a period of less than 1', () {
      expect(() => DateInterval(period: 0), throwsArgumentError);
      expect(() => DateInterval(period: -1), throwsArgumentError);
    });

    test('should remove all time properties when setting the initial date', () {
      final DateTime withTime = DateTime(2020, 01, 01, 1, 1, 1, 1, 1);
      final DateTime withoutTime = DateTime(2020, 01, 01, 0, 0, 0, 0, 0);

      final DateInterval interval = DateInterval(startDate: withTime);
      expect(interval.startDate, isNot(equals(withTime)));
      expect(interval.startDate, equals(withoutTime));
    });

    test('should remove all time properties when setting the end date', () {
      final DateTime withTime = DateTime(2020, 01, 01, 1, 1, 1, 1, 1);
      final DateTime withoutTime = DateTime(2020, 01, 01, 0, 0, 0, 0, 0);

      final DateInterval interval = DateInterval(
        startDate: DateTime(2020, 01, 01),
        endDate: withTime,
      );
      expect(interval.endDate, isNotNull);
      expect(interval.endDate, isNot(equals(withTime)));
      expect(interval.endDate, equals(withoutTime));
    });

    group(
        'should return a list of all valid dates up through the provided end date',
        () {
      test('for the daily interval type', () {
        final DateInterval dateInterval = DateInterval(
          interval: Intervals.daily,
          period: 3,
          startDate: DateTime(2020, 01, 01),
        );

        final List<DateTime> expectedDates = [
          DateTime(2020, 01, 01),
          DateTime(2020, 01, 04),
          DateTime(2020, 01, 07),
          DateTime(2020, 01, 10),
          DateTime(2020, 01, 13),
          DateTime(2020, 01, 16),
          DateTime(2020, 01, 19),
          DateTime(2020, 01, 22),
          DateTime(2020, 01, 25),
          DateTime(2020, 01, 28),
          DateTime(2020, 01, 31),
        ];

        final Iterable<DateTime> dates =
            dateInterval.getDatesThrough(DateTime(2020, 01, 31));

        expect(listEquals(dates.toList(), expectedDates), isTrue);
      });

      test('for the weekly interval type', () {
        final DateInterval interval = DateInterval(
          interval: Intervals.weekly,
          period: 2,
          startDate: DateTime(2020, 01, 01),
        );

        final List<DateTime> expectedDates = [
          DateTime(2020, 01, 01),
          DateTime(2020, 01, 15),
          DateTime(2020, 01, 29),
          DateTime(2020, 02, 12),
          DateTime(2020, 02, 26),
        ];

        final Iterable<DateTime> dates =
            interval.getDatesThrough(DateTime(2020, 02, 29));
        expect(listEquals(dates.toList(), expectedDates), isTrue);
      });

      test('for the monthly interval type', () {
        final DateInterval interval = DateInterval(
          startDate: DateTime(2020, 01, 01),
          interval: Intervals.monthly,
          period: 2,
        );

        final List<DateTime> expectedDates = [
          DateTime(2020, 01, 01),
          DateTime(2020, 03, 01),
          DateTime(2020, 05, 01),
          DateTime(2020, 07, 01),
        ];

        final Iterable<DateTime> dates =
            interval.getDatesThrough(DateTime(2020, 07));
        expect(listEquals(dates.toList(), expectedDates), isTrue);
      });

      test('for the monthly interval type at the end of the month', () {
        final DateInterval interval = DateInterval(
          startDate: DateTime(2020, 01, 31),
          interval: Intervals.monthly,
          period: 1,
        );
        final List<DateTime> expectedDates = [
          DateTime(2020, 01, 31),
          DateTime(2020, 02, 29),
          DateTime(2020, 03, 31),
          DateTime(2020, 04, 30),
          DateTime(2020, 05, 31),
          DateTime(2020, 06, 30),
          DateTime(2020, 07, 31),
          DateTime(2020, 08, 31),
          DateTime(2020, 09, 30),
          DateTime(2020, 10, 31),
          DateTime(2020, 11, 30),
          DateTime(2020, 12, 31),
        ];
        final Iterable<DateTime> dates =
            interval.getDatesThrough(DateTime(2021, 01, 01));
        expect(listEquals(dates.toList(), expectedDates), isTrue);
      });

      test('for the yearly interval type', () {
        final DateInterval interval = DateInterval(
          startDate: DateTime(2020, 01, 15),
          interval: Intervals.yearly,
          period: 2,
        );
        final List<DateTime> expectedDates = [
          DateTime(2020, 01, 15),
          DateTime(2022, 01, 15),
          DateTime(2024, 01, 15),
          DateTime(2026, 01, 15),
        ];
        final Iterable<DateTime> dates =
            interval.getDatesThrough(DateTime(2027));
        expect(listEquals(dates.toList(), expectedDates), isTrue);
      });

      test('for the yearly interval type landing on leap years', () {
        final DateInterval interval = DateInterval(
          startDate: DateTime(2020, 02, 29),
          interval: Intervals.yearly,
          period: 1,
        );
        final List<DateTime> expectedDates = [
          DateTime(2020, 02, 29),
          DateTime(2024, 02, 29),
          DateTime(2028, 02, 29),
        ];
        final Iterable<DateTime> dates =
            interval.getDatesThrough(DateTime(2030));
        expect(listEquals(dates.toList(), expectedDates), isTrue);
      });
    });

    group(
        'should correctly determine if the target date is part of the interval',
        () {
      group('for the one-time interval type', () {
        test('when the days are the same', () {
          final DateTime date = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: date,
            interval: Intervals.once,
          );
          expect(interval.isValidIntervalDate(date), isTrue);
        });

        test('when the days are not the same', () {
          DateTime date = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: date,
            interval: Intervals.once,
          );

          for (int i = 0; i < 100; i++) {
            date = date.add(const Duration(days: 1));
            expect(interval.isValidIntervalDate(date), isFalse);
          }
        });
      });

      group('for the daily interval type', () {
        test('when the days are the same', () {
          final DateTime date = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: date,
            interval: Intervals.daily,
          );
          expect(interval.isValidIntervalDate(date), isTrue);
        });

        test('when the days are correctly spaced', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.daily,
            period: 2,
          );
          final Iterable<DateTime> dates = [
            DateTime(2020, 01, 01),
            DateTime(2020, 01, 03),
            DateTime(2020, 01, 05),
            DateTime(2020, 01, 07),
            DateTime(2020, 01, 09),
            DateTime(2020, 01, 11),
            DateTime(2020, 01, 13),
            DateTime(2020, 01, 15),
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isTrue);
          }
        });

        test('when the days are incorrectly spaced', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.daily,
            period: 3,
          );
          final Iterable<DateTime> dates = [
            DateTime(2020, 01, 02),
            DateTime(2020, 01, 03),
            DateTime(2020, 01, 05),
            DateTime(2020, 01, 06),
            DateTime(2020, 01, 08),
            DateTime(2020, 01, 09),
            DateTime(2020, 01, 11),
            DateTime(2020, 01, 12),
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isFalse);
          }
        });

        test('when the test date is on the interval but is after the end date',
            () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateTime endDate = DateTime(2020, 01, 15);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            endDate: endDate,
            interval: Intervals.daily,
            period: 2,
          );

          expect(interval.isValidIntervalDate(DateTime(2020, 01, 17)), isFalse);
        });

        test(
            'when the test date is on the interval and is the same as the end date',
            () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateTime endDate = DateTime(2020, 01, 15);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            endDate: endDate,
            interval: Intervals.daily,
            period: 2,
          );

          expect(interval.isValidIntervalDate(DateTime(2020, 01, 15)), isTrue);
        });
      });

      group('for the weekly interval type', () {
        test('when the days are the same', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.weekly,
            period: 2,
          );
          expect(interval.isValidIntervalDate(DateTime(2020, 01, 01)), isTrue);
        });

        test('when the days are correctly spaced', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.weekly,
            period: 2,
          );
          final List<DateTime> dates = [
            DateTime(2020, 01, 01),
            DateTime(2020, 01, 15),
            DateTime(2020, 01, 29),
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isTrue);
          }
        });

        test('when the days are incorrecly spaced', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.weekly,
            period: 2,
          );
          final List<DateTime> dates = [
            DateTime(2020, 01, 08),
            DateTime(2020, 01, 22),
            DateTime(2020, 02, 05),
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isFalse);
          }
        });
      });

      group('for the monthly interval type', () {
        test('when the target date is the same as the start date', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.monthly,
            period: 2,
          );
          expect(interval.isValidIntervalDate(DateTime(2020, 01, 01)), isTrue);
        });

        test('when the target date is on the interval', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.monthly,
            period: 2,
          );
          final List<DateTime> dates = [
            DateTime(2020, 01, 01),
            DateTime(2020, 03, 01),
            DateTime(2020, 05, 01),
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isTrue);
          }
        });

        test('when the target date is not on the interval', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.monthly,
            period: 2,
          );
          final List<DateTime> dates = [
            DateTime(2020, 02, 01),
            DateTime(2020, 04, 01),
            DateTime(2020, 06, 01),
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isFalse);
          }
        });

        test('when the start date is near the end of the month', () {
          final DateTime startDate = DateTime(2020, 01, 31);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.monthly,
            period: 1,
          );
          final List<DateTime> dates = [
            DateTime(2020, 01, 31),
            DateTime(2020, 02, 29), // leap day
            DateTime(2020, 03, 31), // same date
            DateTime(2020, 04, 30), // nearest possible day
            DateTime(2021, 02, 28), // non leap day
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isTrue);
          }
        });
      });

      group('for the yearly interval type', () {
        test('when the target date is the same as the start date', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.yearly,
            period: 1,
          );
          expect(interval.isValidIntervalDate(startDate), isTrue);
        });

        test('when the target date falls on the interval', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.yearly,
            period: 2,
          );
          final List<DateTime> dates = [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01),
            DateTime(2024, 01, 01),
            DateTime(2026, 01, 01),
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isTrue);
          }
        });

        test('when the target date is not on the interval', () {
          final DateTime startDate = DateTime(2020, 01, 01);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.yearly,
            period: 2,
          );
          final List<DateTime> dates = [
            DateTime(2021, 01, 01),
            DateTime(2023, 01, 01),
            DateTime(2025, 01, 01),
            DateTime(2027, 01, 01),
          ];

          for (final DateTime date in dates) {
            expect(interval.isValidIntervalDate(date), isFalse);
          }
        });

        test('when the start date is February 29th during a leap year', () {
          final DateTime startDate = DateTime(2020, 02, 29);
          final DateInterval interval = DateInterval(
            startDate: startDate,
            interval: Intervals.yearly,
            period: 1,
          );
          final List<DateTime> nonMatchingDates = [
            DateTime(2021, 02, 28),
            DateTime(2023, 02, 28),
            DateTime(2024, 02, 28),
          ];

          for (final DateTime date in nonMatchingDates) {
            expect(interval.isValidIntervalDate(date), isFalse);
          }

          expect(interval.isValidIntervalDate(DateTime(2024, 02, 29)), isTrue);
        });
      });
    });
  });
}
