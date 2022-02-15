// ignore_for_file: avoid_print

import 'package:flutter_date_interval/flutter_date_interval.dart';

void main() {
  /* One-time event */
  final DateInterval oneTimeEvent = DateInterval(
    startDate: DateTime(2020, 01, 01),
    interval: Intervals.once,
  );

  print(oneTimeEvent.toString());
  // Once on January 1, 2020

  print(oneTimeEvent.includes(DateTime(2020, 01, 01))); // true
  print(oneTimeEvent.includes(DateTime(2020, 01, 02))); // false

  print(oneTimeEvent.getDatesThrough(DateTime(2021, 01, 01)));
  // [
  //  <2020-01-01>,
  // ]

  /* Bi-weekly event */
  final DateInterval biWeekly = DateInterval(
    startDate: DateTime(2020, 01, 01),
    interval: Intervals.weekly,
    period: 2,
  );

  print(biWeekly.toString());
  // Every 2 weeks on Wednesday
  print(biWeekly.toString(includeStartDate: true));
  // Every 2 weeks on Wednesday, beginning on January 1, 2020

  print(biWeekly.includes(DateTime(2020, 01, 01))); // true
  print(biWeekly.includes(DateTime(2020, 01, 02))); // false
  print(biWeekly.includes(DateTime(2020, 01, 15))); // true
  print(biWeekly.includes(DateTime(2020, 03, 25))); // true

  print(biWeekly.getDatesThrough(DateTime(2020, 03, 01)));
  // [
  //  <2020-01-01>,
  //  <2020-01-15>,
  //  <2020-01-29>,
  //  <2020-02-12>,
  //  <2020-02-26>,
  // ]

  /* Every three days */
  final DateInterval threeDays = DateInterval(
    startDate: DateTime(2020, 01, 01),
    interval: Intervals.daily,
    period: 3,
  );

  print(threeDays.toString());
  // Every 3 days
  print(threeDays.toString(includeStartDate: true));
  // Every 3 days, beginning on January 1, 2020

  print(threeDays.includes(DateTime(2020, 01, 01))); // true
  print(threeDays.includes(DateTime(2020, 01, 02))); // false
  print(threeDays.includes(DateTime(2020, 01, 03))); // false
  print(threeDays.includes(DateTime(2020, 01, 04))); // true

  print(threeDays.getDatesThrough(DateTime(2020, 02, 01)));
  // [
  //  <2020-01-01>,
  //  <2020-01-04>,
  //  <2020-01-07>,
  //  <2020-01-10>,
  //  <2020-01-13>,
  //  <2020-01-16>,
  //  <2020-01-19>,
  //  <2020-01-22>,
  //  <2020-01-25>,
  //  <2020-01-28>,
  //  <2020-01-31>,
  // ]

  /* Bi-annual event */
  final DateInterval biAnnual = DateInterval(
    startDate: DateTime(2020, 01, 01),
    interval: Intervals.monthly,
    period: 6,
  );

  print(biAnnual.toString());
  // Every 6 months on the 1st
  print(biAnnual.toString(includeStartDate: true));
  // Every 6 months on the 1st, beginning on January 1, 2020

  print(biAnnual.includes(DateTime(2020, 01, 01))); // true
  print(biAnnual.includes(DateTime(2020, 07, 01))); // true
  print(biAnnual.includes(DateTime(2021, 01, 01))); // true

  print(biAnnual.getDatesThrough(DateTime(2021, 01, 01)));
  // [
  //  <2020-01-01>,
  //  <2020-07-01>,
  //  <2021-01-01>,
  // ]
}
