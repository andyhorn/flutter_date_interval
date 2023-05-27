## 2.1.2

Upgraded to support Flutter >=3.10.2 and Dart >=3.0.2

## 2.1.1

Patches a bug that was causing "additional dates" to be skipped if their integer value was less than that of the `startDate`'s `day` value.

## 2.1.0

<ul>
    <li>
        Added support for "additional days of the month," i.e. you can now represent "the 1st and 15th of the month" (or any arbitrary set of dates) in a single `DateInterval` object
        <ul>
            <li>
                This can be controlled by setting a list of `int` values in the `additionalDaysOfTheMonth` property on the constructor
            </li>
            <li>
                These "additional days" still abide by the "closest end date" rule
            </li>
        </ul>
    </li>
</ul>

## 2.0.0

- Removed the overridden `toString` method as it wasn't really within the scope of this project and wasn't very useful
- Removed the `daysAheadOf` method in favor of Dart's `difference.inDays`
- Minor cleanup to resolve analysis problems

## 1.0.3

- Fixed a typo in the README

## 1.0.2

- Improved examples

## 1.0.1

- Updated the `toString` method to print a readable representation of the interval
- Added an examples file

## 1.0.0

_Initial Release_
This package is based off of work that was previously developed inside another project, so most of the work was done before extracting to this package, but some improvements have been made to the logic and, most of all, readability.
