import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_date_interval/flutter_date_interval.dart';

void main() {
  group(DateInterval, () {
    group('#ctor', () {
      test('should not be able to set a period of less than 1', () {
        expect(() => DateInterval(period: 0), throwsArgumentError);
        expect(() => DateInterval(period: -1), throwsArgumentError);
      });

      test('should remove all time properties when setting the initial date',
          () {
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
    });

    group('#getDatesThrough', () {
      late DateInterval dateInterval;
      late List<DateTime> expectedDates;
      late List<DateTime> result;

      void runTest() {
        expect(
          listEquals(result, expectedDates),
          isTrue,
          reason:
              'Expected $expectedDates\nbut got $result\nmissing ${expectedDates.toSet().difference(result.toSet())}',
        );
      }

      group(Intervals.daily, () {
        setUp(() {
          dateInterval = DateInterval(
            interval: Intervals.daily,
            period: 3,
            startDate: DateTime(2020, 01, 01),
          );

          expectedDates = [
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

          result =
              dateInterval.getDatesThrough(DateTime(2020, 01, 31)).toList();
        });

        test('should be the correct list of dates', () {
          runTest();
        });
      });

      group(Intervals.weekly, () {
        setUp(() {
          dateInterval = DateInterval(
            interval: Intervals.weekly,
            period: 2,
            startDate: DateTime(2020, 01, 01),
          );

          expectedDates = [
            DateTime(2020, 01, 01),
            DateTime(2020, 01, 15),
            DateTime(2020, 01, 29),
            DateTime(2020, 02, 12),
            DateTime(2020, 02, 26),
          ];

          result =
              dateInterval.getDatesThrough(DateTime(2020, 02, 29)).toList();
        });

        test('should return the correct list of dates', () {
          runTest();
        });
      });

      group(Intervals.monthly, () {
        setUp(() {
          dateInterval = DateInterval(
            startDate: DateTime(2020, 01, 01),
            interval: Intervals.monthly,
            period: 2,
          );

          expectedDates = [
            DateTime(2020, 01, 01),
            DateTime(2020, 03, 01),
            DateTime(2020, 05, 01),
            DateTime(2020, 07, 01),
          ];

          result = dateInterval.getDatesThrough(DateTime(2020, 07)).toList();
        });

        test('should return the correct list of dates', () {
          runTest();
        });

        group('at the end of the month', () {
          setUp(() {
            dateInterval = DateInterval(
              startDate: DateTime(2020, 01, 31),
              interval: Intervals.monthly,
              period: 1,
            );

            expectedDates = [
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

            result =
                dateInterval.getDatesThrough(DateTime(2021, 01, 01)).toList();
          });

          test('should return the correct list of dates', () {
            runTest();
          });
        });

        group('with additional dates', () {
          setUp(() {
            dateInterval = DateInterval(
              startDate: DateTime(2020, 01, 01),
              interval: Intervals.monthly,
              period: 2,
              additionalDaysOfTheMonth: [10, 15],
            );

            expectedDates = [
              DateTime(2020, 01, 01),
              DateTime(2020, 01, 10),
              DateTime(2020, 01, 15),
              DateTime(2020, 03, 01),
              DateTime(2020, 03, 10),
              DateTime(2020, 03, 15),
              DateTime(2020, 05, 01),
              DateTime(2020, 05, 10),
              DateTime(2020, 05, 15),
              DateTime(2020, 07, 01),
            ];

            result = dateInterval.getDatesThrough(DateTime(2020, 07)).toList();
          });

          test('should return the correct list of dates', () {
            runTest();
          });
        });
      });

      group(Intervals.yearly, () {
        setUp(() {
          dateInterval = DateInterval(
            startDate: DateTime(2020, 01, 15),
            interval: Intervals.yearly,
            period: 2,
          );

          expectedDates = [
            DateTime(2020, 01, 15),
            DateTime(2022, 01, 15),
            DateTime(2024, 01, 15),
            DateTime(2026, 01, 15),
          ];

          result = dateInterval.getDatesThrough(DateTime(2027)).toList();
        });

        test('should return the correct list of dates', () {
          runTest();
        });

        group('on leap years', () {
          setUp(() {
            dateInterval = DateInterval(
              startDate: DateTime(2020, 02, 29),
              interval: Intervals.yearly,
              period: 1,
            );

            expectedDates = [
              DateTime(2020, 02, 29),
              DateTime(2024, 02, 29),
              DateTime(2028, 02, 29),
            ];

            result = dateInterval.getDatesThrough(DateTime(2030)).toList();
          });

          test('should return the correct list of dates', () {
            runTest();
          });
        });
      });
    });

    group('#includes', () {
      group(Intervals.once, () {
        final DateTime date = DateTime(2020, 01, 01);
        final DateInterval interval = DateInterval(
          startDate: date,
          interval: Intervals.once,
        );

        test('on the same date', () {
          expect(interval.includes(date), isTrue);
        });

        test('on different days', () {
          var testDate = date;
          for (int i = 0; i < 100; i++) {
            testDate = date.add(const Duration(days: 1));
            expect(interval.includes(testDate), isFalse);
          }
        });
      });

      group(Intervals.daily, () {
        final DateTime date = DateTime(2020, 01, 01);
        final DateTime endDate = DateTime(2020, 01, 15);
        final DateInterval interval = DateInterval(
          startDate: date,
          endDate: endDate,
          interval: Intervals.daily,
        );

        test('includes original date', () {
          expect(interval.includes(date), isTrue);
        });

        test('includes correct dates', () {
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

          expect(dates.every(interval.includes), isTrue);
        });

        test('does not include incorrect dates', () {
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

          expect(dates.every(interval.includes), isTrue);
        });

        test('does not include the end date', () {
          expect(interval.includes(DateTime(2020, 01, 15)), isTrue);
        });

        test('does not include dates after the end date', () {
          expect(interval.includes(DateTime(2020, 01, 17)), isFalse);
        });
      });

      group(Intervals.weekly, () {
        late DateTime startDate;
        late DateTime endDate;
        late DateInterval interval;

        setUp(() {
          startDate = DateTime(2020, 01, 01);
          endDate = DateTime(2020, 02, 12);
          interval = DateInterval(
            startDate: startDate,
            endDate: endDate,
            interval: Intervals.weekly,
            period: 2,
          );
        });

        test('includes start date', () {
          expect(interval.includes(DateTime(2020, 01, 01)), isTrue);
        });

        test('includes correct dates', () {
          final List<DateTime> dates = [
            DateTime(2020, 01, 01),
            DateTime(2020, 01, 15),
            DateTime(2020, 01, 29),
            DateTime(2020, 02, 12),
          ];

          expect(dates.every(interval.includes), isTrue);
        });

        test('does not include incorrect dates', () {
          final List<DateTime> dates = [
            DateTime(2020, 01, 08),
            DateTime(2020, 01, 22),
            DateTime(2020, 02, 05),
          ];

          expect(dates.every((date) => !interval.includes(date)), isTrue);
        });

        test('does not include dates after the end date', () {
          final dates = [
            DateTime(2020, 02, 26),
            DateTime(2020, 03, 11),
            DateTime(2020, 03, 25),
          ];

          expect(dates.every((date) => !interval.includes(date)), isTrue);
        });
      });

      group(Intervals.monthly, () {
        late DateTime startDate;
        late DateInterval interval;

        setUp(() {
          startDate = DateTime(2020, 01, 01);
          interval = DateInterval(
            startDate: startDate,
            interval: Intervals.monthly,
            period: 2,
          );
        });

        test('includes the start date', () {
          expect(interval.includes(DateTime(2020, 01, 01)), isTrue);
        });

        test('includes correct dates', () {
          final List<DateTime> dates = [
            DateTime(2020, 01, 01),
            DateTime(2020, 03, 01),
            DateTime(2020, 05, 01),
          ];

          expect(dates.every(interval.includes), isTrue);
        });

        test('does not include incorrect dates', () {
          final List<DateTime> dates = [
            DateTime(2020, 02, 01),
            DateTime(2020, 04, 01),
            DateTime(2020, 06, 01),
          ];

          expect(dates.every((date) => !interval.includes(date)), isTrue);
        });

        group('with additional days of the month', () {
          setUp(() {
            startDate = DateTime(2020, 01, 01);
            interval = DateInterval(
              startDate: startDate,
              interval: Intervals.monthly,
              period: 2,
              additionalDaysOfTheMonth: [15, 20],
            );
          });

          test('includes all correct dates', () {
            final List<DateTime> dates = [
              DateTime(2020, 01, 01),
              DateTime(2020, 01, 15),
              DateTime(2020, 01, 20),
              DateTime(2020, 03, 01),
              DateTime(2020, 03, 15),
              DateTime(2020, 03, 20),
              DateTime(2020, 05, 01),
              DateTime(2020, 05, 15),
              DateTime(2020, 05, 20),
            ];

            expect(dates.every(interval.includes), isTrue);
          });

          test('does not include incorrect dates', () {
            final List<DateTime> dates = [
              DateTime(2020, 01, 02),
              DateTime(2020, 02, 15),
              DateTime(2020, 02, 20),
              DateTime(2020, 03, 02),
              DateTime(2020, 04, 15),
              DateTime(2020, 04, 20),
              DateTime(2020, 05, 02),
              DateTime(2020, 06, 15),
              DateTime(2020, 06, 20),
            ];

            expect(dates.every((date) => !interval.includes(date)), isTrue);
          });
        });

        group('end of the month', () {
          setUp(() {
            startDate = DateTime(2020, 01, 31);
            interval = DateInterval(
              startDate: startDate,
              interval: Intervals.monthly,
              period: 1,
            );
          });

          test('includes "closest end date" dates', () {
            final List<DateTime> dates = [
              DateTime(2020, 01, 31),
              DateTime(2020, 02, 29), // leap day
              DateTime(2020, 03, 31), // same date
              DateTime(2020, 04, 30), // nearest possible day
              DateTime(2021, 02, 28), // non leap day
            ];

            expect(dates.every(interval.includes), isTrue);
          });
        });
      });

      group(Intervals.yearly, () {
        late DateTime startDate;
        late DateInterval interval;

        setUp(() {
          startDate = DateTime(2020, 01, 01);
          interval = DateInterval(
            startDate: startDate,
            interval: Intervals.yearly,
            period: 2,
          );
        });

        test('includes the start date', () {
          expect(interval.includes(startDate), isTrue);
        });

        test('includes correct dates', () {
          final List<DateTime> dates = [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01),
            DateTime(2024, 01, 01),
            DateTime(2026, 01, 01),
          ];

          expect(dates.every(interval.includes), isTrue);
        });

        test('does not include incorrect dates', () {
          final List<DateTime> dates = [
            DateTime(2021, 01, 01),
            DateTime(2023, 01, 01),
            DateTime(2025, 01, 01),
            DateTime(2027, 01, 01),
          ];

          expect(dates.every((date) => !interval.includes(date)), isTrue);
        });

        group('when start date is February 29th', () {
          setUp(() {
            startDate = DateTime(2020, 02, 29);
            interval = DateInterval(
              startDate: startDate,
              interval: Intervals.yearly,
              period: 1,
            );
          });

          test('includes correct dates', () {
            expect(interval.includes(DateTime(2024, 02, 29)), isTrue);
          });

          test('does not include incorrect dates', () {
            final List<DateTime> dates = [
              DateTime(2021, 02, 28),
              DateTime(2023, 02, 28),
              DateTime(2024, 02, 28),
            ];

            expect(dates.every((date) => !interval.includes(date)), isTrue);
          });
        });
      });
    });
  });
}
