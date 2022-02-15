// ignore_for_file: avoid_print

import 'package:flutter_date_interval/flutter_date_interval.dart';

void main() {
  /* One-time event */
  DateInterval example = DateInterval(
    startDate: DateTime(2020, 01, 01),
    interval: Intervals.once,
  );

  print(example.toString());
  // Once on January 1, 2020

  /* Bi-weekly event */
  example = DateInterval(
    startDate: DateTime(2020, 01, 01),
    interval: Intervals.weekly,
    period: 2,
  );

  print(example.toString());
  // Every 2 weeks on Wednesday

  print(example.toString(includeStartDate: true));
  // Every 2 weeks on Wednesday, beginning on January 1, 2020

  /* Quarterly event */
  example = DateInterval(
    startDate: DateTime(2020, 01, 01),
    interval: Intervals.daily,
    period: 3,
  );

  print(example.toString());
  // Every 3 days

  print(example.toString(includeStartDate: true));
  // Every 3 days, beginning on January 1, 2020

  /* Bi-annual event */
  example = DateInterval(
    startDate: DateTime(2020, 01, 01),
    interval: Intervals.monthly,
    period: 6,
  );

  print(example.toString());
  // Every 6 months on the 1st
}
