<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A Dart package for configuring date-repetition patterns (e.g. "bi-weekly", "the 10th of every month", "every three years on June 1st", etc.) and finding the [DateTime] objects that lie on the pattern.

## Features
  * Configure moderately complex date-repetition patterns
  * Create lists of [DateTime] objects that follow the pattern
  * Determine if any given [DateTime] object follows the configured pattern

## Getting started

Simply download the package and import it into your project to begin using.

## Usage

### Configure a [DateInterval] object (e.g. bi-weekly, starting on January 1st, 2020)
```dart
final DateInterval interval = DateInterval(
    startDate: DateTime(2020, 01, 01), // set the first day of the interval
    interval: Intervals.weekly, // set the interval type
    period: 2, // set the period (i.e. how many [interval]s between each occurrence)
);
```

### Create a list of [DateTime] objects that fall on the interval
Using the example bi-weekly object:
```dart
final Iterable<DateTime> dates = interval.getDatesThrough(DateTime(2020, 02, 01));
/*
[
    DateTime(2020, 01, 01),
    DateTime(2020, 01, 15),
    DateTime(2020, 01, 29)
]
*/
```

### Determine if any given [DateTime] lies on the interval
Using the example bi-weekly object:
```dart
final DateTime fifteenthOfJanuary = DateTime(2020, 01, 15);
final bool isOnInterval = interval.includes(fifteenthOfJanuary);
expect(isOnInterval, isTrue); // true
```